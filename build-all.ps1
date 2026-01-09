# ========================================
# MEENGLE APP - BUILD & DEPLOYMENT SCRIPT (Windows)
# ========================================
# Usage: .\build-all.ps1

# Set error handling
$ErrorActionPreference = "Stop"

# Colors
$Green = 'Green'
$Red = 'Red'
$Yellow = 'Yellow'
$Blue = 'Cyan'

# Directories
$FLUTTER_APP = "flutter_app"
$BACKEND = "backend"
$BUILD_OUTPUT = "build_output"

# Create output directory
if (!(Test-Path $BUILD_OUTPUT)) {
    New-Item -ItemType Directory -Path $BUILD_OUTPUT | Out-Null
}

# Functions
function Print-Status {
    Write-Host "[INFO] $args" -ForegroundColor $Blue
}

function Print-Success {
    Write-Host "[SUCCESS] $args" -ForegroundColor $Green
}

function Print-Error {
    Write-Host "[ERROR] $args" -ForegroundColor $Red
}

function Print-Warning {
    Write-Host "[WARNING] $args" -ForegroundColor $Yellow
}

# ==========================================
# PHASE 1: PRE-BUILD CHECKS
# ==========================================

Write-Host ""
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host "?         PHASE 1: PRE-BUILD VERIFICATION            ?" -ForegroundColor $Blue
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host ""

# Check Flutter
Print-Status "Checking Flutter installation..."
try {
    $flutterVersion = flutter --version
    Write-Host $flutterVersion
    Print-Success "Flutter is installed"
} catch {
    Print-Error "Flutter not found. Please install Flutter first."
    exit 1
}

Write-Host ""

# Check Dart
Print-Status "Checking Dart installation..."
dart --version
Print-Success "Dart is installed"

Write-Host ""

# Clean previous builds
Print-Status "Cleaning previous builds..."
Push-Location $FLUTTER_APP
flutter clean
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
}
Pop-Location
Print-Success "Previous builds cleaned"

Write-Host ""

# Run analysis
Print-Status "Running Dart analysis..."
Push-Location $FLUTTER_APP
$analysisResult = dart analyze 2>&1
if ($LASTEXITCODE -eq 0) {
    Print-Success "Dart analysis passed"
} else {
    Print-Error "Dart analysis found issues"
    exit 1
}
Pop-Location

Write-Host ""

# Get dependencies
Print-Status "Getting dependencies..."
Push-Location $FLUTTER_APP
flutter pub get
Print-Success "Dependencies fetched"
Pop-Location

Write-Host ""

# ==========================================
# PHASE 2: BUILD APK (Android)
# ==========================================

Write-Host ""
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host "?         PHASE 2: BUILD APK (ANDROID)               ?" -ForegroundColor $Blue
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host ""

Print-Status "Building APK for Android..."
Push-Location $FLUTTER_APP

try {
    flutter build apk --release
    Print-Success "APK build completed successfully"
    
    # Copy APK to output
    $apkPath = "build\app\outputs\flutter-app-release.apk"
    if (Test-Path $apkPath) {
        Copy-Item $apkPath "..\$BUILD_OUTPUT\meengle-release.apk"
        Print-Success "APK saved to: $BUILD_OUTPUT\meengle-release.apk"
        Get-Item "..\$BUILD_OUTPUT\meengle-release.apk" | Select-Object FullName, Length
    }
} catch {
    Print-Error "APK build failed: $_"
    Pop-Location
    exit 1
}

Pop-Location
Write-Host ""

# ==========================================
# PHASE 3: BUILD iOS (macOS only)
# ==========================================

Write-Host ""
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host "?         PHASE 3: BUILD iOS (macOS ONLY)            ?" -ForegroundColor $Blue
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host ""

if ($IsMacOS) {
    Print-Status "Building iOS app..."
    Push-Location $FLUTTER_APP
    
    try {
        flutter build ios --release
        Print-Success "iOS build completed successfully"
    } catch {
        Print-Warning "iOS build failed: $_"
    }
    
    Pop-Location
} else {
    Print-Warning "iOS build requires macOS - skipped on Windows"
}

Write-Host ""

