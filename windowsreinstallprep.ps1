# This PowerShell script collects information about installed programs, drivers, and system configuration
# and backs up user key configurations to a specified directory.
# Ensure the script is run with administrative privileges


# This script collects information about installed 32-bit programs on a Windows system via the registry
Get-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object { $_.DisplayName} |
    Sort-object DisplayName |
    Out-File -FilePath "C:\Dev\PSScripts\installedprograms.txt"

# Additionally, it collects information about installed 64-bit programs
# on the system and appends it to the same file.
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object { $_.DisplayName} |
    Sort-object DisplayName |
    Out-File -Append "C:\Dev\PSScripts\installedprograms.txt"

#Next, we will collect driver information 
Get-WmiObject Win32_PnPSignedDriver |
    Select-Object DeviceName, Manufacturer, DriverVersion, DriverDate, InfName |
    Sort-Object DeviceName |
    Export-Csv "C:\Dev\PSScripts\Driverslist.csv" -NoTypeInformation

#backup driver files
# This command exports all third-party drivers to the specified directory.
# Note: This will not include built-in Windows drivers.
mkdir C:\Dev\PSScripts\DriversBackup
pnputil /export-driver * C:\Dev\PSScripts\DriversBackup

# --- BEGIN SCRIPT ---

$driverRoot = "C:\Dev\PSScripts\DriversBackup"

# Find all INF files in all subfolders
$allInfs = Get-ChildItem -Path $driverRoot -Recurse -Filter *.inf

# Group by INF filename (case-insensitive)
$latestInfByName = $allInfs | Group-Object { $_.Name.ToLower() } | ForEach-Object {
    $_.Group | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

# Collect folders to KEEP (full path of latest driver for each INF)
$foldersToKeep = $latestInfByName | ForEach-Object { $_.DirectoryName } | Select-Object -Unique

# Collect ALL subfolders under DriversBackup (one per driver export)
$allDriverFolders = Get-ChildItem -Path $driverRoot -Directory

# Delete any driver folder not in foldersToKeep
$deletedCount = 0
foreach ($folder in $allDriverFolders) {
    if ($foldersToKeep -notcontains $folder.FullName) {
        try {
            Remove-Item -Path $folder.FullName -Recurse -Force
            Write-Host "Removed old driver folder: $($folder.FullName)"
            $deletedCount++
        } catch {
            Write-Warning "Could not remove $($folder.FullName): $_"
        }
    }
}

Write-Host "Driver deduplication complete. $deletedCount old driver folders removed."
Write-Host "Only the most recent driver versions for each INF remain in $driverRoot."

# --- END SCRIPT ---

# This script collects information about the system's hardware and software configuration
# not really necessary for reinstall prep, but can be useful for diagnostics 
# can be 
robocopy $env:USERPROFILE "E:\UserData_KeyConfigs\$env:USERNAME" /MIR /Z /XA:H /W:2 /R:2

# Ensure backup directory exists
if (-not (Test-Path -Path "C:\Dev\PSScripts")) { New-Item -Path "C:\Dev\PSScripts" -ItemType Directory }

# Backup PATH variables
[Environment]::GetEnvironmentVariable('PATH','Machine') | Out-File "C:\Dev\PSScripts\SystemPathBackup.txt"
[Environment]::GetEnvironmentVariable('PATH','User') | Out-File "C:\Dev\PSScripts\UserPathBackup.txt"

# Backup all env vars
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' |
    Select-Object Name, Value |
    Export-Csv "C:\Dev\PSScripts\SystemEnvVarsBackup.csv" -NoTypeInformation

Get-ChildItem 'HKCU:\Environment' |
    Select-Object Name, Value |
    Export-Csv "C:\Dev\PSScripts\UserEnvVarsBackup.csv" -NoTypeInformation


