#!/bin/bash
# Jenkins-friendly deployment script for React application
# This script runs on Jenkins and triggers deployment via webhook or API call
# Exit immediately if a command exits with a non-zero status
set -e

# Configuration
DEV_REPO="suryapkh/project3-dev"
PROD_REPO="suryapkh/project3-prod"
SERVER_IP="44.250.43.186"

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

# Create deployment configuration
echo "Creating deployment configuration..."
cat > deployment-config.json << EOF
{
  "docker_image": "${REPO}:latest",
  "container_name": "react-app",
  "port": "80:80",
  "restart_policy": "unless-stopped",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "build_number": "${BUILD_NUMBER:-unknown}",
  "branch": "$CURRENT_BRANCH"
}
EOF

echo "Deployment configuration created:"
cat deployment-config.json

# For now, we'll create a simple HTTP-based deployment trigger
# This can be extended to use webhooks, APIs, or other deployment mechanisms
echo ""
echo "=== DEPLOYMENT READY ==="
echo "Docker image: ${REPO}:latest"
echo "Branch: $CURRENT_BRANCH"
echo "Server: $SERVER_IP"
echo "========================"

# Create a deployment script that can be run on the target server
cat > deploy-on-server.sh << 'EOF'
#!/bin/bash
# This script should be run on the target server (44.250.43.186)
# It can be triggered manually or via a webhook

set -e

# Read deployment configuration
if [ ! -f deployment-config.json ]; then
    echo "Error: deployment-config.json not found"
    exit 1
fi

DOCKER_IMAGE=$(grep -o '"docker_image": "[^"]*' deployment-config.json | cut -d'"' -f4)
CONTAINER_NAME=$(grep -o '"container_name": "[^"]*' deployment-config.json | cut -d'"' -f4)
PORT_MAPPING=$(grep -o '"port": "[^"]*' deployment-config.json | cut -d'"' -f4)

echo "Deploying: $DOCKER_IMAGE"

# Stop existing container if running
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping existing container..."
    docker stop $CONTAINER_NAME
fi

# Remove existing container if exists
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Removing existing container..."
    docker rm $CONTAINER_NAME
fi

# Pull latest image
echo "Pulling latest image: $DOCKER_IMAGE"
docker pull $DOCKER_IMAGE

# Run new container
echo "Starting new container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT_MAPPING \
    --restart unless-stopped \
    $DOCKER_IMAGE

echo "Deployment completed successfully!"
echo "Container status:"
docker ps -f name=$CONTAINER_NAME

# Clean up old images
echo "Cleaning up old images..."
docker image prune -f
EOF

chmod +x deploy-on-server.sh

echo ""
echo "=== DEPLOYMENT FILES CREATED ==="
echo "1. deployment-config.json - Configuration for this deployment"
echo "2. deploy-on-server.sh - Script to run on the target server"
echo ""
echo "To complete deployment, copy these files to the server and run:"
echo "scp -i your-key.pem deployment-config.json deploy-on-server.sh ubuntu@$SERVER_IP:~/"
echo "ssh -i your-key.pem ubuntu@$SERVER_IP 'chmod +x deploy-on-server.sh && ./deploy-on-server.sh'"
echo ""
echo "Or set up a webhook/API endpoint on the server to automate this process."