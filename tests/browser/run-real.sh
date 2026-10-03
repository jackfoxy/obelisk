#!/usr/bin/env bash
# Obelisk's own browser workflows in real Chromium.  urui proves its
# generic behaviour in its own suite; these prove obelisk's composition.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
exec ./node_modules/.bin/playwright test \
  --config tests/browser/real/playwright.config.js
