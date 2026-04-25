param(
    [Parameter(Mandatory = $true)]
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"

$runtimeDir = Join-Path $RepoRoot "runtime"
$comfyDir = Join-Path $runtimeDir "ComfyUI"
$logDir = Join-Path $RepoRoot "logs"
$logFile = Join-Path $logDir "comfyui-install.log"
$cacheDir = Join-Path $RepoRoot "cache"
$downloadUrl = "https://github.com/comfyanonymous/ComfyUI/archive/refs/heads/master.zip"

New-Item -ItemType Directory -Force -Path $runtimeDir, $logDir, $cacheDir | Out-Null
$env:PIP_CACHE_DIR = Join-Path $cacheDir "pip"
$env:PIP_DISABLE_PIP_VERSION_CHECK = "1"
$env:PYTHONNOUSERSITE = "1"
$env:HF_HOME = Join-Path $cacheDir "huggingface"
$env:TORCH_HOME = Join-Path $cacheDir "torch"
New-Item -ItemType Directory -Force -Path $env:PIP_CACHE_DIR, $env:HF_HOME, $env:TORCH_HOME | Out-Null

function Get-UsablePythonCommand {
    $pythonCandidates = @()

    try {
        $pythonCandidates += @(where.exe python 2>$null)
    } catch {
    }

    $pythonCandidates = $pythonCandidates |
        Where-Object { $_ -and ($_ -notmatch "WindowsApps") } |
        Select-Object -Unique

    foreach ($candidate in $pythonCandidates) {
        & $candidate -c "import sys; print(sys.executable)" *> $null
        if ($LASTEXITCODE -eq 0) {
            return @($candidate)
        }
    }

    foreach ($launcher in @("py -3.13", "py -3.12", "py -3.11", "py -3.10", "py -3")) {
        & cmd.exe /c "$launcher -c ""import sys; print(sys.executable)""" *> $null
        if ($LASTEXITCODE -eq 0) {
            return @("cmd.exe", "/c", $launcher)
        }
    }

    throw "No usable Python 3.10+ installation found. Install Python from python.org, not only the Windows Store alias."
}

function Test-PythonExecutable {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return $false
    }

    & $Path -c "import sys; print(sys.executable)" *> $null
    return ($LASTEXITCODE -eq 0)
}

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    $line | Tee-Object -FilePath $logFile -Append
}

Write-Log "Starting ComfyUI install"

if (-not (Test-Path (Join-Path $comfyDir "main.py"))) {
    $tempDir = Join-Path $runtimeDir ("_comfy_download_" + [guid]::NewGuid().ToString("N"))
    $zipFile = Join-Path $tempDir "comfyui.zip"
    $extractDir = Join-Path $tempDir "extract"
    $sourceDir = Join-Path $extractDir "ComfyUI-master"

    New-Item -ItemType Directory -Force -Path $tempDir, $extractDir | Out-Null
    try {
        Write-Log "Downloading ComfyUI zip package"
        Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile $zipFile
        Write-Log "Extracting ComfyUI package"
        Expand-Archive -LiteralPath $zipFile -DestinationPath $extractDir -Force

        if (-not (Test-Path (Join-Path $sourceDir "main.py"))) {
            throw "ComfyUI package structure unexpected"
        }

        Write-Log "Installing ComfyUI files into $comfyDir"
        Move-Item -LiteralPath $sourceDir -Destination $comfyDir -Force
    }
    finally {
        if (Test-Path $tempDir) {
            Remove-Item -LiteralPath $tempDir -Recurse -Force
        }
    }
}
else {
    Write-Log "Existing ComfyUI checkout found, skipping source install"
}

$venvPython = Join-Path $comfyDir ".venv\Scripts\python.exe"
$venvDir = Join-Path $comfyDir ".venv"

if ((Test-Path $venvPython) -and (-not (Test-PythonExecutable -Path $venvPython))) {
    Write-Log "Existing virtual environment is broken, recreating it"
    Remove-Item -LiteralPath $venvDir -Recurse -Force
}

if (-not (Test-Path $venvPython)) {
    $pythonCommand = Get-UsablePythonCommand
    Write-Log "Creating virtual environment"
    if ($pythonCommand.Count -eq 1) {
        & $pythonCommand[0] -m venv $venvDir
    } else {
        & $pythonCommand[0] $pythonCommand[1] "$($pythonCommand[2]) -m venv ""$venvDir"""
    }

    if ($LASTEXITCODE -ne 0) {
        throw "venv creation failed"
    }
}

if (-not (Test-PythonExecutable -Path $venvPython)) {
    throw "Created virtual environment is not usable. Check Python installation outside Windows Store aliases."
}

Write-Log "Upgrading pip"
& $venvPython -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) {
    throw "pip upgrade failed"
}

Write-Log "Installing ComfyUI requirements"
& $venvPython -m pip install --no-cache-dir -r (Join-Path $comfyDir "requirements.txt")
if ($LASTEXITCODE -ne 0) {
    throw "requirements installation failed"
}

Write-Log "ComfyUI install completed"
