#!/usr/bin/env bash
set -euo pipefail

EVENT="${1:-}"
MESSAGE="${2:-}"
URL="${HA_WEBHOOK_URL:-}"

if [[ -z "$EVENT" || -z "$MESSAGE" || -z "$URL" ]]; then
  echo "Uso: HA_WEBHOOK_URL=<url> scripts/ha_event.sh <evento> <mensaje>"
  exit 1
fi

payload=$(cat <<JSON
{"event":"$EVENT","message":"$MESSAGE","ts":"$(date -Iseconds)"}
JSON
)

curl -sS -X POST "$URL" \
  -H 'Content-Type: application/json' \
  -d "$payload" >/dev/null

echo "Evento enviado a Home Assistant: $EVENT"
