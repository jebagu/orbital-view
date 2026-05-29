# Codex Work Package: OrbitalViewKit 3D Sonic Sphere Viewport

**Project:** Wavefield, with planned reuse in Orbisonic and Splat  
**Module name:** `OrbitalViewKit`  
**Primary implementation target:** Wavefield Receiver Swift/SwiftUI workspace  
**Secondary reuse targets:** Orbisonic monitor app, Splat renderer-kernel authoring tool  
**Status:** Initial product/technical spec, not a full PRD  
**Date:** 2026-05-19

---

## 1. Codex assignment summary

Build the foundation for a modular, portable 3D spherical viewport that can visualize a Sonic Sphere-style speaker shell, live per-speaker meter activity, and later Splat renderer-kernel overlays.

This first work package should **not** attempt to build the entire final renderer. It should create the architecture, contracts, tests, and first integration seam so the eventual production viewport can be implemented without entangling rendering, metering, playback, MIDI, OSC, or routing.

The final module should feel like a high-end technical instrument: beautiful, dark, precise, real-time, centered, orbitable, and clear under live audio metering.

---

## 2. User intent in plain language

The user wants a real 3D model view of a spherical Sonic Sphere. The viewport should show a geodesic or lamella sphere with speakers mounted on the surface shell in a regular pattern. The user should be able to drag/orbit the sphere, switch between isometric and plan/elevation views with simple clicks, and always have the sphere locked in the center of the viewport.

Each speaker is also a VU meter. The speakers should **not** behave like normal vertical VU bars and should **not** resize. Instead, the physical speaker object should remain constant while material, glow, bloom, ring color, and intensity communicate RMS/peak/clip state.

The same code should be reusable in:

```text
Wavefield   -> live Sonic Sphere monitor viewport
Orbisonic   -> similar spherical speaker monitor viewport
Splat       -> standalone renderer-kernel authoring tool with virtual speakers/sources around the sphere
```

The user also likes the DomeLab viewport and wants the relevant view/interaction features translated into this module. DomeLab should be treated as a reference and potential geometry-import source, not as a dependency that dominates Wavefield.

DomeLab reference URL:

```text
https://jebagu.github.io/domelab/
```

---

## 3. Module name

Use the module name:

```text
OrbitalViewKit
```

Reason: the module is not only a Sonic Sphere visualizer. It is a reusable orbital 3D viewport for spatial speaker arrays, spherical shells, live meter state, and optional virtual speaker/source objects around the physical array. The name works for Wavefield, Orbisonic, and Splat without tying the code to only one product or one physical sphere.

Recommended package/target split:

```text
OrbitalViewCore        Pure data contracts, geometry DTOs, validation, coordinate transforms
OrbitalViewRender      Native 3D renderer backend
OrbitalViewSwiftUI     SwiftUI wrapper for Wavefield / Orbisonic / Splat
OrbitalViewDomeLab     DomeLab import/export bridge
OrbitalViewSplat       Optional Splat-only editing/kernel overlays
```

For the first Wavefield implementation slice, start with:

```text
Sources/OrbitalViewCore/
Tests/OrbitalViewCoreTests/
```

Then add renderer integration later:

```text
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewRender/
Tests/OrbitalViewSwiftUITests/
```

---

## 4. Current Wavefield workspace notes

The workspace zip inspected for this work package is:

```text
/mnt/data/wavefield-diagnostic.zip
```

Relevant existing structure from the Wavefield package:

```text
Sources/WavefieldApp/        SwiftUI app shell and tabs
Sources/WavefieldAppSupport/ App-facing package generation and helpers
Sources/WavefieldCore/       Pure data models and validation
Sources/WFieldFile/          .wfield loading, validation, and writing
Sources/WavefieldMIDI/       MIDI parsing, routing, and scheduling support
Sources/WavefieldOSC/        Canonical live OSC parsing and loopback support
Sources/WavefieldPlayback/   Player coordinator, playback services, runtime paths
Sources/WavefieldRenderers/  Spatial renderer boundaries and renderer math
Sources/WavefieldMetering/   Monitor and multichannel meter calculations
Sources/WavefieldOutput/     Output route diagnostics
Sources/WavefieldSpeakerLayout/ Speaker layout loading and validation
```

Relevant existing files:

```text
Package.swift
Sources/WavefieldApp/VUMeterViews.swift
Sources/WavefieldApp/VUTabViewModel.swift
Sources/WavefieldMetering/WavefieldMetering.swift
Sources/WavefieldSpeakerLayout/WavefieldSpeakerLayout.swift
fixtures/speaker-layouts/fey-30-layout.json
.tasks/014-spherical-vu-placeholder.md
docs/contracts.md
docs/architecture.md
docs/status.md
```

Existing related task:

```text
.tasks/014-spherical-vu-placeholder.md
```

