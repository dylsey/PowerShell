# 1. Built-in uninstaller (silent)
winget uninstall --id Razer.Synapse --purge --accept-source-agreements

# 2. Kill lingering services
"Razer Synapse Service","Razer Central Service","RzChromaStreamServer" |
  ForEach-Object {
      if (Get-Service $_ -ErrorAction SilentlyContinue) {
          Stop-Service $_ -Force
          sc.exe delete $_
      }
  }

# 3. Delete scheduled tasks
schtasks /query /fo LIST | Select-String "Razer" | ForEach-Object {
    $tn = $_.Line -replace "TaskName:\s+",""
    schtasks /delete /tn $tn /f
}

# 4. Zap folders & registry hives
Remove-Item "$Env:ProgramFiles\Razer","$Env:ProgramFiles(x86)\Razer",
            "$Env:ProgramData\Razer","$Env:LOCALAPPDATA\Razer",
            "$Env:APPDATA\Razer" -Recurse -Force -ErrorAction SilentlyContinue

"HKLM:\SOFTWARE\Razer","HKLM:\SOFTWARE\WOW6432Node\Razer",
"HKCU:\SOFTWARE\Razer" | ForEach-Object {
    Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
}

# 5. remove drivers linked to razer/oem
pnputil /enum-drivers | Select-String -Pattern "Razer" |
    ForEach-Object {
        ($_ -split '\s+')[2]  # yields oem##.inf filename
    } | ForEach-Object {
        pnputil /delete-driver $_ /uninstall /force
    }

# 6. Remove trusted-publisher certs
Get-ChildItem Cert:\*\TrustedPublisher | Where-Object {
    $_.Subject -like "*Razer*"
} | Remove-Item

Get-NetFirewallRule -DisplayName "*Razer*" | Remove-NetFirewallRule

# 7 Reboot guest
Restart-Computer

###############################################################################
# Post Script Audit
###############################################################################

# Running processes
Get-Process | Where-Object { $_.Name -match 'Razer|Rz|Synapse' }

# Installed / running services
Get-Service | Where-Object { $_.Name -match 'Razer|Rz' }

#
schtasks /query /fo LIST | Select-String -Pattern 'Razer'

#
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'      |
    Select-Object -ExpandProperty * | Out-String
Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'      |
    Select-Object -ExpandProperty * | Out-String

#
Get-CimInstance -Namespace root\subscription -Class __EventFilter |
    Where-Object { $_.Name -like '*Razer*' }

# check drivers for leftovers
pnputil /enum-drivers | Select-String -Pattern 'Razer|Rz'

# check file system for leftovers
Get-ChildItem -Path "$Env:SystemDrive\" -Recurse -Depth 2 -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match 'Razer|Rz' }

# Global Registry sweep
Get-ChildItem -Path 'HKLM:\' -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.PSChildName -match 'Razer|Rz' } |
    Select-Object -First 20

# Check trusted publisher certs
Get-ChildItem Cert:\*\TrustedPublisher | Where-Object {
    $_.Subject -like '*Razer*'
}

#check firewall
Get-NetFirewallRule | Where-Object DisplayName -like '*Razer*'

<#@(  'PROCESS',  Get-Process | ?{$_.Name -match 'Razer|Rz'}
  ; 'SERVICE',   Get-Service | ?{$_.Name -match 'Razer|Rz'}
  ; 'TASK',      schtasks /query /fo TABLE | ?{$_ -match 'Razer'}
  ; 'DRIVER',    (pnputil /enum-drivers) | ?{$_ -match 'Razer'}
  ; 'FIREWALL',  Get-NetFirewallRule | ?{$_.DisplayName -match 'Razer'}
  ; 'CERT',      Get-ChildItem Cert:\*\TrustedPublisher | ?{$_.Subject -match 'Razer'}
) -join "`n" | Out-Host
#>

