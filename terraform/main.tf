provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "auth" {
  key_name   = var.aws_key_pair_name
  public_key = "${file("${path.module}/${var.public_key_path}")}"
}

resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu18.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.auth.key_name
  availability_zone      = var.availability_zone
  vpc_security_group_ids = [aws_security_group.JenkinsSG.id]
  subnet_id              = aws_subnet.jenkins_private.id

  tags = {
    Name = "Jenkins Master"
  }
}

resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.ubuntu18.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.auth.key_name
  availability_zone      = var.availability_zone
  vpc_security_group_ids = [aws_security_group.JenkinsSlaveSG.id]
  subnet_id              = aws_subnet.jenkins_private.id
  count                  = var.jenkins_slaves_instance_count
  source_dest_check      = false

  tags = {
    Name = "Jenkins Slave"
  }
}

resource "aws_security_group" "JenkinsSG" {
  name        = "JenkinsSG"
  description = "Allow HTTP and SSH to Jenkins server"
  vpc_id      = aws_vpc.jenkins.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
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
  vpc_id      = aws_vpc.jenkins.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