That task says the current Spherical VU placeholder should be replaced with an initial viewport that uses the loaded Fey speaker layout and current meter data. It also says the Spherical VU should source positions from the validated speaker-layout loader, source activity from `VUMeterSnapshot`, keep DomeLab/Orbisonic visual assets out until licensing/source paths are known, and avoid adding a full production 3D engine dependency for that diagnostic phase.

This new work package supersedes the placeholder direction at the product level, but the existing task is still useful as a guardrail: keep the first implementation small, testable, and data-driven.

---

## 5. Existing Wavefield data constraints to preserve

From the current workspace and docs, preserve these rules:

```text
- Speaker positions are unit-sphere directions.
- Existing Fey layout is 30 main speakers plus optional sub channel 31.
- The Fey layout coordinate system is unitSphereCartesian.
- Axes are x = right, y = front, z = up.
- Channel numbering is 1-based for human-facing docs.
- Do not flatten canonical spatial coordinates into permanent screen coordinates.
- Do not treat MIDI channel as Wavefield object identity.
- Do not reorder speaker channels inside the viewport.
- Do not fake meter data in the UI.
- Do not silently downmix, truncate, or reorder production multichannel output.
- Keep playback, MIDI, OSC, routing, and file parsing outside the viewport module.
```

Existing speaker loader facts:

```swift
SpeakerLayoutLoader.expectedMainSpeakerCount == 30
```

Existing metering structures:

```swift
public struct MeterFrame: Equatable, Sendable {
    public let rms: Float
    public let peak: Float
}

public struct ChannelMeterFrame: Equatable, Identifiable, Sendable {
    public let channel: Int
    public let rms: Float
    public let peak: Float
}

public struct MultichannelMeterFrame: Equatable, Sendable {
    public let channelFrames: [ChannelMeterFrame]
}
```

The new module should either adapt these existing meter structures or accept an app-level mapping from these structures into `SpeakerMeterFrame`.

---

## 6. Product description

`OrbitalViewKit` is a beautiful, real-time 3D viewport for visualizing a Sonic Sphere-style speaker shell. It renders a geodesic or lamella spherical structure with struts, nodes, optional shell/faces, mounted speakers, and live per-speaker VU activity. The user can drag the model freely, but the sphere always remains locked to the center of the viewport. One-click camera modes switch between plan, elevation, side, and isometric views.

Current planning note: the review app hides the Fey geodesic shell by default because that structure does not reliably match active speaker layouts. Future sphere work must make sphere structure and speaker layout stay in sync before the shell is shown by default again.

For Wavefield and Orbisonic, the first purpose is monitoring: a musician or operator sees which physical Sonic Sphere speakers are being driven and how hard they are being driven. The speakers do not become bar meters and do not resize like a normal VU meter. They remain physical solid objects; their material, ring, bloom, and glow react to the current RMS/peak level.

For Splat, the same viewport becomes an authoring environment. The Sonic Sphere stays as the physical speaker target, while virtual stereo, 5.1, Atmos, or arbitrary speaker/source layouts can be placed around or inside the scene. Splat can then visualize renderer kernels such as nearest-neighbor, VBAP, or future matrix/gain renderers.

---

## 7. DomeLab reference and translation scope

DomeLab is a browser-based sphere/dome design app. The user likes its viewport and wants equivalent view behavior where appropriate.

Include/adapt from DomeLab:

```text
- Center-locked orbit camera
- Plan / elevation / isometric camera presets
- Perspective / orthographic or axonometric projection
- Reset view
- Optional spin/demo mode
- Beautiful dark scene styling
- Fog/depth atmosphere
- Front-hemisphere / cutaway option
- Instanced strut and node rendering
- Selection-ready node/strut/speaker hit testing
- PNG/snapshot export later
- DomeLab geometry import
```

Do not include in this module:

```text
- DomeLab BOM UI
- Fabrication and cost assumptions
- Quote/docx/export flows
- DomeLab's full surface/pattern editor
- Browser local-storage save/load UI
- Non-spherical surfaces for the first Wavefield version
- DomeLab's complete tab model
```

The best DomeLab import path is **not** to port the whole TypeScript app into Swift. Instead, add or consume a neutral geometry export.

Suggested neutral DomeLab/shell geometry schema:

```json
{
  "schema": "orbital-view.shell.v1",
  "source": "DomeLab",
  "units": "meters",
  "coordinateSystem": { "x": "right", "y": "front", "z": "up" },
  "shell": {
    "kind": "geodesic",
    "radiusM": 1.0,
    "nodes": [
      {
        "id": "n001",
        "position": [0.0, 0.5547, -0.8320],
        "normal": [0.0, 0.5547, -0.8320]
      }
    ],
    "edges": [
      { "id": "e001", "a": "n001", "b": "n002", "role": "strut" }
    ],
    "faces": [
      { "id": "f001", "nodes": ["n001", "n002", "n003"] }
    ]
  }
}
```

