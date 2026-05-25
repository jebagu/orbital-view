# Test Strategy

> Current note: the explicit Cube VU speaker merge task re-activates the renderer, SwiftUI wrapper, object overlay, and viewer tests as active coverage for this package. The historical deprecation record remains only as context.

## Current Package

The Swift package exists and is verified with the full Xcode toolchain.

## Testing Goals

Once implementation starts, the test suite should prove:

- core contracts validate invalid data explicitly
- physical speaker channel identity is preserved
- meter frames preserve levels by channel
- monitor camera presets keep the target at origin
- imported shell geometry references are valid
- downstream adapters do not reorder Wavefield/Fey speakers
- canonical coordinates stay Z-up: `x = right`, `y = front`, `z = up`
- local Wavefield JSON adapter rejects invalid layout shape explicitly
- local Wavefield meter adapter rejects duplicate channels and invalid levels explicitly

## Unit Tests

Use for:

- vector and unit direction validation
- shell node/edge/face validation
- speaker ID/channel/shape validation
- meter frame identity
- telemetry source descriptor defaults and validation
- telemetry overload diagnostics round-trip and deduplication
- camera preset state
- scene builder behavior

## Integration Tests

Use when a downstream adapter is added:

- load or construct the Fey 30 layout
- adapt it to `OrbitalViewSceneSpec`
- assert 30 physical speaker records
- assert channels remain `1...30`
- assert Fey channels group by rising `z` rings: `1-5`, `6-10`, `11-15`, `16-20`, `21-25`, `26-30`
- assert channel 1 is on the lowest ring with negative canonical `z`
- assert labels remain stable
- assert directions match the source layout
- reject unsupported axes and invalid speaker counts
- map channel/rms/peak records into `SpeakerMeterFrame`
- preserve missing meter channels as absent values
- derive clip from a configurable threshold
- apply explicit meter source descriptors such as external Wavefield stream or local livestream test generator
- preserve Wavefield object IDs as source-object identity when prepared object frame and object meter snapshots are provided by the host
- treat local livestream generator profiles as source metadata and stress inputs, not alternate audio paths

## Renderer Tests

The accepted renderer backend is MetalKit / MTKView, with SwiftUI in a wrapper target.

Renderer harness details live in:

```text
docs/renderer-test-harness.md
```

Current renderer seam tests cover:

- scene updates increment structural revision without touching meter revision
- meter updates increment meter revision without rebuilding scene state
- camera and selection updates emit events
- `OrbitalViewMetalRenderer` provides an `MTKViewDelegate` seam
- offscreen Metal smoke rendering produces a non-clear frame from a deterministic scene, or skips clearly when no Metal device exists
- meter-only and camera-only updates keep static speaker draw inputs stable
- meter source descriptors stay metadata and do not change renderer static geometry
- speaker draw inputs preserve ID/channel order and stable cube/prism dimensions
- speaker draw inputs project canonical `x` horizontally and canonical `z` vertically, treating canonical `y` as depth/front
- cube VU defaults, scalar math, range validation, material payloads, hot-fill independence, and palette-drive behavior stay separate from raw RMS
- dynamic object frame/meter/settings updates render through a separate object path and do not rebuild speaker static geometry
- retained speaker/object buffers do not reallocate on meter/settings/camera-only renders

Future renderer drawing checks should cover:

- center-lock survives resize and camera preset changes
- selection emits speaker/channel identity without mutating playback
- renderer target compiles without adding audio, playback, routing, MIDI, OSC, or downstream app dependencies
- meter updates can be tested separately from structural scene updates
- targeted pixel probes catch blank frames without brittle full-frame snapshots

## SwiftUI Wrapper And Review Tests

Current wrapper skeleton tests cover:

- `OrbitalView` initializes with camera and selection bindings
- identical configuration updates do not repeatedly increment structural renderer revision
- changed meter frames update meter revision without rebuilding scene state
- cube VU settings and object frames/meters forward through the coordinator without reloading scene state
- host-bound object visual settings and performance settings initialize through the tuning-surface initializer
- MTKView applies active 30/60 FPS and draw-on-demand performance settings
- camera and selection configuration emits renderer events

Current review-surface tests cover `OrbitalViewReview` through the existing SwiftUI test target:

