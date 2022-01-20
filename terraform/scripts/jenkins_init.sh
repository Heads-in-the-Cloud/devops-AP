#!/bin/bash
"this lock!" > lock.txt

sudo yum update -y
sudo yum upgrade -y

sudo yum install docker -y

sudo systemctl daemon-reload
sudo systemctl start docker
sudo usermod -a -G docker jenkins

wget http://localhost:8080/jnlpJars/jenkins-cli.jar

echo Exporting Environment Variables ----------
export AWS_ACCESS_KEY=${aws_access_key}
export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}

export JENKINS_URL=http://localhost:8080
export JENKINS_USER_ID=${jenkins_user_id}
export JENKINS_API_TOKEN=${jenkins_api_token}
export JENKINS_HOME="/var/lib/jenkins"
export CASC_JENKINS_CONFIG="/var/lib/jenkins/configs"

mkdir "$JENKINS_HOME"/configs

echo Installing Plugins ----------
java -jar jenkins-cli.jar install-plugin pipeline-utility-steps -deploy
java -jar jenkins-cli.jar install-plugin ec2 -deploy
java -jar jenkins-cli.jar install-plugin amazon-ecr -deploy
java -jar jenkins-cli.jar install-plugin configuration-as-code -deploy

echo Plugins are updating ----------
UPDATE_LIST=$( java -jar jenkins-cli.jar list-plugins | grep -e ')$' | awk '{ print $1 }' | tr '\n' ' ' )
if [ -n "$${UPDATE_LIST}" ]; then
    for plugin in $${UPDATE_LIST};
    do
        echo Updating plugin: $plugin
        java -jar jenkins-cli.jar install-plugin -deploy $plugin
    done

    java -jar jenkins-cli.jar safe-restart
fi

echo Creating Credentials YAML ----------
cat > "$JENKINS_HOME"/jenkins.yaml <<EOF
${jenkins_config}
EOF

echo AWS_ACCESS_KEY=$AWS_ACCESS_KEY | sudo tee -a /etc/profile.d/sh.local
echo AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY | sudo tee -a /etc/profile.d/sh.local

echo JENKINS_URL=http://localhost:8080 | sudo tee -a /etc/profile.d/sh.local
echo JENKINS_USER_ID=$JENKINS_USER_ID | sudo tee -a /etc/profile.d/sh.local
echo JENKINS_API_TOKEN=$JENKINS_API_TOKEN | sudo tee -a /etc/profile.d/sh.local
echo JENKINS_HOME=$JENKINS_HOME | sudo tee -a /etc/profile.d/sh.local
echo CASC_JENKINS_CONFIG=$CASC_JENKINS_CONFIG | sudo tee -a /etc/profile.d/sh.local

sudo systemctl restart jenkins

rm lock.txt