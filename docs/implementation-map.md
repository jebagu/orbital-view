# Implementation Map

## Purpose

This file maps project behavior to files and folders so the current system can be understood without reading every document.

## Top-Level Structure

```text
docs/                         Active project documentation
.tasks/                       Bounded Codex execution tasks
work-packages/orbital-view-kit/ Initial OrbitalViewKit work package
docs/object-tree-merge-compatibility.md Native object-tree merge notes
docs/renderer-cache-plan.md   Renderer static/cache invariants for cube/prism drawing
openspec/                     Behavioral change/spec templates
mockups/                      Disposable visual mockups
.agents/skills/               Local project skills
.codex/agents/                Local reviewer agent configs
reviewers/                    Human-readable review checklists
prompts/                      Reusable project prompts
```

Swift source directories are now present for `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewOrbisonic`, `OrbitalViewRender`, `OrbitalViewSwiftUI`, `OrbitalViewViewerSupport`, and `OrbitalViewViewer`.

## Feature Map

### OrbitalViewCore Foundation

Purpose:

```text
Pure data contracts and validation for spherical speaker viewport scenes.
```

Implementation locations:

```text
Package.swift
Sources/OrbitalViewCore/
Tests/OrbitalViewCoreTests/
```

Key object-overlay file:

```text
Sources/OrbitalViewCore/OrbitalViewObjects.swift
```

Related docs:

```text
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
.tasks/001-orbital-view-core-foundation.md
```

### Wavefield Adapters

Purpose:

```text
Convert Wavefield speaker-layout JSON and Wavefield-style meter records into OrbitalViewCore contracts.
```

Implementation locations:

```text
Sources/OrbitalViewWavefield/
Tests/OrbitalViewWavefieldTests/
```

The current adapter reads speaker-layout JSON and local channel/rms/peak meter DTOs. Direct Wavefield package type integration is not implemented.
Slice 020 adds a sanitized adapter path that converts Wavefield-style channel RMS/peak frames into `SpeakerMeterFrameSanitizer.Result`, returning both strict display-safe `SpeakerMeterFrame` data and `OrbitalViewInputDiagnostics`.

### Wavefield App Orbital View Tab

Purpose:

```text
Host the native Orbital View VU component inside the sibling Wavefield Receiver app while preserving the existing Spherical VU tab.
```

Implementation locations:

```text
../Wavefield Receiver/Package.swift
../Wavefield Receiver/Sources/WavefieldApp/OrbitalViewTabViewModel.swift
../Wavefield Receiver/Sources/WavefieldApp/Views.swift
../Wavefield Receiver/Sources/WavefieldApp/AppShellView.swift
../Wavefield Receiver/Sources/WavefieldApp/WavefieldDesignSystem.swift
../Wavefield Receiver/Sources/WavefieldAppSupport/WavefieldAppSupport.swift
../Wavefield Receiver/Tests/WavefieldAppTests/TabSourceActionTests.swift
../Wavefield Receiver/Tests/WavefieldAppSupportTests/WavefieldAppSupportTests.swift
```

The tab builds an `OrbitalViewSceneSpec` from Wavefield's cached Spherical VU/Fey speaker geometry and maps `PlayerSnapshot.meterSummary.multichannelLevels` into Orbital View meters by physical channel. MIDI Track to Speakers, nearest-speaker, and VBAP modes use multichannel levels when available. Mono Equal is the only path that mirrors mono RMS/peak to every modeled speaker channel. The tab surfaces source label, signal source, active channel count, missing/extra/invalid/duplicate channels, and sanitized values, and Wavefield's color-scheme menu now includes Daft Punk Bow.

### Orbisonic Host Adapter Skeleton

Purpose:

```text
Define the Orbisonic drop-in seam without importing or editing the Orbisonic app.
```

Implementation locations:

```text
Sources/OrbitalViewOrbisonic/
Tests/OrbitalViewOrbisonicTests/
docs/orbisonic-integration-contract.md
```

