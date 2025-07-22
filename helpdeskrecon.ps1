
#remote into the client computer
Enter-PSSession -ComputerName "<client computer name>"

# check total memory and free memory 
Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory

# Show all running services with their working-set (RAM in MB), sorted high→low
Get-CimInstance Win32_Service |
    Where-Object  State -EQ 'Running' |
    ForEach-Object {
        $p = Get-Process -Id $_.ProcessId -ErrorAction SilentlyContinue
        [pscustomobject]@{
            ServiceName  = $_.Name
            DisplayName  = $_.DisplayName
            PID          = $_.ProcessId
            MemoryMB     = if ($p) { [math]::Round($p.WorkingSet64 / 1MB, 4) } else { $null }
        }
    } |
    Sort-Object MemoryMB -Descending |
    Format-Table -AutoSize

# Display the current IP address of the remote session
Write-Host "Fetching the current IP address of the remote session..."
curl -s https://ifconfig.me


    