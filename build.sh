#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration - change these as needed
IMAGE_NAME="suryapkh/project3"
DEV_REPO="suryapkh/project3-dev"
PROD_REPO="suryapkh/project3-prod"

# Get the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TAG=$(date +%Y%m%d-%H%M%S)

echo "Building Docker image..."
docker build -t $IMAGE_NAME:$TAG .

# Tag for appropriate repository based on branch
if [ "$CURRENT_BRANCH" == "dev" ]; then
    echo "Tagging image for dev repository..."
    docker tag $IMAGE_NAME:$TAG $DEV_REPO:$TAG
    docker tag $IMAGE_NAME:$TAG $DEV_REPO:latest
    
    echo "Pushing to dev repository..."
    docker push $DEV_REPO:$TAG
    docker push $DEV_REPO:latest
    
    echo "Image successfully pushed to development repository"
elif [ "$CURRENT_BRANCH" == "master" ] || [ "$CURRENT_BRANCH" == "main" ]; then
    echo "Tagging image for production repository..."
    docker tag $IMAGE_NAME:$TAG $PROD_REPO:$TAG
    docker tag $IMAGE_NAME:$TAG $PROD_REPO:latest
    
    echo "Pushing to production repository..."
    docker push $PROD_REPO:$TAG
    docker push $PROD_REPO:latest
    
    echo "Image successfully pushed to production repository"
else
    echo "Current branch is neither dev nor master/main. Not pushing to any repository."
    exit 1
fi

echo "Build process completed successfully!"