- the confirmed SceneKit `OrbitalViewportMockup` viewer identity, left rail options, right tuning panel inventory, geodesic shell counts, and adaptive FPS constants remain intact
- SceneKit review-app `View Detail` stays focused on Speaker Size, Fog Density, Speaker Numbers, and Hidden Lines
- SceneKit review-app audio source uses native transport icon buttons for Play and Pause
- SceneKit review-app right panel includes Theme, Speaker Appearance, Sphere Appearance, Ground Appearance, Meter Behavior, and Diagnostics section headers with the active tray order `Saved Themes`, `Speaker Shape`, `Speaker Pattern`, `Label Font`, `Color Palette`, `Cube Surface`, `Bloom Style`, `Sphere Geometry`, `Geodesic Appearance`, `Ground Appearance`, `Meter Source`, `Meter Response`, `Performance`, and `Diagnostics`
- SceneKit review-app `Ground Appearance` exposes Ground Palette, Grid Plane, Grid Visibility, Grid Spacing, and Grid Size controls
- SceneKit review-app right panel includes the `Saved Themes` tray, app-resource theme directory, and Save/Refresh/Load/Set Default controls
- SceneKit review-app `Color Palette` tray uses full-width custom theme buttons, includes the Orbisonic family palette list from `orbisonic-palette-brief`, and does not use a native segmented picker
- SceneKit review-app startup defaults are pinned to the exported settings JSON values without mutating the Core cube settings default contract
- SceneKit review-app meter-only ticks update material cadence without rebuilding shell or speaker geometry
- SceneKit review-app Cube VU controls preserve Core scalar defaults, default to 9x9 face pixels, default Cube Outline to invisible, keep outline constants delicate, and ignore old speaker-height values for geometry/material keys
- SceneKit review-app Cube VU retained face-texture support exposes the face-pixel quantization and center-fill contract on the actual cube faces without replacing the approved SceneKit surface
- SceneKit review-app Cube VU idle face textures have edge-to-edge pixels with no generated tile gaps and preserve an unlit checkerboard surface
- SceneKit review-app `Cube Surface` controls expose Pixel Fill and Surface Checker Opacity, can recover the older separated-pixel face mode, can mute the forced idle checkerboard without changing geometry, and keep their dice randomizer scoped to cube-surface values
- SceneKit review-app speaker type options include `Prism`, `Sphere`, and `Cube VU`, with full-width tray header hit targets for collapsible tuning sections
- SceneKit review-app `Label Font` tray exposes grouped Normie, Nerd, and Nostromo font options plus a Font Size slider; bundled fonts resolve from SwiftPM resources, removed unavailable fonts are absent from the selector and decode to System Default from older JSON, commercial install-only options fall back safely, and font/font-size changes rebuild label geometry but not shell or speaker body geometry
- SceneKit review-app Jost speaker labels use the static regular TTF resource, render through the texture-backed label path instead of `SCNText`, and preserve readable numeric labels for channels containing 6 and 9
- SceneKit review-app speaker `Color Palette` drives speaker colors and app skin, while `Geodesic Appearance` has an independent palette plus Geodesic Saturation that updates only the shell/geodesic material key
- SceneKit review-app grid-plane visibility, spacing, and ground palette changes stay isolated from shell, speaker geometry, speaker material, and label update keys
- SceneKit review-app local audio file metering reduces channel powers to equal mono speaker RMS/peak samples without requiring per-frame SwiftUI state
- SceneKit review-app `Meter Source` exposes Music, Impulse Test Ripple, Impulse Test Waves, and Impulse Test Orbiting Comets, with deterministic spatial patterns instead of random or uniform channel values; orbiting comets are exactly two broader hot trails
- SceneKit review-app left audio source exposes All Mono, Excite Ripple, Excite Waves, and Excite Comets render types that reuse the mono RMS/peak sample as a cheap spatial-pattern envelope
- SceneKit review-app `Bloom Style` exposes Soft Center Bloom, Hot Core Bloom, Halo Edge Bloom, and Block Center Bloom without reset/export controls or a four-up preview, and its dice randomizer chooses a different preset when possible
- SceneKit review-app `Meter Response` keeps its dice randomizer scoped to meter response sliders
- SceneKit review-app saved theme/settings payload includes speaker palette, geodesic palette, speaker type, speaker label font and font size, meter source, audio render type, Cube VU preset/settings, performance cadence values, and the full left-panel audio/camera/view-detail state
- SceneKit review-app saved theme/settings payload round-trips top-level `groundAppearance.showGridPlane`, `gridPlaneVisibilitySlider`, `gridPlaneSpacing`, and `gridPlaneRenderStyle`, while decoding older `leftPanel.viewDetail` grid fields and defaulting missing older JSON values to `false`, `70`, default spacing, and the fallback palette
- SceneKit review-app grid-plane geometry keeps the canonical `z = -1.2` offset, default `0.5` spacing, 10 x 10 bounds, deterministic default line count, alternate spacing line counts, and default opacity mapping
- SceneKit review-app camera projection maps canonical `+X = right` to screen right and `-X = left` to screen left for Plan, Elevation, and Isometric; horizontal drag control also uses the corrected left/right yaw sign
- SceneKit review-app `Saved Themes` storage generates unique two-word filenames, displays manual filename renames, round-trips selected fonts/font size, survives default-theme filename changes by `themeID`, and falls back safely for missing or invalid defaults
- SceneKit review-app `Sphere Geometry` and `Speaker Pattern` trays exist as future placeholders and expose only `Future work`
- SceneKit review-app hidden diagnostics expose raw RMS, raw peak, calibrated RMS, display scalar, and hot scalar values without mutating the raw meter source
- SceneKit review-app diagnostic log is capped and is not driven by meter-only frame ticks
- SceneKit review-app object/trail/glow/bounds trays are inactive while the review surface focuses on speakers

