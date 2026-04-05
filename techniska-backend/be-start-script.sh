set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting techniska-backend deployment..."
kubectl apply -f $SCRIPT_DIR/namespace/techniska-be-ns.yml
kubectl apply -f $SCRIPT_DIR/services/api-gateway.yml

kubectl apply -f $SCRIPT_DIR/ingress/be-ingress.yml
echo "✅ techniska-backend deployed successfully!"