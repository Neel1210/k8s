#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NS_FILE="$SCRIPT_DIR/sandbox-ns.yml"
RABBIT_FILE="$SCRIPT_DIR/rabbit-mq/rabbit-mq.yml"
INGRESS_FILE="$SCRIPT_DIR/ingress.yml"

# ---------------------------------------------------
# 1️⃣ Check Docker Daemon (Colima / Docker Desktop)
# ---------------------------------------------------
echo "➡ Checking Docker daemon..."
if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker daemon not running!"
  echo "👉 Start Colima using:"
  echo "   colima start --runtime docker"
  exit 1
else
  echo "✅ Docker daemon is running"
fi

# ---------------------------------------------------
# 2️⃣ Check Kubernetes access
# ---------------------------------------------------
echo "➡ Checking Kubernetes API server connection..."
if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "❌ Kubernetes API is not reachable."
  echo "👉 Create a kind cluster:"
  echo "   kind create cluster --name sandbox --config ../cluster-config.yml"
  exit 1
fi
echo "✅ Kubernetes API reachable"

# ---------------------------------------------------
# 3️⃣ Read Namespace from sandbox-ns.yml
# ---------------------------------------------------
if [[ ! -f "$NS_FILE" ]]; then
  echo "❌ Namespace file not found: $NS_FILE"
  exit 1
fi

NAMESPACE=$(awk '
  /^metadata:/ { m=1 }
  m && /name:/ { print $2; exit }
' "$NS_FILE")

if [[ -z "$NAMESPACE" ]]; then
  echo "❌ Could not extract namespace name from sandbox-ns.yml"
  exit 1
fi

echo "➡ Using namespace: $NAMESPACE"

# ---------------------------------------------------
# 4️⃣ Apply Namespace
# ---------------------------------------------------
echo "🔧 Creating/updating namespace..."
kubectl apply -f "$NS_FILE" --validate=false
echo "✅ Namespace applied"

# ---------------------------------------------------
# 5️⃣ Deploy RabbitMQ (force namespace rewrite)
# ---------------------------------------------------
echo "🐇 Deploying RabbitMQ into namespace: $NAMESPACE"

kubectl apply -f <(
  sed -E "s/^(  namespace:).*/\1 $NAMESPACE/" "$RABBIT_FILE"
) --validate=false

echo "✅ RabbitMQ deployed"

# ---------------------------------------------------
# 6️⃣ Deploy Ingress (auto-namespace rewrite too)
# ---------------------------------------------------
echo "🌐 Deploying Ingress..."

kubectl apply -f <(
  sed -E "s/^(  namespace:).*/\1 $NAMESPACE/" "$INGRESS_FILE"
) --validate=false

echo "✅ Ingress deployed"

# ---------------------------------------------------
# 7️⃣ Final Summary
# ---------------------------------------------------
echo ""
echo "🎉 Deployment complete!"
echo "✔ Namespace: $NAMESPACE"
echo "✔ RabbitMQ Deployment + Service"
echo "✔ Ingress configured"
echo ""
echo "📌 Verify resources:"
echo "   kubectl get all -n $NAMESPACE"
echo ""
echo "📌 Check logs:"
echo "   kubectl logs -n $NAMESPACE -l app=rabbit-mq"
echo ""
echo "📌 Access RabbitMQ:"
echo "   kubectl port-forward -n $NAMESPACE svc/rabbit-mq-service 15672:15672"
echo "   → http://localhost:15672"