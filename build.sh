#!/bin/bash
set -e

echo "Building CryptoBar..."
cd "$(dirname "$0")"

swift build -c release

# Create .app bundle
APP_DIR="CryptoBar.app/Contents/MacOS"
mkdir -p "$APP_DIR"
cp .build/release/CryptoBar "$APP_DIR/"

# Create Info.plist
cat > CryptoBar.app/Contents/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>CryptoBar</string>
    <key>CFBundleIdentifier</key>
    <string>com.cryptobar.app</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>CryptoBar</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
PLIST

echo ""
echo "Build complete!"
echo "  App bundle: $(pwd)/CryptoBar.app"
echo ""
echo "To run:  open CryptoBar.app"
echo "To install: cp -r CryptoBar.app /Applications/"
