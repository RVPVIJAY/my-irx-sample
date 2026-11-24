param(
    [string]$IrxDir   = "irx-output",
    [string]$ScanName = "sample-app-build-$($env:BUILD_NUMBER)"
)
$ErrorActionPreference = "Stop"
$appscan = Join-Path $env:SACLIENT_HOME "bin\appscan.bat"
$root = Split-Path -Parent $PSScriptRoot

function Invoke-AppScan {
    param([string[]]$CmdArgs)
    $out = & $appscan @CmdArgs 2>&1 | Out-String
    Write-Host $out
    if ($LASTEXITCODE -ne 0 -or $out -match "Unrecognized option|expired|re-authenticate|Error|Failed|Unable") {
        throw "appscan $($CmdArgs[0]) failed"
    }
}

$irx = Get-ChildItem (Join-Path $root $IrxDir) -Filter *.irx | Select-Object -First 1
if (-not $irx) { throw "No .irx found in $IrxDir" }

$loginArgs = @("api_login", "-u", $env:ASOC_KEY_ID, "-P", $env:ASOC_KEY_SECRET, "-acceptssl")
if ($env:APPSCAN_SERVER) { $loginArgs += @("-service_url", $env:APPSCAN_SERVER) }
Invoke-AppScan $loginArgs

Invoke-AppScan @("queue_analysis", "-a", $env:APPSCAN_APP_ID, "-f", $irx.FullName, "-n", $ScanName, "-acceptssl")

Write-Host "Scan submitted: $ScanName"
