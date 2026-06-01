#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f $SCRIPT_DIR/namespace/sandbox-ns.yml
echo "✅ Namespace 'sandbox' created."

kubectl apply -f $SCRIPT_DIR/data/configmap.yml
kubectl apply -f $SCRIPT_DIR/data/secrets.yml


kubectl apply -f $SCRIPT_DIR/services/message-management-service/message-management-service.yml
echo "✅ message-management-service deployed."

kubectl apply -f $SCRIPT_DIR/services/worker-service/language-configs.yml
kubectl apply -f $SCRIPT_DIR/services/worker-service/local-worker-service.yml
echo "✅ worker-service deployed."

kubectl apply -f $SCRIPT_DIR/ingress-rule/ingress.yml
echo "✅ Ingress deployed."