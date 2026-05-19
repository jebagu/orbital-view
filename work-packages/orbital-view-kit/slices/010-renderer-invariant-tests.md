# Slice 010: Renderer Invariant Tests

## Status

```text
complete
```

## Goal

Lock down renderer invariants around static speaker draw inputs before adding broader production visuals.

## Scope

Do:

- Add internal renderer draw-input snapshot values.
- Keep draw-input snapshots out of public host-app API.
- Verify meter-only updates leave static speaker geometry unchanged.
- Verify camera-only updates leave static speaker geometry unchanged.
- Verify speaker draw inputs preserve ID/channel order.
- Verify speaker quad dimensions remain stable under VU changes.
- Update active docs and work-package state.

Do not:

- add production camera projection
- add shell rendering
- add static Metal buffer caches or rebuild counters
- add pixel-probe tests
- add SwiftUI gestures or controls
- touch Wavefield, Orbisonic, or Splat source
- touch audio, playback, routing, MIDI, OSC, or metering paths

## Protected Path Check

This slice explicitly permits:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
```

This slice does not permit:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
downstream app source paths
audio, playback, routing, MIDI, OSC, or metering paths
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
