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
# Check for a C compiler (cl.exe) which is required for building some packages on Windows
function Test-HasCompiler {
    $cl = Get-Command cl -ErrorAction SilentlyContinue
    if ($null -ne $cl) { return $true }
    return $false
}

if (-not (Test-HasCompiler)) {
    Write-Host "Note: No MSVC compiler detected (cl.exe). Some packages like matplotlib may need build tools to compile from source."
    Write-Host "If installation fails, consider installing the 'Build Tools for Visual Studio' or using Conda/Miniconda to install binary packages."
}

# Use prefer-binary to prefer wheels over source builds where possible
try {
    pip install --prefer-binary -r $projectReq
} catch {
    Write-Host "\nERROR: pip failed to install one or more packages."
    Write-Host "Common culprits on Windows are packages that require a C compiler (e.g. matplotlib)."
    Write-Host "Options:\n  1) Install Visual C++ Build Tools (https://visualstudio.microsoft.com/downloads/)\n  2) Use Miniconda/Conda and run: conda create -n yolo python=3.12; conda activate yolo; conda install -c conda-forge matplotlib; pip install -r $projectReq (after removing matplotlib from requirements)\n  3) Move your environment to a path without special characters (the script already does this)\n"
    throw $_
}

Write-Host "Done. To reactivate later run:`n`$env:venvPath = '$venvPath'`n& '$venvPath\Scripts\Activate.ps1'"
