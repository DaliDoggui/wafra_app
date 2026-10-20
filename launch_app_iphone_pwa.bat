@echo off
title Wafra Client App - iPhone Safari & PWA Launcher
echo ========================================================
echo   WAFRA CLIENT APP - IPHONE PWA & WEB CLOUD LAUNCHER
echo ========================================================
echo.
cd /d "%~dp0"

echo [1/2] Serving Wafra Client App on port 4000...
start "Wafra App Web Server" cmd /k "python -m http.server 4000 --directory build\web"

timeout /t 2 /nobreak >nul

echo [2/2] Generating Free Global HTTPS URL for iPhone Safari...
echo.
echo ======================================================================
echo  1. On the same Wi-Fi, you can open directly on iPhone Safari:
echo     http://192.168.0.124:4000
echo.
echo  2. Or use the Global Cloudflare HTTPS Link generated below!
echo.
echo  3. HOW TO INSTALL ON IPHONE:
echo     - In Safari, tap Share icon (Square with arrow up)
echo     - Tap 'Add to Home Screen' (Sur l'ecran d'accueil)
echo     - The Wafra icon will appear on your iPhone home screen!
echo ======================================================================
echo.
..\wafra_backend\cloudflared.exe tunnel --url http://127.0.0.1:4000
pause
