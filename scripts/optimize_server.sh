#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  echo "No existe .env. Ejecuta scripts/create_server.sh primero."
  exit 1
fi

profile="${1:-balanced}" # low|balanced|high

case "$profile" in
  low)
    VIEW=6; SIM=4; TICK=60000 ;;
  balanced)
    VIEW=8; SIM=6; TICK=60000 ;;
  high)
    VIEW=10; SIM=8; TICK=90000 ;;
  *)
    echo "Uso: scripts/optimize_server.sh [low|balanced|high]"
    exit 1
    ;;
esac

python - <<PY
from pathlib import Path
import re
p=Path('.env')
t=p.read_text()
for k,v in {'VIEW_DISTANCE':'$VIEW','SIMULATION_DISTANCE':'$SIM','MAX_TICK_TIME':'$TICK'}.items():
    t=re.sub(rf'^{k}=.*$', f'{k}={v}', t, flags=re.M)
p.write_text(t)
PY

echo "Perfil aplicado: $profile"
echo "VIEW_DISTANCE=$VIEW"
echo "SIMULATION_DISTANCE=$SIM"
echo "MAX_TICK_TIME=$TICK"
