#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-mc-survival}"
TYPE="${2:-PAPER}"
MEMORY="${3:-6G}"
PORT="${4:-25565}"
MODE="${5:-nocrafty}" # crafty|nocrafty

progress() {
  echo "[$1%] $2"
}

progress 5 "Validando parámetros..."
if [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "Nombre inválido: usa a-z, 0-9 y guion (-)."
  exit 1
fi
if [[ "$MODE" != "crafty" && "$MODE" != "nocrafty" ]]; then
  echo "Modo inválido: usa crafty o nocrafty."
  exit 1
fi

progress 20 "Creando archivo .env desde plantilla si no existe..."
if [[ ! -f .env ]]; then
  cp .env.example .env
fi

progress 45 "Aplicando configuración del servidor..."
python - <<PY
from pathlib import Path
import re
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
    t=re.sub(rf'^{k}=.*$', f'{k}={v}', t, flags=re.M)
p.write_text(t)
PY

progress 70 "Preparando estructura de carpetas..."
mkdir -p "data/$NAME" backups monitoring/grafana data/crafty/{backups,logs,servers,config,import}

progress 90 "Generando resumen de configuración..."
echo "Servidor configurado:"
echo "  Nombre : $NAME"
echo "  Tipo   : $TYPE"
echo "  RAM    : $MEMORY"
echo "  Puerto : $PORT"
echo "  Modo   : $MODE"
echo

echo "[100%] FINALIZADO: creación de servidor completada"
echo "Siguiente paso: scripts/stack.sh up $MODE"
