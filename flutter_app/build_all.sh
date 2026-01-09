#!/bin/bash
# Complete build script for both Android and iOS

set -e

echo "🚀 Meengle Multi-Platform Build Script"
echo "======================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter version:${NC}"
flutter --version
echo ""

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Clean
echo -e "${YELLOW}🧹 Cleaning build artifacts...${NC}"
flutter clean
flutter pub get

# Analyze
echo -e "${YELLOW}📊 Analyzing code...${NC}"
dart analyze lib/ --fatal-infos

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Analysis failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Code analysis passed${NC}"
echo ""

# Build Android
if [ "$1" == "android" ] || [ "$1" == "all" ]; then
    echo -e "${YELLOW}🤖 Building Android APK...${NC}"
    flutter build apk --release
    
    if [ $? -eq 0 ]; then
        APK_PATH="build/app/outputs/apk/release/app-release.apk"
        if [ -f "$APK_PATH" ]; then
            SIZE=$(du -h "$APK_PATH" | cut -f1)
            echo -e "${GREEN}✅ Android APK built successfully${NC}"
            echo -e "${GREEN}   Location: $APK_PATH${NC}"
            echo -e "${GREEN}   Size: $SIZE${NC}"
        fi
    else
        echo -e "${RED}❌ Android build failed${NC}"
        exit 1
    fi
    echo ""
fi

# Build iOS
if [ "$1" == "ios" ] || [ "$1" == "all" ]; then
    echo -e "${YELLOW}🍎 Building iOS app...${NC}"
    
    if [ "$(uname)" == "Darwin" ]; then
        flutter build ios --release
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ iOS app built successfully${NC}"
            echo -e "${GREEN}   Location: build/ios/iphoneos/Runner.app${NC}"
        else
            echo -e "${RED}❌ iOS build failed${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  iOS build only available on macOS${NC}"
    fi
    echo ""
fi

# Summary
echo "======================================="
echo -e "${GREEN}✅ Build Complete!${NC}"
echo ""
echo "📱 Outputs:"
echo "   Android: build/app/outputs/apk/release/app-release.apk"
echo "   iOS: build/ios/iphoneos/Runner.app"
echo ""
echo "📤 Next steps:"
echo "   1. Test on devices"
echo "   2. Upload to Play Store (Android)"
echo "   3. Upload to App Store Connect (iOS)"
echo ""
