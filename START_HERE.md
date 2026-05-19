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

Prepare the next bounded slice after the `OrbitalViewCore` foundation.

The current core already establishes pure Swift contracts and tests for:

- coordinate systems
- vectors and unit-sphere directions
- shell geometry
- physical speaker identity and anchors
- meter frames by channel
- center-locked camera presets
- scene validation

## Do Not Start With

- production rendering
- WebView or DomeLab code import
- Wavefield app tab changes
- MIDI, OSC, playback, output routing, or audio rendering changes
- Splat editing tools

## Recommended Next Prompt

Create a new bounded task before implementing any renderer, SwiftUI, or downstream app integration work. Good next candidates:

```text
OrbitalViewCore Wavefield adapter planning
OrbitalViewSwiftUI visual mockup
Renderer backend decision
```
