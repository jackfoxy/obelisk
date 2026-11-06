#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URUI="$ROOT/../urui"
if [[ ! -x "$URUI/bin/verify-sync.sh" ]]; then
  echo 'urui checkout not found at ../urui — clone it beside this repo to check sync status' >&2
  exit 1
fi
exec "$URUI/bin/verify-sync.sh" --dest "$ROOT" "$@"
