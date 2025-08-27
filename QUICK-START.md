# Quick Start

## 1) One-time setup

### Windows (PowerShell)
```
./setup-audible-cli.ps1 -AutoYes
./setup-dependencies.ps1
```

### macOS (Terminal)
```
./setup-dependencies.sh
./setup-audible-cli.sh --auto-yes
```

## 2) Convert the audiobook (AAX → M4B)

### Windows
```
./convert-direct.ps1 -InputFile ".\YourBook.aax" -TrimIntroOutro
```

### macOS
```
./convert-direct.sh -i ./YourBook.aax --trim-intro-outro
```

Output: `./converted/YourBook.m4b`

## 3) Split into chapter tracks (best for Plex)

### Windows
```
./split-into-tracks.ps1 -InputFile ".\converted\YourBook.m4b"
```

### macOS
```
./split-into-tracks.sh -i ./converted/YourBook.m4b
```

Output: `./converted/YourBook (Chapters)/NN - Chapter NN.m4b`

## 4) Move to Plex
Create: `Plex Audiobooks/Author/Book Title/` and move chapter files there. Refresh Plex library.
