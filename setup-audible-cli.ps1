<#
  Audible CLI Setup Script (sanitized)
  - Configures audible-cli for authentication and metadata
  - Avoids emojis and nested quote issues for reliability
#>

param(
    [switch]$AutoYes = $false,
    [switch]$SkipQuickstart = $false
)

Write-Host 'Audible CLI Setup Wizard' -ForegroundColor Green
Write-Host '========================' -ForegroundColor Green

# Check if audible-cli is installed
try {
    $audibleVersion = & .\audible-cli-wrapper.ps1 --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $audibleVersion) {
        Write-Host ('Audible CLI is installed: ' + $audibleVersion) -ForegroundColor Green
    } else { throw }
} catch {
    Write-Host 'Audible CLI not found. Installing (user scope)...' -ForegroundColor Yellow
    try { pip install --user audible-cli } catch { Write-Host 'pip install failed. Please install Python/pip and re-run.' -ForegroundColor Red; exit 1 }
}

Write-Host ''
Write-Host 'This setup will:' -ForegroundColor Yellow
Write-Host '1. Configure audible-cli with your Audible account' -ForegroundColor White
Write-Host '2. Create a profile for automatic authentication' -ForegroundColor White
Write-Host '3. Set up activation code extraction' -ForegroundColor White
Write-Host '4. Enable enhanced metadata downloads' -ForegroundColor White

$proceed = 'n'
if ($AutoYes) {
    $proceed = 'y'
} else {
    $proceed = Read-Host 'Proceed with setup? (y/n)'
}

if ($proceed -eq 'y' -or $proceed -eq 'Y') {
    Write-Host ''
    Write-Host 'Starting audible-cli quickstart...' -ForegroundColor Yellow
    Write-Host 'You will need to:' -ForegroundColor Cyan
    Write-Host '- Enter your Audible email and password' -ForegroundColor White
    Write-Host '- Complete any 2FA if enabled' -ForegroundColor White
    Write-Host '- Choose your country marketplace' -ForegroundColor White
    
    if (-not $AutoYes) {
        Write-Host ''
        Write-Host 'Press Enter to continue...' -ForegroundColor Yellow
        Read-Host | Out-Null
    }
    
    # Run audible quickstart
    try {
        if (-not $SkipQuickstart) {
            & .\audible-cli-wrapper.ps1 quickstart
        }
        
        Write-Host ''
        Write-Host 'Audible CLI setup completed!' -ForegroundColor Green
        
        # Test the setup
        Write-Host ''
        Write-Host 'Testing setup...' -ForegroundColor Yellow
        $LASTEXITCODE = 0
        try { & .\audible-cli-wrapper.ps1 manage profile list 2>$null } catch { $LASTEXITCODE = 1 }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host 'Profile configuration successful' -ForegroundColor Green
            
            # Get activation bytes
            Write-Host ''
            Write-Host 'Extracting activation code...' -ForegroundColor Yellow
            $activationBytes = ''
            try { $activationBytes = & .\audible-cli-wrapper.ps1 activation-bytes 2>$null } catch { $activationBytes = '' }
            
            if (-not [string]::IsNullOrWhiteSpace($activationBytes)) {
                # Save activation code
                $activationBytes | Out-File -FilePath 'audible-activation-code.txt' -Encoding UTF8
                Write-Host 'Activation code saved to audible-activation-code.txt' -ForegroundColor Green
                
                Write-Host ''
                Write-Host 'Setup Complete!' -ForegroundColor Green
                Write-Host 'You can now use the enhanced conversion scripts.' -ForegroundColor Cyan
                
            } else {
                Write-Host 'Could not retrieve activation code automatically' -ForegroundColor Yellow
                Write-Host 'You may need to run "audible activation-bytes" manually later' -ForegroundColor White
            }
            
        } else {
            Write-Host 'Profile setup may have issues. Check audible-cli configuration.' -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host ('Error during setup: ' + $_.Exception.Message) -ForegroundColor Red
        Write-Host 'You can run "audible quickstart" manually if needed.' -ForegroundColor Yellow
    }
    
} else {
    Write-Host 'Setup cancelled. You can run this script again later.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Next Steps:' -ForegroundColor Cyan
Write-Host '1. Optionally run .\download-audible-books.ps1 to fetch books' -ForegroundColor White
Write-Host '2. Convert: .\convert-direct.ps1 -InputFile ".\YourBook.aax" [-TrimIntroOutro]' -ForegroundColor White
Write-Host '3. Split:   .\split-into-tracks.ps1 -InputFile ".\converted\YourBook.m4b"' -ForegroundColor White
