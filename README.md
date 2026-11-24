# my-irx-sample

Sample repo: pull code on a Windows worker node, generate an IRX, configure the plug-in.

## Run manually on the worker node (PowerShell)
```powershell
git clone https://github.com/<you>/my-irx-sample.git
cd my-irx-sample
powershell -ExecutionPolicy Bypass -File scripts\generate_irx.ps1
powershell -ExecutionPolicy Bypass -File scripts\configure_plugin.ps1
```

## Run via Jenkins
Create a Pipeline job > "Pipeline script from SCM" > this repo. Set the agent label in `Jenkinsfile`.

Note: scripts contain PLACEHOLDER lines to replace with your tool's real IRX and plug-in commands.
