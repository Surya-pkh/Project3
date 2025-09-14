# 🚀 Project3: Production-Ready React DevOps Deployment

A complete end-to-end DevOps solution for deploying React applications with Docker, Jenkins CI/CD, AWS infrastructure, and automated monitoring.

## ✨ Features

- **🔄 Automated CI/CD Pipeline**: Jenkins with GitHub webhook integration
- **🐳 Containerized Deployment**: Docker with nginx for production-ready serving
- **🏗️ Infrastructure as Code**: Complete AWS setup with Terraform
- **🌍 Multi-Environment Support**: Separate dev and production deployments
- **📊 Monitoring & Alerting**: AWS CloudWatch + SNS integration
- **🔒 Security Best Practices**: No hardcoded credentials, SSH key management

## 🏗️ Architecture

```
GitHub Repository → Jenkins CI/CD → Docker Hub → AWS EC2 → CloudWatch + SNS
     ↓                    ↓              ↓           ↓            ↓
   Webhook            Build & Test    Push Image   Deploy App   Monitor & Alert
```

## 🚀 Quick Start

### Prerequisites
- AWS Account with EC2, CloudWatch, SNS permissions
- Docker Hub account
- GitHub repository access
- Terraform installed

### 1. Infrastructure Setup
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
terraform init && terraform apply
```

### 2. Jenkins Configuration
```bash
# Get Jenkins URL from Terraform output
terraform output jenkins_public_ip
# Open http://JENKINS_IP:8080 and complete setup
```

### 3. Deploy Application
```bash
# Push to trigger automatic deployment
git push origin dev     # Deploys to development
git push origin master  # Deploys to production
```

## 📁 Project Structure

```
Project3/
├── 📁 build/                     # React production build
├── 📁 docs/                      # Documentation & outputs
│   ├── jenkins-outputs/          # CI/CD build logs
│   ├── monitoring-outputs/       # Monitoring screenshots
│   ├── deployment-screenshots/   # Deployment process images
│   └── Project3 deployment.pdf   # Complete deployment guide
├── 📁 terraform/                 # Infrastructure as Code
│   ├── main.tf                   # AWS resources definition
│   ├── variables.tf              # Configuration parameters
│   └── terraform.tfvars          # Environment-specific values
├── 📄 Dockerfile                 # Container configuration
├── 📄 docker-compose.yml         # Local development setup
├── 📄 nginx.conf                 # Web server configuration
├── 📄 Jenkinsfile                # CI/CD pipeline definition
├── 📄 build.sh                   # Automated build script
├── 📄 deploy.sh                  # Automated deployment script
├── 📄 DEPLOYMENT_GUIDE.md        # Comprehensive deployment guide
└── 📄 README.md                  # This file
```

## 🔄 CI/CD Pipeline

### Branch Strategy
- **`dev` branch** → Development environment (`suryapkh/project3-dev`)
- **`master` branch** → Production environment (`suryapkh/project3-prod`)

### Pipeline Stages
1. **Checkout** - Get latest code from GitHub
2. **Setup SSH** - Configure EC2 access
3. **Determine Branch** - Route to correct environment
4. **Build & Push** - Create and push Docker image
5. **Deploy to EC2** - Zero-downtime deployment
6. **Clean Up** - Remove temporary artifacts

## 🛠️ Key Components

### Docker Configuration
- **Base Image**: nginx:alpine (lightweight)
- **Port**: 80 (HTTP)
- **Optimized**: Multi-stage build for minimal size

### AWS Infrastructure
- **EC2 Instances**: Application + Jenkins servers
- **Security Groups**: Properly configured access control
- **CloudWatch**: Log aggregation and metrics
- **SNS**: Email alerting system

### Automation Scripts
- **`build.sh`**: Handles Docker build and push with branch detection
- **`deploy.sh`**: Manages zero-downtime deployment to EC2
- **Jenkinsfile**: Complete CI/CD pipeline with error handling

## 📊 Monitoring

### CloudWatch Integration
- Container logs automatically collected
- EC2 health monitoring
- Custom metrics and alarms

### Alerting
- Email notifications via SNS
- Build failure alerts
- Infrastructure health monitoring

## 🔒 Security

- ✅ No hardcoded credentials
- ✅ SSH key-based authentication
- ✅ Security groups with minimal access
- ✅ Environment variable injection
- ✅ Docker Hub token authentication

## 🚀 Getting Started

### Local Development
```bash
# Run locally with Docker Compose
docker-compose up -d

# Access application
open http://localhost
```

### Production Deployment
```bash
# Deploy to development
git push origin dev

# Deploy to production
git push origin master
```

## 📚 Documentation

- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Complete setup and troubleshooting guide
- **[docs/](docs/)** - Screenshots, logs, and visual documentation
- **[terraform/README.md](terraform/README.md)** - Infrastructure setup details

## 🛠️ Troubleshooting

### Common Issues
1. **Jenkins not triggering**: Check webhook configuration and polling settings
2. **Docker build fails**: Verify Docker Hub credentials in Jenkins
3. **Deployment timeout**: Check security groups and SSH key access
4. **Application not accessible**: Verify port 80 in security groups

### Health Checks
```bash
# Check application status
curl -I http://EC2_PUBLIC_IP

# Check Docker container
ssh -i devops-key.pem ubuntu@EC2_IP 'docker ps'

# View application logs
ssh -i devops-key.pem ubuntu@EC2_IP 'docker logs react-app'
```

## 🏆 Success Metrics

- **Build Time**: < 3 minutes
- **Deployment Time**: < 2 minutes
- **Zero Downtime**: Rolling updates
- **Uptime Target**: 99.9%
- **Automated**: 100% hands-off deployment

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Create Pull Request

## 📧 Support

For deployment issues or questions:
- Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed troubleshooting
- Review [docs/](docs/) for visual guides
- Create GitHub issue for bugs or feature requests

---

**🎯 Production Ready | 🔒 Security Focused | 📈 Scalable Design**

*Complete DevOps solution with automated deployment, monitoring, and infrastructure management.*