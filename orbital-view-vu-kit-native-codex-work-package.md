# Codex Work Package: Orbital View VU Kit — Native Swift / Wavefield / Orbisonic

**Project:** Wavefield reusable visual module, with planned reuse in Orbisonic and later merge compatibility with `Orbital View with Objects`
**Module:** `OrbitalViewKit`
**Primary native targets:** `OrbitalViewCore`, `OrbitalViewRender`, `OrbitalViewSwiftUI`, `OrbitalViewWavefield`
**Host apps:** Wavefield first, Orbisonic second
**Renderer:** Apple-native MetalKit / MTKView through SwiftUI
**Status:** Codex-ready continuation package after existing completed slices 001–011
**Date:** 2026-05-20

---

## 0. Assignment summary

Continue `OrbitalViewKit` into the **3D Sonic Sphere spherical VU meter** now called **Orbital View VU Kit**.

The kit must be a reusable visual instrument that can live as a tab in Wavefield and Orbisonic. It consumes host-provided 30-channel meter frames and renders the Sonic Sphere speaker layout as a centered, performant, beautiful 3D viewport.

The native package must:

- keep the existing Orbital View viewport controls and viewports exactly as designed in the current project;
- add the Sonic Sphere VU speaker visuals;
- support cube speakers as the default and a rectangular-prism option by stretching speaker local z height from one cube to two cubes stacked;
- use each face center as the VU bloom center;
- add a collapsible VU settings tray with save/default preset support;
- add **Daft Punk Bow** as the first-class rainbow VU palette;
- remain resilient when the host passes missing, extra, clamped, or otherwise wrong meter data;
- remain high performance in Swift/Metal;
- stay merge-compatible with a separate tree called `Orbital View with Objects`.

Do **not** implement browser/web standalone work in this native package. The web work has its own separate package.

---

## 1. Current context and preflight warning

The uploaded Orbital View context describes completed slices 001–011:

```text
001 OrbitalViewCore Foundation
002 Wavefield Layout JSON Adapter
003 Wavefield Meter Frame Adapter
004 Orbital Viewport Visual Mockup
005 Renderer Backend Decision
006 OrbitalViewRender Target Seam
007 OrbitalViewSwiftUI Wrapper Skeleton
008 Renderer Test Harness Plan
009 Offscreen Renderer Smoke Test
010 Renderer Invariant Tests
011 VU Meter Plumbing And Settings Tray
```

The current docs say the accepted native production renderer is MetalKit / MTKView, wrapped by SwiftUI. The current renderer has a minimal offscreen draw path and invariant tests for static speaker draw inputs. The current SwiftUI wrapper has an opt-in collapsed VU settings tray.

However, the uploaded package snapshot does **not** build as-is. A local preflight build failed because several core source files or fixture resources referenced by tests/source were missing from the archive, including types such as:

```text
OrbitalViewCoordinateSystem
OrbitalViewShellSpec
OrbitalViewParametricShell
OrbitalViewImportedShellGeometry
OrbitalViewSpeaker
SpeakerAnchor
SpeakerShape
OrbitalViewVector3
UnitSphereDirection
ShellNode
ShellEdge
ShellFace
OrbitalViewSceneBuilder
WavefieldSpeakerLayoutSceneAdapter
Tests/OrbitalViewWavefieldTests/Fixtures/fey-30-layout.json
```

Therefore the first slice is a restore/verification slice, not feature work.

Codex must not assume the package is complete until `swift build` and `swift test` pass on the actual working tree.

---

## 2. Product rules to preserve

### 2.1 OrbitalViewKit is a visual consumer, not an audio owner

The kit must not:

```text
parse .wfield files
own AVFoundation, CoreAudio, MIDI, OSC, playback, routing, or renderer timing
open audio devices
run Wavefield or Orbisonic audio renderers
invent fake production meter data
mirror mono except in explicit host-selected Mono Equal mode
reorder physical channels
claim physical-output verification from chunk-cache or event-derived meters
```

The host app provides:

```text
scene/layout
30-channel VU frames when available
theme
camera state
selection state
settings/preset persistence policy if needed
```

OrbitalViewKit renders only what it is given.

### 2.2 Physical speaker identity is channel identity

The stable join key is the physical speaker channel:

