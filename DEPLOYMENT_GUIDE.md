# Project3: End-to-End Deployment Guide

## Overview
This document provides a comprehensive, step-by-step guide for deploying the Project3 React application using Docker, Jenkins, AWS EC2, Terraform, CloudWatch, and SNS. It also covers troubleshooting and resolution steps for common issues encountered during the process.

---

## 1. Prerequisites
- AWS account with permissions for EC2, IAM, CloudWatch, SNS
- Docker Hub account (username: suryapkh)
- GitHub repository: https://github.com/Surya-pkh/Project3
- SSH key: `/home/surya/Project3/devops-key.pem`
- Jenkins server (provisioned via Terraform)
- Terraform installed locally

---

## 2. Infrastructure Provisioning (Terraform)
1. **Configure variables in `terraform/variables.tf` or `terraform.tfvars`:**
   - `aws_region`, `ami_id`, `instance_type`, `key_name`, `my_ip_cidr`, `alert_email`
2. **Run Terraform:**
   ```bash
   cd /home/surya/Project3/terraform
   terraform init
   terraform apply
   ```
   - This provisions:
     - EC2 for app (with Docker, CloudWatch agent)
     - EC2 for Jenkins (with Docker, Jenkins)
     - Security groups
     - CloudWatch log group and alarm
     - SNS topic and email subscription

**Issue:** _AMI Not Found_
- **Resolution:** Use a valid Ubuntu 20.04 LTS AMI for your region (e.g., `ami-053b0d53c279acc90` for us-west-2).

**Issue:** _SSH not working_
- **Resolution:** Ensure your IP is in `my_ip_cidr` and the key path is correct.

---

## 3. Jenkins Setup
1. **Access Jenkins:**
   - Get public IP from AWS Console or `terraform output`.
   - Open `http://<JENKINS_EC2_PUBLIC_IP>:8080` in your browser.
   - Get the initial admin password:
     ```bash
     ssh -i /home/surya/Project3/devops-key.pem ubuntu@<JENKINS_EC2_PUBLIC_IP>
     sudo cat /var/lib/jenkins/secrets/initialAdminPassword
     ```
2. **Install Plugins:** Docker, Docker Pipeline, GitHub, Pipeline
3. **Add Credentials:**
   - Docker Hub: `suryapkh` / `suryapreethi69` (ID: `docker-hub-credentials`)
   - GitHub token (if private repo)
4. **Create Pipeline Job:**
   - Pipeline script from SCM, point to your repo and `Jenkinsfile`
5. **Set up GitHub Webhook:**
   - Payload URL: `http://<JENKINS_EC2_PUBLIC_IP>:8080/github-webhook/`

**Issue:** _Jenkins cannot run Docker_
- **Resolution:**
  ```bash
  sudo usermod -aG docker jenkins
  sudo systemctl restart docker
  sudo systemctl restart jenkins
  ```

---

## 4. Jenkinsfile Logic
- Detects branch (`dev` or `master`)
- Builds and tags Docker image for correct repo
- Pushes image to Docker Hub
- Deploys to EC2 via `deploy.sh` for both `dev` and `master`

**Issue:** _Branch not supported_
- **Resolution:** Jenkinsfile updated to support both `dev`/`origin/dev` and `master`/`origin/master`.

---

## 5. Deployment Script (`deploy.sh`)
- SSH into EC2 app server
- Pull latest Docker image
- Stop and remove old container
- Run new container

**Sample deploy.sh:**
```bash
#!/bin/bash
SERVER_USER=ubuntu
SERVER_IP=<EC2_PUBLIC_IP>
SSH_KEY="/home/surya/Project3/devops-key.pem"
REPO=$1 # pass 'suryapkh/project3-dev' or 'suryapkh/project3-prod'

ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP << EOF
  docker login -u suryapkh -p suryapreethi69
  docker pull $REPO:latest
  docker stop react-app || true
  docker rm react-app || true
  docker run -d --name react-app -p 80:80 $REPO:latest
EOF
```

---

## 6. Monitoring & Alerting
- **CloudWatch** collects logs from Docker container.
- **CloudWatch Alarm** monitors EC2 health.
- **SNS** sends email alert to `suryaprakash27032001@gmail.com` if instance fails health checks.
- (Optional) Use Uptime Kuma for HTTP endpoint monitoring.

**Issue:** _No alert received_
- **Resolution:** Confirm SNS subscription in your email.

---

## 7. Common Issues & Resolutions
- **Docker permission denied:**
  - Add Jenkins user to docker group and restart services.
- **AMI not found:**
  - Use correct AMI for your region.
- **Branch not supported:**
  - Update Jenkinsfile to handle `origin/dev`, `origin/master`.
- **SSH issues:**
  - Check key path and security group rules.

---

## 8. Cleanup
To destroy all resources:
```bash
cd /home/surya/Project3/terraform
terraform destroy
```

---

## 9. Summary
This guide covers the full CI/CD pipeline, infrastructure as code, monitoring, and troubleshooting for Project3. All steps are automated and ready for production or client demonstration.
