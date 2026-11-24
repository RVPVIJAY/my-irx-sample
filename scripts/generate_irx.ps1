param(
    [string]$ScanDir  = "target",
    [string]$OutDir   = "irx-output",
    [string]$IrxName  = "sample-app"
)
$ErrorActionPreference = "Stop"
$appscan = Join-Path $env:SACLIENT_HOME "bin\appscan.bat"
if (-not (Test-Path $appscan)) { throw "appscan.bat not found. Set SACLIENT_HOME to your SAClientUtil folder." }

$root = Split-Path -Parent $PSScriptRoot
$scanPath = Join-Path $root $ScanDir
if (-not (Test-Path $scanPath)) { throw "Maven output '$scanPath' not found. Run the Maven build first." }

New-Item -ItemType Directory -Force -Path (Join-Path $root $OutDir) | Out-Null

Push-Location $scanPath
try {
    & $appscan prepare -n $IrxName -d (Join-Path $root $OutDir)
    if ($LASTEXITCODE -ne 0) { throw "appscan prepare failed ($LASTEXITCODE)" }
} finally { Pop-Location }

Get-ChildItem (Join-Path $root $OutDir) -Filter *.irx
