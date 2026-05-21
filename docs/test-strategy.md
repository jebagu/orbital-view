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
- local Wavefield JSON adapter rejects invalid layout shape explicitly
- local Wavefield meter adapter rejects duplicate channels and invalid levels explicitly

## Unit Tests

Use for:

- vector and unit direction validation
- shell node/edge/face validation
- speaker ID/channel/shape validation
- meter frame identity
- camera preset state
- scene builder behavior

## Integration Tests

Use when a downstream adapter is added:

- load or construct the Fey 30 layout
- adapt it to `OrbitalViewSceneSpec`
- assert 30 physical speaker records
- assert channels remain `1...30`
- assert labels remain stable
- assert directions match the source layout
- reject unsupported axes and invalid speaker counts
- map channel/rms/peak records into `SpeakerMeterFrame`
- preserve missing meter channels as absent values
- derive clip from a configurable threshold

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
- speaker draw inputs preserve ID/channel order and stable cube/prism dimensions
- cube VU defaults, scalar math, range validation, material payloads, hot-fill independence, and palette-drive behavior stay separate from raw RMS
- dynamic object frame/meter/settings updates render through a separate object path and do not rebuild speaker static geometry
- retained speaker/object buffers do not reallocate on meter/settings/camera-only renders

Future renderer drawing checks should cover:

- center-lock survives resize and camera preset changes
- selection emits speaker/channel identity without mutating playback
- renderer target compiles without adding audio, playback, routing, MIDI, OSC, or downstream app dependencies
- meter updates can be tested separately from structural scene updates
- targeted pixel probes catch blank frames without brittle full-frame snapshots

## SwiftUI Wrapper Tests

Current wrapper skeleton tests cover:

- `OrbitalView` initializes with camera and selection bindings
- identical configuration updates do not repeatedly increment structural renderer revision
- changed meter frames update meter revision without rebuilding scene state
- cube VU settings and object frames/meters forward through the coordinator without reloading scene state
- host-bound object visual settings and performance settings initialize through the tuning-surface initializer
- MTKView applies active 30/60 FPS and draw-on-demand performance settings
- camera and selection configuration emits renderer events
- the confirmed SceneKit `OrbitalViewportMockup` viewer identity, left rail options, right tuning panel inventory, geodesic shell counts, and adaptive FPS constants remain intact
- SceneKit review-app audio source uses native transport icon buttons for Play and Pause
- SceneKit review-app right panel includes the Orbisonic Theme tray and keeps theme controls out of the left rail tuning stack
- SceneKit review-app Orbisonic Theme tray uses full-width custom theme buttons, includes the Orbisonic family palette list from `orbisonic-palette-brief`, and does not use a native segmented picker
- SceneKit review-app startup defaults are pinned to the exported settings JSON values without mutating the Core cube settings default contract
- SceneKit review-app meter-only ticks update material cadence without rebuilding shell or speaker geometry
- SceneKit review-app Cube VU controls preserve Core scalar defaults, default to 9x9 face pixels, default Cube Outline to invisible, keep outline constants delicate, and separate material-only theme/outline tuning from speaker-height geometry tuning
- SceneKit review-app Cube VU retained face-texture support exposes the face-pixel quantization and center-fill contract on the actual cube faces without replacing the approved SceneKit surface
- SceneKit review-app Cube VU idle face textures have edge-to-edge pixels with no generated tile gaps and preserve an unlit checkerboard surface
- SceneKit review-app Cube VU Surface + Bloom controls expose Pixel Fill and Surface Checker Opacity, can recover the older separated-pixel face mode, and can mute the forced idle checkerboard without changing geometry
- SceneKit review-app speaker type options include `Prism`, `Sphere`, and `Cube VU`, with full-width tray header hit targets for collapsible tuning sections
- SceneKit review-app Orbisonic Theme controls expose Geodesic Saturation, update only the shell/geodesic material key, and leave speaker/Cube VU material keys unchanged
- SceneKit review-app local audio file metering reduces channel powers to equal mono speaker RMS/peak samples without requiring per-frame SwiftUI state
- SceneKit review-app VU Drive exposes Music and Impulse Test, with Impulse Test producing a deterministic spatial sphere-ripple meter pattern instead of random or uniform channel values
- SceneKit review-app Cube VU presets expose Soft Center Bloom, Hot Core Bloom, Halo Edge Bloom, and Block Center Bloom without adding a four-up preview
- SceneKit review-app settings JSON export includes theme, speaker type, VU drive, Cube VU preset/settings, performance cadence values, and the full left-panel audio/camera/view-detail state
- SceneKit review-app hidden diagnostics expose raw RMS, raw peak, calibrated RMS, display scalar, and hot scalar values without mutating the raw meter source
- SceneKit review-app diagnostic log is capped and is not driven by meter-only frame ticks
- SceneKit review-app object/trail/glow/bounds trays are inactive while the review surface focuses on speakers

Future wrapper tests should cover:

- gesture updates bind camera state without breaking center lock
- selection bindings round-trip from renderer picking to host UI
- toolbar toggles do not mutate audio, playback, routing, or metering state

## Native Viewer Tests

The native viewer is an executable review surface, with deterministic demo data kept in a support target so it can be tested without opening a window.

Current viewer tests cover:

- one cube speaker per physical speaker
- physical channel order `1...30`
- demo speaker meter coverage for every channel
- dynamic object frame and object meter ID agreement
- object trail caps
- Cube VU diagnostics and object trails enabled for visual review

Launch the viewer for manual review with:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run OrbitalViewViewer
```

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
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run OrbitalViewViewer
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
