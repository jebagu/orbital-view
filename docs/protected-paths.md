# Protected Paths

## Current Scaffold

Current protected source paths:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

`OrbitalViewCore`, `OrbitalViewWavefield`, and `OrbitalViewOrbisonic` source changes are governed by normal task scope and tests.

Slice 013 explicitly allowed:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

for the standalone native SwiftUI/SceneKit browser-mockup-parity screen. That screen is a package-local review surface and does not change downstream audio, routing, or production renderer contracts.

Slice 014 explicitly allowed:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

for the standalone native SwiftUI/SceneKit control-skin, camera-orbit, SceneKit fog, drag/zoom, and Desktop PNG export cleanup. That screen remains a package-local review surface and does not change downstream audio, routing, production renderer, or host-app contracts.

Slice 015 explicitly allowed:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

for the standalone native SwiftUI/SceneKit viewer responsiveness refactor: removing the root SwiftUI animation timeline, adding capped SceneKit and inspector cadences, and cache-keying SceneKit updates. That screen remains a package-local review surface and does not change browser mockups, downstream audio/routing, production renderer, or host-app contracts.

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
- Meter visual setting updates must not rebuild static geometry.
- Object meter, object trail, and object visual setting updates must not rebuild static speaker geometry.
- Object draw buffers should be retained and reused when capacity is sufficient.
- Speaker geometry must not resize for VU behavior.
- Camera target must remain center-locked in monitor mode.
- Rendering must preserve physical speaker channel identity.
- Renderer source must not own audio callbacks or host app meter timing.
- Renderer source changes are allowed only when the active task explicitly permits `Sources/OrbitalViewRender/`.
- SwiftUI wrapper changes are allowed only when the active task explicitly permits `Sources/OrbitalViewSwiftUI/`.

### Review Required

```text
performance reviewer
architecture reviewer
reliability reviewer
```
