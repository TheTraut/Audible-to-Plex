# Changelog

## 1.4.0 - 2025-08-27
- Mac branch is now macOS-only (Apple Silicon/Intel)
- Removed Windows PowerShell scripts and Windows-specific docs
- Simplified README and Quick Start to macOS usage only

### Improvements
- Wrapper now discovers audible-cli in Python user base bin
- Added docs for saving activation bytes to `audible-activation-code.txt`
- `convert-direct.sh` now auto-fetches and saves activation bytes on first run
- Encrypted auth support: supply password via `AUDIBLE_AUTH_PASSWORD` or `--audible-password`

## 1.3.0 - 2025-08-27
- Added macOS (Apple Silicon/Intel) support with new shell scripts:
  - `setup-dependencies.sh`, `setup-audible-cli.sh`, `convert-direct.sh`, `split-into-tracks.sh`, `trim-audio.sh`, `audible-cli-wrapper.sh`
- Updated README and QUICK-START with macOS instructions

## 1.2.0 - 2025-08-26
- Simplified workflow to FFmpeg-only conversion + chapter splitting
- Removed AAXtoMP3 and bash-based scripts
- Added `convert-direct.ps1` and `split-into-tracks.ps1`
- Updated README and QUICK-START

## 1.1.0 - 2025-01-26
- audible-cli integration and docs

## 1.0.0 - 2025-01-26
- Initial scripts and setup
