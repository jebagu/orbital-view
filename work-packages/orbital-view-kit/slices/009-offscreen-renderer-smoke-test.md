# Slice 009: Offscreen Renderer Smoke Test

## Status

```text
complete
```

## Goal

Add the smallest real Metal renderer path and prove it can produce non-empty offscreen output.

## Scope

Do:

- Add a minimal Metal draw pipeline inside `OrbitalViewRender`.
- Render fixed-size speaker quads from validated scene speaker anchors.
- Apply meter level to color/intensity without changing speaker position or size.
- Add an offscreen BGRA texture readback helper for tests.
- Add a deterministic XCTest smoke test that asserts non-clear output.
- Skip the smoke test clearly when no Metal device exists.
- Update active docs and work-package state.

Do not:

- implement production camera projection
- render shell geometry
- implement labels, bloom, materials, hit testing, or picking
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
