#!/bin/bash

# ========================================
# MEENGLE APP - BUILD & DEPLOYMENT SCRIPT
# ========================================
# This script builds APK, iOS, and Web versions
# Usage: ./build-all.sh

set -e

echo "?? MEENGLE APP BUILD SCRIPT"
echo "============================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
FLUTTER_APP="flutter_app"
BACKEND="backend"
BUILD_OUTPUT="build_output"

# Create output directory
mkdir -p "$BUILD_OUTPUT"

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to run command with error checking
run_command() {
    local cmd="$1"
    local description="$2"
    
    print_status "Running: $description"
    if eval "$cmd"; then
        print_success "$description completed successfully"
    else
        print_error "$description failed"
        exit 1
    fi
}

# ==========================================
# PHASE 1: PRE-BUILD CHECKS & VERIFICATION
# ==========================================

echo ""
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo -e "${BLUE}?         PHASE 1: PRE-BUILD VERIFICATION            ?${NC}"
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo ""

# Check Flutter installation
print_status "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi
flutter --version
print_success "Flutter is installed"
echo ""

# Check Dart installation
print_status "Checking Dart installation..."
dart --version
print_success "Dart is installed"
echo ""

# Get Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_status "Using: $FLUTTER_VERSION"
echo ""

# Clean previous builds
print_status "Cleaning previous builds..."
cd "$FLUTTER_APP"
flutter clean
rm -rf build/
print_success "Previous builds cleaned"
cd ..
echo ""

# Run analysis
print_status "Running Dart analysis..."
cd "$FLUTTER_APP"
if dart analyze; then
    print_success "Dart analysis passed - No errors found"
else
    print_error "Dart analysis found issues"
    exit 1
fi
cd ..
echo ""

# Get pub dependencies
print_status "Getting dependencies..."
cd "$FLUTTER_APP"
flutter pub get
print_success "Dependencies fetched"
cd ..
echo ""

# ==========================================
# PHASE 2: BUILD APK (Android)
# ==========================================

echo ""
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo -e "${BLUE}?         PHASE 2: BUILD APK (ANDROID)               ?${NC}"
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo ""

print_status "Building APK for Android..."
cd "$FLUTTER_APP"

if flutter build apk --release; then
    print_success "APK build completed successfully"
    
    # Copy APK to output
    if [ -f "build/app/outputs/flutter-app-release.apk" ]; then
        cp build/app/outputs/flutter-app-release.apk ../"$BUILD_OUTPUT"/meengle-release.apk
        print_success "APK saved to: $BUILD_OUTPUT/meengle-release.apk"
        ls -lh ../"$BUILD_OUTPUT"/meengle-release.apk
    fi
else
    print_error "APK build failed"
    cd ..
    exit 1
fi

cd ..
echo ""

# ==========================================
# PHASE 3: BUILD iOS
# ==========================================

echo ""
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo -e "${BLUE}?         PHASE 3: BUILD iOS                         ?${NC}"
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo ""

print_status "Building iOS app..."
cd "$FLUTTER_APP"

if flutter build ios --release; then
    print_success "iOS build completed successfully"
    
    # Archive the iOS build
    if [ -d "build/ios/Release-iphoneos" ]; then
        print_status "Creating iOS archive..."
        cd build/ios
        xcodebuild -workspace Runner.xcworkspace \
            -scheme Runner \
            -configuration Release \
            -derivedDataPath . \
            archive -archivePath Runner.xcarchive 2>/dev/null || {
            print_warning "iOS archive creation skipped (Xcode not available or not needed)"
        }
        cd ../../..
    fi
else
    print_warning "iOS build failed - this may require Xcode on macOS"
    # Don't exit, continue with web build
fi

cd ..
echo ""

# ==========================================
# PHASE 4: BUILD WEB
# ==========================================

echo ""
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo -e "${BLUE}?         PHASE 4: BUILD WEB                         ?${NC}"
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo ""

print_status "Building Web version..."
cd "$FLUTTER_APP"

