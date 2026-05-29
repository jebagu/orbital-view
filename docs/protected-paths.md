# Protected Paths

## Realtime Audio Family Standards Inheritance

This project inherits the Realtime Audio Family Standards Package. The Bencina Realtime Callback Doctrine is mandatory for every callback and every callback-reachable function. Project-specific requirements may add stricter rules but may not weaken the family standard.

Orbital View Kit currently fits the Control / UI / Telemetry Plane plus Preparation Plane adapters. It owns no Realtime Plane. Protected renderer and SwiftUI paths must remain display-rate code and must not become callback-reachable without an explicit future task, OpenSpec change, and specialty review.

## Current Scaffold

Current protected source paths:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewReview/
Tests/OrbitalViewSwiftUITests/
```

`OrbitalViewCore`, `OrbitalViewWavefield`, and `OrbitalViewSpatGRIS` source changes are governed by normal task scope and tests. `OrbitalViewSpatGRIS` may parse SpatGRIS XML and OSC payload bytes but must not open sockets or own UI. `OrbitalViewReview` is protected because it owns review-only local audio, SceneKit, file-dialog, SpatGRIS layout persistence, review-only OSC listening, PNG export, and app-bundle resource behavior that must not leak back into the production wrapper.

`OrbitalViewViewerSupport` may hold deterministic review and stress fixtures when an active task allows it. Stress fixture changes do not grant permission to edit protected renderer, SwiftUI, or review source paths unless the task explicitly names those paths.

The final realtime-family adoption audit is `docs/realtime-family-compliance-audit.md`. Updating that audit does not grant permission to edit protected renderer, SwiftUI, review, or downstream host paths.

## Protected Path: Downstream Audio And Routing Integrations

### Applies When

A future task edits Wavefield, Orbisonic, Splat, or another host app.

Orbisonic and Splat integration profiles are documentation-only until a future slice explicitly names a downstream repository and protected paths. This repository must not edit downstream host source as part of profile/specification slices.

### Examples

```text
Sources/WavefieldPlayback/
Sources/WavefieldRenderers/
Sources/WavefieldMetering/
Sources/WavefieldMIDI/
Sources/WavefieldOSC/
Sources/WavefieldOutput/
Sources/WavefieldSpeakerLayout/
```

Exact protected paths must be verified in the downstream repository before editing.

For Orbisonic, verify current playback, Core Audio device I/O, routing, channel mapping, output, render/control, meter extraction, tap-point, operator-state, and performance-gate paths before editing.

For Splat, verify current project/session, authoring/edit, renderer-kernel analysis, neutral geometry import/export, file format, persistence, and handoff paths before editing.

### Invariants

- Do not block timing-sensitive audio paths.
- Do not change playback state transitions without explicit approval.
- Do not change MIDI, OSC, rendering, routing, output, or metering semantics casually.
- Do not downmix, truncate, reorder, or fake channel data.
- Do not let UI own audio timing behavior.

### Allowed Changes

Only allowed when an active task or work-package slice explicitly permits that protected path.

### Review Required

```text
audio reviewer
performance reviewer
reliability reviewer
architecture reviewer
protected path reviewer
```

## Protected Path: Future Production Renderer

### Applies When

`OrbitalViewRender` or `OrbitalViewSwiftUI` exists.

Accepted backend:

```text
MetalKit / MTKView renderer with SwiftUI wrapper
```

### Invariants

- Meter updates must not rebuild static geometry every frame.
- Speaker geometry must not resize for VU behavior.
- Camera target must remain center-locked in monitor mode.
- Rendering must preserve physical speaker channel identity.
- Imported receiver speaker layouts may change review geometry and scene bounds, but must preserve SpatGRIS patch IDs as channel IDs.
- Review-only source markers must stay separate from receiver speaker nodes and must not rewrite receiver channel order.
- Renderer source must not own audio callbacks or host app meter timing.
- Renderer source changes are allowed only when the active task explicitly permits `Sources/OrbitalViewRender/`.
- SwiftUI wrapper changes are allowed only when the active task explicitly permits `Sources/OrbitalViewSwiftUI/`.
- Review source changes are allowed only when the active task explicitly permits `Sources/OrbitalViewReview/`, local review playback/export behavior, or the native review executable.
- Production host integrations must import `OrbitalViewSwiftUI`, not `OrbitalViewReview`, unless a future task explicitly opts into review/demo tooling.
- Visible UI or review-surface changes must verify against `docs/orbisonic-design-language.md` and the referenced Orbisonic design-language files before final review.

### Review Required

```text
performance reviewer
architecture reviewer
reliability reviewer
```
