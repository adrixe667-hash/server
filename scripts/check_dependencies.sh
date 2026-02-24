#!/usr/bin/env bash
set -euo pipefail

missing=0
for cmd in bash tar curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Falta dependencia: $cmd"
    missing=1
  fi
done

if ! command -v docker >/dev/null 2>&1; then
  echo "Falta dependencia: docker"
  missing=1
else
  if ! docker compose version >/dev/null 2>&1; then
    echo "Falta plugin/subcomando: docker compose"
    missing=1
  fi
fi

if [[ "$missing" -eq 1 ]]; then
  echo "Instala las dependencias faltantes y vuelve a ejecutar."
  exit 1
fi

echo "Dependencias básicas OK."
