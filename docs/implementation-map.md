# Implementation Map

> Current note: the explicit Cube VU speaker merge task supersedes the earlier deprecation warning for the native Cube VU/object overlay work. The active direction is this package's SwiftUI + MetalKit wrapper with reusable cube/object/performance controls, not a new standalone app copied from Orbital View VU Kit. See `docs/deprecated/native-cube-vu-chat-work.md` for historical context only.

## Purpose

This file maps project behavior to files and folders so the current system can be understood without reading every document. The current head project name is `Orbital View`; older `Orbital View Kit`, `Orbital View VU Kit`, `Orbital View Turbo`, and `orbital-view-with-objects` names are non-head variation labels tracked in `docs/project-identity.md`.

## Top-Level Structure

```text
docs/                         Active project documentation
docs/project-identity.md      Canonical head name and non-head variation labels
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

Swift source directories are now present for `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewSpatGRIS`, `OrbitalViewRender`, `OrbitalViewSwiftUI`, `OrbitalViewReview`, `OrbitalViewViewerSupport`, the `OrbitalViewViewer` executable, and the review-only `OrbitalViewHeadlessBenchmark` executable.

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

Current meter frames include `OrbitalViewTelemetrySourceDescriptor` metadata so speaker and object telemetry can identify its source of truth without changing channel/object identity. `SpeakerMeterVisualSettings` owns display-only speaker type selection through `SpeakerMeterSpeakerType` (`cubeVU`, `pixelJets`, or `cellJets`), a validated Pixel Density of `1...9`, and a validated jet length in pixels; older settings payloads default to Cube VU and `48` px, while legacy `jetsVU` / `solidJets` payloads migrate to Pixel Jets. `SpeakerCubeVUScalars` preserves raw RMS as raw evidence and can accept optional display drive for visual reach. Pixel Jets uses VU-gated axial/cross face pixels sourced from the selected VU ramp. Cell Jets uses the same display-only radial jet length with retained coarse five-face cells and no texture/shader generation. Neither jet style creates autonomous time-only pulses in normal meter paths. `OrbitalViewInputDiagnostics` can also record allowed lossy-display overload actions: dropped stale frames, decimated display refresh, latest complete snapshot retention, and diagnostics set outside realtime.

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

Wavefield owns external stream parsing, local livestream generator profiles, MIDI streams, realtime event queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and performance gates. Orbital View receives prepared scene, speaker meter, object frame, object meter, diagnostics, and source metadata snapshots only.

### SpatGRIS Layout Import/Export

Purpose:

```text
Load and save SpatGRIS receiver speaker layouts and source layouts without layout editing.
```

Implementation locations:

```text
Sources/OrbitalViewSpatGRIS/
Tests/OrbitalViewSpatGRISTests/
Sources/OrbitalViewReview/OrbitalViewportMockup.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
```

`OrbitalViewSpatGRIS` parses current `SPEAKER_SETUP` `4.0.0`, legacy `SPEAKER_N`, fixture-covered older speaker setup XML, `SPAT_GRIS_PROJECT_DATA` source metadata, and `/spat/serv` source-position OSC payloads. The parser rejects unsafe XML, malformed tuples, duplicate or out-of-range IDs, invalid SpatGRIS modes, oversized files, and invalid OSC ports. Export normalizes receiver and source layouts back to current SpatGRIS `SPEAKER_SETUP` XML.

The review app adds a right-panel `Speaker and Source Layout` section after the top `Sound Metering Input` / `Input` area with `Sonic Sphere Speakers` and `Source Speakers` trays. The speaker tray says `Speaker layout in SPAT XML format.` and the source tray says `Source speaker layout in SPAT XML format.` Receiver and source layout stores mirror saved-theme behavior: generated no-overwrite names, saved rows, invalid XML rows, `Load`, `Set Default`, metadata defaults, manual rename recovery, and refresh. Source project metadata is display/state metadata only; it does not create editable layout fields.

The review-only UDP listener lives in `OrbitalViewReview` and listens for SpatGRIS `/spat/serv` source movement on a configured valid UDP port, defaulting to `18032`. Production targets do not open sockets.

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

Orbisonic provides prepared bus/object/speaker meter snapshots from explicit tap points, labels provenance as `orbisonicPreparedMeterTap`, keeps playback/routing/Core Audio/device/output ownership in Orbisonic, and preserves Orbisonic design-language palette grammar. Orbisonic speaker telemetry can publish VU display intent through existing `vuNormalized` and `vuDbFS` fields plus an explicit VU-normalized-valid record flag; Orbital View uses `vuNormalized` only as display drive when that flag is set while preserving raw RMS, raw peak, clip state, and physical channel identity.

Splat uses Orbital View for virtual speakers, source objects, renderer-kernel overlays, neutral geometry review, camera/selection, and diagnostics. Splat edit/export actions stay preparation/control behavior, canonical 3D coordinates remain canonical, and neutral geometry import/export stays separate from browser or DomeLab runtime code.

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

The current renderer stores scene, speaker meters, cube/jet VU settings, dynamic object frames, object meters, object visual settings, camera, and selection state separately. It exposes an `MTKViewDelegate` path and includes an offscreen-tested Metal draw pipeline with one instanced cube/prism mesh per speaker. Speaker meter updates change material/color payloads only; static speaker geometry and physical channel mapping stay stable. Pixel Jets is interpreted as display-only outward radial prism geometry in shader space from the speaker anchor, using the VU-gated axial/cross pixel-cell branch without changing the scene speaker shape or cache key. Cell Jets uses the same outward shader geometry with a separate low-CPU stepped-cell branch driven by the selected color ramp and current meter scalar only; its idle opacity uniform can hide silent Cell Jets without suppressing active meter cells, and the tip cap is forced dark until full-scale display or clip. The Metal screen projection uses canonical `x` horizontally and canonical `z` vertically, treating canonical `y` as depth/front. Dynamic object overlays render through a separate retained quad path.

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

The current wrapper provides `OrbitalView`, an `NSViewRepresentable` MetalKit bridge, coordinator tests, and opt-in collapsible tuning trays. The binding initializer lets hosts tune `SpeakerMeterVisualSettings`, `ObjectVisualSettings`, and `OrbitalViewPerformanceSettings`; value-based initializers remain available for hosts that do not want the tuning surface. The production tuning tray now exposes speaker display type and shows `Jet Length` for Pixel Jets and Cell Jets while preserving the existing Cube VU style contract. Cell Jets also exposes `Idle Opacity`, defaulting to 100%, while other speaker types omit that control. Pixel Density sliders are capped at `1...9`. The production target does not own SceneKit, local audio playback, file dialogs, PNG export, bundled review fonts, or theme JSON persistence. Gestures, hit testing, and production inspector UI remain deferred.

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

`OrbitalViewReview` owns `OrbitalViewportMockup`, the confirmed VU Kit SceneKit geodesic viewport review app, plus its SwiftPM font resources. This target may use review-only `AVFoundation`, `AppKit`, `SceneKit`, `NSOpenPanel`, CoreText font registration, app-bundle theme JSON, SpatGRIS layout stores, a review-only UDP OSC listener, and PNG export behavior. SceneKit remains a Y-up implementation detail, so canonical vectors are mapped as `(x, y, z) -> (x, z, y)` at the SceneKit boundary. Pixel Jets review geometry extends custom prism geometry outward along the speaker's radial normal from the speaker anchor, stores its length in saved-theme JSON with legacy-safe defaults, applies retained axial/cross pixel textures to the side faces, keeps no-provider/silent meters nearly dark, follows the selected VU ramp, uses no SceneKit shader modifiers, and shares the Cube Outline child-node path. Cell Jets uses the same outward custom prism geometry but assigns one retained material per five-face cell, so meter updates mutate color/emission/alpha without geometry or texture rebuilds; Cell Jets idle opacity affects only silent cells, and the final end-capped cell colors only at full-scale/clip. SceneKit and canvas fallback speaker labels are positioned from the furthest visible speaker/meter extremity plus the small Cube VU-style gap. Production hosts should import `OrbitalViewSwiftUI`; the review executable imports `OrbitalViewReview`.

The ribbed speaker sphere still derives deterministic fitted rib/ring diagnostic segments from active speaker centers, but SceneKit no longer models each segment as its own `SCNCylinder` node or as an independent open tube fragment. The review surface builds ordered vertical-rib and horizontal-ring curves, sweeps one welded tube along each full curve, shares cross-section rings across adjacent spans, caps vertical rib endpoints, closes horizontal rings back to their first cross-section ring, and still batches all vertical curves into one mesh node plus all horizontal curves into one mesh node. The old rib alpha values now drive opaque constant-material brightness/emission rather than partially transparent tube surfaces. `Hidden Lines` off shows an invisible depth-only SceneKit clipping plane through the fitted ribbed sphere center, perpendicular to the current camera direction, so rear-half frame fragments are hidden by normal depth testing. `Hidden Lines` on hides that clipping plane and reveals the full welded frame. Camera-only motion updates the clipping-plane transform from the cached ribbed fit and does not walk ribbed segments, rebuild topology, rewrite ribbed materials, or use SceneKit material KVC cutaway uniforms. Ribbed sphere color authority is retained SceneKit material diffuse/emission state only; the rejected ribbed shader modifier path is removed because it produced a live magenta shader fallback despite source-level palette state appearing correct.

The right panel now places `Speaker and Source Layout` directly after `Input`. Imported receiver speakers drive the SceneKit speaker geometry and layout-derived scene bounds. Imported sources and review OSC source movement draw in a separate source marker layer with independent IDs and colors. File paths, XML warnings, OSC packet parse failures, and raw diagnostics are recorded in Diagnostics rather than the primary panel.

The review viewport records actual SceneKit render/update cadence through the review coordinator. The viewport shows a bottom-right compact FPS chip with only the status color dot and current FPS value; target and threshold status text remain diagnostics data, not visible chip copy. FPS diagnostics log entries use the existing capped Diagnostics log at up to five steady samples per second plus immediate target/below/under-target status transitions. During active spin, the headed review app uses SceneKit's render delegate for camera motion and FPS sampling while meter/material work remains on the existing lower-rate meter cadence. The render delegate never blocks behind an in-progress main-thread SceneKit mutation; if the coordinator mutation lock is already held, that active camera frame is skipped so SceneKit transaction commit cannot deadlock against the render queue.

`OrbitalViewHeadlessBenchmark` is a review-only command-line executable that imports `OrbitalViewReview`, builds the same SceneKit Cube VU review configuration offscreen, renders through Metal without opening the SwiftUI window, and reports idle versus active offscreen throughput. It can explicitly enable the ribbed sphere with `--ribbed`, tune density with `--vertical-ribs` and `--horizontal-rings`, enable hidden lines, and set fog density. Output includes ribbed segment count, SceneKit node count, FPS, and process CPU percent. It is an operator/performance evidence tool, not a production host API, and it must not alter visible speaker design or host-renderer contracts.

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
Sources/OrbitalViewHeadlessBenchmark/
Sources/OrbitalViewViewer/
Sources/OrbitalViewViewerSupport/
Tests/OrbitalViewViewerTests/
```

