$QueryId = 'UAL00005'
$ServiceAccount = "gsheets-worker@automated-gsheets.iam.gserviceaccount.com"
$Scope = "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.file"
$CertPswd = "notasecret"
$SpreadSheetID = "11Pif_q8DOaTDQwlIK2FBq7stVxZJyHfca1igSZLfDTA"
$SpreadSheetTitle = "CSTEM Endpoint Status"
$SheetName = "Endpoint Status"
$certPath = "$PSSCRIPTROOT\automated-gsheets-6467ecc5c1bf.p12"
$SystemInfo = New-Object System.Collections.ArrayList
$Upload = @()
$Alphabet=@()
65..90|ForEach-Object{$Alphabet+=[char]$_}
Import-Module "C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1"
Get-PSDrive | Where-Object{$_.Provider.Name -eq 'CMSite'} | Set-Location -LiteralPath {"$($_.Name):\"}



Function Adjust-Data{

    [CmdletBinding()]
    param(
        [Parameter(Position=1)]
        $Data
    )

    if ($null -eq $Data){
        $Output = "Unknown"
    }
    elseif($Data -eq 1){
        $Output = "True"
    }
    elseif($Data -eq 0){
        $Output = "False"
    }
    else{
        $Output = $Data
    }

    return $Output
}


#Generate headers for spreadsheet#
$Upload = @($(Adjust-Data 'Computer Name'), $(Adjust-Data 'Operating System'), $(Adjust-Data 'Operating System Version'), $(Adjust-Data 'Manufacturer'), $(Adjust-Data 'Model'), $(Adjust-Data 'BIOS Version'),
           $(Adjust-Data 'Serial Number'), $(Adjust-Data 'Manufacture Date'), $(Adjust-Data 'TPM Specification'), $(Adjust-Data 'TPM Ready?'), $(Adjust-Data 'Bitlocker Enabled?'), $(Adjust-Data 'CPU Manufacturer'), 
            $(Adjust-Data 'CPU Cores'), $(Adjust-Data 'Logical Processors'), $(Adjust-Data 'Memory(KB)'))

#Add headers to arraylist#
$SystemInfo.add($Upload) | Out-Null

#Add information from CM query to hash table and then arraylist#
Invoke-CMQuery -id $QueryId | ForEach-Object{

    $Upload = @($(Adjust-Data $_.SMS_R_SYSTEM.Name), $(Adjust-Data $_.SMS_R_SYSTEM.operatingsystem), $(Adjust-Data $_.SMS_R_SYSTEM.operatingsystemversion), $(Adjust-Data $_.SMS_G_SYSTEM_COMPUTER_SYSTEM.Manufacturer), 
                $(Adjust-Data $_.SMS_G_SYSTEM_COMPUTER_SYSTEM.Model), $(Adjust-Data $_.SMS_G_SYSTEM_PC_BIOS.SMBIOSBIOSVersion), $(Adjust-Data $_.SMS_G_SYSTEM_SYSTEM_ENCLOSURE.SerialNumber),
                "$(Adjust-Data $_.SMS_G_SYSTEM_DELL_DCIM_CHASSIS_1_0.ManufactureDate)", $(Adjust-Data $_.SMS_G_SYSTEM_TPM.SpecVersion), $(Adjust-Data $_.SMS_G_SYSTEM_TPM_STATUS.IsReady), 
                $(Adjust-Data $_.SMS_G_SYSTEM_ENCRYPTABLE_VOLUME.ProtectionStatus), $(Adjust-Data $_.SMS_G_SYSTEM_PROCESSOR.Manufacturer), $(Adjust-Data $_.SMS_G_SYSTEM_PROCESSOR.NumberofCores), 
                $(Adjust-Data $_.SMS_G_SYSTEM_PROCESSOR.NumberofLogicalProcessors), $(Adjust-Data $_.SMS_G_SYSTEM_x86_PC_Memory.TotalPhysicalMemory))



    $SystemInfo.add($Upload) | Out-Null
}


#Get OAuth Token#
$accessToken = Get-GOAuthTokenService -scope $scope -certPath $certPath -certPswd $certPswd -iss $ServiceAccount

Set-GSheetData -accessToken $accessToken -sheetName $sheetName -spreadSheetID $spreadSheetID -rangeA1 "A1:$($alphabet[$($Upload.Length)])$($SystemInfo.Count)" -values $SystemInfo