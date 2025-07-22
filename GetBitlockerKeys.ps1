Get-ADObject -SearchBase "CN=<deviceName>,OU=Windows 11 Endpoints,OU=Workstations,DC=pubdef,DC=arkgov,DC=net" -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -Properties msfve-recoverypassword

#my Computer name is J5RQK24
Get-ADObject -SearchBase "CN=J5RQK24,OU=Windows 11 Endpoints,OU=Workstations,DC=pubdef,DC=arkgov,DC=net" -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -Properties msfve-recoverypassword