The viewer executable now imports `OrbitalViewReview` and hosts `OrbitalViewportMockup`, the confirmed VU Kit SceneKit viewport review app. This preserves the original camera/view-detail controls, replaces the old imported/Fey shell workflow with the ribbed sphere overlay, preserves full-window PNG export, and keeps the adaptive SceneKit interaction loop. The desktop left rail is a full-height always-on operator rail: its visible background and divider run from the top to bottom of the window, the title reads `Orbital View` with the Wavefield Receiver player-panel title treatment, and Camera/View Detail sit directly underneath the title. The `Hidden Lines` switch applies across the review scene: off hides the back half of the ribbed sphere plus rear speaker bodies and rear speaker labels; on reveals them with the existing rear alpha/fog treatment. The left `View Detail` rail exposes the default-off display-only `Ground Plane` toggle after `Speaker Labels` and `Hidden Lines`. The right-panel `Ground Appearance` tray exposes `Grid Visibility`, `Grid Spacing`, and a separate ground palette choice that draw a display-only 10 x 10 horizontal line grid at canonical `z = -1.2`, mapped into SceneKit's Y-up space as `(x, y, z) -> (x, z, y)`, with half extent `5.0` and default spacing `0.5`. A single top `Input` tray exposes the `Telemetry`, `Local Song`, and `Impulse Test` selector and owns telemetry details, local song transport/render controls, impulse pattern controls, and `Meter Source` status. Speaker type selection now lives in the right `Speaker Shape` tray and exposes `Prism`, `Sphere`, and `Cube VU`; Cube VU uses square cube geometry with the shared Cube VU scalar/material path.

