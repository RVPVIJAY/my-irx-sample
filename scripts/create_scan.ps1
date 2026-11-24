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
    return $out
}

$irx = Get-ChildItem (Join-Path $root $IrxDir) -Filter *.irx | Select-Object -First 1
if (-not $irx) { throw "No .irx found in $IrxDir" }

$loginArgs = @("api_login", "-u", $env:ASOC_KEY_ID, "-P", $env:ASOC_KEY_SECRET, "-acceptssl")
if ($env:APPSCAN_SERVER) { $loginArgs += @("-service_url", $env:APPSCAN_SERVER) }
$null = Invoke-AppScan $loginArgs

$queueOut = Invoke-AppScan @("queue_analysis", "-a", $env:APPSCAN_APP_ID, "-f", $irx.FullName, "-n", $ScanName, "-acceptssl")

# Read the SAST scan ID from the output
$m = [regex]::Match($queueOut, 'SAST scan ID:\s*([0-9a-fA-F\-]{36})')
if (-not $m.Success) { throw "Could not find the SAST scan ID in the queue_analysis output" }
$scanId = $m.Groups[1].Value
Write-Host "SAST scan ID captured: $scanId"

# Store it in the 'appscan-state' variable group for later runs
if (-not $env:SYSTEM_ACCESSTOKEN) {
    Write-Warning "SYSTEM_ACCESSTOKEN not available, scan ID was not stored. ID: $scanId"
} else {
    $project = [uri]::EscapeDataString($env:SYSTEM_TEAMPROJECT)
    $base = "$($env:SYSTEM_COLLECTIONURI)$project/_apis/distributedtask/variablegroups"
    $headers = @{ Authorization = "Bearer $($env:SYSTEM_ACCESSTOKEN)" }

    $res = Invoke-RestMethod -Uri "${base}?groupName=appscan-state&api-version=7.1" -Headers $headers
    if ($res.count -lt 1) { throw "Variable group 'appscan-state' not found" }
    $group = $res.value[0]
    $group.variables.APPSCAN_SCAN_ID.value = $scanId

    $body = $group | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Method Put -Uri "$base/$($group.id)?api-version=7.1" -Headers $headers -ContentType "application/json" -Body $body | Out-Null
    Write-Host "Stored APPSCAN_SCAN_ID in variable group 'appscan-state'"
}

Write-Host "Scan submitted: $ScanName"
