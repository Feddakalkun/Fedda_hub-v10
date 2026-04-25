# FEDDAKALKUN v10

Ny baseline for FEDDA v10 med ny frontend-design og en renere install/run/update-flyt for ComfyUI.

## Struktur

- `frontend/` - Vite/React UI
- `backend/` - lokal API for status og workflow-register
- `scripts/` - PowerShell-script for install, start, update og health checks
- `logs/` - runtime-logger
- `runtime/` - lokal installasjon av ComfyUI og tilhorende filer
- `backend/workflows/` - sted der du legger workflow JSON-filer

## Første milepæl

Denne baselinen setter opp:

- eget git-repo
- frontend skilt ut i egen mappe
- `install.bat` for basisinstall av frontend, backend og ComfyUI
- `run.bat` for a starte frontend, backend og ComfyUI
- `update.bat` for a oppdatere ComfyUI checkout
- health check mot `http://127.0.0.1:8188/system_stats`
- backend health/status pa `http://127.0.0.1:8000`

## Krav

- Windows
- Git
- Python 3.10+
- Node.js 18+
- npm

## Bruk

1. Kjor `install.bat`
2. Kjor `run.bat`
3. Aapne `http://127.0.0.1:3000`

## Neste steg

- bygge ut backend-API for workflow-kjoring og install/status
- node-manager for custom nodes
- repair/update-flyt for workflows og modeller
- knytte UI til install-logg og runtime-status
