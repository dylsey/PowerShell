
ffprobe -v quiet `
-show_streams `
Event20230929060033001.wav | ForEach-Object {
    if ($_ -like "*codec_name=*") 
    {
        $audio_codec = $_.Split('=')[1].Trim()
        Write-Host "Audio Codec: $($audio_codec)"
    }
}

#########
#extract raw audio data
#########

ffmpeg -i Event20230929060033001.wav -f s16le -acodec pcm_s16le Event20230929060033001.wav.raw

# Prompt the user for the filename
$filename = Read-Host "Enter the file name (e.g. Event20230929060033001.wav)"

#Get the full path using the current directory
$path = Join-Path (Get-Location) $filename

if (Test-Path $path) 
{
    $bytes = New-Object byte[] 8 # Allocates an 8-byte array
    $hex = ""

    #open the file in read mode and read the first 8 bytes
    $fs = [System.IO.File]::Open($path, 'Open', 'Read') 
    $fs.Read($bytes, 0, 8) | Out-Null
    $fs.Close() 

    #convert the bytes to hex string
    $hex = ($bytes | ForEach-Object { $_.ToString("X2") }) -join ''
    Write-Output "File Signature: $hex"
}

#Dictionary of file signatures 
$knownSignatures = @{
    "52494646" = "RIFF"
    "57415645" = "WAVE"
    "664C6143" = "flac"
    "4D546864" = "MThd"
    "FFD8FFDB" = "JPEG"
    "FFD8FFE0" = "JPEG"
    "FFD8FFE1" = "JPEG"
    "89504E47" = "PNG"
    "47494638" = "GIF"
    "00000100" = "ICO"
    "00000200" = "CUR"}
    


