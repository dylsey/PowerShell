# This script is designed to run nmap and ipconfig commands and save the output to a text file on the desktop.
ipconfig /all > "$env:USERPROFILE\Desktop\ipconfig_dungeon_master.txt"

# Quick ping sweep – finds live hosts fast
nmap -sn 192.168.69.0/24 -oN $env:USERPROFILE\Desktop\nmap_ping_sweep.txt

# Service discovery – finds open ports and services 
nmap -A -T4 192.168.69.1 -oN $env:USERPROFILE\Desktop\gateway_scan.txt

# Phase 1 – ping/ARP discovery + MAC vendor
nmap -sn 192.168.69.0/24 -oN $env:USERPROFILE\Desktop\nmap_ping_sweep.txt

# Extract ONLY the IPv4 addresses from the ping-sweep file
Get-Content $env:USERPROFILE\Desktop\nmap_ping_sweep.txt |
    Select-String -Pattern '\b\d{1,3}(\.\d{1,3}){3}\b' -AllMatches |
    ForEach-Object {$_.Matches.Value} |
    Sort-Object -Unique |
    Set-Content $env:USERPROFILE\Desktop\live_hosts.txt

# Re-run the service scan
nmap --top-ports 20 -sV -iL $env:USERPROFILE\Desktop\live_hosts.txt `
     -oN $env:USERPROFILE\Desktop\nmap_hosts_top20.txt
