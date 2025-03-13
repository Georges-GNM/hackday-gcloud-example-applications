#!/bin/bash
set -e

# GCloud configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="europe-west2"

# app-specific configuration - YOU SHOULD CHANGE THESE FOR YOUR OWN APP
IMAGE_NAME="node-hello-world-app"
SERVICE_NAME="node-hello-world-service"

# Build the container image with explicit platform
echo "Building container image..."
docker build --platform=linux/amd64 -t "eu.gcr.io/$PROJECT_ID/$IMAGE_NAME" .

# Push it to Google Container Registry
echo "Pushing image to European Google Container Registry..."
docker push "eu.gcr.io/$PROJECT_ID/$IMAGE_NAME"

# Deploy to Cloud Run
echo "Deploying to Cloud Run in $REGION..."
gcloud run deploy $SERVICE_NAME \
  --image "eu.gcr.io/$PROJECT_ID/$IMAGE_NAME" \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated

echo "Deployment complete!"
echo "Your service is available at: $(gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)')"
