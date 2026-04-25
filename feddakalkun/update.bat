@echo off
setlocal EnableExtensions
title FEDDAKALKUN v10 - Update

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "LOG_DIR=%ROOT%\logs"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>nul

echo.
echo  =========================================
echo    FEDDAKALKUN v10 ^| Update
echo  =========================================
echo.

if not exist "%ROOT%\runtime\ComfyUI\main.py" (
  echo  [ERROR] No ComfyUI checkout found.
  echo  Run install.bat first.
  pause
  exit /b 1
)

powershell -ExecutionPolicy Bypass -File "%ROOT%\scripts\update_comfyui.ps1" -RepoRoot "%ROOT%"
if errorlevel 1 (
  echo.
  echo  [ERROR] Update failed.
  pause
  exit /b 1
)

echo.
echo  [OK] Update completed.
pause
exit /b 0
