@echo off
REM ?? MEENGLE SIMPLE BUILD - WINDOWS
REM Builds all platforms sequentially

setlocal enabledelayedexpansion

cls
echo.
echo ====================================
echo ?? MEENGLE PRODUCTION BUILD
echo ====================================
echo.

cd flutter_app

echo [1/5] Cleaning...
flutter clean

echo.
echo [2/5] Getting dependencies...
flutter pub get

echo.
echo [3/5] Building Android APK...
flutter build apk --release --build-number=1 --build-name=1.0.0

echo.
echo [4/5] Building Android AAB...
flutter build appbundle --release --build-number=1 --build-name=1.0.0

echo.
echo [5/5] Building Web...
flutter build web --release --build-name=1.0.0

echo.
echo ====================================
echo ? BUILD COMPLETE!
echo ====================================
echo.
echo ?? APK: build\app\outputs\apk\release\app-release.apk
echo ?? AAB: build\app\outputs\bundle\release\app-release.aab
echo ?? Web: build\web\
echo.

pause
