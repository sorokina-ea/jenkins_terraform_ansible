#!/bin/bash

# Create ssh key
ssh-keygen -m PEM -t rsa -b 2048 -C jenkins@jenkins -f jenkins.pem -N "" -q
chmod 600 jenkins.pem
mv jenkins.pem.pub jenkins.pub

# Go to terraform directory and download required for run plugins
cd terraform
terraform init

# Run terraform plan and apply with auto-approve, if you're pretty sure, what you are doing
terraform plan -auto-approve
terraform apply -auto-approve

# Run Ansible
cd ../ansible
ansible-playbook -i ec2.py linux_jenkins_slave.yml
ansible-playbook -i ec2.py linux_jenkins_installation.ym
