# Architecture

## Overview

Orbital View Kit will become a layered Swift module family for spherical speaker visualization. The first layer is `OrbitalViewCore`, a pure data and validation target. Rendering, SwiftUI wrapping, and downstream app adapters are future layers.

## Planned Module Layers

```text
OrbitalViewCore
  Pure data contracts, validation, coordinate system, shell/speaker/meter/camera types.

OrbitalViewRender
  MetalKit / MTKView renderer seam with an initial offscreen smoke-tested draw path.

OrbitalViewSwiftUI
  Compile-only SwiftUI wrapper skeleton for host apps.

OrbitalViewDomeLab
  Optional neutral shell geometry import/export bridge.

OrbitalViewSplat
  Optional Splat editor overlays for virtual speakers, source objects, and renderer kernels.

OrbitalViewWavefield
  Local Wavefield speaker-layout JSON and meter-frame adapters into OrbitalViewCore.
```

`OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewRender`, and the compile-only `OrbitalViewSwiftUI` wrapper skeleton are implemented. `OrbitalViewRender` now has a minimal Metal draw path verified by an offscreen smoke test and invariant tests for static draw inputs. Full production drawing, SwiftUI controls/gestures, and downstream app source integration remain deferred.

## Runtime Architecture

Current package:

```text
OrbitalViewCore tests and validates core scene contracts.
OrbitalViewWavefield converts Wavefield speaker-layout JSON into OrbitalViewCore scenes.
OrbitalViewWavefield converts Wavefield-style channel/rms/peak meter records into SpeakerMeterFrame.
OrbitalViewRender stores scene, meter, camera, and selection state behind a MetalKit renderer seam and can render fixed-size speaker quads for an offscreen smoke test. Internal draw-input snapshots separate static speaker geometry from meter color inputs for invariant testing.
OrbitalViewSwiftUI wraps the renderer seam in an NSViewRepresentable MTKView bridge.
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

## Renderer Backend Decision

Production rendering uses the custom MetalKit / MTKView direction in `OrbitalViewRender`, wrapped by `OrbitalViewSwiftUI` for host-app binding.

Current renderer drawing is intentionally minimal: scene speaker anchors are projected into fixed-size Metal quads and meter values affect color/intensity only. Shell geometry, labels, hit testing, production camera projection, and visual polish are deferred.

Long-term renderer source should not be SceneKit-first, RealityKit-first, WebView-based, or DomeLab-code-based. SceneKit or HTML mockups may be used only as disposable prototypes if a future task explicitly allows that scope.

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
- `OrbitalViewWavefield` depends only on Foundation and `OrbitalViewCore`; it must not depend on Wavefield package targets unless a future task explicitly changes that boundary.
- `OrbitalViewRender` may depend on Metal and MetalKit; it must not depend on SwiftUI, AVFoundation, CoreMIDI, or downstream app targets.
- `OrbitalViewSwiftUI` may depend on SwiftUI, MetalKit, `OrbitalViewCore`, and `OrbitalViewRender`; it must not depend on AVFoundation, CoreMIDI, or downstream app targets.
- Host apps adapt their own layouts and meters into core scene contracts.
- Renderer backends consume core types but do not change their semantic meaning.
- App integrations must preserve speaker channel identity and order.

## External Dependencies

Current implementation dependencies:

```text
Foundation
Metal
MetalKit
SwiftUI
```

Future production rendering may use Apple-native rendering frameworks. A major third-party dependency requires an explicit task decision.

The accepted production rendering framework is MetalKit.

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

- MetalKit gives the needed long-term control but costs more implementation effort than a high-level 3D framework.
- DomeLab geometry import must use a neutral schema to avoid porting browser app internals.
- Downstream Wavefield adapter location depends on actual package visibility when implementation starts.
