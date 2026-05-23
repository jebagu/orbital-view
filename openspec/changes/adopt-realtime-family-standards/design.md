# Design: Adopt Realtime Audio Family Standards

## Technical Approach

Use OpenSpec as the behavioral control layer for the realtime-family adoption. The change package defines the intended boundaries before later slices touch source, tests, stress gates, host integrations, or review-surface cleanup.

This change has four capability deltas:

```text
orbital-view-realtime-boundary
orbital-view-telemetry-ingress
orbital-view-host-integration
orbital-view-review-surface
```

Each delta explicitly answers:

```text
realtime impact
routing impact
meter source-of-truth
callback reachability
overload policy
performance gates
```

## Architecture Notes

Orbital View Kit fits the Control / UI / Telemetry Plane plus Preparation Plane adapters. It owns no Realtime Plane.

The host app owns:

- realtime callbacks
- callback-safe queues or bridges
- audio device routing
- playback timing
- MIDI and OSC transport
- meter extraction and source-of-truth decisions

Orbital View Kit owns:

- validated display contracts
- host-prepared layout and telemetry ingress
- renderer and SwiftUI display state
- review-surface visual harnesses
- camera and selection events

## Audio Notes

The Bencina Realtime Callback Doctrine applies to every callback and callback-reachable function in the realtime audio family. Orbital View Kit must not become callback-reachable unless a future OpenSpec change proves a narrower callback-safe contract.

Current package APIs are display and preparation APIs. They may allocate, validate, render, coalesce, or drop visual updates at display cadence. Host applications must keep those operations outside their realtime callback paths.

## Protected Path Notes

This slice does not edit protected source paths.

Later slices may affect protected renderer, SwiftUI, review-surface, or downstream integration paths. Those slices must keep their own bounded task scope, update docs, run the expected checks, and use specialty review when touching audio-adjacent behavior.

## Alternatives Considered

### Option A: Docs-Only Adoption

Pros:

- Simple.
- Keeps all requirements in existing project docs.

Cons:

- Does not give future risky changes a behavioral change package.
- Harder to distinguish current requirements from proposed changes.

### Option B: OpenSpec Change Package Plus Docs

Pros:

- Gives future slices a concrete proposed behavior layer.
- Keeps docs as source of truth while OpenSpec controls change intent.
- Matches the requested openspec.dev workflow.

Cons:

- Adds another project-control artifact that must stay synchronized.

## Decision

Use Option B. OpenSpec will govern behavioral intent for this realtime-family adoption while project docs, tasks, work packages, and status remain active sources of project control.

## Risks

- OpenSpec files can drift from `docs/` if later slices update one layer but not the other.
- The OpenSpec CLI is not installed in the current environment, so this slice relies on static file review.
- Later source slices still need real stress gates and review evidence before any compliance claim.

