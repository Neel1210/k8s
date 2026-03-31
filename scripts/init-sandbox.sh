#!/usr/bin/env bash
set -euo pipefail

current_dir=$(pwd)
CLUSTER_NAME="sandbox"
RUNTIMECLASS_NAME="gvisor"

echo "🚀 Starting sandbox setup..."
# -----------------------------
# 1. Start Colima (Docker VM)
# -----------------------------
if ! colima status &>/dev/null; then
  echo "🔧 Starting Colima..."
  colima start --runtime docker
else
  echo "✅ Colima already running"
fi
# -----------------------------
# 2. Recreate kind cluster
# -----------------------------
echo "🧹 Deleting existing kind cluster (if any)..."
./stop-sandbox.sh

echo "📦 Creating kind cluster: $CLUSTER_NAME"
kind create cluster --name $CLUSTER_NAME --config $current_dir/../cluster/cluster-config.yml
kubectl cluster-info --context kind-$CLUSTER_NAME
sleep 2

# -----------------------------------
# 3. Install gVisor and RuntimeClass
# -----------------------------------
chmod +x ./temp.sh
./temp.sh
sleep 15

# -----------------------------------
# 4. Install Ingress Controller
# -----------------------------------
#kubectl create namespace ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo "⏳ Waiting for ingress-nginx controller pod to be Ready..."
sleep 15

#3. Wait until ingress controller is Running (simple loop)
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

# 5. Create namespace
kubectl apply -f $current_dir/../sandbox/sandbox-ns.yml
echo "✅ sandbox namespace ready."
sleep 2

# 6. Apply k8s-dashboard in that namespace
kubectl apply -f $current_dir/../k8s-dashboard/k8s-dashboard.yml
kubectl apply -f $current_dir/../k8s-dashboard/rb-dashboard-admin.yaml
kubectl create clusterrolebinding kubernetes-dashboard-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kubernetes-dashboard:kubernetes-dashboard
echo "✅ k8s-dashboard deployed."
echo "view on - http://localhost:8090/console/"

#5. Apply ingress in that namespace
sleep 5
kubectl apply -f $current_dir/../sandbox/ingress-controllers/ingress.yml 
echo "✅ Ingress deployed."

# 6. Apply message-management-service in that namespace
#kind load docker-image sandbox-message-management:latest --name sandbox
#kubectl apply -f ./sandbox/message-management-service/message-management-service.yml

# 7. Apply port forwarding
#kubectl port-forward --address 0.0.0.0 -n ingress-nginx svc/ingress-nginx-controller 8090:80 
cd ../sandbox/worker-service
#
echo "✅ Set-up successfully completed !"