#!/bin/bash

# Set the Promt
echo "PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]\[\033[0m\]\n$ '" | sudo tee /etc/profile.d/sh.local
cd /home/ec2-user

echo "sudo cloud-init status --wait" >> .bashrc

function wait_for_sonarqube () {
    echo "-- -- -- Waiting on SonarQube to boot up"

    STATUS_CODE="$(curl -s -o /dev/null -I -w "%%{http_code}" http://localhost:9000)"
    while [ $STATUS_CODE -eq 503 ] || [ $STATUS_CODE -eq 000 ]; do
        let STATUS_CODE="$(curl -s -o /dev/null -I -w "%%{http_code}" http://localhost:9000)"
        printf .
        sleep 1
    done

    echo
    echo "-- -- -- SonarQube is running"
}

echo "Installs dependencies ----------"
sudo amazon-linux-extras install epel -y
sudo yum update -y

sudo yum install docker jq -y
sudo amazon-linux-extras install java-openjdk11 -y

sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
sudo ulimit -n 131072
sudo ulimit -u 8192

sudo systemctl daemon-reload
sudo systemctl start docker

sudo usermod -a -G docker ec2-user

echo "Install PostgreSQL"
sudo amazon-linux-extras install postgresql10
sudo yum install -y postgresql-server postgresql-devel -y
sudo /usr/bin/postgresql-setup --initdb

cat <<EOF | sudo tee /var/lib/pgsql/data/pg_hba.conf >/dev/null
local   all     sonar   md5
local   all     all     peer
host    all     all     127.0.0.1/32    md5
host    all     all     ::1/128         md5
EOF

sudo systemctl daemon-reload
sudo systemctl start postgresql
sudo systemctl enable postgresql

export JDBC_USER="sonar"
export JDBC_PASSWORD="wow"
export DB_NAME="sonarqube"

sudo -u postgres psql postgres -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql postgres -c "CREATE USER $JDBC_USER WITH ENCRYPTED PASSWORD '$JDBC_PASSWORD';"
sudo -u postgres psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME to $JDBC_USER;"

sudo systemctl restart postgresql

cd /opt

sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.3.0.51899.zip
sudo unzip sonarqube-9.3.0.51899.zip
sudo mv sonarqube-9.3.0.51899 sonarqube

sudo cat /opt/sonarqube/conf/sonar.properties |\
sed 's|#sonar.jdbc.username=.*|sonar.jdbc.username='"$JDBC_USER"'|1' |\
sed 's|#sonar.jdbc.password=.*|sonar.jdbc.password='"$JDBC_PASSWORD"'|1' |\
sed 's|#sonar.jdbc.url=.*|'"sonar.jdbc.url=jdbc:postgresql://localhost/$DB_NAME"'|1' |\
sed 's|#sonar.web.javaOpts=.*|sonar.web.javaOpts=-Djava.net.preferIPv4Stack=true|1' |\
sed 's|#sonar.web.javaAdditionalOpts=.*|sonar.web.javaAdditionalOpts=-server|1' |\
sudo tee /opt/somefile.properties >/dev/null
cat /opt/somefile.properties | sudo tee /opt/sonarqube/conf/sonar.properties >/dev/null
rm /opt/somefile.properties

sudo cat /opt/sonarqube/bin/linux-x86-64/sonar.sh |\
sed 's|#RUN_AS_USER=.*|RUN_AS_USER=sonar|1' |\
sudo tee /opt/somefile.sh >/dev/null
cat /opt/somefile.sh | sudo tee /opt/sonarqube/bin/linux-x86-64/sonar.sh >/dev/null
sudo rm /opt/somefile.sh

sudo useradd sonar
sudo chown -R sonar:sonar /opt/sonarqube
sudo chmod -R 775 /opt/sonarqube

echo "DefaultLimitNOFILE=65536" | sudo tee -a /etc/systemd/user.conf
echo "DefaultLimitNOFILE=65536" | sudo tee -a /etc/systemd/system.conf

cat <<EOF | sudo tee -a /etc/security/limits.conf
*  soft    nofile  65536
*  hard    nofile  65536
elasticsearch   soft    nofile  65536
elasticsearch   hard    nofile  65536
elasticsearch   memlock unlimited
EOF

echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo systemctl restart postgresql

cd /opt/sonarqube/bin/linux-x86-64
./sonar.sh start

echo "Exporting Environment Variables ----------"
export AWS_REGION=${aws_secret_region}

wait_for_sonarqube

aws sns publish \
--topic-arn arn:aws:sns:$AWS_REGION:${user_id}:${sns_topic} \
--region $AWS_REGION \
--message "User script for the SonarQube Instance finished running at $(date)"