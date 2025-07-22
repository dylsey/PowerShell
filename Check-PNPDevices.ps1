<#
.SYNOPSIS
Fixes devices with issues by removing and re-detecting them.

.DESCRIPTION
This script identifies PNP devices with errors and tries to fix them by removing the problematic devices and forcing the system to re-detect them. 
It uses customizable filters for device classes and IDs, logs the process, and outputs the results.

.PARAMETER ClassFilterExclude
List of device classes to exclude. Defaults to an empty string, meaning no exclusions.

.PARAMETER ClassFilterInclude
List of device classes to include. Defaults to "*", meaning all classes are included.

.PARAMETER DeviceIDFilterExclude
List of device IDs to exclude. Defaults to an empty string, meaning no exclusions.

.PARAMETER DeviceIDFilterInclude
List of device IDs to include. Defaults to "*", meaning all IDs are included.

.NOTES
- Requires `pnputil.exe` to work, which needs to be available in the system PATH.
- Run this script with administrative privileges for it to function properly.

.EXAMPLE
.\Check-PNPDevicesRemediation.ps1
Runs the script with default filters to fix all PNP devices with issues.

#>

# Initialize device filters
$ClassFilterExclude = ""
$ClassFilterInclude = "*"
$DeviceIDFilterExclude = ""
$DeviceIDFilterInclude = "*"

# Check for pnputil.exe availability
if (-not (Get-Command pnputil.exe -ErrorAction SilentlyContinue)) {
    Write-Error "pnputil.exe is missing. Make sure it's in your PATH."
    exit 1
}

# Find devices with issues
[array]$DevicesWithIssue = Get-PnpDevice -PresentOnly -Status ERROR -ErrorAction SilentlyContinue |
Where-Object PNPClass -notin $ClassFilterExclude |
Where-Object { if ("*" -in $ClassFilterInclude) { $_ } elseif ($_.PNPClass -in $ClassFilterInclude) { $_ } } |
Where-Object PNPDeviceID -notin $DeviceIDFilterExclude |
Where-Object { if ("*" -in $DeviceIDFilterInclude) { $_ } elseif ($_.PNPDeviceID -in $DeviceIDFilterInclude) { $_ } }

# Initialize logging
$Output = ""
$PnpUtilOut = ""

if ($DevicesWithIssue.Count -gt 0) {
    foreach ($Device in $DevicesWithIssue) {
        $FriendlyName = if ([string]::IsNullOrWhiteSpace($Device.FriendlyName)) { "N/A" } else { $Device.FriendlyName }
        $PNPClass = if ([string]::IsNullOrWhiteSpace($Device.PNPClass)) { "N/A" } else { $Device.PNPClass }

        # Log the device being processed
        Write-Verbose "Processing Device: $FriendlyName (Class: $PNPClass, ID: $($Device.PNPDeviceID))"

        # Try to remove the device
        try {
            $PnpUtilOut += (pnputil.exe /remove-device "$($Device.PNPDeviceID)") | Out-String
        }
        catch {
            Write-Warning "Failed to remove device: $FriendlyName (ID: $($Device.PNPDeviceID)). Error: $_"
            continue
        }

        # Try to re-detect devices
        try {
            Write-Verbose "Re-detecting devices"
            $PnpUtilOut += (pnputil.exe /scan-devices) | Out-String
            $Output += " | Re-detected Device: $FriendlyName (Class: $PNPClass, ID: $($Device.PNPDeviceID))"
        }
        catch {
            Write-Warning "Re-detection failed for device: $FriendlyName (ID: $($Device.PNPDeviceID)). Error: $_"
        }
    }

    # Display the final results
    Write-Host $Output.TrimStart(" |")
}
else {
    Write-Host "No problematic devices found."
}