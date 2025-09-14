# Project3: Complete DevOps Deployment Guide

## 🎯 Overview

This guide provides a complete, production-ready deployment solution for a React application using modern DevOps practices. The solution includes automated CI/CD pipelines, infrastructure as code, monitoring, and security best practices.

### 🏗️ Architecture

```
GitHub Repository → Jenkins CI/CD → Docker Hub → AWS EC2 → CloudWatch + SNS
```

### ✨ Key Features
- **Automated CI/CD**: Push-to-deploy with Jenkins
- **Branch-Based Deployment**: Separate dev/prod environments
- **Infrastructure as Code**: Complete AWS setup with Terraform
- **Zero-Downtime Deployment**: Rolling container updates
- **Production Monitoring**: AWS CloudWatch + SNS alerting
- **Security**: No hardcoded credentials, SSH key management

---

## 📋 Prerequisites

### Required Accounts & Access
- **AWS Account** with permissions for: EC2, IAM, CloudWatch, SNS, VPC
- **Docker Hub Account** (Username: `suryapkh`)
- **GitHub Repository**: https://github.com/Surya-pkh/Project3
- **Email Address** for monitoring alerts

### Required Tools
- **Terraform** (v1.0+)
- **AWS CLI** (configured with credentials)
- **SSH Client**
- **Git**

---

## 🚀 Quick Start (30 minutes)

### 1. Clone and Configure
```bash
git clone https://github.com/Surya-pkh/Project3.git
cd Project3/terraform
cp terraform.tfvars.example terraform.tfvars
```

### 2. Update Configuration
Edit `terraform/terraform.tfvars`:
```hcl
aws_region = "us-west-2"
ami_id = "ami-053b0d53c279acc90"  # Ubuntu 20.04 LTS
instance_type = "t2.micro"
key_name = "your-aws-key-name"
my_ip_cidr = "YOUR_PUBLIC_IP/32"
alert_email = "your-email@domain.com"
```

### 3. Deploy Infrastructure
```bash
cd terraform
terraform init
terraform apply
```

### 4. Setup Jenkins (5 minutes)
```bash
# Get Jenkins URL from output
terraform output jenkins_public_ip
# Open http://JENKINS_IP:8080 and follow setup wizard
```

### 5. Test Deployment
```bash
git push origin master  # Triggers production deployment
git push origin dev     # Triggers development deployment
```

---

## 🏗️ Detailed Infrastructure Setup

### Terraform Configuration

#### **Core Resources Created:**
- **EC2 Instances**: Application server + Jenkins server
- **Security Groups**: HTTP/HTTPS + SSH access control
- **CloudWatch**: Log groups + metric alarms
- **SNS**: Email alerting system
- **SSH Key Management**: Automated key distribution

#### **Key Files:**
- `terraform/main.tf` - Infrastructure definitions
- `terraform/variables.tf` - Configurable parameters
- `terraform/user_data.sh` - Application server setup
- `terraform/jenkins_user_data.sh` - Jenkins server setup

### Infrastructure Commands
```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply infrastructure
terraform apply

# Get outputs
terraform output

# Destroy everything (cleanup)
terraform destroy
```

### Security Groups Configuration
- **Jenkins Server**: Port 8080 (Jenkins UI), Port 22 (SSH)
- **Application Server**: Port 80 (HTTP), Port 22 (SSH from local + Jenkins)
- **SSH Access**: Restricted to your IP + Jenkins server IP

---

## 🔧 Jenkins Configuration

### Initial Setup
1. **Access Jenkins**: `http://<JENKINS_PUBLIC_IP>:8080`
2. **Get Admin Password**:
   ```bash
   ssh -i devops-key.pem ubuntu@<JENKINS_IP>
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. **Install Suggested Plugins** + Additional:
   - Docker Pipeline
   - GitHub Integration
   - SSH Agent

### Credentials Configuration
1. **Docker Hub Credentials**:
   - ID: `docker-hub-credentials`
   - Type: Username with password
   - Username: `suryapkh`
   - Password: Your Docker Hub token

2. **GitHub Credentials** (if private repo):
   - Type: Personal Access Token

### Pipeline Job Creation
1. **New Item** → **Pipeline**
2. **Pipeline Definition**: Pipeline script from SCM
3. **SCM**: Git
4. **Repository URL**: `https://github.com/Surya-pkh/Project3.git`
5. **Script Path**: `Jenkinsfile`

### GitHub Webhook Setup
1. **GitHub Repository** → **Settings** → **Webhooks**
2. **Payload URL**: `http://<JENKINS_IP>:8080/github-webhook/`
3. **Content Type**: `application/json`
4. **Events**: Push events

---

