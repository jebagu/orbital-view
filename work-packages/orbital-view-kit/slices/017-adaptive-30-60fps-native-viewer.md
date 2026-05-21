# Slice 017: Adaptive 30/60 FPS Native Viewer

## Status

```text
complete
```

## Goal

Add a 30/60 fps active-motion toggle to the approved standalone native SwiftUI/SceneKit review app while keeping the low-idle CPU guardrails from Slice 015.

## Scope

Done when this slice:

- Exposes a matching native control-rail 30/60 fps toggle for active viewport motion.
- Defaults active viewport motion to 60 fps.
- Keeps the meter-only idle viewport cadence at 10 fps.
- Keeps the inspector/meter-list SwiftUI cadence at 10 fps.
- Keeps SceneKit draw-on-demand by default.
- Keeps immediate drag, zoom, camera, control, and selection redraw requests.
- Keeps implicit SceneKit actions disabled during per-frame updates.
- Preserves the approved UI layout and visual language unchanged.
- Adds focused tests for the 30/60 active-motion toggle, 60 fps default, and unchanged idle/inspector guardrails.

Out of scope:

- UI redesign.
- Public API changes.
- Browser mockup edits.
- Production Metal renderer work.
- Downstream host, audio, routing, MIDI, OSC, or playback changes.

## Protected Path Check

This slice explicitly permits:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

This slice does not permit:

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
Implemented. The native app keeps the approved UI and low-idle behavior while allowing active viewport motion to switch between 30 and 60 fps.
```
