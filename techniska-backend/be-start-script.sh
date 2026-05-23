set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting techniska-backend deployment..."
kubectl apply -f $SCRIPT_DIR/namespace/techniska-be-ns.yml
kubectl apply -f $SCRIPT_DIR/data/configmap.yml
kubectl apply -f $SCRIPT_DIR/data/secrets.yml

kubectl apply -f $SCRIPT_DIR/services/api-gateway.yml
kubectl apply -f $SCRIPT_DIR/services/auth-server.yml
kubectl apply -f $SCRIPT_DIR/services/user-management-service.yml

kubectl apply -f $SCRIPT_DIR/ingress/be-ingress.yml
echo "✅ techniska-backend deployed successfully!"