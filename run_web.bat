@echo off
title Wafra Mobile App (Employee)
echo ========================================================
echo   Launching Wafra App (Employee Welfare & Discounts)
echo ========================================================
cd /d "%~dp0"
flutter run -d chrome --web-port 3000
pause
