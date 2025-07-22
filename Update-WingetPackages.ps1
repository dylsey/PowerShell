<#
.SYNOPSIS
    Runs a fully-silent `winget upgrade --all` so you never see MSI pop-ups.

.DESCRIPTION
    • --accept-source-agreements / --accept-package-agreements suppress EULAs  
    • --disable-interactivity turns off *winget* prompts  
    • --silent forces installers that support quiet flags to run headlessly  
    • --include-unknown catches packages missing version metadata

    Output is logged to C:\Dev\PowerShell\Scripts\Logs\Winget-YYYY-MM-DD_HH-MM.log
#>

# Uncomment line below for simple one-liner
# winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements --disable-interactivity


#----------  Initial setup  ----------
$logDirectory = Join-Path $PSScriptRoot 'Logs'

# Test for log directory, create if missing
if (-not (Test-Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
}

$timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm'
$logFile = Join-Path $logDirectory "Winget-$timestamp.log"

#----------  Build Winget arguments  ----------
$wingetArguments = @(
    'upgrade'
    '--all'
    '--include-unknown'
    '--accept-source-agreements'
    '--accept-package-agreements'
    '--disable-interactivity'
    '--silent'
)

#----------  Execute and log  ----------
try {
    Start-Process -FilePath 'winget.exe' `
        -ArgumentList $wingetArguments `
        -NoNewWindow -Wait `
        -RedirectStandardOutput $logFile `
}
catch {
    Write-Error "Failed to run winget:"
}