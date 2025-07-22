 Enter-PSSession -ComputerName "J5RQK24"

 #ComputerName: J5RQK24
#Description: This script initiates a PowerShell session to a remote computer using the specified credentials

Enter-PSSession -ComputerName "J5RQK24" -Credential (Get-Credential PUBDEF\dyelenich0923)


Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory

$host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size 300, 9999


Get-Process | Select-Object Name, Id, CPU, WS, VM | Sort-Object CPU -Descending | Format-Table -AutoSize
Get-Process | Select-Object Name, Id, CPU, WS, VM | Sort-Object WS -Descending | Format-Table -AutoSize
Get-Process | Select-Object Name, Id, CPU, WS, VM | Sort-Object VM -Descending | Format-Table -AutoSize
Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object DisplayName, Name, Status | Format-Table -AutoSize

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

