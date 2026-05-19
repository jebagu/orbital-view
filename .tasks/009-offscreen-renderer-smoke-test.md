# Task 009: Offscreen Renderer Smoke Test

## Status

```text
complete
```

## Goal

Implement the first minimal Metal draw path and verify it with an offscreen renderer smoke test.

## Scope

Implemented:

- `OrbitalViewMetalDrawPipeline` for a small Metal render pipeline.
- `OrbitalViewMetalRenderer.draw(in:)` command encoding for `MTKView`.
- Internal offscreen render entry point for renderer tests.
- XCTest smoke coverage that renders a deterministic scene into a BGRA texture and asserts non-clear pixels.
- Clean XCTest skip when no Metal device is available.
- Active docs and work-package status updated.

Out of scope:

- Production camera projection.
- Shell rendering.
- Materials, bloom, labels, hit testing, or selection picking.
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