That gives Wavefield/Orbisonic/Splat a stable import target. DomeLab can still own parametric dome generation; `OrbitalViewKit` owns visualization, live meter state, camera behavior, and app-facing scene contracts.

---

## 8. Core feature set

### 8.1 Real spherical shell model

The viewport renders an actual 3D shell, not a 2D projection.

Supported initial shell types:

```text
Geodesic shell:
- Icosahedron or octahedron base
- Frequency subdivision
- Class I initially; Class II later if needed
- Vertices normalized/projected to spherical radius
- Edges rendered as physical struts/capsules
- Optional triangular faces as transparent glass/mesh panels

Lamella shell:
- Sector count
- Ring count
- Lamella angle / handedness
- Horizontal hoops
- Optional crown/base rings
- Struts rendered as cylinders/capsules along generated spherical paths
```

The renderer should accept either:

```text
A. Parametric shell spec
B. Imported shell geometry from DomeLab
C. Explicit production shell geometry from a future Sonic Sphere source
```

For Wavefield's first version, importing or hardcoding a validated shell is safer than exposing full editing controls. Splat can later enable editing. The shell source and speaker layout must be validated together; do not treat the current review Fey geodesic as a valid default-visible shell for arbitrary active speaker layouts.

### 8.2 Physical speaker objects

Speakers are mounted to the shell surface and displayed as real 3D solids.

Future shell visibility depends on a synchronized shell/speaker contract: each active layout must either derive from the same sphere geometry as the visible shell or explicitly map speakers to stable shell nodes, struts, faces, or directions before the shell is default-visible again.

Speaker visual shapes:

```text
Sphere:
- Good for abstract live meters and channel dots
- Fast to instance
- Easy glow/ring material

Rectangular prism:
- Better physical representation of actual speaker boxes
- Oriented normal-out from the sphere
- Optional bevels/rounded corners later
```

Speaker placement modes:

```text
Explicit unit-sphere direction:
- Matches existing Wavefield speaker layout data.
- Position = direction * shell radius + outward offset.

Node-mounted:
- Speaker is attached to a named shell node.
- Useful when the speaker layout corresponds to geodesic/lamella intersections.

Strut-mounted:
- Speaker is attached to an edge at parameter t = 0...1.
- Position is interpolated along the strut and projected/oriented outward.

Face-mounted:
- Speaker is attached to a face center or barycentric coordinate.
- Useful for future physical model variants.
```

Each speaker should have stable identity:

```text
channel: Int                 // physical Sonic Sphere channel, 1...30
label: String                // e.g. Fey 01
position: UnitSpherePoint
shape: sphere | rectangularPrism
anchor: explicit | node | edge | face
```

No channel reordering should happen inside the viewport. The app gives the module channel identities; the module only visualizes them.

### 8.3 Live VU behavior as material, not size

The speaker mesh size stays constant. Level changes appear through:

```text
- Emissive body tint
- Thin colored ring around or slightly above the speaker
- Halo/bloom near high levels
- Peak flash / short hold
- Optional label brightness
```

Suggested visual mapping:

```text
RMS:
- Controls steady body glow.
- Smooth release, no jitter.

Peak:
- Controls outer ring brightness.
- Short peak hold, then decay.

Near clip / hard drive:
- Add bloom.
- Ring shifts toward white/hot amber.
- Optional brief pulse in emission only, not geometry size.
```

Suggested envelope behavior:

```text
Attack:      8-15 ms
Release:    120-250 ms
Peak hold:  120-300 ms
Display FPS: 60 Hz, independent from audio callback rate
```

The module consumes already-measured levels:

```swift
public struct SpeakerMeterLevel: Sendable, Equatable {
    public let rms: Float      // normalized 0...1 or already scaled
    public let peak: Float     // normalized 0...1
    public let clip: Bool
}

public struct SpeakerMeterFrame: Sendable, Equatable {
    public let timestamp: TimeInterval
    public let levels: [SpeakerMeterLevel]
}
```

Wavefield can derive this from the existing `MultichannelMeterFrame` or app-level meter snapshots.

### 8.4 Center-locked camera and interaction

The sphere must never drift off to the side.

Camera rules:

```text
- Orbit target is always world origin.
- Pan is disabled by default.
- Camera target cannot be dragged away from [0, 0, 0].
- Zoom is allowed but bounded.
- On resize, recompute fit from model bounding sphere.
- Reset returns to the selected canonical view.
- Double-click or toolbar button = frame sphere.
```

Mouse/trackpad interaction:

```text
Drag: rotate/orbit around sphere
Scroll/pinch: zoom
Shift/option drag: disabled in Wavefield; optional in Splat editing mode
Click speaker: select speaker/channel
Click strut/node: optional diagnostics
Double-click selected speaker: focus without moving target off origin
```

Camera presets, expressed in Wavefield coordinates:

