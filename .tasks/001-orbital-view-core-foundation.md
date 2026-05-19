# Task 001: OrbitalViewCore Foundation

## Status

```text
complete
```

## Goal

Create the first pure Swift foundation for `OrbitalViewKit` without implementing rendering or downstream app integration.

## Background

The work package calls for a reusable spherical speaker viewport. The first safe slice is a renderer-independent `OrbitalViewCore` target that owns contracts and validation.

## Relevant Docs

Read these before starting:

```text
AGENTS.md
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
work-packages/orbital-view-kit/orbital-view-kit-codex-work-package.md
```

## Scope

Implement:

- `Package.swift` with `OrbitalViewCore` and `OrbitalViewCoreTests`.
- Pure core value types for coordinate system, vector/unit direction, shell geometry, speakers, meter frames, camera state, selection/events, and validation errors.
- Center-locked camera preset helpers.
- Scene validation helpers.

Update:

- `docs/status.md`
- `docs/implementation-map.md`
- `docs/contracts.md` only if implementation needs a documented contract refinement
- `docs/test-strategy.md` if test layout changes

Add tests for:

- unit direction validation
- speaker validation
- shell reference validation
- meter channel identity
- camera center-lock presets
- scene validation

## Out of Scope

Do not:

- implement a production renderer
- create a SwiftUI wrapper
- add WebView or DomeLab code dependencies
- touch Wavefield, Orbisonic, or Splat source code
- implement playback, MIDI, OSC, output routing, or audio rendering behavior
- fake live meter data

## Contract References

```text
docs/contracts.md#module-orbitalviewcore
```

## Protected Path Check

This task:

```text
does not touch protected downstream paths
```

## Expected Files

Likely files to create or modify:

```text
Package.swift
Sources/OrbitalViewCore/
Tests/OrbitalViewCoreTests/
docs/status.md
docs/implementation-map.md
```

## Acceptance Criteria

- `swift build` succeeds.
- `swift test` succeeds.
- `OrbitalViewCore` is exposed as a library product and target.
- Core target has no forbidden UI, renderer, audio, MIDI, OSC, playback, or downstream app dependencies.
- 30 physical speakers can be represented without channel reorder.
- Monitor camera presets target the origin.
- Invalid scene, shell, speaker, and meter data produce explicit errors.

## Verification Commands

```text
swift build
swift test
```

## Stopping Conditions

Stop and report instead of continuing if:

- a public contract needs to change beyond the task scope
- a protected downstream path must be touched
- a major dependency is required
- renderer work becomes necessary
- implementation cannot be verified
