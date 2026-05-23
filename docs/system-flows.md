# System Flows

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
  Adapter --> Core["OrbitalViewCore scene + meters"]
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

The current wrapper bridges state into the renderer seam. It does not implement toolbar controls, gestures, hit testing, or inspector UI yet.

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

Saved themes, speaker shape, speaker pattern, label font and font size, speaker color palette, cube surface, bloom style, sphere geometry, geodesic appearance, meter source, meter response, performance, and diagnostics are host-facing controls in the current SceneKit review surface. They tune visual/render settings only; they do not own host audio, playback, routing, MIDI, OSC, or meter timing. The review-only impulse drives are deterministic synthetic meter sources for visual stress testing and do not change production host meter contracts. Audio-excited render types use the already-computed mono audio RMS/peak sample as a lightweight spatial-pattern envelope. Dice-icon randomizers are local to Cube Surface, Bloom Style, and Meter Response and do not save themes automatically.

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
