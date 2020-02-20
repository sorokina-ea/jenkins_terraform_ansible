# General
Quick start on how to provision Jenkins CI/CD using terraform amd ansible scripts

## Pre-requisites:
This playbook is written for Linux only with the focus on Ubuntu18.04.

You should have the following software installed on your host
1. terraform
2. ansible
3. python

## Project structure
* ansible - folder with ansible playbooks, inventories, etc.
* terraform - folder with terraform infrastructure files
```
|-- ansible
|   |-- roles
|   |   |-- ansible-role-java
|   |   `-- ansible-role-jenkins
|   |-- templates
|   `-- tmp
|-- jenkins
|-- terraform

```
## Getting started
Prepend environment for using ansible dynamic inventory with Amazon ec2:
```
$ pip install boto
$ chmod +x ansible/ec2.py
```
Of course, you'll need to have AWS credentials. By default you can find it in  ~/.aws/credentials
```
$ cat ~/.aws/credentials
[default]
aws_access_key_id = <AWS_ACCESS_TOKEN>
aws_secret_access_key = <AWS_SECRET_ACCESS_KEY>
...
```
To run this automation right now with defaults:
```
chmod a+x run.sh
./run.sh
```

Or go though the next topic.

## Usage
Ansible and Terraform scripts will ask you for private and public ssh keys.
In case you have no existed one, follow the instruction below:
```
ssh-keygen -m PEM -t rsa -b 2048 -C jenkins@jenkins -f jenkins.pem -N "" -q
chmod 600 jenkins.pem
mv jenkins.pem.pub jenkins.pub
```

Or set your variables in "terraform.tfvars" and "vars/jenkins_vars.yml" files accordingly.
```
public_key_path = "../jenkins.pub"
private_key_path = "../jenkins.pem"
key_pair_name = "jenkins"
```

### Terraform
Go to terraform folder and download all required plugins.
```
$ cd terraform
$ terraform init
```

If your want to see plan of your own infrastructure

```
$ terraform plan
```
OR if you would like to pass variables directly to the script against usage of .tfvars file
```
$ terraform plan -var private_key_path = <path_to_your_private_key> -var public_key_path = <path_to_your_public_key>
```

To create all resources and provision all services
```
$ terraform apply
```
OR
```
$ terraform apply -var private_key_path = <path_to_your_private_key> -var public_key_path = <path_to_your_public_key>
```
Now your resources should be successfully created and available in AWS Console.

To delete all created resources
```
$ terraform destroy
```
OR
```
$ terraform destroy -var private_key_path = <path_to_your_private_key> -var public_key_path = <path_to_your_public_key>
```

### Ansible
Go to ansible folder to configure Jenkins Master and Jenkins Slave hosts.
```
$ cd ansible

```

The next step will configure Jenkins Slave host(s).
This playbook will install java, maven packages and create configuration file for the slaves.
Run the following command, if you use `vars/jenkins_vars.yml`
```
ansible-playbook -i ec2.py linux_jenkins_slave.yml

```
OR insert your variables to command line
```
ansible-playbook -i ec2.py linux_jenkins_slave.yml -u ubuntu --private-key=<path_to_your_private_key> -e "ansible_python_interpreter=/usr/bin/python3" -e "<your_extra_vars>"

```

To install and configure Jenkins Master server, please execute 'linux_jenkins_installation.yml' playbook
```
ansible-playbook -i ec2.py linux_jenkins_installation.yml
```
OR
```
ansible-playbook -i ec2.py linux_jenkins_installation.yml -u ubuntu --private-key=<path_to_your_private_key> -e "ansible_python_interpreter=/usr/bin/python3" -e "<your_extra_vars>"
```

Now you could use your new Jenkins!

# Terraform structure
```
terraform
|-- data.tf        # data sources
|-- main.tf        # contain general infrastructure description
|-- output.tf      # contain variables, that will be printed as an output
|-- variables.tf   # define all required variables with description and default values

```
### General
Terraform script will create required infrastructure, based on AWS Cloud EC2 instances.
Will create requested amount of hosts for Jenkins Master and Slaves.
At the same time the security group will be configured and assigned for them.

#### Input variables
Terraform scripts get the following variables as an input:
```
"aws_region"
  description: "AWS EC2 Region"
  default value: "eu-central-1"

"key_pair_name"
  description: "Name of key pair that will be generated in AWS for further access to the instances"
  default value: "jenkins"

"public_key_path"
  description: "Path to SSH public key"
  default value: has no default value

"private_key_path"
  description: "Path to the SSH private key"
  default value: has no default value

"ssh_user"
  description: "User used to log in to instance"
  default value: "ubuntu"

"jenkins_slaves_instance_count"
  description: "Count of EC2 instances allocated for Jenkins master"
  default = "1"

"jenkins_slaves_instance_count"
  description: "Count of EC2 instances allocated for Jenkins Slaves"
  default value: "1"
```

