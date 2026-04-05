set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting techniska-ui deployment..."
kubectl apply -f $SCRIPT_DIR/files/techniska-ui-ns.yml
kubectl apply -f $SCRIPT_DIR/files/ui-deployment.yml
kubectl apply -f $SCRIPT_DIR/files/ui-service.yml
kubectl apply -f $SCRIPT_DIR/files/ui-ingress.yml
echo "✅ techniska-ui deployed successfully!"