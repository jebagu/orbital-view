# Task 010: Renderer Invariant Tests

## Status

```text
complete
```

## Goal

Add renderer invariant tests that prove meter and camera updates do not change static speaker draw inputs.

## Scope

Implemented:

- Internal draw-input snapshot structs for `OrbitalViewRender` tests.
- Stable static speaker draw input fields: speaker ID, physical channel, projected position, and quad radius.
- Tests proving meter-only updates do not change static speaker draw inputs.
- Tests proving camera-only updates do not change static speaker draw inputs.
- Tests proving draw inputs preserve speaker ID/channel order and stable dimensions.
- Active docs and work-package status updated.

Out of scope:

- Production camera projection.
- Shell rendering.
- Static Metal buffer caching or rebuild counters.
- Pixel-probe tests.
- SwiftUI gestures, controls, toolbar, or inspector UI.
- Downstream app integration.
- Audio, playback, routing, MIDI, OSC, or metering changes.

## Protected Path Check

This task explicitly permits:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
```

This task does not touch:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
downstream Wavefield, Orbisonic, or Splat source paths
audio, playback, routing, MIDI, OSC, or metering paths
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
