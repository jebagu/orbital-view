# Implementation Map

> Current note: the explicit Cube VU speaker merge task supersedes the earlier deprecation warning for the native Cube VU/object overlay work. The active direction is this package's SwiftUI + MetalKit wrapper with reusable cube/object/performance controls, not a new standalone app copied from Orbital View VU Kit. See `docs/deprecated/native-cube-vu-chat-work.md` for historical context only.

## Purpose

This file maps project behavior to files and folders so the current system can be understood without reading every document.

## Top-Level Structure

```text
docs/                         Active project documentation
.tasks/                       Bounded Codex execution tasks
work-packages/orbital-view-kit/ Initial OrbitalViewKit work package
openspec/                     Behavioral change/spec templates
mockups/                      Disposable visual mockups
.agents/skills/               Local project skills
.codex/agents/                Local reviewer agent configs
reviewers/                    Human-readable review checklists
prompts/                      Reusable project prompts
```

UI design-language contract:

```text
docs/orbisonic-design-language.md
```

Realtime-family compliance closeout:

```text
docs/realtime-family-compliance-audit.md
```

Swift source directories are now present for `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewRender`, `OrbitalViewSwiftUI`, `OrbitalViewReview`, `OrbitalViewViewerSupport`, and the `OrbitalViewViewer` executable.

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

Current meter frames include `OrbitalViewTelemetrySourceDescriptor` metadata so speaker and object telemetry can identify its source of truth without changing channel/object identity. `OrbitalViewInputDiagnostics` can also record allowed lossy-display overload actions: dropped stale frames, decimated display refresh, latest complete snapshot retention, and diagnostics set outside realtime.

Canonical coordinates are Z-up across the package: `x = right`, `y = front`, and `z = up`. Core shell helpers put top/bottom on `+Z/-Z` and front/back on `+Y/-Y`.

Related docs:

```text
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
.tasks/001-orbital-view-core-foundation.md
```

### Realtime Family Compliance Audit

Purpose:

```text
Record the final standards-adoption state for the current package.
```

Implementation locations:

```text
docs/realtime-family-compliance-audit.md
openspec/changes/adopt-realtime-family-standards/
```

The audit states the inherited realtime audio family standard, target-to-plane mapping, callback inventory, review-only target separation, OpenSpec status, Wavefield local generator boundary, Orbisonic design-language role, and explicit remaining risks. It is documentation only and does not create callback-safe APIs.

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

The current adapter reads speaker-layout JSON and local channel/rms/peak meter DTOs. It validates Wavefield/Fey layout axes as `x/right`, `y/front`, and `z/up`, preserving FEY physical channel order `1...30` without sorting by position. Direct Wavefield package type integration is not implemented. Wavefield-style meter frames are labeled as `.externalWavefieldStream` by default, with room for the local livestream test generator to use `.localLivestreamTestGenerator` in a later host integration slice.

Wavefield realtime connection contract:

```text
docs/integrations/wavefield-realtime-connection.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md
```

Wavefield owns external stream parsing, local livestream generator profiles, MIDI streams, realtime event queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and performance gates. Orbital View Kit receives prepared scene, speaker meter, object frame, object meter, diagnostics, and source metadata snapshots only.

### Orbisonic And Splat Host Profiles

Purpose:

```text
Define how Orbisonic and Splat should connect without changing downstream apps.
```

Integration contract:

```text
docs/integrations/orbisonic-splat-host-profiles.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md
```

Orbisonic provides prepared bus/object/speaker meter snapshots from explicit tap points, labels provenance as `orbisonicPreparedMeterTap`, keeps playback/routing/Core Audio/device/output ownership in Orbisonic, and preserves Orbisonic design-language palette grammar.

Splat uses Orbital View Kit for virtual speakers, source objects, renderer-kernel overlays, neutral geometry review, camera/selection, and diagnostics. Splat edit/export actions stay preparation/control behavior, canonical 3D coordinates remain canonical, and neutral geometry import/export stays separate from browser or DomeLab runtime code.

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

This is disposable HTML/CSS/JS with fake speaker positions and fake meter animation. It now mirrors DomeLab's 3D Model control panel on the left side of the viewport, grouped under Camera, Color, Speaker Shape, and View Detail headings. The shell structure is generated as a Fey 3V class-I icosahedron geodesic from the DomeLab project config values in `fey sphere - domelab-configuration.json`, normalized to the viewport sphere. Purple, Flamingo, Green, and B&W color palettes theme the full mockup surface, with Purple as the default. Projection is always axonometric, speaker numbers and hidden lines use switch controls defaulted off, speaker size is centered at 1.95x with half/double range mapping, fog density remaps the prior 30-density look to the slider midpoint, and prism mode is the default shape using true 8-vertex rectangular-prism speaker cabinets with hidden-line face clipping. The mockup keeps speaker data in canonical Z-up coordinates and maps to its Y-up canvas math at projection time. It is not production renderer source.

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

