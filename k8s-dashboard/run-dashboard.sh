#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f $SCRIPT_DIR/k8s-dashboard.yml 
sleep 5 
echo "✅ Kubernetes Dashboard deployed."

kubectl create clusterrolebinding kubernetes-dashboard-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kubernetes-dashboard:kubernetes-dashboard

kubectl apply -f $SCRIPT_DIR/ingress-rule/k8s-ingress.yml
echo "✅ Kubernetes dashboard ingress-rule applied."

echo "✅ ClusterRoleBinding for kubernetes-dashboard created."