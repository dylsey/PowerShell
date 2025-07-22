#Ping Sweep for CMD Shell
#for (/L %x in (1, 1, 225)) do ping -n 1 170.94.36.%x | find /i "reply" >> pingresults.txt

#Ping Sweep for PowerShell
for ($x = 1; $x -le 225; $x++){
     ping -n 1 "170.94.36.$x" | Select-String "reply"}