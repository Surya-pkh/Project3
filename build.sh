#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration - change these as needed
IMAGE_NAME="suryapkh/project3"
DEV_REPO="suryapkh/project3-dev"
PROD_REPO="suryapkh/project3-prod"

# Get the current branch - handle Jenkins environment
if [ -n "$GIT_BRANCH" ]; then
    # Use Jenkins environment variable if available
    CURRENT_BRANCH="$GIT_BRANCH"
else
    # Fallback to git command
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

TAG=$(date +%Y%m%d-%H%M%S)
echo "Building from branch: $CURRENT_BRANCH"

echo "Building Docker image..."
docker build -t $IMAGE_NAME:$TAG .

# Authenticate with Docker Hub using environment variables
if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
    echo "Logging in to Docker Hub..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
else
    echo "Warning: Docker Hub credentials not provided. Using existing authentication."
fi

# Tag for appropriate repository based on branch
if [ "$CURRENT_BRANCH" == "dev" ] || [ "$CURRENT_BRANCH" == "origin/dev" ]; then
    echo "Tagging image for dev repository..."
    docker tag $IMAGE_NAME:$TAG $DEV_REPO:$TAG
    docker tag $IMAGE_NAME:$TAG $DEV_REPO:latest
    
    echo "Pushing to dev repository..."
    docker push $DEV_REPO:$TAG
    docker push $DEV_REPO:latest
    
    echo "Image successfully pushed to development repository: $DEV_REPO"
elif [ "$CURRENT_BRANCH" == "master" ] || [ "$CURRENT_BRANCH" == "origin/master" ] || [ "$CURRENT_BRANCH" == "main" ] || [ "$CURRENT_BRANCH" == "origin/main" ]; then
    echo "Tagging image for production repository..."
    docker tag $IMAGE_NAME:$TAG $PROD_REPO:$TAG
    docker tag $IMAGE_NAME:$TAG $PROD_REPO:latest
    
    echo "Pushing to production repository..."
    docker push $PROD_REPO:$TAG
    docker push $PROD_REPO:latest
    
    echo "Image successfully pushed to production repository: $PROD_REPO"
else
    echo "Branch '$CURRENT_BRANCH' is not supported. Supported branches: dev, master, main (with or without origin/ prefix)"
    exit 1
fi

echo "Build process completed successfully!"