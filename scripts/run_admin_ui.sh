#!/usr/bin/env bash
set -euo pipefail

progress(){ echo "[$1%] $2"; }

progress 10 "Validando dependencias base..."
scripts/check_dependencies.sh

progress 30 "Preparando entorno..."
[[ -f .env ]] || cp .env.example .env

progress 50 "Creando servidor por defecto si no existe configuración..."
MC_NAME_VAL=$(grep '^MC_NAME=' .env | cut -d= -f2- || true)
if [[ -z "$MC_NAME_VAL" || ! "$MC_NAME_VAL" =~ ^[a-z0-9-]+$ ]]; then
  scripts/create_server.sh mc-survival PAPER 6G 25565 nocrafty >/dev/null
fi

progress 70 "Levantando stack no-Crafty con monitoreo..."
scripts/stack.sh up nocrafty

progress 90 "Mostrando endpoints..."
echo "UI Admin (esqueleto): http://localhost:8088"
echo "Portainer: https://localhost:9443"
echo "Grafana: http://localhost:3000"

echo "[100%] FINALIZADO: entorno administrativo listo"
