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

## Current Wavefield Orbital View Flow

```mermaid
flowchart LR
  Player["Wavefield PlayerSnapshot"] --> Summary["MeterSummary.multichannelLevels"]
  Mode["Renderer mode"] --> Adapter["WavefieldOrbitalViewModel"]
  Summary --> Adapter
  Mono["Mono RMS/peak"] --> Adapter
  Geometry["Cached Fey Spherical VU geometry"] --> Scene["OrbitalViewSceneSpec"]
  Adapter --> Meter["SpeakerMeterFrame"]
  Adapter --> Diagnostics["OrbitalViewInputDiagnostics"]
  Theme["Wavefield color scheme"] --> OrbitalTheme["OrbitalViewTheme"]
  Scene --> View["Wavefield Orbital View tab"]
  Meter --> View
  Diagnostics --> View
  OrbitalTheme --> Scene
```

MIDI Track to Speakers, nearest-speaker, and VBAP modes use the measured multichannel levels when present. Mono Equal is the only host-selected mode that mirrors mono RMS/peak into every modeled speaker channel. Empty multichannel levels stay empty and surface diagnostics instead of fake 30-channel values.

## Current Orbisonic Host Contract Flow

```mermaid
flowchart LR
  Monitor["Orbisonic renderer/output monitor"] --> Records["30 physical channel VU records"]
  Speakers["Orbisonic output speaker records"] --> Adapter["OrbitalViewOrbisonic adapter skeleton"]
  Records --> Adapter
  Theme["Orbisonic color scheme"] --> Daft["Daft Punk Bow or Orbisonic Lab theme"]
  Daft --> Adapter
  Adapter --> Scene["OrbitalViewSceneSpec"]
  Adapter --> Meter["SpeakerMeterFrame"]
  Adapter --> Diagnostics["OrbitalViewInputDiagnostics"]
  Scene --> View["OrbitalView"]
  Meter --> View
  Diagnostics --> View
```

Orbisonic owns renderer/output monitor state, live input capture, output routing, Dante output, Roon/Spotify/Aux source selection, and meter production. `OrbitalViewOrbisonic` owns only the package-level DTO seam from 30 physical speaker records and normalized VU records into `OrbitalViewCore`. The LFE/subwoofer channel remains outside the 30 physical speaker viewport unless a future task explicitly defines a 30.1 visualization.

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
  RawMeters["Host meter samples"] --> Sanitizer["SpeakerMeterFrameSanitizer"]
  Sanitizer --> MeterFrame["Latest meter frame"]
  Sanitizer --> Diagnostics["OrbitalViewInputDiagnostics"]
  MeterFrame --> VisualState["Display-rate visual envelope"]
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

## Current Meter Input Safety Flow

```mermaid
flowchart LR
  HostSamples["Host channel/rms/peak samples"] --> Sanitizer["SpeakerMeterFrameSanitizer"]
  Expected["Expected physical channels"] --> Sanitizer
  Sanitizer --> StrictFrame["SpeakerMeterFrame"]
  Sanitizer --> Diagnostics["missing/extra/invalid/duplicate/replaced/clamped diagnostics"]
  StrictFrame --> Renderer["OrbitalViewRender state"]
  Diagnostics --> HostUI["Host diagnostics UI"]
```

Strict meter constructors still reject invalid timestamps, channels, and non-finite values. The sanitizer is the runtime-safe adapter path for host UI surfaces that should keep running when a bad sample appears.

## Current Renderer Seam Flow

```mermaid
flowchart TD
  Scene["OrbitalViewSceneSpec"] --> State["OrbitalViewRenderState"]
  Meters["SpeakerMeterFrame"] --> State
  MeterSettings["SpeakerMeterVisualSettings cube scalar center bloom"] --> State
  Objects["OrbitalViewObjectFrameSet"] --> State
  ObjectMeters["ObjectMeterFrame"] --> State
  ObjectSettings["ObjectVisualSettings"] --> State
  Camera["OrbitalViewCameraState"] --> State
  Selection["OrbitalViewSelection"] --> Events["OrbitalViewEvent queue"]
  State --> Delegate["OrbitalViewMetalRenderer MTKViewDelegate"]
  Delegate --> Inputs["Speaker mesh/material inputs + object draw inputs"]
  Inputs --> Pipeline["OrbitalViewMetalDrawPipeline"]
  Pipeline --> Frame["MTKView frame or offscreen texture"]
```

