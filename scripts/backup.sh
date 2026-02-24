#!/usr/bin/env bash
set -euo pipefail

MC_NAME="${MC_NAME:-mc-survival}"
BACKUP_DIR="backups"
DATA_DIR="data/${MC_NAME}"
TS="$(date +%F-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [[ ! -d "$DATA_DIR" ]]; then
  echo "No existe directorio de datos: $DATA_DIR"
  exit 1
fi

archive="$BACKUP_DIR/${MC_NAME}-${TS}.tar.gz"
tar -czf "$archive" "$DATA_DIR"
echo "Backup creado: $archive"

# Retención simple: conservar últimos 14 backups
ls -1t "$BACKUP_DIR"/${MC_NAME}-*.tar.gz 2>/dev/null | tail -n +15 | xargs -r rm -f
echo "Retención aplicada (últimos 14 backups)."
