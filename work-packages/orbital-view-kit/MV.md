# Work Package: Orbital View VU Kit Foundation

## Goal

Create the reusable foundation for `OrbitalViewKit`, a spherical speaker viewport shared by Wavefield, Orbisonic, and Splat.

## Current Tree

```text
codex/vu-meter-plumbing-tray branch
```

## Worktree Decision

```text
main tree
```

Reasoning:

```text
The completed slices are small enough for the main tree.
```

## Product Summary

OrbitalViewKit should eventually render a beautiful, center-locked, orbitable 3D Sonic Sphere-style viewport. Speakers remain physical objects while RMS, peak, and clip state appear through material, glow, rings, and bloom rather than geometry resizing.

## Architecture Summary

Start with `OrbitalViewCore`: pure Swift contracts and validation. The renderer now has an initial MetalKit seam, offscreen smoke-tested draw path, static draw-input invariant tests, and display-only checker pulse/ring/diagonal wave VU visual settings. Full production checker facet animation, broader SwiftUI controls, DomeLab import, Splat overlays, and downstream app adapters are later slices.

## Related OpenSpec Change

```text
none
```

## Renderer Backend Decision

```text
docs/decisions/0002-renderer-backend.md
```

Accepted direction:

```text
MetalKit / MTKView production renderer in OrbitalViewRender, with SwiftUI wrapper above it.
```

## Visual Mockups

```text
mockups/orbital-view-viewport/
```

## Protected Paths

Current protected source paths:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

Future downstream app integrations may touch protected audio, metering, routing, playback, or renderer paths and will require explicit task permission.

## Audio Constraints

- Do not own audio callbacks or timing behavior.
- Consume measured meter frames only.
- Do not fake, downmix, truncate, or reorder physical channel data.

## Performance Constraints

- Core validation should be deterministic and lightweight.
- Future renderer meter updates must avoid rebuilding static geometry every frame.

## Reliability Constraints

- Invalid geometry and speaker data must fail explicitly.
- Camera presets in monitor mode must target origin.
- Channel identity must be stable.

## Slices

### Slice 001: OrbitalViewCore Foundation

Status:

```text
complete
```

Goal:

```text
Create pure core Swift contracts and tests.
```

Agent:

```text
Codex
```

Depends on:

```text
project scaffold
```

Review required:

```text
normal, with architecture review useful if contracts drift
```

Protected path touch:

```text
no
```

### Slice 002: Wavefield Layout JSON Adapter

Status:

```text
complete
```

Goal:

```text
Map Wavefield speaker-layout JSON into OrbitalViewCore scenes.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 001
```

Review required:

```text
normal
```

Protected path touch:

```text
no
```

### Slice 003: Wavefield Meter Frame Adapter

Status:

```text
complete
```

Goal:

```text
Map Wavefield-style channel/rms/peak meter records into OrbitalViewCore SpeakerMeterFrame.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 001
```

Review required:

```text
normal
```

Protected path touch:

```text
no
```

### Slice 004: Orbital Viewport Visual Mockup

Status:

```text
complete
```

Goal:

```text
Preview viewport interaction, camera presets, selection, labels, cutaway, and fake meter glow before renderer implementation.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 001
```

Review required:

```text
normal
```

Protected path touch:

```text
no
```

### Slice 005: Renderer Backend Decision

Status:

```text
complete
```

Goal:

```text
Accept the production renderer backend before adding native renderer source.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 004
```

Review required:

```text
normal, with architecture review useful before first renderer source
```

Protected path touch:

```text
no
```

### Slice 006: OrbitalViewRender Target Seam

Status:

```text
complete
```

Goal:

```text
Create a minimal MetalKit renderer target seam without production drawing.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 005
```

Review required:

```text
normal, with architecture/performance review useful before draw-loop work
```

Protected path touch:

```text
Sources/OrbitalViewRender/ allowed by this slice
```

### Slice 007: OrbitalViewSwiftUI Wrapper Skeleton

Status:

```text
complete
```

Goal:

```text
Create a compile-only SwiftUI wrapper target above the MetalKit renderer seam.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 006
```

Review required:

```text
normal, with architecture review useful before gesture/control work
```

Protected path touch:

```text
Sources/OrbitalViewSwiftUI/ allowed by this slice
```

### Slice 008: Renderer Test Harness Plan

Status:

```text
complete
```

Goal:

```text
Define offscreen renderer smoke tests, invariant tests, and pixel-probe strategy before draw-loop implementation.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 007
```

Review required:

```text
normal, with architecture/performance review useful before first draw-loop code
```

Protected path touch:

```text
no
```

### Slice 009: Offscreen Renderer Smoke Test

Status:

```text
complete
```

Goal:

```text
Implement the smallest Metal draw path and verify non-empty offscreen renderer output.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 008
```

Review required:

```text
protected-path, architecture, performance, and reliability review useful before accepting broader renderer work
```

Protected path touch:

```text
Sources/OrbitalViewRender/ and Tests/OrbitalViewRenderTests/ allowed by this slice
```

### Slice 010: Renderer Invariant Tests

Status:

```text
complete
```

Goal:

```text
Verify static renderer draw inputs stay stable across meter-only and camera-only updates.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 009
```

Review required:

```text
protected-path, architecture, performance, and reliability review useful before accepting broader renderer work
```

Protected path touch:

```text
Sources/OrbitalViewRender/ and Tests/OrbitalViewRenderTests/ allowed by this slice
```

### Slice 011: VU Meter Plumbing And Settings Tray

Status:

```text
complete
```

Goal:

```text
Add display-only checker pulse/ring/diagonal wave VU meter visual settings, 30-channel renderer plumbing, and a SwiftUI collapsible settings tray.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 010
```

Review required:

```text
protected-path, architecture, performance, and reliability review useful before production animation work
```

Protected path touch:

```text
Sources/OrbitalViewRender/, Tests/OrbitalViewRenderTests/, Sources/OrbitalViewSwiftUI/, and Tests/OrbitalViewSwiftUITests/ allowed by this slice
```

## Bugs Found During Package

Link:

```text
docs/bugs.md
```

## Current Status

Slice 011 is complete. `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewRender`, and `OrbitalViewSwiftUI` exist with tests; the renderer test harness plan exists; the first offscreen Metal smoke test passes; renderer invariant tests prove static draw-input stability; checker pulse/ring/diagonal wave VU visual settings flow through renderer and optional SwiftUI tray state; the first viewport interaction mockup exists; and the production renderer backend is accepted as MetalKit / MTKView.

## Next Action

Open a new bounded task for production checker facet animation/materials, pixel-probe renderer tests, renderer static buffer/cache plan, or SwiftUI control/gesture binding plan.