#### Output variables

```
"key_pair_name": AWS key pair name

"public_key_path": Path to SSH public key

"private_key_path": Path to SSH private key

"jenkins_master_sg_id": Security group ID applied for Jenkins Master host

"jenkins_slave_sg_id": Security group ID applied for Jenkins Slave hosts

"jenkins_master_public_ip": Public IP address of created Jenkins Master host

"jenkins_master_public_dns": Public DNS names of created Jenkins Master host

"jenkins_slave_public_ip": Public IP addresses of created Jenkins Slave hosts

"jenkins_slave_public_dns": Public DNS names of created Jenkins Slave hosts

"ami_id": ID of EC2 image used for resources

"aws_region": Region used in resource creation
```

# Ansible structure

```
|-- ansible
|   |-- roles
|   |   |-- ansible-role-java
|   |   `-- ansible-role-jenkins
|   |-- templates
|   |-- vars
```

### General
Ansible directory contain all required stuff to configure Jenkins Master and Slave hosts.

#### playbooks

* Playbook: linux_jenkins_slave.yml
  * Install:
    - package updates
    - java (default: java11)
    - maven
  * Generate slave host configuration file from template `templates/jenkins-slave.xml.j2`

* Playbook: `linux_jenkins_installation.yml` includes:
  * Install:
    - package updates
    - java (default: java11)
    - jenkins (default: stable)

  * Configure:
    - pipeline job
    - slave hosts

#### inventory
In this configuration is used dynamic inventory script ec2.py, which takes information from AWS Cloud.
Please find more information https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#inventory-script-example-aws-ec2

#### roles/ - directory with roles used in the playbooks
* ansible-role-java. Find more information here: "https://github.com/geerlingguy/ansible-role-java"

* ansible-role-jenkins. Find more information here: "https://github.com/geerlingguy/ansible-role-jenkins"

#### vars/ - variables used for playbooks
Variable used in Ansible script:
```
# Default user for ssh connection during playbook execution. Used "ubuntu" value, because instances run on Ubuntu18.04 image
ansible_ssh_user: "ubuntu"

# SSH public and private key paths. Used for connection and for some templates
public_key_path: "../jenkins-master.pub"
private_key_path: "../jenkins-master.pem"
# SSH public and private keys values uploaded to specific variable. Used in templates.
public_key: "{{ lookup('file', '{{ public_key_path }}' )}}"
private_key: "{{ lookup('file', '{{ private_key_path }}' )}}"

# Variables used for Jenkins Master and Jenkins Slaves configuration
jenkins_admin_username: admin
jenkins_admin_password: admin
jenkins_hostname: "{{ ec2_public_dns_name }}"
jenkins_http_port: 8080
jenkins_jar_location: /opt/jenkins-cli.jar
jenkins_slave_packages:
  - maven

# Variables for jenkins-slave.xml.j2
# Number of executors for each slave host
num_executors: 1
# Default label for slaves
jenkins_slave_label: "jenkins-slave"
# SSH port for connection to slave
ssh_port: 22
# Credential ID used for connection to slave
credentials_id: "ubuntu"

# Variables for job_config.xml.j2
# Git repository with source code
git_repo: "https://github.com/sorokina-ea/simple-java-maven-app.git"
# Default branch
default_branch: master
# Job will be created with this name
jenkins_job_name: "maven-project-pipeline"

```
Please find more information about role variables:
* Role: ansible-role-java following path "ansible/roles/ansible-role-java/README.md" or "https://github.com/geerlingguy/ansible-role-java"
* Role: ansible-role-jenkins following path "ansible/roles/ansible-role-jenkins/README.md" or "https://github.com/geerlingguy/ansible-role-jenkins"

#### templates/ - template files used for Jenkins slave nodes, jobs, etc.

```
|   |-- templates
|   |   |-- aws_ec2_cloud_configuraiton.groovy.j2  # Template to add slaves as a dynamic slaves evaluated on request
|   |   |-- credentials.groovy.j2                  # Template for groovy script, created credentials
|   |   |-- credentials.xml.j2                     # Template for credentials generation wiht SSH key
|   |   |-- jenkins-slave.xml.j2                   # Template for Jenkins slaves configuration
|   |   `-- job_config.xml.j2                      # Template for job configuration wiht pipeline
```
