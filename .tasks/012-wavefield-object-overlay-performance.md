# Task 012: Wavefield Object Overlay Performance Slice

## Status

```text
complete
```

## Goal

Add Wavefield-style source-object overlay contracts and renderer plumbing while preserving the existing viewport control panel and VU-kit merge path.

## Scope

Implement:

- Pure core contracts for active object frames, object meter frames, object visual settings, trails, glow trails, and fixed `-5...+5` render/effect bounds.
- Renderer state and draw-input plumbing for object cores and capped trail samples.
- Retained Metal buffer storage so repeated draws can reuse existing buffers instead of allocating every frame.
- SwiftUI forwarding for object frames, object meters, and object visual settings without owning object animation state in SwiftUI.
- Disposable mockup controls added below the existing View Detail controls in the same left control rail.
- Documentation and tests for the new contracts, renderer invariants, UI forwarding, and mockup controls.

Do not:

- Change downstream Wavefield, Orbisonic, or Splat source.
- Parse `.wfield` files, receive OSC, parse MIDI, or own audio timing.
- Change speaker channel identity or speaker VU behavior.
- Replace, rename, or redesign the existing viewport control panel.
- Add a right-side object control panel.
- Add post-process bloom.
- Add new dependencies.

## Protected Path Check

This task explicitly permits:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

This task does not permit:

```text
downstream app source paths
audio, playback, routing, MIDI, OSC, or metering paths
```

## Verification

```text
node inline JavaScript parse for mockups
node object-control mockup assertions
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```
