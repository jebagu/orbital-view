#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h}"

"$PROJECT_DIR/scripts/build-orbital-viewer-app.sh"

open -n "$PROJECT_DIR/Orbital View Viewer.app"
