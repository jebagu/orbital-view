# Module Contracts

Contracts are binding once implemented. If a task needs to change a contract, document the change before editing code.

## Realtime Audio Family Standards Inheritance

This project inherits the Realtime Audio Family Standards Package. The Bencina Realtime Callback Doctrine is mandatory for every callback and every callback-reachable function. Project-specific requirements may add stricter rules but may not weaken the family standard.

Orbital View currently fits the Control / UI / Telemetry Plane plus Preparation Plane adapters. It owns no Realtime Plane. Public contracts consume host-prepared telemetry and must not be treated as realtime-callback-safe unless a future OpenSpec change explicitly defines and verifies that guarantee.

The current head project name is `Orbital View`. `Orbital View Kit`, `Orbital View VU Kit`, `Orbital View Turbo`, and `orbital-view-with-objects` are non-head variation labels. Target/type names keep the `OrbitalView*` prefix for source compatibility.

The final adoption audit is `docs/realtime-family-compliance-audit.md`. That audit is the current closeout record for plane ownership, callback inventory, review-only separation, OpenSpec status, host integration boundaries, UI guideline status, and explicit remaining risks.

## Plane Ownership Contract

- Host applications own realtime callbacks, callback-safe queues, routing, playback timing, MIDI, OSC, and meter extraction.
- Orbital View owns validated display contracts for scenes, speaker/object meter snapshots, camera state, selection state, renderer state, and UI diagnostics.
- `OrbitalViewCore` and host adapters may normalize prepared data before rendering, but they must not block or allocate on behalf of a host audio callback.
- `OrbitalViewRender`, `OrbitalViewSwiftUI`, and `OrbitalViewReview` are Control / UI / Telemetry Plane code. They may visualize measured levels and test harness input sources, but they must not fake production meter data or reorder physical speaker channels.

## Final Compliance Contract

Orbital View may be described as realtime-family compliant only in this scope:

- it is a visual telemetry and preparation package;
- it owns no realtime callback entry points;
- no public package target is callback-safe by default;
- host applications own callback p99, callback deadlines, route repair, device I/O, MIDI/OSC, playback, and meter extraction;
- review-only code is separated in `OrbitalViewReview` and must not be imported by production hosts unless a future task explicitly allows it;
- OpenSpec is required for future audio-facing, architecture-facing, or protected-path behavior changes;
- Wavefield local livestream generator profiles are host source metadata, not alternate Orbital View audio paths;
- Orbisonic design language is a UI guideline, not Orbisonic product behavior.

## Telemetry Source And Overload Contract

Every displayed speaker or object meter frame must carry an `OrbitalViewTelemetrySourceDescriptor`. Supported source kinds are `speakerBus`, `objectBus`, `finalOutput`, `hardwareTap`, `localLivestreamTestGenerator`, `externalWavefieldStream`, `orbisonicPreparedMeterTap`, `splatPreparedAnalysis`, `reviewLocalAudio`, and `syntheticVisualStress`.

Display telemetry is latest-complete-frame-wins. Orbital View may drop stale frames, decimate display refresh, keep only the latest complete snapshot, and set diagnostics flags outside realtime paths. It must not make audio wait for the viewport, allocate more display queue from an audio callback, log or post UI from a callback, or send raw packets directly into the renderer.

## SpatGRIS Layout Contract

`OrbitalViewSpatGRIS` imports and exports SpatGRIS `SPEAKER_SETUP` XML for receiver speaker layouts and source-position layouts. It accepts current `4.0.0` files, legacy `SPEAKER_N` files, and fixture-covered import-only older speaker setup XML. Export always writes normalized current `SPEAKER_SETUP` XML.

The target also imports `SPAT_GRIS_PROJECT_DATA` source metadata and parses SpatGRIS source-position OSC payloads at `/spat/serv`. It does not own UDP sockets; production hosts must feed parsed source-position messages explicitly. The review app may run a review-only UDP listener on the SpatGRIS default input port `18032`, constrained to valid user UDP ports `1024...65535`.

Guard rails:

- reject malformed XML, DTD/entity declarations, files larger than the importer limit, invalid coordinate tuples, duplicate patch/source IDs, IDs outside `1...256`, invalid SpatGRIS modes, and invalid OSC ports
- preserve receiver speaker IDs as physical channel IDs
- keep source positions and source/project metadata read-only in the review UI
- place parse warnings, file paths, and raw diagnostics in Diagnostics, not in the primary control panel

## Visual Stress Gate Contract

The display stress gate is defined in `docs/visual-telemetry-stress-gates.md`.

