# Architecture

## Overview

Orbital View Kit will become a layered Swift module family for spherical speaker visualization. The first layer is `OrbitalViewCore`, a pure data and validation target. Rendering, SwiftUI wrapping, and downstream app adapters are future layers.

## Planned Module Layers

```text
OrbitalViewCore
  Pure data contracts, validation, coordinate system, shell/speaker/meter/camera types.

OrbitalViewRender
  Native renderer backend, expected to be MetalKit when production rendering starts.

OrbitalViewSwiftUI
  SwiftUI wrapper for host apps.

OrbitalViewDomeLab
  Optional neutral shell geometry import/export bridge.

OrbitalViewSplat
  Optional Splat editor overlays for virtual speakers, source objects, and renderer kernels.
```

Only `OrbitalViewCore` is implemented.

## Runtime Architecture

Current package:

```text
OrbitalViewCore tests and validates core scene contracts.
```

Future runtime shape:

```text
Host app
  -> app-owned layout, meter, selection, and camera state
  -> OrbitalViewSwiftUI
  -> OrbitalViewRender
  -> OrbitalViewCore contracts
```

The viewport receives scene and meter state from the host app. It does not parse files, schedule playback, receive OSC, parse MIDI, or decide output routing.

## Audio Architecture

Orbital View Kit does not own audio behavior.

It may consume already-computed meter frames:

```text
channel -> rms / peak / clip
```

It must not:

- run audio callbacks
- perform playback or rendering
- downmix or reorder channels
- make routing decisions
- block timing-sensitive host paths

## UI Architecture

Initial UI work is deferred.

Future UI should provide:

- center-locked orbit camera
- plan, front, side, and isometric presets
- perspective/orthographic toggle
- structure, speakers, labels, and cutaway toggles
- speaker selection events

Wavefield and Orbisonic use monitor mode. Splat may enable edit modes later.

## Data Architecture

`OrbitalViewCore` owns value types for:

- coordinate systems
- 3D vectors and unit-sphere directions
- shell nodes, edges, and faces
- speaker anchors, shapes, and visual roles
- scene specs
- meter frames by channel
- camera state
- selection and events

Persistence is out of scope for core.

## Module Boundaries

Core rules:

- `OrbitalViewCore` has no dependency on SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, or downstream app targets.
- Host apps adapt their own layouts and meters into core scene contracts.
- Renderer backends consume core types but do not change their semantic meaning.
- App integrations must preserve speaker channel identity and order.

## External Dependencies

Current implementation:

```text
Foundation only
```

Future production rendering may use Apple-native rendering frameworks. A major third-party dependency requires an explicit task decision.

## Performance Model

Future renderer constraints:

- Do not rebuild shell or speaker geometry for every meter update.
- Smooth visual envelopes on display refresh, not in audio callbacks.
- Use instancing for repeated speakers, nodes, and struts when practical.
- Keep meter updates separate from structural scene updates.

## Reliability Model

Validation should reject invalid scene data early:

- non-finite vectors
- invalid unit directions
- duplicate speaker IDs
- invalid physical channel identities
- invalid shell references
- non-origin monitor camera targets

## Known Risks

- Renderer backend choice affects long-term visual quality and development cost.
- DomeLab geometry import must use a neutral schema to avoid porting browser app internals.
- Downstream Wavefield adapter location depends on actual package visibility when implementation starts.
