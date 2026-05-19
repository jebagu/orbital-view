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

## Renderer Tests

Deferred until renderer work exists.

Future renderer checks should cover:

- static geometry is not rebuilt for every meter frame
- speaker mesh dimensions remain constant under VU updates
- center-lock survives resize and camera preset changes
- selection emits speaker/channel identity without mutating playback

## Required Checks

Current package:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
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
