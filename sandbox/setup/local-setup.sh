#!/usr/bin/env bash
set -euo pipefail

kind load docker-image sandbox-message-management:latest --name sandbox
kubectl apply -f ../message-management-service/local-message-management-service.yml
echo "✅ message-management-service deployed."

kind load docker-image worker-service:latest --name sandbox
kubectl apply -f ../worker-service/local-worker-service.yml
echo "✅ worker-service deployed."

kubectl apply -f ../ingress-controllers/ingress.yml
echo "✅ Ingress deployed."