`OrbitalViewVisualTelemetryStressScene` is a fixture contract, not a production meter source. It must preserve 30 physical speaker channels, 128 source object identities, capped object trails, local livestream generator source metadata, and a faster-than-display meter cadence. Display overload must be represented through `OrbitalViewInputDiagnostics.overloadActions`, not through fabricated missing-channel, invalid-channel, replacement, clamping, timestamp, or audio-failure state.

Passing the stress gate proves viewport no-backpressure behavior only. It does not certify callback p99, callback deadline, allocation-free host callback behavior, route repair, device I/O, MIDI/OSC, or host meter-extraction timing.

## Orbisonic Design Language Contract

UI and review-surface work must follow `docs/orbisonic-design-language.md` and the referenced Orbisonic design-language source files. This contract applies to shell layout, visible tuning controls, diagnostics, palette behavior, and visual meter treatment only.

Orbital View must preserve its own module responsibilities and host ownership boundaries. The design language must not be used to import Orbisonic playback, routing, source, transport, or product-specific semantics into this package.

Review criteria for UI changes:

- strict grid alignment
- no page-level active-workflow scrolling
- title-only panel headers
- compact status primary UI
- diagnostics for raw evidence
- no global animation timeline for static shell chrome

Daft Punk Bow remains display-only VU color/material behavior and the canonical successor to Tech Rainbow naming.

## Orbisonic And Splat Host Profile Contract

Orbisonic and Splat host profiles are defined in `docs/integrations/orbisonic-splat-host-profiles.md`.

Orbisonic receives Orbital View as a prepared viewport for bus, object, and speaker meter snapshots from explicit host tap points. Orbisonic keeps ownership of playback, transport, Core Audio device I/O, route discovery, route repair, channel mapping, output routing, render/control engines, meter extraction, operator state, and realtime performance gates. Orbital View must treat Orbisonic tap-point names as source metadata only and should label prepared meter frames with `OrbitalViewTelemetrySourceDescriptor.orbisonicPreparedMeterTap` or a validated descriptor with the same ownership boundary.

Splat receives Orbital View as a preparation/control viewport for virtual speakers, source objects, renderer-kernel overlays, neutral geometry review, camera, selection, and diagnostics. Splat owns authoring/edit commands, project/session state, kernel analysis, geometry import/export decisions, file formats, persistence, and any eventual handoff to an audio/render host. Orbital View should label Splat analysis snapshots with `OrbitalViewTelemetrySourceDescriptor.splatPreparedAnalysis`.

Splat edit/export behavior remains preparation/control behavior until a host applies a prepared snapshot. Canonical 3D coordinates must not be replaced by permanent flattened screen coordinates, and neutral geometry import/export must stay separate from browser or DomeLab runtime code.

Direct downstream source edits require current host repository inspection, explicit protected-path permission, and OpenSpec coverage when behavior or architecture changes.

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
OrbitalViewTelemetrySourceKind
OrbitalViewTelemetrySourceDescriptor
OrbitalViewTelemetryOverloadAction
SpeakerMeterVisualSettings
SpeakerCubeVUScalars
SpeakerMeterFrameSanitizer
OrbitalViewInputDiagnostics
OrbitalViewObjectFrameSet
OrbitalViewObjectFrame
ObjectMeterFrame
ObjectMeterLevel
OrbitalViewSourceLayout
OrbitalViewSource
SourceMeterFrame
SourceMeterLevel
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
- source descriptors identifying meter source-of-truth
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
- Cartesian speaker anchors must contain finite canonical Z-up coordinates.
- Source IDs must be unique and in `1...256`; source positions must be finite.
- Dynamic object IDs must be `1...128`, object trails must stay within frame/settings caps, and object render bounds must be positive.
- Default object render/effect bounds are fixed at `-5...+5` on x, y, and z through `OrbitalViewObjectRenderBounds(halfExtent: 5)`.
- Performance settings must keep active viewport FPS to `30` or `60`, meter-only viewport cadence in `1...30`, inspector refresh cadence in `1...30`, and draw-on-demand enabled by default.
- Monitor camera presets must target the origin.
- Speaker meter frames must carry a valid telemetry source descriptor; the default is `speakerBus`.
- Object meter frames must carry a valid telemetry source descriptor; the default is `objectBus`.
- Telemetry source labels must be non-empty after trimming and no longer than 96 characters.
- Telemetry source details, when provided, must be non-empty after trimming and no longer than 160 characters.

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
- meter source descriptor defaults and validation
- telemetry overload diagnostics
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
- meter frame source descriptors remain metadata and must not affect static geometry, routing, or channel mapping

## Module: OrbitalViewSwiftUI

### Responsibility

Expose `OrbitalViewRender` through SwiftUI for native host apps.

### Public Interface

Current wrapper skeleton:

```text
OrbitalView
```

