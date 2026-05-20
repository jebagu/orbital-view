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
  HostObjects["Host source-object frames"] --> Adapter
  HostObjectMeters["Host object meter frames"] --> Adapter
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
  Objects["Active object frame set"] --> ObjectPose["Object pose/width/trail inputs"]
  ObjectMeters["Object meter frame"] --> ObjectColor["Object meter skin colors"]
  Camera["Camera state"] --> ViewUniforms["View uniforms"]
  StaticGeometry --> Draw["MTKView draw"]
  VisualState --> Draw
  ObjectPose --> Draw
  ObjectColor --> Draw
  ViewUniforms --> Draw
```

Static speaker geometry, object pose/trail state, meter state, and camera state should stay separate so meter or trail updates do not rebuild the scene.

## Current Renderer Seam Flow

```mermaid
flowchart TD
  Scene["OrbitalViewSceneSpec"] --> State["OrbitalViewRenderState"]
  Meters["SpeakerMeterFrame"] --> State
  MeterSettings["SpeakerMeterVisualSettings"] --> State
  Objects["OrbitalViewObjectFrameSet"] --> State
  ObjectMeters["ObjectMeterFrame"] --> State
  ObjectSettings["ObjectVisualSettings"] --> State
  Camera["OrbitalViewCameraState"] --> State
  Selection["OrbitalViewSelection"] --> Events["OrbitalViewEvent queue"]
  State --> Delegate["OrbitalViewMetalRenderer MTKViewDelegate"]
  Delegate --> Inputs["Static speaker draw inputs + object draw inputs + colors"]
  Inputs --> Pipeline["OrbitalViewMetalDrawPipeline"]
  Pipeline --> Frame["MTKView frame or offscreen texture"]
```

The current renderer seam stores validated state, emits camera/selection events, applies display-only speaker and object visual settings, and issues a minimal Metal draw command for fixed-size speaker/object quads.

## Current Renderer Invariant Flow

```mermaid
flowchart LR
  Scene["Scene speakers"] --> StaticInputs["ID, channel, position, quad radius"]
  Meter["Meter frame"] --> ColorInputs["speaker color/intensity"]
  Settings["Visual gain + style"] --> ColorInputs
  Objects["Active objects"] --> ObjectInputs["object pose/width/trail draw inputs"]
  ObjectMeter["Object meters"] --> ObjectInputs
  Camera["Camera state"] --> State["renderer state"]
  StaticInputs --> Tests["invariant tests"]
  ColorInputs --> Tests
  ObjectInputs --> Tests
  State --> Tests
```

Meter, meter visual setting, object meter, trail, and camera updates must not change the static speaker draw inputs. Speaker meter and display-setting changes affect color/intensity only in the current renderer baseline. Object disappearance is represented by removal from the active object frame set, which also removes trail draw-input ownership.

## Current Object Overlay Flow

```mermaid
flowchart LR
  Wavefield["Wavefield objectId snapshots"] --> Frames["OrbitalViewObjectFrameSet"]
  WavefieldMeters["Object VU levels"] --> Meters["ObjectMeterFrame"]
  Settings["ObjectVisualSettings"] --> Renderer["OrbitalViewRenderState revisions"]
  Frames --> Renderer
  Meters --> Renderer
  Renderer --> DrawInputs["Object cores + capped trail samples"]
  DrawInputs --> Buffers["Retained Metal position/color buffers"]
  Buffers --> Draw["MTKView draw"]
```

Object centers stay canonical unit-sphere directions. The render/effect bounds default to `-5...+5` on x, y, and z; clipping affects object trails/glow/debug visuals, not canonical poses.

## Current SwiftUI Wrapper Flow

```mermaid
flowchart TD
  HostView["Host SwiftUI view"] --> OrbitalView["OrbitalView"]
  Tray["Optional VU settings tray"] --> OrbitalView
  OrbitalView --> Bridge["NSViewRepresentable"]
  Bridge --> MTKView["MTKView"]
  Bridge --> Renderer["OrbitalViewMetalRenderer"]
  Renderer --> Events["camera/selection events"]
  Events --> HostView
```

The current wrapper bridges state into the renderer seam and can show an optional collapsed VU settings tray. It forwards object snapshots and settings without per-frame SwiftUI-owned animation state. It does not implement toolbar controls, gestures, hit testing, or inspector UI yet.

## Current Offscreen Harness Flow

```mermaid
flowchart LR
  Fixture["Deterministic scene fixture"] --> Renderer["OrbitalViewRender"]
  Renderer --> Texture["Offscreen Metal texture"]
  Texture --> Probe["Pixel probes"]
  Probe --> XCTest["XCTest assertions"]
```

The current drawing harness proves non-empty offscreen output without opening a host app or using live audio.

## Current Browser Mockup Music Flow

```mermaid
flowchart LR
  YouTube["YouTube or other tab audio"] --> Capture["Browser tab capture"]
  LocalFile["Local MP3/M4A/WAV"] --> AudioElement["HTML audio element"]
  Capture --> WebAudio["Web Audio analyser"]
  AudioElement --> WebAudio
  Mode["Exclusive VU drive mode"] --> WebAudio
  Mode --> Impulse["Impulse Test drops"]
  WebAudio --> Metrics["RMS / peak / bass"]
  Metrics --> Scalar["VU scalar = RMS"]
  Metrics --> Meter["Normal Music Meter"]
  Scalar --> Mockup["Cube center-bloom VU animation"]
  Impulse --> Mockup
```

This flow is limited to the disposable browser mockup. Music mode lets the user hear music while the page analyzes browser audio, sets the cube VU scalar equal to the RMS percent, and blooms cube faces outward from that scalar. Peak and bass remain visible diagnostics. Impulse Test mode stops browser audio capture/playback and uses only artificial drops. It does not change `OrbitalViewCore`, `OrbitalViewRender`, `OrbitalViewSwiftUI`, host app routing, or production meter ownership.

## Boundary Flow

```mermaid
flowchart TD
  Audio["Host audio and metering"] --> Snapshot["Measured meter snapshot"]
  Objects["Host object positions"] --> Snapshot
  Snapshot --> Viewport["OrbitalViewKit"]
  Viewport --> Selection["Selection and camera events"]
  Selection --> HostUI["Host UI diagnostics"]
```

Orbital View VU Kit consumes measured state and emits UI-facing events. It does not own audio timing, playback, routing, MIDI, OSC, or output behavior.
