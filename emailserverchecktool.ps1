# Prompt the user to enter the domain
$domain = Read-Host "Enter the domain to check (example: website.com)"
$selector = "selector1"  # Default selector, can be expanded later if needed

Write-Host "`n========== DNS RECORD CHECK FOR $domain ==========" -ForegroundColor Yellow

# MX Records
Write-Host "`n--- MX Records ---`n" -ForegroundColor Green
$mxRecords = Resolve-DnsName -Name $domain -Type MX -ErrorAction SilentlyContinue
if ($mxRecords) {
    $mxRecords | Where-Object {$_.NameExchange} | ForEach-Object {
        Write-Host ("{0,-45} Preference: {1}" -f $_.NameExchange, $_.Preference) -ForegroundColor White
    }
} else {
    Write-Host "No MX records found." -ForegroundColor Red -BackgroundColor Black
}

# A Record
Write-Host "`n--- A Record ---`n" -ForegroundColor Green
$aRecords = Resolve-DnsName -Name $domain -Type A -ErrorAction SilentlyContinue
if ($aRecords) {
    $aRecords | Where-Object {$_.IPAddress} | ForEach-Object {
        Write-Host $_.IPAddress -ForegroundColor White
    }
} else {
    Write-Host "No A record found." -ForegroundColor Red -BackgroundColor Black
}


# SPF Record
Write-Host "`n--- SPF Record ---`n" -ForegroundColor Green
$spfRecord = Resolve-DnsName -Name $domain -Type TXT -ErrorAction SilentlyContinue | Where-Object { $_.Strings -match "v=spf1" }
if ($spfRecord) {
    $spfRecord.Strings | ForEach-Object { Write-Host $_ -ForegroundColor White }
} else {
    Write-Host "No SPF record found." -ForegroundColor Red -BackgroundColor Black
}


# DMARC Record
Write-Host "`n--- DMARC Record ---`n" -ForegroundColor Green
$dmarcRecord = Resolve-DnsName -Name "_dmarc.$domain" -Type TXT -ErrorAction SilentlyContinue
if ($dmarcRecord) {
    $dmarcRecord.Strings | ForEach-Object { Write-Host $_ -ForegroundColor White }
} else {
    Write-Host "No DMARC record found." -ForegroundColor Red -BackgroundColor Black
}

# DKIM Record
Write-Host "`n--- DKIM Record (Selector: $selector) ---`n" -ForegroundColor Green
$dkimRecord = Resolve-DnsName -Name "$selector._domainkey.$domain" -Type TXT -ErrorAction SilentlyContinue
if ($dkimRecord) {
    $dkimRecord.Strings | ForEach-Object { Write-Host $_ -ForegroundColor White }
} else {
    Write-Host "No DKIM record found (or wrong selector)." -ForegroundColor Red -BackgroundColor Black
}

# AAAA Record (IPv6)
Write-Host "`n--- AAAA Record ---`n" -ForegroundColor Green
$aaaaRecords = Resolve-DnsName -Name $domain -Type AAAA -ErrorAction SilentlyContinue | Where-Object { $_.QueryType -eq "AAAA" }
if ($aaaaRecords) {
    $aaaaRecords | ForEach-Object { Write-Host $_.IP6Address -ForegroundColor White }
} else {
    Write-Host "No AAAA (IPv6) record found." -ForegroundColor DarkGray
}

# NS Records (Name Servers)
Write-Host "`n--- NS Records ---`n" -ForegroundColor Green
$nsRecords = Resolve-DnsName -Name $domain -Type NS -ErrorAction SilentlyContinue
if ($nsRecords) {
    $nsRecords | Where-Object {$_.NameHost} | ForEach-Object {
        Write-Host ("Name Server: {0}" -f $_.NameHost) -ForegroundColor White
    }
} else {
    Write-Host "No NS records found." -ForegroundColor Red -BackgroundColor Black
}
