# Audio Trimming Script
# Removes Audible intro/outro from converted audiobooks

param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [int]$TrimStart = 2,
    
    [Parameter(Mandatory=$false)]
    [int]$TrimEnd = 6
)

$ffmpegPath = ".\tools\ffmpeg\bin\ffmpeg.exe"
$ffprobePath = ".\tools\ffmpeg\bin\ffprobe.exe"

if (!(Test-Path $ffmpegPath) -or !(Test-Path $ffprobePath)) {
    Write-Host "FFmpeg tools not found. Please run setup-dependencies.ps1 first." -ForegroundColor Red
    exit 1
}

if (!(Test-Path $InputFile)) {
    Write-Host "Input file not found: $InputFile" -ForegroundColor Red
    exit 1
}

Write-Host "Trimming audio file: $InputFile" -ForegroundColor Green
Write-Host "Removing first $TrimStart seconds and last $TrimEnd seconds" -ForegroundColor Yellow

try {
    # Get duration of the file
    $durationOutput = & $ffprobePath -i "$InputFile" -show_entries format=duration -v quiet -of csv="p=0"
    $duration = [math]::Floor([double]$durationOutput)
    $trimmedDuration = $duration - $TrimStart - $TrimEnd
    
    Write-Host "Original duration: $duration seconds" -ForegroundColor Cyan
    Write-Host "Trimmed duration: $trimmedDuration seconds" -ForegroundColor Cyan
    
    # Create temp file names
    $directory = [System.IO.Path]::GetDirectoryName($InputFile)
    $filename = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $extension = [System.IO.Path]::GetExtension($InputFile)
    $coverFile = Join-Path $directory "cover_temp.jpg"
    $tempFile = Join-Path $directory "$filename`_temp$extension"
    
    # Extract cover art
    Write-Host "Extracting cover art..." -ForegroundColor Yellow
    & $ffmpegPath -i "$InputFile" -an -codec:v copy "$coverFile" -y 2>$null
    
    # Trim the audio
    Write-Host "Trimming audio..." -ForegroundColor Yellow
    & $ffmpegPath -hide_banner -i "$InputFile" -ss $TrimStart -t $trimmedDuration -map 0:a -c copy "$tempFile" -y
    
    if ($LASTEXITCODE -eq 0) {
        # Replace original file
        Remove-Item "$InputFile" -Force
        Rename-Item "$tempFile" (Split-Path $InputFile -Leaf)
        
        # Re-add cover art if it was extracted
        if (Test-Path $coverFile) {
            Write-Host "Re-adding cover art..." -ForegroundColor Yellow
            # This requires mp4art which might not be available on Windows
            # Alternative: use ffmpeg to add the cover
            $finalTemp = Join-Path $directory "$filename`_final$extension"
            & $ffmpegPath -i "$InputFile" -i "$coverFile" -map 0 -map 1 -codec copy -disposition:v:0 attached_pic "$finalTemp" -y 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                Remove-Item "$InputFile" -Force
                Rename-Item "$finalTemp" (Split-Path $InputFile -Leaf)
            }
            
            Remove-Item "$coverFile" -Force -ErrorAction SilentlyContinue
        }
        
        Write-Host "Audio trimming completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Error during audio trimming" -ForegroundColor Red
        # Clean up temp files
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
        if (Test-Path $coverFile) { Remove-Item $coverFile -Force -ErrorAction SilentlyContinue }
    }
    
} catch {
    Write-Host "Error during trimming: $($_.Exception.Message)" -ForegroundColor Red
}
