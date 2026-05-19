# Slice 001: OrbitalViewCore Foundation

## Status

```text
complete
```

## Goal

Create a pure Swift `OrbitalViewCore` target with core data contracts, validation, and tests.

## Scope

Do:

- Add `Package.swift`.
- Add `Sources/OrbitalViewCore/`.
- Add `Tests/OrbitalViewCoreTests/`.
- Implement core scene, shell, speaker, meter, camera, selection, and validation types.
- Add tests matching `docs/test-strategy.md`.
- Update status and implementation map docs.

Do not:

- implement renderer code
- implement SwiftUI wrapper code
- import DomeLab code
- modify downstream Wavefield, Orbisonic, or Splat repositories
- touch audio, playback, MIDI, OSC, routing, or output behavior

## Relevant Docs

```text
AGENTS.md
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/implementation-map.md
docs/test-strategy.md
docs/status.md
docs/bugs.md
work-packages/orbital-view-kit/MV.md
work-packages/orbital-view-kit/orbital-view-kit-codex-work-package.md
```

## Related OpenSpec

```text
none
```

## Expected Files

```text
Package.swift
Sources/OrbitalViewCore/
Tests/OrbitalViewCoreTests/
docs/status.md
docs/implementation-map.md
```

## Protected Path Check

This slice:

```text
does not
```

touch a protected path.

## Review Required

```text
normal
```

Architecture specialty review is recommended if public contracts drift from `docs/contracts.md`.

## Acceptance Criteria

- `swift build` succeeds.
- `swift test` succeeds.
- `OrbitalViewCore` has no forbidden dependencies.
- Core types can represent coordinate system, shell, 30 speakers, meter levels by channel, and center-locked camera state.
- Invalid core data produces explicit errors.
- Docs/status is updated.

## Verification

```text
swift build
swift test
```

## Final Summary Required

Return:

1. What changed
2. Files changed
3. Tests run
4. Bugs found or fixed
5. Protected paths touched
6. Risks
7. Recommended next slice
