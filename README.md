# Audible to Plex Converter

This project converts Audible AAX/AAXC audiobooks to Plex-friendly M4B files and (optionally) splits them into per‑chapter tracks for the best Plex experience.

## Features
- Convert AAX to M4B using FFmpeg and your activation bytes
- Preserve embedded metadata and chapters
- Optional: split M4B into chapter tracks for Plex (album-like browsing)
- No admin rights required; portable FFmpeg on Windows / Homebrew on macOS

## Requirements
- Windows 10/11 with PowerShell, or macOS (Intel/Apple Silicon) with bash/zsh
- Python + audible-cli (to obtain activation bytes)
- Your Audible account

## Quick Start

### Windows (PowerShell)

1) Setup
- Run audible-cli setup (one-time):
```
./setup-audible-cli.ps1 -AutoYes
```
- Portable FFmpeg (if needed):
```
./setup-dependencies.ps1
```

2) Convert a book (AAX → M4B)
```
./convert-direct.ps1 -InputFile ".\YourBook.aax" -TrimIntroOutro
```
- Uses `audible-activation-code.txt` if present, or prompts for activation bytes (8 hex)
- Outputs to `./converted/YourBook.m4b`

3) Split into chapter tracks (recommended for Plex)
```
./split-into-tracks.ps1 -InputFile ".\converted\YourBook.m4b"
```
- Outputs: `./converted/YourBook (Chapters)/NN - Chapter NN.m4b`

### macOS (Apple Silicon or Intel)

1) Setup
- Install/verify dependencies (ffmpeg, ffprobe, jq):
```
./setup-dependencies.sh
```
- audible-cli setup (one-time):
```
./setup-audible-cli.sh --auto-yes
```

2) Convert a book (AAX/AAXC → M4B)
```
./convert-direct.sh -i ./YourBook.aax --trim-intro-outro
```
- Uses `audible-activation-code.txt` if present, or prompts for activation bytes (8 hex)
- Outputs to `./converted/YourBook.m4b`

3) Split into chapter tracks (recommended for Plex)
```
./split-into-tracks.sh -i ./converted/YourBook.m4b
```
- Outputs: `./converted/YourBook (Chapters)/NN - Chapter NN.m4b`

4) Organize for Plex
- Create folders like `Plex Audiobooks/Author/Book Title/`
- Move chapter tracks into the `Book Title` folder
- Add/refresh your Plex Music library to point at `Plex Audiobooks`

## Tips
- To verify chapters in an M4B (Windows example):
```
./tools/ffmpeg/bin/ffprobe.exe -v error -print_format json -show_chapters -show_format ".\converted\YourBook.m4b" > chapters.json
```
- macOS example:
```
ffprobe -v error -print_format json -show_chapters -show_format ./converted/YourBook.m4b > chapters.json
```
- If you only want a single file (no split), you can skip step 3. Plex may not show embedded chapters, but the file will play fine.

## Scripts
- `setup-audible-cli.ps1` / `setup-audible-cli.sh` – Configure audible-cli and save activation bytes
- `setup-dependencies.ps1` / `setup-dependencies.sh` – Install FFmpeg (portable on Windows / Homebrew on macOS)
- `convert-direct.ps1` / `convert-direct.sh` – Convert AAX → M4B (metadata + chapters preserved)
- `split-into-tracks.ps1` / `split-into-tracks.sh` – Create per‑chapter M4B tracks
- `trim-audio.ps1` / `trim-audio.sh` – Trim Audible intro/outro on a given M4B

## Legal
- For personal use only with books you own.
- Respect copyright and DRM laws.
