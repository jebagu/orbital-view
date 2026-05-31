#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h}"
PRIMARY_APP_DIR="$PROJECT_DIR/Orbital View.app"
LEGACY_APP_DIR="$PROJECT_DIR/Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app"

if [[ -d "$PRIMARY_APP_DIR/Contents" ]]; then
  APP_DIR="$PRIMARY_APP_DIR"
else
  APP_DIR="$LEGACY_APP_DIR"
fi

APP_BINARY="$APP_DIR/Contents/MacOS/OrbitalViewViewer"
APP_RESOURCES="$APP_DIR/Contents/Resources"
APP_ICON_SOURCE="$PROJECT_DIR/dist/app-logo/AppIcon.icns"
APP_ICON_DEST="$APP_RESOURCES/AppIcon.icns"
APP_PLIST="$APP_DIR/Contents/Info.plist"

cd "$PROJECT_DIR"

if [[ ! -d "$APP_DIR/Contents" ]]; then
  echo "Orbital View launcher could not find the review app bundle:"
  echo "$APP_DIR"
  exit 1
fi

echo "Building latest OrbitalViewViewer..."
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --product OrbitalViewViewer

BIN_DIR="$(DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --show-bin-path)"
BUILD_BINARY="$BIN_DIR/OrbitalViewViewer"
BUILD_REVIEW_BUNDLE=""

for candidate in "$BIN_DIR/OrbitalView_OrbitalViewReview.bundle" "$BIN_DIR/OrbitalViewKit_OrbitalViewReview.bundle"; do
  if [[ -d "$candidate" ]]; then
    BUILD_REVIEW_BUNDLE="$candidate"
    break
  fi
done

if [[ ! -x "$BUILD_BINARY" ]]; then
  echo "Orbital View launcher could not find built executable:"
  echo "$BUILD_BINARY"
  exit 1
fi

if [[ -z "$BUILD_REVIEW_BUNDLE" ]]; then
  echo "Orbital View launcher could not find built review resources in:"
  echo "$BIN_DIR"
  exit 1
fi

mkdir -p "$APP_DIR/Contents/MacOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"

rm -rf "$APP_RESOURCES/OrbitalView_OrbitalViewReview.bundle"
rm -rf "$APP_RESOURCES/OrbitalViewKit_OrbitalViewReview.bundle"
cp -R "$BUILD_REVIEW_BUNDLE" "$APP_RESOURCES/$(basename "$BUILD_REVIEW_BUNDLE")"

if [[ -d "$APP_RESOURCES/OrbitalViewKit_OrbitalViewSwiftUI.bundle" ]]; then
  rm -rf "$APP_RESOURCES/OrbitalViewKit_OrbitalViewSwiftUI.bundle"
fi

if [[ -f "$APP_ICON_SOURCE" ]]; then
  cp "$APP_ICON_SOURCE" "$APP_ICON_DEST"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "$APP_PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$APP_PLIST"
else
  echo "Orbital View launcher warning: app icon source is missing:"
  echo "$APP_ICON_SOURCE"
fi

/usr/libexec/PlistBuddy -c "Set :CFBundleName Orbital View 1.0" "$APP_PLIST" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :CFBundleName string Orbital View 1.0" "$APP_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName Orbital View 1.0" "$APP_PLIST" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string Orbital View 1.0" "$APP_PLIST"
touch "$APP_DIR"

codesign --force --deep --sign - "$APP_DIR"

echo "Opening latest Orbital View review app..."
echo "$APP_DIR"

pkill -f OrbitalViewViewer 2>/dev/null || true

open -n "$APP_DIR"