```text
SpeakerLayout channel -> OrbitalViewSpeaker.channel -> SpeakerMeterFrame.levelsByChannel[channel]
```

Do not join by array index, MIDI channel, screen coordinate, object ID, or label.

### 2.3 VU changes material, not geometry size

Speaker geometry must stay fixed for the selected shape. RMS/peak/clip affect only material, glow, ring, halo, bloom, label brightness, or clip flash.

Do not scale speaker size as a VU bar.

---

## 3. Public native shape

The durable SwiftUI entry point should remain close to:

```swift
OrbitalView(
    scene: OrbitalViewSceneSpec,
    meters: SpeakerMeterFrame?,
    meterVisualSettings: Binding<SpeakerMeterVisualSettings>,
    theme: OrbitalViewTheme,
    camera: Binding<OrbitalViewCameraState>,
    selection: Binding<OrbitalViewSelection?>,
    diagnostics: OrbitalViewInputDiagnostics?,
    settingsStore: OrbitalViewSettingsStore?,
    onEvents: @escaping ([OrbitalViewEvent]) -> Void
)
```

Codex may introduce a configuration struct if that keeps the initializer manageable:

```swift
public struct OrbitalViewConfiguration: Equatable, Sendable {
    public var scene: OrbitalViewSceneSpec
    public var meters: SpeakerMeterFrame?
    public var meterVisualSettings: SpeakerMeterVisualSettings
    public var theme: OrbitalViewTheme
    public var camera: OrbitalViewCameraState
    public var selection: OrbitalViewSelection?
    public var diagnostics: OrbitalViewInputDiagnostics?
    public var viewportControls: OrbitalViewViewportControls
}
```

Keep `OrbitalViewCore` independent of SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, and host app targets.

---

## 4. Speaker geometry contract

### 4.1 Default shape

Default production speaker shape:

```text
cube
```

Cubes should look like the Sonicsphere cube VU prototype: solid, physical, Minecraft-like, not spheres and not traditional VU bars.

### 4.2 Rectangular-prism option

Add an option to stretch the speaker along its local z dimension:

```swift
public enum SpeakerShape: Equatable, Codable, Sendable {
    case cube(edgeM: Double)
    case rectangularPrism(edgeM: Double, zScale: Double)
}
```

Required validation:

```text
edgeM > 0
zScale finite
zScale range: 1.0...2.0
zScale 1.0 == cube
zScale 2.0 == two cubes stacked
```

If the existing tree already has `SpeakerShape`, extend it additively instead of replacing it. If the existing local frame defines a different speaker local z convention, use that convention. The user-facing control should say something like:

```text
Speaker Height: Cube -> 2 Cubes
```

Do not make shape height depend on the VU level.

### 4.3 Face-center VU rule

Every visible face uses its own face-local center as the VU origin:

```text
u = face-local x in 0...1
v = face-local y in 0...1
faceCenter = (0.5, 0.5)
distance = hypot(u - 0.5, v - 0.5) * sqrt(2)
```

For a rectangular prism, each face still blooms from its own center. Do not use the object center as a shared VU origin for all faces.

---

## 5. Music visual mapping

The production music mapping is **cube/prism scalar center bloom**.

For each speaker channel:

```text
rms  -> center bloom radius, body emission, steady color heat
peak -> halo/ring brightness and short peak hold
clip -> hot flash / danger edge / stronger bloom
```

Default music math:

```text
vuScalar = sanitizedRMS
heat = compressVu(vuScalar)
radius = lerp(bloomMin, bloomMax, pow(vuScalar, radiusCurve))
fill = 1 - smoothstep(radius, radius + bloomEdge, distanceFromFaceCenter)
idleBase = mix(panel, accent, idleTint)
vuColor = sampleVuStops(theme.vuRamp, heat)
hotColor = final theme.vuRamp stop
hot = hotFillStrength * smoothstep(hotThreshold, 1.0, peakOrHeldEnergy)
tileColor = mix(mix(idleBase, hotColor, hot), vuColor, fill)
```

Peak and clip can affect halo/edge/hot fill, but the normal music face bloom should be driven primarily by RMS.

### 5.1 Visual styles

Update or extend the style enum so the new default is first-class:

