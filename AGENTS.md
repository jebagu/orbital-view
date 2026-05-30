# AGENTS.md

## Project

Orbital View is the canonical head project for the reusable spherical speaker viewport. The historical names `Orbital View Kit`, `Orbital View VU Kit`, `Orbital View Turbo`, and `orbital-view-with-objects` are non-head variation labels.

The current implemented Swift package targets are `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewSpatGRIS`, `OrbitalViewRender`, `OrbitalViewTelemetry`, `OrbitalViewSwiftUI`, `OrbitalViewReview`, `OrbitalViewViewerSupport`, and `OrbitalViewViewer`. The production renderer backend decision is accepted as MetalKit / MTKView. The native SceneKit review app is the current visible review surface; production host integration still goes through `OrbitalViewSwiftUI` and `OrbitalViewRender`.

## Local Hosting

This project is not currently a locally hosted web project.

Permanent local URL:

```text
not applicable yet
```

If a future mockup or local web tool is hosted, use a stable project path:

```text
http://127.0.0.1:<port>/OrbitalView/
```

Pin the port in this file before treating that URL as permanent.

## Launchers

The project launcher is:

```text
Open Orbital View.command
```

The legacy compatibility launcher is:

```text
Open Orbital View Kit.command
```

The stable launcher in the parent `vibecode projects` folder is:

```text
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command
```

Keep the parent launcher as a thin wrapper that delegates to this checkout's project launcher. The project launcher is the source of truth and must rebuild `OrbitalViewViewer`, refresh the native review `.app` executable and current review resource bundle, restart any stale `OrbitalViewViewer` process, and open the latest app.

Whenever source, resource, bundled theme, app-bundle, or launch-flow changes affect the visible review app, update `Open Orbital View.command`, keep `Open Orbital View Kit.command` as a compatibility wrapper, confirm the parent launcher still points to a working launcher path, and launch through the parent launcher before reporting the change complete.

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
docs/project-identity.md
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

## Operating Rules

- Work only on the requested task or slice.
- Keep implementation slices small and testable.
- Canonical 3D coordinates in this repository are always Z-up: `x = right/left`, `y = front/back`, and `z = up/down`.
- Keep `OrbitalViewCore` independent of SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, and downstream app targets.
- Do not introduce WebView or DomeLab code dependencies.
- Treat DomeLab as a visual reference and future neutral geometry-import source only.
- Do not fake meter data in production UI paths.
- Do not reorder physical speaker channels.
- Do not flatten canonical 3D coordinates into permanent screen coordinates.
- Do not add major dependencies without an explicit task decision.
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
