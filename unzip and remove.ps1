
#Script for opening, unzipping, and deleting files in a directory
# Path to the directory containing your zip files
$zipFolderPath = "A:\Music\Samples and Packs\90s Sample CDs"   #"C:\Path\To\ZipFiles"

# Change to the directory
Set-Location -Path $zipFolderPath

# Get all .zip files in the directory
Get-ChildItem -Path $zipFolderPath -Filter *.zip | ForEach-Object {

    # Construct the destination path by removing the .zip extension
    # e.g., FileName.zip becomes a folder C:\Path\To\ZipFiles\FileName
    $destinationFolder = Join-Path $zipFolderPath ([System.IO.Path]::GetFileNameWithoutExtension($_.Name))

    # Expand-Archive will extract the zip file contents
    # -Force will overwrite any existing files in the destination
    Expand-Archive -Path $_.FullName -DestinationPath $destinationFolder -Force

    # If the extraction was successful, remove the .zip file
    Remove-Item $_.FullName
}
