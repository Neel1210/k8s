set -euo pipefail

kind create cluster --name sandbox --config ./cluster-config.yml
kubectl cluster-info --context sandbox

kubectl apply -f ./sandbox/sandbox-ns.yml
kubectl apply -f ./sandbox/ingress.yml