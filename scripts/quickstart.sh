#!/usr/bin/env bash
set -euo pipefail

scripts/check_dependencies.sh

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Se creó .env desde .env.example."
fi

# Validar nombre compatible
MC_NAME_VAL=$(grep "^MC_NAME=" .env | cut -d= -f2- || true)
if [[ -z "$MC_NAME_VAL" || ! "$MC_NAME_VAL" =~ ^[a-z0-9-]+$ ]]; then
  echo "MC_NAME no compatible. Usa solo: a-z, 0-9 y guion (-)."
  exit 1
fi

# shellcheck disable=SC1091
source .env
MODE="${PANEL_MODE:-nocrafty}"

docker compose config >/dev/null

echo "Configuración válida."
echo "Crea servidor si quieres cambiar parámetros:"
echo "  scripts/create_server.sh <nombre> <tipo> <ram> <puerto> <crafty|nocrafty>"
echo "Levantar stack:"
echo "  scripts/stack.sh up $MODE"
