#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h}"
MOCKUP_PATH="$PROJECT_DIR/mockups/orbital-view-viewport/index.html"

if [[ ! -f "$MOCKUP_PATH" ]]; then
  echo "Orbital View Kit launcher could not find:"
  echo "$MOCKUP_PATH"
  exit 1
fi

escaped_path="${MOCKUP_PATH// /%20}"
cache_buster="$(date +%s)"

echo "Opening live Orbital View Kit mockup..."
echo "$MOCKUP_PATH"

open "file://$escaped_path?v=$cache_buster"
