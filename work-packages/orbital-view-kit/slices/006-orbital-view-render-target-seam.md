# Slice 006: OrbitalViewRender Target Seam

## Status

```text
complete
```

## Goal

Create the first native renderer source seam after the MetalKit backend decision.

## Scope

Do:

- Add `OrbitalViewRender` as a Swift package product and target.
- Depend on `OrbitalViewCore`.
- Import MetalKit only inside the renderer target.
- Provide a small renderer protocol and Metal renderer shell.
- Keep scene, meter, camera, and selection updates separate.
- Add compile-focused tests for the seam.

Do not:

- write SwiftUI wrapper source
- write Metal shaders
- implement draw commands, glow, bloom, materials, hit testing, or picking
- touch Wavefield, Orbisonic, or Splat source
- touch audio, playback, routing, MIDI, OSC, or metering paths

## Protected Path Check

This slice:

```text
allows Sources/OrbitalViewRender/
does not allow downstream protected paths
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
