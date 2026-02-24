#!/usr/bin/env bash
set -euo pipefail

scripts/check_dependencies.sh || true

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Se creó .env desde .env.example. Edita contraseñas antes de producción."
fi

# Validar nombre compatible
MC_NAME_VAL=$(grep "^MC_NAME=" .env | cut -d= -f2- || true)
if [[ -z "$MC_NAME_VAL" || ! "$MC_NAME_VAL" =~ ^[a-z0-9-]+$ ]]; then
  echo "MC_NAME no compatible. Usa solo: a-z, 0-9 y guion (-)."
  exit 1
fi

docker compose config >/dev/null

echo "Configuración válida."
echo "Siguientes pasos:"
echo "  1) docker compose up -d"
echo "  2) Panel: https://localhost:9443"
echo "  3) Grafana: http://localhost:3000"