```swift
public enum SpeakerMeterVisualStyle: String, Codable, CaseIterable, Sendable {
    case cubeScalarCenterBloom      // default music mode
    case cubeHotCoreBloom
    case cubeHaloEdgeBloom
    case cubeBlockCenterBloom
    case impulseRippleTest          // artificial stress/tuning mode only
    case checkerPulseRingAndDiagonalWaveLegacy
    case prismGlowLegacy
}
```

Do not delete old enum cases if deleting them would break Codable persistence. Prefer migration and deprecation.

### 5.2 Impulse/ripple behavior

The older ripple/checker/packet behavior remains useful as an artificial test mode only:

```text
Impulse Test mode: allowed
Normal Music mode: do not use ripple as the main mapping
```

---

## 6. VU settings tray and preset persistence

The existing collapsed bottom VU settings tray should be extended, not replaced. The tray should be collapsed by default and remember open/closed state when the host provides persistence.

### 6.1 Basic controls

Include at least:

```text
Visual Gain
Responsiveness
Peak Hold
Release / Memory
Color Scheme
Speaker Height: Cube -> 2 Cubes
Show Labels
Show Diagnostics
Save as Default
Save Preset
Reset to Saved Default
Reset to Factory
```

### 6.2 Advanced controls

Include advanced controls behind disclosure/tabs:

```text
RMS Drive / VU Palette Drive
Noise Floor / Gate
Clip Threshold
Bloom Strength
Bloom Min / Max
Bloom Edge Softness
Radius Curve
Hot Fill Strength
Hot Threshold
Face Pixels / Tile Detail
Idle Tint
Checker Contrast
Impulse Test parameters, only when impulse mode is selected
```

Recommended default values from the cube scalar prototype:

```text
style: cubeScalarCenterBloom / Soft Center Bloom
facePixels: 9
idleTint: 0.25 to 0.36
hotFillStrength: around 0.86
hotThreshold: around 0.68
vuPaletteDrive: around 1.7
memory/release feel: around 0.64
checkerContrast: subtle, around 0.08
speaker zScale: 1.0
```

### 6.3 Save/default behavior

Settings must be Codable and saveable. Keep persistence outside `OrbitalViewCore` if possible.

Recommended contract:

```swift
public struct OrbitalViewVisualPreset: Equatable, Codable, Sendable, Identifiable {
    public var id: String
    public var name: String
    public var settings: SpeakerMeterVisualSettings
    public var createdAt: Date
    public var updatedAt: Date
}

public protocol OrbitalViewSettingsStore: Sendable {
    func loadDefaultPreset() throws -> OrbitalViewVisualPreset?
    func loadPresets() throws -> [OrbitalViewVisualPreset]
    func savePreset(_ preset: OrbitalViewVisualPreset) throws
    func setDefaultPreset(id: String?) throws
    func resetDefaultPreset() throws
}
```

`OrbitalViewSwiftUI` may provide a small `UserDefaults` implementation, but host apps should be able to inject their own store.

The tray should support:

```text
Save Current as Default
Save Named Preset
Load Preset
Reset to Factory
Reset to Saved Default
```

When a user saves settings and marks them default, future Orbital View tabs should start with those settings unless the host overrides them.

---

## 7. Theme and color schemes

### 7.1 Full theme tokens

The current theme is only a name. Expand it into renderer/useful tokens:

```swift
public struct OrbitalViewTheme: Equatable, Codable, Sendable {
    public let name: String
    public let background: OrbitalColor
    public let panel: OrbitalColor
    public let line: OrbitalColor
    public let text: OrbitalColor
    public let mutedText: OrbitalColor
    public let accent: OrbitalColor
    public let accentSecondary: OrbitalColor
    public let success: OrbitalColor
    public let warning: OrbitalColor
    public let danger: OrbitalColor
    public let vuRamp: [OrbitalColorStop]
}
```

Use whatever color representation already exists in the target tree if it is equivalent. Do not introduce platform color types into `OrbitalViewCore`.

### 7.2 Daft Punk Bow

Add **Daft Punk Bow** as a first-class palette/color scheme across Wavefield and Orbisonic themes.

User-facing name:

```text
Daft Punk Bow
```

Suggested ramp:

```text
0.00  #A78BFA  violet
0.18  #5B8CFF  blue
0.34  #22D3EE  cyan
0.50  #34D399  green
0.66  #FDE047  yellow
0.82  #FB923C  orange
1.00  #EF4444  red / hot
```

