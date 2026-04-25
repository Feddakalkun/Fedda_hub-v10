param(
    [Parameter(Mandatory = $true)]
    [string]$RepoRoot,
    [int]$Port = 8188
)

$ErrorActionPreference = "Stop"

$comfyDir = Join-Path $RepoRoot "runtime\ComfyUI"
$venvPython = Join-Path $comfyDir ".venv\Scripts\python.exe"
$logDir = Join-Path $RepoRoot "logs"
$logFile = Join-Path $logDir "comfyui-run.log"
$cacheDir = Join-Path $RepoRoot "cache"

if (-not (Test-Path $venvPython)) {
    throw "ComfyUI venv not found. Run install.bat first."
}

& $venvPython -c "import sys; print(sys.executable)" *> $null
if ($LASTEXITCODE -ne 0) {
    throw "ComfyUI venv Python is broken. Re-run install.bat after installing a usable Python (not only Windows Store alias)."
}

New-Item -ItemType Directory -Force -Path $logDir | Out-Null
New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
$env:HF_HOME = Join-Path $cacheDir "huggingface"
$env:TORCH_HOME = Join-Path $cacheDir "torch"
$env:PIP_CACHE_DIR = Join-Path $cacheDir "pip"
$env:PIP_DISABLE_PIP_VERSION_CHECK = "1"
$env:PYTHONNOUSERSITE = "1"
New-Item -ItemType Directory -Force -Path $env:HF_HOME, $env:TORCH_HOME, $env:PIP_CACHE_DIR | Out-Null

Push-Location $comfyDir
try {
    & $venvPython main.py --listen 127.0.0.1 --port $Port 2>&1 | Tee-Object -FilePath $logFile -Append
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
