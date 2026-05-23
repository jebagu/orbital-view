# Realtime Family Compliance Audit

Status: final closeout for realtime-family adoption package

## Compliance Result

Orbital View Kit has adopted the Realtime Audio Family Standards Package as a visual telemetry and preparation package.

Inherited standard:

```text
Realtime Audio Family Standards Package
Reference path: /Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards
Inherited revision label: 2026-05-23-family-standard
```

The Bencina Realtime Callback Doctrine applies to every callback and callback-reachable function in this repo family. Orbital View Kit currently owns no realtime audio callback, so its compliance claim is limited to preserving host callback separation, source-of-truth boundaries, physical identity, and no-backpressure display behavior.

## Plane Map

| Target or surface | Plane | Callback entry ownership | Compliance status |
| --- | --- | --- | --- |
| `OrbitalViewCore` | Preparation Plane | none | compliant as pure value contracts and validation |
| `OrbitalViewWavefield` | Preparation Plane adapter | none | compliant as local prepared-layout and prepared-meter adapter |
| `OrbitalViewRender` | Control / UI / Telemetry Plane | none | compliant as display-rate Metal renderer seam; protected path |
| `OrbitalViewSwiftUI` | Control / UI / Telemetry Plane | none | compliant as production host wrapper; protected path |
| `OrbitalViewReview` | Control / UI / Telemetry Plane review/demo surface | none | compliant only as review tooling; protected path |
| `OrbitalViewViewerSupport` | Preparation Plane fixture support | none | compliant as deterministic demo/stress fixtures |
| `OrbitalViewViewer` | Control / UI / Telemetry Plane review executable | none | compliant as review executable only |
| Test targets | Test / verification plane | none | compliance evidence only; no production realtime guarantee |

No target is marked callback-safe. Host apps must cross their own callback-safe bridge before invoking Orbital View Kit.

## Callback Inventory

Owned callback entry points:

```text
none
```

Orbital View Kit does not own:

- audio render callbacks;
- Core Audio, AVAudioEngine, AudioUnit, JACK, plugin, MIDI, OSC, or network realtime callbacks;
- playback scheduling;
- output routing;
- route discovery or route repair;
- host meter extraction timing;
- callback p99 or callback deadline gates.

## Source-Of-Truth Boundary

Production source-of-truth:

- physical speaker channels are host-owned;
- production meters are host-measured;
- source object identity is host-owned;
- routing, playback, MIDI, OSC, and output behavior are host-owned.

Orbital View Kit may validate, sanitize, diagnose, coalesce, drop, and display prepared snapshots. It must not synthesize production meter truth, reorder channels, downmix, truncate production channels, or represent display overload as audio failure.

## Review-Only Separation

Review-only SceneKit, local audio playback, impulse patterns, file dialogs, PNG export, app-bundle theme persistence, and bundled review fonts live in `OrbitalViewReview` and the review executable path.

Production hosts should import `OrbitalViewSwiftUI` and `OrbitalViewRender`, not `OrbitalViewReview`, unless a future task explicitly opts into review/demo tooling. Review local audio, synthetic impulse patterns, and visual stress fixtures are display evidence only and are not production meter source-of-truth.

## OpenSpec Status

OpenSpec is active for future audio-facing, architecture-facing, and protected-path changes.

Active change package:

```text
openspec/changes/adopt-realtime-family-standards/
```

Covered deltas:

- `orbital-view-realtime-boundary`
- `orbital-view-telemetry-ingress`
- `orbital-view-host-integration`
- `orbital-view-review-surface`

Local CLI validation status:

```text
No openspec or opsx CLI is installed in this checkout environment.
```

Until a CLI is installed, this repo uses static file/reference checks plus Swift build/test verification. Future audio-facing or architecture-facing work should still start from an OpenSpec change before code edits.

## Host Integration Status

Wavefield:

- Wavefield owns external livestream parsing, local livestream generator timing, MIDI streams, realtime queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and performance gates.
- The local livestream test generator is a Wavefield host source and source metadata provider.
- Generator profiles such as `smoke`, `moving-pose`, `sustained-moving-object`, `burst-reorder`, `16-object-stress`, and `32-object-should-pass-stress` are display stress inputs, not alternate Orbital View audio paths.

Orbisonic:

- Orbisonic owns playback, transport, Core Audio device I/O, route discovery, route repair, channel mapping, output routing, render/control engines, meter extraction, tap-point selection, operator state, and realtime performance gates.
- Orbital View Kit may receive prepared meter snapshots from explicit Orbisonic tap points with `orbisonicPreparedMeterTap` provenance.

Splat:

- Splat owns project/session state, authoring/edit commands, renderer-kernel analysis, neutral geometry import/export decisions, file formats, persistence, and any later handoff to an audio/render host.
- Orbital View Kit may visualize prepared virtual speakers, source objects, renderer-kernel overlays, neutral geometry review, camera, selection, diagnostics, and `splatPreparedAnalysis` provenance.

## UI Design Guideline

Orbisonic design language is the UI guideline for future Orbital View UI and review-surface work:

```text
docs/orbisonic-design-language.md
```

This is a visual and ergonomic guideline for shell layout, palette behavior, meter treatment, diagnostics separation, and information hierarchy. It does not import Orbisonic playback, routing, source-selection, or product semantics into Orbital View Kit.

## Display Stress Gate

The visual telemetry stress gate lives in:

```text
docs/visual-telemetry-stress-gates.md
Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift
```

It proves viewport no-backpressure behavior with 30 physical speakers, 128 source objects, capped trails, 60 FPS active motion, 120 FPS incoming meter cadence, local livestream generator provenance, and overload diagnostics for stale display drops.

It does not prove host callback p99, callback deadline, allocation-free callback behavior, route repair timing, device I/O timing, MIDI/OSC timing, or host meter-extraction timing.

## Remaining Risks

- Host realtime callback p99 and deadline compliance cannot be proven in this package because Orbital View Kit owns no host callback.
- Downstream Wavefield, Orbisonic, and Splat source integrations remain future work and must inspect their current repositories before editing protected paths.
- OpenSpec CLI validation could not run until `openspec` or `opsx` is installed locally.
- The visual stress fixture is source/test-visible but not yet exposed as a manual review-app mode.
- Some repo guidance text still reflects the project's earlier scaffold history; `docs/status.md` and this audit are the current closeout record for realtime-family adoption.

## Current Verdict

No hidden noncompliance is known in the current adoption package. The repo can honestly state that Orbital View Kit is standards-aligned as a visual telemetry/preparation package, with host realtime compliance remaining in the owning host apps.
