# Architecture

## Overview

Orbital View VU Kit will become a layered Swift module family for spherical speaker visualization. The first layer is `OrbitalViewCore`, a pure data and validation target. Rendering, SwiftUI wrapping, and downstream app adapters are future layers.

## Planned Module Layers

```text
OrbitalViewCore
  Pure data contracts, validation, coordinate system, shell/speaker/meter/camera types.

OrbitalViewRender
  MetalKit / MTKView renderer seam with an offscreen-tested cube/prism speaker draw path.

OrbitalViewSwiftUI
  Compile-only SwiftUI wrapper skeleton for host apps.

OrbitalViewDomeLab
  Optional neutral shell geometry import/export bridge.

OrbitalViewSplat
  Optional Splat editor overlays for virtual speakers, source objects, and renderer kernels.

OrbitalViewWavefield
  Local Wavefield speaker-layout JSON and meter-frame adapters into OrbitalViewCore.

OrbitalViewOrbisonic
  Local Orbisonic renderer/output monitor speaker and meter adapter skeleton into OrbitalViewCore.

OrbitalViewViewerSupport
  Deterministic package-local demo scene, speaker meter frame, object frames, object meters, and object visual settings.

OrbitalViewViewer
  Standalone SwiftUI executable harness that launches OrbitalViewSwiftUI without a downstream host app.
```

`OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewOrbisonic`, `OrbitalViewRender`, `OrbitalViewSwiftUI`, `OrbitalViewViewerSupport`, and `OrbitalViewViewer` are implemented. `OrbitalViewRender` now has a Metal draw path that renders speakers as instanced cube/prism meshes with procedural face-center bloom, Daft Punk Bow ramp uniforms, invariant tests for static draw inputs, source-object draw inputs, and retained buffer reuse. The default VU style is music-mode cube scalar center bloom, while checker pulse/ring/diagonal wave remains available as a legacy/impulse-test style. `OrbitalViewSwiftUI` exposes an optional collapsible VU settings tray with Basic, Advanced, Presets, and Diagnostics sections, optional host-provided preset storage, and object overlay forwarding. `OrbitalViewViewer` is a package-local SwiftUI executable harness using deterministic demo data from `OrbitalViewViewerSupport`; it is not a host integration or meter source. The sibling Wavefield app now hosts a guarded native Orbital View tab through a local package dependency while keeping its existing Spherical VU tab available. The Orbisonic seam is currently a package-level adapter skeleton and contract only; it does not edit the Orbisonic app. Shell/strut rendering, toolbar/gesture/hit-testing controls beyond the viewer harness, live object smoothing, and Splat app source integration remain deferred.

## Runtime Architecture

Current package:

