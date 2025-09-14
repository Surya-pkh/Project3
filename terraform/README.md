# Terraform AWS Deployment for React App

## Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform installed
- Docker image pushed to Docker Hub (prod repo)

## Variables to Set
- `aws_region`: AWS region (default: us-east-1)
- `ami_id`: Ubuntu 20.04 LTS AMI ID for your region
- `instance_type`: EC2 instance type (default: t2.micro)
- `key_name`: Your AWS EC2 SSH key name
- `my_ip_cidr`: Your IP in CIDR format (e.g., 1.2.3.4/32)
- `alert_email`: Email to receive SNS alerts

## Usage
1. Edit `terraform.tfvars` or pass variables via CLI:
   ```hcl
   aws_region    = "us-east-1"
   ami_id        = "ami-xxxxxxxxxxxxxxxxx"
   instance_type = "t2.micro"
   key_name      = "your-key-name"
   my_ip_cidr    = "YOUR.IP.ADDRESS/32"
   alert_email   = "your@email.com"
   ```
2. Initialize and apply:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```
3. Approve the plan. The EC2 instance will launch, auto-deploy the Docker app, and set up CloudWatch and SNS.

## CloudWatch & SNS
- Logs from the Docker container are sent to CloudWatch Log Group `/aws/react-app`.
- EC2 health alarms are set up; alerts are sent to your email via SNS if the instance fails status checks.

## Cleanup
To destroy all resources:
```bash
terraform destroy
```
