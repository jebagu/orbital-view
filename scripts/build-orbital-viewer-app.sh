#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h:h}"
APP_NAME="Orbital View VU Kit"
APP_BUNDLE="$PROJECT_DIR/$APP_NAME.app"
EXECUTABLE_NAME="OrbitalViewViewer"
BUILD_CONFIGURATION="${BUILD_CONFIGURATION:-release}"

cd "$PROJECT_DIR"

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export CLANG_MODULE_CACHE_PATH="$PROJECT_DIR/.build/clang-module-cache"
export SWIFTPM_CACHE_DIR="$PROJECT_DIR/.build/swiftpm-cache"

mkdir -p "$CLANG_MODULE_CACHE_PATH"
mkdir -p "$SWIFTPM_CACHE_DIR"

echo "Building $APP_NAME ($BUILD_CONFIGURATION)..."
swift build --disable-sandbox --configuration "$BUILD_CONFIGURATION" --product "$EXECUTABLE_NAME"

BIN_DIR="$(swift build --disable-sandbox --configuration "$BUILD_CONFIGURATION" --show-bin-path)"
BINARY_PATH="$BIN_DIR/$EXECUTABLE_NAME"

if [[ ! -x "$BINARY_PATH" ]]; then
  echo "Could not find built viewer executable:"
  echo "$BINARY_PATH"
  exit 1
fi

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BINARY_PATH" "$APP_BUNDLE/Contents/MacOS/$EXECUTABLE_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$EXECUTABLE_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>local.orbitalviewkit.vu-kit</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.developer-tools</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

echo "Built $APP_BUNDLE"
