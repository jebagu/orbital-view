# Task 006: OrbitalViewRender Target Seam

## Status

```text
complete
```

## Goal

Add a minimal compile-focused `OrbitalViewRender` target that establishes the MetalKit renderer seam without implementing production drawing.

## Scope

Implemented:

- `OrbitalViewRender` package product and target.
- `OrbitalViewRendering` protocol for loading scenes, updating meters, updating camera, selection, and event draining.
- `OrbitalViewRenderState` with separate structural, meter, and camera revisions.
- `OrbitalViewMetalRenderer` that conforms to `MTKViewDelegate`.
- Tests proving scene and meter update paths stay separate, camera/selection emit events, and the renderer exposes an MTKView delegate seam.

Out of scope:

- SwiftUI wrapper.
- Real drawing commands.
- Metal shaders.
- Materials, glow, bloom, hit testing, or selection picking.
- Downstream app integration.
- Audio, playback, routing, MIDI, OSC, or metering changes.

## Protected Path Check

This task:

```text
touches Sources/OrbitalViewRender/ as explicitly permitted by this renderer seam task
does not touch downstream protected paths
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
