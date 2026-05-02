# run_all.ps1
# Runs preprocessing and model notebooks in order and writes executed copies to ./executed
# Usage:
#   Activate your virtualenv first (PowerShell):
#     .venv\Scripts\Activate.ps1
#   Then run:
#     Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#     .\run_all.ps1

param(
    [int]$TimeoutSeconds = 3600
)

$ErrorActionPreference = 'Stop'

# Ensure script runs from repository root (where this file lives)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "Running notebooks from: $PWD"

if (-Not (Test-Path -Path "executed")) {
    Write-Host "Creating executed/ directory..."
    New-Item -ItemType Directory -Path "executed" | Out-Null
}

$notebooks = @(
    "00_common_preprocessing.ipynb",
    "01_linear_regression.ipynb",
    "02_decision_tree.ipynb",
    "03_random_forest.ipynb",
    "05_model_comparison.ipynb"
)

foreach ($nb in $notebooks) {
    $src = "notebooks/$nb"
    Write-Host "`n=== Executing: $src ==="
    try {
        jupyter nbconvert --to notebook --execute $src --output $nb --output-dir=executed --ExecutePreprocessor.timeout=$TimeoutSeconds
        Write-Host "Completed: $nb"
    } catch {
        $msg = "ERROR running {0}`n{1}" -f $nb, $_.Exception.Message
        Write-Host $msg -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nAll notebooks executed. Check the executed/ folder and models/ for outputs."
