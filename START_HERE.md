# Start Here

Orbital View is the canonical head project for the native spherical speaker viewport.

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

Prepare the next bounded slice after the `OrbitalViewCore` foundation, local Wavefield layout/meter adapters, first viewport visual mockup, renderer backend decision, initial `OrbitalViewRender` seam, compile-only `OrbitalViewSwiftUI` wrapper skeleton, renderer test harness plan, offscreen renderer smoke test, and renderer invariant tests.

The current core already establishes pure Swift contracts and tests for:

- coordinate systems
- vectors and unit-sphere directions
- shell geometry
- physical speaker identity and anchors
- meter frames by channel
- center-locked camera presets
- scene validation

The current Wavefield bridge already maps the Fey 30 speaker-layout JSON shape and Wavefield-style channel/rms/peak meter records into `OrbitalViewCore`.

The current mockup previews the intended center-locked spherical monitor viewport at:

```text
mockups/orbital-view-viewport/index.html
```

The root launcher opens that live mockup file:

```text
Open Orbital View Kit.command
```

The canonical project launcher is:

```text
Open Orbital View.command
```

`Open Orbital View Kit.command` remains as a compatibility wrapper for older notes and shortcuts.

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

The current renderer invariant tests are in the same file and cover static draw-input stability across meter and camera updates.

## Do Not Start With

- full production rendering
- WebView or DomeLab code import
- Wavefield app tab changes
- MIDI, OSC, playback, output routing, or audio rendering changes
- Splat editing tools

## Recommended Next Prompt

Create a new bounded task before implementing any renderer, SwiftUI, or downstream app integration work. Good next candidates:

```text
SwiftUI control/gesture binding plan
Pixel-probe renderer tests
Renderer static buffer/cache plan
```