The adapter skeleton defines `Orbisonic renderer/output monitor -> 30 channel VU records -> SpeakerMeterFrame -> OrbitalView`. It accepts 30 physical output speaker records, normalized output-monitor VU records, and host color-scheme choices including Daft Punk Bow. It converts those DTOs into `OrbitalViewCore` scene, theme, meter, and diagnostics values while keeping Orbisonic audio, output, Dante, live input, Roon/Spotify/Aux, and app UI ownership in the Orbisonic repo.

### Orbital Viewport Visual Mockup

Purpose:

```text
Preview the intended spherical monitor viewport interaction before native renderer work.
```

Implementation locations:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
```

This is disposable HTML/CSS/JS with fake speaker positions and fake meter animation. It now mirrors DomeLab's 3D Model control panel on the left side of the viewport, grouped under Camera, Color, Speaker Shape, and View Detail headings. The shell structure is generated as a Fey 3V class-I icosahedron geodesic from the DomeLab project config values in `fey sphere - domelab-configuration.json`, normalized to the viewport sphere. Purple, Flamingo, Green, and B&W color palettes theme the full mockup surface, with Purple as the default. Projection is always axonometric, speaker numbers and hidden lines use switch controls defaulted off, speaker size is centered at 1.95x with half/double range mapping, fog density remaps the prior 30-density look to the slider midpoint, and prism mode is the default shape using true 8-vertex rectangular-prism speaker cabinets with hidden-line face clipping. It is not production renderer source.

### Native Orbital Viewport 3D App

Purpose:

```text
Provide a native SwiftUI/SceneKit viewport review app for local review and future host-app visual alignment.
```

Implementation locations:

```text
Sources/OrbitalViewSwiftUI/OrbitalViewportMockup.swift
Sources/OrbitalViewViewer/OrbitalViewViewer.swift
Open Native Orbital View VU Kit.command
scripts/build-orbital-viewer-app.sh
```

`OrbitalViewportMockup` keeps the browser mockup as a loose behavior/control-inventory reference while using Orbisonic design language as the control-skin source of truth. It renders native 3D SceneKit geometry with fixed left/right rails, native SwiftUI/AppKit-backed controls, Fey 30 speaker coordinates, generated 3V geodesic count contract, Purple/Prism/Isometric defaults, fake meter stream, color schemes, camera controls, speaker shape controls, speaker size, fog density, speaker numbers, hidden lines, selection, spin, drag orbit, wheel/magnification zoom, inspector, speaker list, footer, and PNG export. The SceneKit path orbits the camera around static content and uses SceneKit camera-space fog instead of rotating the model root or applying fog-driven material alpha fades. This is a native review app and does not replace the accepted production MetalKit renderer backend.

### Sonicsphere Cube VU Single-Screen Mockup

Purpose:

```text
Preview a cube-only low-resolution center-bloom scalar VU style with all variants and controls visible in one browser viewport.
```

Implementation locations:

```text
mockups/sonicsphere-cube-vu-single-screen/index.html
mockups/sonicsphere-cube-vu-single-screen/notes.md
OrbitalViewKit -> mockups/sonicsphere-cube-vu-single-screen
```

Local server URL:

```text
http://127.0.0.1:8765/OrbitalViewKit/
```

This is a disposable imported HTML/CSS/JS mockup. It uses a fixed 1512 x 850 CSS-pixel artboard that scales uniformly to the viewport, keeps body scrolling disabled, and lays out a normal Music Meter above four cube VU variants on the left with a tabbed tuning rail on the right. The Tune tab keeps live audio, one Cube VU scalar, palette, and surface controls readable; the Impulse tab holds artificial Drop/Repeat testing; the Advanced tab holds custom palette JSON and implementation export. It includes an exclusive VU drive toggle: Music mode uses tab-audio capture through `getDisplayMedia` or local MP3/M4A/WAV playback through the page's `<audio>` element, while Impulse Test mode stops browser audio capture/playback and enables only artificial impulses. Web Audio analysis shows RMS/peak/bass, but the cube `vuScalar` is exactly the RMS percent and drives four center-bloom cube-face variants in Music mode. The mockup keeps CPU cost down by using one large cube per panel, cached tile geometry, a 9 x 9 default face grid, capped canvas DPR, down-sampled meter drawing, and a 24 fps render throttle. This mockup audio path is not production renderer source and does not change the Swift package contract.

### OrbitalViewRender Seam

Purpose:

```text
Provide the initial MetalKit renderer seam for validated OrbitalViewCore scenes.
```

Accepted backend:

```text
MetalKit / MTKView custom renderer, wrapped by SwiftUI above it.
```

Implementation locations:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
```

