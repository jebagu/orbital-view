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
  Camera["OrbitalViewCameraState"] --> State
  Selection["OrbitalViewSelection"] --> Events["OrbitalViewEvent queue"]
  State --> Delegate["OrbitalViewMetalRenderer MTKViewDelegate"]
  Delegate --> Pipeline["OrbitalViewMetalDrawPipeline"]
  Pipeline --> Frame["MTKView frame or offscreen texture"]
```

The current renderer seam stores validated state, emits camera/selection events, and issues a minimal Metal draw command for fixed-size speaker quads.

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