```text
Plan:
- Looking from +Z down toward origin.
- Up vector should be +Y or another agreed plan-up convention.

Front elevation:
- Looking from +Y toward origin.
- Up vector = +Z.

Side elevation:
- Looking from +X or -X toward origin.
- Up vector = +Z.

Isometric:
- Looking from a normalized diagonal, e.g. (+X, +Y, +Z).
- Up vector = +Z.
```

DomeLab already has plan/elevation/isometric and perspective/axonometric concepts. Adapt those to Wavefield's `x right / y front / z up` coordinate system rather than copying axes blindly.

### 8.5 View toolbar

Initial Wavefield toolbar:

```text
[Plan] [Front] [Side] [Iso] [Reset]
[Perspective / Orthographic]
[Structure] [Speakers] [Labels] [Cutaway]
```

Optional later toolbar:

```text
[Spin]
[Export PNG]
[Front hemisphere only]
[Show meter trails]
[Show active only]
[Show channel labels]
[Show renderer links]
```

For Splat, the toolbar can grow into an editor toolbar with move/rotate/duplicate/delete modes for virtual speakers.

### 8.6 Beautiful visual style

Visual direction:

```text
- Dark, high-contrast background
- Cyan/teal base accent, compatible with current Wavefield colors
- Metallic or soft ceramic struts
- Slight glass/ghost sphere surface
- Speaker solids with luminous rings
- Bloom only when musically meaningful
- Labels that face camera but do not clutter the viewport
- Far-side speakers dimmed or ghosted
- Optional front-hemisphere clipping/cutaway
```

The structure should look like a real object first and a meter second. It should feel like a high-end technical instrument, not a chart.

---

## 9. Recommended technical direction

Because Wavefield is native macOS SwiftUI, do not embed DomeLab in a WebView as the main path. DomeLab should inform the viewport and provide geometry import, but the reusable app module should be native.

Renderer backend recommendation:

```text
Best long-term choice:
- MetalKit / MTKView custom renderer

Why:
- Best control over instancing, glow, bloom, outlines, hit testing, and future Splat overlays.
- Best path for a renderer-kernel tool where gain matrices, virtual speakers, and animated overlays become important.
- Good fit for a Swift package wrapper around SwiftUI.
```

Avoid making new long-term code SceneKit-first. SceneKit can prototype a 3D viewport quickly, but the contracts should stay backend-neutral so the renderer can move to MetalKit.

Practical recommendation:

```text
Phase 1:
- Build OrbitalViewCore now.
- Build a simple native renderer seam or placeholder SwiftUI integration.
- Keep the renderer behind a protocol so the backend can change.

Phase 2:
- Commit to MetalKit for the production-quality visual pipeline and Splat overlays.

Phase 3:
- Add optional web/Three.js backend only if Splat or another app becomes browser-based.
```

Renderer backend protocol:

```swift
public protocol OrbitalViewRendering {
    func loadScene(_ scene: OrbitalViewSceneSpec)
    func updateMeters(_ frame: SpeakerMeterFrame)
    func updateCamera(_ camera: OrbitalViewCameraState)
    func setViewMode(_ mode: OrbitalViewMode)
    func select(_ id: OrbitalViewSelectableID?)
    func snapshot() async throws -> OrbitalViewImage
}
```

SwiftUI wrapper concept:

```swift
public struct OrbitalView: View {
    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame,
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?>,
        options: OrbitalViewOptions
    )
}
```

---

## 10. Core data contracts

The first Codex implementation should focus on `OrbitalViewCore`, with no dependency on SwiftUI, AppKit, MetalKit, or WavefieldApp.

### 10.1 Scene spec

```swift
public struct OrbitalViewSceneSpec: Sendable, Equatable {
    public let id: String
    public let coordinateSystem: OrbitalViewCoordinateSystem
    public let shell: OrbitalViewShellSpec
    public let speakers: [OrbitalViewSpeaker]
    public let virtualObjects: [OrbitalViewVirtualObject]
    public let theme: OrbitalViewTheme
}
```

For the first implementation, `theme` and `virtualObjects` may be simple placeholder/value types if full renderer styling is deferred.

### 10.2 Coordinate system

```swift
public struct OrbitalViewCoordinateSystem: Sendable, Equatable {
    public let xAxis: AxisMeaning   // right
    public let yAxis: AxisMeaning   // front
    public let zAxis: AxisMeaning   // up
}

public enum AxisMeaning: String, Sendable, Equatable, Codable {
    case right
    case left
    case up
    case down
    case front
    case back
}
```

This must be explicit because DomeLab, Wavefield, and future imported assets may not use the same up/front convention.

### 10.3 Unit-sphere point

If `WavefieldCore.UnitSpherePoint` is available and appropriate, either depend on `WavefieldCore` or add a conversion extension in a Wavefield integration target. Prefer keeping `OrbitalViewCore` portable by defining its own pure unit vector value:

```swift
public struct OrbitalViewVector3: Sendable, Equatable, Codable {
    public let x: Double
    public let y: Double
    public let z: Double
}

public struct UnitSphereDirection: Sendable, Equatable, Codable {
    public let x: Double
    public let y: Double
    public let z: Double

    public init(x: Double, y: Double, z: Double) throws
}
```

