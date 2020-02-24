resource "aws_security_group" "alb_sg" {
  name        = "jenkins-master-alb-sg"
  description = "Control access to ALB"
  vpc_id      = aws_vpc.jenkins.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins-master-alb-sg"
  }
}

resource "aws_alb" "jenkins_master_alb" {
  name               = "jenkins-master-alb"
  internal           = false
  subnets            = [aws_subnet.jenkins_public_1.id, aws_subnet.jenkins_public_2.id]
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  tags = {
    Name = "jenkins-master-alb"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS ALB Target Group
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_alb_target_group" "jenkins_master_alb_tg" {
  depends_on  = [aws_alb.jenkins_master_alb]
  name        = "jenkins-master-alb-tg"
  protocol    = "HTTP"
  port        = 8080
  vpc_id      = aws_vpc.jenkins.id
  target_type = "instance"
  health_check {
    path = "/"
    port = 8080
  }
  tags = {
    Name = "jenkins-master-alb-tg"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS ALB Listener
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_alb_listener" "jenkins_master_web_listener" {
  load_balancer_arn = aws_alb.jenkins_master_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.jenkins_master_alb_tg.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "jenkins_master" {
  target_group_arn = aws_alb_target_group.jenkins_master_alb_tg.arn
  target_id        = aws_instance.jenkins_master.id
  port             = 8080
}
