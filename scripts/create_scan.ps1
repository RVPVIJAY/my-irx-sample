param(
    [string]$IrxDir   = "irx-output",
    [string]$ScanName = "sample-app-build-$($env:BUILD_NUMBER)"
)
$ErrorActionPreference = "Stop"
$appscan = Join-Path $env:SACLIENT_HOME "bin\appscan.bat"
$root = Split-Path -Parent $PSScriptRoot

$irx = Get-ChildItem (Join-Path $root $IrxDir) -Filter *.irx | Select-Object -First 1
if (-not $irx) { throw "No .irx found in $IrxDir" }

$loginArgs = @("api_login", "-u", $env:ASOC_KEY_ID, "-P", $env:ASOC_KEY_SECRET, "-persist", "-acceptssl")
if ($env:APPSCAN_SERVER) { $loginArgs += @("-server", $env:APPSCAN_SERVER) }
& $appscan @loginArgs
if ($LASTEXITCODE -ne 0) { throw "appscan api_login failed ($LASTEXITCODE)" }

& $appscan queue_analysis -a $env:APPSCAN_APP_ID -f $irx.FullName -n $ScanName -acceptssl
if ($LASTEXITCODE -ne 0) { throw "appscan queue_analysis failed ($LASTEXITCODE)" }

Write-Host "Scan submitted: $ScanName"
