# Quick Start (macOS)

## 1) One-time setup
```
./setup-dependencies.sh
./setup-audible-cli.sh --auto-yes
```

## 2) Convert the audiobook (AAX/AAXC → M4B)
```
./convert-direct.sh -i ./YourBook.aax --trim-intro-outro
```
Output: `./converted/YourBook.m4b`

## 3) Split into chapter tracks (best for Plex)
```
./split-into-tracks.sh -i ./converted/YourBook.m4b
```
Output: `./converted/YourBook (Chapters)/NN - Chapter NN.m4b`

## 4) Move to Plex
Create: `Plex Audiobooks/Author/Book Title/` and move chapter files there. Refresh Plex library.
