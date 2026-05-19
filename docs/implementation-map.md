# Implementation Map

## Purpose

This file maps project behavior to files and folders so the current system can be understood without reading every document.

## Top-Level Structure

```text
docs/                         Active project documentation
.tasks/                       Bounded Codex execution tasks
work-packages/orbital-view-kit/ Initial OrbitalViewKit work package
openspec/                     Behavioral change/spec templates
mockups/                      Disposable visual mockups
.agents/skills/               Local project skills
.codex/agents/                Local reviewer agent configs
reviewers/                    Human-readable review checklists
prompts/                      Reusable project prompts
```

Swift source directories are now present for `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewRender`, and `OrbitalViewSwiftUI`.

## Feature Map

### OrbitalViewCore Foundation

Purpose:

```text
Pure data contracts and validation for spherical speaker viewport scenes.
```

Implementation locations:

```text
Package.swift
Sources/OrbitalViewCore/
Tests/OrbitalViewCoreTests/
```

Related docs:

```text
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
.tasks/001-orbital-view-core-foundation.md
```

### Wavefield Adapters

Purpose:

```text
Convert Wavefield speaker-layout JSON and Wavefield-style meter records into OrbitalViewCore contracts.
```

Implementation locations:

```text
Sources/OrbitalViewWavefield/
Tests/OrbitalViewWavefieldTests/
```

The current adapter reads speaker-layout JSON and local channel/rms/peak meter DTOs. Direct Wavefield package type integration is not implemented.

### Orbital Viewport Visual Mockup

Purpose:

```text
Preview the intended spherical monitor viewport interaction before native renderer work.
```

Implementation locations:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
```

This is disposable HTML/CSS/JS with fake speaker positions and fake meter animation. It now mirrors DomeLab's 3D Model control panel on the left side of the viewport, grouped under Camera, Color, Speaker Shape, and View Detail headings. Color palettes theme the full mockup surface, projection is always axonometric, speaker numbers and hidden lines use switch controls, fog fades hidden shell lines and speaker faces consistently, and prism mode uses true 8-vertex rectangular-prism speaker cabinets with hidden-line face clipping. It is not production renderer source.

### OrbitalViewRender Seam

Purpose:

```text
Provide the initial MetalKit renderer seam for validated OrbitalViewCore scenes.
```

Accepted backend:

```text
MetalKit / MTKView custom renderer, wrapped by SwiftUI above it.
```

Implementation locations:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
```

Decision record:

```text
docs/decisions/0002-renderer-backend.md
```

The current renderer stores scene, meter, camera, and selection state separately, exposes an `MTKViewDelegate` path, and includes a minimal Metal draw pipeline verified by offscreen smoke testing. Full production visuals, hit testing, and SwiftUI controls are deferred.

### OrbitalViewSwiftUI Wrapper Skeleton

Purpose:

```text
Expose OrbitalViewRender through host-app SwiftUI bindings.
```

Implementation locations:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

The current wrapper provides `OrbitalView`, an `NSViewRepresentable` bridge, and coordinator tests. SwiftUI controls, gestures, and inspector UI are deferred.

### Renderer Test Harness Plan

Purpose:

```text
Define how the first Metal draw-loop work will be verified before drawing behavior is added.
```

Implementation locations:

```text
docs/renderer-test-harness.md
```

The plan defines contract tests, offscreen renderer smoke tests, renderer invariant checks, targeted pixel probes, and optional interactive harness constraints.

### Offscreen Renderer Smoke Test

Purpose:

```text
Prove OrbitalViewRender can issue Metal draw commands and produce non-empty output without a host app window.
```

Implementation locations:

```text
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewRender/OrbitalViewMetalRenderer.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

The current draw path renders fixed-size speaker quads from scene speaker anchors. Meter values affect color and intensity only, preserving the rule that VU behavior must not resize speaker geometry.

### Renderer Invariant Tests

Purpose:

```text
Lock down renderer draw-input invariants before expanding production visuals.
```

Implementation locations:

```text
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

The current invariant tests compare static speaker draw inputs across meter-only and camera-only updates. Static inputs include speaker ID, physical channel, projected position, and quad radius.

## Test Map

```text
unit direction validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
speaker validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
shell reference validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
meter channel identity -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
camera center-lock presets -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Wavefield JSON layout adaptation -> Tests/OrbitalViewWavefieldTests/WavefieldSpeakerLayoutSceneAdapterTests.swift
Wavefield meter-frame adaptation -> Tests/OrbitalViewWavefieldTests/WavefieldMeterFrameAdapterTests.swift
renderer seam state separation and events -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
offscreen renderer smoke output -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
renderer static draw-input invariants -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
SwiftUI wrapper configuration and coordinator behavior -> Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
renderer test harness plan -> docs/renderer-test-harness.md
visual mockup inline script syntax -> node parse command in .tasks/004-orbital-viewport-visual-mockup.md
renderer backend decision -> docs/decisions/0002-renderer-backend.md
```

## Last Updated

2026-05-19 Mockup grouped controls and fog parity
