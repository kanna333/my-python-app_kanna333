#!/bin/bash
set -e

# Variables
REPO_URL="https://github.com/kanna333/myautomationbash.git"
APP_NAME="my-python-app"
IMAGE_NAME="${APP_NAME}:1.0"
DEPLOY_NAME="${APP_NAME}-deployment"
SERVICE_NAME="${APP_NAME}-service"
PORT=8000

# 1. Clone or update repo
if [ -d "$APP_NAME" ]; then
    echo ">>> Repo already exists. Pulling latest changes..."
    git -C "$APP_NAME" pull
else
    echo ">>> Cloning repo..."
    git clone "$REPO_URL" "$APP_NAME"
fi

cd "$APP_NAME"

# 2. Use Minikube's Docker daemon
echo ">>> Setting Minikube Docker env..."
eval $(minikube docker-env)

# 3. Build Docker image
echo ">>> Building Docker image..."
docker build -t $IMAGE_NAME .

# 4. Create Kubernetes deployment
echo ">>> Creating Kubernetes deployment..."
kubectl delete deployment $DEPLOY_NAME --ignore-not-found
kubectl create deployment $DEPLOY_NAME --image=$IMAGE_NAME

# 5. Expose service
echo ">>> Exposing service..."
kubectl delete service $SERVICE_NAME --ignore-not-found
kubectl expose deployment $DEPLOY_NAME --name=$SERVICE_NAME --type=NodePort --port=$PORT --target-port=$PORT

# 6. Get service URL
echo ">>> Application deployed! Access it via:"
minikube service $SERVICE_NAME --url
