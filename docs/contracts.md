# Module Contracts

Contracts are binding once implemented. If a task needs to change a contract, document the change before editing code.

## Module: OrbitalViewCore

### Responsibility

Own pure data contracts and validation for an orbital 3D speaker viewport.

### Non-Responsibilities

This module must not:

- render UI or 3D graphics
- depend on SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, or downstream app targets
- parse `.wfield` files
- receive live OSC or MIDI
- decide channel routing
- mutate playback state
- import DomeLab app code

### Public Interface

The first implementation should define Swift value types for:

```text
OrbitalViewSceneSpec
OrbitalViewCoordinateSystem
OrbitalViewVector3
UnitSphereDirection
OrbitalViewShellSpec
OrbitalViewImportedShellGeometry
ShellNode
ShellEdge
ShellFace
OrbitalViewSpeaker
SpeakerAnchor
SpeakerShape
SpeakerFaceCenterBloom
SpeakerVisualRole
SpeakerMeterFrame
SpeakerMeterLevel
SpeakerMeterSample
SpeakerMeterFrameSanitizer
SpeakerMeterVisualSettings
SpeakerMeterVisualStyle
SpeakerMeterColorScheme
OrbitalViewInputDiagnostics
OrbitalViewVisualPreset
OrbitalViewVisualPresetStore
OrbitalViewObjectFrameSet
OrbitalViewObjectFrame
ObjectMeterFrame
ObjectMeterLevel
ObjectVisualSettings
ObjectVisualShape
ObjectVisualPalette
OrbitalViewObjectRenderBounds
OrbitalViewCameraState
OrbitalViewMode
OrbitalViewProjection
OrbitalViewOrbit
OrbitalViewSelection
OrbitalViewEvent
OrbitalViewValidationError
OrbitalColor
OrbitalColorStop
```

Exact Swift names may vary only if the task explains why.

### Inputs

Inputs are host-provided scene and meter data:

- coordinate system
- shell geometry or parametric shell spec
- physical speaker list
- active source-object frames keyed by source-object ID
- object meter levels keyed by source-object ID
- display-only object visual settings for geometry, motion, meter skin, trails, glow trails, and bounds
- meter levels keyed by physical channel
- runtime-safe raw meter samples for sanitizer/adapters
- display-only meter visual settings
- color scheme, platform-neutral theme tokens, VU ramp, cube scalar center-bloom controls, and legacy checker/ripple controls
- camera state

### Outputs

Core may output:

- validated scene specs
- validation errors
- camera preset states
- selection/event values for renderer or host app use
- runtime input diagnostics for missing, extra, invalid, duplicate, replaced, or clamped meter input

Core must not output audio, routing changes, playback state mutations, or UI navigation.

### Validation Rules

- Vector components must be finite.
- Unit directions must reject zero vectors and values too far from unit length unless an explicit normalizing initializer is provided.
- Shell radius must be positive and finite.
- Shell edges and faces must reference known nodes.
- Speaker IDs must be unique inside a scene.
- Physical speaker channels must be positive.
- Physical channels should be unique unless a future contract explicitly allows duplicates for non-physical roles.
- Speaker labels must not be empty after trimming.
- Shape dimensions must be positive and finite.
- Sonic Sphere production speaker shape defaults to `SpeakerShape.cube(edgeM:)`.
- Sonic Sphere rectangular-prism shape uses fixed cube edge dimensions with local z depth scaled from `1.0...2.0`; `1.0` is cube height and `2.0` is two cubes stacked.
- Speaker face-center bloom math uses each visible face's local `(0.5, 0.5)` center; face-local `u` and `v` coordinates must be finite and in `0...1`.
- Edge anchor `t` must be in `0...1`.
- Monitor camera presets must target the origin.
- Meter visual gain must be finite and in `-24...24` dB.
- Meter visual speaker z scale must be finite and in `1...2`.
- `SpeakerMeterVisualStyle.cubeScalarCenterBloom` is the default music-mode style.
- Legacy encoded checker/ripple style aliases decode to `checkerPulseRingAndDiagonalWave`.
- Cube scalar center-bloom controls must stay in finite documented ranges: bloom min/max `0...1`, bloom edge `0.001...1`, response curve `0.2...4`, peak hold `0...3`, release/memory `0...1`, hot fill `0...1`, and face pixels `4...64`.
- `SpeakerMeterColorScheme.daftPunkBow` is the user-facing Daft Punk Bow palette; legacy encoded `techRainbow` values decode to `daftPunkBow`.
- `OrbitalViewTheme` is platform-neutral and carries background, panel, line, text, muted text, accent, secondary accent, success, warning, danger, and VU ramp tokens.
- Checker visual controls must stay in documented finite ranges, including tile detail `4...32`.
- Strict `SpeakerMeterFrame` and `SpeakerMeterLevel` constructors must reject invalid channel/timestamp/value data; runtime host input safety belongs in `SpeakerMeterFrameSanitizer`.
- `SpeakerMeterFrameSanitizer` may replace NaN/inf level values with safe zeros and clamp finite level values to `0...1`, while returning `OrbitalViewInputDiagnostics`.
- `OrbitalViewVisualPreset` is Codable and validates ID, display name, and settings on decode.
- `OrbitalViewCore` exposes only the visual-preset store protocol and remains persistence-free.
- Source-object IDs must be in `1...128`.
- Object frame sets must reject duplicate object IDs.
- Object centers must be represented as unit-sphere directions.
- Object width must be finite and non-negative.
- Active objects must not exceed the frame-set cap, default `128`.
- Trail samples must not exceed the frame-set cap or object visual settings cap.
- Object visual settings must keep trails off by default and cap max trail points to `0...256`.
- Object render/effect bounds default to a cube from `-5...+5` on x, y, and z.