The current renderer stores scene, speaker meters, cube VU settings, dynamic object frames, object meters, object visual settings, camera, and selection state separately. It exposes an `MTKViewDelegate` path and includes an offscreen-tested Metal draw pipeline with one instanced cube/prism mesh per speaker. Speaker meter updates change material/color payloads only; static speaker geometry and physical channel mapping stay stable. The Metal screen projection uses canonical `x` horizontally and canonical `z` vertically, treating canonical `y` as depth/front. Dynamic object overlays render through a separate retained quad path.

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

The current wrapper provides `OrbitalView`, an `NSViewRepresentable` MetalKit bridge, coordinator tests, and opt-in collapsible tuning trays. The binding initializer lets hosts tune `SpeakerMeterVisualSettings`, `ObjectVisualSettings`, and `OrbitalViewPerformanceSettings`; value-based initializers remain available for hosts that do not want the tuning surface. The production target does not own SceneKit, local audio playback, file dialogs, PNG export, bundled review fonts, or theme JSON persistence. Gestures, hit testing, and production inspector UI remain deferred.

### OrbitalViewReview Surface

Purpose:

```text
Keep review/demo-only SceneKit, local-audio, theme, export, and font tooling out of the production SwiftUI wrapper.
```

Implementation locations:

```text
Sources/OrbitalViewReview/
Tests/OrbitalViewSwiftUITests/
```

`OrbitalViewReview` owns `OrbitalViewportMockup`, the confirmed VU Kit SceneKit geodesic viewport review app, plus its SwiftPM font resources. This target may use review-only `AVFoundation`, `AppKit`, `SceneKit`, `NSOpenPanel`, CoreText font registration, app-bundle theme JSON, and PNG export behavior. SceneKit remains a Y-up implementation detail, so canonical vectors are mapped as `(x, y, z) -> (x, z, y)` at the SceneKit boundary. Production hosts should import `OrbitalViewSwiftUI`; the review executable imports `OrbitalViewReview`.

Any future visible review-surface change must verify against `docs/orbisonic-design-language.md` and the Orbisonic design-language source files it references. The rule covers layout, palette, meter treatment, diagnostics separation, and information hierarchy; it does not import Orbisonic product semantics.

### Native OrbitalViewViewer

Purpose:

```text
Launch the confirmed VU Kit native SceneKit geodesic review surface from this package.
```

Implementation locations:

```text
Package.swift
Sources/OrbitalViewReview/
Sources/OrbitalViewViewer/
Sources/OrbitalViewViewerSupport/
Tests/OrbitalViewViewerTests/
```

The viewer executable now imports `OrbitalViewReview` and hosts `OrbitalViewportMockup`, the confirmed VU Kit SceneKit geodesic viewport review app. This preserves the original camera/view-detail controls, the Fey 3V geodesic shell, full-window PNG export, and adaptive SceneKit interaction loop. `Song Audio Source` sits at the top of the left rail with native transport icon buttons for Play and Pause plus audio render type buttons. Speaker type selection now lives in the right `Speaker Shape` tray and exposes `Prism`, `Sphere`, and `Cube VU`; Cube VU uses square cube geometry with the shared Cube VU scalar/material path.

The right panel is now a tuning/debug surface instead of a large meter inspector. It is sectioned by use: `Theme` contains `Saved Themes`; `Speaker Appearance` contains `Speaker Shape`, `Speaker Pattern`, `Label Font`, `Color Palette`, `Cube Surface`, and `Bloom Style`; `Sphere Appearance` contains `Sphere Geometry` and `Geodesic Appearance`; `Meter Behavior` contains `Meter Source`, `Meter Response`, and `Performance`; `Diagnostics` contains `Diagnostics`. `Sphere Geometry` and `Speaker Pattern` are empty future trays that currently show only `Future work`. `Cube Surface`, `Bloom Style`, and `Meter Response` each include a local dice-icon randomizer. The speaker `Color Palette` tray uses full-width custom theme buttons with fixed-height rows, subtitles, palette swatches, and active borders; it does not use a native segmented picker. The palette list is sourced from the Orbisonic design-language brief and includes Purple, Flamingo, Green, B&W, Daft Punk Bow, Rack Mint, Rack Pink, Rack Blue, Ember Console, Graphite, Flamingo Green, and Dusty Rose. The speaker palette also drives the app skin. `Geodesic Appearance` uses the same palette list independently and owns `Geodesic Saturation`, a shell-only color control that desaturates the geodesic struts/nodes to grayscale at the low end and restores the selected geodesic palette at the high end without changing speaker or Cube VU materials. The `Saved Themes` tray saves, refreshes, loads, and sets defaults for JSON themes in `Contents/Resources/View Themes/`; new files get unique two-word names, manual filename changes become the visible app label on refresh, and default selection uses a stable `themeID` before falling back to filename. The old Scene summary, selected-speaker placeholder, and 30-channel VU list are removed. Object Overlay, Trails, Glow Trails, and Bounds are inactive in this review surface for now, while the reusable object contracts and renderer paths remain available for future Wavefield work.