Validation:

```text
- Components must be finite.
- Magnitude must be approximately 1.0.
- Reject zero vectors.
- Either normalize with an explicit initializer or require already-normalized input.
```

### 10.4 Shell

```swift
public enum OrbitalViewShellSpec: Sendable, Equatable {
    case parametric(OrbitalViewParametricShell)
    case imported(OrbitalViewImportedShellGeometry)
}

public struct OrbitalViewImportedShellGeometry: Sendable, Equatable {
    public let radiusM: Double
    public let nodes: [ShellNode]
    public let edges: [ShellEdge]
    public let faces: [ShellFace]
}
```

Suggested first-pass shell types:

```swift
public struct ShellNode: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    public let position: OrbitalViewVector3
    public let normal: OrbitalViewVector3?
}

public struct ShellEdge: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    public let a: String
    public let b: String
    public let role: ShellEdgeRole
}

public struct ShellFace: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    public let nodes: [String]
}

public enum ShellEdgeRole: String, Sendable, Equatable, Codable {
    case strut
    case hoop
    case lamella
    case seam
}
```

### 10.5 Speaker

```swift
public struct OrbitalViewSpeaker: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    public let channel: Int
    public let label: String
    public let anchor: SpeakerAnchor
    public let shape: SpeakerShape
    public let visualRole: SpeakerVisualRole
}

public enum SpeakerAnchor: Sendable, Equatable, Codable {
    case direction(UnitSphereDirection, offsetM: Double)
    case node(nodeID: String, offsetM: Double)
    case edge(edgeID: String, t: Double, offsetM: Double)
    case face(faceID: String, barycentric: OrbitalViewVector3, offsetM: Double)
}

public enum SpeakerShape: Sendable, Equatable, Codable {
    case sphere(radiusM: Double)
    case rectangularPrism(widthM: Double, heightM: Double, depthM: Double, bevelM: Double)
}

public enum SpeakerVisualRole: String, Sendable, Equatable, Codable {
    case physicalSpeaker
    case virtualSpeaker
    case source
    case diagnostic
}
```

Validation:

```text
- Channel must be positive.
- Labels must not be empty after trimming.
- IDs must be stable and unique inside a scene.
- Direction anchors must be valid unit directions.
- Edge anchor t must be in 0...1.
- Face barycentric values should be valid once face mounting is implemented.
- Shape dimensions must be finite and positive.
```

### 10.6 Meters

```swift
public struct SpeakerMeterFrame: Sendable, Equatable {
    public let timestamp: TimeInterval
    public let levelsByChannel: [Int: SpeakerMeterLevel]
}

public struct SpeakerMeterLevel: Sendable, Equatable {
    public let rms: Float
    public let peak: Float
    public let clip: Bool
}
```

Validation/clamping:

```text
- Public initializer should clamp or reject non-finite values.
- Prefer clamping visual levels to 0...1 at the visualization mapping layer.
- Do not drop channels silently unless documented.
```

### 10.7 Camera

```swift
public struct OrbitalViewCameraState: Sendable, Equatable {
    public let mode: OrbitalViewMode
    public let projection: OrbitalViewProjection
    public let orbit: OrbitalViewOrbit
    public let target: OrbitalViewVector3
}

public enum OrbitalViewMode: String, Sendable, Equatable, Codable {
    case plan
    case frontElevation
    case sideElevation
    case isometric
    case custom
}

public enum OrbitalViewProjection: String, Sendable, Equatable, Codable {
    case perspective
    case orthographic
}

public struct OrbitalViewOrbit: Sendable, Equatable, Codable {
    public let yawRadians: Double
    public let pitchRadians: Double
    public let distanceM: Double
}
```

Center-lock invariant:

```text
Wavefield monitor mode target must always be origin: [0, 0, 0].
```

### 10.8 Events out

```swift
public enum OrbitalViewEvent: Sendable, Equatable {
    case cameraChanged(OrbitalViewCameraState)
    case selected(OrbitalViewSelection?)
    case speakerHovered(channel: Int?)
    case renderWarning(String)
}
```

The module should output IDs, camera state, and warnings. It should not mutate Wavefield playback state.

---

## 11. Splat reuse

Splat should reuse the same `OrbitalView` and add authoring layers.

Additional Splat inputs:

```swift
public struct VirtualSpeakerLayout: Sendable, Equatable {
    public let id: String
    public let name: String
    public let speakers: [VirtualSpeaker]
    public let layoutKind: LayoutKind   // stereo, 5.1, 7.1.4, Atmos, custom
}

public struct RendererKernelOverlay: Sendable, Equatable {
    public let rendererKind: RendererKind   // nearest, VBAP, custom
    public let sourceObjects: [KernelSource]
    public let gains: [KernelGain]          // source -> Sonic Sphere speaker/channel
}
```

