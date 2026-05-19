# Mockup Notes: Orbital Viewport

## What This Demonstrates

- Center-locked spherical monitor viewport.
- Plan, front, side, isometric, reset, projection, structure, labels, speakers, and cutaway controls.
- Speaker geometry stays fixed while fake RMS/peak values change glow, ring, and color.
- Speaker click selection with channel, level, and coordinate inspection.
- Fey-style 30-speaker layout using the same coordinate convention as the core docs.

## What Is Fake

- No Swift, SwiftUI, MetalKit, or production renderer code.
- No real audio, metering, smoothing, or callback timing.
- No DomeLab import.
- No physical shell dimensions or cabinet model.
- The meter animation is deterministic fake data.

## Product Questions for Jeremy

- Should the first production viewport prioritize a minimal monitor mode or a richer diagnostic inspector?
- Should the default camera be isometric, front, or the last saved user camera?
- Should labels be numeric-only by default or use full speaker names?
- Should cutaway hide the back hemisphere or dim it?

## Swift Implementation Notes

Later Swift work will need:

- SwiftUI wrapper around a renderer view.
- Renderer backend decision, likely MetalKit for production.
- Adapter from `OrbitalViewSceneSpec` and `SpeakerMeterFrame` into renderer buffers.
- Camera state binding and center-lock enforcement.
- Hit testing that returns `OrbitalViewSelection`.
- Meter smoothing in the visual frame loop, not in audio callbacks.

