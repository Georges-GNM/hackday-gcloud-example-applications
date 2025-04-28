#!/bin/bash
set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper functions ---
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error_exit() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

# --- Configuration ---
REGION="europe-west2"
REPOSITORY_PREFIX="eu.gcr.io"

# --- Pre-checks ---
info "Checking Docker installation..."
command -v docker &> /dev/null || error_exit "Docker is not installed or not available in PATH."

info "Checking gcloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
  error_exit "No active gcloud account found. Please run 'gcloud auth login'."
fi

info "Checking gcloud project configuration..."
PROJECT_ID=$(gcloud config get-value project 2> /dev/null)
if [[ -z "${PROJECT_ID}" ]]; then
  error_exit "No GCP project set. Please run 'gcloud config set project YOUR_PROJECT_ID'."
fi

info "Validating APPLICATION_NAME file..."
if [[ ! -f "APPLICATION_NAME" ]]; then
  error_exit "APPLICATION_NAME file not found."
fi

# Gets the application name from the APP_Name file, for consistency (and trims whitespace)
APPLICATION_NAME=$(< APP_NAME xargs)
if [[ -z "$APPLICATION_NAME" ]]; then
  error_exit "APPLICATION_NAME file is empty."
fi

if [[ "$APPLICATION_NAME" == "node-hello-world" ]]; then
  error_exit "APPLICATION_NAME is still set to the template default 'node-hello-world'. Please change it."
fi

# --- Setup variables ---
IMAGE_NAME="${APPLICATION_NAME}-image"
SERVICE_NAME="${APPLICATION_NAME}-service"
SERVICE_ACCOUNT_NAME="${APPLICATION_NAME}-sa"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# --- Ensure script is run from project root ---
if [[ ! -f "Dockerfile" ]]; then
  error_exit "Script must be run from the project root directory (Dockerfile missing)."
fi

# --- Ensure service account exists ---
info "Checking service account $SERVICE_ACCOUNT_EMAIL..."
if ! gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" >/dev/null 2>&1; then
  warning "Service account not found. Creating $SERVICE_ACCOUNT_NAME..."
  gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
    --display-name "Service Account for $SERVICE_NAME"
  sleep 5
fi

# --- Build and push the container image ---
info "Building container image..."
docker build --platform=linux/amd64 -t "$REPOSITORY_PREFIX/$PROJECT_ID/$IMAGE_NAME" .

info "Pushing container image to Container Registry..."
docker push "$REPOSITORY_PREFIX/$PROJECT_ID/$IMAGE_NAME"

# --- Deploy to Cloud Run ---
info "Deploying service $SERVICE_NAME to Cloud Run in region $REGION..."
gcloud run deploy "$SERVICE_NAME" \
  --image "$REPOSITORY_PREFIX/$PROJECT_ID/$IMAGE_NAME" \
  --platform managed \
  --region "$REGION" \
  --service-account "$SERVICE_ACCOUNT_EMAIL" \
  --allow-unauthenticated

# --- Output service URL ---
success "Deployment complete!"
info "Your service is available at:"
gcloud run services describe "$SERVICE_NAME" \
  --platform managed \
  --region "$REGION" \
  --format 'value(status.url)'
