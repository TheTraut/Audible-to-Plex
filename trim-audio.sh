#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -i <input_file> [--trim-start 2] [--trim-end 6]" >&2
}

INPUT_FILE=""
TRIM_START=2
TRIM_END=6

while [ $# -gt 0 ]; do
  case "$1" in
    -i|--input)
      INPUT_FILE="$2"; shift 2 ;;
    --trim-start)
      TRIM_START="$2"; shift 2 ;;
    --trim-end)
      TRIM_END="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

[ -n "$INPUT_FILE" ] || { usage; exit 1; }

command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg not found. Run ./setup-dependencies.sh" >&2; exit 1; }
command -v ffprobe >/dev/null 2>&1 || { echo "ffprobe not found. Run ./setup-dependencies.sh" >&2; exit 1; }

if [ ! -f "$INPUT_FILE" ]; then
  echo "Input file not found: $INPUT_FILE" >&2
  exit 1
fi

echo "Trimming audio file: $INPUT_FILE"
echo "Removing first $TRIM_START seconds and last $TRIM_END seconds"

# Get duration
DURATION=$(ffprobe -i "$INPUT_FILE" -show_entries format=duration -v quiet -of csv="p=0")
DURATION=${DURATION%.*}
TRIMMED_DURATION=$(( DURATION - TRIM_START - TRIM_END ))

dir=$(cd "$(dirname "$INPUT_FILE")" && pwd)
filename=$(basename -- "$INPUT_FILE")
name="${filename%.*}"
ext=".${filename##*.}"
cover_file="$dir/cover_temp.jpg"
temp_file="$dir/${name}_temp$ext"

# Extract cover art (if present)
ffmpeg -i "$INPUT_FILE" -an -codec:v copy "$cover_file" -y >/dev/null 2>&1 || true

# Trim audio
ffmpeg -hide_banner -i "$INPUT_FILE" -ss "$TRIM_START" -t "$TRIMMED_DURATION" -map 0:a -c copy "$temp_file" -y

# Replace original
mv -f "$temp_file" "$INPUT_FILE"

# Re-add cover art if we extracted it
if [ -f "$cover_file" ]; then
  final_temp="$dir/${name}_final$ext"
  ffmpeg -i "$INPUT_FILE" -i "$cover_file" -map 0 -map 1 -codec copy -disposition:v:0 attached_pic "$final_temp" -y >/dev/null 2>&1 || true
  if [ -f "$final_temp" ]; then
    mv -f "$final_temp" "$INPUT_FILE"
  fi
  rm -f "$cover_file"
fi

echo "Audio trimming completed successfully!" 