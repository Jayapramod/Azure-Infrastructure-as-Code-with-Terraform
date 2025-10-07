#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 user@host private_key_path"
  echo "Example: $0 azureuser@10.0.0.4 ~/.ssh/id_rsa"
  exit 1
fi

DEST="$1"
KEY="$2"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_TAR="/tmp/webapp_$$.tar.gz"

# Create tarball of the app folder contents
( cd "$ROOT_DIR" && tar -czf "$TMP_TAR" app )

# Copy tarball and run remote deployment
scp -i "$KEY" -o StrictHostKeyChecking=no "$TMP_TAR" "$DEST:/tmp/webapp.tar.gz"
ssh -i "$KEY" -o StrictHostKeyChecking=no "$DEST" bash -s <<'EOF'
set -euo pipefail
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable --now docker
mkdir -p ~/webapp
sudo tar -xzf /tmp/webapp.tar.gz -C ~
# The tar created a top-level 'app' directory under ~
cd ~/app || cd ~/webapp/app || true
if [ -f ./generate-ssl.sh ]; then
  chmod +x ./generate-ssl.sh || true
  ./generate-ssl.sh || true
fi
sudo docker-compose up -d --build || true
EOF

rm -f "$TMP_TAR"

echo "Deployment finished to $DEST"
