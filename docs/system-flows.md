# System Flows

## Realtime Audio Family Standards Inheritance

This project inherits the Realtime Audio Family Standards Package. The Bencina Realtime Callback Doctrine is mandatory for every callback and every callback-reachable function. Project-specific requirements may add stricter rules but may not weaken the family standard.

Orbital View Kit currently fits the Control / UI / Telemetry Plane plus Preparation Plane adapters. It owns no Realtime Plane and receives host-prepared snapshots rather than direct callback data.

```mermaid
flowchart LR
  HostCallback["Host Realtime Plane callback"] --> HostBridge["Host callback-safe bridge"]
  HostBridge --> Prepared["Prepared scene / meter / object snapshot"]
  Prepared --> Orbital["Orbital View Kit Control / UI / Telemetry Plane"]
  Orbital --> HostUI["Host diagnostics and selection handling"]
```

The callback-safe bridge is owned by the host app, not this package. Orbital View Kit must not block, allocate, route audio, schedule playback, or emit MIDI/OSC from a callback path.

## Current Compliance Audit Flow

```mermaid
flowchart TD
  Standard["Realtime Audio Family Standards Package"] --> Audit["docs/realtime-family-compliance-audit.md"]
  Audit --> Planes["Target-to-plane map"]
  Audit --> Callback["No owned callback entry points"]
  Audit --> Review["Review-only separation"]
  Audit --> OpenSpec["OpenSpec required for future audio-facing changes"]
  Audit --> Hosts["Wavefield / Orbisonic / Splat host-owned boundaries"]
  Audit --> Risks["Explicit remaining risks"]
```

The audit records compliance for Orbital View Kit as a visual telemetry/preparation package. It does not convert renderer, SwiftUI, review, or fixture APIs into callback-safe APIs.

## Current Scaffold Flow

```mermaid
flowchart TD
  WorkPackage["OrbitalViewKit work package"] --> Docs["Project docs"]
  Docs --> Task["First bounded task"]
  Task --> FutureCode["Future OrbitalViewCore source"]
```

## Future Monitor Data Flow

```mermaid
flowchart LR
  HostLayout["Host speaker layout"] --> Adapter["App adapter"]
  HostMeters["Host meter frames"] --> Adapter
  HostSource["Telemetry source descriptor"] --> Adapter
  Adapter --> Core["OrbitalViewCore scene + sourced meters"]
  Core --> Renderer["OrbitalViewRender MetalKit renderer"]
  Renderer --> UI["Host app viewport"]
```

## Future Camera Flow

```mermaid
flowchart TD
  User["User drag or preset click"] --> Wrapper["SwiftUI wrapper"]
  Wrapper --> Camera["OrbitalViewCameraState"]
  Camera --> Validate["Center-lock validation"]
  Validate --> Renderer["MetalKit renderer camera update"]
  Renderer --> Event["cameraChanged event"]
```

## Future Renderer Frame Flow

```mermaid
flowchart LR
  Scene["Validated scene"] --> StaticGeometry["Static Metal buffers"]
  MeterFrame["Latest meter frame"] --> VisualState["Display-rate visual envelope"]
  Camera["Camera state"] --> ViewUniforms["View uniforms"]
  StaticGeometry --> Draw["MTKView draw"]
  VisualState --> Draw
  ViewUniforms --> Draw
```

Static geometry, meter state, and camera state should stay separate so meter updates do not rebuild the scene.

## Current Renderer Seam Flow

```mermaid
flowchart TD
  Scene["OrbitalViewSceneSpec"] --> State["OrbitalViewRenderState"]
  Meters["SpeakerMeterFrame"] --> State
  CubeSettings["SpeakerMeterVisualSettings"] --> State
  Performance["OrbitalViewPerformanceSettings"] --> Wrapper["SwiftUI MTKView bridge"]
  ObjectFrames["OrbitalViewObjectFrameSet"] --> State
  ObjectMeters["ObjectMeterFrame"] --> State
  ObjectSettings["ObjectVisualSettings"] --> State
  Camera["OrbitalViewCameraState"] --> State
  Selection["OrbitalViewSelection"] --> Events["OrbitalViewEvent queue"]
  Wrapper --> Delegate
  State --> Delegate["OrbitalViewMetalRenderer MTKViewDelegate"]
  Delegate --> Inputs["Static speaker cube inputs + display-only meter materials + object inputs"]
  Inputs --> Pipeline["OrbitalViewMetalDrawPipeline"]
  Pipeline --> Frame["MTKView frame or offscreen texture"]
```

The current renderer seam stores validated state, emits camera/selection events, and issues Metal draw commands for instanced cube/prism speakers plus separate object overlay quads.