The current renderer seam stores validated state, emits camera/selection events, applies display-only speaker and object visual settings, renders speakers as fixed cube/prism meshes with shader-side center bloom, and keeps object overlays on the simpler quad draw path.

## Current Renderer Invariant Flow

```mermaid
flowchart LR
  Scene["Scene speakers"] --> StaticInputs["ID, channel, position, quad radius, mesh depth"]
  Meter["Meter frame"] --> MaterialInputs["RMS / peak / clip material"]
  Settings["Visual gain + palette + bloom settings"] --> MaterialInputs
  Objects["Active objects"] --> ObjectInputs["object pose/width/trail draw inputs"]
  ObjectMeter["Object meters"] --> ObjectInputs
  Camera["Camera state"] --> State["renderer state"]
  StaticInputs --> Tests["invariant tests"]
  MaterialInputs --> Tests
  ObjectInputs --> Tests
  State --> Tests
```

Meter, object meter, trail, and camera updates must not change the static speaker draw inputs. Speaker meter and display-setting changes affect dynamic material/ramp data only; speaker z-scale settings do not mutate scene speaker shapes. Object disappearance is represented by removal from the active object frame set, which also removes trail draw-input ownership.

## Current Object Overlay Flow

```mermaid
flowchart LR
  HostObjects["Host source-object snapshots"] --> Frames["OrbitalViewObjectFrameSet"]
  HostObjectMeters["Object VU levels"] --> Meters["ObjectMeterFrame"]
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
  Presets["Optional host preset store"] --> Tray
  Diagnostics["Input diagnostics"] --> Tray
  OrbitalView --> Bridge["NSViewRepresentable"]
  Bridge --> MTKView["MTKView"]
  Bridge --> Renderer["OrbitalViewMetalRenderer"]
  Renderer --> Events["camera/selection events"]
  Events --> HostView
```

The current wrapper bridges state into the renderer seam and can show an optional collapsed VU settings tray with Basic, Advanced, Presets, and Diagnostics sections. Preset persistence is optional and host-provided through `OrbitalViewVisualPresetStore`; diagnostics are host-provided through `OrbitalViewInputDiagnostics`. The wrapper forwards object snapshots and settings without per-frame SwiftUI-owned animation state. It does not implement toolbar controls, gestures, hit testing, or inspector UI yet.

## Current Standalone Native 3D Viewer Flow

```mermaid
flowchart LR
  Launcher["Open Native Orbital View VU Kit.command"] --> Builder["scripts/build-orbital-viewer-app.sh"]
  Builder --> App["Orbital View VU Kit.app"]
  App --> Mockup["OrbitalViewportMockup SwiftUI shell"]
  Controls["Camera color shape detail controls"] --> Mockup
  Mockup --> SceneKit["Native SceneKit 3D viewport"]
  SceneKit --> Geometry["Fey 30 speakers + generated 3V shell"]
  SceneKit --> Inspector["Scene metrics selection speaker list"]
  SceneKit --> Export["PNG snapshot export"]
```

The standalone app launches the native SwiftUI/SceneKit review viewport without a downstream host app. Its controls use Orbisonic design language native SwiftUI/AppKit-backed controls; the browser mockup is only a loose behavior/control-inventory reference. The SceneKit viewport keeps sphere content static, orbits the camera around the origin, and uses SceneKit camera-space fog while hidden-line visibility stays separate. Its 30-channel levels are a deterministic fake meter stream for review parity only; they are not a production meter source and do not touch audio, routing, playback, MIDI, OSC, output, or downstream app code. The package-local `OrbitalViewViewerSupport` deterministic data remains available for tests and future review surfaces.

The standalone interaction polish keeps the preferred full-width native button groups, single-track value-hidden sliders, and aligned switch columns. Spin advances horizontally in screen space for Plan, Elevation, and Isometric presets, drag uses coordinator-owned start-pose state with the requested vertical direction, mouse-wheel zoom uses the requested direction, fog density `0` disables all fog/fallback fade behavior, and Export PNG writes a timestamped Desktop file with footer feedback.

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
