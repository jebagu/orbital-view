# Decision 0002: Use MetalKit For Production Renderer

## Status

Accepted

## Context

`OrbitalViewCore` and `OrbitalViewWavefield` now provide pure scene and meter contracts, and `mockups/orbital-view-viewport/` previews the desired monitor interaction. The next implementation phase needs a renderer direction before adding `OrbitalViewRender` or `OrbitalViewSwiftUI` source.

The viewport needs stable 3D geometry, live meter material updates, glow/ring intensity, hit testing, camera presets, and later Splat overlays. It must remain native for Wavefield and Orbisonic, and it must not import DomeLab code or embed DomeLab in a WebView.

## Decision

Use a custom Apple-native MetalKit renderer as the production backend.

The intended target split is:

```text
OrbitalViewRender
  MetalKit / MTKView renderer internals.

OrbitalViewSwiftUI
  SwiftUI wrapper and host-app binding surface.
```

The renderer must consume `OrbitalViewCore` scene, meter, camera, and selection contracts without changing their semantics. Static scene geometry and live meter frames should remain separate update paths.

## Binding Rules

- `OrbitalViewCore` remains renderer-independent.
- `OrbitalViewRender` may depend on MetalKit and platform rendering frameworks when the renderer task is opened.
- `OrbitalViewSwiftUI` may depend on SwiftUI and `OrbitalViewRender` when the wrapper task is opened.
- Host apps own audio, playback, routing, MIDI, OSC, and metering. The renderer consumes measured state only.
- Speaker geometry dimensions remain stable; meters affect material, glow, rings, and bloom.
- Monitor camera presets stay center-locked at origin.

## Alternatives Considered

### SceneKit First

Pros:

- Faster native 3D prototype.
- Less renderer infrastructure up front.

Cons:

- Less control over instancing, glow, bloom, outlines, and future Splat overlays.
- Higher risk of building around a short-lived abstraction.
- Still requires a later migration for production visual quality.

### RealityKit First

Pros:

- Modern Apple 3D framework.
- Good for entity-style scene composition.

Cons:

- More AR/spatial-computing oriented than this viewport requires.
- Less direct fit for custom meter materials, diagnostics, and renderer-kernel overlays.
- Adds framework assumptions that do not help the current macOS monitor use case.

### WebView / Three.js

Pros:

- Fast iteration and strong browser 3D ecosystem.

Cons:

- Conflicts with the native reusable module goal.
- Reintroduces the DomeLab/WebView dependency path the project explicitly avoids.
- Creates a weaker path for Wavefield and Orbisonic native app integration.

## Consequences

Positive:

- Best long-term control over visual quality, instancing, hit testing, glow, bloom, and Splat overlays.
- Keeps the renderer native for Wavefield, Orbisonic, and Splat.
- Preserves backend-neutral `OrbitalViewCore` contracts.

Negative:

- More engineering work than SceneKit or a browser prototype.
- The first native renderer slice should be small and compile-focused.

## Follow-Up

- Add a bounded task for a minimal `OrbitalViewRender` target and compile-only renderer seam.
- Add a later bounded task for `OrbitalViewSwiftUI` wrapper bindings.
- Keep `mockups/orbital-view-viewport/` as disposable interaction reference, not production code.
