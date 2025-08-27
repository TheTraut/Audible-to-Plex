#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -i <input_file> [--output-dir ./converted] [--trim-intro-outro]" >&2
}

INPUT_FILE=""
OUTPUT_DIR="./converted"
TRIM=false

while [ $# -gt 0 ]; do
  case "$1" in
    -i|--input)
      INPUT_FILE="$2"; shift 2 ;;
    --output-dir)
      OUTPUT_DIR="$2"; shift 2 ;;
    --trim-intro-outro)
      TRIM=true; shift ;;
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
if [ -f audible-activation-code.txt ]; then
  AUTH_BYTES=$(tr -d '\n\r' < audible-activation-code.txt)
fi
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