Splat viewport features:

```text
- Show Sonic Sphere physical speakers as the fixed target.
- Add virtual stereo / 5.1 / Atmos speakers around the sphere.
- Allow virtual speakers to be moved in 3D.
- Draw lines/arcs from virtual speakers or sources to driven Sonic Sphere speakers.
- Show gain heatmaps on the physical speaker ring.
- Toggle renderer mode: nearest, VBAP, custom kernel.
- Export camera snapshots and renderer-kernel diagnostics.
```

The key reuse principle:

```text
Wavefield and Orbisonic use the module in monitor mode.
Splat uses it in editor mode.
```

```swift
public enum OrbitalViewInteractionMode {
    case monitor       // Wavefield / Orbisonic
    case inspect       // selectable diagnostics
    case editLayout    // Splat
    case editKernel    // Splat
}
```

---

## 12. App-specific integration

### 12.1 Wavefield

Wavefield should pass:

```text
- Existing Fey 30 speaker layout
- Existing multichannel meter levels
- Current renderer mode
- Optional shell geometry spec/import
- Current source/transport state for labels only
```

Wavefield should not let the viewport:

```text
- Read .wfield files
- Parse MIDI
- Receive OSC
- Render audio
- Decide channel routing
- Modify Player state
```

### 12.2 Orbisonic

Orbisonic should pass the same scene and meter contracts, with a different app theme and possibly different speaker layout. The core module should not know it is inside Orbisonic.

### 12.3 Splat

Splat should pass:

```text
- Sonic Sphere physical shell/speaker scene
- Virtual speaker/source layout
- Renderer-kernel gains
- Editing selection and transform state
```

Splat can enable panning/transform gizmos, but Wavefield should keep pan disabled and sphere centered.

---

## 13. Initial implementation slice for Codex

### 13.1 Include now

```text
- New OrbitalViewCore target in Package.swift.
- New OrbitalViewCoreTests target.
- Pure data contracts for scene, shell, speakers, meter frame, camera, selection, and view options.
- Validation for direction vectors, speaker IDs/channels, shape dimensions, and imported shell references.
- A builder/adapter that converts an existing Wavefield SpeakerLayout into OrbitalViewSceneSpec.
- A simple default shell, such as a generated/imported placeholder sphere shell with enough nodes/edges to test rendering contracts.
- Tests proving Fey 30 layout maps to 30 stable OrbitalViewSpeaker records without changing channel order.
- Tests proving meter frames preserve channel identity.
- Tests proving camera presets are center-locked.
```

### 13.2 Defer

```text
- Full Splat editing tools
- Atmos layout editing
- Renderer-kernel overlays
- Full DomeLab parametric editor
- BOM/fabrication/cost data
- Production model asset licensing
- Complex physically based speaker cabinet models
- User-authored material editor
- Production Metal renderer, if too large for this first Codex pass
```

### 13.3 Optional if time remains

```text
- Add OrbitalViewSwiftUI target with a placeholder/prototype view that compiles.
- Add a lightweight non-3D diagnostic renderer that uses the same OrbitalViewCore scene spec.
- Replace or prepare the Spherical VU tab to consume OrbitalViewCore scene data.
```

The first pass is successful even if it stops at `OrbitalViewCore` plus tests. Do not destabilize the app trying to implement a full renderer in one pass.

---

## 14. Suggested file layout

```text
Sources/OrbitalViewCore/
  OrbitalViewCore.swift
  OrbitalViewSceneSpec.swift
  OrbitalViewCoordinateSystem.swift
  OrbitalViewVector3.swift
  OrbitalViewShell.swift
  OrbitalViewSpeaker.swift
  OrbitalViewMeters.swift
  OrbitalViewCamera.swift
  OrbitalViewSelection.swift
  OrbitalViewValidation.swift
  OrbitalViewSceneBuilder.swift

Sources/WavefieldAppSupport/
  OrbitalViewWavefieldAdapter.swift     // only if the adapter belongs in app support

Tests/OrbitalViewCoreTests/
  OrbitalViewVectorTests.swift
  OrbitalViewSpeakerTests.swift
  OrbitalViewShellTests.swift
  OrbitalViewMeterTests.swift
  OrbitalViewCameraTests.swift

Tests/WavefieldSpeakerLayoutTests/ or Tests/WavefieldAppSupportTests/
  OrbitalViewWavefieldAdapterTests.swift
```

Package additions should be minimal and explicit.

---

## 15. Acceptance criteria

The work package is complete when:

```text
1. `swift build` succeeds.
2. `swift test` succeeds, or any environmental failure is clearly documented.
3. Package.swift exposes a new OrbitalViewCore library target.
4. OrbitalViewCore has no dependency on WavefieldApp, SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, or playback.
5. OrbitalViewCore can represent a scene with:
   - coordinate system
   - shell spec
   - 30 physical speakers
   - meter frame by channel
   - center-locked camera state
6. Existing Fey 30 layout can be adapted into 30 OrbitalViewSpeaker values.
7. Channel order and identity are preserved.
8. Camera preset defaults keep target at origin.
9. Invalid geometry and invalid speaker specs produce explicit errors.
10. The docs or task notes clearly state that production rendering is deferred unless implemented.
```

