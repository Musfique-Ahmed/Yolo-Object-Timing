# Setup virtual environment in a safe path and install requirements
# Usage: Open PowerShell as Administrator (if needed), then:
#   .\scripts\setup-env.ps1

# Configuration - change if you prefer a different venv path
$venvRoot = 'C:\venvs'
$venvName = 'yolo-obj-timing'
$projectReq = "${PSScriptRoot}\..\requirements.txt"  # relative to script location

# Ensure the venv root directory exists
if (-Not (Test-Path -Path $venvRoot)) {
    New-Item -ItemType Directory -Path $venvRoot -Force | Out-Null
}

$venvPath = Join-Path $venvRoot $venvName

Write-Host "Creating virtual environment at: $venvPath"
python -m venv $venvPath

Write-Host "Activating virtual environment"
# Activate by dot-sourcing the activation script in the current shell
$activateScript = Join-Path $venvPath 'Scripts\Activate.ps1'
if (-Not (Test-Path -Path $activateScript)) {
    Write-Error "Activation script not found at $activateScript"
    exit 1
}

# ExecutionPolicy note: if script fails to run, run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
. $activateScript

Write-Host "Upgrading pip, setuptools, wheel"
python -m pip install --upgrade pip setuptools wheel

Write-Host "Installing requirements (prefer-binary to use wheels when available)"
# Use prefer-binary to prefer wheels over source builds where possible
pip install --prefer-binary -r $projectReq

Write-Host "Done. To reactivate later run:`n`$env:venvPath = '$venvPath'`n& '$venvPath\Scripts\Activate.ps1'"
