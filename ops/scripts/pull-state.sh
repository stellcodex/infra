#!/usr/bin/env bash
# Pull canonical state from Drive before deploy or during restore
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${INFRA_REPO_ROOT}/scripts/lib/runtime_env.sh"

DRIVE_ROOT="${DRIVE_ROOT:-gdrive:STELL}"
STELLCODEX_REPO_ROOT="${STELLCODEX_REPO_ROOT:-/srv/stellcodex}"
LOG_PREFIX="[pull-state $(date '+%Y-%m-%d %H:%M:%S')]"
RESTORE_DB_CONTAINER="${DB_CONTAINER:-$(runtime_resolve_db_container 2>/dev/null || true)}"

echo "$LOG_PREFIX Pulling state from Drive..."

# 1. Knowledge base
echo "$LOG_PREFIX Knowledge base..."
mkdir -p "${STELLCODEX_REPO_ROOT}/_knowledge"
rclone sync "${DRIVE_ROOT}/08_STELL_AI_MEMORY/knowledge/" \
  "${STELLCODEX_REPO_ROOT}/_knowledge/"
echo "$LOG_PREFIX Knowledge OK"

# 2. Model backup restore (only if missing)
MODEL_DIR="${STELLCODEX_REPO_ROOT}/_models"
if [ ! -d "$MODEL_DIR" ] || [ -z "$(ls -A $MODEL_DIR 2>/dev/null)" ]; then
  echo "$LOG_PREFIX Pulling model backups..."
  mkdir -p "$MODEL_DIR"
  rclone copy "${DRIVE_ROOT}/01_BACKUPS/models/" "$MODEL_DIR/"
  echo "$LOG_PREFIX Model OK"
else
  echo "$LOG_PREFIX Models already present, skipping."
fi

# 3. Print available DB backups for manual restore
echo
echo "$LOG_PREFIX Available DB backups:"
rclone lsf "${DRIVE_ROOT}/01_BACKUPS/db/" 2>/dev/null | tail -5 || echo "  (no backups found)"
echo
echo "$LOG_PREFIX Pull complete."
echo "DB restore command:"
echo "  rclone copy ${DRIVE_ROOT}/01_BACKUPS/db/<file>.sql.gz /tmp/"
echo "  gunzip -c /tmp/<file>.sql.gz | docker exec -i ${RESTORE_DB_CONTAINER:-stellcodex-postgres} psql -U stellcodex"
