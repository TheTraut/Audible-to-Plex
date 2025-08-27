#!/usr/bin/env bash
set -euo pipefail

AUTO_YES=false
SKIP_QUICKSTART=false

for arg in "$@"; do
  case "$arg" in
    --auto-yes)
      AUTO_YES=true
      shift
      ;;
    --skip-quickstart)
      SKIP_QUICKSTART=true
      shift
      ;;
    *)
      ;;
  esac
done

echo "Audible CLI Setup Wizard"
echo "========================"

if ! command -v audible >/dev/null 2>&1; then
  echo "audible CLI not found. Installing with pip3..."
  if command -v pip3 >/dev/null 2>&1; then
    pip3 install --user audible-cli
  else
    echo "pip3 not found. Please install Python 3 and pip3, then re-run." >&2
    exit 1
  fi
fi

if [ "$AUTO_YES" = true ]; then
  PROCEED="y"
else
  read -r -p "Proceed with setup? (y/n) " PROCEED
fi

if [ "$PROCEED" != "y" ] && [ "$PROCEED" != "Y" ]; then
  echo "Setup cancelled."
  exit 0
fi

if [ "$SKIP_QUICKSTART" = false ]; then
  echo "Starting audible-cli quickstart..."
  ./audible-cli-wrapper.sh quickstart || true
fi

echo "Testing setup..."
if ./audible-cli-wrapper.sh manage profile list >/dev/null 2>&1; then
  echo "Profile configuration detected."
  echo "Extracting activation code..."
  if ACT_BYTES=$(./audible-cli-wrapper.sh activation-bytes 2>/dev/null); then
    if [[ "$ACT_BYTES" =~ ^[0-9a-fA-F]{8}$ ]]; then
      printf "%s" "$ACT_BYTES" > audible-activation-code.txt
      echo "Activation code saved to audible-activation-code.txt"
    else
      echo "Could not retrieve valid activation bytes automatically."
    fi
  else
    echo "Activation bytes command failed."
  fi
else
  echo "audible-cli profile not configured; run quickstart again if needed."
fi

echo "Done." 