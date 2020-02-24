resource "aws_vpc" "jenkins" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "Jenkins VPC"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.jenkins.id
}

/*
  NAT Instance
*/
resource "aws_security_group" "nat" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"
  vpc_id      = aws_vpc.jenkins.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr]
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

  tags = {
    Name = "NAT SG"
  }
}

resource "aws_instance" "nat" {
  ami                    = data.aws_ami.vpc_nat.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.auth.key_name
  availability_zone      = var.availability_zone
  vpc_security_group_ids = [aws_security_group.nat.id]
  subnet_id              = aws_subnet.jenkins_public_1.id
  source_dest_check      = false

  tags = {
    Name = "VPC NAT"
  }
}

resource "aws_eip" "nat" {
  instance = aws_instance.nat.id
  vpc      = true
}

/*
  Public Subnet
*/

resource "aws_subnet" "jenkins_public_1" {

  vpc_id                  = aws_vpc.jenkins.id
  cidr_block              = var.public_1_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Jenkins public 1 subnet"
  }
}

resource "aws_subnet" "jenkins_public_2" {

  vpc_id                  = aws_vpc.jenkins.id
  cidr_block              = var.public_2_subnet_cidr
  availability_zone       = var.public_2_subnet_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Jenkins public 2 subnet"
  }
}

resource "aws_route_table" "public_1" {
  vpc_id = aws_vpc.jenkins.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "Jenkins public 1 subnet route"
  }
}

resource "aws_route_table" "public_2" {
  vpc_id = aws_vpc.jenkins.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "Jenkins public 2 subnet route"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.jenkins_public_1.id
  route_table_id = aws_route_table.public_1.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.jenkins_public_2.id
  route_table_id = aws_route_table.public_2.id
}

/*
  Private Subnet
*/

resource "aws_subnet" "jenkins_private" {
  vpc_id            = aws_vpc.jenkins.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "Jenkins private subnet"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.jenkins.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.jenkins_private.id
  route_table_id = aws_route_table.private.id
}
