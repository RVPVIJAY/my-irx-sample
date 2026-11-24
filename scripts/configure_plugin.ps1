$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$pluginDir = if ($env:PLUGIN_DIR) { $env:PLUGIN_DIR } else { "C:\myplugin\conf" }

New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null
Copy-Item (Join-Path $root "config\plugin-config.yaml") $pluginDir -Force
Copy-Item (Join-Path $root "build\app.irx") $pluginDir -Force

# PLACEHOLDER: if your plug-in has an install/register command, call it here, e.g.
#   & "C:\Path\To\tool.exe" plugin install "$pluginDir\app.irx"

Write-Host "Plugin configured in $pluginDir"
