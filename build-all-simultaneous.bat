@echo off
REM ?? SIMULTANEOUS BUILD - APK, AAB, iOS, WEB
REM Executes all builds in parallel

setlocal enabledelayedexpansion

echo.
echo ========================================
echo ?? MEENGLE SIMULTANEOUS BUILD START
echo ========================================
echo.
echo ?? Building: APK
echo ?? Building: AAB (Google Play)
echo ?? Building: iOS
echo ?? Building: Web
echo.

cd "flutter_app"

echo [1/4] Starting APK build...
start "APK Build" cmd /k "flutter build apk --release --build-name=1.0.0 --build-number=1"

echo [2/4] Starting AAB build...
start "AAB Build" cmd /k "flutter build appbundle --release --build-name=1.0.0 --build-number=1"

echo [3/4] Starting iOS build...
start "iOS Build" cmd /k "flutter build ios --release --build-name=1.0.0 --build-number=1"

echo [4/4] Starting Web build...
start "Web Build" cmd /k "flutter build web --release --build-name=1.0.0"

echo.
echo ========================================
echo ? All builds started simultaneously!
echo ========================================
echo.
echo Wait for all windows to complete...
echo.
echo Expected completion times:
echo   APK:  10-15 minutes
echo   AAB:  10-15 minutes
echo   iOS:  15-20 minutes
echo   Web:  5-10 minutes
echo.
echo When complete, check:
echo   APK:  build\app\outputs\apk\release\app-release.apk
echo   AAB:  build\app\outputs\bundle\release\app-release.aab
echo   iOS:  build\ios\ipa\meengle.ipa
echo   Web:  build\web\
echo.

pause
