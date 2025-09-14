## Jenkins Server Deployment

Terraform will also provision a Jenkins server on a separate EC2 instance.

### Access Jenkins

1. Get the Jenkins EC2 public IP from the AWS Console or by running:
   ```bash
   terraform output
   ```
2. Open Jenkins in your browser:
   ```
   http://<JENKINS_EC2_PUBLIC_IP>:8080
   ```
3. Get the initial admin password:
   ```bash
   ssh -i /home/surya/Project3/devops-key.pem ubuntu@<JENKINS_EC2_PUBLIC_IP>
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
4. Complete the Jenkins setup wizard in your browser.

Jenkins is pre-installed with Docker and ready for pipeline configuration.
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

## SSH Access
To SSH into your EC2 instance, use:
```bash
ssh -i /home/surya/Project3/devops-key.pem ubuntu@<EC2_PUBLIC_IP>
```

## CloudWatch & SNS
- Logs from the Docker container are sent to CloudWatch Log Group `/aws/react-app`.
- EC2 health alarms are set up; alerts are sent to your email via SNS if the instance fails status checks.

## Cleanup
To destroy all resources:
```bash
terraform destroy
```