`OrbitalView` accepts a scene, optional speaker meter frame with source descriptor, optional object frames/meters/settings with source descriptors where applicable, optional performance settings, input diagnostics, camera binding, selection binding, and event callback. A value-based initializer keeps existing host call sites source-compatible. A binding initializer opts into native collapsible tuning trays with bindings to `SpeakerMeterVisualSettings`, `ObjectVisualSettings`, and `OrbitalViewPerformanceSettings`, plus an optional visual preset store.

### Non-Responsibilities

The wrapper must not:

- own audio processing
- own local file playback
- own file dialogs or PNG export
- reorder channels
- fake production meter data
- mutate host playback state
- persist review themes or app-bundle review settings
- parse downstream app file formats
- import DomeLab code
- import SceneKit review tooling
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
SceneKit
CoreMIDI
Wavefield app targets
Orbisonic app targets
Splat app targets
```

### Status

SwiftUI wrapper and optional collapsible tuning trays are implemented. The production target is limited to `OrbitalView`, `OrbitalViewMetalView`, host bindings, the MetalKit bridge, and production-safe tuning controls. Review-only SceneKit, local audio, file-dialog, PNG export, font-resource, and theme persistence behavior lives in `OrbitalViewReview` and does not change the public `OrbitalView` API. Gestures, hit testing, full inspector UI, and production host integration remain deferred.

### Tests Required

- wrapper initializes with camera and selection bindings
- coordinator does not repeat structural updates for identical configuration
- coordinator forwards cube VU settings without reloading scene state
- coordinator forwards object frames/meters/settings without reloading scene state
- coordinator emits camera and selection events

## Module: OrbitalViewReview

### Responsibility

Own review/demo-only visual tuning surfaces for the package, including the confirmed SceneKit geodesic viewport mockup hosted by `OrbitalViewViewer`.

### Public Interface

Current review surface:

```text
OrbitalViewportMockup
```

### Non-Responsibilities

This target must not:

- provide the production host-app wrapper
- establish realtime callback safety
- own production audio processing, routing, playback timing, MIDI, OSC, or output behavior
- synthesize production meter truth
- reorder physical speaker channels
- become a dependency of production host integrations unless an explicit future task accepts that boundary

### Dependencies

Allowed:

```text
Foundation
SwiftUI
AppKit
AVFoundation
SceneKit
CoreText
UniformTypeIdentifiers
OrbitalViewCore
```

Forbidden:

```text
OrbitalViewSwiftUI as a required production wrapper dependency
OrbitalViewRender as a production renderer replacement
CoreMIDI
Wavefield app targets
Orbisonic app targets
Splat app targets
```

### Status

The review target owns the SceneKit surface, local file playback for visual testing, `NSOpenPanel`, full-window PNG export, app-bundle theme JSON persistence, CoreText font registration, AppKit-generated speaker label textures, and bundled review fonts. It is Control / UI / Telemetry Plane review tooling only.

### Tests Required

- review-app identity and window contract remain intact
- single right-panel `Input` tray source selector inventory remains exactly `Telemetry`, `Local Song`, and `Impulse Test`
- telemetry mode remains silent when no provider is connected and must not fake live telemetry
- local audio file metering remains review-only and mono-reduced
- local song transport controls and impulse pattern controls remain scoped to their source trays
- theme JSON persistence round trips visual settings without restoring local audio file state
- PNG export remains available from the review surface
- SceneKit material and label rebuild invariants stay separate from production renderer contracts

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
axes x/right, y/front, z/up
mainSpeakerCount = 30
speakers[] channel, label, position
```

### Outputs

`OrbitalViewSceneSpec` with 30 physical speakers, Wavefield coordinate system, and direction anchors preserving channel order and labels.

`SpeakerMeterFrame` with levels keyed by physical channel, preserving missing channels as absent values.

`SpeakerMeterFrame` source `.externalWavefieldStream` by default, or a more specific caller-provided Wavefield-compatible source such as `.localLivestreamTestGenerator`.

Wavefield realtime integration is defined in `docs/integrations/wavefield-realtime-connection.md`. Wavefield owns external live stream parsing, the local livestream test generator, MIDI streams, realtime event queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and performance gates. Orbital View receives only prepared scene, speaker meter, object frame, object meter, diagnostics, and source metadata snapshots.

Wavefield object IDs remain source-object identity for `OrbitalViewObjectFrame.objectID` and `ObjectMeterFrame.levelsByObjectID`. Physical speaker channels remain speaker identity for `OrbitalViewSpeaker.channel` and `SpeakerMeterFrame.levelsByChannel`. Generator profile names are source metadata only, not audio path branches. Object disappear is represented by omitting that object ID from the next prepared `OrbitalViewObjectFrameSet.activeObjects` snapshot. Missing or stale display frames may be dropped under the telemetry overload contract.

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
