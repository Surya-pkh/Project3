#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration - change these as needed
DEV_REPO="suryapkh/project3-dev"
SSH_KEY="~/.ssh/your-aws-key.pem"  # Replace with your actual key filename
SERVER_USER="ec2-user"
SERVER_IP="YOUR_EC2_PUBLIC_IP"  # Replace with your actual AWS instance IP

# Using only the dev repository
REPO=$DEV_REPO
echo "Deploying from development repository..."

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
# Login to Docker Hub if needed (you'll need to set these environment variables on the server)
if [ ! -z "$DOCKER_USERNAME" ] && [ ! -z "$DOCKER_PASSWORD" ]; then
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