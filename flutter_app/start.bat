@echo off
REM Meengle Flutter App Startup Script for Windows

cd /d "%~dp0"
echo.
echo ==========================================
echo   MEENGLE FLUTTER APP
echo ==========================================
echo.
echo Building and launching Flutter app...
echo.
echo Make sure your Android emulator or iOS simulator is running
echo And the backend server is running on http://localhost:3001
echo.
echo ==========================================
echo.

flutter run

pause