---

## 16. Test cases to add

### 16.1 Unit direction validation

```text
- Accepts finite normalized direction.
- Rejects NaN/infinite components.
- Rejects zero vector.
- Rejects vector too far from unit magnitude unless using an explicit normalizing initializer.
```

### 16.2 Speaker validation

```text
- Rejects non-positive channel.
- Rejects empty label.
- Rejects duplicate speaker IDs inside a scene.
- Rejects duplicate physical channels inside a scene unless explicitly allowed for virtual/diagnostic roles.
- Rejects negative/zero shape dimensions.
```

### 16.3 Shell validation

```text
- Imported shell references only known node IDs.
- Edges must connect two different existing nodes.
- Faces must reference at least three existing nodes.
- Radius must be positive and finite.
```

### 16.4 Camera validation

```text
- Plan preset target is origin.
- Front elevation preset target is origin.
- Side elevation preset target is origin.
- Isometric preset target is origin.
- Monitor mode disallows non-origin target.
```

### 16.5 Wavefield adapter tests

```text
- Fey 30 fixture produces 30 OrbitalViewSpeaker records.
- Channels are 1...30.
- Labels remain Fey 01...Fey 30.
- Direction values match loaded layout positions.
- No channel reorder occurs in adapter.
```

### 16.6 Meter tests

```text
- SpeakerMeterFrame preserves levels by channel.
- Missing channel means no level for that speaker, not zero unless the renderer explicitly maps it to zero.
- RMS and peak values are finite.
- Clip flag survives adaptation.
```

---

## 17. Renderer behavior specification for later implementation

When implementing `OrbitalViewRender` / `OrbitalViewSwiftUI`, follow these requirements.

### 17.1 Real-time update model

```text
- Audio/metering produces frames independently of visual frame rate.
- UI consumes latest available meter frame on display refresh.
- Smooth visual levels inside renderer, not in audio callback.
- Do not perform heavy geometry rebuilds for meter updates.
- Use instancing for speakers, nodes, and struts when practical.
```

### 17.2 Visual meter mapping

```text
- Mesh dimensions are constant.
- RMS -> body emissive intensity.
- Peak -> ring brightness / peak flash.
- Clip -> bloom/hot accent.
- Release smoothing prevents jitter.
- Far-side speakers may be dimmed but still readable.
```

### 17.3 Camera implementation

```text
- Orbit target fixed at origin in Wavefield monitor mode.
- Panning disabled in Wavefield.
- Zoom bounded by scene radius.
- Preset buttons animate camera or snap camera without changing target.
- The sphere remains centered after resize.
```

### 17.4 Selection

```text
- Clicking a speaker emits channel/ID selection.
- Selection should not mutate playback.
- Selection can be used by Wavefield for diagnostics or channel focus.
```

---

## 18. Risks and decisions

The biggest architectural decision is renderer backend. `MetalKit` is the best fit for visual quality and Splat future, but it is more engineering work than a high-level 3D framework. The contracts should be backend-neutral from day one.

The biggest data decision is DomeLab import. The cleanest route is a neutral exported shell geometry JSON. Parsing DomeLab project config and regenerating geometry in Swift is possible, but it risks divergence. Exported geometry is more reliable.

The biggest UX decision is camera axes. Wavefield's coordinate system is `x right / y front / z up`; plan/elevation presets should be defined against that system explicitly.

---

## 19. Guardrails for Codex

Before changing the repo:

```text
- Read AGENTS.md if present.
- Read docs/contracts.md.
- Read docs/architecture.md.
- Read docs/status.md.
- Inspect Package.swift.
- Inspect Sources/WavefieldSpeakerLayout/WavefieldSpeakerLayout.swift.
- Inspect Sources/WavefieldMetering/WavefieldMetering.swift.
- Inspect Sources/WavefieldApp/VUMeterViews.swift and VUTabViewModel.swift.
```

Implementation guardrails:

```text
- Keep changes small and testable.
- Do not create renderer-side dependencies in OrbitalViewCore.
- Do not move existing Wavefield types unless necessary.
- Do not alter MIDI/rendering/playback behavior.
- Do not change Fey layout fixture values.
- Do not reorder channels.
- Do not fake meter levels.
- Do not introduce a WebView dependency.
- Do not import DomeLab code directly unless explicitly approved.
- Update docs/status.md or add a task note if the repo convention requires it.
```

---

## 20. Suggested Codex execution plan

### Step 1: Repo reconnaissance

Inspect:

