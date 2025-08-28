# Audible CLI Wrapper
# Mirrors behavior of macOS wrapper: resolves audible, injects password from env, and falls back to python -m audible_cli

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Inject password for encrypted auth files if provided via env var and not already set
if ($env:AUDIBLE_AUTH_PASSWORD) {
    $hasPasswordArg = $false
    foreach ($a in $Arguments) {
        if ($a -eq '-p' -or $a -eq '--password') { $hasPasswordArg = $true; break }
    }
    if (-not $hasPasswordArg) {
        $Arguments = @('-p', $env:AUDIBLE_AUTH_PASSWORD) + $Arguments
    }
}

# Try audible in PATH first
$audibleCmd = $null
try { $audibleCmd = Get-Command audible -ErrorAction Stop } catch { $audibleCmd = $null }
if ($audibleCmd -and $audibleCmd.Source) {
    & $audibleCmd.Source @Arguments
    exit $LASTEXITCODE
}

# Search common per-user install locations
$audiblePaths = @(
    "$env:APPDATA\Python\Python39\Scripts\audible.exe",
    "$env:APPDATA\Python\Python310\Scripts\audible.exe",
    "$env:APPDATA\Python\Python311\Scripts\audible.exe",
    "$env:APPDATA\Python\Python312\Scripts\audible.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python39\Scripts\audible.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python310\Scripts\audible.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python311\Scripts\audible.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python312\Scripts\audible.exe"
)

foreach ($path in $audiblePaths) {
    if (Test-Path $path) {
        & $path @Arguments
        exit $LASTEXITCODE
    }
}

# Fallback: python -m audible_cli
try {
    & python -m audible_cli @Arguments
    exit $LASTEXITCODE
} catch {
    # Try python3 if python failed
    try { & python3 -m audible_cli @Arguments; exit $LASTEXITCODE } catch {}
}

Write-Host "Audible CLI not found. Install with: pip install --user audible-cli" -ForegroundColor Red
exit 1

