# Decision 0001: Start With Pure OrbitalViewCore

## Status

Accepted

## Context

The desired product is a high-quality 3D spherical speaker viewport that can serve Wavefield, Orbisonic, and Splat. A full renderer is valuable, but starting with rendering would risk coupling scene semantics, meter behavior, and downstream app concerns too early.

## Decision

Start with a pure Swift target named `OrbitalViewCore`.

`OrbitalViewCore` will define scene, shell, speaker, meter, camera, selection, and validation contracts without depending on UI, rendering, audio, playback, MIDI, OSC, or downstream app targets.

Renderer and app integrations are deferred until the core contracts and tests exist.

## Rationale

- Keeps the first implementation slice small and testable.
- Preserves channel identity before any visual layer exists.
- Allows MetalKit or another native renderer decision later without changing core data semantics.
- Allows Wavefield, Orbisonic, and Splat to share one contract layer.

## Alternatives Considered

### Build Renderer First

Pros:

- Faster visual proof.

Cons:

- Higher risk of hard-coding renderer assumptions into data contracts.
- More likely to touch downstream app UI before validation exists.

### Embed DomeLab In A WebView

Pros:

- Quick browser-style visual surface.

Cons:

- Conflicts with native Swift reuse.
- Couples OrbitalViewKit to DomeLab internals.
- Does not establish portable scene contracts.

## Consequences

Positive:

- First code slice can be verified with unit tests.
- Downstream app integrations have a stable target shape.

Negative:

- No immediate 3D viewport until later renderer work.

## Follow-Up

- Implement `.tasks/001-orbital-view-core-foundation.md`.
- Decide renderer backend after core contracts compile and pass tests.