The SceneKit review camera keeps canonical left/right semantics in viewport space: `+X = right` projects to screen right and `-X = left` projects to screen left across Plan, Elevation, and Isometric. DomeLab-style drag control keeps horizontal movement on yaw and vertical movement on pitch, with the accepted right/left and up/down drag directions pinned in review tests. Canonical Z-up speaker data and the SceneKit coordinate bridge are unchanged.

The right panel is now a tuning/debug surface instead of a large meter inspector. It starts with a `Sound Metering Input` header above one collapsed-by-default expandable `Input` tray containing the source selector, mode-specific controls, and `Meter Source` rows; `Speaker and Source Layout` contains collapsed-by-default `Sonic Sphere Speakers` and `Source Speakers`; `Roll the dice on looks` contains a centered icon-only global dice action; `Theme` contains `Color Palette` followed by `Saved Themes`; `Speaker Appearance` contains `Speaker Shape`, `Label Font`, the dynamic `Cube Surface` / `Jet Surface` tray, and `Bloom Style`; `Sphere Appearance` contains `Sphere Geometry` and `Sphere Palette`; `Ground Appearance` contains `Ground Appearance`; `Meter Behavior` contains `Meter Response` and `Performance`; `Diagnostics` contains `Diagnostics`. All collapsible right-panel trays start closed by default, with an explicit empty default expansion list in `OrbitalViewportMockup`. `Color Palette` uses the Orbisonic family palette list and drives the app skin, physical speaker pixels, source marker pixels, ribbed sphere palette, ground grid palette, and Cube VU ramp together. New saved themes mirror the legacy `sourceSpeakerRenderStyle` field to the global `renderStyle`; older saved themes with separate source palette values still decode safely but no longer expose a separate source palette tray. `Sphere Geometry` exposes the default-off `Ribbed Speaker Sphere` switch plus `Rib Thickness`, `Vertical Ribs`, and `Horizontal Rings`; `Rib Thickness` is clamped to `70%...250%` because thinner welded tubes visibly break up in the SceneKit review surface. `Sphere Palette` owns only `Sphere Palette` and `Sphere Saturation`; changing it after a global palette choice locally overrides only the ribbed sphere palette/saturation. `Ground Appearance` uses the same palette list independently for grid lines and may locally override the ground palette after a global palette choice. Choosing a new global `Color Palette` resets the sphere and ground palette overrides to match. `Cube Surface` / `Jet Surface`, `Bloom Style`, and `Meter Response` each include a local dice-icon randomizer, while `Roll the dice on looks` randomizes the broader view/visual state except Input, including Color Palette, Sphere Geometry, Sphere Palette, and Ground Appearance. The palette list is sourced from the Orbisonic design-language brief and includes Purple, Flamingo, Green, B&W, Daft Punk Bow, Rack Mint, Rack Pink, Rack Blue, Ember Console, Graphite, Flamingo Green, and Dusty Rose. `Sphere Saturation` desaturates both ribbed speaker sphere color lanes to grayscale at the low end and restores the selected sphere palette accent hue on both the vertical and horizontal batches at the high end through retained SceneKit material diffuse/emission values, without shader modifiers and without changing speaker, Cube VU, source marker, or ground-plane update state. Palette selection raises the exported default zero sphere saturation to a visible hue value. The ribbed overlay fits active receiver speaker centers, including imported SpatGRIS layouts, from the speaker centroid and median speaker radius, then uses evenly spaced symmetrical longitude ribs and latitude rings. DEBUG-only ribbed probes can force rib visibility, suppress saved-theme/random-animation interference, trace render writes, force-green the live material state, force continuous rendering, and expose the live build/style/saturation/material fields through an accessible overlay. `Grid Visibility` scales grid opacity only, `Grid Spacing` rebuilds only grid line geometry, and both remain isolated from speaker material, labels, source markers, and ribbed-sphere keys. The `Saved Themes` tray saves, refreshes, loads, and sets defaults for JSON themes in `Contents/Resources/View Themes/`; new files get unique two-word names, manual filename changes become the visible app label on refresh, and default selection uses a stable `themeID` before falling back to filename. The old Scene summary, selected-speaker placeholder, and 30-channel VU list are removed. Object Overlay, Trails, Glow Trails, and Bounds are inactive in this review surface for now, while the reusable object contracts and renderer paths remain available for future Wavefield work.

