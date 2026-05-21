# Task 017: Adaptive 30/60 FPS Native Viewer

## Status

```text
complete
```

## Goal

Make the standalone SwiftUI/SceneKit Orbital View VU Kit review app feel smoother during active viewport motion by adding a 30/60 fps active-motion toggle while preserving low-idle CPU behavior.

## Scope

Implement:

- Add a native control-rail 30/60 fps toggle for active viewport motion.
- Default the native viewport active-motion cadence to 60 fps.
- Keep meter-only idle viewport drawing capped at 10 fps.
- Keep inspector/meter-list SwiftUI refresh capped at 10 fps.
- Keep SceneKit draw-on-demand behavior with `rendersContinuously = false` and `isPlaying = false`.
- Preserve immediate camera, zoom, drag, selection, and control updates.
- Keep implicit SceneKit actions disabled during per-frame updates.
- Update focused tests for the 30/60 active-motion toggle, 60 fps default, and unchanged idle/inspector guardrails.
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
Implemented. Active spin/viewport motion now uses a 30/60 fps SceneKit cadence toggle, defaulting to 60 fps, while meter-only idle drawing and inspector refresh remain capped at 10 fps.
```
