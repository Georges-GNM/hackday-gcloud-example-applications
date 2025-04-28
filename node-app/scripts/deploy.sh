#!/bin/bash
set -e

# Read name from the APPLICATION_NAME file, with whitespace trimmed
APPLICATION_NAME=$(echo $(cat APPLICATION_NAME) | xargs)

# GCloud configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="europe-west2"

# app-specific configuration
IMAGE_NAME="${APPLICATION_NAME}-image"
SERVICE_NAME="${APPLICATION_NAME}-service"
SERVICE_ACCOUNT_NAME="${APPLICATION_NAME}-sa"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@$PROJECT_ID.iam.gserviceaccount.com"


# Ensure script is run from project root
if [[ ! -f "Dockerfile" ]]; then
  echo "Error: Script must be run from project root directory" >&2
  exit 1
fi

# Set up a service account for the application, if it does not exist
# This will allow us to grant the application access to gcloud resources (e.g. API keys via gcloud secrets)
if ! gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" >/dev/null 2>&1; then
  echo "Creating service account $SERVICE_ACCOUNT_NAME..."
  gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
    --display-name "Service Account for $SERVICE_NAME"
fi

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
  --region "$REGION" \
  --service-account "$SERVICE_ACCOUNT_EMAIL" \
  --allow-unauthenticated

echo "Deployment complete!"
echo "Your service is available at: $(gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)')"
