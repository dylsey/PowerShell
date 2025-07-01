# Prompt the user for the directory path and the text to remove
$directoryPath = ""A:\Music\DT1 sounds\A""

#uncommment the next line to remove the text from the file names
#$removeText = "Hainbach - Isolation Loops (soundpack) - "
<#
Get-ChildItem -Path $directoryPath -Recurse -File | ForEach-Object {
    # Check if the file name contains the specified text
    if ($_.Name -like "*$removeText*") {
        # Remove the specified text portion from the file name by replacing it with an empty string
        $newName = $_.Name -replace [regex]::Escape($removeText), ""
        try {
            Rename-Item -Path $_.FullName -NewName $newName
            Write-Host "Renamed '$($_.Name)' to '$newName'"
        } catch {
            Write-Host "Error renaming '$($_.Name)': $_" -ForegroundColor Yellow
        }
    }
}#>


# Prompt the user for the directory path and the text to remove
$directoryPath = "A:\Music\DT1 sounds\H"
#uncomment the next line to remove the text from the file names
# Define the regex pattern to match the text at the beginning of the file name
$pattern = "^H(0[0-9]{2}|[1-9][0-9]{0,2})"

Get-ChildItem -Path $directoryPath -Recurse -File | ForEach-Object {
    # Check if the file name starts with the specified pattern
    if ($_.Name -match $pattern) {
        # Remove the matched portion from the beginning of the file name
        $newName = $_.Name -replace $pattern, ""
        try {
            Rename-Item -Path $_.FullName -NewName $newName
            Write-Host "Renamed '$($_.Name)' to '$newName'"
        } catch {
            Write-Host "Error renaming '$($_.Name)': $_" -ForegroundColor Yellow
        }
    }
}


