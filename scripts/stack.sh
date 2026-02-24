#!/usr/bin/env bash
set -euo pipefail

action="${1:-up}"
mode="${2:-${PANEL_MODE:-nocrafty}}"

progress() {
  echo "[$1%] $2"
}

progress 10 "Preparando entorno..."
if [[ ! -f .env ]]; then
  cp .env.example .env
fi

# shellcheck disable=SC1091
source .env

progress 25 "Seleccionando perfiles por modo..."
profiles=()
if [[ "$mode" == "crafty" ]]; then
  profiles+=("crafty")
else
  profiles+=("nocrafty")
fi

if [[ "${ENABLE_MONITORING:-true}" == "true" ]]; then
  profiles+=("monitoring")
fi

if [[ "${ENABLE_HOMEASSISTANT:-false}" == "true" ]]; then
  profiles+=("homeassistant")
fi

profile_args=()
for p in "${profiles[@]}"; do
  profile_args+=(--profile "$p")
done

progress 60 "Ejecutando acción sobre el stack..."
case "$action" in
  up) docker compose "${profile_args[@]}" up -d ;;
  down) docker compose "${profile_args[@]}" down ;;
  restart) docker compose "${profile_args[@]}" restart ;;
  ps) docker compose "${profile_args[@]}" ps ;;
  *)
    echo "Uso: scripts/stack.sh [up|down|restart|ps] [crafty|nocrafty]"
    exit 1
    ;;
esac

progress 100 "FINALIZADO: acción '$action' completada"
