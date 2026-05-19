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

Prepare a safe first implementation slice for `OrbitalViewCore`.

The initial code should establish pure Swift contracts and tests for:

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

Use the bounded task prompt in:

```text
.tasks/001-orbital-view-core-foundation.md
```

