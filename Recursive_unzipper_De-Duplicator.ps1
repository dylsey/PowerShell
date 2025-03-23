# Prompt the user for the directory path and the text to remove
$directoryPath = Read-Host "Enter the directory path to search within"
$removeText = Read-Host "Enter the text portion to remove from file names"

# Validate if the directory exists
if (-Not (Test-Path -Path $directoryPath)) {
    Write-Host "The directory path '$directoryPath' does not exist." -ForegroundColor Red
    exit
}

# Get all files recursively within the specified directory
Get-ChildItem -Path $directoryPath -Recurse -File | ForEach-Object {
    # Check if the file name contains the text to remove
    if ($_.Name -like "*$removeText*") {
        # Remove the specified text portion from the file name
        $newName = $_.Name -replace [regex]::Escape($removeText), ""
        # Create the full path for the new file name
        $newFullPath = Join-Path -Path $_.DirectoryName -ChildPath $newName

        # Rename the file
        try {
            Rename-Item -Path $_.FullName -NewName $newName
            Write-Host "Renamed '$($_.Name)' to '$newName'"
        } catch {
            Write-Host "Failed to rename '$($_.Name)': $_" -ForegroundColor Yellow
        }
    }
}
