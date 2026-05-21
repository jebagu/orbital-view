# Task 015: Native VU Interaction And Fog Regression

## Status

```text
in progress
```

## Goal

Fix the remaining standalone native `Orbital View VU Kit` interaction regressions while preserving the approved Orbisonic-native visual direction.

## Scope

Implement:

- Hard-off fog behavior at fog level `0`.
- Screen-horizontal spin/orbit behavior for Plan, Elevation, and Isometric views.
- Native single-track Orbisonic slider rows without visible numeric values.
- Right-aligned switch rows for boolean controls.
- Desktop PNG export with visible success/failure feedback.

Update:

- SwiftUI tests for the native control/fog/orbit/export contract.
- Project docs and bug/status records.

## Out of Scope

Do not:

- Change Wavefield, Orbisonic, Splat, audio, playback, routing, MIDI, OSC, or output behavior.
- Replace the production MetalKit renderer backend.
- Add a WebView or browser dependency.
- Treat the standalone fake meter stream as production meter input.

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
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
docs/protected-paths.md
docs/bugs.md
```

## Acceptance Criteria

- Fog level `0` leaves the model fully visible and unfogged in SceneKit and fallback Canvas paths.
- Hidden Lines are independent of fog density.
- Plan, Elevation, and Isometric spin horizontally without flattening, downward movement, or diagonal drift.
- Drag starts from stable pose state and does not jump on mouse-up.
- Speaker Size and Fog Density sliders show one native SwiftUI-drawn track and no numeric value.
- Speaker Numbers and Hidden Lines switches are right-justified and aligned.
- Export PNG saves to Desktop and shows visible completion/failure feedback.

## Verification Commands

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist
open -n Orbital\ View\ VU\ Kit.app
```
