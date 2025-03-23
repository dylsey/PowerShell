# Path to the directory where you want to search for duplicates
$targetPath = 'C:\Path\To\Folder'

# Name of the subdirectory for duplicates (you can change this)
$duplicatesFolderName = 'Duplicates'

# Full path to the new subfolder for duplicates
$duplicatesPath = Join-Path $targetPath $duplicatesFolderName

# Create the duplicates folder if it does not already exist
if (-not (Test-Path $duplicatesPath)) {
    New-Item -ItemType Directory -Path $duplicatesPath | Out-Null
    Write-Host "Created folder: $duplicatesPath"
} else {
    Write-Host "Duplicates folder already exists: $duplicatesPath"
}

# Get all files in the target directory (recursively),
# excluding anything in the duplicates folder
$files = Get-ChildItem -Path $targetPath -File -Recurse | Where-Object {
    $_.FullName -notlike "$duplicatesPath*"
}

# Create a hashtable to track files by their hash
$hashTable = @{}

foreach ($file in $files) {
    try {
        # Get the MD5 hash of the current file
        $fileHash = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash

        # Check if this hash is already in the hashtable
        if ($hashTable.ContainsKey($fileHash)) {
            # It's a duplicate of something we've already encountered
            # Move the file to the duplicates folder

            # Build a destination path
            # If there's a chance the file name already exists, you might want to handle conflicts
            # For example, you could append a timestamp or incrementing number
            $destinationPath = Join-Path $duplicatesPath $file.Name

            # If the destination file already exists, append a unique suffix
            $finalDestination = $destinationPath
            $count = 1
            while (Test-Path $finalDestination) {
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                $extension = [System.IO.Path]::GetExtension($file.Name)
                $finalDestination = Join-Path $duplicatesPath ("{0}_{1}{2}" -f $baseName, $count, $extension)
                $count++
            }

            Move-Item -Path $file.FullName -Destination $finalDestination
            Write-Host "Moved duplicate: $($file.FullName) --> $finalDestination"
        }
        else {
            # Not seen this hash yet, so store it
            $hashTable[$fileHash] = $file.FullName
        }
    }
    catch {
        Write-Warning "Could not process file $($file.FullName): $_"
    }
}