# Task 011: VU Meter Plumbing And Settings Tray

## Status

```text
complete
```

## Goal

Add the first reusable VU meter visual plumbing for 30 physical speakers, plus a SwiftUI collapsible settings tray for display gain and style.

## Background

`OrbitalViewCore` already represents meter frames by physical channel. `OrbitalViewRender` already separates scene, meter, camera, and selection state, and its current draw path changes speaker color/intensity without resizing speaker geometry. This task adds a public display-settings contract and passes that state through renderer and SwiftUI without touching host audio behavior.

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
```

## Scope

Implemented:

- Pure `OrbitalViewCore` meter visual settings for display gain, default checker pulse/ring/diagonal wave style, color scheme, and checker controls.
- Renderer state plumbing for meter visual settings with a separate revision counter.
- Draw-input mapping from each scene speaker's physical channel into `SpeakerMeterFrame.levelsByChannel`.
- A source-compatible `OrbitalView` path with no settings tray.
- A new `OrbitalView` initializer that accepts a `Binding<SpeakerMeterVisualSettings>` and shows a bottom collapsible settings tray.

Update:

- `docs/status.md`
- `docs/contracts.md`
- `docs/architecture.md`
- `docs/system-flows.md`
- `docs/implementation-map.md`
- `docs/test-strategy.md`
- `work-packages/orbital-view-kit/MV.md`

Added tests for:

- Meter visual settings defaults, validation, and style codability.
- Renderer 30-channel meter-to-speaker mapping.
- Visual gain/style changes affecting visual state without changing static geometry or raw meter revision.
- SwiftUI existing initializer compatibility.
- SwiftUI settings configuration and settings-only coordinator updates.

## Out of Scope

Do not:

- implement production speaker animation
- resize speaker geometry for VU behavior
- add shell rendering, labels, hit testing, gestures, or toolbar controls
- touch Wavefield, Orbisonic, or Splat source
- touch audio, playback, routing, MIDI, OSC, or host metering paths
- add a major dependency

## Contract References

```text
docs/contracts.md#module-orbitalviewcore
docs/contracts.md#module-orbitalviewrender
docs/contracts.md#module-orbitalviewswiftui
```

## Protected Path Check

This task does touch protected paths.

Permitted protected paths:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

This task does not permit:

```text
downstream Wavefield, Orbisonic, or Splat source paths
audio, playback, routing, MIDI, OSC, or metering paths
```

## Expected Files

Likely files to create or modify:

```text
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewCoreTests/
Tests/OrbitalViewRenderTests/
Tests/OrbitalViewSwiftUITests/
docs/
work-packages/orbital-view-kit/MV.md
```

This list is guidance, not permission to make unrelated changes.

## Acceptance Criteria

This task is complete when:

- `SpeakerMeterVisualSettings` and `SpeakerMeterVisualStyle` are public pure-core contracts.
- Visual gain validates finite values in `-24...24` dB.
- Renderer meter visual settings have their own revision counter.
- A 30-speaker scene maps channel-keyed meter data by physical channel without reordering.
- Missing channels render as silent/default and extra channels are ignored.
- Existing `OrbitalView` usage remains tray-free and source-compatible.
- The new `OrbitalView` settings initializer shows a collapsed bottom tray with Visual Gain, Style, Color Scheme, and checker controls.
- Relevant tests pass.
- Relevant docs are updated.

## Verification Commands

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

## Stopping Conditions

Stop and report instead of continuing if:

- The task requires touching protected paths not listed above.
- The task requires touching downstream app source.
- The task requires audio, playback, routing, MIDI, OSC, or host metering changes.
- The task requires a major new dependency.
- Tests fail for reasons outside this task.
- The work cannot be verified.

## Required Final Summary

Return:

1. What changed
2. Files changed
3. Tests added or updated
4. Commands run and results
5. Documentation updated
6. Bugs found or fixed
7. Protected paths touched
8. Assumptions
9. Risks or blockers
10. Recommended next task
