# Task 014: Native Orbisonic Control Skin And Camera Fog

## Status

```text
complete
```

## Goal

Refine the standalone native `Orbital View VU Kit` review app so every control follows the Orbisonic design language, while preserving a native SwiftUI/SceneKit 3D viewport.

## Scope

Implement:

- Orbisonic-design-language control styling for the standalone native viewport shell.
- Swift-native buttons, toggles, sliders, pickers, and segmented controls.
- Fixed left and right rails with a flexible centered SceneKit viewport.
- SceneKit camera orbit around static content.
- SceneKit camera-space fog with an explicit hard-off state at density `0`.
- Stable pan/spin behavior without mouse-up pose jumps.
- Desktop PNG export with in-app feedback.

Update:

- SwiftUI tests for the native control/fog/orbit contract.
- Project docs and status.

## Out of Scope

Do not:

- Add a WebView or browser dependency.
- Use browser styling as the native control skin.
- Replace the production MetalKit renderer backend.
- Change Wavefield, Orbisonic, Splat, audio, playback, routing, MIDI, or OSC behavior.
- Treat the standalone fake meter stream as production input.

## Protected Path Check

This task:

```text
does
```

touch protected paths.

Permitted protected paths:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

## Expected Files

```text
Sources/OrbitalViewSwiftUI/OrbitalViewportMockup.swift
Sources/OrbitalViewViewer/OrbitalViewViewer.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
docs/status.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
docs/protected-paths.md
docs/bugs.md
```

## Acceptance Criteria

- Standalone app uses Orbisonic-native control styling instead of web-styled chrome.
- Sliders use the native Orbisonic title/value + cyan-tinted SwiftUI slider row and no duplicate underline/track.
- Speaker Size and Fog Density sliders use a single native cyan track with no inline numeric value.
- Left and right panels stay fixed-width and flush to the window edges.
- Speaker meters fill inside fixed rows without resizing the right panel.
- Drag orbit is smooth and does not jump on mouse-up.
- Drag vertical direction and mouse wheel zoom direction match the requested native feel.
- Spin starts/stops without jumping, pauses during drag, and sweeps horizontally in screen space across Plan, Elevation, and Isometric presets.
- SceneKit fog is camera-space, no longer uses model-rotated manual alpha fading, and density `0` keeps the model fully visible.
- Hidden Lines remain independent of fog density.
- Speaker number and spin toggles visibly update the native viewport.
- Export PNG saves a timestamped image to Desktop and reports success or failure in the footer.

## Verification Commands

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist
open -n Orbital\ View\ VU\ Kit.app
```