The default review state is now explicit in `OrbitalViewportMockup` and is sourced from the exported settings file `Orbital View Settings 2026-05-21-171537.json`. Startup defaults select Purple for the speaker/app palette, Purple for the geodesic palette, hidden ribbed speaker sphere, Rib Thickness `100%`, `16` vertical ribs, `8` horizontal rings, Cube VU, Hot Core Bloom, `Telemetry` with `No Provider`, Impulse Test Ripple as the remembered impulse pattern, geodesic saturation `0`, Pixel Fill `0.86`, Surface Checker Opacity `0`, Cube Outline `0.64`, and 120 fps active motion while leaving Core-level `OrbitalViewportCubeVUSettings.default` unchanged for contract tests. The zero geodesic saturation is preserved for exported-settings compatibility, but palette selection raises it to a visible value.

The SceneKit Cube VU review path uses one retained per-speaker material with a retained 9x9 pixelated face texture cache applied directly to the actual six `SCNBox` cube faces. It uses a Cube-VU-only readable face scale for visibility at small on-sphere speaker sizes, applies RMS-driven center bloom through `SpeakerCubeVUScalars`, uses the selected speaker palette for fog/label/VU colors and app skin, and applies peak/hot fill without adding separate halo geometry or overlay face planes. The `Pixel Density` slider at the top of `Cube Surface` / `Jet Surface` owns the shared face-pixel density value, while `Pixel Fill` tunes each tile from the older separated-pixel mode to edge-to-edge filled pixels. `Surface Checker Opacity` scales the idle/unlit checkerboard read independently from face count and bloom settings. Cell Jets alone adds `Idle Opacity` to the Jet Surface tray. The `Rim Halo Edge` control adds a material-only ring highlight at the bloom boundary. The `Cube Outline` control in `Speaker Shape` drives the approved twelve separate chamfered SceneKit edge-box outline child nodes per Cube VU, Pixel Jets, and Cell Jets speaker from invisible to clear edge outlines without rebuilding the speaker body geometry or changing the approved cube/jet faces/materials. The old `Speaker Height` slider is gone; older saved `speakerHeight` values decode but no longer affect review-app cube geometry or material keys. Prism and Sphere keep the simpler existing material tint behavior while inheriting the selected speaker palette.