The default review state is now explicit in `OrbitalViewportMockup` and is sourced from the exported settings file `Orbital View VU Kit Settings 2026-05-21-171537.json`. Startup defaults select Purple for the speaker/app palette, Purple for the geodesic palette, Cube VU, Hot Core Bloom, Impulse Test Ripple, geodesic saturation `0`, Pixel Fill `0.86`, Surface Checker Opacity `0`, Cube Outline `0.64`, and 60 fps active motion while leaving Core-level `OrbitalViewportCubeVUSettings.default` unchanged for contract tests.

The SceneKit Cube VU review path uses one retained per-speaker material with a retained 9x9 pixelated face texture cache applied directly to the actual six `SCNBox` cube faces. It uses a Cube-VU-only readable face scale for visibility at small on-sphere speaker sizes, applies RMS-driven center bloom through `SpeakerCubeVUScalars`, uses the selected speaker palette for fog/label/VU colors and app skin, and applies peak/hot fill without adding separate halo geometry or overlay face planes. The `Pixel Fill` control in `Cube Surface` tunes each face tile from the older separated-pixel mode to edge-to-edge filled pixels. `Surface Checker Opacity` scales the idle/unlit checkerboard read independently from face count and bloom settings. The `Rim Halo Edge` control adds a material-only ring highlight at the bloom boundary. The `Cube Outline` control in `Speaker Shape` drives retained cube-edge child-node material alpha from invisible to clear edge outlines without rebuilding the speaker body geometry; the edge bars are intentionally thinner and lower opacity than the first outline pass. The old `Speaker Height` slider is gone; older saved `speakerHeight` values decode but no longer affect review-app cube geometry or material keys. Prism and Sphere keep the simpler existing material tint behavior while inheriting the selected speaker palette.

The `Label Font` tray switches SceneKit speaker-number labels between grouped Normie, Nerd, and Nostromo typefaces and includes a `Font Size` slider. Normie contains System Default, Helvetica Black, and Futura; Nerd contains Press Start 2P, Minecraft, and Chintzy CPU BRK; Nostromo contains Archivo Black, Jost, Michroma, and Sevastopol Interface. Bundled offline fonts are SwiftPM resources registered through CoreText from `Bundle.module`; Jost uses the static `Jost-Regular.ttf` resource and renders through AppKit-generated label textures on billboard planes so SceneKit digit tessellation cannot collapse 6/9 glyphs into dot fragments. Older saved JSON values for City Light, Pump Demi, Eurostile Bold Extended, or Microgramma decode to System Default. Font and font-size changes rebuild label text geometry without rebuilding shell or speaker body geometry.

`Meter Source` has four mutually exclusive modes: `Music`, `Impulse Test Ripple`, `Impulse Test Waves`, and `Impulse Test Orbiting Comets`. Music uses the local-audio/fake review meter source. Orbiting Comets now uses exactly two larger comets with longer hot VU trails, and the left rail `Render Type` can keep local audio as All Mono or use the mono RMS/peak sample to excite the ripple, waves, or comets spatial patterns. Fog keeps the same 0...100 slider but uses a lighter low/mid curve and stronger max fog. The `Bloom Style` tray selects Soft Center Bloom, Hot Core Bloom, Halo Edge Bloom, and Block Center Bloom without reset/export buttons or a four-up preview. The `Saved Themes` tray saves the visual payload with an optional stable `themeID`. The payload includes top-level tuning fields including `speakerLabelFont`, `speakerLabelFontSizeSlider`, `speakerLabelFontSizeScale`, `geodesicRenderStyle`, and a `leftPanel` block for audio source mode/file metadata/play state/render mode, camera view, yaw, pitch, zoom, spin, adjusted-camera flag, speaker type, speaker size/fog slider values and resolved values, speaker numbers, hidden lines, and selected channel. Theme load ignores audio file fields and selected channel so themes remain visual settings only. The `Diagnostics` tray stays collapsed by default and includes raw RMS, raw peak, calibrated RMS, display scalar, hot scalar, and diagnostic channel values.

