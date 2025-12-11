#!/bin/bash
set -euo pipefail
kubectl apply -f k8s-dashboard.yml 
sleep 5
echo "✅ Kubernetes Dashboard deployed."

kubectl create clusterrolebinding kubernetes-dashboard-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kubernetes-dashboard:kubernetes-dashboard

echo "✅ ClusterRoleBinding for kubernetes-dashboard created."
