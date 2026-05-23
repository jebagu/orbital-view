# Change Proposal: Adopt Realtime Audio Family Standards

## Why

Orbital View Kit is audio-adjacent infrastructure for Orbisonic-family realtime audio applications. It visualizes prepared speaker layouts, measured meter snapshots, object telemetry, camera state, and selection events, but it must not accidentally become a realtime audio engine, callback target, router, playback scheduler, MIDI/OSC transport, or source of production meter truth.

This change creates the OpenSpec control layer for adopting the shared Realtime Audio Family Standards before behavior-changing implementation begins.

## What Changes

- Establish OpenSpec as the behavioral intent layer for this adoption and for future audio-facing or architecture-facing changes.
- Define the realtime boundary that keeps Orbital View Kit out of callback-reachable host audio paths.
- Define telemetry ingress requirements for prepared layout, meter, object, and diagnostic snapshots.
- Define host integration expectations for Wavefield, Orbisonic, Splat, and future realtime-family apps.
- Define review-surface constraints for local file playback, impulse sources, local livestream generators, and visual-only diagnostics.

## What Does Not Change

- No Swift source, package target, public API, renderer behavior, or review-app behavior changes in this OpenSpec activation slice.
- OpenSpec does not replace `docs/`, `.tasks/`, work packages, or `AGENTS.md`.
- The activation slice did not claim full realtime-family compliance by itself; the final closeout audit is `docs/realtime-family-compliance-audit.md`.
- Orbital View Kit does not own audio callbacks, output routing, playback scheduling, MIDI, OSC, file parsing, or realtime event queues.

## Impacted Specs

```text
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-realtime-boundary/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-telemetry-ingress/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-review-surface/spec.md
```

## Impacted Docs

```text
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/test-strategy.md
docs/status.md
openspec/README.md
work-packages/orbital-view-kit/realtime-family-adoption-work-package.md
```

## Risk

```text
medium
```

Risk is medium because the change governs future protected and audio-adjacent work, even though this slice itself is documentation and OpenSpec content only.

## Specialty Review Required

```text
yes
```

Required review areas:

```text
performance
reliability
architecture
audio
protected-path
```