```text
AGENTS.md
Package.swift
docs/contracts.md
docs/architecture.md
docs/status.md
Sources/WavefieldSpeakerLayout/WavefieldSpeakerLayout.swift
Sources/WavefieldMetering/WavefieldMetering.swift
Sources/WavefieldApp/VUMeterViews.swift
Sources/WavefieldApp/VUTabViewModel.swift
fixtures/speaker-layouts/fey-30-layout.json
```

### Step 2: Add core target

Modify `Package.swift` to add:

```text
.library(name: "OrbitalViewCore", targets: ["OrbitalViewCore"])
.target(name: "OrbitalViewCore")
.testTarget(name: "OrbitalViewCoreTests", dependencies: ["OrbitalViewCore"])
```

If a Wavefield adapter is implemented in `WavefieldAppSupport`, add `OrbitalViewCore` as a dependency of `WavefieldAppSupport` and the relevant tests.

### Step 3: Implement pure contracts

Create the value types, validation errors, and helper constructors listed in sections 10 and 16.

### Step 4: Implement default scene builder

Add a builder that can create a default monitor scene from a list of physical speaker records.

Pseudo-interface:

```swift
public enum OrbitalViewSceneBuilder {
    public static func makeMonitorScene(
        id: String,
        coordinateSystem: OrbitalViewCoordinateSystem,
        shell: OrbitalViewShellSpec,
        speakers: [OrbitalViewSpeaker]
    ) throws -> OrbitalViewSceneSpec
}
```

### Step 5: Implement Wavefield adapter only if clean

Preferred adapter location:

```text
Sources/WavefieldAppSupport/OrbitalViewWavefieldAdapter.swift
```

Concept:

```swift
import OrbitalViewCore
import WavefieldCore

public enum OrbitalViewWavefieldAdapter {
    public static func makeScene(from layout: SpeakerLayout) throws -> OrbitalViewSceneSpec
}
```

If `SpeakerLayout` is not visible in `WavefieldCore` or is defined elsewhere, place the adapter in the lowest appropriate target that can depend on both `OrbitalViewCore` and the speaker layout module.

### Step 6: Add tests

Add tests for:

```text
- OrbitalViewCore validation
- camera presets
- shell validation
- meter frame channel identity
- Fey 30 adapter mapping, if adapter is implemented
```

### Step 7: Verify

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

If the environment lacks Xcode or SwiftPM cannot run, document the exact error and still provide code changes.

---

## 21. Initial Codex prompt

Use this prompt to hand off the work package to Codex:

```text
You are working in the Wavefield Receiver Swift package. Implement the first modular foundation for a reusable 3D spherical speaker viewport called OrbitalViewKit.

Start with a pure Swift target named OrbitalViewCore. Do not implement the production renderer yet. Do not touch playback, MIDI, OSC, output routing, or audio rendering.

Read AGENTS.md if present, then read Package.swift, docs/contracts.md, docs/architecture.md, docs/status.md, Sources/WavefieldSpeakerLayout/WavefieldSpeakerLayout.swift, Sources/WavefieldMetering/WavefieldMetering.swift, Sources/WavefieldApp/VUMeterViews.swift, Sources/WavefieldApp/VUTabViewModel.swift, and fixtures/speaker-layouts/fey-30-layout.json.

Add OrbitalViewCore and OrbitalViewCoreTests. Implement pure data contracts for:
- coordinate system
- vector/unit-sphere direction
- shell geometry
- speaker anchors and shapes
- scene spec
- speaker meter frame
- camera state and center-locked presets
- selection/event IDs
- validation errors

Keep OrbitalViewCore independent of SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, and WavefieldApp.

If clean, add an adapter that converts the existing Fey/Wavefield SpeakerLayout into an OrbitalViewSceneSpec with 30 physical speakers, preserving channel order and identity. Place the adapter in the lowest target that can depend on both OrbitalViewCore and the existing speaker layout/core types.

Add tests for validation, camera center-lock behavior, meter channel identity, imported shell reference validation, and Fey 30 layout adaptation if the adapter is implemented.

Acceptance criteria:
- swift build succeeds
- swift test succeeds, or exact environment errors are documented
- OrbitalViewCore is a library product/target
- 30 Fey speakers can be represented without channel reorder
- monitor camera presets target the origin
- invalid scene/shell/speaker data produces explicit errors

Do not introduce WebView or DomeLab code dependencies. DomeLab is only a reference and future neutral geometry import source.
```

---

## 22. Future PRD topics

This work package is intentionally not the full PRD. The next PRD should decide:

```text
- Exact production renderer backend: MetalKit vs RealityKit prototype vs other.
- Exact Sonic Sphere physical shell dimensions and mounting geometry.
- Exact speaker cabinet shape and material.
- DomeLab export schema and import responsibility.
- Wavefield tab UI placement and toolbar style.
- Meter color palette and bloom thresholds.
- Splat virtual speaker editing model.
- Splat renderer-kernel visual overlays.
- Snapshot/export requirements.
- Accessibility requirements for channel/meter inspection.
```
