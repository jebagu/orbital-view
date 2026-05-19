# Slice 008: Renderer Test Harness Plan

## Status

```text
complete
```

## Goal

Define a test harness plan before adding the first Metal draw-loop behavior.

## Scope

Do:

- Add `docs/renderer-test-harness.md`.
- Define offscreen rendering smoke-test expectations.
- Define renderer invariant tests.
- Define targeted pixel-probe strategy.
- Define first draw-loop acceptance criteria.
- Update active docs and work-package state.

Do not:

- write Metal draw-loop code
- write shader code
- add offscreen texture tests yet
- add SwiftUI gestures or controls
- touch Wavefield, Orbisonic, or Splat source
- touch audio, playback, routing, MIDI, OSC, or metering paths

## Protected Path Check

This slice:

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
