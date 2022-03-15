#!/bin/bash

# Set the Promt
echo "PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]\[\033[0m\]\n$ '" | sudo tee /etc/profile.d/sh.local

# Installs dependencies
sudo yum update -y
sudo amazon-linux-extras install epel -y

# Installs the MATE Desktop environment
sudo amazon-linux-extras install mate-desktop1.x -y
sudo bash -c 'echo PREFERRED=/usr/bin/mate-session > /etc/sysconfig/desktop'

# Installs a VNC server and sets a password
sudo yum install tigervnc-server -y

export HOME="/home/ec2-user"
echo "Value of the home variable:" $HOME

vncserver :1 <<EOF
${password}
${password}
n
EOF
vncserver -kill :1

# Sets up the service for the vnc server
sudo cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@.service
sudo sed -i 's/<USER>/ec2-user/' /etc/systemd/system/vncserver@.service

# Starts the VNC server and service
sudo systemctl daemon-reload
sudo systemctl enable vncserver@:1
sudo systemctl start vncserver@:1

# Installs the chromium browser
sudo yum install chromium -y

vncserver :1 <<EOF
${password}
${password}
n
EOF