Older notes may call this palette `Tech Rainbow`. Treat that only as a migration alias for old JSON/Codable settings if needed. Do not show `Tech Rainbow` as the main user-facing name.

Music mode should be amplitude-driven through the ramp. Cycling every stop is acceptable only in impulse/test mode.

---

## 8. Keep existing viewports and controls exactly

The user explicitly wants the viewport controls from the existing Orbital View Kit project preserved because they were carefully tuned.

Codex must inspect the current tree for the actual viewport controls before editing. The docs describe the existing viewport/mockup controls as including:

```text
Camera group
Color group
Speaker Shape group
View Detail group
center-locked orbit
plan / front elevation / side elevation / isometric / custom camera modes
reset view
projection toggle
structure toggle
speaker toggle
label toggle
cutaway / front hemisphere toggle
speaker selection inspector
speaker level list
speaker size control
fog/depth atmosphere control
hidden-line / speaker number options, defaulted off
existing palette controls such as Purple, Flamingo, Green, and B&W in the mockup docs
```

Do not replace these with a simplified toolbar. Add the VU tray and save controls around the existing controls. If exact source for the existing web mockup is present in the working tree, use it as the behavioral reference; if it is absent, use the docs and existing Swift camera contracts.

The production app should keep one main viewport active by default unless the existing Orbital View design already has a different viewport layout. Preserve what is already there.

---

## 9. Data pipe and runtime resilience

### 9.1 Host-provided meter frame

Use the existing core shape:

```swift
public struct SpeakerMeterFrame: Equatable, Sendable {
    public let timestamp: TimeInterval
    public let levelsByChannel: [Int: SpeakerMeterLevel]
}

public struct SpeakerMeterLevel: Equatable, Sendable {
    public let rms: Float
    public let peak: Float
    public let clip: Bool
}
```

For Wavefield, the best current pipe is:

```text
PlayerSnapshot.meterSummary
  -> MeterSummary.multichannelLevels
  -> channels 1...30
  -> SpeakerMeterFrame
  -> OrbitalView
```

`VUMeterSnapshot.playbackDualOutput(mono:channels:)` is correct for MIDI Track to Speakers, nearest-speaker, VBAP, and any measured 30-channel render. `playbackMonoEqualAllChannels` is correct only for explicit Mono Equal mode.

For Orbisonic, require the same public adapter contract:

```text
Orbisonic renderer/output monitor
  -> 30 channel VU summaries
  -> SpeakerMeterFrame
  -> OrbitalView
```

### 9.2 Strict vs runtime-safe handling

Keep strict validation for tests and construction. Add runtime-safe sanitization for app display.

Runtime display behavior:

```text
missing channel  -> render that speaker idle/silent and report diagnostic
extra channel    -> ignore for rendering and report diagnostic
negative values  -> clamp to 0 and report diagnostic
values > 1       -> clamp to 1 for display and optionally mark over-range diagnostic
NaN/inf          -> replace with 0 and report diagnostic
bad timestamp    -> use receive time or previous sane timestamp and report diagnostic
missing scene    -> show unavailable panel, no crash
wrong count      -> render known speakers, show warning
```

Recommended diagnostic contract:

```swift
public struct OrbitalViewInputDiagnostics: Equatable, Sendable {
    public var expectedChannels: Set<Int>
    public var receivedChannels: Set<Int>
    public var missingChannels: [Int]
    public var extraChannels: [Int]
    public var sanitizedValueCount: Int
    public var clampedValueCount: Int
    public var sourceLabel: String?
    public var signalSourceLabel: String?
    public var warnings: [String]
}
```

---

## 10. Renderer performance requirements

This project must feel snappy in Swift apps.

### 10.1 Static vs dynamic state

Separate these paths:

```text
static scene geometry:
  shell nodes/edges/faces
  speaker base cube/prism mesh
  speaker transforms
  labels anchor positions
  channel-to-instance map

dynamic per-frame state:
  rms display envelope per channel
  peak display envelope per channel
  clip flash per channel
  selected channel
  camera matrices
  theme uniforms
  visual settings uniforms
```

Meter updates must not rebuild static geometry.

