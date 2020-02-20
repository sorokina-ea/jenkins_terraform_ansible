variable "aws_region" {
  description = "Region"
  default     = "eu-central-1"
}

variable "key_pair_name" {
  description = "name of ssh key to create"
  default     = "jenkins"
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
