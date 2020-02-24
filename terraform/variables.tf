variable "aws_region" {
  description = "Region"
  default     = "eu-central-1"
}

variable "aws_key_pair_name" {
  description = "name of ssh key to create"
  default     = "jenkins"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "public_1_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "10.0.0.0/24"
}

variable "public_2_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for all resources"
  default     = "eu-central-1b"
}

variable "public_2_subnet_availability_zone" {
  description = "Availability zone for all resources"
  default     = "eu-central-1a"
}

variable "public_key_path" {
  description = "Path to ssh public key used to create this key on AWS"
}

variable "private_key_path" {
  description = "Path to the private key used to connect to instance"
}

variable "ssh_user" {
  description = "User used to log in to instance"
  default     = "ubuntu"
}

variable "jenkins_master_instance_count" {
  default = "1"
}

variable "jenkins_slaves_instance_count" {
  default = "1"
}
