#!/usr/bin/env bash
set -euo pipefail

# Audible CLI wrapper for macOS/Linux
# Usage: ./audible-cli-wrapper.sh [args...]

args=("$@")

# Inject password for encrypted auth files if provided via env var and not already set
if [ -n "${AUDIBLE_AUTH_PASSWORD:-}" ]; then
  has_pass=""
  for a in "${args[@]}"; do
    if [ "$a" = "-p" ] || [ "$a" = "--password" ]; then
      has_pass="1"
      break
    fi
  done
  if [ -z "$has_pass" ]; then
    args=( -p "$AUDIBLE_AUTH_PASSWORD" "${args[@]}" )
  fi
fi

if command -v audible >/dev/null 2>&1; then
  exec audible "${args[@]}"
fi

# Try the user's Python user-base bin (common on macOS with --user installs)
USER_BASE_BIN=$(python3 -c "import site, os; print(os.path.join(site.getuserbase(), 'bin'))" 2>/dev/null || true)
if [ -n "${USER_BASE_BIN:-}" ] && [ -x "$USER_BASE_BIN/audible" ]; then
  exec "$USER_BASE_BIN/audible" "$@"
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 -m audible_cli --version >/dev/null 2>&1; then
    exec python3 -m audible_cli "${args[@]}"
  fi
fi

echo "audible CLI not found. Install with: pip3 install --user audible-cli" >&2
exit 1 