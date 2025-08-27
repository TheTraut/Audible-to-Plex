#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -i <input_file> [--output-dir ./converted] [--trim-intro-outro] [--audible-password <pw>]" >&2
}

INPUT_FILE=""
OUTPUT_DIR="./converted"
TRIM=false
AUDIBLE_PASSWORD_ARG=""

while [ $# -gt 0 ]; do
  case "$1" in
    -i|--input)
      INPUT_FILE="$2"; shift 2 ;;
    --output-dir)
      OUTPUT_DIR="$2"; shift 2 ;;
    --trim-intro-outro)
      TRIM=true; shift ;;
    --audible-password)
      AUDIBLE_PASSWORD_ARG="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      if [ -z "$INPUT_FILE" ] && [ -f "$1" ]; then
        INPUT_FILE="$1"; shift
      else
        echo "Unknown argument: $1" >&2; usage; exit 1
      fi ;;
  esac
done

if [ -z "$INPUT_FILE" ]; then
  usage; exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg not found. Run ./setup-dependencies.sh" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

AUTH_BYTES=""
# Try file first
if [ -f audible-activation-code.txt ]; then
  AUTH_BYTES=$(tr -d '\n\r' < audible-activation-code.txt)
fi
# If missing, try to auto-fetch via audible-cli
if [ -z "$AUTH_BYTES" ]; then
  if [ -x ./audible-cli-wrapper.sh ]; then
    # Prefer explicit flag, else fall back to env var
    if [ -n "$AUDIBLE_PASSWORD_ARG" ]; then
      export AUDIBLE_AUTH_PASSWORD="$AUDIBLE_PASSWORD_ARG"
    fi
    if ACT_BYTES=$(./audible-cli-wrapper.sh activation-bytes 2>/dev/null); then
      if [[ "$ACT_BYTES" =~ ^[0-9a-fA-F]{8}$ ]]; then
        AUTH_BYTES="$ACT_BYTES"
        printf "%s" "$AUTH_BYTES" > audible-activation-code.txt
        echo "Saved activation bytes to audible-activation-code.txt"
      fi
    fi
  fi
fi
# Fallback to interactive prompt
if [ -z "$AUTH_BYTES" ]; then
  read -r -p "Enter Audible activation bytes (8 hex): " AUTH_BYTES
fi
if ! [[ "$AUTH_BYTES" =~ ^[0-9a-fA-F]{8}$ ]]; then
  echo "Invalid activation bytes; expected 8 hex characters." >&2
  exit 1
fi

name=$(basename -- "$INPUT_FILE")
name="${name%.*}"
out_file="$OUTPUT_DIR/$name.m4b"

echo "Converting to: $out_file"

ffmpeg -hide_banner -y -activation_bytes "$AUTH_BYTES" -i "$INPUT_FILE" -map_metadata 0 -map_chapters 0 -vn -c:a copy "$out_file"

if [ "$TRIM" = true ]; then
  ./trim-audio.sh -i "$out_file"
fi

echo "Done. Output: $out_file" 