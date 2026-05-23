#!/bin/bash
set -e

CLUSTER_NAME="sandbox"
RUNTIMECLASS_NAME="gvisor"

# -----------------------------
# 1. Install gVisor in kind node
# -----------------------------
echo "🛡️ Installing gVisor (runsc) inside kind node..."

NODE_CONTAINER=$(docker ps \
  --filter "name=${CLUSTER_NAME}-control-plane" \
  --format "{{.Names}}")

if [ -z "$NODE_CONTAINER" ]; then
  echo "❌ kind control-plane container not found"
  exit 1
fi

docker exec "$NODE_CONTAINER" bash -c '
  set -e

  ARCH=$(uname -m)
  BASE_URL="https://storage.googleapis.com/gvisor/releases/release/latest/${ARCH}"

  echo "⬇️ Downloading runsc..."
  curl -fsSL ${BASE_URL}/runsc -o /usr/local/bin/runsc

  echo "⬇️ Downloading containerd shim..."
  curl -fsSL ${BASE_URL}/containerd-shim-runsc-v1 \
    -o /usr/local/bin/containerd-shim-runsc-v1

  chmod +x /usr/local/bin/runsc \
           /usr/local/bin/containerd-shim-runsc-v1

  echo "📦 Configuring containerd..."

  if [ ! -f /etc/containerd/config.toml ]; then
    containerd config default > /etc/containerd/config.toml
  fi

  if ! grep -q runsc /etc/containerd/config.toml; then
    cat <<EOF >> /etc/containerd/config.toml

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
EOF
  fi

  echo "🔄 Restarting containerd..."
  pkill containerd
'

# -----------------------------
# 2. Create RuntimeClass
# -----------------------------
echo "📜 Applying RuntimeClass: $RUNTIMECLASS_NAME"

kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: $RUNTIMECLASS_NAME
handler: runsc
EOF

# -----------------------------
# 3. Verify runtime
# -----------------------------
echo "🔍 Verifying RuntimeClass..."
kubectl get runtimeclass

echo "✅ gVisor setup complete!"
echo "👉 Use runtimeClassName: $RUNTIMECLASS_NAME in your Pods / Jobs"