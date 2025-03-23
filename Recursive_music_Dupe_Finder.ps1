# ------------------------------
# Script: Find and Move Duplicate Music Files
# ------------------------------

# Path to the directory where you want to search for duplicates
$targetPath = "N:\Old Music Library 200+gigs"

# Name of the subdirectory where duplicates will be moved
$duplicatesFolderName = 'Music_Duplicates'

# Combine the main path with the duplicates subfolder
$duplicatesPath = Join-Path $targetPath $duplicatesFolderName

# Create the duplicates folder if it does not already exist
if (-not (Test-Path $duplicatesPath)) {
    New-Item -ItemType Directory -Path $duplicatesPath | Out-Null
    Write-Host "Created folder for duplicates: $duplicatesPath"
}
else {
    Write-Host "Duplicates folder already exists: $duplicatesPath"
}

# Get all files in the target directory (recursively),
# excluding any file that already resides in the duplicates folder
$files = Get-ChildItem -Path $targetPath -File -Recurse |
    Where-Object { $_.FullName -notlike "$duplicatesPath*" }

# Create a hashtable to map: <MD5 hash> -> <OriginalFilePath>
$hashTable = @{}

foreach ($file in $files) {
    try {
        # Compute the MD5 hash of the current file
        $fileHash = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash

        # Check if we've already encountered a file with this hash
        if ($hashTable.ContainsKey($fileHash)) {

            # This file is a duplicate, move it to the duplicates folder
            $destinationPath = Join-Path $duplicatesPath $file.Name

            # If a file with the same name already exists in duplicates,
            # we append a counter to the filename to avoid overwriting
            $finalDestination = $destinationPath
            $count = 1
            while (Test-Path $finalDestination) {
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                $extension = [System.IO.Path]::GetExtension($file.Name)
                $finalDestination = Join-Path $duplicatesPath ("{0}_{1}{2}" -f $baseName, $count, $extension)
                $count++
            }

            Move-Item -Path $file.FullName -Destination $finalDestination
            Write-Host "Moved duplicate: $($file.FullName)  -->  $finalDestination"
        }
        else {
            # First time seeing a file with this hash. Store it in the hashtable.
            $hashTable[$fileHash] = $file.FullName
        }
    }
    catch {
        Write-Warning "Could not process file $($file.FullName): $_"
    }
}

Write-Host "Duplicate detection and move complete."
