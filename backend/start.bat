@echo off
REM Meengle Backend Startup Script for Windows

cd /d "%~dp0"
echo.
echo ==========================================
echo   MEENGLE BACKEND SERVER
echo ==========================================
echo.
echo Starting server on http://localhost:3001
echo Health check: http://localhost:3001/health
echo.
echo Press Ctrl+C to stop the server
echo.
echo ==========================================
echo.

npm start

pause