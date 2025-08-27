param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    [string]$OutputDir = '.\\converted',
    [switch]$TrimIntroOutro = $false
)

$ffmpeg = '.\\tools\\ffmpeg\\bin\\ffmpeg.exe'
if (!(Test-Path $ffmpeg)) { Write-Host 'FFmpeg not found. Run .\\setup-dependencies.ps1.' -ForegroundColor Red; exit 1 }
if (!(Test-Path $InputFile)) { Write-Host ('Input not found: ' + $InputFile) -ForegroundColor Red; exit 1 }
if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

# Read and sanitize activation bytes (8 hex)
$authCode = ''
if (Test-Path 'audible-activation-code.txt') { $authCode = (Get-Content -Raw 'audible-activation-code.txt') }
if ([string]::IsNullOrWhiteSpace($authCode)) { $authCode = (Read-Host 'Enter Audible activation bytes (8 hex)') }
$m = [regex]::Match([string]$authCode, '[0-9a-fA-F]{8}')
if (-not $m.Success) { Write-Host 'Invalid activation bytes. Expect 8 hex characters.' -ForegroundColor Red; exit 1 }
$authCode = $m.Value

# Build output path
$name = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$outFile = Join-Path $OutputDir ($name + '.m4b')

Write-Host ('Converting to: ' + $outFile) -ForegroundColor Green

# Decrypt and remux (copy audio), keep metadata and chapters
& $ffmpeg -hide_banner -y -activation_bytes $authCode -i $InputFile -map_metadata 0 -map_chapters 0 -vn -c:a copy $outFile | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host 'Conversion failed.' -ForegroundColor Red; exit 1 }

if ($TrimIntroOutro) {
  & .\\trim-audio.ps1 -InputFile $outFile
}

Write-Host 'Done.' -ForegroundColor Green
Write-Host ('Output: ' + $outFile) -ForegroundColor Cyan
exit 0


