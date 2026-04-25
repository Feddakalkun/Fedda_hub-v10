param(
    [Parameter(Mandatory = $true)]
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"

$comfyDir = Join-Path $RepoRoot "runtime\ComfyUI"
$venvPython = Join-Path $comfyDir ".venv\Scripts\python.exe"
$logDir = Join-Path $RepoRoot "logs"
$logFile = Join-Path $logDir "comfyui-update.log"
$cacheDir = Join-Path $RepoRoot "cache"
$downloadUrl = "https://github.com/comfyanonymous/ComfyUI/archive/refs/heads/master.zip"

New-Item -ItemType Directory -Force -Path $logDir, $cacheDir | Out-Null
$env:PIP_CACHE_DIR = Join-Path $cacheDir "pip"
$env:PIP_DISABLE_PIP_VERSION_CHECK = "1"
$env:PYTHONNOUSERSITE = "1"
$env:HF_HOME = Join-Path $cacheDir "huggingface"
$env:TORCH_HOME = Join-Path $cacheDir "torch"
New-Item -ItemType Directory -Force -Path $env:PIP_CACHE_DIR, $env:HF_HOME, $env:TORCH_HOME | Out-Null

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    $line | Tee-Object -FilePath $logFile -Append
}

if (-not (Test-Path (Join-Path $comfyDir "main.py"))) {
    throw "ComfyUI checkout not found"
}

if (-not (Test-Path $venvPython)) {
    throw "ComfyUI virtual environment not found"
}

& $venvPython -c "import sys; print(sys.executable)" *> $null
if ($LASTEXITCODE -ne 0) {
    throw "ComfyUI venv is broken. Re-run install.bat."
}

$tempDir = Join-Path (Join-Path $RepoRoot "runtime") ("_comfy_update_" + [guid]::NewGuid().ToString("N"))
$zipFile = Join-Path $tempDir "comfyui.zip"
$extractDir = Join-Path $tempDir "extract"
$sourceDir = Join-Path $extractDir "ComfyUI-master"
New-Item -ItemType Directory -Force -Path $tempDir, $extractDir | Out-Null

try {
    Write-Log "Downloading latest ComfyUI package"
    Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile $zipFile
    Write-Log "Extracting latest ComfyUI package"
    Expand-Archive -LiteralPath $zipFile -DestinationPath $extractDir -Force

    if (-not (Test-Path (Join-Path $sourceDir "main.py"))) {
        throw "ComfyUI package structure unexpected"
    }

    Write-Log "Syncing ComfyUI code (preserving local runtime folders)"
    $args = @(
        "`"$sourceDir`"",
        "`"$comfyDir`"",
        "/E",
        "/R:1",
        "/W:1",
        "/XD",
        ".git",
        ".venv",
        "models",
        "input",
        "output",
        "custom_nodes",
        "user",
        "logs"
    )
    & robocopy @args | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy sync failed"
    }

    Write-Log "Refreshing Python requirements"
    & $venvPython -m pip install --no-cache-dir -r (Join-Path $comfyDir "requirements.txt")
    if ($LASTEXITCODE -ne 0) {
        throw "requirements refresh failed"
    }
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item -LiteralPath $tempDir -Recurse -Force
    }
}

Write-Log "ComfyUI update completed"
