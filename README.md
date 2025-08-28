# Audible to Plex Converter

This project converts Audible AAX/AAXC audiobooks to Plex‑friendly M4B files and (optionally) splits them into per‑chapter tracks for the best Plex experience.

## Features
- Convert AAX/AAXC to M4B using FFmpeg and your activation bytes
- Preserve embedded metadata and chapters
- Optional: split M4B into chapter tracks for Plex (album‑like browsing)
- No admin rights required; portable FFmpeg on Windows, Homebrew support on macOS

## Requirements
- Windows 10/11 with PowerShell or macOS/Linux with Bash
- Python + audible-cli (to obtain activation bytes)
- Your Audible account

## Quick Start

### Windows (PowerShell)
1) Setup audible-cli and dependencies
```
./setup-audible-cli.ps1 -AutoYes
./setup-dependencies.ps1
```
2) Convert a book (AAX → M4B)
```
./convert-direct.ps1 -InputFile ".\YourBook.aax" [-TrimIntroOutro] [-AudiblePassword "your_pw_if_encrypted"]
```
- Uses `audible-activation-code.txt` if present
- If missing, auto-fetches via `audible-cli activation-bytes` and saves it
3) Split into chapter tracks (recommended for Plex)
```
./split-into-tracks.ps1 -InputFile ".\converted\YourBook.m4b"
```

### macOS/Linux (Bash)
1) Setup audible-cli and dependencies
```
./setup-audible-cli.sh --auto-yes
./setup-dependencies.sh
```
2) Convert a book (AAX → M4B)
```
./convert-direct.sh -i "./YourBook.aax" [--trim-intro-outro] [--audible-password "your_pw_if_encrypted"]
```
- Uses `audible-activation-code.txt` if present
- If missing, auto-fetches via `./audible-cli-wrapper.sh activation-bytes` and saves it
3) Split into chapter tracks (recommended for Plex)
```
./split-into-tracks.sh -i "./converted/YourBook.m4b"
```

4) Organize for Plex
- Create folders like `Plex Audiobooks/Author/Book Title/`
- Move chapter tracks into the `Book Title` folder
- Add/refresh your Plex Music library to point at `Plex Audiobooks`

## Tips
- To verify chapters in an M4B (Windows):
```
./tools/ffmpeg/bin/ffprobe.exe -v error -print_format json -show_chapters -show_format ".\converted\YourBook.m4b" > chapters.json
```
- To verify chapters in an M4B (macOS/Linux):
```
ffprobe -v error -print_format json -show_chapters -show_format "./converted/YourBook.m4b" > chapters.json
```
- If you only want a single file (no split), you can skip the split step. Plex may not show embedded chapters, but the file will play fine.

## Scripts
- Windows: `setup-audible-cli.ps1`, `setup-dependencies.ps1`, `convert-direct.ps1`, `split-into-tracks.ps1`, `trim-audio.ps1`, `audible-cli-wrapper.ps1`
- macOS/Linux: `setup-audible-cli.sh`, `setup-dependencies.sh`, `convert-direct.sh`, `split-into-tracks.sh`, `trim-audio.sh`, `audible-cli-wrapper.sh`

Notes:
- The wrapper scripts will prefer `audible` on PATH and fall back to Python module execution.
- You can pass the password for encrypted auth files using `AUDIBLE_AUTH_PASSWORD` (macOS/Linux) or `-AudiblePassword`/`$env:AUDIBLE_AUTH_PASSWORD` (Windows).

## Legal
- For personal use only with books you own.
- Respect copyright and DRM laws.
