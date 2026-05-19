# Task 005: Renderer Backend Decision

## Status

```text
complete
```

## Goal

Decide the production renderer backend before adding native renderer source.

## Scope

Implemented:

- Accepted MetalKit / MTKView as the production renderer backend.
- Recorded SwiftUI as the wrapper layer, not the renderer core.
- Rejected WebView, DomeLab import, SceneKit-first, and RealityKit-first as long-term renderer paths.
- Updated active docs and work-package state.

Out of scope:

- Swift renderer source.
- SwiftUI wrapper source.
- Metal shader code.
- Downstream app integration.
- Audio, playback, routing, MIDI, OSC, or metering changes.

## Protected Path Check

This task:

```text
does not touch protected downstream paths or future renderer source paths
```

## Verification

```text
docs decision exists
manifest parses
swift build passes
swift test passes
```
