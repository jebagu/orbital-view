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

This is disposable HTML/CSS/JS with fake speaker positions and fake meter animation. It now mirrors DomeLab's 3D Model control panel on the left side of the viewport, grouped under Camera, Color, Speaker Shape, and View Detail headings. The shell structure is generated as a Fey 3V class-I icosahedron geodesic from the DomeLab project config values in `fey sphere - domelab-configuration.json`, normalized to the viewport sphere. Purple, Flamingo, Green, and B&W color palettes theme the full mockup surface, with Purple as the default. Projection is always axonometric, speaker numbers and hidden lines use switch controls defaulted off, speaker size is centered at 1.95x with half/double range mapping, fog density remaps the prior 30-density look to the slider midpoint, and prism mode is the default shape using true 8-vertex rectangular-prism speaker cabinets with hidden-line face clipping. It is not production renderer source.

### Sonicsphere Cube VU Single-Screen Mockup

Purpose:

```text
Preview a cube-only low-resolution center-bloom scalar VU style with all variants and controls visible in one browser viewport.
```

Implementation locations:

```text
mockups/sonicsphere-cube-vu-single-screen/index.html
mockups/sonicsphere-cube-vu-single-screen/notes.md
OrbitalViewKit -> mockups/sonicsphere-cube-vu-single-screen
```

Local server URL:

```text
http://127.0.0.1:8765/OrbitalViewKit/
```

This is a disposable imported HTML/CSS/JS mockup. It uses a fixed 1512 x 850 CSS-pixel artboard that scales uniformly to the viewport, keeps body scrolling disabled, and lays out a normal Music Meter above four cube VU variants on the left with a tabbed tuning rail on the right. The Tune tab keeps live audio, one Cube VU scalar, palette, and surface controls readable; the Impulse tab holds artificial Drop/Repeat testing; the Advanced tab holds custom palette JSON and implementation export. It includes an exclusive VU drive toggle: Music mode uses tab-audio capture through `getDisplayMedia` or local MP3/M4A/WAV playback through the page's `<audio>` element, while Impulse Test mode stops browser audio capture/playback and enables only artificial impulses. Web Audio analysis shows RMS/peak/bass, but the cube `vuScalar` is exactly the RMS percent and drives four center-bloom cube-face variants in Music mode. The mockup keeps CPU cost down by using one large cube per panel, cached tile geometry, a 9 x 9 default face grid, capped canvas DPR, down-sampled meter drawing, and a 24 fps render throttle. This mockup audio path is not production renderer source and does not change the Swift package contract.

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

The current renderer stores scene, meter, meter visual settings, camera, and selection state separately, exposes an `MTKViewDelegate` path, and includes a minimal Metal draw pipeline verified by offscreen smoke testing. Full production visuals, animation, hit testing, and broad SwiftUI controls are deferred.

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

The current wrapper provides `OrbitalView`, an `NSViewRepresentable` bridge, optional bottom VU settings tray, and coordinator tests. SwiftUI gestures, toolbar controls, and inspector UI are deferred.

### VU Meter Visual Settings And Tray

Purpose:

```text
Pass display-only meter gain/style through core, renderer, and SwiftUI without touching audio behavior.
```

Implementation locations:

```text
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewCoreTests/
Tests/OrbitalViewRenderTests/
Tests/OrbitalViewSwiftUITests/
```

The current implementation maps each scene speaker to `SpeakerMeterFrame.levelsByChannel` by physical channel, applies the default checker pulse/ring/diagonal wave color transform to every speaker, keeps Kimi Purple as the default color scheme, and preserves stable static speaker geometry. The SwiftUI tray is opt-in and collapsed by default with controls for visual gain, style, color scheme, ring/front density, band softness, tile detail, idle tint, memory, band velocity, and band width.

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
renderer 30-channel VU mapping, checker color-scheme settings, and visual settings revisions -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
SwiftUI wrapper configuration and coordinator behavior -> Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
SwiftUI VU settings tray opt-in and settings-only coordinator updates -> Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
renderer test harness plan -> docs/renderer-test-harness.md
visual mockup inline script syntax -> node parse command in .tasks/004-orbital-viewport-visual-mockup.md
renderer backend decision -> docs/decisions/0002-renderer-backend.md
```

## Last Updated

2026-05-20 Center-bloom cube VU mockup
