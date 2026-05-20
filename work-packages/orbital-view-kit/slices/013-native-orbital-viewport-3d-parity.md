# Slice 013: Native Orbital Viewport 3D Parity

## Status

```text
complete
```

## Goal

Create a native SwiftUI app screen that matches the actual browser viewport mockup while using native 3D geometry for the Fey shell and speakers.

## Scope

```text
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewViewer/
Tests/OrbitalViewSwiftUITests/
scripts/
root launcher
project docs
```

## Completed

- Added `OrbitalViewportMockup`, a SwiftUI screen with the browser mockup's control rail, 3D viewport, inspector, and footer geometry.
- Implemented the viewport as SceneKit-backed native 3D: Fey 30 prism/sphere speaker nodes, generated 3V geodesic shell, lighting, fog, hidden-line visibility, labels, selection, drag orbit, spin, wheel/magnification zoom, and PNG export.
- Changed the standalone executable to launch `Orbital View VU Kit` directly into this native 3D screen.
- Added `Open Native Orbital View VU Kit.command`.
- Updated focused SwiftUI tests for the viewport contract.

## Protected Paths

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

## Out of Scope

```text
Production Metal renderer replacement
Wavefield, Orbisonic, or Splat app integration
Audio callback, playback, routing, MIDI, or OSC changes
WebView/browser embedding
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=.build/clang-module-cache SWIFTPM_CACHE_DIR=.build/swiftpm-cache swift test --disable-sandbox --filter OrbitalViewSwiftUITests/testOrbitalViewport
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist
open -n Orbital\ View\ VU\ Kit.app
```

## Notes

The native app intentionally keeps the browser mockup's fake meter stream for visual parity. This does not change production meter-input contracts or host-app audio behavior.
