# Jenkins Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins UI"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data     = file("${path.module}/jenkins_user_data.sh")
  tags = {
    Name = "jenkins-server"
  }
}
# Terraform main configuration for React app deployment on AWS

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "react_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.react_sg.id]
  user_data     = file("${path.module}/user_data.sh")
  tags = {
    Name = "react-app-server"
  }
}

resource "aws_security_group" "react_sg" {
  name        = "react-app-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "react_logs" {
  name = "/aws/react-app"
  retention_in_days = 7
}

resource "aws_sns_topic" "alert_topic" {
  name = "react-app-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch alarm for EC2 status check failed
resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  alarm_name          = "EC2StatusCheckFailed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors EC2 instance status check failures."
  alarm_actions       = [aws_sns_topic.alert_topic.arn]
  dimensions = {
    InstanceId = aws_instance.react_app.id
  }
}
