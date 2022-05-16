#!/bin/bash

set -ex

echo "Add an enrollment token"
sudo mkdir -p /var/lib/sftd
echo "${enrollment_token}" | sudo tee /var/lib/sftd/enrollment.token

curl -C - https://asascriptstorage.blob.core.windows.net/newcontainer/OktaAccessAddress.sh -o /home/shi/OktaAccessAddress.sh

sudo chmod +x /home/shi/OktaAccessAddress.sh

sudo systemctl enable crond.service

echo "@reboot /home/shi/OktaAccessAddress.sh" | sudo tee -a /var/spool/cron/root
sudo systemctl start crond.service

echo "Modify the redhat.conf file"
sudo sed -i 's|\tInclude|\t#Include|g' /etc/ssh/ssh_config.d/*-redhat.ssh_config

#Add the Advanced Server Access yum repository:
curl -C - https://pkg.scaleft.com/scaleft_yum.repo | sudo tee /etc/yum.repos.d/scaleft.repo

#Import the repository signing key to your local keyring:
sudo rpm --import https://dist.scaleft.com/pki/scaleft_rpm_key.asc

sudo yum update -y

#Install the server tools package, which includes the agent:
sudo yum install scaleft-server-tools -y

sudo /home/shi/OktaAccessAddress.sh

sudo sleep 10

echo "CASignatureAlgorithms +ssh-rsa" | sudo tee -a /etc/ssh/sshd_config

sudo systemctl restart sshd
sudo systemctl restart sftd
