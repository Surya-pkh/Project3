#!/bin/bash
# Deployment script for React application using Docker and Docker Compose
# Exit immediately if a command exits with a non-zero status
set -e

# Configuration - change these as needed
DEV_REPO="suryapkh/project3-dev"
PROD_REPO="suryapkh/project3-prod"
# SSH key path - different for local vs Jenkins environment
if [ -f "/home/surya/Project3/devops-key.pem" ]; then
    SSH_KEY="/home/surya/Project3/devops-key.pem"  # Local environment
elif [ -f "$HOME/.ssh/devops-key.pem" ]; then
    SSH_KEY="$HOME/.ssh/devops-key.pem"  # Jenkins home directory
elif [ -f "/var/lib/jenkins/devops-key.pem" ]; then
    SSH_KEY="/var/lib/jenkins/devops-key.pem"  # Jenkins workspace
elif [ -f "./devops-key.pem" ]; then
    SSH_KEY="./devops-key.pem"  # Current directory
elif [ -f "./devops-key-jenkins.pem" ]; then
    SSH_KEY="./devops-key-jenkins.pem"  # Jenkins workspace key
else
    echo "Error: SSH key not found in expected locations:"
    echo "  - /home/surya/Project3/devops-key.pem"
    echo "  - $HOME/.ssh/devops-key.pem"
    echo "  - /var/lib/jenkins/devops-key.pem" 
    echo "  - ./devops-key.pem"
    echo "  - ./devops-key-jenkins.pem"
    exit 1
fi
SERVER_USER="ubuntu"
SERVER_IP="44.250.43.186"  # Replace with your actual AWS instance IP

# Get the current branch - try multiple methods to handle Jenkins environment
if [ -n "$GIT_BRANCH" ]; then
    # Use Jenkins environment variable if available
    CURRENT_BRANCH="$GIT_BRANCH"
else
    # Fallback to git command
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

echo "Detected branch: $CURRENT_BRANCH"

# Determine which repository to pull from based on branch
if [ "$CURRENT_BRANCH" == "dev" ] || [ "$CURRENT_BRANCH" == "origin/dev" ]; then
    REPO=$DEV_REPO
    echo "Deploying from development repository: $DEV_REPO"
elif [ "$CURRENT_BRANCH" == "master" ] || [ "$CURRENT_BRANCH" == "origin/master" ] || [ "$CURRENT_BRANCH" == "main" ] || [ "$CURRENT_BRANCH" == "origin/main" ]; then
    REPO=$PROD_REPO
    echo "Deploying from production repository: $PROD_REPO"
else
    echo "Branch '$CURRENT_BRANCH' is not supported for deployment. Supported branches: dev, master, main (with or without origin/ prefix)"
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
scp -o StrictHostKeyChecking=no -i $SSH_KEY docker-compose.deploy.yml ${SERVER_USER}@${SERVER_IP}:/home/${SERVER_USER}/docker-compose.yml

# Create a deployment script with credentials using printf to avoid escaping issues
printf '#!/bin/bash
set -e

REPO="%s"
DOCKER_USERNAME="%s" 
DOCKER_PASSWORD="%s"

echo "Starting deployment on server..."
echo "Repository: $REPO"

# Login to Docker Hub if credentials are available
if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
    echo "Logging in to Docker Hub with provided credentials..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
else
    echo "No Docker Hub credentials provided. Attempting to pull public image..."
fi

# Stop existing container if running
if [ $(docker ps -q -f name=react-app) ]; then
    echo "Stopping existing container..."
    docker stop react-app || true
fi

# Remove existing container if exists
if [ $(docker ps -aq -f name=react-app) ]; then
    echo "Removing existing container..."
    docker rm react-app || true
fi

# Pull the latest image
echo "Pulling latest image: $REPO:latest"
if ! docker pull $REPO:latest; then
    echo "Failed to pull image. Image might be private or not exist."
    exit 1
fi

# Start new container using docker run
echo "Starting new container..."
docker run -d \\
    --name react-app \\
    -p 80:80 \\
    --restart unless-stopped \\
    $REPO:latest

# Verify deployment
echo "Verifying deployment..."
sleep 3
if [ $(docker ps -q -f name=react-app) ]; then
    echo "✅ Container is running successfully!"
    docker ps -f name=react-app
else
    echo "❌ Container failed to start!"
    docker logs react-app || true
    exit 1
fi

# Clean up old images
echo "Cleaning up old images..."
docker image prune -f || true

echo "🎉 Deployment completed successfully!"
' "$REPO" "$DOCKER_USERNAME" "$DOCKER_PASSWORD" > deploy_remote.sh

# Copy deployment script to server
echo "Copying deployment script to server..."
scp -o StrictHostKeyChecking=no -i $SSH_KEY deploy_remote.sh ${SERVER_USER}@${SERVER_IP}:/home/${SERVER_USER}/

# Execute deployment on server with credentials
echo "Executing deployment on server..."
ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SERVER_USER}@${SERVER_IP} "chmod +x deploy_remote.sh && ./deploy_remote.sh '$REPO' '$DOCKER_USERNAME' '$DOCKER_PASSWORD'"

echo "✅ Automated deployment completed successfully!"

echo "Deployment completed successfully!"