### Side Effects

This module should have no side effects.

### Dependencies

Allowed:

```text
Foundation
```

Forbidden:

```text
SwiftUI
AppKit
MetalKit
AVFoundation
CoreMIDI
networking
Wavefield app targets
Orbisonic app targets
Splat app targets
```

### Tests Required

- unit direction validation
- speaker validation
- shell reference validation
- meter channel identity
- meter visual settings validation
- meter visual style codability
- meter color scheme and checker setting codability
- Daft Punk Bow ramp stops, display name, Codable round trip, and `techRainbow` migration alias
- cube scalar center-bloom default settings, range validation, legacy style migration, and settings Codable defaults
- runtime meter sanitizer clamping, missing/extra channel diagnostics, invalid channel diagnostics, NaN/inf replacement, and timestamp fallback
- visual preset Codable round trip, decode validation, and default reset
- object frame identity, duplicate ID, active-object cap, and trail-cap validation
- object meter identity by object ID
- object visual settings defaults and validation
- center-locked camera presets
- scene validation

## Module: OrbitalViewRender

### Responsibility

Provide the native renderer seam for validated `OrbitalViewCore` scenes.

### Accepted Backend

Production renderer direction:

```text
MetalKit / MTKView custom renderer in OrbitalViewRender
SwiftUI host wrapper in OrbitalViewSwiftUI
```

This decision is documented in `docs/decisions/0002-renderer-backend.md`.

### Non-Responsibilities

The renderer must not:

- own audio processing
- reorder channels
- fake meter data
- mutate host playback state
- parse downstream app file formats
- import DomeLab code
- embed a WebView as the main renderer path
- resize speaker geometry for meter animation

### Public Interface

Current renderer seam:

```text
OrbitalViewRendering
OrbitalViewRenderState
OrbitalViewMetalRenderer
```

Current internal renderer harness:

```text
OrbitalViewMetalDrawPipeline
OrbitalViewOffscreenFrame
OrbitalViewSpeakerDrawInputs
OrbitalViewSpeakerStaticDrawInput
OrbitalViewSpeakerStaticGeometryCacheKey
OrbitalViewObjectDrawInputs
OrbitalViewObjectDrawInput
OrbitalViewObjectStaticDrawInput
```

### Status

Initial seam, instanced cube/prism speaker draw path, procedural face-center bloom shader, Daft Punk Bow ramp uniform path, static draw-input invariants, meter visual setting plumbing, object overlay draw inputs, and retained Metal buffer reuse implemented. Shell rendering, struts, live object smoothing, hit testing, and broad SwiftUI controls remain deferred.

### Tests Required

- scene updates increment structural revision without touching meter revision
- meter updates increment meter revision without rebuilding scene state
- meter visual settings increment their own revision without touching structural or raw meter revisions
- speaker z-scale visual setting updates do not mutate scene speaker shapes or static draw inputs
- 30 channel-keyed meter levels map to speakers by physical channel
- cube scalar center-bloom is the default meter visual style; checker pulse/ring/diagonal wave remains a legacy/impulse-test style
- camera updates emit camera events
- selection updates emit selection events
- Metal renderer conforms to `MTKViewDelegate`
- offscreen renderer smoke test produces non-clear pixels when Metal is available
- meter-only updates leave static speaker draw inputs unchanged
- camera-only updates leave static speaker draw inputs unchanged
- draw inputs preserve physical speaker ID/channel order and stable dimensions
- speaker draw inputs expose cube/prism mesh vertex count, shape depth scale, normal-out orientation, and RMS/peak/clip material payloads
- offscreen pixel probes prove hot/clip meter changes alter color/intensity without changing speaker geometry bounds
- Daft Punk Bow ramp uniform changes offscreen color without changing static speaker geometry
- static speaker geometry cache keys include speaker shape, so cube and rectangular-prism scenes invalidate geometry separately
- channel-to-instance maps preserve scene speaker order and physical channel identity
- repeated meter/settings/camera-only renders reuse retained speaker buffers when capacity is sufficient
- object frame updates increment object frame revision without touching speaker structural revision
- object meter updates increment object meter revision without rebuilding speaker or object static geometry
- object disappearance removes active object draw input and trail ownership
- trails and glow trails share the same capped object draw-input stream
- repeated object rendering reuses retained Metal buffer capacity
- 30 speakers plus 128 active objects with capped trails stay inside the renderer input caps