### 10.2 Metal implementation rules

Required:

```text
precompute static mesh buffers for shell and speaker base shapes
use instanced drawing for speakers
use one compact dynamic instance buffer for meter state
use ring/triple buffering for dynamic buffers if needed
cache pipeline states and depth states
cache channel-to-instance lookup once per scene revision
coalesce meter updates to display frames
avoid creating MTLBuffers every frame unless the existing minimal seam has not yet been upgraded
avoid per-speaker textures
avoid per-tile CPU drawing in the Swift renderer
perform face-center bloom procedurally in shader
avoid SwiftUI recreating MTKView on settings changes
keep renderer retained across tab switches when host permits
```

The cube/prism face tile effect should be procedural shader math. A CPU-created tile grid is acceptable only as precomputed static UV/face metadata, never as per-meter-frame drawing.

### 10.3 Dirty flags and revisions

Preserve or extend the current revision separation:

```text
structuralRevision
meterRevision
meterVisualSettingsRevision
cameraRevision
selectionRevision if needed
objectLayerRevision for future object merge compatibility
```

Tests must prove:

```text
meter-only update does not change static speaker draw inputs
meter visual setting update does not rebuild static geometry
camera-only update does not rebuild static geometry
speaker shape zScale changes update static shape only when the setting actually changes
channel identity remains stable after sanitizer and renderer mapping
```

### 10.4 App-level performance

SwiftUI wrapper rules:

```text
make configuration Equatable where practical
apply diffing before pushing state into renderer
throttle/debounce tray slider updates if they produce visible jank
avoid heavy work on the main actor
avoid allocating large arrays in View.body
keep diagnostics strings out of hot renderer paths
```

---

## 11. Merge compatibility with `Orbital View with Objects`

A separate tree named `Orbital View with Objects` will allow live 3D objects in the same viewport. This VU package must be merge-friendly.

### 11.1 First rule: inspect before inventing

Before adding any new object-related type or renderer layer, Codex must inspect the target working tree for existing object APIs. If the object tree already defines object scene/layer contracts, prefer adapting to those names and contracts rather than creating conflicting names.

### 11.2 Do not block object overlays

Do not hard-code the renderer as “shell plus speakers only.” Architect the renderer as layered content:

```text
physical shell layer
physical speaker meter layer
labels/diagnostics layer
future object layer
future renderer-kernel overlay layer
```

The VU package does not need to implement object editing. It only needs to avoid making object merge painful.

### 11.3 Scene contracts

If `OrbitalViewSceneSpec` already contains `virtualObjects`, preserve that additively. If the objects tree has a better object scene model, create a compatibility note and avoid duplicate semantics.

Recommended approach:

```swift
public struct OrbitalViewSceneSpec {
    public var shell: OrbitalViewShellSpec
    public var speakers: [OrbitalViewSpeaker]
    public var virtualObjects: [OrbitalViewVirtualObject] // optional/future, do not render unless layer exists
}
```

For renderer state, reserve layer revision fields without implementing object rendering if useful:

```text
objectLayerRevision
```

### 11.4 Merge checkpoints

At the end of every native slice after Slice 013, Codex must include a short compatibility note:

```text
Object-tree compatibility:
- contracts added/changed
- symbols that may conflict
- renderer layers affected
- whether changes are additive
```

---

## 12. Native slice plan

Continue numbering from the existing completed project slices.

### Slice 012: Preflight restore and build verification

**Goal:** Make the current package complete and buildable before new feature work.

Do:

- Read `AGENTS.md`, `START_HERE.md`, `docs/product-brief.md`, `docs/architecture.md`, `docs/contracts.md`, `docs/protected-paths.md`, `docs/system-flows.md`, `docs/implementation-map.md`, `docs/test-strategy.md`, `docs/status.md`, and `work-packages/orbital-view-kit/MV.md`.
- Run `swift build` and `swift test` on the working tree.
- Restore or locate missing core source files and fixture resources required by existing tests.
- If source files are missing because of packaging only, restore from the canonical repo/tree rather than rewriting behavior from scratch.
- Preserve existing public contracts unless compile failures prove they are incomplete.
- Update `docs/bugs.md` with any restore/build blockers found.
- Update `docs/status.md` with commands run and results.

Do not:

