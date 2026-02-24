#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Se creó .env desde .env.example. Edita contraseñas antes de producción."
fi

docker compose config >/dev/null

echo "Configuración válida."
echo "Siguientes pasos:"
echo "  1) docker compose up -d"
echo "  2) Panel: https://localhost:9443"
echo "  3) Grafana: http://localhost:3000"
