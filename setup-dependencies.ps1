# Audible to Plex Setup Script
# This script downloads and sets up the required dependencies for converting Audible books

Write-Host "Setting up Audible to Plex conversion tools..." -ForegroundColor Green

# Create a tools directory
$toolsDir = ".\tools"
if (!(Test-Path $toolsDir)) {
    New-Item -ItemType Directory -Path $toolsDir
    Write-Host "Created tools directory" -ForegroundColor Yellow
}

# Download portable ffmpeg
Write-Host "Downloading portable ffmpeg..." -ForegroundColor Yellow
$ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
$ffmpegZip = ".\tools\ffmpeg.zip"

try {
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $ffmpegZip -UseBasicParsing
    Write-Host "FFmpeg downloaded successfully" -ForegroundColor Green
    
    # Extract ffmpeg
    Write-Host "Extracting ffmpeg..." -ForegroundColor Yellow
    Expand-Archive -Path $ffmpegZip -DestinationPath ".\tools\" -Force
    
    # Find the extracted folder and rename it
    $ffmpegFolder = Get-ChildItem ".\tools\" -Directory | Where-Object { $_.Name -like "ffmpeg-*" } | Select-Object -First 1
    if ($ffmpegFolder) {
        Rename-Item $ffmpegFolder.FullName ".\tools\ffmpeg"
        Write-Host "FFmpeg extracted to .\tools\ffmpeg" -ForegroundColor Green
    }
    
    # Clean up zip file
    Remove-Item $ffmpegZip -Force
    
} catch {
    Write-Host "Error downloading ffmpeg: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You can manually download ffmpeg from https://ffmpeg.org/download.html" -ForegroundColor Yellow
}

# Set up environment
Write-Host "Setting up environment..." -ForegroundColor Yellow
$env:PATH += ";$PWD\tools\ffmpeg\bin"

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "FFmpeg location: .\tools\ffmpeg\bin\" -ForegroundColor Cyan
Write-Host "You can now run the conversion scripts." -ForegroundColor Cyan
