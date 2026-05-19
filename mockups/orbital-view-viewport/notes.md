# Mockup Notes: Orbital Viewport

## What This Demonstrates

- Center-locked spherical monitor viewport.
- DomeLab-style left-side 3D Model control panel grouped under Camera, Color, Speaker Shape, and View Detail headings.
- DomeLab-style drag direction, spin direction, reset-to-current-preset behavior, always-axonometric projection, full-surface Purple, Flamingo, Green, and B&W color palettes, hidden-line clipping, and canvas PNG export.
- Fey sphere 3V geodesic shell structure generated from the DomeLab project config values in `fey sphere - domelab-configuration.json`.
- Speaker shape, size, and number-switch controls for comparing true 8-vertex rectangular-prism speaker cabinets against spheres, with Prism as the default shape.
- Purple, Prism, 1.95x centered speaker size, 38 fog density, Speaker numbers off, and Hidden Lines off are the current mockup defaults.
- Speaker size uses a center-weighted slider where the midpoint is 1.95x, the left edge is half that size, and the right edge is double that size.
- Fog density uses a remapped slider where the midpoint is the previous 30-density visual value, so the middle of the control is less dark.
- Reversed vertical drag response for the mockup orbit control while leaving horizontal yaw unchanged.
- Hidden Lines off, or Fog density at 100, draws a structure-style circular boundary and hides back-half structure and speaker faces.
- Mid-range fog now fades hidden speaker faces and hidden shell lines through the same depth fade rule.
- Speaker geometry stays fixed while fake RMS/peak values change glow, ring, and color.
- Speaker click selection with channel, level, and coordinate inspection.
- Fey-style 30-speaker layout using the same coordinate convention as the core docs.

## What Is Fake

- No Swift, SwiftUI, MetalKit, or production renderer code.
- No real audio, metering, smoothing, or callback timing.
- No DomeLab import.
- No physical shell dimensions or cabinet model.
- The geodesic shell uses the Fey config's 3V icosahedron settings, but the mockup normalizes the geometry to the viewport sphere instead of using physical meter-scale coordinates.
- The prism dimensions are visual proportions only, not measured cabinet dimensions.
- The cuboid clipping is a canvas mockup of production 3D clipping behavior, not a Metal implementation.
- The meter animation is deterministic fake data.
- The DomeLab controls are replicated as mockup behavior only; no DomeLab code or runtime dependency is imported.

## Product Questions for Jeremy

- Should the first production viewport prioritize a minimal monitor mode or a richer diagnostic inspector?
- Should the default camera be isometric, elevation, or the last saved user camera?
- Should labels be numeric-only by default or use full speaker names?
- Should production Hidden Lines off fully clip the back half or dim it for context?

## Swift Implementation Notes

Later Swift work will need:

- SwiftUI wrapper around a renderer view.
- Renderer backend decision, likely MetalKit for production.
- Adapter from `OrbitalViewSceneSpec` and `SpeakerMeterFrame` into renderer buffers.
- Camera state binding and center-lock enforcement.
- Production equivalents for spin, PNG export, always-axonometric projection, color style, speaker shape/size, speaker-number visibility, hidden-line clipping, and fog density.
- A production geodesic import path should consume a neutral geometry/config contract instead of importing DomeLab runtime code.
- Hit testing that returns `OrbitalViewSelection`.
- Meter smoothing in the visual frame loop, not in audio callbacks.