## Module: OrbitalViewSwiftUI

### Responsibility

Expose `OrbitalViewRender` through SwiftUI for native host apps.

### Public Interface

Current wrapper skeleton:

```text
OrbitalView
OrbitalViewportMockup
```

Current Wavefield host seam:

```text
WavefieldOrbitalViewModel
WavefieldMeterFrameAdapter.makeSanitizedSpeakerMeterFrame(...)
```

The Wavefield host seam consumes cached Fey speaker geometry, `PlayerSnapshot.meterSummary.multichannelLevels`, renderer mode, and Wavefield theme selection. MIDI Track to Speakers, nearest-speaker, and VBAP modes use multichannel levels when available; Mono Equal is the only mode allowed to mirror mono RMS/peak across speaker channels. Empty multichannel levels must stay empty and surface diagnostics rather than creating fake 30-channel meters.

`OrbitalView` accepts a scene, optional speaker meter frame, optional object frame set, optional object meter frame, object visual settings, optional input diagnostics, camera binding, selection binding, and event callback. A second initializer accepts `Binding<SpeakerMeterVisualSettings>` and shows a bottom collapsible VU settings tray with Basic, Advanced, Presets, and Diagnostics sections. The tray can receive an optional `OrbitalViewVisualPresetStore`; persistence is host-provided and never mandatory.

`OrbitalViewportMockup` is a package-local native review surface for the standalone viewer app. It owns a fake meter stream and SceneKit 3D scene only inside that app. It uses Orbisonic design language as the source of truth for native SwiftUI/AppKit-backed control styling, while treating `mockups/orbital-view-viewport/index.html` only as a loose behavior/control-inventory reference. It must keep fixed left/right rails, camera-space SceneKit fog, camera orbit around static content, and deterministic fake review meters separate from production host meter input contracts.

### Non-Responsibilities

The wrapper must not:

- own audio processing
- reorder channels
- fake production meter data
- mutate host playback state
- parse downstream app file formats
- import DomeLab code
- embed a WebView as the main renderer path
- implement production toolbar, gesture, hit-testing, or inspector controls before an explicit task
- own per-frame object animation state in SwiftUI

### Dependencies

Allowed:

```text
SwiftUI
MetalKit
OrbitalViewCore
OrbitalViewRender
```

Allowed only for the standalone native review surface:

```text
AppKit
SceneKit
```

Forbidden:

```text
AVFoundation
CoreMIDI
Wavefield app targets
Orbisonic app targets
Splat app targets
```

### Status

Wrapper skeleton plus optional VU settings tray implemented. The tray includes display settings, speaker height, advanced bloom/checker controls, optional visual-preset save/load/reset actions, and input diagnostics display. `OrbitalViewportMockup` implements the standalone native SwiftUI/SceneKit review screen with Orbisonic-design-language controls. Production toolbar controls, gestures, inspector UI, hit testing, and production host integration remain deferred.

### Tests Required

- wrapper initializes with camera and selection bindings
- coordinator does not repeat structural updates for identical configuration
- coordinator emits camera and selection events
- existing initializer remains tray-free
- settings-bound initializer opts into the tray
- settings-bound initializer can receive optional diagnostics and an optional visual-preset store
- preset actions work through an optional store and no-op safely when persistence is absent
- native viewport mockup preserves browser chrome constants, Fey 30 count, 3V shell counts, camera options, color options, shape options, and fake meter snapshot identity
- diagnostics summaries report missing, extra, invalid, duplicate, replaced, clamped, and timestamp-fallback meter input
- coordinator applies settings-only updates without reloading scene state
- coordinator forwards object frame, object meter, and object visual settings snapshots without reloading scene state

## Module: Future Downstream Adapters

### Responsibility

Convert host app data such as Wavefield speaker layouts and meter frames into `OrbitalViewCore` contracts.

### Boundary Rule

Adapters belong in the lowest target that can cleanly depend on both `OrbitalViewCore` and the host app's layout/meter types.