## Current Telemetry Source And Overload Flow

```mermaid
flowchart LR
  HostSnapshot["Host-prepared complete snapshot"] --> Source["Source descriptor"]
  Source --> Frame["SpeakerMeterFrame / ObjectMeterFrame"]
  Frame --> Latest["Keep latest complete snapshot"]
  Latest --> Display["Display-rate renderer update"]
  Stale["Stale display frames"] --> Drop["Drop or decimate"]
  Drop --> Diagnostics["Diagnostics set outside realtime"]
```

Speaker and object meter frames carry source descriptors such as speaker bus, object bus, final output, hardware tap, local livestream test generator, external Wavefield stream, Orbisonic prepared meter tap, Splat prepared analysis, review local audio, or synthetic visual stress. Overload behavior is lossy on the display side only: stale frames may be dropped, display refresh may be decimated, and diagnostics may be set outside realtime. Audio must never wait for the viewport, callbacks must not allocate more display queue, callbacks must not log or post UI, and raw packets must not enter the renderer.

## Current Visual Telemetry Stress Flow

```mermaid
flowchart LR
  Generator["Local livestream generator metadata"] --> Stress["Visual telemetry stress fixture"]
  Stress --> Speakers["30 physical speakers"]
  Stress --> Objects["128 source objects with capped trails"]
  Stress --> Meters["120 FPS incoming meter cadence"]
  Meters --> Latest["Latest complete display snapshot"]
  Latest --> Viewport["60 FPS active viewport"]
  Meters --> Drops["Stale display frame drops"]
  Drops --> Diagnostics["Overload diagnostics only"]
```

The stress fixture proves display no-backpressure behavior. Dropped display frames are visible as overload diagnostics and are not represented as host audio failure, callback p99 evidence, callback deadline evidence, route repair evidence, device I/O evidence, MIDI/OSC timing evidence, or meter-extraction timing evidence.

## Current Wavefield Realtime Connection Flow

```mermaid
flowchart LR
  External["External Wavefield stream"] --> Wavefield["Wavefield-owned realtime/preparation boundary"]
  Generator["Local livestream test generator"] --> Wavefield
  MIDI["Local MIDI streams"] --> Wavefield
  Wavefield --> Prepared["Prepared scene, speaker meters, object frames, object meters, diagnostics, source metadata"]
  Prepared --> Orbital["Orbital View Kit display contracts"]
  Orbital --> Viewport["Renderer / SwiftUI / review viewport"]
```

Wavefield owns stream parsing, generator timing, MIDI, realtime event queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and performance gates. Orbital View Kit receives prepared snapshots only. Wavefield object IDs remain object identity, speaker channels remain physical speaker identity, generator profile names remain source metadata, disappeared objects are omitted from active object snapshots, and stale display frames may be dropped.

## Current Orbisonic Host Profile Flow

```mermaid
flowchart LR
  Playback["Orbisonic playback / route / render ownership"] --> Taps["Explicit Orbisonic tap points"]
  Taps --> Prepared["Prepared bus, object, speaker meter snapshots + diagnostics + source metadata"]
  Prepared --> Orbital["Orbital View Kit viewport"]
  Orbital --> UIEvents["Camera / selection / diagnostics UI state"]
```

Orbisonic owns playback, transport, device I/O, route discovery, channel mapping, output routing, render/control engines, meter extraction, tap-point selection, operator state, and realtime performance gates. Orbital View Kit receives prepared snapshots, preserves physical channel and object identity, labels Orbisonic meter provenance with `orbisonicPreparedMeterTap`, and follows the Orbisonic design-language palette grammar without owning Orbisonic product behavior.

## Current Splat Host Profile Flow

```mermaid
flowchart LR
  Project["Splat project / authoring state"] --> Prep["Splat preparation and analysis"]
  Prep --> Snapshots["Virtual speakers, source objects, renderer-kernel overlays, neutral geometry, diagnostics"]
  Snapshots --> Orbital["Orbital View Kit viewport"]
  Orbital --> Events["Camera / selection events"]
```

Splat owns edit commands, project/session state, renderer-kernel analysis, file formats, persistence, neutral geometry import/export decisions, and any later handoff to an audio/render host. Orbital View Kit can visualize virtual speakers, source objects, overlays, and diagnostics through prepared snapshots labeled with `splatPreparedAnalysis`. Canonical 3D coordinates remain canonical; permanent flattened screen coordinates are not valid spatial state.

## Current Renderer Invariant Flow