The SceneKit review renderer now treats material cadence and material visual state separately. Meter-frame advancement alone is not proof that speaker or source materials changed: quantized per-speaker/source signatures include RMS/peak-derived scalar state, alpha, selection, source state, and palette-affecting settings, so silent or unchanged buckets update coordinator keys without touching SceneKit materials. Generic SceneKit material writes are also state-cached by retained `SCNMaterial` identity, and VU ramp `NSColor` values are cached by render style and high-resolution ramp bucket. The no-op render gate skips `SCNTransaction` commits and `needsDisplay` requests when every scene update key is unchanged or only unchanged-meter material keys advanced.

The `Label Font` tray switches SceneKit speaker-number labels between grouped Normie, Nerd, and Nostromo typefaces and includes a `Font Size` slider. Normie contains System Default, Helvetica Black, and Futura; Nerd contains Press Start 2P, Minecraft, and Chintzy CPU BRK; Nostromo contains Archivo Black, Jost, Michroma, and Sevastopol Interface. Bundled offline fonts are SwiftPM resources registered through CoreText from `Bundle.module`; Jost uses the static `Jost-Regular.ttf` resource and renders through AppKit-generated label textures on billboard planes so SceneKit digit tessellation cannot collapse 6/9 glyphs into dot fragments. Older saved JSON values for City Light, Pump Demi, Eurostile Bold Extended, or Microgramma decode to System Default. Font and font-size changes rebuild label text geometry without rebuilding shell or speaker body geometry.