- add new Sonic Sphere VU features yet;
- change Wavefield or Orbisonic app code;
- alter audio, MIDI, OSC, routing, playback, or metering semantics.

Protected path touch:

```text
Allowed only as needed to restore currently referenced existing files/tests.
No feature changes in protected renderer/UI paths.
```

Verification:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Slice-end response must end with:

```text
Slice 012 is finished. Next: Slice 013 — Orbital View with Objects merge compatibility review.
```

---

### Slice 013: Orbital View with Objects merge compatibility review

**Goal:** Prepare the tree so this VU work can merge with the separate `Orbital View with Objects` tree without type conflicts or renderer dead ends.

Do:

- Locate or receive the `Orbital View with Objects` tree if it exists in the workspace.
- Compare public symbols, scene contracts, render state, camera state, and object-related names.
- Produce `docs/object-tree-merge-compatibility.md` or equivalent.
- Identify conflicts and recommend additive names/bridges.
- Add only minimal compatibility scaffolding if needed, such as layer revision fields or protocols, and only when tests can prove no behavior changes.
- Preserve the physical speaker/meter API.

Do not:

- implement object rendering;
- implement object editing;
- rename public types casually;
- block the VU path on object features.

Protected path touch:

```text
Docs preferred. Source touch only if needed for harmless additive compatibility.
```

Verification:

```text
swift build
swift test
```

Slice-end response must end with:

```text
Slice 013 is finished. Next: Slice 014 — Speaker cube/prism shape contract and face-center VU contract.
```

---

### Slice 014: Speaker cube/prism shape contract and face-center VU contract

**Goal:** Add the production speaker geometry contract: cube default plus rectangular-prism z-height option.

Do:

- Extend `SpeakerShape` or equivalent with cube and rectangular-prism options.
- Validate cube edge and prism z scale.
- Set default Sonic Sphere speakers to cube shape.
- Add a public setting for speaker z height from `1.0...2.0`.
- Document that VU never scales geometry.
- Add tests for cube, prism, zScale validation, and stable channel identity.
- Add tests proving VU/meter changes do not mutate speaker shape.

Do not:

- implement full Metal cube visuals yet;
- delete old speaker shapes if they are needed for Codable/backward compatibility;
- use sphere as the default production Sonic Sphere speaker shape.

Protected path touch:

```text
OrbitalViewCore allowed.
Renderer tests allowed only if needed for invariant coverage.
```

Verification:

```text
swift build
swift test --filter OrbitalViewCoreTests
```

Slice-end response must end with:

```text
Slice 014 is finished. Next: Slice 015 — Daft Punk Bow theme tokens and palette migration.
```

---

### Slice 015: Daft Punk Bow theme tokens and palette migration

**Goal:** Expand theme/color contracts and add Daft Punk Bow as a first-class VU palette.

Do:

- Expand `OrbitalViewTheme` into real platform-neutral color tokens.
- Add `OrbitalColor` and `OrbitalColorStop` or reuse equivalent existing types.
- Add `Daft Punk Bow` as a user-facing color scheme and VU ramp.
- Preserve Codable compatibility for existing settings.
- If older encoded settings use `techRainbow`, decode them into `daftPunkBow` but display `Daft Punk Bow`.
- Add tests for ramp stops, display name, Codable round trip, and migration alias.
- Update Wavefield/Orbisonic theme docs so both apps can offer Daft Punk Bow later.

Do not:

- hard-code AppKit/SwiftUI color types in `OrbitalViewCore`;
- make Daft Punk Bow cycle in normal music mode;
- remove Kimi Purple or existing palettes.

Protected path touch:

```text
OrbitalViewCore allowed. Renderer/SwiftUI only if needed to preserve compilation after enum changes.
```

Verification:

```text
swift build
swift test --filter OrbitalViewCoreTests
```

Slice-end response must end with:

```text
Slice 015 is finished. Next: Slice 016 — Cube scalar bloom settings, sanitizer, diagnostics, and presets.
```

---

### Slice 016: Cube scalar bloom settings, sanitizer, diagnostics, and presets

**Goal:** Replace the current default checker VU settings with music-mode cube scalar center bloom, add runtime-safe input handling, and add saveable presets.

Do:

