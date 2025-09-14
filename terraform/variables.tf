variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (use latest Ubuntu 20.04 LTS or similar)"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name for EC2 login"
}

variable "my_ip_cidr" {
  description = "Your IP address in CIDR notation for SSH access (e.g., 1.2.3.4/32)"
}

variable "alert_email" {
  description = "Email address to receive SNS alerts"
}
