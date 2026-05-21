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

OrbitalViewKit should eventually render a beautiful, center-locked, orbitable 3D Sonic Sphere-style viewport. Speakers remain physical objects while RMS, peak, and clip state appear through material, glow, rings, and bloom rather than geometry resizing. Wavefield source objects are overlaid as unit-sphere objects keyed by `objectId`, with separate object VU skin and capped trails.

## Architecture Summary

Start with `OrbitalViewCore`: pure Swift contracts and validation. The renderer now has an initial MetalKit seam, offscreen smoke-tested draw path, static draw-input invariant tests, display-only checker pulse/ring/diagonal wave VU visual settings, source-object overlay draw inputs, and retained buffer reuse. Full production checker facet animation, live object smoothing, broader SwiftUI controls, DomeLab import, Splat overlays, and downstream app adapters are later slices.

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
- Renderer meter/object/trail updates must avoid rebuilding static geometry every frame.
- SwiftUI must not own per-frame object position state.
- Metal buffers should be retained and reused when capacity is sufficient.

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

### Slice 012: Wavefield Object Overlay Performance Slice

Status:

```text
complete
```

Goal:

```text
Add Wavefield source-object frame, object meter, object visual settings, capped trail, retained renderer buffer, and mockup control contracts while preserving speaker VU behavior.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 011
```

Review required:

```text
protected-path, architecture, performance, and reliability review useful before production live smoothing work
```

Protected path touch:

```text
Sources/OrbitalViewRender/, Tests/OrbitalViewRenderTests/, Sources/OrbitalViewSwiftUI/, and Tests/OrbitalViewSwiftUITests/ allowed by this slice
```

### Slice 013: Native Orbital Viewport 3D Parity

Status:

```text
complete
```

Goal:

```text
Rebuild the standalone native app as a real SwiftUI/SceneKit 3D version of the browser viewport mockup with the same controls, layout roles, defaults, and fake meter stream.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 011
```

Review required:

```text
protected-path and visual/interaction review useful before downstream host integration
```

Protected path touch:

```text
Sources/OrbitalViewSwiftUI/ and Tests/OrbitalViewSwiftUITests/ allowed by this slice
```

### Slice 014: Native Orbisonic Control Skin And Camera Fog

Status:

```text
complete
```

Goal:

```text
Tighten the standalone SwiftUI/SceneKit review app around Orbisonic design-language controls, fixed rails, camera-orbit behavior, SceneKit fog, drag/zoom, speaker labels, and PNG export.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 013
```

Review required:

```text
protected-path and visual/interaction review useful before downstream host integration
```

Protected path touch:

```text
Sources/OrbitalViewSwiftUI/ and Tests/OrbitalViewSwiftUITests/ allowed by this slice
```

### Slice 015: Snappier Native Viewer

Status:

```text
complete
```

Goal:

```text
Make the approved standalone SwiftUI/SceneKit review app more responsive by removing the root SwiftUI animation clock, scoping the 10 fps SwiftUI inspector refresh to the inspector subview, moving fake meter/spin updates into the SceneKit coordinator with a 30 fps active-motion cap and 10 fps meter-only idle cadence, cache-keying SceneKit update work, and release-building the local review app bundle by default.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 014
```

Review required:

```text
performance and protected-path review useful before larger native/host integration work
```

Protected path touch:

```text
Sources/OrbitalViewSwiftUI/ and Tests/OrbitalViewSwiftUITests/ allowed by this slice
```

### Slice 016: Native Export And Depth Tuning

Status:

```text
complete
```

Goal:

```text
Polish the approved standalone SwiftUI/SceneKit review app by exporting the whole visible app window as PNG, increasing speaker label and shell strut readability, and rebalancing rear-depth fog/material visibility so rear speakers are more subdued while rear shell structure remains faintly visible.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 015
```

Review required:

```text
visual/interaction and protected-path review useful before larger native/host integration work
```

Protected path touch:

```text
Sources/OrbitalViewSwiftUI/ and Tests/OrbitalViewSwiftUITests/ allowed by this slice
```

### Slice 017: Adaptive 30/60 FPS Native Viewer

Status:

```text
complete
```

Goal:

```text
Add a 30/60 fps active-motion toggle to the approved standalone SwiftUI/SceneKit review app while keeping meter-only idle drawing and inspector refresh capped at 10 fps.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 016
```

Review required:

```text
performance and protected-path review useful before larger native/host integration work
```

Protected path touch:

```text
Sources/OrbitalViewSwiftUI/ and Tests/OrbitalViewSwiftUITests/ allowed by this slice
```

## Bugs Found During Package

Link:

```text
docs/bugs.md
```

## Current Status

Slice 017 is complete. `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewOrbisonic`, `OrbitalViewRender`, `OrbitalViewSwiftUI`, `OrbitalViewViewerSupport`, and `OrbitalViewViewer` exist with tests; the renderer test harness plan exists; the first offscreen Metal smoke test passes; renderer invariant tests prove static draw-input stability; checker pulse/ring/diagonal wave VU visual settings flow through renderer and optional SwiftUI tray state; Wavefield source-object frames/meters/settings flow through core, renderer, and SwiftUI; and the standalone native app now launches an Orbisonic-design-language SwiftUI/SceneKit 3D review screen with Fey 30 fake meter stream, camera orbit, native controls, SceneKit camera-space fog, no root SwiftUI animation timeline, inspector-only 10 fps refresh, selectable 30/60 fps SceneKit active-motion cap defaulting to 60 fps, 10 fps meter-only idle cadence, draw-on-demand SceneKit, cache-keyed SceneKit update work, full-window PNG export, larger speaker labels, 1.5x thicker shell struts, rear-depth speaker material attenuation, and a release-built local app bundle by default. The browser viewport mockup is only a loose behavior/control-inventory reference. The production renderer backend remains accepted as MetalKit / MTKView.

## Next Action

Open a new bounded task for production live object smoothing/interpolation, production checker facet animation/materials, pixel-probe renderer tests, lower-level native CPU profiling, or downstream Wavefield/Orbisonic host integration.
