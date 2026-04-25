@echo off
setlocal EnableExtensions
title FEDDAKALKUN v10 - Repo Updater

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "APP_DIR=%ROOT%\feddakalkun"

echo.
echo  =========================================
echo    FEDDAKALKUN v10 ^| Repo Updater
echo  =========================================
echo.
echo    App source : %APP_DIR%
echo.

if not exist "%APP_DIR%\update.bat" (
  echo  [ERROR] Could not find:
  echo    %APP_DIR%\update.bat
  echo.
  pause
  exit /b 1
)

pushd "%APP_DIR%" || (
  echo  [ERROR] Could not enter feddakalkun source folder.
  pause
  exit /b 1
)

call update.bat
set "UPDATE_EXIT=%ERRORLEVEL%"
popd

exit /b %UPDATE_EXIT%
