# Protected Paths

## Current Scaffold

There are Swift package source paths in this repository, but no protected source paths yet. Current `OrbitalViewCore` and `OrbitalViewWavefield` source changes are governed by normal task scope and tests.

## Protected Path: Downstream Audio And Routing Integrations

### Applies When

A future task edits Wavefield, Orbisonic, Splat, or another host app.

### Examples

```text
Sources/WavefieldPlayback/
Sources/WavefieldRenderers/
Sources/WavefieldMetering/
Sources/WavefieldMIDI/
Sources/WavefieldOSC/
Sources/WavefieldOutput/
Sources/WavefieldSpeakerLayout/
```

Exact protected paths must be verified in the downstream repository before editing.

### Invariants

- Do not block timing-sensitive audio paths.
- Do not change playback state transitions without explicit approval.
- Do not change MIDI, OSC, rendering, routing, output, or metering semantics casually.
- Do not downmix, truncate, reorder, or fake channel data.
- Do not let UI own audio timing behavior.

### Allowed Changes

Only allowed when an active task or work-package slice explicitly permits that protected path.

### Review Required

```text
audio reviewer
performance reviewer
reliability reviewer
architecture reviewer
protected path reviewer
```

## Protected Path: Future Production Renderer

### Applies When

`OrbitalViewRender` or `OrbitalViewSwiftUI` exists.

Accepted backend:

```text
MetalKit / MTKView renderer with SwiftUI wrapper
```

### Invariants

- Meter updates must not rebuild static geometry every frame.
- Speaker geometry must not resize for VU behavior.
- Camera target must remain center-locked in monitor mode.
- Rendering must preserve physical speaker channel identity.
- Renderer source must not own audio callbacks or host app meter timing.

### Review Required

```text
performance reviewer
architecture reviewer
reliability reviewer
```
