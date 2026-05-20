#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h}"
APP_PATH="$PROJECT_DIR/Orbital View VU Kit.app"
BUILD_SCRIPT="$PROJECT_DIR/scripts/build-orbital-viewer-app.sh"

"$BUILD_SCRIPT"

if [[ ! -d "$APP_PATH" ]]; then
  osascript -e 'display dialog "Build did not produce Orbital View VU Kit.app" with icon stop'
  exit 1
fi

open -n "$APP_PATH"
