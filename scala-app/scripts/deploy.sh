#!/bin/bash
set -e

# GCloud configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="europe-west2"

# app-specific configuration - YOU SHOULD CHANGE THESE FOR YOUR OWN APP
IMAGE_NAME="scala-hello-world-app"  # matches `Docker / packageName` in `build.sbt`
SERVICE_NAME="scala-hello-world-service"

# Ensure script is run from project root
if [[ ! -f "build.sbt" ]]; then
  echo "Error: Script must be run from project root directory" >&2
  exit 1
fi

echo "Building container image with sbt..."
sbt Docker/publishLocal

echo "Tagging image for Google Container Registry..."
docker tag "$IMAGE_NAME:latest" "eu.gcr.io/$PROJECT_ID/$IMAGE_NAME"

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
