# Renderer Test Harness Plan

## Purpose

Define the verification shape for the first real Metal draw-loop work before adding rendering behavior.

The harness should prove that `OrbitalViewRender` can draw deterministic, inspectable output while preserving the project rules:

- no audio ownership
- no channel reorder
- no geometry rebuild for meter-only updates
- no WebView or DomeLab code import
- no downstream host app dependency

## Current Baseline

Implemented today:

```text
OrbitalViewRender
OrbitalViewSwiftUI
OrbitalViewRenderTests
OrbitalViewSwiftUITests
```

Current tests prove state and wrapper behavior, not pixels:

- scene updates increment structural revision
- meter updates increment meter revision separately
- camera and selection updates emit events
- `OrbitalViewMetalRenderer` conforms to `MTKViewDelegate`
- `OrbitalViewSwiftUI` forwards configuration without duplicate structural updates
- offscreen renderer smoke coverage renders a deterministic scene into a BGRA texture and asserts non-clear pixels

## Harness Layers

### Layer 1: Compile And Contract Tests

Status:

```text
implemented
```

Purpose:

```text
Verify package targets compile and renderer/wrapper state contracts remain stable.
```

Required checks:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

### Layer 2: Offscreen Renderer Smoke Tests

Status:

```text
implemented
```

Purpose:

```text
Verify a minimal Metal draw pass produces non-empty output without opening a host app.
```

Expected behavior:

- create or inject an `MTLDevice`
- compile the minimal shader pipeline
- render one deterministic scene into an offscreen texture
- assert the texture contains at least one non-clear pixel
- skip with a clear XCTest skip reason if no Metal device exists

This layer should use a tiny deterministic scene, not the full Fey 30 fixture.

Current implementation:

```text
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

The current draw path renders fixed-size speaker quads from scene speaker anchors. Meter values affect color and intensity only; they do not resize speaker geometry.

### Layer 3: Renderer Invariant Tests

Status:

```text
future after first draw pass
```

Purpose:

```text
Verify renderer behavior that can regress silently once drawing exists.
```

Required invariants:

- loading a new scene increments structural revision
- meter-only updates do not rebuild static geometry
- camera-only updates do not rebuild static geometry
- speaker mesh dimensions remain stable under meter changes
- channel identity is preserved in draw inputs
- monitor camera target remains origin-centered

### Layer 4: Pixel Probe Tests

Status:

```text
future after deterministic draw pass
```

Purpose:

```text
Catch blank frames, inverted axes, and missing speaker marks without brittle full-image snapshots.
```

Initial pixel probes should check:

- frame is not all clear color
- center region contains shell or speaker content for isometric preset
- plan/front/side presets move expected markers to different screen regions
- meter hot channel changes color/intensity in a localized region

Avoid exact full-frame golden images until the visual design stabilizes.

### Layer 5: Interactive Harness

Status:

```text
future optional
```

Purpose:

```text
Give developers a local manual visual check without integrating Wavefield.
```

Potential shape:

```text
Examples/OrbitalViewHarness/
```

Constraints:

- local-only
- deterministic fixture data
- no audio devices
- no host app dependency
- no permanent local web URL unless the harness becomes hosted

## First Draw-Loop Slice Acceptance Criteria

Status:

```text
complete for the smoke-test baseline
```

The first Metal draw-loop implementation should stop when all of this is true:

- `OrbitalViewRender` has a minimal render pipeline.
- A deterministic scene can render one offscreen frame.
- XCTest can assert non-clear output.
- Existing tests still pass.
- New tests skip cleanly if Metal is unavailable.
- No SwiftUI gestures, toolbar, inspector UI, audio, or downstream app integration is added.

## Test Fixture Rules

- Use a one-speaker or three-speaker scene for smoke tests.
- Use the Fey 30 fixture only when testing channel/order integration.
- Keep all meter data deterministic.
- Do not use live audio or wall-clock animation.
- Do not rely on a visible window for CI-style tests.

## Risks

- Metal offscreen testing can be machine-dependent; tests must skip clearly when no device is available.
- Full-frame snapshots may be too brittle early; prefer targeted pixel probes.
- A test harness can drift into a demo app; keep it separate from production wrapper behavior.
