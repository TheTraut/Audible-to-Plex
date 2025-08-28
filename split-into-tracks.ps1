param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    [string]$OutputDir = ''
)

$ffmpeg = '.\\tools\\ffmpeg\\bin\\ffmpeg.exe'
$ffprobe = '.\\tools\\ffmpeg\\bin\\ffprobe.exe'
if (!(Test-Path $ffmpeg) -or !(Test-Path $ffprobe)) { Write-Host 'FFmpeg/ffprobe not found. Run .\\setup-dependencies.ps1.' -ForegroundColor Red; exit 1 }
if (!(Test-Path $InputFile)) { Write-Host ('Input not found: ' + $InputFile) -ForegroundColor Red; exit 1 }

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $base = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
  $parent = [System.IO.Path]::GetDirectoryName($InputFile)
  $OutputDir = Join-Path $parent ($base + ' (Chapters)')
}
if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

# Probe chapters
$json = & $ffprobe -v quiet -print_format json -show_chapters -show_format -i $InputFile
$data = $null
try { $data = $json | ConvertFrom-Json } catch { Write-Host 'Failed to parse chapter data.' -ForegroundColor Red; exit 1 }
if (-not $data.chapters -or $data.chapters.Count -eq 0) { Write-Host 'No chapters found in file.' -ForegroundColor Yellow; exit 0 }

$album = if ($data.format.tags.album) { $data.format.tags.album } else { [System.IO.Path]::GetFileNameWithoutExtension($InputFile) }
$artist = if ($data.format.tags.artist) { $data.format.tags.artist } else { '' }

$num = 1
foreach ($ch in $data.chapters) {
  $start = [double]::Parse($ch.start_time)
  $end = [double]::Parse($ch.end_time)
  $dur = [math]::Max(0.1, $end - $start)
  $title = if ($ch.tags.title) { $ch.tags.title } else { 'Chapter ' + $num }
  $safeTitle = ($title -replace '[<>:"/\\|?*]', '_').Trim()
  $track = ($num.ToString('00')) + ' - ' + $safeTitle + '.m4b'
  $outPath = Join-Path $OutputDir $track

  Write-Host ('Creating: ' + $track) -ForegroundColor Green
  & $ffmpeg -hide_banner -y -i $InputFile -ss $start -t $dur -map 0:a -c copy -metadata title="$title" -metadata album="$album" -metadata artist="$artist" -metadata track=$num $outPath | Out-Null
  if ($LASTEXITCODE -ne 0) { Write-Host ('Failed track ' + $num) -ForegroundColor Yellow }
  $num++
}

Write-Host ('Chapter split complete: ' + $OutputDir) -ForegroundColor Cyan
exit 0


