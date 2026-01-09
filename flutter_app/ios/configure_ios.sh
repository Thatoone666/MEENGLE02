#!/bin/bash
# iOS Build Configuration Script

echo "🍎 iOS Build Configuration"
echo "============================"

# Check Xcode
if ! xcode-select -p &> /dev/null; then
    echo "❌ Xcode not installed. Installing..."
    xcode-select --install
else
    echo "✅ Xcode installed: $(xcode-select -p)"
fi

# Check CocoaPods
if ! command -v pod &> /dev/null; then
    echo "❌ CocoaPods not installed. Installing..."
    sudo gem install cocoapods
else
    echo "✅ CocoaPods installed: $(pod --version)"
fi

# Navigate to project
cd "$(dirname "$0")"
cd flutter_app/ios

echo ""
echo "📦 Installing CocoaPods dependencies..."
pod install --repo-update

echo ""
echo "✅ iOS build configuration complete!"
echo ""
echo "To build for iOS:"
echo "  flutter build ios --release"
echo ""
echo "To export IPA:"
echo "  xcodebuild -workspace Runner.xcworkspace \\"
echo "    -scheme Runner \\"
echo "    -configuration Release \\"
echo "    -archivePath build/Runner.xcarchive \\"
echo "    archive"
