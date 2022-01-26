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

echo "Installing Jenkins ----------"
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade -y
sudo yum install jenkins java-1.8.0-openjdk-devel git docker -y

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

export JENKINS_USER_ID=${jenkins_user_id}
export JENKINS_API_TOKEN=${jenkins_api_token}
export JENKINS_PASSWORD=$(echo -n ${jenkins_password} | base64 -d)

export JENKINS_URL=http://localhost:8080
export JENKINS_HOME="/var/lib/jenkins"

echo 'Installing Plugins ----------'
PLUGINS_LIST="
${plugins_list}
"

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
mkdir ./jenkins_views

cat > ./jenkins_jobs/UsersPipeline.xml <<'EOF'
${users_pipeline_XML}
EOF

cat > ./jenkins_jobs/FlightsPipeline.xml <<'EOF'
${flights_pipeline_XML}
EOF

cat > ./jenkins_jobs/BookingsPipeline.xml <<'EOF'
${bookings_pipeline_XML}
EOF

cat > ./jenkins_jobs/ECSDeploy.xml <<'EOF'
${ecs_deploy_XML}
EOF

cat ./jenkins_jobs/UsersPipeline.xml | java -jar jenkins-cli.jar create-job UsersPipeline
cat ./jenkins_jobs/FlightsPipeline.xml | java -jar jenkins-cli.jar create-job FlightsPipeline
cat ./jenkins_jobs/BookingsPipeline.xml | java -jar jenkins-cli.jar create-job BookingsPipeline
cat ./jenkins_jobs/ECSDeploy.xml | java -jar jenkins-cli.jar create-job ECSDeploy

sudo systemctl restart jenkins
wait_for_jenkins

rm "$JENKINS_HOME"/jenkins.yaml

echo "Docker Compose Setup ----------"
curl -L https://raw.githubusercontent.com/docker/compose-cli/main/scripts/install/install_linux.sh | sh