#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h}"
PRODUCT_NAME="OrbitalViewVUKit"
DEBUG_BIN="$PROJECT_DIR/.build/debug/$PRODUCT_NAME"
RELEASE_BIN="$PROJECT_DIR/.build/release/$PRODUCT_NAME"

if [[ -x "$RELEASE_BIN" ]]; then
  BINARY="$RELEASE_BIN"
elif [[ -x "$DEBUG_BIN" ]]; then
  BINARY="$DEBUG_BIN"
else
  echo "Building Orbital View VU Kit..."
  cd "$PROJECT_DIR"
  swift build --product "$PRODUCT_NAME"
  BINARY="$DEBUG_BIN"
fi

echo "Launching Orbital View VU Kit: $BINARY"
exec "$BINARY"
