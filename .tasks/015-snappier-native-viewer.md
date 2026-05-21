# Task 015: Snappier Native Viewer

## Status

```text
complete
```

## Goal

Make the native SwiftUI/SceneKit Orbital View VU Kit review app feel snappier without changing its approved UI, visual direction, public package API, browser mockups, or production Metal renderer seam.

## Scope

Implement:

- Remove the root `TimelineView(.animation)` driver from `OrbitalViewportMockup`.
- Keep SwiftUI layout mostly static and refresh the inspector/meter list at a capped 10 fps.
- Scope the 10 fps inspector/meter-list timer to the inspector subtree.
- Move fake meter and spin animation into the SceneKit coordinator, with a capped 30 fps active-motion path and a 10 fps meter-only idle path.
- Set the SceneKit view to draw on demand instead of continuous 60 fps rendering.
- Request immediate SceneKit redraws for drag, scroll, click, camera, control, and selection updates.
- Disable implicit SceneKit actions for per-frame camera/material updates.
- Add cache keys so shell/material/speaker updates only run when their relevant inputs change.
- Build the local app bundle from a release binary by default for responsiveness review.
- Add tests for cadence constants, no root animation timeline, cache key behavior, and geometry rebuild boundaries.
- Update status and test strategy docs.

Do not:

- Redesign the UI.
- Change public package API.
- Touch browser mockups.
- Touch `OrbitalViewRender` unless required for a compile fix.
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
Implemented. Build and tests pass. The rebuilt release Orbital View VU Kit.app was launched and verified with Computer Use.
```
