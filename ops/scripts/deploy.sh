#!/usr/bin/env bash
# Canonical deploy: restore runtime state -> build -> recreate -> backup -> cleanup
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
LOG_PREFIX="[deploy $(date '+%Y-%m-%d %H:%M:%S')]"
COMPOSE_FILE="${COMPOSE_FILE:-${INFRA_REPO_ROOT}/deploy/docker-compose.yml}"
ENV_FILE="${ENV_FILE:-${INFRA_REPO_ROOT}/deploy/.env}"

echo "$LOG_PREFIX Deploy starting..."

# 1. Pull state from Drive.
echo "$LOG_PREFIX Pulling state..."
bash "$SCRIPT_DIR/pull-state.sh"

# 2. Rebuild canonical stack.
echo "$LOG_PREFIX Building canonical stack..."
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" build --no-cache frontend backend worker stellai orchestra

# 3. Recreate containers.
echo "$LOG_PREFIX Recreating containers..."
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --remove-orphans

# 4. Health check.
echo "$LOG_PREFIX Running health checks..."
for i in $(seq 1 12); do
  STATUS=$(curl -s --max-time 5 http://127.0.0.1:8000/api/v1/health 2>/dev/null || echo "fail")
  if echo "$STATUS" | grep -q '"status":"ok"'; then
    echo "$LOG_PREFIX Backend healthy ✓"
    break
  fi
  [ $i -eq 12 ] && { echo "$LOG_PREFIX ERROR: backend did not become healthy"; exit 1; }
  echo "$LOG_PREFIX Waiting ($i/12)..."
  sleep 10
done

# 5. Immediate post-deploy backup.
echo "$LOG_PREFIX Running post-deploy backup..."
bash "$SCRIPT_DIR/backup-state.sh"

# 6. Cleanup.
echo "$LOG_PREFIX Running cleanup..."
bash "$SCRIPT_DIR/cleanup.sh"

echo "$LOG_PREFIX Deploy complete."
