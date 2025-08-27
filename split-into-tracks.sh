#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -i <input_file> [--output-dir <dir>]" >&2
}

INPUT_FILE=""
OUTPUT_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    -i|--input)
      INPUT_FILE="$2"; shift 2 ;;
    --output-dir)
      OUTPUT_DIR="$2"; shift 2 ;;
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

[ -n "$INPUT_FILE" ] || { usage; exit 1; }

command -v ffprobe >/dev/null 2>&1 || { echo "ffprobe not found. Run ./setup-dependencies.sh" >&2; exit 1; }
command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg not found. Run ./setup-dependencies.sh" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq not found. Run ./setup-dependencies.sh" >&2; exit 1; }

if [ -z "$OUTPUT_DIR" ]; then
  base=$(basename -- "$INPUT_FILE")
  base="${base%.*}"
  dir=$(cd "$(dirname "$INPUT_FILE")" && pwd)
  OUTPUT_DIR="$dir/$base (Chapters)"
fi
mkdir -p "$OUTPUT_DIR"

json=$(ffprobe -v quiet -print_format json -show_chapters -show_format -i "$INPUT_FILE")
chap_count=$(printf '%s' "$json" | jq '.chapters | length')
if [ "$chap_count" -eq 0 ]; then
  echo "No chapters found in file."
  exit 0
fi

album=$(printf '%s' "$json" | jq -r '.format.tags.album // empty')
artist=$(printf '%s' "$json" | jq -r '.format.tags.artist // empty')

num=1
printf '%s' "$json" | jq -r '.chapters[] | [.start_time, .end_time, (.tags.title // ("Chapter "+(0|tostring)))] | @tsv' | while IFS=$'\t' read -r start end title; do
  printf -v track "%02d - %s.m4b" "$num" "${title//[<>:"/\\|?*]/_}"
  out_path="$OUTPUT_DIR/$track"
  echo "Creating: $track"
  ffmpeg -hide_banner -y -i "$INPUT_FILE" -ss "$start" -to "$end" -map 0:a -c copy -metadata title="$title" -metadata album="$album" -metadata artist="$artist" -metadata track=$num "$out_path" >/dev/null
  num=$((num+1))
done

echo "Chapter split complete: $OUTPUT_DIR" 