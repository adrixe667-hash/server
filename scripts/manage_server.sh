#!/usr/bin/env bash
set -euo pipefail

MC_NAME="${MC_NAME:-mc-survival}"

usage() {
  cat <<USAGE
Uso:
  scripts/manage_server.sh start
  scripts/manage_server.sh stop
  scripts/manage_server.sh restart
  scripts/manage_server.sh status
  scripts/manage_server.sh logs
  scripts/manage_server.sh op <jugador>
  scripts/manage_server.sh deop <jugador>
  scripts/manage_server.sh give <jugador> <item> [cantidad]
  scripts/manage_server.sh kick <jugador> [razon]
  scripts/manage_server.sh ban <jugador> [razon]
  scripts/manage_server.sh mute <jugador>
USAGE
}

run_mc_cmd() {
  local cmd="$*"
  docker exec -i "$MC_NAME" rcon-cli "$cmd"
}

cmd="${1:-}"
case "$cmd" in
  start) docker compose up -d minecraft ;;
  stop) docker compose stop minecraft ;;
  restart) docker compose restart minecraft ;;
  status) docker ps --filter "name=$MC_NAME" ;;
  logs) docker logs -f "$MC_NAME" ;;
  op)
    player="${2:-}"; [[ -n "$player" ]] || { usage; exit 1; }
    run_mc_cmd "op $player" ;;
  deop)
    player="${2:-}"; [[ -n "$player" ]] || { usage; exit 1; }
    run_mc_cmd "deop $player" ;;
  give)
    player="${2:-}"; item="${3:-}"; qty="${4:-1}"
    [[ -n "$player" && -n "$item" ]] || { usage; exit 1; }
    run_mc_cmd "give $player $item $qty" ;;
  kick)
    player="${2:-}"; reason="${3:-Expulsado por administrador}"
    [[ -n "$player" ]] || { usage; exit 1; }
    run_mc_cmd "kick $player $reason" ;;
  ban)
    player="${2:-}"; reason="${3:-Baneado por administrador}"
    [[ -n "$player" ]] || { usage; exit 1; }
    run_mc_cmd "ban $player $reason" ;;
  mute)
    player="${2:-}"; [[ -n "$player" ]] || { usage; exit 1; }
    echo "Mute depende de plugin (Essentials/LuckPerms). Ejemplo:"
    echo "  /lp user $player permission set essentials.mute true"
    ;;
  *) usage; exit 1 ;;
esac
