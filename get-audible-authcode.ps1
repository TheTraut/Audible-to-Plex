# Script to help obtain Audible activation code
# Provides instructions and methods to get your Audible authcode

Write-Host "Audible Activation Code Helper" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

Write-Host "`nTo convert AAX files, you need your Audible activation code." -ForegroundColor Yellow
Write-Host "This is a unique code tied to your Audible account that allows decryption of your purchased books.`n" -ForegroundColor Yellow

Write-Host "Methods to obtain your activation code:" -ForegroundColor Cyan
Write-Host "`n1. EASIEST - Using Web Browser (Chrome/Firefox):" -ForegroundColor Green
Write-Host "   a) Go to https://audible.com and sign in" -ForegroundColor White
Write-Host "   b) Open Developer Tools (F12)" -ForegroundColor White
Write-Host "   c) Go to Application/Storage tab" -ForegroundColor White
Write-Host "   d) Look for 'adp-token' in Local Storage or Session Storage" -ForegroundColor White
Write-Host "   e) The activation code is part of this token" -ForegroundColor White

Write-Host "`n2. Using audible-cli (Python tool):" -ForegroundColor Green
Write-Host "   a) Install: pip install audible-cli" -ForegroundColor White
Write-Host "   b) Run: audible activation-bytes" -ForegroundColor White
Write-Host "   c) Follow the authentication prompts" -ForegroundColor White

Write-Host "`n3. Using audible-activator (Alternative tool):" -ForegroundColor Green
Write-Host "   a) Download from: https://github.com/inAudible-NG/audible-activator" -ForegroundColor White
Write-Host "   b) Run the tool and follow instructions" -ForegroundColor White

Write-Host "`n4. Check existing Audible software:" -ForegroundColor Green
Write-Host "   a) Look in Audible app settings/preferences" -ForegroundColor White
Write-Host "   b) May be stored in registry or config files" -ForegroundColor White

Write-Host "`nIMPORTANT NOTES:" -ForegroundColor Red
Write-Host "• The activation code is for YOUR books only" -ForegroundColor White
Write-Host "• Keep your activation code private and secure" -ForegroundColor White
Write-Host "• This is for personal backup/format conversion only" -ForegroundColor White
Write-Host "• Do not share DRM-free files publicly" -ForegroundColor White

Write-Host "`nOnce you have your activation code, save it securely for future use." -ForegroundColor Yellow

$saveCode = Read-Host "`nWould you like to save your activation code to a secure file? (y/n)"

if ($saveCode -eq 'y' -or $saveCode -eq 'Y') {
    $authCode = Read-Host "Enter your activation code (will be saved to authcode.txt)"
    
    if (![string]::IsNullOrEmpty($authCode)) {
        # Save to file with restricted permissions
        $authCode | Out-File -FilePath "authcode.txt" -Encoding UTF8
        
        # Try to set file permissions (Windows)
        try {
            $acl = Get-Acl "authcode.txt"
            $acl.SetAccessRuleProtection($true, $false)
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
            $acl.SetAccessRule($accessRule)
            Set-Acl "authcode.txt" $acl
            Write-Host "Activation code saved to authcode.txt (protected)" -ForegroundColor Green
        } catch {
            Write-Host "Activation code saved to authcode.txt" -ForegroundColor Green
            Write-Host "Note: Could not set file permissions. Keep this file secure!" -ForegroundColor Yellow
        }
    }
}

Write-Host "`nNext step: Run .\convert-audible-book.ps1 to convert your first book!" -ForegroundColor Cyan
