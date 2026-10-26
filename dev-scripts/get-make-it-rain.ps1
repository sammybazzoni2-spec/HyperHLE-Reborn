# Download the Make It Rain IPA from the Internet Archive into touchHLE_apps\
# so it shows up in the app picker, then (optionally) launch it.
#
# The IPA is fetched on the machine that will run it; it is never committed to
# this repository or shipped inside HyperHLE builds. Only use it if you are
# entitled to.
#
# Usage (PowerShell, from the folder that contains touchHLE.exe):
#   .\get-make-it-rain.ps1            # download only
#   .\get-make-it-rain.ps1 -Run       # download, then start touchHLE.exe
param(
    [string]$Destination = 'touchHLE_apps',
    [string]$Exe = '.\touchHLE.exe',
    [switch]$Run
)
$ErrorActionPreference = 'Stop'

$name = 'Make It Rain-v2.3--iOS6.0-(Clutch-1.4.6).ipa'
$url = 'https://archive.org/download/legacy_ios_apps/6.x/Make%20It%20Rain-v2.3--iOS6.0-%28Clutch-1.4.6%29.ipa'

New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$path = Join-Path $Destination $name

function Test-Zip([string]$file) {
    if (-not (Test-Path -LiteralPath $file)) { return $false }
    $bytes = [System.IO.File]::ReadAllBytes($file) | Select-Object -First 2
    return ($bytes.Count -eq 2 -and $bytes[0] -eq 0x50 -and $bytes[1] -eq 0x4B)
}

if (Test-Zip $path) {
    Write-Host "Already downloaded: $path"
} else {
    Write-Host 'Downloading Make It Rain from the Internet Archive...'
    $tmp = "$path.part"
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
    if (-not (Test-Zip $tmp)) {
        Remove-Item -LiteralPath $tmp -Force
        throw 'The downloaded file is not a valid IPA (not a zip archive).'
    }
    Move-Item -LiteralPath $tmp -Destination $path -Force
    Write-Host "Saved: $path"
}

if ($Run) {
    & $Exe $path
}
