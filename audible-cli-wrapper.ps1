# Audible CLI Wrapper
# Provides easy access to audible-cli with proper path resolution

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Find audible.exe in common locations
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

$audiblePath = $null
foreach ($path in $audiblePaths) {
    if (Test-Path $path) {
        $audiblePath = $path
        break
    }
}

if ($audiblePath) {
    # Execute audible-cli with provided arguments
    & $audiblePath @Arguments
    return $LASTEXITCODE
} else {
    Write-Host "✗ Audible CLI not found. Please install with: pip install audible-cli" -ForegroundColor Red
    return 1
}
