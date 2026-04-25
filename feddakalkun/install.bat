@echo off
setlocal EnableExtensions
title FEDDAKALKUN v10 - Install

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "LOG_DIR=%ROOT%\logs"
set "LOG_FILE=%LOG_DIR%\install.log"
set "CACHE_DIR=%ROOT%\cache"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>nul
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%" >nul 2>nul
if not exist "%CACHE_DIR%\npm" mkdir "%CACHE_DIR%\npm" >nul 2>nul
if not exist "%CACHE_DIR%\pip" mkdir "%CACHE_DIR%\pip" >nul 2>nul
if not exist "%CACHE_DIR%\huggingface" mkdir "%CACHE_DIR%\huggingface" >nul 2>nul
if not exist "%CACHE_DIR%\torch" mkdir "%CACHE_DIR%\torch" >nul 2>nul

set "npm_config_cache=%CACHE_DIR%\npm"
set "PIP_CACHE_DIR=%CACHE_DIR%\pip"
set "PIP_DISABLE_PIP_VERSION_CHECK=1"
set "PYTHONNOUSERSITE=1"
set "HF_HOME=%CACHE_DIR%\huggingface"
set "TORCH_HOME=%CACHE_DIR%\torch"

echo [%date% %time%] install start > "%LOG_FILE%"
echo.
echo  =========================================
echo    FEDDAKALKUN v10 ^| Install
echo  =========================================
echo.
echo    Root: %ROOT%
echo.

where python >nul 2>nul || goto :err_python
where node >nul 2>nul || goto :err_node
where npm >nul 2>nul || goto :err_npm

echo  [OK] Tool checks passed.
echo [%date% %time%] tool checks passed >> "%LOG_FILE%"

echo  [INFO] Installing frontend dependencies...
pushd "%ROOT%\frontend" || goto :err_install
call npm install --no-fund --no-audit
if errorlevel 1 (
  popd
  goto :err_install
)
popd

echo  [INFO] Installing backend dependencies...
pushd "%ROOT%\backend" || goto :err_install
call npm install --no-fund --no-audit
if errorlevel 1 (
  popd
  goto :err_install
)
popd

powershell -ExecutionPolicy Bypass -File "%ROOT%\scripts\install_comfyui.ps1" -RepoRoot "%ROOT%"
if errorlevel 1 goto :err_install

echo.
echo  [OK] Install completed.
echo  Next step: run.bat
echo [%date% %time%] install success >> "%LOG_FILE%"
pause
exit /b 0

:err_python
echo.
echo  [ERROR] Python not found.
pause
exit /b 1

:err_node
echo.
echo  [ERROR] Node.js not found.
pause
exit /b 1

:err_npm
echo.
echo  [ERROR] npm not found.
pause
exit /b 1

:err_install
echo.
echo  [ERROR] Install failed. Check logs\install.log
echo [%date% %time%] install failed >> "%LOG_FILE%"
pause
exit /b 1
