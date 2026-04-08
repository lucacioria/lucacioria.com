#!/bin/bash
set -euo pipefail

echo "=== Deploying lucacioria.com ==="

cd "$(dirname "$0")"

echo "-> Pulling latest changes..."
git pull --ff-only 2>/dev/null || echo "   (no remote or nothing to pull)"

echo "-> Starting container..."
docker compose -f docker-compose.prod.yml up -d --build

echo "-> Waiting for container to be healthy..."
sleep 2

echo "-> Smoke test..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 https://lucacioria.com/ 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  echo "   OK — https://lucacioria.com/ returned $HTTP_CODE"
else
  echo "   WARNING — https://lucacioria.com/ returned $HTTP_CODE (DNS may not be configured yet)"
  echo "   Checking container directly..."
  docker exec lucacioria wget -qO- http://localhost/ > /dev/null && echo "   Container is serving content correctly" || echo "   Container check failed"
fi

echo "=== Deploy complete ==="
