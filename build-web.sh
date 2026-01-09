#!/bin/bash

# Meengle Web App Build Script
# This script builds the web app for deployment and APK generation

set -e

echo "======================================"
echo "MEENGLE WEB APP BUILD SCRIPT"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}? Node.js is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Node.js version:${NC}"
node --version
echo ""

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}? npm is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${YELLOW}npm version:${NC}"
npm --version
echo ""

# Install dependencies
echo -e "${YELLOW}?? Installing dependencies...${NC}"
cd frontend
npm install
cd ..
echo -e "${GREEN}? Dependencies installed${NC}"
echo ""

# Build frontend assets
echo -e "${YELLOW}?? Building frontend assets...${NC}"
cd frontend
npm run build
cd ..
echo -e "${GREEN}? Frontend assets built${NC}"
echo ""

# Create dist directory structure
echo -e "${YELLOW}?? Creating distribution structure...${NC}"
mkdir -p dist
mkdir -p dist/assets/{css,js,icons,images}
mkdir -p dist/pages

# Copy HTML files
echo -e "${YELLOW}?? Copying HTML files...${NC}"
cp frontend/index.html dist/
cp frontend/pages/*.html dist/pages/
cp frontend/manifest.json dist/
cp frontend/service-worker.js dist/

# Copy assets
echo -e "${YELLOW}?? Copying CSS files...${NC}"
cp -r frontend/assets/css/* dist/assets/css/

echo -e "${YELLOW}?? Copying JavaScript files...${NC}"
cp -r frontend/assets/js/* dist/assets/js/

# Copy images if they exist
if [ -d "frontend/assets/images" ]; then
    echo -e "${YELLOW}???  Copying images...${NC}"
    cp -r frontend/assets/images/* dist/assets/images/
fi

# Copy icons if they exist
if [ -d "frontend/assets/icons" ]; then
    echo -e "${YELLOW}?? Copying icons...${NC}"
    cp -r frontend/assets/icons/* dist/assets/icons/
fi

echo -e "${GREEN}? Distribution files copied${NC}"
echo ""

# Validate build
echo -e "${YELLOW}? Validating build...${NC}"
if [ -f "dist/index.html" ] && [ -f "dist/manifest.json" ] && [ -f "dist/service-worker.js" ]; then
    echo -e "${GREEN}? Build validation passed${NC}"
else
    echo -e "${RED}? Build validation failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}======================================"
echo "? BUILD COMPLETE"
echo "======================================${NC}"
echo ""
echo -e "${YELLOW}Distribution folder:${NC} dist/"
echo -e "${YELLOW}Ready for:${NC}"
echo "  • Web deployment (copy dist/ to server)"
echo "  • Capacitor/APK build (use dist as webDir)"
echo "  • Mobile app build"
echo ""

# Optional: Display build size
echo -e "${YELLOW}Build size:${NC}"
du -sh dist/
echo ""

# Optional: Next steps
echo -e "${YELLOW}Next steps:${NC}"
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
