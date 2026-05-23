set -euo pipefail

kind delete cluster --name sandbox

docker ps -a --filter "name=kind" --format "{{.Names}}" | xargs -r docker rm -f

docker network rm kind 2>/dev/null || true

mkdir -p ~/.kube

rm -f ~/.kube/config

unset KUBECONFIG

kubectl config get-contexts

echo "✅ K8s cleared"
