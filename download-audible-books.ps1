# Download Audible Books with Enhanced Metadata
# Uses audible-cli to download books with covers and chapter information

param(
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = ".\downloaded",
    
    [Parameter(Mandatory=$false)]
    [switch]$DownloadAll = $false,
    
    [Parameter(Mandatory=$false)]
    [string]$ASIN = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Format = "aax",  # aax or aaxc
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeChapters = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeCover = $true,
    
    [Parameter(Mandatory=$false)]
    [int]$CoverSize = 1215
)

Write-Host "Audible Book Downloader" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green

# Check if audible-cli is configured
try {
    $profiles = & .\audible-cli-wrapper.ps1 manage profile list 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Audible CLI not configured. Run .\setup-audible-cli.ps1 first." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Audible CLI not found. Run .\setup-audible-cli.ps1 first." -ForegroundColor Red
    exit 1
}

# Create output directory
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force
    Write-Host "Created download directory: $OutputDir" -ForegroundColor Yellow
}

# Build download command arguments
$downloadArgs = @("download")

if ($DownloadAll) {
    Write-Host "Downloading all books from your library..." -ForegroundColor Yellow
    $downloadArgs += "--all"
} elseif (![string]::IsNullOrEmpty($ASIN)) {
    Write-Host "Downloading book with ASIN: $ASIN" -ForegroundColor Yellow
    $downloadArgs += "--asin", $ASIN
} else {
    Write-Host "Please specify --DownloadAll or provide an --ASIN" -ForegroundColor Red
    Write-Host "To find ASIN numbers, run: audible library list" -ForegroundColor Yellow
    exit 1
}

# Add format preference
if ($Format -eq "aaxc") {
    $downloadArgs += "--aaxc"
    Write-Host "Format: AAXC (newer format)" -ForegroundColor Cyan
} else {
    Write-Host "Format: AAX (standard format)" -ForegroundColor Cyan
}

# Add enhanced metadata options
if ($IncludeCover) {
    $downloadArgs += "--cover", "--cover-size", $CoverSize
    Write-Host "Including high-quality cover art ($CoverSize px)" -ForegroundColor Cyan
}

if ($IncludeChapters) {
    $downloadArgs += "--chapter"
    Write-Host "Including detailed chapter information" -ForegroundColor Cyan
}

# Add output directory
$downloadArgs += "--output-dir", $OutputDir

Write-Host "`nStarting download..." -ForegroundColor Green
Write-Host "Command: audible $($downloadArgs -join ' ')" -ForegroundColor Gray

try {
    & .\audible-cli-wrapper.ps1 @downloadArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ Download completed successfully!" -ForegroundColor Green
        
        # List downloaded files
        $downloadedFiles = Get-ChildItem $OutputDir -Recurse -Include "*.aax", "*.aaxc"
        
        if ($downloadedFiles.Count -gt 0) {
            Write-Host "`nDownloaded books:" -ForegroundColor Cyan
            foreach ($file in $downloadedFiles) {
                Write-Host "  📚 $($file.Name)" -ForegroundColor White
                
                # Check for associated metadata files
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                $directory = $file.Directory.FullName
                
                $coverFile = Join-Path $directory "$baseName.jpg"
                $chapterFile = Join-Path $directory "$baseName.json"
                $voucherFile = Join-Path $directory "$baseName.voucher"
                
                if (Test-Path $coverFile) {
                    Write-Host "    🖼️ Cover art included" -ForegroundColor Green
                }
                if (Test-Path $chapterFile) {
                    Write-Host "    📖 Chapter data included" -ForegroundColor Green
                }
                if (Test-Path $voucherFile) {
                    Write-Host "    🎫 Voucher file included (for AAXC)" -ForegroundColor Green
                }
            }
            
            Write-Host "`nNext steps:" -ForegroundColor Yellow
            Write-Host "1. Run .\convert-with-audible-cli.ps1 to convert with enhanced metadata" -ForegroundColor White
            Write-Host "2. Or use .\batch-convert-enhanced.ps1 for automatic processing" -ForegroundColor White
            
        } else {
            Write-Host "⚠ No audio files found in download directory" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "✗ Download failed. Check your internet connection and account status." -ForegroundColor Red
    }
    
} catch {
    Write-Host "✗ Error during download: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTip: Use '.\audible-cli-wrapper.ps1 library list' to see all available books and their ASINs" -ForegroundColor Cyan