## 🔄 CI/CD Pipeline Workflow

### Automated Pipeline Stages

#### 1. **Setup SSH Key**
- Copies SSH key from Jenkins server to workspace
- Sets proper permissions for EC2 access

#### 2. **Branch Detection**
- Automatically detects `dev` or `master` branch
- Routes to appropriate Docker repository:
  - `dev` → `suryapkh/project3-dev`
  - `master` → `suryapkh/project3-prod`

#### 3. **Build and Push** (`build.sh`)
- Builds Docker image with timestamp tag
- Authenticates with Docker Hub
- Pushes to branch-specific repository
- Tags as `latest` for easy deployment

#### 4. **Deploy to EC2** (`deploy.sh`)
- SSH to EC2 application server
- Authenticates server with Docker Hub
- Performs zero-downtime deployment:
  - Stop existing container
  - Pull latest image
  - Start new container
  - Verify deployment
  - Clean up old images

#### 5. **Cleanup**
- Removes temporary images
- Cleans up workspace

### Branch Strategy
```
master branch  → Production Environment  (suryapkh/project3-prod)
dev branch     → Development Environment (suryapkh/project3-dev)
```

### Pipeline Files
- **`Jenkinsfile`**: Pipeline definition
- **`build.sh`**: Automated build and push script  
- **`deploy.sh`**: Automated deployment script
- **`Dockerfile`**: Container definition
- **`nginx.conf`**: Web server configuration

---

## 📊 Monitoring & Alerting

### AWS CloudWatch Integration
- **Log Groups**: Container logs automatically collected
- **Metrics**: EC2 instance health monitoring
- **Alarms**: Automated failure detection

### SNS Email Alerting
- **EC2 Status Check Failed**: Instance health issues
- **Deployment Failures**: CI/CD pipeline errors
- **Application Errors**: Container-level issues

### Monitoring Setup
```bash
# Test CloudWatch alarm manually
aws cloudwatch set-alarm-state \
    --alarm-name "EC2StatusCheckFailed" \
    --state-value ALARM \
    --state-reason "Testing alert system"

# Check alarm status
aws cloudwatch describe-alarms \
    --alarm-names "EC2StatusCheckFailed"
```

### Application Health Checks
```bash
# Check deployment status
curl -I http://<EC2_PUBLIC_IP>

# Check container status
ssh -i devops-key.pem ubuntu@<EC2_IP> 'docker ps -f name=react-app'

# View container logs
ssh -i devops-key.pem ubuntu@<EC2_IP> 'docker logs react-app --tail 50'
```

---

## 🔒 Security Best Practices

### Credential Management
- ✅ **No hardcoded passwords** in any files
- ✅ **Jenkins Credentials Store** for sensitive data
- ✅ **Environment variables** for runtime secrets
- ✅ **SSH key rotation** supported
- ✅ **Docker Hub tokens** instead of passwords

### Network Security
- ✅ **Security Groups** restrict access by IP
- ✅ **SSH access** limited to authorized IPs
- ✅ **HTTPS ready** (certificate can be added)
- ✅ **VPC isolation** (can be enhanced)

### Infrastructure Security
- ✅ **IAM roles** with minimal permissions
- ✅ **Encrypted storage** options available
- ✅ **Regular updates** via user data scripts
- ✅ **Backup strategies** can be implemented

---

## 🛠️ Troubleshooting Guide

### Common Issues & Solutions

#### **Jenkins Build Failures**
```bash
# Issue: Docker permission denied
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Issue: SSH connection timeout  
# Check security groups allow Jenkins IP to EC2

# Issue: Docker Hub authentication failed
# Verify credentials in Jenkins credential store
```

#### **Deployment Failures**
```bash
# Issue: Container won't start
ssh -i devops-key.pem ubuntu@<EC2_IP> 'docker logs react-app'

# Issue: Port 80 not accessible
# Check security groups allow HTTP traffic

# Issue: Image pull failed
# Verify Docker Hub repository exists and is accessible
```

#### **Infrastructure Issues**
```bash
# Issue: AMI not found
# Use correct AMI ID for your AWS region:
# us-west-2: ami-053b0d53c279acc90
# us-east-1: ami-0c02fb55956c7d316

# Issue: Terraform state conflicts
terraform refresh
terraform plan

# Issue: Resource limits exceeded
# Check AWS service limits in console
```

### Debugging Commands
```bash
# Check Jenkins logs
ssh -i devops-key.pem ubuntu@<JENKINS_IP> 'sudo journalctl -u jenkins'

# Check Docker status
ssh -i devops-key.pem ubuntu@<EC2_IP> 'sudo systemctl status docker'

# Check application logs
ssh -i devops-key.pem ubuntu@<EC2_IP> 'docker logs react-app --follow'

# Test network connectivity
ssh -i devops-key.pem ubuntu@<JENKINS_IP> 'telnet <EC2_IP> 22'
```

