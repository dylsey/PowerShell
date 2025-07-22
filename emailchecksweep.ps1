$domain = "" #replace with your domain name
$selector = "" #replace with your DKIM selector

Write-Host "`n--- MX Record ---`n" -ForegroundColor Green
Resolve-DnsName -Name $domain -Type MX

Write-Host "`n--- SPF Record ---`n" -ForegroundColor Green
Reslove-DNSname -Name $domain -Type TXT | Where-Object {$_.Strings -match "v=spf1"} | Select-Object -ExpandProperty Strings

Write-Host "`n--- DKIM Record ---`n" -ForegroundColor Green
Resolve-DnsName -Name "$selector._domainkey.$domain" -Type TXT | Select-Object -ExpandProperty Strings

Write-Host "`n--- DMARC Record ---`n" -ForegroundColor Green
Resolve-DnsName -Name "_dmarc.$domain" -Type TXT | Select-Object -ExpandProperty Strings

Write-Host "`n--- CNAME Record ---`n" -ForegroundColor Green
Resolve-DnsName -Name "$selector._domainkey.$domain" -Type CNAME | Select-Object -ExpandProperty Strings

Write-Host "`n--- A Record ---`n" -ForegroundColor Green
Resolve-DnsName -Name $domain -Type A | Select-Object -ExpandProperty Strings

Write-Host "`n--- AAAA Record ---`n" -ForegroundColor Green
Resolve-DnsName -Name $domain -Type AAAA | Select-Object -ExpandProperty Strings

Write-Host "`n--- NS Record ---`n" -ForegroundColor Green
Resolve-DnsName -Name $domain -Type NS | Select-Object -ExpandProperty Strings