Decision record:

```text
docs/decisions/0002-renderer-backend.md
```

The current renderer stores scene, speaker meter, speaker meter visual settings, object frames, object meters, object visual settings, camera, and selection state separately, exposes an `MTKViewDelegate` path, and includes an offscreen-tested Metal draw pipeline. Speakers render as instanced cube/prism meshes with retained position/orientation/material/ramp buffers; object overlays still use the simpler retained quad path. Internal test harness cache keys for static speaker geometry and channel-to-instance maps lock renderer invariants. Shell/strut visuals, live object smoothing, hit testing, and broad SwiftUI controls are deferred.

### Renderer Static Cache Plan

Purpose:

```text
Lock performance/cache boundaries for production-direction cube/prism center-bloom rendering.
```

Implementation locations:

```text
docs/renderer-cache-plan.md
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

The current static speaker geometry key includes speaker ID, physical channel, anchor, shape, and visual role. Meter, settings, camera, and object-layer changes do not change that key. Cube and rectangular-prism scenes intentionally produce different keys. Renderer tests also verify channel-to-instance mapping by scene order and retained speaker-buffer reuse across meter/settings/camera-only renders.

### OrbitalViewSwiftUI Wrapper Skeleton

Purpose:

```text
Expose OrbitalViewRender through host-app SwiftUI bindings.
```

Implementation locations:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

`OrbitalViewSwiftUI` also contains the package-local `OrbitalViewportMockup` native 3D review screen. That screen is separate from the production `OrbitalView` wrapper contract and uses SceneKit only for the standalone native review app surface.

The current wrapper provides `OrbitalView`, an `NSViewRepresentable` bridge, optional bottom VU settings tray, object snapshot/settings forwarding, optional input diagnostics display, optional host-provided visual-preset store actions, and coordinator tests. SwiftUI gestures, toolbar controls, hit testing, and inspector UI are deferred.

### Standalone Orbital View Viewer

Purpose:

```text
Launch the native OrbitalViewSwiftUI viewport from this package without opening Wavefield, Orbisonic, or Splat.
```

Implementation locations:

```text
Sources/OrbitalViewViewer/
Sources/OrbitalViewViewerSupport/
Tests/OrbitalViewViewerTests/
Package.swift
Open Orbital View Viewer.command
scripts/build-orbital-viewer-app.sh
```

The executable product `OrbitalViewViewer` uses the same public `OrbitalView` SwiftUI API that hosts use. `OrbitalViewViewerSupport` constructs deterministic demo-only data: a 30-speaker Fey monitor scene, static channel-keyed speaker meter frame, sample source-object frames/meters, and object visual settings. The viewer has local plan/front/side/isometric scene transforms and a lightweight shell-guide overlay. `Open Orbital View Viewer.command` delegates to `scripts/build-orbital-viewer-app.sh`, which builds a local `Orbital View Viewer.app` bundle and opens that bundle. The viewer does not read live audio, own meter timing, or import downstream app targets.

### VU Meter Visual Settings And Tray

Purpose:

```text
Pass display-only meter gain/style through core, renderer, and SwiftUI without touching audio behavior.
```

Implementation locations:

```text
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewCoreTests/
Tests/OrbitalViewRenderTests/
Tests/OrbitalViewSwiftUITests/
```

The current implementation maps each scene speaker to `SpeakerMeterFrame.levelsByChannel` by physical channel, applies the default cube scalar center-bloom style with Daft Punk Bow colors through renderer material/ramp state, keeps legacy checker pulse/ring/diagonal wave available, and preserves stable static speaker geometry. The SwiftUI tray is opt-in and collapsed by default with Basic controls for visual gain, style, color scheme, and speaker height, Advanced controls for bloom/checker tuning, optional preset actions, and diagnostics display for sanitized host input.

### Theme Tokens And Daft Punk Bow

Purpose:

```text
Keep theme and VU palette data platform-neutral while giving Wavefield and Orbisonic one shared rainbow VU scheme.
```

Implementation locations:

```text
Sources/OrbitalViewCore/OrbitalViewSceneSpec.swift
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
```

`OrbitalViewTheme` now carries neutral color tokens and a `vuRamp`. `SpeakerMeterColorScheme.daftPunkBow` displays as `Daft Punk Bow`, maps to the shared ramp, and decodes legacy `techRainbow` JSON as Daft Punk Bow. Wavefield offers this same shared color scheme in host-level controls, and the Orbisonic seam exposes `OrbisonicOrbitalColorScheme.daftPunkBow` for the future app integration.

### Cube Scalar Center Bloom Settings And Input Safety

Purpose:

```text
Make music-mode cube scalar center bloom the default VU contract while keeping bad host meter input from crashing UI surfaces.
```

Implementation locations:

```text
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewCore/OrbitalViewMeterInput.swift
Sources/OrbitalViewCore/OrbitalViewVisualPreset.swift
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewSwiftUI/OrbitalView.swift
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

