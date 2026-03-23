#!/usr/bin/env bash
# State + DB + config -> Google Drive canonical archive
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${INFRA_REPO_ROOT}/scripts/lib/runtime_env.sh"

DRIVE_ROOT="${DRIVE_ROOT:-gdrive:STELL}"
STELLCODEX_REPO_ROOT="${STELLCODEX_REPO_ROOT:-/srv/stellcodex}"
LOCAL_BACKUP_DIR="${LOCAL_BACKUP_DIR:-${STELLCODEX_REPO_ROOT}/backups}"
TS="$(date +%Y%m%d_%H%M%S)"
LOG_PREFIX="[backup-state $TS]"
TMP="/tmp/stellcodex-backup-$$"
mkdir -p "$TMP"
trap "rm -rf $TMP" EXIT

echo "$LOG_PREFIX Starting..."

# 1. PostgreSQL dump -> Drive/01_BACKUPS/db/
echo "$LOG_PREFIX Dumping database..."
DB_CONTAINER="${DB_CONTAINER:-$(runtime_resolve_db_container 2>/dev/null || true)}"
DB_USER="${POSTGRES_USER:-stellcodex}"
DB_NAME="${POSTGRES_DB:-stellcodex}"

if [ -n "${DB_CONTAINER}" ] && docker ps --format "{{.Names}}" | grep -q "^${DB_CONTAINER}$"; then
  mkdir -p "${LOCAL_BACKUP_DIR}"
  DUMP="$TMP/db_${DB_NAME}_${TS}.sql.gz"
  docker exec "$DB_CONTAINER" sh -c \
    "PGPASSWORD=\"\${POSTGRES_PASSWORD}\" pg_dump -U ${DB_USER} ${DB_NAME}" \
    | gzip > "$DUMP"
  cp "$DUMP" "${LOCAL_BACKUP_DIR}/"
  rclone copy "$DUMP" "${DRIVE_ROOT}/01_BACKUPS/db/"
  echo "$LOG_PREFIX DB dump -> Drive OK"

  rclone delete "${DRIVE_ROOT}/01_BACKUPS/db/" \
    --min-age 30d --include "db_*.sql.gz" 2>/dev/null || true
else
  echo "$LOG_PREFIX WARNING: ${DB_CONTAINER:-postgres container} unavailable, DB dump skipped."
fi

# 2. Config files -> Drive/01_BACKUPS/config/<TS>/
echo "$LOG_PREFIX Backing up config..."
CFG="$TMP/cfg"
mkdir -p "$CFG"

# Sensitive env files.
for f in \
  "${STELLCODEX_REPO_ROOT}/.env" \
  "${INFRA_REPO_ROOT}/deploy/.env"; do
  [ -f "$f" ] && cp "$f" "$CFG/$(echo $f | tr '/' '_').env" || true
done

rclone copy "$CFG/" "${DRIVE_ROOT}/01_BACKUPS/config/${TS}/"

CONF_COUNT=$(rclone lsf "${DRIVE_ROOT}/01_BACKUPS/config/" --dirs-only 2>/dev/null | wc -l)
if [ "$CONF_COUNT" -gt 10 ]; then
  OLDEST=$(rclone lsf "${DRIVE_ROOT}/01_BACKUPS/config/" --dirs-only 2>/dev/null | sort | head -1)
  rclone purge "${DRIVE_ROOT}/01_BACKUPS/config/${OLDEST}" 2>/dev/null || true
  echo "$LOG_PREFIX Pruned old config backup: $OLDEST"
fi
echo "$LOG_PREFIX Config -> Drive OK"

# 3. Knowledge/memory -> Drive/08_STELL_AI_MEMORY/
echo "$LOG_PREFIX Syncing STELL.AI knowledge..."
[ -d "${STELLCODEX_REPO_ROOT}/_knowledge" ] && \
  rclone sync "${STELLCODEX_REPO_ROOT}/_knowledge/" "${DRIVE_ROOT}/08_STELL_AI_MEMORY/knowledge/" 2>/dev/null || true
echo "$LOG_PREFIX Knowledge OK"

# 4. Runtime evidence -> Drive/03_EVIDENCE/
echo "$LOG_PREFIX Syncing evidence..."
if [ -d "${STELLCODEX_REPO_ROOT}/evidence" ] && [ "$(find "${STELLCODEX_REPO_ROOT}/evidence" -mindepth 1 -print -quit 2>/dev/null)" ]; then
  rclone sync "${STELLCODEX_REPO_ROOT}/evidence/" "${DRIVE_ROOT}/03_EVIDENCE/server-runtime/" --create-empty-src-dirs
  echo "$LOG_PREFIX Evidence -> Drive OK"
fi

echo "$LOG_PREFIX Backup complete."
