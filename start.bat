@echo off
title FARM OF PHAM - Tactical Game Vault Server
color 0A
echo ========================================================
echo   KHOI DONG HE THONG FARM OF PHAM (TACTICAL GAME VAULT)
echo ========================================================
echo.
cd /d "%~dp0"

echo [1/2] Dang mo trinh duyet toi http://localhost:3000 ...
start http://localhost:3000

echo [2/2] Dang khoi dong Node.js Web Server...
echo.
echo Khi can tat server, ban chi can dong cua so nay.
echo ========================================================
echo.
node server.js
pause
