# Task 016: Native Export And Depth Tuning

## Status

```text
complete
```

## Goal

Polish the standalone SwiftUI/SceneKit Orbital View VU Kit review app by exporting the full visible app window and tuning speaker labels, shell struts, and rear-depth fog/material balance.

## Scope

Implement:

- Change Export PNG to capture the full application window as visible, including the dark UI background and rails.
- Avoid transparent viewport-only PNG export for the native review app.
- Make 3D speaker number labels visually larger and tie their font contract to the left-rail control-button size.
- Make shell struts and node markers 1.5x thicker.
- Diagnose and rebalance rear-depth visuals so rear speakers are more fog/material attenuated while rear shell struts remain faintly visible.
- Add tests for export scope, label/strut tuning constants, and depth-balance behavior.
- Update status, test strategy, protected-path, implementation-map, and MV docs.

Do not:

- Redesign the UI.
- Change public package API.
- Touch browser mockups.
- Touch `OrbitalViewRender`.
- Add dependencies.
- Modify downstream Wavefield, Orbisonic, Splat, audio, routing, MIDI, OSC, or playback code.

## Protected Path Check

This task explicitly permits:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

This task does not permit:

```text
Sources/OrbitalViewRender/
downstream app source paths
audio, playback, routing, MIDI, OSC, or metering paths
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
zsh -n scripts/build-orbital-viewer-app.sh
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist
open -n Orbital\ View\ VU\ Kit.app
git diff --check
```

## Result

```text
Implemented. Export now captures the app window, speaker labels and shell struts are larger, and rear-depth material/fog balance keeps back speakers more subdued while preserving faint rear shell structure.
```
