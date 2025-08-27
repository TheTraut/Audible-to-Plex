# Quick Start (macOS)

## 1) One-time setup
```
./setup-dependencies.sh
./setup-audible-cli.sh --auto-yes
```

## 2) Convert the audiobook (AAX/AAXC → M4B)
```
./convert-direct.sh -i ./YourBook.aax 
```
Add "--trim-intro-outro" to trim off audibles intros and outros
Output: `./converted/YourBook.m4b`

Note: The converter will auto-save activation bytes on first run when possible. If it prompts, you can paste them once, or save in advance with:
```
./audible-cli-wrapper.sh activation-bytes | tr -d '\n' > audible-activation-code.txt
```

If you encrypted your audible-cli auth file, either export the password once per shell:
```
export AUDIBLE_AUTH_PASSWORD="your-password"
```
or pass it to the converter directly:
```
./convert-direct.sh -i ./YourBook.aax --audible-password "your-password"
```

## 3) Split into chapter tracks (best for Plex)
```
./split-into-tracks.sh -i ./converted/YourBook.m4b
```
Output: `./converted/YourBook (Chapters)/NN - Chapter NN.m4b`

## 4) Move to Plex
Create: `Plex Audiobooks/Author/Book Title/` and move chapter files there. Refresh Plex library.
