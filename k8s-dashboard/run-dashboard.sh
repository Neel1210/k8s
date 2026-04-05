#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f $SCRIPT_DIR/k8s-dashboard.yml 
sleep 5 
echo "✅ Kubernetes Dashboard deployed."

kubectl create clusterrolebinding kubernetes-dashboard-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kubernetes-dashboard:kubernetes-dashboard

echo "✅ ClusterRoleBinding for kubernetes-dashboard created."