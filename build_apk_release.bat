@echo off
title Build Wafra Client App APK Release
echo ========================================================
echo   Building Wafra Client Mobile App (Release APK)
echo ========================================================
echo.
cd /d "%~dp0"
call flutter build apk --release
echo.
echo ========================================================
echo   Build Complete! 
echo   APK File: build\app\outputs\flutter-apk\app-release.apk
echo ========================================================
pause
