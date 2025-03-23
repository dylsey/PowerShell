# Prompt the user for the directory path and the text to remove
$directoryPath = "A:\Music\Samples and Packs\Hainbach - Isolation Loops"

$removeText = "Hainbach - Isolation Loops (soundpack) - "

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
}