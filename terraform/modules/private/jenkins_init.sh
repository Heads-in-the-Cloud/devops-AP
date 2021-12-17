#!/bin/bash

# Set the Promt
echo "PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]\[\033[0m\]\n$ '" | sudo tee /etc/profile.d/sh.local

# Installs dependencies
sudo amazon-linux-extras install epel -y
sudo yum update -y

# Installing Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade
sudo yum install jenkins java-1.8.0-openjdk-devel -y

# Services
sudo systemctl daemon-reload
sudo systemctl start jenkins