---

## 🧹 Maintenance & Operations

### Regular Maintenance Tasks
```bash
# Update system packages (monthly)
ssh -i devops-key.pem ubuntu@<EC2_IP> 'sudo apt update && sudo apt upgrade -y'

# Clean Docker system (weekly)
ssh -i devops-key.pem ubuntu@<EC2_IP> 'docker system prune -f'

# Backup Jenkins configuration
ssh -i devops-key.pem ubuntu@<JENKINS_IP> 'sudo tar -czf jenkins-backup.tar.gz /var/lib/jenkins/'

# Monitor disk usage
ssh -i devops-key.pem ubuntu@<EC2_IP> 'df -h'
```

### Scaling Considerations
- **Horizontal Scaling**: Add load balancer + multiple EC2 instances
- **Database**: Add RDS for persistent data
- **CDN**: Add CloudFront for static assets
- **Auto Scaling**: Use Auto Scaling Groups

### Backup Strategy
```bash
# Application data backup
docker run --rm -v react-app-data:/data -v $(pwd):/backup ubuntu tar czf /backup/app-backup.tar.gz /data

# Infrastructure backup (Terraform state)
terraform state pull > terraform-state-backup.json
```

---

## 🚀 Advanced Configurations

### Multi-Environment Setup
```hcl
# terraform/environments/prod/terraform.tfvars
environment = "prod"
instance_type = "t3.medium"
min_size = 2
max_size = 5

# terraform/environments/dev/terraform.tfvars  
environment = "dev"
instance_type = "t2.micro"
min_size = 1
max_size = 2
```

### Custom Domain Setup
```bash
# Add Route 53 hosted zone
resource "aws_route53_zone" "main" {
  name = "yourdomain.com"
}

# Add SSL certificate
resource "aws_acm_certificate" "main" {
  domain_name       = "yourdomain.com"
  validation_method = "DNS"
}
```

### Container Registry Migration
```yaml
# Switch to AWS ECR instead of Docker Hub
# In build.sh:
ECR_REPO="123456789.dkr.ecr.us-west-2.amazonaws.com/project3"
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REPO
docker push $ECR_REPO:latest
```

---

## 📚 Project Structure Reference

```
Project3/
├── 📁 build/                    # React production build
├── 📁 terraform/               # Infrastructure as Code
│   ├── main.tf                 # Core infrastructure
│   ├── variables.tf            # Configuration parameters
│   └── terraform.tfvars        # Environment-specific values
├── 📄 Dockerfile              # Container definition
├── 📄 docker-compose.yml      # Local development
├── 📄 nginx.conf              # Web server configuration
├── 📄 Jenkinsfile             # CI/CD pipeline
├── 📄 build.sh               # Automated build script
├── 📄 deploy.sh              # Automated deployment script
├── 📄 devops-key.pem         # SSH key (keep secure!)
└── 📄 DEPLOYMENT_GUIDE.md    # This guide
```

---

## ✅ Success Criteria

### Deployment Success Indicators
- ✅ Jenkins pipeline completes without errors
- ✅ Docker image successfully pushed to hub
- ✅ Application accessible at `http://<EC2_IP>`
- ✅ Container health checks passing
- ✅ CloudWatch receiving logs and metrics
- ✅ SNS alerts configured and tested

### Performance Benchmarks
- **Build Time**: < 3 minutes
- **Deployment Time**: < 2 minutes  
- **Application Response**: < 500ms
- **Uptime Target**: 99.9%

---

## 📞 Support & Resources

### Useful Commands Quick Reference
```bash
# Infrastructure
terraform plan && terraform apply
terraform output

# Application  
curl -I http://<EC2_IP>
docker ps && docker logs react-app

# Monitoring
aws cloudwatch describe-alarms
aws sns list-subscriptions

# Debugging
ssh -i devops-key.pem ubuntu@<EC2_IP>
journalctl -u docker
```

### Additional Resources
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

## 🏁 Conclusion

This deployment guide provides a complete, production-ready DevOps solution with:
- **Automated CI/CD** with Jenkins
- **Infrastructure as Code** with Terraform  
- **Containerization** with Docker
- **Cloud Monitoring** with AWS CloudWatch + SNS
- **Security Best Practices** throughout
- **Zero-Downtime Deployment** capability

The solution is designed for scalability, maintainability, and can serve as a template for future projects.

---

**🎯 Ready for Production | 🔒 Security Focused | 📈 Scalable Design**
