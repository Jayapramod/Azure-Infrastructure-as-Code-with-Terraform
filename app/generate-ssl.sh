#!/usr/bin/env bash
set -euo pipefail

mkdir -p certs

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/server.key -out certs/server.crt \
  -subj "/CN=localhost"

echo "Generated certs in ./certs"