`SpeakerMeterVisualStyle.cubeScalarCenterBloom` is the default music style and uses Daft Punk Bow by default. `SpeakerMeterVisualSettings` now includes bloom min/max/edge, response curve, peak hold, release memory, hot fill, face pixels, diagnostics visibility, and existing z-scale/checker controls. `SpeakerMeterFrameSanitizer` converts unsafe runtime `SpeakerMeterSample` values into strict `SpeakerMeterFrame` values and returns `OrbitalViewInputDiagnostics` for missing, extra, invalid, duplicate, replaced, or clamped input. `OrbitalViewVisualPreset` is Codable and validated on decode; `OrbitalViewVisualPresetStore` is a protocol only, so Core remains persistence-free. The renderer now uses the cube scalar path for shader-side speaker materials; checker facet animation remains a future renderer material slice.

### Sonic Sphere Speaker Shape Contract

Purpose:

```text
Define production speaker geometry as fixed cube/prism objects and keep VU behavior mapped to material/color state rather than geometry size.
```

Implementation locations:

```text
Sources/OrbitalViewCore/OrbitalViewSpeaker.swift
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewWavefield/WavefieldSpeakerLayoutSceneAdapter.swift
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
Tests/OrbitalViewWavefieldTests/WavefieldSpeakerLayoutSceneAdapterTests.swift
```

`SpeakerShape.cube(edgeM:)` is the default Sonic Sphere speaker shape. `SpeakerShape.sonicSphereRectangularPrism(edgeM:zScale:)` validates local z scale in `1...2` and maps it to fixed rectangular-prism dimensions. `SpeakerFaceCenterBloom` defines normalized face-center distance from each face's local `(0.5, 0.5)` center. `SpeakerMeterVisualSettings.speakerZScale` is a display setting only; renderer tests verify it does not mutate scene speaker shapes or static draw inputs.

### Wavefield Object Overlay

Purpose:

```text
Accept host source-object snapshots, object VU levels, object visual tuning settings, and bounded trails without changing speaker VU behavior.
```

Implementation locations:

```text
Sources/OrbitalViewCore/OrbitalViewObjects.swift
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewCoreTests/
Tests/OrbitalViewRenderTests/
Tests/OrbitalViewSwiftUITests/
mockups/orbital-view-viewport/index.html
```

