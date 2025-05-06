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

info "Validating APP_NAME file..."
if [[ ! -f "APP_NAME" ]]; then
  error_exit "APP_NAME file not found."
fi

APPLICATION_NAME=$(< APP_NAME xargs)
if [[ -z "APPLICATION_NAME" ]]; then
  error_exit "APP_NAME file is empty."
fi

if [[ "$APPLICATION_NAME" == "scala-hello-world" ]]; then
  error_exit "APPLICATION_NAME is still set to the template default 'scala-hello-world'. Please change it to your app's name."
fi

# --- Configuration ---
REGION="europe-west2" # London
REPOSITORY_PREFIX="eu.gcr.io"
SHARED_SERVICE_ACCOUNT_EMAIL="guardian-hackday-shared-sa@${PROJECT_ID}.iam.gserviceaccount.com"

# --- Setup variables ---
IMAGE_NAME="${APPLICATION_NAME}-image"  # matches Docker / packageName in build.sbt
SERVICE_NAME="${APPLICATION_NAME}-service"

# --- Ensure script is run from project root ---
if [[ ! -f "build.sbt" ]]; then
  error_exit "Script must be run from the project root directory (build.sbt missing)."
fi

# --- Shared service account ---
info "Using shared service account: $SHARED_SERVICE_ACCOUNT_EMAIL"

# --- Build and tag the container image ---
info "Building container image with sbt..."
sbt Docker/publishLocal

info "Tagging image for Google Container Registry..."
docker tag "$IMAGE_NAME:latest" "$REPOSITORY_PREFIX/$PROJECT_ID/$IMAGE_NAME"

# --- Push to Container Registry ---
info "Pushing image to Container Registry..."
docker push "$REPOSITORY_PREFIX/$PROJECT_ID/$IMAGE_NAME"

# --- Deploy to Cloud Run ---
info "Deploying service $SERVICE_NAME to Cloud Run in region $REGION..."
gcloud run deploy "$SERVICE_NAME" \
  --image "$REPOSITORY_PREFIX/$PROJECT_ID/$IMAGE_NAME" \
  --platform managed \
  --region "$REGION" \
  --service-account "$SHARED_SERVICE_ACCOUNT_EMAIL" \
  --allow-unauthenticated \
  --update-secrets "CAPI_API_KEY=CAPI_API_KEY:latest"

# --- Output service URL ---
success "Deployment complete!"
success "Your service is available at:"
gcloud run services describe "$SERVICE_NAME" \
  --platform managed \
  --region "$REGION" \
  --format 'value(status.url)'