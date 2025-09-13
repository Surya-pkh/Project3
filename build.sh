#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration - change these as needed
IMAGE_NAME="surya-pkh/project3"
DEV_REPO="surya-pkh/project3-dev"
PROD_REPO="surya-pkh/project3-prod"

# Get the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TAG=$(date +%Y%m%d-%H%M%S)

echo "Building Docker image..."
docker build -t $IMAGE_NAME:$TAG .

# Tag and push to dev repository
echo "Tagging image for dev repository..."
docker tag $IMAGE_NAME:$TAG $DEV_REPO:$TAG
docker tag $IMAGE_NAME:$TAG $DEV_REPO:latest

echo "Pushing to dev repository..."
docker push $DEV_REPO:$TAG
docker push $DEV_REPO:latest

echo "Image successfully pushed to development repository"

echo "Build process completed successfully!"