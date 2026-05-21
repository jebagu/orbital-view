# Start Here

Orbital View Kit starts as a docs-first project-control repository.

## First Read

```text
README.md
AGENTS.md
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/status.md
work-packages/orbital-view-kit/MV.md
```

## Current Goal

Prepare the next bounded slice after the `OrbitalViewCore` foundation, local Wavefield layout/meter adapters, first viewport visual mockup, renderer backend decision, initial `OrbitalViewRender` seam, `OrbitalViewSwiftUI` wrapper, renderer test harness plan, offscreen renderer smoke test, renderer invariant tests, checker VU meter plumbing/settings tray, required native control surface, and imported Fey geodesic shell node anchoring.

The current core already establishes pure Swift contracts and tests for:

- coordinate systems
- vectors and unit-sphere directions
- shell geometry
- physical speaker identity and anchors
- meter frames by channel
- display-only checker VU visual settings
- viewport display settings for speaker shape, speaker size, fog, speaker numbers, and hidden lines
- imported Fey geodesic shell generation and nearest-node speaker anchoring
- center-locked camera presets
- scene validation

The current Wavefield bridge already maps the Fey 30 speaker-layout JSON shape and Wavefield-style channel/rms/peak meter records into `OrbitalViewCore`. By default it uses the imported Fey 3V geodesic shell and anchors speakers to shell nodes while preserving channel order.

Normal native kit use includes the `OrbitalView` control surface:

```text
Plan / Elevation / Isometric / Export PNG / speaker shape / speaker size / speaker numbers / hidden lines / fog
```

The current mockup previews the intended center-locked spherical monitor viewport at:

```text
mockups/orbital-view-viewport/index.html
```

The root launcher opens the native Orbital View VU Kit app:

```text
Open Orbital View VU Kit.command
```

The accepted production renderer backend is documented at:

```text
docs/decisions/0002-renderer-backend.md
```

The current renderer seam is:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

The renderer test harness plan is:

```text
docs/renderer-test-harness.md
```

The current renderer smoke test is:

```text
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

The current renderer invariant tests are in the same file and cover static draw-input stability across meter, meter visual setting, and camera updates.

## Do Not Start With

- full production rendering
- WebView or DomeLab code import
- Wavefield app tab changes
- MIDI, OSC, playback, output routing, or audio rendering changes
- Splat editing tools

## Recommended Next Prompt

Create a new bounded task before implementing any renderer, SwiftUI, or downstream app integration work. Good next candidates:

```text
Production shell/hidden-line/fog drawing
PNG snapshot capture
Production checker facet animation/materials
SwiftUI gesture binding plan
Pixel-probe renderer tests
Renderer static buffer/cache plan
```
