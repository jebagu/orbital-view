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
pending
```

Goal:

```text
Create pure core Swift contracts and tests.
```

Agent:

```text
unassigned
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

## Bugs Found During Package

Link:

```text
docs/bugs.md
```

## Current Status

The work package is ready for Slice 001.

## Next Action

Run `.tasks/001-orbital-view-core-foundation.md`.