Live telemetry samples keep raw RMS/peak for diagnostics and channel identity, while Cube VU, Pixel Jets, and Cell Jets use `vuNormalized` as display drive only when Orbisonic marks the VU-normalized slot valid, falling back to raw RMS for absent or untrusted VU slots. Diagnostics show display drive separately from raw RMS and raw peak so full visual scale is not interpreted as clipping by itself.

The collapsed-by-default top `Input` tray sits under the `Sound Metering Input` header and is the only global review source picker when expanded. `Telemetry` maps to the future Orbisonic telemetry consumer path but currently displays `No Provider` and a silent meter source when no review advertiser is present; if multiple advertisers are available, it renders selectable full-width advertiser buttons and preserves selection by advertiser ID. `Local Song` exposes `Choose File`, Play/Pause transport, filename/status text, and one mono RMS/peak music meter; no selected file is also silent. `Impulse Test` exposes `Ripple`, `Waves`, and `Orbiting Comets`, with Orbiting Comets using exactly two larger comets with longer hot VU trails. The `Meter Source` rows report selected source details/status inside `Input` instead of changing global source mode. Legacy local-song render-mode fields still decode for older theme JSON but no longer drive visible synthetic speaker patterns. Fog keeps the same 0...100 slider but uses a lighter low/mid curve and stronger max fog. The `Bloom Style` tray selects Soft Center Bloom, Hot Core Bloom, Halo Edge Bloom, and Block Center Bloom without reset/export buttons or a four-up preview. The global `Roll the dice on looks` action randomizes camera, zoom, spin, fog, speaker labels, hidden lines, Color Palette, Sphere Geometry, Sphere Palette, ground/grid, speaker shape, label font/size, cube surface, bloom, meter response, and performance FPS while preserving Input, theme metadata, selected speaker, and diagnostics. The `Saved Themes` tray saves the visual payload with an optional stable `themeID`. The schema `9` payload includes top-level tuning fields including `speakerLabelFont`, `speakerLabelFontSizeSlider`, `speakerLabelFontSizeScale`, legacy-compatible `sourceSpeakerRenderStyle`, `geodesicRenderStyle`, `geodesicSaturation`, `showRibbedSpeakerSphere`, `ribbedSphereThickness`, `ribbedSphereVerticalRibs`, `ribbedSphereHorizontalRings`, `groundAppearance`, `sourceMode`, legacy `driveMode`, and a `leftPanel` block for audio source mode/file metadata/play state/render mode, camera view, yaw, pitch, zoom, spin, adjusted-camera flag, speaker type, speaker size/fog slider values and resolved values, speaker labels, hidden lines, legacy grid plane, legacy grid visibility, and selected channel. Theme load ignores audio file fields, selected channel, and legacy separate source palette values so themes remain visual settings only under the global color palette model. Older theme JSON without `sourceSpeakerRenderStyle` falls back to the decoded global palette; older theme JSON without `sourceMode` infers `Local Song` from legacy music drive mode and `Impulse Test` from legacy impulse drive modes; older theme JSON without `groundAppearance` falls back to the legacy left-panel grid fields and default spacing/theme values. Older JSON containing `hideSphereStructure` decodes safely but no longer affects rendering or exported JSON, older JSON without the ribbed fields defaults the ribbed overlay to hidden with default thickness/counts, and legacy `showSpeakerCenterStruts` decodes into ribbed sphere visibility when the new visibility key is absent. The relocation keeps the existing review settings JSON shape, including the legacy `leftPanel.audioSource` block. All right-panel collapsible trays, including `Diagnostics`, start collapsed by default; `Diagnostics` includes raw RMS, raw peak, display drive, calibrated RMS, display scalar, hot scalar, and diagnostic channel values when opened.

