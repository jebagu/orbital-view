# ChatGPT Pro Architecture Brief: Orbital View Kit

## What This Project Is

Orbital View Kit is a reusable Apple-native 3D visualization module for Sonic Sphere-style spatial audio systems. It is intended to become a drop-in viewport for Wavefield, Orbisonic, and Splat standalone.

The viewport should render a physical spherical speaker shell, live per-speaker VU activity, and future moving spatial objects in a foggy, beautiful, high-performance 3D environment. The production target is not a generic 3D scene. It should feel like the best current browser mockup: immediate controls, strong depth, prism/glass speaker shapes, atmospheric fog, high contrast, hidden rear-geometry suppression, smooth orbit and zoom, and a visually polished monitor surface.

The performance goal is ideally locked 60 FPS.

## Current State

The repository currently contains a Swift package named `OrbitalViewKit` with these implemented targets:

```text
OrbitalViewCore
  Pure data contracts, validation, coordinate system, scene, shell, speaker,
  meter, camera, and selection types.

OrbitalViewWavefield
  Local adapters from Wavefield-style speaker-layout JSON and meter records
  into OrbitalViewCore contracts.

OrbitalViewRender
  MetalKit / MTKView renderer seam with a minimal offscreen smoke-tested draw path.

OrbitalViewSwiftUI
  Compile-only SwiftUI wrapper skeleton around the Metal renderer seam.
```

The current renderer is intentionally minimal. It can issue a Metal draw command and pass offscreen smoke/invariant tests, but it does not yet implement production shell rendering, camera projection, fog, bloom, glass/prism materials, labels, hit testing, moving objects, or full SwiftUI controls.

There is also a disposable browser mockup in `mockups/orbital-view-viewport/`. That mockup is not production code, but it is a critical visual reference. It captures the desired feel: fast direct manipulation, strong fog/depth, prism speakers, high-contrast palettes, hidden-line behavior, and a left control surface. The native renderer should preserve that design discipline while using a production Metal architecture.

## Product Goals

Orbital View Kit should support:

- Physical Sonic Sphere-style arrays with 30 speakers now.
- A likely 52-speaker physical configuration later.
- Stable 3D speaker objects whose positions and channel identities are preserved exactly.
- Live animated VU state on every speaker.
- Up to 128 moving objects for sources, virtual speakers, renderer-kernel visualization, Splat authoring, trails, gain overlays, or diagnostics.
- A foggy, stylized, high-depth visual world that feels beautiful and responsive.
- A drop-in integration model for Wavefield, Orbisonic, and Splat standalone.

Speaker VU animation must not resize speaker geometry. RMS, peak, and clip state should appear through shader-driven material, color, glow, ring, and bloom effects.

Moving objects must animate smoothly in the same fog/depth environment without making the UI feel heavy.

## Hard Constraints

`OrbitalViewCore` must stay pure and renderer-independent. It should not depend on SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, routing, or downstream app targets.

The viewport consumes host-provided scene and meter data. It must not own audio callbacks, audio timing, playback, routing, MIDI, OSC, channel ordering, or downmix behavior.

Physical speaker channel identity must be preserved. Do not reorder, truncate, fake, or remap physical channels unless an explicit host adapter contract says to do so.

SwiftUI should wrap and control the renderer, but should not participate in the frame hot path.

The production renderer direction currently favored by the repo is custom MetalKit / MTKView.

## Desired Production Architecture Direction

The likely production architecture is:

```text
Host app
  -> host-owned layout, meter, object, camera, and selection state
  -> OrbitalViewSwiftUI wrapper
  -> OrbitalViewRender MetalKit renderer
  -> OrbitalViewCore contracts
```

The renderer should probably use:

- Static GPU buffers for shell geometry, struts, nodes, speaker bodies, and stable speaker identity.
- Small dynamic per-frame buffers for speaker VU state.
- Small dynamic per-frame buffers for up to 128 moving object transforms and visual state.
- GPU shaders for depth fog, prism/glass material response, VU glow, ring intensity, and clip accents.
- A controlled post-processing path for bloom/glow rather than many expensive scene objects.
- A frame loop designed around a 16.67 ms budget.

The CPU-side hot path should be small: update camera uniforms, speaker VU instance data, moving-object instance data, and render settings. Static geometry should not rebuild for meter-only updates.

## What We Want ChatGPT Pro To Brainstorm

Please propose the best production architecture for making this beautiful, atmospheric, and high performance at ideally locked 60 FPS.

Focus on:

- Metal render-pass design.
- Static versus dynamic buffer strategy.
- Scene/object model for 30 or 52 speakers plus up to 128 moving objects.
- Per-speaker VU animation model for RMS, peak, clip, glow, ring, material intensity, and bloom.
- Fog, depth fade, hidden rear-geometry suppression, prism/glass material, and bloom strategy.
- Camera/orbit/zoom interaction model that feels as immediate as the browser mockup.
- SwiftUI/AppKit boundary so UI controls remain ergonomic without entering the render hot path.
- Data flow from Wavefield, Orbisonic, and Splat into shared `OrbitalViewCore` contracts.
- Testing strategy for pixel probes, frame timing, buffer rebuild invariants, and regression coverage.
- Migration path from the current scaffold to a production renderer without breaking the existing module boundaries.

Please assume visual quality and interaction feel are first-class requirements, not decoration. The goal is a renderer that looks exceptional and stays fast.

## Current Files To Read First

Recommended order:

```text
README.md
START_HERE.md
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
docs/renderer-test-harness.md
docs/decisions/0002-renderer-backend.md
Package.swift
Sources/OrbitalViewCore/
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
```
