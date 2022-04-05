#!/bin/bash

# Set the Promt
echo "PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]\[\033[0m\]\n$ '" | sudo tee /etc/profile.d/sh.local
cd /home/ec2-user

echo "sudo cloud-init status --wait" >> .bashrc

function wait_for_jenkins () {
    echo "-- -- -- Waiting on Jenkins to boot up"

    STATUS_CODE="$(curl -s -o /dev/null -I -w "%%{http_code}" http://localhost:8080)"
    while [ $STATUS_CODE -eq 503 ] || [ $STATUS_CODE -eq 000 ]; do
        let STATUS_CODE="$(curl -s -o /dev/null -I -w "%%{http_code}" http://localhost:8080)"
        printf .
        sleep 1
    done

    echo
    echo "-- -- -- Jenkins is running"
}

echo "Installs dependencies ----------"
sudo amazon-linux-extras install epel -y
sudo yum update -y
sudo yum install yum-utils -y
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

echo "Installing Jenkins and Dependencies ----------"
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade -y
sudo yum install jenkins git docker terraform -y

sudo amazon-linux-extras install java-openjdk11 -y

echo "Installing Kubernetes and Dependencies ----------"
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo >/dev/null
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo yum install -y kubelet kubeadm kubectl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

echo "Services ----------"
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl start jenkins

echo "Sleeps for a bit to setup everything ----------"
wait_for_jenkins

sudo usermod -a -G docker jenkins

echo "Remove Setup Wizard ----------"
JAVA_OPTIONS='JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"'
REGEX_PAT='JENKINS_JAVA_OPTIONS=.*'

sudo cat /etc/sysconfig/jenkins | sed 's/'"$REGEX_PAT"'/'"$JAVA_OPTIONS"'/1' | sudo tee ./somefile.txt >/dev/null
cat ./somefile.txt | sudo tee /etc/sysconfig/jenkins >/dev/null
rm ./somefile.txt

sudo systemctl restart jenkins
wait_for_jenkins

echo "Get Jenkins CLI ----------"
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

echo "Exporting Environment Variables ----------"
export AWS_ACCESS_KEY=${aws_access_key}
export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}

export AWS_REGION=${aws_secret_region}
export AWS_SERVICES_SECRET=${aws_secret_services}
export AWS_ECS_SECRET=${aws_ecs_secret}
export AWS_EKS_SECRET=${aws_eks_secret}
export TERRAFORM_SECRET=${terraform_secret}
export SONARQUBE_TOKEN=${sonarqube_token}
export SONARQUBE_URL=${sonarqube_url}
export JENKINS_URL=${jenkins_url}

export S3_BUCKET=${s3_bucket}

export JENKINS_USER_ID=${jenkins_user_id}
export JENKINS_API_TOKEN=${jenkins_api_token}
export JENKINS_PASSWORD=$(echo -n ${jenkins_password} | base64 -d)

export JENKINS_URL=http://localhost:8080
export JENKINS_HOME="/var/lib/jenkins"

export RESOURCE_ID=${resource_secret_name}

echo 'Installing Plugins ----------'
aws s3 cp s3://$S3_BUCKET/plugins_list ./plugins_list.txt
PLUGINS_LIST=$(cat ./plugins_list.txt)

sleep 10
for plugin in $${PLUGINS_LIST};
do
    java -jar jenkins-cli.jar install-plugin "$${plugin//[$'\t\r\n']}" -deploy
done

java -jar jenkins-cli.jar safe-restart

echo "Creating Config YAML ----------"
cat > "$JENKINS_HOME"/jenkins.yaml <<EOF
${jenkins_config}
EOF

sudo systemctl restart jenkins
wait_for_jenkins

echo "Creating Job XML files ----------"
mkdir "$JENKINS_HOME"/configs
mkdir ./jenkins_jobs

# Services
aws s3 cp s3://$S3_BUCKET/users_pipeline_XML ./jenkins_jobs/UsersPipeline.xml
aws s3 cp s3://$S3_BUCKET/flights_pipeline_XML ./jenkins_jobs/FlightsPipeline.xml
aws s3 cp s3://$S3_BUCKET/bookings_pipeline_XML ./jenkins_jobs/BookingsPipeline.xml

cat ./jenkins_jobs/UsersPipeline.xml | java -jar jenkins-cli.jar create-job UsersPipeline
cat ./jenkins_jobs/FlightsPipeline.xml | java -jar jenkins-cli.jar create-job FlightsPipeline
cat ./jenkins_jobs/BookingsPipeline.xml | java -jar jenkins-cli.jar create-job BookingsPipeline

# Deployments
aws s3 cp s3://$S3_BUCKET/ecs_deploy_XML ./jenkins_jobs/ECSDeploy.xml
aws s3 cp s3://$S3_BUCKET/eks_deploy_XML ./jenkins_jobs/EKSDeploy.xml
aws s3 cp s3://$S3_BUCKET/terraform_XML ./jenkins_jobs/Terraform.xml

cat ./jenkins_jobs/ECSDeploy.xml | java -jar jenkins-cli.jar create-job ECSDeploy
cat ./jenkins_jobs/EKSDeploy.xml | java -jar jenkins-cli.jar create-job EKSDeploy
cat ./jenkins_jobs/Terraform.xml | java -jar jenkins-cli.jar create-job Terraform

sudo systemctl restart jenkins
wait_for_jenkins

rm "$JENKINS_HOME"/jenkins.yaml

echo "Docker Compose Setup ----------"
curl -L https://raw.githubusercontent.com/docker/compose-cli/main/scripts/install/install_linux.sh | sh

echo "Install KMS Encrypt and Decrypt Scripts"
pip3 install aws-encryption-sdk-cli
aws s3 cp s3://$S3_BUCKET/KMS_ENCRYPT /usr/local/bin/kms-encrypt.sh
aws s3 cp s3://$S3_BUCKET/KMS_DECRYPT /usr/local/bin/kms-decrypt.sh

# Changing permissions
chmod +x /usr/local/bin/kms-encrypt.sh
chmod +x /usr/local/bin/kms-decrypt.sh

aws sns publish \
--topic-arn arn:aws:sns:$AWS_REGION:${user_id}:${sns_topic} \
--region $AWS_REGION \
--message "User script for the Jenkins Instance finished running at $(date)"