The project launcher `Open Orbital View Kit.command` is the current refresh path for the verbose local `.app` bundle. It builds `OrbitalViewViewer`, copies the executable into `Contents/MacOS/OrbitalViewViewer`, copies `OrbitalViewKit_OrbitalViewReview.bundle` into `Contents/Resources/`, removes the stale pre-split SwiftUI resource bundle if present, restarts any stale viewer process, and opens the refreshed app so bundled label fonts are available offline.

The parent `vibecode projects` folder also has `Open Orbital View Kit Latest.command`, a thin wrapper that delegates to this checkout's project launcher for Finder access.

The review app also has a local audio file input mode for quick visual testing. `Choose File` loads a local audio file, side-by-side transport icon buttons control Play and Pause, and the current file meter is reduced to one mono RMS/peak sample that drives every speaker equally. This intentionally does not change the production contract: downstream hosts should continue to feed real `SpeakerMeterFrame` values keyed by physical channel.

The production `OrbitalView` wrapper and MTKView bridge still exist for downstream hosts. The SceneKit review executable is the approved visual/tuning surface for this iteration; `OrbitalViewViewerSupport` remains as demo-content support for the production wrapper tests and future review paths.

Launch command:

```text
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command
```

### Visual Telemetry Stress Gate

Purpose:

```text
Provide a deterministic display-only pressure fixture for viewport no-backpressure tests.
```

Implementation locations:

```text
Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift
Tests/OrbitalViewViewerTests/OrbitalViewViewerDemoContentTests.swift
docs/visual-telemetry-stress-gates.md
```

The fixture uses 30 physical speaker channels, 128 source objects, 16 trail points per object, 60 FPS active motion, 120 FPS incoming meter cadence, open diagnostics, and `.localLivestreamTestGenerator` source metadata for the `32-object-should-pass-stress` profile. Its diagnostics model stale display drops through overload actions only. It does not establish host audio callback p99, deadline, route, device I/O, MIDI/OSC, or meter-extraction compliance.

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

The current draw path renders instanced cube/prism speakers from scene speaker anchors. Meter values affect material/color state only, preserving the rule that VU behavior must not resize or rebuild static speaker geometry.

### Native Cube VU Renderer

Purpose:

```text
Translate the browser cube VU behavior into native Metal speaker materials without porting browser runtime code.
```

Implementation locations:

```text
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewCore/OrbitalViewSpeaker.swift
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewSwiftUI/OrbitalView.swift
```

The cube path uses `SpeakerCubeVUScalars`:

```text
rawRms -> calibratedRms -> displayVuScalar -> cube bloom
rawRms -> calibratedRms -> hotScalar -> whole-cube hot fill
meter value -> paletteHeat -> VU ramp color
```

The production renderer consumes host-provided `SpeakerMeterFrame` values keyed by physical channel. Browser Web Audio, tab capture, HTML controls, and JavaScript runtime behavior remain mockup-only references.

### Dynamic Object Overlay

Purpose:

```text
Keep source-object visualization and object meter state separate from physical speaker meters.
```

Implementation locations:

```text
Sources/OrbitalViewCore/OrbitalViewObjects.swift
Sources/OrbitalViewRender/OrbitalViewRenderState.swift
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewSwiftUI/OrbitalViewMetalView.swift
```

`OrbitalViewObjectFrameSet` and `ObjectMeterFrame` are keyed by source object ID and render beside speaker VU inputs. They do not collapse into `SpeakerMeterFrame` and do not affect speaker static geometry.

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

The current invariant tests compare static speaker draw inputs across meter-only and camera-only updates. Static inputs include speaker ID, physical channel, projected position, and quad radius.

## Test Map

```text
unit direction validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
speaker validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
shell reference validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
meter channel identity -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
camera center-lock presets -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Wavefield JSON layout adaptation -> Tests/OrbitalViewWavefieldTests/WavefieldSpeakerLayoutSceneAdapterTests.swift
Wavefield meter-frame adaptation -> Tests/OrbitalViewWavefieldTests/WavefieldMeterFrameAdapterTests.swift
renderer seam state separation and events -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
offscreen renderer smoke output -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
renderer static draw-input invariants -> Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
cube VU scalar math and defaults -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
dynamic object frames/meters -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift, Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
SwiftUI wrapper configuration and coordinator behavior -> Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
renderer test harness plan -> docs/renderer-test-harness.md
visual mockup inline script syntax -> node parse command in .tasks/004-orbital-viewport-visual-mockup.md
renderer backend decision -> docs/decisions/0002-renderer-backend.md
```

## Last Updated

2026-05-21 Orbisonic family theme tray consolidation
