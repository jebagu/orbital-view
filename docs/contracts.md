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
SpeakerCubeVUScalars
SpeakerMeterFrameSanitizer
OrbitalViewInputDiagnostics
OrbitalViewObjectFrameSet
OrbitalViewObjectFrame
ObjectMeterFrame
ObjectMeterLevel
ObjectVisualSettings
OrbitalViewPerformanceSettings
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
- optional dynamic object frames and object meter levels keyed by source object ID
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
- Shape dimensions must be positive and finite. Sonic Sphere speaker defaults use cube geometry.
- Cube VU control ranges must stay finite and within the browser-derived contract: input calibration `0.25...2`, level compression `1...4`, display ceiling `0.5...1`, hot response `0.5...3`, hot threshold `0.35...0.98`, hot fill strength `0...1`, palette drive `0.5...4`, idle tint `0...1`, checker contrast `0...0.4`, and face pixels `4...64`.
- Edge anchor `t` must be in `0...1`.
- Dynamic object IDs must be `1...128`, object trails must stay within frame/settings caps, and object render bounds must be positive.
- Default object render/effect bounds are fixed at `-5...+5` on x, y, and z through `OrbitalViewObjectRenderBounds(halfExtent: 5)`.
- Performance settings must keep active viewport FPS to `30` or `60`, meter-only viewport cadence in `1...30`, inspector refresh cadence in `1...30`, and draw-on-demand enabled by default.
- Monitor camera presets must target the origin.

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
OrbitalViewObjectDrawInputs
```

### Status

Instanced cube/prism speaker drawing, cube scalar center-bloom materials, retained speaker/object buffers, object overlay drawing, offscreen smoke/pixel-probe tests, and native SwiftUI tuning trays are implemented. Shell rendering, labels, hit testing, and live object smoothing remain deferred.

### Tests Required

- scene updates increment structural revision without touching meter revision
- meter updates increment meter revision without rebuilding scene state
- camera updates emit camera events
- selection updates emit selection events
- Metal renderer conforms to `MTKViewDelegate`
- offscreen renderer smoke test produces non-clear pixels when Metal is available
- meter-only updates leave static speaker draw inputs unchanged
- camera-only updates leave static speaker draw inputs unchanged
- draw inputs preserve physical speaker ID/channel order and stable dimensions
- cube VU material payloads expose display VU scalar, hot scalar, palette heat, and clip without changing static geometry
- object frame/meter/settings updates stay separate from speaker static geometry
- repeated speaker/object renders reuse retained Metal buffer capacity

## Module: OrbitalViewSwiftUI

### Responsibility

Expose `OrbitalViewRender` through SwiftUI for native host apps.

### Public Interface

Current wrapper skeleton:

```text
OrbitalView
```

`OrbitalView` accepts a scene, optional speaker meter frame, optional object frames/meters/settings, optional performance settings, input diagnostics, camera binding, selection binding, and event callback. A value-based initializer keeps existing host call sites source-compatible. A binding initializer opts into native collapsible tuning trays with bindings to `SpeakerMeterVisualSettings`, `ObjectVisualSettings`, and `OrbitalViewPerformanceSettings`, plus an optional visual preset store.

### Non-Responsibilities

The wrapper must not:

- own audio processing
- reorder channels
- fake production meter data
- mutate host playback state
- parse downstream app file formats
- import DomeLab code
- embed a WebView as the main renderer path
- implement production controls or gestures before an explicit task

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

SwiftUI wrapper and optional collapsible tuning trays are implemented. The review-only SceneKit surface organizes the active right-panel controls into Theme, Speaker Appearance, Sphere Appearance, Meter Behavior, and Diagnostics sections. It includes `Saved Themes` JSON persistence with selected speaker-label font and font size, geodesic palette, audio render mode, and stable `themeID` metadata under the app bundle resources, plus `Speaker Shape`, future `Speaker Pattern` and `Sphere Geometry` placeholders, `Label Font`, speaker `Color Palette`, `Cube Surface`, `Bloom Style`, `Geodesic Appearance`, `Meter Source`, `Meter Response`, `Performance`, and `Diagnostics`; this does not change the public `OrbitalView` API. `Cube Surface`, `Bloom Style`, and `Meter Response` include review-only dice randomizers. Speaker height remains decodable from older JSON through `OrbitalViewportCubeVUSettings`, but it is ignored by the review surface. Gestures, hit testing, full inspector UI, and production host integration remain deferred.

### Tests Required

- wrapper initializes with camera and selection bindings
- coordinator does not repeat structural updates for identical configuration
- coordinator forwards cube VU settings without reloading scene state
- coordinator forwards object frames/meters/settings without reloading scene state
- coordinator emits camera and selection events

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