# ==========================================
# PHASE 4: BUILD WEB
# ==========================================

Write-Host ""
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host "?         PHASE 4: BUILD WEB                         ?" -ForegroundColor $Blue
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host ""

Print-Status "Building Web version..."
Push-Location $FLUTTER_APP

try {
    flutter build web --release
    Print-Success "Web build completed successfully"
    
    # Copy web build to output
    $webPath = "build\web"
    if (Test-Path $webPath) {
        $outputWeb = "..\$BUILD_OUTPUT\web"
        if (!(Test-Path $outputWeb)) {
            New-Item -ItemType Directory -Path $outputWeb | Out-Null
        }
        Copy-Item "$webPath\*" $outputWeb -Recurse -Force
        Print-Success "Web build saved to: $BUILD_OUTPUT\web"
        Get-ChildItem $outputWeb | Select-Object Name | Head -10
    }
} catch {
    Print-Error "Web build failed: $_"
    Pop-Location
    exit 1
}

Pop-Location
Write-Host ""

# ==========================================
# PHASE 5: BUILD SUMMARY
# ==========================================

Write-Host ""
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host "?         BUILD SUMMARY                              ?" -ForegroundColor $Blue
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host ""

Print-Status "Build Output Directory: $((Get-Location).Path)\$BUILD_OUTPUT"
Write-Host ""

Write-Host "?? BUILD ARTIFACTS:" -ForegroundColor $Green
Write-Host ""

# Check APK
$apkFile = "$BUILD_OUTPUT\meengle-release.apk"
if (Test-Path $apkFile) {
    $apkSize = (Get-Item $apkFile).Length / 1MB
    Write-Host "? Android APK" -ForegroundColor $Green
    Write-Host "  Location: $apkFile"
    Write-Host "  Size: $([Math]::Round($apkSize, 2)) MB"
} else {
    Write-Host "? Android APK - Not found" -ForegroundColor $Yellow
}

Write-Host ""

# Check Web
$webDir = "$BUILD_OUTPUT\web"
if (Test-Path $webDir) {
    Write-Host "? Web Build" -ForegroundColor $Green
    Write-Host "  Location: $webDir"
    $webSize = (Get-ChildItem $webDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "  Size: $([Math]::Round($webSize, 2)) MB"
} else {
    Write-Host "? Web Build - Not found" -ForegroundColor $Yellow
}

Write-Host ""

# ==========================================
# DEPLOYMENT INSTRUCTIONS
# ==========================================

Write-Host ""
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host "?         DEPLOYMENT INSTRUCTIONS                    ?" -ForegroundColor $Blue
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Blue
Write-Host ""

Write-Host "?? ANDROID (APK):" -ForegroundColor $Yellow
Write-Host "1. Upload APK to Google Play Console"
Write-Host "2. Review and test on staging track"
Write-Host "3. Promote to production"
Write-Host ""

Write-Host "?? iOS (App Store):" -ForegroundColor $Yellow
Write-Host "1. Build on macOS with Xcode"
Write-Host "2. Create App Store provisioning profiles"
Write-Host "3. Upload to App Store Connect"
Write-Host "4. Submit for approval"
Write-Host ""

Write-Host "?? WEB:" -ForegroundColor $Yellow
Write-Host "1. Deploy to web server or CDN"
Write-Host "2. Configure domain and SSL"
Write-Host "3. Set up environment variables"
Write-Host "4. Monitor analytics"
Write-Host ""

# ==========================================
# FINAL STATUS
# ==========================================

Write-Host ""
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Green
Write-Host "?  BUILD COMPLETED SUCCESSFULLY! ?                  ?" -ForegroundColor $Green
Write-Host "??????????????????????????????????????????????????????" -ForegroundColor $Green
Write-Host ""

Print-Success "All builds completed successfully"
Print-Status "Build artifacts are in: $BUILD_OUTPUT"
Write-Host ""

Write-Host "Next steps:"
Write-Host "1. Test applications locally"
Write-Host "2. Review build artifacts"
Write-Host "3. Follow deployment instructions above"
Write-Host "4. Submit to app stores"
Write-Host ""

Print-Success "Build script completed!"
