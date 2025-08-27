#!/usr/bin/env bash
set -euo pipefail

# Audible CLI wrapper for macOS/Linux
# Usage: ./audible-cli-wrapper.sh [args...]

if command -v audible >/dev/null 2>&1; then
  exec audible "$@"
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 -m audible_cli --version >/dev/null 2>&1; then
    exec python3 -m audible_cli "$@"
  fi
fi

echo "audible CLI not found. Install with: pip3 install --user audible-cli" >&2
exit 1 