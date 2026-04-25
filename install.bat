@echo off
setlocal EnableExtensions
title FEDDAKALKUN v10 - Repo Installer

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "APP_DIR=%ROOT%\feddakalkun"

echo.
echo  =========================================
echo    FEDDAKALKUN v10 ^| Repo Installer
echo  =========================================
echo.
echo    App source : %APP_DIR%
echo.

if not exist "%APP_DIR%\install.bat" (
  echo  [ERROR] Could not find:
  echo    %APP_DIR%\install.bat
  echo.
  pause
  exit /b 1
)

pushd "%APP_DIR%" || (
  echo  [ERROR] Could not enter feddakalkun source folder.
  pause
  exit /b 1
)

call install.bat
set "INSTALL_EXIT=%ERRORLEVEL%"
popd

exit /b %INSTALL_EXIT%
