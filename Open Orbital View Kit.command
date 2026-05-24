#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h}"
APP_DIR="$PROJECT_DIR/Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app"
APP_BINARY="$APP_DIR/Contents/MacOS/OrbitalViewViewer"
APP_RESOURCES="$APP_DIR/Contents/Resources"

cd "$PROJECT_DIR"

if [[ ! -d "$APP_DIR/Contents" ]]; then
  echo "Orbital View Kit launcher could not find the review app bundle:"
  echo "$APP_DIR"
  exit 1
fi

echo "Building latest OrbitalViewViewer..."
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --product OrbitalViewViewer

BIN_DIR="$(DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --show-bin-path)"
BUILD_BINARY="$BIN_DIR/OrbitalViewViewer"
BUILD_REVIEW_BUNDLE="$BIN_DIR/OrbitalViewKit_OrbitalViewReview.bundle"

if [[ ! -x "$BUILD_BINARY" ]]; then
  echo "Orbital View Kit launcher could not find built executable:"
  echo "$BUILD_BINARY"
  exit 1
fi

if [[ ! -d "$BUILD_REVIEW_BUNDLE" ]]; then
  echo "Orbital View Kit launcher could not find built review resources:"
  echo "$BUILD_REVIEW_BUNDLE"
  exit 1
fi

mkdir -p "$APP_DIR/Contents/MacOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"

rm -rf "$APP_RESOURCES/OrbitalViewKit_OrbitalViewReview.bundle"
cp -R "$BUILD_REVIEW_BUNDLE" "$APP_RESOURCES/OrbitalViewKit_OrbitalViewReview.bundle"

if [[ -d "$APP_RESOURCES/OrbitalViewKit_OrbitalViewSwiftUI.bundle" ]]; then
  rm -rf "$APP_RESOURCES/OrbitalViewKit_OrbitalViewSwiftUI.bundle"
fi

echo "Opening latest Orbital View Kit review app..."
echo "$APP_DIR"

pkill -f OrbitalViewViewer 2>/dev/null || true

open "$APP_DIR"
