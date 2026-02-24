#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-mc-survival}"
TYPE="${2:-PAPER}"
MEMORY="${3:-6G}"
PORT="${4:-25565}"
MODE="${5:-nocrafty}" # crafty|nocrafty

if [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "Nombre inválido: usa a-z, 0-9 y guion (-)."
  exit 1
fi

cp -n .env.example .env

python - <<PY
from pathlib import Path
p=Path('.env')
t=p.read_text()
updates={
 'MC_NAME':'$NAME',
 'MC_TYPE':'$TYPE',
 'MC_MEMORY':'$MEMORY',
 'MC_PORT':'$PORT',
 'PANEL_MODE':'$MODE',
}
for k,v in updates.items():
    import re
    t=re.sub(rf'^{k}=.*$', f'{k}={v}', t, flags=re.M)
p.write_text(t)
PY

mkdir -p "data/$NAME" backups monitoring/grafana data/crafty/{backups,logs,servers,config,import}

echo "Servidor configurado:"
echo "  Nombre : $NAME"
echo "  Tipo   : $TYPE"
echo "  RAM    : $MEMORY"
echo "  Puerto : $PORT"
echo "  Modo   : $MODE"
echo
echo "Siguiente paso: scripts/stack.sh up $MODE"
