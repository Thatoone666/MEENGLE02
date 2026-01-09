@echo off
REM Android Build Configuration Script for Windows

echo.
echo 🤖 Android Build Configuration
echo ==============================
echo.

REM Check Java
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Java not found. Please install JDK 11+
    pause
    exit /b 1
) else (
    echo ✅ Java found: 
    java -version
)

REM Check Android SDK
if not exist "%ANDROID_HOME%" (
    echo ❌ ANDROID_HOME not set
    echo Please set ANDROID_HOME environment variable
    pause
    exit /b 1
) else (
    echo ✅ Android SDK: %ANDROID_HOME%
)

REM Check Flutter
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter not found in PATH
    pause
    exit /b 1
) else (
    echo ✅ Flutter found
)

REM Clean and get dependencies
echo.
echo 📦 Getting dependencies...
call flutter pub get

REM Build APK
echo.
echo 🔨 Building release APK...
call flutter build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Build successful!
    echo.
    echo 📱 APK location:
    echo    build\app\outputs\apk\release\app-release.apk
    echo.
    echo 📦 AAB location (for Play Store):
    echo    build\app\outputs\bundle\release\app-release.aab
) else (
    echo.
    echo ❌ Build failed
    pause
    exit /b 1
)

pause
