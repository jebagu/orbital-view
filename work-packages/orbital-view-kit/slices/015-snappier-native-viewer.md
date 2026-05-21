# Slice 015: Snappier Native Viewer

## Status

```text
complete
```

## Goal

Improve the responsiveness of the native SwiftUI/SceneKit Orbital View VU Kit review app while preserving the existing UI and visual look.

## Scope

Done when this slice:

- Removes the root SwiftUI animation timeline from `OrbitalViewportMockup`.
- Uses a 10 fps SwiftUI inspector/meter-list refresh cadence.
- Keeps the 10 fps SwiftUI inspector/meter-list timer scoped to the inspector subtree.
- Uses a 30 fps SceneKit active-motion cap for spin and a 10 fps meter-only idle cadence for fake meters.
- Keeps SceneKit draw-on-demand by default.
- Requests immediate viewport redraws for user input.
- Disables implicit SceneKit actions during per-frame updates.
- Caches shell, speaker geometry, speaker visibility, speaker material, camera, and fog update keys.
- Builds the local app bundle from a release binary by default.
- Proves meter-only ticks do not rebuild shell or speaker geometry.
- Keeps the UI, browser mockups, public package API, and production Metal renderer seam unchanged.

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
Implemented. The native viewer keeps the approved UI, moves animation work into the SceneKit coordinator, scopes inspector ticking to the inspector subview, and verifies cadence/cache behavior with focused SwiftUI tests.
```