The project launcher `Open Orbital View.command` is the current refresh path for the verbose local `.app` bundle. It builds `OrbitalViewViewer`, copies the executable into `Contents/MacOS/OrbitalViewViewer`, copies `OrbitalViewKit_OrbitalViewReview.bundle` into `Contents/Resources/`, copies the tracked black-background planet app logo from `dist/app-logo/AppIcon.icns` into `Contents/Resources/AppIcon.icns`, sets `CFBundleIconFile` to `AppIcon`, removes the stale pre-split SwiftUI resource bundle if present, restarts any stale viewer process, and opens the refreshed app so bundled label fonts are available offline. The generated app-icon source lives at `dist/app-logo/OrbitalViewKit-AppIcon-source.svg`, with the current 1024 PNG and ICNS beside it and the previous gradient option 02 icon archived under `dist/app-logo/archive/`.

The parent `vibecode projects` folder also has `Open Orbital View Latest.command`, a thin wrapper that delegates to this checkout's project launcher for Finder access.

The review app also has a local audio file input mode for quick visual testing under the `Local Song` source tray. `Choose File` loads a local audio file, transport icon buttons control Play and Pause, and the current file meter is reduced to one mono RMS/peak sample that drives every speaker equally. This intentionally does not change the production contract: downstream hosts should continue to feed real `SpeakerMeterFrame` values keyed by physical channel.

The production `OrbitalView` wrapper and MTKView bridge still exist for downstream hosts. The SceneKit review executable is the approved visual/tuning surface for this iteration; `OrbitalViewViewerSupport` remains as demo-content support for the production wrapper tests and future review paths.

Launch command:

```text
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Latest.command
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

The fixture uses 30 physical speaker channels, 128 source objects, 16 trail points per object, 120 FPS active motion, 120 FPS incoming meter cadence, 30 FPS displayed meter cadence, open diagnostics, and `.localLivestreamTestGenerator` source metadata for the `32-object-should-pass-stress` profile. Its diagnostics model stale display drops through overload actions only. It does not establish host audio callback p99, deadline, route, device I/O, MIDI/OSC, or meter-extraction compliance.

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

Future performance direction:

```text
Move the approved Cube VU face visual fully into the production Metal renderer when SceneKit texture churn becomes the limiting factor.
```

The reason is performance architecture, not a visual redesign: the SceneKit review path can match the approved Cube VU look, but live profiling showed the slow path is CPU-side face-texture generation and `SCNMaterialProperty` image assignment. A Metal implementation should preserve static instanced speaker geometry and physical channel identity, then update compact per-speaker material payloads for display scalar, hot scalar, palette heat, clip, alpha, face-pixel settings, bloom, checker, and rim values. The shader should quantize cube-face UVs into the same readable pixel grid, compute center bloom/hot fill/clip in shader math, and keep outline visuals equivalent to the approved twelve-edge SceneKit look. This belongs in a future protected `OrbitalViewRender` slice with OpenSpec/protected-path review if public renderer behavior changes, retained-buffer tests, offscreen pixel probes, and screenshot parity against the approved SceneKit review surface.

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