Object centers use canonical unit-sphere directions keyed by Wavefield `objectId` in `1...128`. The render/effect bounds default to a cube from `-5...+5` on x, y, and z. Trails are off by default, capped by both frame and settings contracts, and glow trails share the same capped draw-input stream. Renderer state keeps object frame, object meter, and object visual setting revisions separate from speaker scene and speaker VU revisions.

### Object Tree Merge Compatibility

Purpose:

```text
Record how the current VU tree should merge with the separate Orbital View with Objects tree without public type conflicts or renderer-layer dead ends.
```

Implementation locations:

```text
docs/object-tree-merge-compatibility.md
```

The current inspected object tree already shares the static `OrbitalViewSceneSpec.virtualObjects` contract but lacks the current dynamic object frame, object meter, object visual settings, renderer object revision, retained object buffer, and SwiftUI object forwarding APIs. The current VU object APIs are additive relative to that tree.

### Renderer Test Harness Plan

Purpose:

```text
Define how the first Metal draw-loop work will be verified before drawing behavior is added.
```

Implementation locations:

```text
docs/renderer-test-harness.md
```

The plan defines contract tests, offscreen renderer smoke tests, renderer invariant checks, targeted pixel probes, and optional interactive harness constraints.

### Offscreen Renderer Smoke Test

Purpose:

```text
Prove OrbitalViewRender can issue Metal draw commands and produce non-empty output without a host app window.
```

Implementation locations:

```text
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewRender/OrbitalViewMetalRenderer.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

The current speaker draw path renders fixed-size instanced cube/prism meshes from scene speaker anchors. Static speaker position/orientation data stays separate from dynamic RMS/peak/clip material data and Daft Punk Bow ramp uniforms. Meter values affect shader fill, halo/ring, and clip flash only, preserving the rule that VU behavior must not resize speaker geometry.

### Renderer Invariant Tests

Purpose:

```text
Lock down renderer draw-input invariants before expanding production visuals.
```

Implementation locations:

```text
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

The current invariant tests compare static speaker draw inputs across meter-only and camera-only updates. Static inputs include speaker ID, physical channel, projected position, quad radius, mesh vertex count, and mesh depth scale. Renderer pixel probes also compare offscreen geometry bounds across quiet, hot, and clipped meter frames.

## Test Map

```text
unit direction validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
speaker validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
shell reference validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
meter channel identity -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
camera center-lock presets -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Wavefield JSON layout adaptation -> Tests/OrbitalViewWavefieldTests/WavefieldSpeakerLayoutSceneAdapterTests.swift
Wavefield meter-frame adaptation -> Tests/OrbitalViewWavefieldTests/WavefieldMeterFrameAdapterTests.swift
Orbisonic host adapter scene, meter, and Daft Punk Bow contract -> Tests/OrbitalViewOrbisonicTests/OrbisonicOrbitalViewAdapterTests.swift
renderer seam state separation and events -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
offscreen renderer smoke output -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
renderer static draw-input invariants -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
renderer 30-channel VU mapping, meter color-scheme settings, and visual settings revisions -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
renderer static cache keys, cube/prism invalidation, channel-to-instance mapping, and speaker buffer reuse -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
renderer cube/prism center-bloom pixel probes and Daft Punk Bow ramp uniform checks -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
cube scalar center-bloom defaults, sanitizer diagnostics, and visual preset codability -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
object frame/meter/settings validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
object renderer revisions, disappearance, trail caps, and retained buffer reuse -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
SwiftUI object snapshot/settings forwarding -> Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
SwiftUI wrapper configuration and coordinator behavior -> Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
SwiftUI VU settings tray opt-in, preset store actions, diagnostics summaries, settings-only coordinator updates, and standalone native viewport control/orbit/fog/export behavior -> Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
renderer test harness plan -> docs/renderer-test-harness.md
renderer static cache plan -> docs/renderer-cache-plan.md
visual mockup inline script syntax -> node parse command in .tasks/004-orbital-viewport-visual-mockup.md
renderer backend decision -> docs/decisions/0002-renderer-backend.md
```

## Last Updated

2026-05-21 Standalone native Orbital View VU Kit control, orbit, fog, zoom, and export polish