### Status

Wavefield and Orbisonic now have package-level adapter targets. Splat remains deferred until its package layout is inspected during an explicit task.

## Module: OrbitalViewWavefield

### Responsibility

Convert Wavefield speaker-layout JSON and Wavefield-style meter channel records into `OrbitalViewCore` monitor scene and meter contracts.

### Non-Responsibilities

This module must not:

- edit or depend on the Wavefield package
- parse `.wfield` compositions
- adapt full app-level `VUMeterSnapshot` state
- render UI or 3D graphics
- modify audio, playback, MIDI, OSC, routing, or output behavior

### Public Interface

```text
WavefieldSpeakerLayoutSceneAdapter
WavefieldSpeakerLayoutSceneAdapterError
WavefieldMeterFrameAdapter
WavefieldMeterFrameAdapterError
WavefieldMeterChannelFrame
```

### Inputs

Wavefield speaker layout JSON with:

```text
coordinateSystem.type = unitSphereCartesian
axes x/right, y/up, z/front
mainSpeakerCount = 30
speakers[] channel, label, position
```

### Outputs

`OrbitalViewSceneSpec` with 30 physical speakers, Wavefield coordinate system, and direction anchors preserving channel order and labels.

`SpeakerMeterFrame` with levels keyed by physical channel, preserving missing channels as absent values.

### Dependencies

Allowed:

```text
Foundation
OrbitalViewCore
```

Forbidden:

```text
Wavefield package targets
SwiftUI
AppKit
MetalKit
AVFoundation
CoreMIDI
```

### Tests Required

- Fey 30 fixture maps to 30 speakers.
- Channels remain `1...30`.
- Labels remain `Fey 01...Fey 30`.
- Direction coordinates match the fixture.
- Unsupported axes, invalid speaker count, and invalid unit directions fail explicitly.
- Meter channel records preserve channel identity.
- Duplicate or invalid channels fail explicitly.
- Non-finite RMS/peak values fail explicitly.
- Clip flags derive from the configured peak threshold.

## Module: OrbitalViewOrbisonic

### Responsibility

Define the package-level Orbisonic host seam for native Orbital View integration without importing the Orbisonic app.

Required host contract:

```text
Orbisonic renderer/output monitor
  -> 30 channel VU records
  -> SpeakerMeterFrame
  -> OrbitalView
```

### Non-Responsibilities

This module must not:

- edit or depend on the Orbisonic package
- capture live input
- read audio buffers directly
- derive production routing
- include the LFE/subwoofer channel in the 30 physical speaker viewport
- render UI or 3D graphics
- modify audio, playback, routing, metering, output, Roon, Spotify, or Dante behavior

### Public Interface

```text
OrbisonicOrbitalViewAdapter
OrbisonicOrbitalViewAdapterError
OrbisonicOutputSpeakerRecord
OrbisonicMeterRecord
OrbisonicOrbitalMeterSource
OrbisonicOrbitalColorScheme
OrbitalViewCoordinateSystem.orbisonicMonitor
```

### Inputs

Orbisonic host-owned output speaker records with:

```text
physicalChannel = 1...30
position = unit-sphere-capable x/y/z
label = host display label
```

Orbisonic host-owned meter records with:

```text
physicalChannel = 1...30
rms = normalized display RMS in 0...1
peak = normalized display peak in 0...1
clip = host clip flag
```

The host may derive these records from current Orbisonic types such as renderer output speakers, `ChannelMeter`, or `MeterSnapshot.danteMeters`, but that mapping remains in Orbisonic until a future app integration slice.

### Outputs

`OrbitalViewSceneSpec` with 30 physical speakers using `OrbitalViewCoordinateSystem.orbisonicMonitor`.

`SpeakerMeterFrameSanitizer.Result` with display-safe `SpeakerMeterFrame` values plus diagnostics for missing, extra, invalid, duplicate, replaced, clamped, and timestamp-fallback input.

`OrbisonicOrbitalColorScheme.daftPunkBow` maps directly to `OrbitalViewTheme.daftPunkBow`.

### Dependencies

Allowed:

```text
Foundation
OrbitalViewCore
```

Forbidden:

```text
Orbisonic app targets
Wavefield app targets
SwiftUI
AppKit
MetalKit
AVFoundation
CoreMIDI
```

### Tests Required

- Orbisonic speaker records map to 30 physical speaker scene records.
- Channels remain `1...30`.
- Duplicate, incomplete, or wrong physical channel sets fail explicitly.
- Orbisonic meter records sanitize missing, extra, invalid, duplicate, replaced, and clamped input.
- Daft Punk Bow is present in the Orbisonic color-scheme contract and maps to `OrbitalViewTheme.daftPunkBow`.
