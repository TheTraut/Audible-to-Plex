# Audible to Plex Converter (macOS)

This project converts Audible AAX/AAXC audiobooks to Plex-friendly M4B files and (optionally) splits them into per‑chapter tracks for the best Plex experience.

## Features
- Convert AAX/AAXC to M4B using FFmpeg and your activation bytes
- Preserve embedded metadata and chapters
- Optional: split M4B into chapter tracks for Plex (album-like browsing)
- Uses Homebrew for dependencies on macOS

## Requirements
- macOS (Apple Silicon or Intel) with bash/zsh
- Python + audible-cli (to obtain activation bytes)
- Your Audible account

## Quick Start (macOS)

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
- To verify chapters in an M4B:
```
ffprobe -v error -print_format json -show_chapters -show_format ./converted/YourBook.m4b > chapters.json
```
- If you only want a single file (no split), you can skip step 3. Plex may not show embedded chapters, but the file will play fine.

## Scripts (macOS)
- `setup-dependencies.sh` – Install FFmpeg and jq via Homebrew
- `setup-audible-cli.sh` – Configure audible-cli and save activation bytes
- `convert-direct.sh` – Convert AAX/AAXC → M4B (metadata + chapters preserved)
- `split-into-tracks.sh` – Create per‑chapter M4B tracks
- `trim-audio.sh` – Trim Audible intro/outro on a given M4B
- `audible-cli-wrapper.sh` – Wrapper to call audible-cli reliably

## Activation bytes
- The converter needs your Audible activation bytes (8 hex). `convert-direct.sh` will now auto-fetch and save them to `audible-activation-code.txt` on first run (if possible), falling back to a prompt only if needed.
- You can also save them manually if desired:
```
./audible-cli-wrapper.sh activation-bytes | tr -d '\n' > audible-activation-code.txt
```

### Encrypted audible-cli auth
- If you encrypted your audible-cli auth file, set a password before running commands:
```
export AUDIBLE_AUTH_PASSWORD="your-password"
```
- Or pass it to the converter directly:
```
./convert-direct.sh -i ./YourBook.aax --audible-password "your-password"
```

## Legal
- For personal use only with books you own.
- Respect copyright and DRM laws.
