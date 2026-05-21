# AGENTS.md

## Project

Orbital View Kit is a docs-first scaffold for a reusable spherical speaker viewport module named `OrbitalViewKit`.

The current implemented Swift package targets are `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewRender`, and `OrbitalViewSwiftUI`. The production renderer backend decision is accepted as MetalKit / MTKView, and `OrbitalViewRender` now has a minimal offscreen smoke-test draw path, static draw-input invariant tests, display-only checker pulse/ring/diagonal wave VU settings, native display settings, and imported-shell node-anchor projection. `OrbitalViewSwiftUI` now includes the required viewport control surface by default, with Plan / Elevation / Isometric, Export PNG callback, speaker shape, speaker size, speaker numbers, hidden lines, and fog controls, plus an opt-in collapsed VU settings tray with color-scheme and checker controls. Production visual rendering, production checker facet animation, gestures, Wavefield app integration, Orbisonic integration, and Splat integration remain deferred until explicit tasks are opened.

## Local Hosting

This project is not currently a locally hosted web project.

Permanent local URL:

```text
not applicable yet
```

If a future mockup or local web tool is hosted, use a stable project path:

```text
http://127.0.0.1:<port>/OrbitalViewKit/
```

Pin the port in this file before treating that URL as permanent.

## Read First

Before making changes, read:

```text
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/status.md
docs/bugs.md
work-packages/orbital-view-kit/MV.md
```

For implementation work, also read the relevant task or slice:

```text
.tasks/
work-packages/orbital-view-kit/slices/
openspec/changes/
```

## Current Project Assumption

This repository contains project-control docs, the pure Swift source target `OrbitalViewCore`, the local adapter target `OrbitalViewWavefield`, the MetalKit renderer target `OrbitalViewRender`, and the SwiftUI wrapper skeleton target `OrbitalViewSwiftUI`.

Current renderer source must stay within the active renderer task scope, and it must not touch downstream app audio, playback, MIDI, OSC, routing, or render pipelines.

Future uses of the kit must include the native `OrbitalView` control surface and must default physical Fey/Wavefield scenes to the imported Fey 3V geodesic shell with speakers anchored to shell nodes. Do not replace that default with a generic parametric direction shell unless a future task explicitly changes the visual contract and documents the reason.

## Operating Rules

- Work only on the requested task or slice.
- Keep implementation slices small and testable.
- Keep `OrbitalViewCore` independent of SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, and downstream app targets.
- Do not introduce WebView or DomeLab code dependencies.
- Treat DomeLab as a visual reference and future neutral geometry-import source only.
- Do not fake meter data in production UI paths.
- Do not reorder physical speaker channels.
- Do not flatten canonical 3D coordinates into permanent screen coordinates.
- Do not add major dependencies without an explicit task decision.
- Do not integrate the kit without the required native control surface: Plan, Elevation, Isometric, Export PNG, speaker shape, speaker size, speaker numbers, hidden lines, and fog.
- Do not default physical speaker scenes to a generic direction shell when the imported Fey geodesic shell and node anchors are available.
- Update docs when project structure, contracts, protected paths, tests, or status changes.

## Protected Path Rule

`Sources/OrbitalViewRender/` and `Sources/OrbitalViewSwiftUI/` are protected renderer/UI paths governed by `docs/protected-paths.md`.

Future downstream integrations with Wavefield, Orbisonic, or Splat may touch protected audio, rendering, routing, metering, or playback paths. If a task reaches into those downstream repositories or modules, read `docs/protected-paths.md` and confirm the task explicitly permits the touch.

## Documentation Requirements

After each implementation task, update:

```text
docs/status.md
```

Also update these when relevant:

```text
docs/implementation-map.md
docs/system-flows.md
docs/contracts.md
docs/test-strategy.md
docs/bugs.md
docs/protected-paths.md
```

## Testing Requirements

Expected checks are:

```text
swift build
swift test
```

If a task cannot run its intended checks, document the exact reason in `docs/status.md` and the final response.

## Stopping Conditions

Stop and report instead of continuing if:

- A public contract needs to change outside the active task.
- A protected downstream path would be changed without explicit permission.
- A major dependency is required.
- The task conflicts with the work package or docs.
- The task would implement renderer or app integration work before `OrbitalViewCore` is established.
- Tests fail for reasons unrelated to the task.
- The implementation cannot be verified.

## Final Response Format

Every implementation response should include:

```text
Summary:
Files changed:
Tests added or updated:
Commands run:
Results:
Documentation updated:
Bugs found or fixed:
Protected paths touched:
Assumptions:
Risks or blockers:
Recommended next task:
```
