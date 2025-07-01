# PowerShell Network Discovery Script
$localSubnet = (Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.PrefixOrigin -eq "Dhcp"}).Prefix
$pingResults = @()

1..254 | ForEach-Object {
    $ip = "$($localSubnet.Split('/')[0].Substring(0, $localSubnet.Split('/')[0].LastIndexOf('.') + 1))$_"
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
        $hostname = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { "Unknown" }
        $mac = (Get-NetNeighbor -IPAddress $ip -ErrorAction SilentlyContinue).LinkLayerAddress
        $pingResults += [PSCustomObject]@{
            IPAddress = $ip
            Hostname  = $hostname
            MAC       = $mac
        }
    }
}

$pingResults | Format-Table -AutoSize

curl -s https://ifconfig.me


