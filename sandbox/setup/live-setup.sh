#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f ../message-management-service/message-management-service.yml
echo "✅ message-management-service deployed."

kubectl apply -f ../worker-service/worker-service.yml
echo "✅ worker-service deployed."

kubectl apply -f ../ingress-controllers/ingress.yml
echo "✅ Ingress deployed."