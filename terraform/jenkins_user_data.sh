#!/bin/bash
# Install Java
apt-get update
apt-get install -y openjdk-11-jdk

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y jenkins
systemctl start jenkins
systemctl enable jenkins

# Install Docker
apt-get install -y docker.io
usermod -aG docker jenkins
systemctl restart docker
systemctl restart jenkins

# Open firewall for Jenkins (if ufw is enabled)
if command -v ufw >/dev/null 2>&1; then
  ufw allow 8080/tcp
fi
