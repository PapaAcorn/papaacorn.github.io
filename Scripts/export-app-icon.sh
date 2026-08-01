#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT/.build/icon-export"
mkdir -p "$BUILD_DIR"

swiftc -o "$BUILD_DIR/ExportAppIcon" \
  "$ROOT/Scripts/ExportAppIcon.swift" \
  "$ROOT/Metricize/Views/Design/AppIconArtwork.swift" \
  -framework AppKit \
  -framework SwiftUI

"$BUILD_DIR/ExportAppIcon" "$ROOT"
