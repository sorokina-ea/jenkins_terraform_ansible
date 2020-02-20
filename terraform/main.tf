provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_pair_name
  public_key = "${file("${path.module}/${var.public_key_path}")}"
}

resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu18.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.auth.key_name
  vpc_security_group_ids = [aws_security_group.JenkinsSG.id]
  count                  = var.jenkins_master_instance_count

  tags = {
    Name = "Jenkins Master"
  }
}

resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.ubuntu18.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.auth.key_name
  vpc_security_group_ids = [aws_security_group.JenkinsSlaveSG.id]
  count                  = var.jenkins_slaves_instance_count

  tags = {
    Name = "Jenkins Slave"
  }
}

resource "aws_security_group" "JenkinsSG" {
  name        = "JenkinsSG"
  description = "Allow HTTP and SSH to Jenkins server"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "JenkinsSlaveSG" {
  name        = "JenkinsSlaveSG"
  description = "Allow SSH to Jenkins slaves"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