```text
OrbitalViewCore tests and validates core scene contracts.
OrbitalViewWavefield converts Wavefield speaker-layout JSON into OrbitalViewCore scenes.
OrbitalViewWavefield converts Wavefield-style channel/rms/peak meter records into SpeakerMeterFrame.
OrbitalViewOrbisonic defines a neutral Orbisonic contract for 30 physical output speaker records and output-monitor VU records, converting them into OrbitalViewCore scenes and sanitized SpeakerMeterFrame values without importing Orbisonic targets.
OrbitalViewCore can sanitize unsafe host meter samples into strict SpeakerMeterFrame values while returning OrbitalViewInputDiagnostics.
OrbitalViewRender stores scene, meter, meter visual settings, camera, and selection state behind a MetalKit renderer seam and renders fixed cube/prism speaker meshes with shader-side face-center bloom for offscreen smoke and pixel-probe tests. Internal draw-input snapshots, static geometry cache keys, and channel-to-instance maps separate static speaker geometry from dynamic RMS/peak/clip material inputs for invariant testing.
OrbitalViewRender also stores active object frames, object meter frames, object visual settings, and separate object revisions for source-object overlays. Object cores and capped trail samples render through the same minimal quad baseline while retaining Metal buffers across repeated draws.
OrbitalViewSwiftUI wraps the renderer seam in an NSViewRepresentable MTKView bridge, can opt into a bottom collapsible VU settings tray, can display host-provided input diagnostics, can use an optional host-provided visual preset store, and forwards object overlay inputs without owning object animation state.
OrbitalViewViewerSupport constructs deterministic 30-channel demo scene data, a static sample speaker meter frame, sample source-object frames, sample object meters, and object visual settings for local viewer smoke use.
OrbitalViewViewer launches OrbitalViewSwiftUI as a standalone SwiftPM executable, passes the support target's demo data into the same public SwiftUI API that host apps use, and exposes package-local camera preset buttons.
The Wavefield app integration builds its scene from cached Fey/Spherical VU speaker geometry, adapts `PlayerSnapshot.meterSummary.multichannelLevels` through `OrbitalViewWavefield`, and passes Wavefield color-scheme tokens into `OrbitalViewTheme`.
The future Orbisonic app integration should consume Orbisonic-owned renderer/output monitor records, use `OrbitalViewOrbisonic` DTOs or an equivalent host-side adapter, and pass `OrbisonicOrbitalColorScheme.daftPunkBow.theme` when the user selects Daft Punk Bow.
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

Current renderer drawing renders scene speakers as fixed-size instanced cube/prism meshes oriented normal-out from existing speaker anchors. RMS drives center fill/body glow, peak drives halo/ring intensity, clip drives a hot flash, and the Daft Punk Bow VU ramp is passed through retained renderer uniforms. Object overlays remain on the simpler quad path. Shell geometry, struts, labels, hit testing, production camera projection, animation, and visual polish are deferred.

Long-term renderer source should not be SceneKit-first, RealityKit-first, WebView-based, or DomeLab-code-based. SceneKit or HTML mockups may be used only as disposable prototypes if a future task explicitly allows that scope.

## Audio Architecture

Orbital View VU Kit does not own audio behavior.

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

Broad viewport UI work is deferred, but the optional VU settings tray in `OrbitalViewSwiftUI` now includes Basic, Advanced, Presets, and Diagnostics sections.

Future UI should provide:

- collapsible display settings for meter visual gain, style, color scheme, cube height, bloom controls, checker controls, preset actions, and diagnostics
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
- speaker face-center bloom distance and Sonic Sphere cube/prism z-scale contracts
- scene specs
- meter frames by channel
- meter visual settings
- runtime meter input sanitizer diagnostics
- visual preset contracts and persistence protocol shape
- platform-neutral theme tokens, VU ramps, meter color schemes, and checker visual controls
- source-object frames by source-object ID
- object meter frames by source-object ID
- object visual settings for geometry, motion, trails, glow trails, and render/effect bounds
- camera state
- selection and events

Persistence is out of scope for core.

## Module Boundaries

Core rules:

- `OrbitalViewCore` has no dependency on SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, or downstream app targets.
- `OrbitalViewCore` remains persistence-free; it exposes visual preset values and a store protocol, but concrete storage belongs in SwiftUI or host-facing targets.
- `OrbitalViewWavefield` depends only on Foundation and `OrbitalViewCore`; it must not depend on Wavefield package targets unless a future task explicitly changes that boundary.
- `OrbitalViewOrbisonic` depends only on Foundation and `OrbitalViewCore`; it must not depend on Orbisonic package targets unless a future task explicitly changes that boundary.
- `OrbitalViewRender` may depend on Metal and MetalKit; it must not depend on SwiftUI, AVFoundation, CoreMIDI, or downstream app targets.
- `OrbitalViewSwiftUI` may depend on SwiftUI, MetalKit, `OrbitalViewCore`, and `OrbitalViewRender`; it must not depend on AVFoundation, CoreMIDI, or downstream app targets.
- `OrbitalViewViewerSupport` may depend only on Foundation and `OrbitalViewCore`; it provides deterministic demo data and must not become a production meter source.
- `OrbitalViewViewer` may depend on SwiftUI, `OrbitalViewCore`, `OrbitalViewSwiftUI`, and `OrbitalViewViewerSupport`; it must stay a standalone package harness and not import Wavefield, Orbisonic, Splat, AVFoundation, CoreMIDI, playback, routing, or output targets.
- Host apps adapt their own layouts and meters into core scene contracts.
- Wavefield host UI exposes `SpeakerMeterColorScheme.daftPunkBow` as `Daft Punk Bow`; the Orbisonic seam exposes `OrbisonicOrbitalColorScheme.daftPunkBow` with the same `OrbitalViewTheme.daftPunkBow` ramp.
- Renderer backends consume core types but do not change their semantic meaning.
- App integrations must preserve speaker channel identity and order.
- Host integrations should pass dirty runtime meter input through `SpeakerMeterFrameSanitizer` before strict frame construction when bad host samples should not crash a UI tab.

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
- Do not rebuild shell or speaker geometry for display-only meter visual setting updates.
- Do not rebuild shell or speaker geometry for camera-only updates.
- Do not mutate scene speaker shape when speaker z-scale display settings change.
- Include speaker shape in the static renderer cache key so cube and rectangular-prism geometry invalidate correctly.
- Keep channel-to-instance mapping stable by scene speaker order and physical channel identity.
- Do not rebuild speaker or object static geometry for object meter-only or trail-only updates.
- Reuse Metal buffers across repeated draws when capacity is sufficient.
- Grow retained buffers when capacity increases; do not allocate new speaker buffers for meter/settings/camera-only renders.
- Keep object animation out of SwiftUI per-frame state; SwiftUI forwards snapshots and settings only.
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
- non-finite runtime meter input is converted only through the sanitizer path and is reported through diagnostics

## Known Risks

- MetalKit gives the needed long-term control but costs more implementation effort than a high-level 3D framework.
- DomeLab geometry import must use a neutral schema to avoid porting browser app internals.
- Future app-embedded Orbisonic and Splat integration locations depend on each host package's active source layout when those slices open.
