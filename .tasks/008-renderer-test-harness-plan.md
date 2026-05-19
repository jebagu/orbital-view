# Task 008: Renderer Test Harness Plan

## Status

```text
complete
```

## Goal

Define how the first Metal draw-loop work will be verified before implementing drawing behavior.

## Scope

Implemented:

- `docs/renderer-test-harness.md`.
- Harness layers for contract tests, offscreen renderer smoke tests, renderer invariant tests, pixel probes, and optional interactive harness.
- Acceptance criteria for the first draw-loop slice.
- Active docs and work-package status updated.

Out of scope:

- Metal draw-loop implementation.
- Shader code.
- Offscreen texture test implementation.
- SwiftUI gestures, controls, or inspector UI.
- Downstream app integration.
- Audio, playback, routing, MIDI, OSC, or metering changes.

## Protected Path Check

This task:

```text
does not touch protected source paths
does not touch downstream protected paths
```

## Verification

```text
manifest parse
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
