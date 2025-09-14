#!/bin/bash
# Deployment script for React application using Docker and Docker Compose
# Exit immediately if a command exits with a non-zero status
set -e

# Configuration - change these as needed
DEV_REPO="suryapkh/project3-dev"
PROD_REPO="suryapkh/project3-prod"
SSH_KEY="~/.ssh/your-aws-key.pem"  # Replace with your actual key filename
SERVER_USER="ec2-user"
SERVER_IP="YOUR_EC2_PUBLIC_IP"  # Replace with your actual AWS instance IP

# Get the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Determine which repository to pull from based on branch
if [ "$CURRENT_BRANCH" == "dev" ]; then
    REPO=$DEV_REPO
    echo "Deploying from development repository..."
elif [ "$CURRENT_BRANCH" == "master" ] || [ "$CURRENT_BRANCH" == "main" ]; then
    REPO=$PROD_REPO
    echo "Deploying from production repository..."
else
    echo "Current branch is neither dev nor master/main. Cannot determine which repository to deploy from."
    exit 1
fi

# Generate Docker Compose file for deployment
cat > docker-compose.deploy.yml << EOF
version: '3'

services:
  react-app:
    image: ${REPO}:latest
    container_name: react-app
    ports:
      - "80:80"
    restart: unless-stopped
EOF

# Copy the Docker Compose file to the server
echo "Copying docker-compose file to server..."
scp -i $SSH_KEY docker-compose.deploy.yml ${SERVER_USER}@${SERVER_IP}:/home/${SERVER_USER}/docker-compose.yml

# Connect to the server and deploy
echo "Connecting to server and deploying..."
ssh -i $SSH_KEY ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
# Login to Docker Hub using environment variables (must be set securely)
if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
    echo "ERROR: DOCKER_USERNAME and DOCKER_PASSWORD environment variables must be set for Docker Hub login."
    exit 1
else
    echo "Logging in to Docker Hub..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
fi

# Pull the latest image and deploy
echo "Pulling the latest image..."
docker-compose pull

echo "Stopping and removing existing containers..."
docker-compose down

echo "Starting new containers..."
docker-compose up -d

echo "Cleaning up old images..."
docker image prune -f
ENDSSH

echo "Deployment completed successfully!"