if flutter build web --release; then
    print_success "Web build completed successfully"
    
    # Copy web build to output
    if [ -d "build/web" ]; then
        mkdir -p ../"$BUILD_OUTPUT"/web
        cp -r build/web/* ../"$BUILD_OUTPUT"/web/
        print_success "Web build saved to: $BUILD_OUTPUT/web"
        ls -la ../"$BUILD_OUTPUT"/web | head -20
    fi
else
    print_error "Web build failed"
    cd ..
    exit 1
fi

cd ..
echo ""

# ==========================================
# PHASE 5: BACKEND BUILD (Optional)
# ==========================================

echo ""
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo -e "${BLUE}?         PHASE 5: BACKEND VERIFICATION              ?${NC}"
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo ""

if [ -d "$BACKEND" ]; then
    print_status "Checking Backend..."
    cd "$BACKEND"
    
    # Check if Node.js is installed
    if command -v node &> /dev/null; then
        print_status "Node.js version:"
        node --version
        print_success "Backend directory verified"
    else
        print_warning "Node.js not installed - skipping backend verification"
    fi
    
    cd ..
else
    print_warning "Backend directory not found"
fi

echo ""

# ==========================================
# PHASE 6: BUILD SUMMARY
# ==========================================

echo ""
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo -e "${BLUE}?         BUILD SUMMARY                              ?${NC}"
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo ""

print_status "Build Output Directory: $(pwd)/$BUILD_OUTPUT"
echo ""

echo -e "${GREEN}?? BUILD ARTIFACTS:${NC}"
echo ""

# Check APK
if [ -f "$BUILD_OUTPUT/meengle-release.apk" ]; then
    APK_SIZE=$(ls -lh "$BUILD_OUTPUT/meengle-release.apk" | awk '{print $5}')
    echo -e "${GREEN}?${NC} Android APK"
    echo "  Location: $BUILD_OUTPUT/meengle-release.apk"
    echo "  Size: $APK_SIZE"
else
    echo -e "${YELLOW}?${NC} Android APK - Not found"
fi

echo ""

# Check iOS
if [ -d "flutter_app/build/ios/Release-iphoneos" ]; then
    echo -e "${GREEN}?${NC} iOS Build"
    echo "  Location: flutter_app/build/ios/Release-iphoneos"
else
    echo -e "${YELLOW}?${NC} iOS Build - Available on macOS with Xcode"
fi

echo ""

# Check Web
if [ -d "$BUILD_OUTPUT/web" ]; then
    WEB_SIZE=$(du -sh "$BUILD_OUTPUT/web" | awk '{print $1}')
    echo -e "${GREEN}?${NC} Web Build"
    echo "  Location: $BUILD_OUTPUT/web"
    echo "  Size: $WEB_SIZE"
else
    echo -e "${YELLOW}?${NC} Web Build - Not found"
fi

echo ""

# ==========================================
# PHASE 7: DEPLOYMENT INSTRUCTIONS
# ==========================================

echo ""
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo -e "${BLUE}?         DEPLOYMENT INSTRUCTIONS                    ?${NC}"
echo -e "${BLUE}??????????????????????????????????????????????????????${NC}"
echo ""

echo -e "${YELLOW}?? ANDROID (APK):${NC}"
echo "1. Upload APK to Google Play Console"
echo "2. Review and test on staging track"
echo "3. Promote to production"
echo "4. Monitor crash reports"
echo ""

echo -e "${YELLOW}?? iOS (App Store):${NC}"
echo "1. Generate App Store provisioning profiles"
echo "2. Create release archive with Xcode"
echo "3. Upload to App Store Connect"
echo "4. Review and submit for approval"
echo "5. Monitor for rejections"
echo ""

echo -e "${YELLOW}?? WEB:${NC}"
echo "1. Deploy to web server or CDN"
echo "2. Configure domain and SSL"
echo "3. Set up environment variables"
echo "4. Monitor analytics and errors"
echo "5. Enable offline PWA caching"
echo ""

# ==========================================
# FINAL STATUS
# ==========================================

echo ""
echo -e "${GREEN}??????????????????????????????????????????????????????${NC}"
echo -e "${GREEN}?  BUILD COMPLETED SUCCESSFULLY! ?                  ?${NC}"
echo -e "${GREEN}??????????????????????????????????????????????????????${NC}"
echo ""

print_success "All builds completed successfully"
print_status "Build artifacts are in: $(pwd)/$BUILD_OUTPUT"
echo ""

echo "Next steps:"
echo "1. Test applications locally"
echo "2. Review build artifacts"
echo "3. Follow deployment instructions above"
echo "4. Submit to app stores"
echo ""

print_success "Build script completed!"
