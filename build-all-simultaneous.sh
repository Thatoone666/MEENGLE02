#!/bin/bash

# ?? Meengle - Simultaneous Multi-Platform Build
# Builds APK, AAB, iOS, and Web at the same time

set -e

echo ""
echo "=========================================="
echo "?? MEENGLE SIMULTANEOUS BUILD"
echo "=========================================="
echo ""
echo "?? Building: APK"
echo "?? Building: AAB (Google Play)"
echo "?? Building: iOS"
echo "?? Building: Web"
echo ""

# Set directories
FLUTTER_APP_DIR="$PWD/flutter_app"
OUTPUT_DIR="$PWD/dist"

# Create output directories
mkdir -p "$OUTPUT_DIR/android"
mkdir -p "$OUTPUT_DIR/ios"
mkdir -p "$OUTPUT_DIR/web"

echo "?? Output Directory: $OUTPUT_DIR"
echo ""

# Clean
echo "?? Cleaning previous builds..."
cd "$FLUTTER_APP_DIR"
flutter clean
cd - > /dev/null
echo "? Cleaned"
echo ""

# Start all builds simultaneously
echo "?? Starting simultaneous builds..."
echo ""

# APK Build
echo "?? [1/4] Starting APK build in background..."
(
    cd "$FLUTTER_APP_DIR"
    flutter build apk --release --build-name=1.0.0 --build-number=1
) &
APK_PID=$!

# AAB Build
echo "?? [2/4] Starting AAB build in background..."
(
    cd "$FLUTTER_APP_DIR"
    flutter build appbundle --release --build-name=1.0.0 --build-number=1
) &
AAB_PID=$!

# iOS Build
echo "?? [3/4] Starting iOS build in background..."
(
    cd "$FLUTTER_APP_DIR"
    flutter build ios --release --build-name=1.0.0 --build-number=1
) &
IOS_PID=$!

# Web Build
echo "?? [4/4] Starting Web build in background..."
(
    cd "$FLUTTER_APP_DIR"
    flutter build web --release --build-name=1.0.0
) &
WEB_PID=$!

echo ""
echo "=========================================="
echo "? All 4 builds started simultaneously!"
echo "=========================================="
echo ""
echo "Process IDs:"
echo "  APK: $APK_PID"
echo "  AAB: $AAB_PID"
echo "  iOS: $IOS_PID"
echo "  Web: $WEB_PID"
echo ""
echo "Waiting for all builds to complete..."
echo ""

# Wait for all processes
wait $APK_PID
APK_STATUS=$?

wait $AAB_PID
AAB_STATUS=$?

wait $IOS_PID
IOS_STATUS=$?

wait $WEB_PID
WEB_STATUS=$?

echo ""
echo "=========================================="
echo "? ALL BUILDS COMPLETE!"
echo "=========================================="
echo ""

# Check results
if [ $APK_STATUS -eq 0 ]; then
    echo "? APK Build - SUCCESS"
else
    echo "? APK Build - FAILED"
fi

if [ $AAB_STATUS -eq 0 ]; then
    echo "? AAB Build - SUCCESS"
else
    echo "? AAB Build - FAILED"
fi

if [ $IOS_STATUS -eq 0 ]; then
    echo "? iOS Build - SUCCESS"
else
    echo "? iOS Build - FAILED"
fi

if [ $WEB_STATUS -eq 0 ]; then
    echo "? Web Build - SUCCESS"
else
    echo "? Web Build - FAILED"
fi

echo ""
echo "?? BUILD ARTIFACTS:"
echo ""

# Check and copy artifacts
APK_FILE="$FLUTTER_APP_DIR/build/app/outputs/apk/release/app-release.apk"
if [ -f "$APK_FILE" ]; then
    SIZE=$(ls -lh "$APK_FILE" | awk '{print $5}')
    echo "? APK: $APK_FILE"
    echo "   Size: $SIZE"
    cp "$APK_FILE" "$OUTPUT_DIR/android/meengle-1.0.0.apk"
fi

AAB_FILE="$FLUTTER_APP_DIR/build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_FILE" ]; then
    SIZE=$(ls -lh "$AAB_FILE" | awk '{print $5}')
    echo "? AAB (Google Play): $AAB_FILE"
    echo "   Size: $SIZE"
    cp "$AAB_FILE" "$OUTPUT_DIR/android/meengle-1.0.0.aab"
fi

IOS_FILE="$FLUTTER_APP_DIR/build/ios/ipa/meengle.ipa"
if [ -f "$IOS_FILE" ]; then
    SIZE=$(ls -lh "$IOS_FILE" | awk '{print $5}')
    echo "? iOS: $IOS_FILE"
    echo "   Size: $SIZE"
    cp "$IOS_FILE" "$OUTPUT_DIR/ios/meengle.ipa"
fi

WEB_DIR="$FLUTTER_APP_DIR/build/web"
if [ -d "$WEB_DIR" ]; then
    SIZE=$(du -sh "$WEB_DIR" | awk '{print $1}')
    echo "? Web: $WEB_DIR"
    echo "   Size: $SIZE"
    cp -r "$WEB_DIR" "$OUTPUT_DIR/web/meengle-web-1.0.0"
fi

echo ""
echo "?? Distribution packages created in: $OUTPUT_DIR"
echo ""
echo "?? NEXT STEPS:"
echo "   1. Upload AAB to Google Play Console"
echo "   2. Upload IPA to App Store Connect"
echo "   3. Deploy Web to Firebase/Netlify"
echo ""
echo "? BUILD COMPLETE!"
echo ""