The production wrapper and review surface intentionally share a test target for now, but they import separate package targets. Production wrapper assertions should exercise `OrbitalViewSwiftUI`; review/demo assertions should exercise `OrbitalViewReview`.

## Orbisonic Design-Language Checks

Design-language guidance lives in:

```text
docs/orbisonic-design-language.md
```

Existing SwiftUI/review-surface tests cover current source-level design hooks such as Orbisonic design-language source labels, full-width Orbisonic theme buttons, palette source attribution, current palette inventory, Daft Punk Bow display name, and Tech Rainbow migration behavior.

Future UI changes should add static tests only when a design-language rule becomes a source-level constant or behavior. Manual visual review is required when visible UI behavior, layout, palette rendering, or review executable controls change. Docs-only design-language updates do not require manual visual review.

## Host Profile Checks

Host profile contracts live in:

```text
docs/integrations/wavefield-realtime-connection.md
docs/integrations/orbisonic-splat-host-profiles.md
docs/visual-telemetry-stress-gates.md
docs/realtime-family-compliance-audit.md
```

Docs-only host profile slices should run static reference checks for the relevant host names and boundaries. Source-level host adapter slices must add tests for source descriptor provenance, physical channel identity, object identity, neutral geometry preservation, and no direct dependency on downstream app targets unless the slice explicitly allows it.

Future wrapper tests should cover:

- gesture updates bind camera state without breaking center lock
- selection bindings round-trip from renderer picking to host UI
- toolbar toggles do not mutate audio, playback, routing, or metering state

## Compliance Closeout Checks

The realtime-family adoption closeout requires:

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`
- `git diff --check`
- OpenSpec CLI validation when `openspec` or `opsx` is installed
- static reference checks for final compliance terms when OpenSpec CLI validation is unavailable

The compliance audit is a documentation gate, not a new runtime test target. It should not claim callback p99/deadline coverage unless a host-owned integration test supplies that evidence.

## Visual Telemetry Stress Checks

The Slice 9 stress fixture lives in:

```text
Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift
Tests/OrbitalViewViewerTests/OrbitalViewViewerDemoContentTests.swift
```

Current stress tests cover:

- 30 physical speakers in channel order;
- 128 source objects with object IDs `1...128`;
- object trails capped at 16 points per object;
- local livestream generator provenance for speaker and object meter frames;
- `32-object-should-pass-stress` source metadata;
- 120 FPS incoming meter cadence versus 60 FPS active viewport cadence;
- diagnostics-open stress profile intent;
- dropped display frames represented by overload actions only, without fabricated input/audio failure fields.

Renderer retained-buffer tests and SwiftUI/review diagnostics tests remain the evidence for no static-geometry rebuilds, retained buffer stability, object-meter separation, and diagnostic log caps. The visual telemetry stress gate proves viewport no-backpressure behavior only; host callback p99/deadline tests belong in the owning host app.

## Native Viewer Tests

The native viewer is an executable review surface, with deterministic demo data kept in a support target so it can be tested without opening a window.

Current viewer tests cover:

- one cube speaker per physical speaker
- physical channel order `1...30`
- demo speaker meter coverage for every channel
- dynamic object frame and object meter ID agreement
- object trail caps
- Cube VU diagnostics and object trails enabled for visual review
- the display-only stress fixture preserves physical speaker identity, source object identity, capped trails, local generator provenance, and display-drop diagnostics

Launch the viewer for manual review with:

```text
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command
```

The viewer imports `OrbitalViewReview` for the SceneKit/local-audio review surface. Production host apps should import `OrbitalViewSwiftUI` instead.

## Mockup Checks

Disposable browser mockups should stay separate from production Swift code. For `mockups/orbital-view-viewport/`, verify:

- `index.html` and `notes.md` exist
- inline JavaScript parses with Node extraction
- Fey geodesic generator produces the expected 3V full-sphere counts: 92 nodes, 270 edges, and 3 length groups
- mockup text does not claim real audio, real meters, or production renderer behavior
- static browser review confirms the DomeLab-style left control panel headings, no Projection picker, always-axonometric projection, full-surface Color palettes, Purple/Prism defaults, remapped speaker size/fog sliders, Speaker numbers switch defaulted off, Hidden Lines switch defaulted off, consistent shell/speaker fog behavior, prism face clipping, PNG export, and inspector are usable

## Required Checks

Current package:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command
```

Current mockup:

```text
node -e 'const fs=require("fs"); const html=fs.readFileSync("mockups/orbital-view-viewport/index.html","utf8"); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]).join("\n"); new Function(scripts); console.log("inline JS parses");'
```

The plain Command Line Tools environment on this machine can build but cannot currently run XCTest:

```text
swift test -> XCTest not available
```

## Test Data Rules

- Use deterministic scene fixtures.
- Keep geometry fixtures small.
- Do not rely on live audio devices.
- Do not fake production meter sources in app UI tests.
- Do not store secrets.
