
#winget registration via microsoft 
#must be logged in as a user
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

#if the above fails, try this:
Install-PackageProvider -Name "NuGet" -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Script winget-install -Force

#install find and install powershell
winget search Microsoft.PowerShell
winget install --id Microsoft.PowerShell --source winget

#installs editor for terminal
winget install Microsoft.Edit

#run a winget sweep for any updates
winget upgrade --all --include-unknown --force --accept-source-agreements


install-module -Name Microsoft.Winget.Client
import-module -Name Microsoft.Winget.Client
Get-WingetPackage -verbose | Where-Object { $_.IsUpdateAvailable } | select-object Id | Update-WinGetPackage