```mermaid
flowchart LR
  Scene["Scene speakers"] --> StaticInputs["ID, channel, position, cube/prism geometry"]
  Meter["Meter frame"] --> ColorInputs["display VU scalar, hot scalar, palette heat, clip"]
  Objects["Object frames/meters"] --> ObjectInputs["object overlay inputs"]
  Camera["Camera state"] --> State["renderer state"]
  StaticInputs --> Tests["invariant tests"]
  ColorInputs --> Tests
  ObjectInputs --> Tests
  State --> Tests
```

Meter, camera, cube-setting, and object-meter updates must not change static speaker draw inputs. Speaker meters affect display-only material values, while object frames/meters remain a separate renderer layer.

## Current SwiftUI Wrapper Flow

```mermaid
flowchart TD
  HostView["Host SwiftUI view"] --> OrbitalView["OrbitalView"]
  OrbitalView --> Bridge["NSViewRepresentable"]
  Bridge --> MTKView["MTKView"]
  Bridge --> Renderer["OrbitalViewMetalRenderer"]
  Renderer --> Events["camera/selection events"]
  Events --> HostView
```

The current production wrapper bridges state into the renderer seam. It does not own SceneKit review tooling, local audio playback, file dialogs, PNG export, theme persistence, toolbar controls, gestures, hit testing, or inspector UI yet.

## Current Review Surface Flow

```mermaid
flowchart TD
  Viewer["OrbitalViewViewer"] --> Review["OrbitalViewReview"]
  Review --> Mockup["OrbitalViewportMockup SceneKit surface"]
  Review --> LocalAudio["Review-only local audio and impulse sources"]
  Review --> Themes["Review-only app-bundle themes and PNG export"]
  Mockup --> Core["OrbitalViewCore display contracts"]
```

`OrbitalViewReview` owns the review/demo SceneKit surface and its local file playback, PNG export, bundled font, and theme behavior. Production host apps import `OrbitalViewSwiftUI` instead.

## Current Tuning Tray Flow

```mermaid
flowchart LR
  Tray["Collapsible tuning trays"] --> SpeakerSettings["SpeakerMeterVisualSettings binding"]
  Tray --> ObjectSettings["ObjectVisualSettings binding"]
  Tray --> PerfSettings["OrbitalViewPerformanceSettings binding"]
  SpeakerSettings --> Renderer["Metal renderer dynamic material state"]
  ObjectSettings --> Renderer
  PerfSettings --> MTKView["MTKView FPS and draw-on-demand config"]
```

Saved themes, speaker shape, speaker pattern, label font and font size, speaker color palette, cube surface, bloom style, sphere geometry, geodesic appearance, meter source, meter response, performance, and diagnostics are review-facing controls in the current SceneKit review surface. They tune visual/render settings only; they do not own host audio, playback, routing, MIDI, OSC, or meter timing. The review-only impulse drives are deterministic synthetic meter sources for visual stress testing and do not change production host meter contracts. Audio-excited render types use the already-computed mono audio RMS/peak sample as a lightweight spatial-pattern envelope. Dice-icon randomizers are local to Cube Surface, Bloom Style, and Meter Response and do not save themes automatically.

## Current Saved Themes Flow

```mermaid
flowchart LR
  Tray["Saved Themes tray"] --> Save["Save visual settings JSON"]
  Save --> Folder["Contents/Resources/View Themes"]
  Folder --> Refresh["Refresh list"]
  Refresh --> Names["Display filename stems"]
  Names --> Load["Load visual settings"]
  Names --> Default["Set default metadata"]
  Default --> Launch["Apply default on next app launch"]
```

View themes are review-app visual settings only. Loading a theme restores viewport styling, camera/view-detail, speaker label font and font size, Cube VU tuning, drive mode, and performance FPS, but it does not restore a local audio file, playback state, or selected speaker.

## Current Offscreen Harness Flow

```mermaid
flowchart LR
  Fixture["Deterministic scene fixture"] --> Renderer["OrbitalViewRender"]
  Renderer --> Texture["Offscreen Metal texture"]
  Texture --> Probe["Pixel probes"]
  Probe --> XCTest["XCTest assertions"]
```

The current drawing harness proves non-empty offscreen output without opening a host app or using live audio.

## Boundary Flow

```mermaid
flowchart TD
  Audio["Host audio and metering"] --> Snapshot["Measured meter snapshot"]
  Snapshot --> Viewport["OrbitalViewKit"]
  Viewport --> Selection["Selection and camera events"]
  Selection --> HostUI["Host UI diagnostics"]
```

Orbital View Kit consumes measured state and emits UI-facing events. It does not own audio timing, playback, routing, MIDI, OSC, or output behavior.
