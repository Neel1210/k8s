#!/usr/bin/env bash
set -euo pipefail

NS="sandbox"
SERVICE_NAME="message-mgmt"
IMAGE_NAME="message-mgmt:latest"
PROJECT_DIR="$(cd ../../message-management-service && pwd)"
K8S_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "➡ Ensuring namespace exists: $NS"
kubectl get ns $NS >/dev/null 2>&1 || kubectl create ns $NS

echo "➡ Building microservice JAR..."
cd "$PROJECT_DIR"
./mvnw clean package -DskipTests

echo "➡ Building Docker image..."
docker build -t $IMAGE_NAME .

echo "➡ Loading image into kind cluster..."
kind load docker-image $IMAGE_NAME --name sandbox

echo "➡ Applying Kubernetes Deployment & Service..."
kubectl apply -f "$K8S_DIR/deployment.yml"
kubectl apply -f "$K8S_DIR/service.yml"

echo "➡ Waiting for pod to become ready..."
kubectl rollout status deployment/message-mgmt -n $NS

echo ""
echo "🎉 DONE! Your microservice is running in namespace '$NS'"
echo ""
echo "📌 Check pod:"
echo "  kubectl get pods -n $NS"
echo ""
echo "📌 Port-forward to test locally:"
echo "  kubectl port-forward -n $NS svc/message-mgmt-service 8080:8080"
echo ""
echo "Then open: http://localhost:8080/"
