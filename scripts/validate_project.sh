#!/usr/bin/env bash
set -euo pipefail

echo "[20%] Validando sintaxis de scripts..."
bash -n scripts/*.sh

echo "[40%] Verificando archivos clave..."
for f in docker-compose.yml .env.example monitoring/prometheus.yml README.md docs/USO_PROYECTO.md docs/GUIA_CRAFTY_OPTIMIZACION.md GUIA_SERVIDOR_HEADLESS.md; do
  [[ -f "$f" ]] || { echo "Falta: $f"; exit 1; }
done

echo "[60%] Revisando consistencia de guías..."
rg -n "crafty|nocrafty|Home Assistant|create_server|stack.sh|optimize_server" README.md docs/USO_PROYECTO.md docs/GUIA_CRAFTY_OPTIMIZACION.md GUIA_SERVIDOR_HEADLESS.md >/dev/null

echo "[80%] Probando scripts en modo seguro..."
scripts/create_server.sh mc-validate PAPER 4G 25576 nocrafty >/dev/null
scripts/optimize_server.sh low >/dev/null

if command -v docker >/dev/null 2>&1; then
  echo "[90%] Validando compose..."
  docker compose config >/dev/null
else
  echo "[90%] Aviso: docker no disponible, se omite compose config"
fi

echo "[100%] FINALIZADO: validación del proyecto completada"
