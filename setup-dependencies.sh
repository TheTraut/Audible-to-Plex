#!/usr/bin/env bash
set -euo pipefail

echo "Setting up dependencies (ffmpeg, ffprobe, jq) for macOS..."

need_ffmpeg=false
need_jq=false

if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v ffprobe >/dev/null 2>&1; then
  need_ffmpeg=true
fi

if ! command -v jq >/dev/null 2>&1; then
  need_jq=true
fi

if [ "$need_ffmpeg" = false ] && [ "$need_jq" = false ]; then
  echo "All dependencies already present."
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  echo "Using Homebrew to install missing dependencies..."
  if [ "$need_ffmpeg" = true ]; then
    brew install ffmpeg
  fi
  if [ "$need_jq" = true ]; then
    brew install jq
  fi
else
  echo "Homebrew not found. Please install Homebrew from https://brew.sh and re-run this script." >&2
  echo "Alternatively, install dependencies manually:" >&2
  echo "  - ffmpeg (with ffprobe)" >&2
  echo "  - jq" >&2
  exit 1
fi

echo "Setup complete." 