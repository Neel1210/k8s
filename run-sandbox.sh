#!/usr/bin/env bash
set -euo pipefail

# 1. Create KIND cluster
kind create cluster --name sandbox --config ./cluster-config.yml
kind get clusters

# 2. Install ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo "⏳ Waiting for ingress-nginx controller pod to be Ready..."

# 3. Wait until ingress controller is Running (simple loop)
while true; do
    POD=$(kubectl get pods -n ingress-nginx \
        -l app.kubernetes.io/component=controller \
        -o jsonpath="{.items[0].metadata.name}" 2>/dev/null || echo "")
    STATUS=$(kubectl get pod "$POD" -n ingress-nginx -o jsonpath="{.status.phase}" 2>/dev/null || echo "")
    READY=$(kubectl get pod "$POD" -n ingress-nginx -o jsonpath="{.status.containerStatuses[0].ready}" 2>/dev/null || echo "")

    if [[ "$STATUS" == "Running" && "$READY" == "true" ]]; then
        echo "✅ ingress-nginx controller is Running and Ready (1/1)!"
        break
    fi
    sleep 7
done

# 4. Create namespace
kubectl apply -f ./sandbox/sandbox-ns.yml

# 5. Apply ingress in that namespace
kubectl apply -f ./sandbox/ingress.yml

# 6. Apply message-management-service in that namespace
kind load docker-image sandbox-message-management:latest --name sandbox
kubectl apply -f ./sandbox/message-management-service/message-management-service.yml

# 7. Apply port forwarding
kubectl port-forward --address 0.0.0.0 svc/ingress-nginx-controller 8090:80 

echo "✅ Cluster + ingress + namespace ready."
