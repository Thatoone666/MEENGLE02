# ?? Meengle - Simultaneous Multi-Platform Build
# Builds APK, AAB, iOS, and Web at the same time

param(
    [switch]$SkipClean = $false
)

Write-Host "========================================" -ForegroundColor Green
Write-Host "?? MEENGLE SIMULTANEOUS BUILD" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Set directories
$flutterAppDir = Join-Path (Get-Location) "flutter_app"
$outputDir = Join-Path (Get-Location) "dist"

# Create output directories
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

New-Item -ItemType Directory -Path "$outputDir\android" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\ios" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\web" -Force | Out-Null

Write-Host "?? Output Directory: $outputDir" -ForegroundColor Cyan
Write-Host ""

# Clean if not skipped
if (-not $SkipClean) {
    Write-Host "?? Cleaning previous builds..." -ForegroundColor Yellow
    Push-Location $flutterAppDir
    flutter clean
    Pop-Location
    Write-Host "? Cleaned" -ForegroundColor Green
    Write-Host ""
}

# Start all builds simultaneously
Write-Host "?? Starting simultaneous builds..." -ForegroundColor Cyan
Write-Host ""

$jobs = @()

# Job 1: APK Build
Write-Host "?? [1/4] Starting APK build..." -ForegroundColor Blue
$apkJob = Start-Job -ScriptBlock {
    param($dir)
    Push-Location $dir
    flutter build apk --release --build-name=1.0.0 --build-number=1 2>&1 | Tee-Object -Variable output
    Pop-Location
    return $output
} -ArgumentList $flutterAppDir -Name "APK Build"
$jobs += $apkJob

# Job 2: AAB Build
Write-Host "?? [2/4] Starting AAB build (Google Play)..." -ForegroundColor Blue
$aabJob = Start-Job -ScriptBlock {
    param($dir)
    Push-Location $dir
    flutter build appbundle --release --build-name=1.0.0 --build-number=1 2>&1 | Tee-Object -Variable output
    Pop-Location
    return $output
} -ArgumentList $flutterAppDir -Name "AAB Build"
$jobs += $aabJob

# Job 3: iOS Build
Write-Host "?? [3/4] Starting iOS build..." -ForegroundColor Blue
$iosJob = Start-Job -ScriptBlock {
    param($dir)
    Push-Location $dir
    flutter build ios --release --build-name=1.0.0 --build-number=1 2>&1 | Tee-Object -Variable output
    Pop-Location
    return $output
} -ArgumentList $flutterAppDir -Name "iOS Build"
$jobs += $iosJob

# Job 4: Web Build
Write-Host "?? [4/4] Starting Web build..." -ForegroundColor Blue
$webJob = Start-Job -ScriptBlock {
    param($dir)
    Push-Location $dir
    flutter build web --release --build-name=1.0.0 2>&1 | Tee-Object -Variable output
    Pop-Location
    return $output
} -ArgumentList $flutterAppDir -Name "Web Build"
$jobs += $webJob

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "? All 4 builds started simultaneously!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Monitoring builds..." -ForegroundColor Yellow
Write-Host ""

# Wait for all jobs and display progress
while ($jobs | Where-Object { $_.State -eq 'Running' }) {
    $completed = @($jobs | Where-Object { $_.State -eq 'Completed' }).Count
    $running = @($jobs | Where-Object { $_.State -eq 'Running' }).Count
    Write-Host "Progress: $completed/4 completed, $running running" -ForegroundColor Cyan
    Start-Sleep -Seconds 30
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "? ALL BUILDS COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Collect results
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    $jobName = $job.Name
    $state = $job.State
    
    if ($state -eq 'Completed') {
        Write-Host "? $jobName - SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "? $jobName - FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "?? BUILD ARTIFACTS:" -ForegroundColor Yellow
Write-Host ""

# Check and copy artifacts
$apkPath = Join-Path $flutterAppDir "build\app\outputs\apk\release\app-release.apk"
$aabPath = Join-Path $flutterAppDir "build\app\outputs\bundle\release\app-release.aab"
$iosPath = Join-Path $flutterAppDir "build\ios\ipa\meengle.ipa"
$webPath = Join-Path $flutterAppDir "build\web"

if (Test-Path $apkPath) {
    $size = (Get-Item $apkPath).Length / 1MB
    Write-Host "? APK: $apkPath" -ForegroundColor Green
    Write-Host "   Size: $([math]::Round($size, 2)) MB" -ForegroundColor Gray
    Copy-Item $apkPath "$outputDir\android\meengle-1.0.0.apk" -Force
}

if (Test-Path $aabPath) {
    $size = (Get-Item $aabPath).Length / 1MB
    Write-Host "? AAB (Google Play): $aabPath" -ForegroundColor Green
    Write-Host "   Size: $([math]::Round($size, 2)) MB" -ForegroundColor Gray
    Copy-Item $aabPath "$outputDir\android\meengle-1.0.0.aab" -Force
}

if (Test-Path $iosPath) {
    $size = (Get-Item $iosPath).Length / 1MB
    Write-Host "? iOS: $iosPath" -ForegroundColor Green
    Write-Host "   Size: $([math]::Round($size, 2)) MB" -ForegroundColor Gray
    Copy-Item $iosPath "$outputDir\ios\meengle.ipa" -Force
}

if (Test-Path $webPath) {
    $size = (Get-ChildItem $webPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "? Web: $webPath" -ForegroundColor Green
    Write-Host "   Size: $([math]::Round($size, 2)) MB" -ForegroundColor Gray
    Copy-Item $webPath "$outputDir\web\meengle-web-1.0.0" -Recurse -Force
}

Write-Host ""
Write-Host "?? Distribution packages created in: $outputDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "?? NEXT STEPS:" -ForegroundColor Yellow
Write-Host "   1. Upload AAB to Google Play Console" -ForegroundColor Gray
Write-Host "   2. Upload IPA to App Store Connect" -ForegroundColor Gray
Write-Host "   3. Deploy Web to Firebase/Netlify" -ForegroundColor Gray
Write-Host ""
Write-Host "? BUILD COMPLETE!" -ForegroundColor Green
Write-Host ""

# Clean up jobs
Get-Job | Remove-Job -Force
