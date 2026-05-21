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
SpeakerVisualRole
SpeakerMeterFrame
SpeakerMeterLevel
SpeakerMeterVisualSettings
SpeakerMeterVisualStyle
SpeakerMeterColorScheme
OrbitalViewDisplaySettings
OrbitalViewSpeakerDisplayShape
OrbitalViewCameraState
OrbitalViewMode
OrbitalViewProjection
OrbitalViewOrbit
OrbitalViewSelection
OrbitalViewEvent
OrbitalViewValidationError
```

Exact Swift names may vary only if the task explains why.

### Inputs

Inputs are host-provided scene and meter data:

- coordinate system
- shell geometry or parametric shell spec
- physical speaker list
- optional virtual objects later
- meter levels keyed by physical channel
- display-only meter visual settings
- viewport display settings for the required native control surface
- color scheme and checker pulse/ring/diagonal wave controls
- camera state

### Outputs

Core may output:

- validated scene specs
- validation errors
- camera preset states
- selection/event values for renderer or host app use

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
- Edge anchor `t` must be in `0...1`.
- Monitor camera presets must target the origin.
- Meter visual gain must be finite and in `-24...24` dB.
- Checker visual controls must stay in documented finite ranges, including tile detail `4...32`.
- Speaker display scale must be finite and in `0.975...3.9`.
- Fog density must be finite and in `0...100`.

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
- viewport display settings validation and codability
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
```

### Status

Initial seam, minimal smoke-test draw path, static draw-input invariants, meter visual setting plumbing, display setting state, and imported-shell node-anchor projection implemented. Full production drawing, shell rendering, labels, materials, animation, hit testing, and gestures remain deferred.

### Tests Required

- scene updates increment structural revision without touching meter revision
- meter updates increment meter revision without rebuilding scene state
- meter visual settings increment their own revision without touching structural or raw meter revisions
- 30 channel-keyed meter levels map to speakers by physical channel
- checker pulse/ring/diagonal wave is the default meter visual style
- camera updates emit camera events
- selection updates emit selection events
- Metal renderer conforms to `MTKViewDelegate`
- offscreen renderer smoke test produces non-clear pixels when Metal is available
- meter-only updates leave static speaker draw inputs unchanged
- camera-only updates leave static speaker draw inputs unchanged
- draw inputs preserve physical speaker ID/channel order and stable dimensions
- imported shell node anchors project from shell node positions instead of collapsing to the scene center
- display setting updates increment only display-setting state and do not mutate scene or raw meters

## Module: OrbitalViewSwiftUI

### Responsibility

Expose `OrbitalViewRender` through SwiftUI for native host apps.

### Public Interface

Current wrapper skeleton:

```text
OrbitalView
OrbitalViewControlSurface
```

`OrbitalView` accepts a scene, optional meter frame, display settings binding, camera binding, selection binding, event callback, and Export PNG callback. The native viewport control surface is included by default and exposes Plan, Elevation, Isometric, Export PNG, speaker shape, speaker size, speaker numbers, hidden lines, and fog controls. A second initializer accepts `Binding<SpeakerMeterVisualSettings>` and shows a bottom collapsible VU settings tray with display gain, style, color scheme, and checker controls.

### Non-Responsibilities

The wrapper must not:

- own audio processing
- reorder channels
- fake production meter data
- mutate host playback state
- parse downstream app file formats
- import DomeLab code
- embed a WebView as the main renderer path
- remove or bypass the required viewport control surface in normal kit use

### Dependencies

Allowed:

```text
SwiftUI
MetalKit
OrbitalViewCore
OrbitalViewRender
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

Wrapper skeleton plus required viewport control surface and optional VU settings tray implemented. Gestures, inspector UI, hit testing, and production host integration remain deferred.

### Tests Required

- wrapper initializes with camera and selection bindings
- coordinator does not repeat structural updates for identical configuration
- coordinator applies display settings without reloading scene or raw meter state
- coordinator emits camera and selection events
- existing initializer remains tray-free
- settings-bound initializer opts into the tray
- coordinator applies settings-only updates without reloading scene state

## Module: Future Downstream Adapters

### Responsibility

Convert host app data such as Wavefield speaker layouts and meter frames into `OrbitalViewCore` contracts.

### Boundary Rule

Adapters belong in the lowest target that can cleanly depend on both `OrbitalViewCore` and the host app's layout/meter types.

### Status

Deferred until the actual downstream package layout is inspected during the first code task.

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

`OrbitalViewSceneSpec` with 30 physical speakers, Wavefield coordinate system, imported Fey geodesic shell geometry, and node anchors preserving channel order and labels.

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
- The default scene uses the imported Fey geodesic shell with 92 nodes and 270 edges.
- Speaker anchors reference imported shell nodes while channel order remains `1...30`.
- Unsupported axes, invalid speaker count, and invalid unit directions fail explicitly.
- Meter channel records preserve channel identity.
- Duplicate or invalid channels fail explicitly.
- Non-finite RMS/peak values fail explicitly.
- Clip flags derive from the configured peak threshold.