- Add `cubeScalarCenterBloom` as the default music style.
- Keep legacy checker/ripple styles as legacy or impulse-test styles.
- Add settings for bloom, response, peak hold, release/memory, hot fill, face pixels, idle tint, zScale, Daft Punk Bow palette, and diagnostics visibility.
- Add `SpeakerMeterFrameSanitizer` or equivalent runtime-safe adapter.
- Add `OrbitalViewInputDiagnostics`.
- Add `OrbitalViewVisualPreset` and a persistence protocol/store contract.
- Keep `OrbitalViewCore` persistence-free; put concrete `UserDefaults` storage in SwiftUI or a host-facing utility target if needed.
- Add tests for clamping, missing/extra channel diagnostics, NaN/inf replacement, preset Codable round trip, default reset, and legacy style migration.

Do not:

- make strict constructors silently clamp invalid data;
- let bad host data crash the SwiftUI tab;
- implement full Metal rendering yet.

Protected path touch:

```text
OrbitalViewCore allowed.
OrbitalViewSwiftUI allowed only for compile updates or store protocol placement.
```

Verification:

```text
swift build
swift test --filter OrbitalViewCoreTests
swift test --filter OrbitalViewSwiftUITests
```

Slice-end response must end with:

```text
Slice 016 is finished. Next: Slice 017 — Renderer static buffer/cache plan and performance invariants.
```

---

### Slice 017: Renderer static buffer/cache plan and performance invariants

**Goal:** Lock renderer performance structure before production cube/prism visual work.

Do:

- Add or update a renderer cache plan doc.
- Add tests proving meter-only/settings-only/camera-only updates do not rebuild static speaker geometry.
- Add draw-input or cache-key tests for cube vs rectangular-prism static geometry.
- Add channel-to-instance-map tests.
- Add object-layer compatibility note for future object rendering.
- If current renderer allocates per-frame buffers, document the migration path and add tests around cache invalidation even if implementation remains minimal.

Do not:

- implement expensive visual polish yet;
- add postprocess bloom yet;
- touch host app audio paths.

Protected path touch:

```text
Sources/OrbitalViewRender/ and Tests/OrbitalViewRenderTests/ allowed.
```

Verification:

```text
swift build
swift test --filter OrbitalViewRenderTests
```

Slice-end response must end with:

```text
Slice 017 is finished. Next: Slice 018 — Metal cube/prism center-bloom renderer prototype.
```

---

### Slice 018: Metal cube/prism center-bloom renderer prototype

**Goal:** Implement the first production-direction Metal visual for cube/prism speakers with face-center scalar bloom.

Do:

- Render speakers as instanced cube/prism meshes, not flat quads.
- Orient each speaker normal-out according to existing scene/camera conventions.
- Apply procedural face-center bloom in shader.
- Map RMS to center fill/body glow, peak to halo/ring/hold, clip to hot flash.
- Add Daft Punk Bow ramp support in renderer uniforms.
- Keep speaker geometry fixed for meter changes.
- Keep shell/strut rendering as simple as necessary; do not overbuild.
- Add offscreen smoke/pixel-probe tests that prove hot channel changes color/intensity without moving/resizing geometry.
- Add a skip path for machines without Metal.

Do not:

- add live audio;
- add Wavefield tab integration in this slice;
- add object rendering;
- allocate textures per speaker or per frame.

Protected path touch:

```text
Sources/OrbitalViewRender/ and Tests/OrbitalViewRenderTests/ allowed.
```

Verification:

```text
swift build
swift test --filter OrbitalViewRenderTests
```

Slice-end response must end with:

```text
Slice 018 is finished. Next: Slice 019 — SwiftUI viewport controls, VU tray, and preset save UI.
```

---

### Slice 019: SwiftUI viewport controls, VU tray, and preset save UI

**Goal:** Wire the native UI around the existing Orbital View viewport controls and the new VU settings/preset model.

Do:

- Preserve the existing Orbital View viewport controls exactly.
- Add/extend the bottom collapsible VU tray.
- Add Basic and Advanced sections.
- Add Save as Default, Save Preset, Load Preset, Reset to Saved Default, and Reset to Factory actions.
- Add `Speaker Height: Cube -> 2 Cubes` control.
- Add diagnostics display for missing/extra/sanitized channels.
- Ensure SwiftUI changes do not recreate the MTKView unnecessarily.
- Add UI tests or compile tests for the new initializer/store surfaces.

