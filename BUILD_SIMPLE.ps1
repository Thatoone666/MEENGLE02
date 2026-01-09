#!/usr/bin/env pwsh

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "?? MEENGLE PRODUCTION BUILD" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

Set-Location flutter_app

Write-Host "[1/5] Cleaning..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "[2/5] Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "[3/5] Building Android APK..." -ForegroundColor Yellow
flutter build apk --release --build-number=1 --build-name=1.0.0

Write-Host ""
Write-Host "[4/5] Building Android AAB..." -ForegroundColor Yellow
flutter build appbundle --release --build-number=1 --build-name=1.0.0

Write-Host ""
Write-Host "[5/5] Building Web..." -ForegroundColor Yellow
flutter build web --release --build-name=1.0.0

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "? BUILD COMPLETE!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "?? APK: build\app\outputs\apk\release\app-release.apk" -ForegroundColor Cyan
Write-Host "?? AAB: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Cyan
Write-Host "?? Web: build\web\" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
