$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$out = Join-Path $root "build"
New-Item -ItemType Directory -Force -Path $out | Out-Null

$zip = Join-Path $out "app.zip"
$irx = Join-Path $out "app.irx"
Remove-Item $zip, $irx -ErrorAction SilentlyContinue

# PLACEHOLDER: replace the next 2 lines with your product's real IRX export command, e.g.
#   & "C:\Path\To\tool.exe" export --project . --format irx --output build\app.irx
Compress-Archive -Path "src","config" -DestinationPath $zip
Rename-Item $zip "app.irx"

Write-Host "Generated: $irx"