Do not:

- replace the existing viewport controls with a simpler toolbar;
- alter audio/playback behavior;
- make persistence mandatory for hosts.

Protected path touch:

```text
Sources/OrbitalViewSwiftUI/ and Tests/OrbitalViewSwiftUITests/ allowed.
```

Verification:

```text
swift build
swift test --filter OrbitalViewSwiftUITests
swift test --filter OrbitalViewRenderTests
```

Slice-end response must end with:

```text
Slice 019 is finished. Next: Slice 020 — Wavefield Orbital View tab integration.
```

---

### Slice 020: Wavefield Orbital View tab integration

**Goal:** Add the native Orbital View VU tab to Wavefield using the existing Wavefield data pipe.

Do:

- Add Wavefield adapter from `PlayerSnapshot.meterSummary.multichannelLevels` to `SpeakerMeterFrame`.
- Use loaded Fey 30 speaker layout geometry joined by channel.
- Add the Orbital View tab or guarded replacement for the existing Spherical VU tab.
- Keep existing Spherical VU available until Orbital View is verified stable, unless the task owner explicitly says to replace it.
- Pass Wavefield theme tokens into `OrbitalViewTheme`.
- Add Daft Punk Bow to Wavefield color scheme options.
- Surface diagnostics: source label, signal source, active channel count, missing/extra channels, sanitized values.
- Verify MIDI Track to Speakers, nearest-speaker, and VBAP modes use `playbackDualOutput`/multichannel levels when available.
- Preserve Mono Equal semantics as the only mode that mirrors mono to all channels.

Do not:

- change Wavefield playback, MIDI, OSC, routing, audio rendering, or output semantics unless explicitly required and reviewed;
- fake 30-channel meters if `MeterSummary.multichannelLevels` is empty;
- claim hardware output proof from chunk-cache meters.

Protected path touch:

```text
Wavefield app UI and adapter paths allowed by this slice.
Wavefield audio/playback/rendering/output paths are protected; touch only if absolutely necessary and document why.
```

Verification:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
focused Wavefield adapter/UI tests
```

Slice-end response must end with:

```text
Slice 020 is finished. Next: Slice 021 — Orbisonic integration seam and shared host contract.
```

---

### Slice 021: Orbisonic integration seam and shared host contract

**Goal:** Ensure Orbital View can drop into Orbisonic with the same public UI component and meter contract.

Do:

- Add docs and adapter skeletons for Orbisonic if the Orbisonic tree is present.
- Define the required Orbisonic host contract:

```text
Orbisonic renderer/output monitor
  -> 30 channel VU records
  -> SpeakerMeterFrame
  -> OrbitalView
```

- Add Daft Punk Bow to the Orbisonic color scheme contract.
- Add tests for a generic host adapter if the Orbisonic tree is not present.
- Confirm no Wavefield-only assumptions leak into `OrbitalViewCore`, `OrbitalViewRender`, or `OrbitalViewSwiftUI`.
- Update docs with Wavefield vs Orbisonic responsibilities.

Do not:

- make OrbitalViewKit import Wavefield as a core dependency;
- make OrbitalViewKit import Orbisonic as a core dependency;
- couple the renderer to either host app.

Protected path touch:

```text
Docs and adapter skeletons preferred. Orbisonic app paths only if present and explicitly part of this slice.
```

Verification:

```text
swift build
swift test
host adapter tests if host tree is available
```

Slice-end response must end with:

```text
Slice 021 is finished. Next: open the separate web work package when ready.
```

---

## 13. Documentation updates required after each slice

Always update:

```text
docs/status.md
```

Update when relevant:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
docs/protected-paths.md
docs/bugs.md
work-packages/orbital-view-kit/MV.md
AGENTS.md
```

Add slice files under the existing work-package/slices convention if that convention exists in the working tree.

---

## 14. Codex final response format

Every slice response must include:

```text
Summary:
Files changed:
Tests added or updated:
Commands run:
Results:
Documentation updated:
Bugs found or fixed:
Protected paths touched:
Object-tree compatibility:
Assumptions:
Risks or blockers:
Recommended next task:
```

And every slice response must end with the exact required slice-end sentence for that slice.
