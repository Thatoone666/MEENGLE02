#!/bin/bash
# MEENGLE Web App Build Script for Mac/Linux
# This script builds the web app for deployment and APK generation

set -e

echo "======================================"
echo "MEENGLE WEB APP BUILD SCRIPT"
echo "======================================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js is not installed. Please install it first."
    exit 1
fi

echo "Node.js version:"
node --version
echo ""

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "[ERROR] npm is not installed. Please install it first."
    exit 1
fi

echo "npm version:"
npm --version
echo ""

# Install dependencies
echo "[*] Installing frontend dependencies..."
cd frontend
npm install
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to install frontend dependencies"
    exit 1
fi
cd ..
echo "[OK] Frontend dependencies installed"
echo ""

# Build frontend assets
echo "[*] Building frontend assets..."
cd frontend
npm run build
if [ $? -ne 0 ]; then
    echo "[ERROR] Frontend build failed"
    exit 1
fi
cd ..
echo "[OK] Frontend assets built"
echo ""

# Create dist directory structure
echo "[*] Creating distribution structure..."
mkdir -p dist
mkdir -p dist/assets
mkdir -p dist/assets/css
mkdir -p dist/assets/js
mkdir -p dist/assets/icons
mkdir -p dist/assets/images
mkdir -p dist/pages

# Copy HTML files
echo "[*] Copying HTML files..."
cp frontend/index.html dist/
cp frontend/pages/*.html dist/pages/ 2>/dev/null || true
cp frontend/manifest.json dist/
cp frontend/service-worker.js dist/

# Verify required pages exist
echo "[*] Verifying required pages..."
required_pages=(
    "login.html"
    "signup.html"
    "forgot-password.html"
    "landing.html"
    "dashboard.html"
    "terms.html"
    "privacy.html"
    "community-guidelines.html"
    "help.html"
    "safety.html"
    "error.html"
    "404.html"
    "verify-email.html"
    "profile.html"
    "settings.html"
    "subscription.html"
)

missing_pages=0
for page in "${required_pages[@]}"; do
    if [ ! -f "dist/pages/$page" ]; then
        echo "[WARN] Missing page: $page"
        ((missing_pages++))
    fi
done

if [ $missing_pages -gt 0 ]; then
    echo "[WARN] $missing_pages pages are missing but build will continue"
fi

echo "[OK] Page verification complete"
echo ""

# Copy assets
echo "[*] Copying CSS files..."
cp -r frontend/assets/css/* dist/assets/css/ 2>/dev/null || true

echo "[*] Copying JavaScript files..."
cp -r frontend/assets/js/* dist/assets/js/ 2>/dev/null || true

# Copy images if they exist
if [ -d "frontend/assets/images" ]; then
    echo "[*] Copying images..."
    cp -r frontend/assets/images/* dist/assets/images/ 2>/dev/null || true
fi

# Copy icons if they exist
if [ -d "frontend/assets/icons" ]; then
    echo "[*] Copying icons..."
    cp -r frontend/assets/icons/* dist/assets/icons/ 2>/dev/null || true
fi

echo "[OK] Distribution files copied"
echo ""

# Validate build
echo "[*] Validating build..."
validation_passed=true

if [ ! -f "dist/index.html" ]; then
    echo "[ERROR] dist/index.html not found"
    validation_passed=false
fi

if [ ! -f "dist/manifest.json" ]; then
    echo "[ERROR] dist/manifest.json not found"
    validation_passed=false
fi

if [ ! -f "dist/service-worker.js" ]; then
    echo "[ERROR] dist/service-worker.js not found"
    validation_passed=false
fi

if [ ! -d "dist/assets/js" ] || [ -z "$(ls -A dist/assets/js/)" ]; then
    echo "[ERROR] No JavaScript files in dist/assets/js"
    validation_passed=false
fi

if [ ! -d "dist/assets/css" ] || [ -z "$(ls -A dist/assets/css/)" ]; then
    echo "[WARN] No CSS files in dist/assets/css"
fi

if [ "$validation_passed" = true ]; then
    echo "[OK] Build validation passed"
else
    echo "[ERROR] Build validation failed"
    exit 1
fi

echo ""
echo "======================================"
echo "[OK] BUILD COMPLETE"
echo "======================================"
echo ""

echo "Distribution folder: dist/"
echo "Ready for:"
echo "  - Web deployment (copy dist/ to server)"
echo "  - Capacitor/APK build (use dist as webDir)"
echo "  - Mobile app build"
echo ""

# Count files
filecount=$(find dist -type f | wc -l)
pagecount=$(find dist/pages -type f 2>/dev/null | wc -l)
echo "Build statistics:"
echo "  Total files: $filecount"
echo "  HTML pages: $pagecount"
echo ""

echo "Next steps:"
echo "1. For Capacitor APK build:"
echo "   npx cap sync"
echo "   npx cap build android"
echo ""
echo "2. For web deployment:"
echo "   Upload 'dist/' folder to your server"
echo ""
echo "3. For testing:"
echo "   npm install -g http-server"
echo "   http-server dist/"
echo ""
echo "4. For backend (if available):"
echo "   cd backend"
echo "   npm install"
echo "   npm start"
echo ""

echo "BUILD READY! ??"
