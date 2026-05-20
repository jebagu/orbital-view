# Slice 012: Wavefield Object Overlay Performance

## Status

```text
complete
```

## Goal

Add high-performance Wavefield source-object overlay contracts, renderer plumbing, SwiftUI forwarding, and mockup controls while preserving the existing Orbital View Kit viewport control panel and VU-kit behavior.

## Scope

Done when this slice:

- Adds active object frames and object meter frames keyed by Wavefield `objectId`.
- Keeps object centers on canonical `unitSphereCartesian` unit-sphere directions.
- Adds object visual settings for geometry, motion, meter skin, trails, glow trails, and `-5...+5` render/effect bounds.
- Keeps trails capped and disabled by default.
- Keeps glow trails sharing the same capped trail samples.
- Adds object renderer state/revisions separately from speaker scene/meter/settings revisions.
- Adds retained Metal buffer storage for repeated speaker/object draws.
- Adds object controls below View Detail in the existing mockup control rail.
- Updates docs and tests.

Out of scope:

- Downstream Wavefield app integration.
- `.wfield`, OSC, MIDI, audio, routing, playback, or metering changes.
- Full production shell/material rendering.
- Post-process bloom.
- New UI panel systems or new dependencies.

## Protected Path Check

This slice explicitly permits:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

This slice does not permit:

```text
downstream app source paths
audio, playback, routing, MIDI, OSC, or metering paths
```

## Verification

```text
node inline JavaScript parse for mockups
node object-control mockup assertions
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```
