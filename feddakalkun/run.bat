@echo off
setlocal EnableExtensions
title FEDDAKALKUN v10 - Run

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "LOG_DIR=%ROOT%\logs"
set "CACHE_DIR=%ROOT%\cache"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>nul
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%" >nul 2>nul
if not exist "%CACHE_DIR%\npm" mkdir "%CACHE_DIR%\npm" >nul 2>nul
if not exist "%CACHE_DIR%\huggingface" mkdir "%CACHE_DIR%\huggingface" >nul 2>nul
if not exist "%CACHE_DIR%\torch" mkdir "%CACHE_DIR%\torch" >nul 2>nul

set "npm_config_cache=%CACHE_DIR%\npm"
set "PIP_DISABLE_PIP_VERSION_CHECK=1"
set "PYTHONNOUSERSITE=1"
set "HF_HOME=%CACHE_DIR%\huggingface"
set "TORCH_HOME=%CACHE_DIR%\torch"

echo.
echo  =========================================
echo    FEDDAKALKUN v10 ^| Run
echo  =========================================
echo.

if not exist "%ROOT%\runtime\ComfyUI\main.py" (
  echo  [ERROR] ComfyUI is not installed yet.
  echo  Run install.bat first.
  pause
  exit /b 1
)

echo  [INFO] Starting ComfyUI...
start "FEDDA ComfyUI" powershell -ExecutionPolicy Bypass -File "%ROOT%\scripts\start_comfyui.ps1" -RepoRoot "%ROOT%"

echo  [INFO] Waiting for ComfyUI health check...
powershell -ExecutionPolicy Bypass -File "%ROOT%\scripts\healthcheck_comfyui.ps1" -Port 8188 -TimeoutSeconds 60
if errorlevel 1 (
  echo  [WARN] ComfyUI health check did not pass yet.
) else (
  echo  [OK] ComfyUI is responding on port 8188.
)

echo  [INFO] Starting backend on http://127.0.0.1:8000
start "FEDDA Backend" cmd /c "cd /d ""%ROOT%\backend"" && npm run dev"

echo  [INFO] Waiting for backend health check...
powershell -ExecutionPolicy Bypass -File "%ROOT%\scripts\healthcheck_backend.ps1" -Port 8000 -TimeoutSeconds 30
if errorlevel 1 (
  echo  [WARN] Backend health check did not pass yet.
) else (
  echo  [OK] Backend is responding on port 8000.
)

echo  [INFO] Starting frontend on http://127.0.0.1:3000
start "FEDDA Frontend" cmd /c "cd /d ""%ROOT%\frontend"" && npm run dev -- --host 127.0.0.1"

echo.
echo  Frontend: http://127.0.0.1:3000
echo  Backend : http://127.0.0.1:8000
echo  ComfyUI : http://127.0.0.1:8188
echo.
pause
exit /b 0
