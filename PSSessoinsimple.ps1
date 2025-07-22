
#interactive prompt to get the computer/client name
$clientComputerName = Read-Host -Prompt "Enter the client/computer name:"
Write-Host "You have entered: $clientComputerName"

#get user credentials for syslogin
Write-Host "Enter your credentials for remote session"
$userName = Read-Host -Prompt "UserName:"
$userPass = Read-Host -Prompt "Password:" -AsSecureString

#credential object creation
$accessCredential = New-Object System.Management.Automation.PSCredential ($userName, $userPass)
# Session w/ credential request
Enter-PSSession -ComputerName $clientComputerName -Credential $accessCredential
# Check if the session was established
try {
    Write-Host "Session established successfully with $clientComputerName"
} catch {
    Write-Host "Failed to establish session with $clientComputerName"
    Write-Host "Error: $_"
    exit
}
# Display the current IP address of the remote session
Write-Host "Fetching the current IP address of the remote session..."
curl -s https://ifconfig.me

