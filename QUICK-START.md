# Quick Start

## 1) One-time setup
```
./setup-audible-cli.ps1 -AutoYes
./setup-dependencies.ps1
```

## 2) Convert the audiobook (AAX → M4B)
```
./convert-direct.ps1 -InputFile ".\YourBook.aax" -TrimIntroOutro
```
Output: `./converted/YourBook.m4b`

## 3) Split into chapter tracks (best for Plex)
```
./split-into-tracks.ps1 -InputFile ".\converted\YourBook.m4b"
```
Output: `./converted/YourBook (Chapters)/NN - Chapter NN.m4b`

## 4) Move to Plex
Create: `Plex Audiobooks/Author/Book Title/` and move chapter files there. Refresh Plex library.
