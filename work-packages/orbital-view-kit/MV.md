# Work Package: Orbital View Kit Foundation

## Goal

Create the reusable foundation for `OrbitalViewKit`, a spherical speaker viewport shared by Wavefield, Orbisonic, and Splat.

## Current Tree

```text
main tree
```

## Worktree Decision

```text
main tree
```

Reasoning:

```text
The current request is scaffold-only. The first implementation slice is small enough for the main tree.
```

## Product Summary

OrbitalViewKit should eventually render a beautiful, center-locked, orbitable 3D Sonic Sphere-style viewport. Speakers remain physical objects while RMS, peak, and clip state appear through material, glow, rings, and bloom rather than geometry resizing.

## Architecture Summary

Start with `OrbitalViewCore`: pure Swift contracts and validation. Renderer, SwiftUI wrapper, DomeLab import, Splat overlays, and downstream app adapters are later slices.

## Related OpenSpec Change

```text
none yet
```

## Visual Mockups

```text
none yet
```

## Protected Paths

Current scaffold:

```text
none
```

Future downstream app integrations may touch protected audio, metering, routing, playback, or renderer paths and will require explicit task permission.

## Audio Constraints

- Do not own audio callbacks or timing behavior.
- Consume measured meter frames only.
- Do not fake, downmix, truncate, or reorder physical channel data.

## Performance Constraints

- Core validation should be deterministic and lightweight.
- Future renderer meter updates must avoid rebuilding static geometry every frame.

## Reliability Constraints

- Invalid geometry and speaker data must fail explicitly.
- Camera presets in monitor mode must target origin.
- Channel identity must be stable.

## Slices

### Slice 001: OrbitalViewCore Foundation

Status:

```text
complete
```

Goal:

```text
Create pure core Swift contracts and tests.
```

Agent:

```text
Codex
```

Depends on:

```text
project scaffold
```

Review required:

```text
normal, with architecture review useful if contracts drift
```

Protected path touch:

```text
no
```

### Slice 002: Wavefield Layout JSON Adapter

Status:

```text
complete
```

Goal:

```text
Map Wavefield speaker-layout JSON into OrbitalViewCore scenes.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 001
```

Review required:

```text
normal
```

Protected path touch:

```text
no
```

### Slice 003: Wavefield Meter Frame Adapter

Status:

```text
complete
```

Goal:

```text
Map Wavefield-style channel/rms/peak meter records into OrbitalViewCore SpeakerMeterFrame.
```

Agent:

```text
Codex
```

Depends on:

```text
Slice 001
```

Review required:

```text
normal
```

Protected path touch:

```text
no
```

## Bugs Found During Package

Link:

```text
docs/bugs.md
```

## Current Status

Slice 003 is complete. `OrbitalViewCore` and `OrbitalViewWavefield` scene/meter adapters exist with tests.

## Next Action

Open a new bounded task for renderer visual mockup or renderer backend decision.
