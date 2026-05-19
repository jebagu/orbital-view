# Test Strategy

## Current Package

The Swift package exists and is verified with the full Xcode toolchain.

## Testing Goals

Once implementation starts, the test suite should prove:

- core contracts validate invalid data explicitly
- physical speaker channel identity is preserved
- meter frames preserve levels by channel
- monitor camera presets keep the target at origin
- imported shell geometry references are valid
- downstream adapters do not reorder Wavefield/Fey speakers
- local Wavefield JSON adapter rejects invalid layout shape explicitly
- local Wavefield meter adapter rejects duplicate channels and invalid levels explicitly

## Unit Tests

Use for:

- vector and unit direction validation
- shell node/edge/face validation
- speaker ID/channel/shape validation
- meter frame identity
- camera preset state
- scene builder behavior

## Integration Tests

Use when a downstream adapter is added:

- load or construct the Fey 30 layout
- adapt it to `OrbitalViewSceneSpec`
- assert 30 physical speaker records
- assert channels remain `1...30`
- assert labels remain stable
- assert directions match the source layout
- reject unsupported axes and invalid speaker counts
- map channel/rms/peak records into `SpeakerMeterFrame`
- preserve missing meter channels as absent values
- derive clip from a configurable threshold

## Renderer Tests

The accepted renderer backend is MetalKit / MTKView, with SwiftUI in a wrapper target.

Renderer harness details live in:

```text
docs/renderer-test-harness.md
```

Current renderer seam tests cover:

- scene updates increment structural revision without touching meter revision
- meter updates increment meter revision without rebuilding scene state
- camera and selection updates emit events
- `OrbitalViewMetalRenderer` provides an `MTKViewDelegate` seam
- offscreen Metal smoke rendering produces a non-clear frame from a deterministic scene, or skips clearly when no Metal device exists
- meter-only and camera-only updates keep static speaker draw inputs stable
- speaker draw inputs preserve ID/channel order and stable quad dimensions

Future renderer drawing checks should cover:

- center-lock survives resize and camera preset changes
- selection emits speaker/channel identity without mutating playback
- renderer target compiles without adding audio, playback, routing, MIDI, OSC, or downstream app dependencies
- meter updates can be tested separately from structural scene updates
- targeted pixel probes catch blank frames without brittle full-frame snapshots

## SwiftUI Wrapper Tests

Current wrapper skeleton tests cover:

- `OrbitalView` initializes with camera and selection bindings
- identical configuration updates do not repeatedly increment structural renderer revision
- changed meter frames update meter revision without rebuilding scene state
- camera and selection configuration emits renderer events

Future wrapper tests should cover:

- gesture updates bind camera state without breaking center lock
- selection bindings round-trip from renderer picking to host UI
- toolbar toggles do not mutate audio, playback, routing, or metering state

## Mockup Checks

Disposable browser mockups should stay separate from production Swift code. For `mockups/orbital-view-viewport/`, verify:

- `index.html` and `notes.md` exist
- inline JavaScript parses with Node extraction
- mockup text does not claim real audio, real meters, or production renderer behavior
- static browser review confirms the DomeLab-style left control panel headings, no Projection picker, always-axonometric projection, full-surface Color palettes, Purple/Prism defaults, remapped speaker size/fog sliders, Speaker numbers switch defaulted off, Hidden Lines switch defaulted off, consistent shell/speaker fog behavior, prism face clipping, PNG export, and inspector are usable

## Required Checks

Current package:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Current mockup:

```text
node -e 'const fs=require("fs"); const html=fs.readFileSync("mockups/orbital-view-viewport/index.html","utf8"); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]).join("\n"); new Function(scripts); console.log("inline JS parses");'
```

The plain Command Line Tools environment on this machine can build but cannot currently run XCTest:

```text
swift test -> XCTest not available
```

## Test Data Rules

- Use deterministic scene fixtures.
- Keep geometry fixtures small.
- Do not rely on live audio devices.
- Do not fake production meter sources in app UI tests.
- Do not store secrets.
