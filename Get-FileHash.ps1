# Description: This script calculates the hash of a specified file using a specified algorithm from a list of algorithms.

# Prompt the user to enter the file path
do {
    $filePath = Read-Host "Enter the full path of the file (e.g., C:\Users\UserName\Downloads\FileName11.0.iso)"
    if (!(Test-Path $filePath)) {
        Write-Host "Error: The specified file path '$filePath' does not exist. `nPlease try again." -ForegroundColor Red
    }
} while (!(Test-Path $filePath))

 #Define a list of valid algorithms for hashing
 $validAlgorithms = @("SHA1", "SHA256", "MD5", "BLAKE2")

# Prompt the user to enter the hashing algorithm
do { 
    Write-Host "Available algorithms: $($validAlgorithms -join ', ')"
    $userDefinedAlgorithm = Read-Host "Enter the hashing algorithm you want to use from the list above"
    if (-not ($validAlgorithms -contains $userDefinedAlgorithm)) {
        Write-Host "Error: '$userDefinedAlgorithm' is not a valid algorithm.\
        Please choose from the lst: $(validAlgorithms -join ', ')"
    }
} while(-not ($validAlgorithms -contains $userDefinedAlgorithm))

try {
    Write-Host "`nCalculating $algorithm has for file: $filePath`n"
    $hashResult = Get-FileHash -Path $filePath -Algorithm $userDefinedAlgorithm

    Write-Host "Path       : $($hashResult.Path)"
    Write-Host "Algorithm  : $($hashResult.Algorithm)"
    Write-Host "Hash       : $($hashResult.Hash)"
    
    Write-Host "`nCopy the hash above for analysis or further processing.`n"

}
catch {
    Write-Host "`nError: an error ocured while calculating the file hash:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
