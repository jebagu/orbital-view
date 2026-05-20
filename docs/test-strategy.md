# Test Strategy

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
- meter visual settings validate display gain, style, color scheme, checker controls, and speaker z scale without touching audio behavior
- Daft Punk Bow color/theme contracts preserve display name, ramp stops, Codable round trips, and legacy `techRainbow` migration
- cube scalar center-bloom is the default music style and validates bloom, response, peak hold, release, hot fill, face pixels, diagnostics visibility, and legacy checker/ripple migration
- runtime meter sanitizing reports missing/extra/invalid/duplicate channels, replaces NaN/inf values, clamps finite values, and preserves strict constructor behavior
- visual presets round-trip through Codable, validate decoded data, and can reset to the default music preset
- Sonic Sphere speaker shapes validate cube edge and rectangular-prism z scale explicitly
- face-center VU bloom math uses each face's local center, not a shared object center
- source-object frame sets validate source-object ID identity, unit-sphere poses, active-object caps, and trail caps explicitly
- object meter frames preserve levels by source-object ID
- object visual settings default to conservative trails-off behavior and `-5...+5` bounds

## Unit Tests

Use for:

- vector and unit direction validation
- shell node/edge/face validation
- speaker ID/channel/shape validation
- meter frame identity
- meter visual settings validation plus style/color-scheme codability
- platform-neutral theme token and VU ramp codability
- cube scalar center-bloom default settings and legacy style migration
- meter input sanitizer diagnostics and safe value replacement/clamping
- visual preset Codable round trip, decode validation, and default reset
- Sonic Sphere cube/prism z-scale and face-center bloom distance validation
- object frame-set identity, duplicate object ID rejection, active-object caps, and trail-cap validation
- object meter identity by object ID
- object visual settings defaults and finite range validation
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
- map runtime Wavefield channel/rms/peak records into sanitized `SpeakerMeterFrame` plus diagnostics for missing, extra, invalid, duplicate, replaced, and clamped channels
- preserve missing meter channels as absent values
- derive clip from a configurable threshold
- verify the Wavefield Orbital View host model joins cached Fey speaker geometry and `PlayerSnapshot.meterSummary.multichannelLevels` by channel
- verify only explicit Mono Equal mode mirrors mono RMS/peak across modeled speaker channels
- verify the Orbisonic adapter skeleton maps exactly 30 physical output speaker records into `OrbitalViewSceneSpec`
- verify the Orbisonic adapter skeleton sanitizes normalized output-monitor VU records into `SpeakerMeterFrame`
- verify the Orbisonic color-scheme contract includes Daft Punk Bow and maps it to `OrbitalViewTheme.daftPunkBow`
- verify the standalone viewer support target builds deterministic 30-channel demo scene and meter data without importing UI or downstream host targets

## Renderer Tests

The accepted renderer backend is MetalKit / MTKView, with SwiftUI in a wrapper target.

Renderer harness details live in:

```text
docs/renderer-test-harness.md
docs/renderer-cache-plan.md
```

Current renderer seam tests cover:

- scene updates increment structural revision without touching meter revision
- meter updates increment meter revision without rebuilding scene state
- camera and selection updates emit events
- `OrbitalViewMetalRenderer` provides an `MTKViewDelegate` seam
- offscreen Metal smoke rendering produces a non-clear frame from a deterministic scene, or skips clearly when no Metal device exists
- meter-only and camera-only updates keep static speaker draw inputs stable
- settings-only updates keep static speaker geometry cache keys stable
- cube and rectangular-prism speaker shapes produce different static geometry cache keys
- speaker draw inputs expose instanced cube/prism mesh metadata, normal-out orientation, and RMS/peak/clip material payloads
- offscreen center-bloom pixel probes prove hot and clipped channels change color/intensity without changing geometry bounds
- Daft Punk Bow ramp uniform updates change offscreen color without changing static speaker geometry
- channel-to-instance mapping preserves scene speaker order and physical channel identity
- repeated meter/settings/camera-only renders reuse retained speaker buffers when capacity is sufficient
- speaker draw inputs preserve ID/channel order and stable dimensions
- 30 channel-keyed meter levels map to scene speakers by physical channel
- meter color-scheme/settings changes affect every speaker color without changing geometry
- meter visual gain/style updates affect color state without changing static geometry or raw meter revision
- speaker z-scale setting updates do not mutate scene speaker shapes or static draw inputs
- object frame, object meter, and object visual setting updates use separate renderer revisions
- object meter-only changes do not rebuild static speaker or static object geometry
- object disappearance removes object draw input and trail ownership
- trails and glow trails share capped object draw inputs
- repeated object rendering reuses retained Metal buffer capacity
- 30 speakers plus 128 active objects with capped trails stay inside the renderer input model

Future renderer drawing checks should cover:

- center-lock survives resize and camera preset changes
- live object smoothing behavior for replay interpolation, visual lookbehind, and damped chase
- selection emits speaker/channel identity without mutating playback
- renderer target compiles without adding audio, playback, routing, MIDI, OSC, or downstream app dependencies
- meter updates can be tested separately from structural scene updates
- targeted pixel probes catch blank frames without brittle full-frame snapshots

## SwiftUI Wrapper Tests

Current wrapper skeleton tests cover:

- `OrbitalView` initializes with camera and selection bindings
- identical configuration updates do not repeatedly increment structural renderer revision
- changed meter frames update meter revision without rebuilding scene state
- changed meter visual settings update only meter visual settings state
- object frame, object meter, and object visual settings snapshots forward to the renderer without reloading scene state
- the settings-bound initializer opts into the collapsed VU settings tray with color-scheme/settings controls, diagnostics input, and optional preset-store injection
- visual preset actions use the optional store and no-op safely when persistence is absent
- diagnostics summaries report missing, extra, invalid, duplicate, replaced, clamped, and timestamp-fallback input
- camera and selection configuration emits renderer events

Future wrapper tests should cover:

- gesture updates bind camera state without breaking center lock
- selection bindings round-trip from renderer picking to host UI
- toolbar toggles do not mutate audio, playback, routing, or metering state

## Standalone Viewer Tests

Current viewer tests cover:

- deterministic 30-channel viewer scene creation
- channel-keyed sample speaker meter coverage for every viewer speaker
- sample source-object frames and object meters sharing object IDs
- viewer object visual settings enabling trails/glow trails only inside the demo harness

## Mockup Checks

Disposable browser mockups should stay separate from production Swift code. For `mockups/orbital-view-viewport/`, verify:

- `index.html` and `notes.md` exist
- inline JavaScript parses with Node extraction
- Fey geodesic generator produces the expected 3V full-sphere counts: 92 nodes, 270 edges, and 3 length groups
- mockup text does not claim real audio, real meters, or production renderer behavior
- static browser review confirms the DomeLab-style left control panel headings, no Projection picker, always-axonometric projection, full-surface Color palettes, Purple/Prism defaults, remapped speaker size/fog sliders, Speaker numbers switch defaulted off, Hidden Lines switch defaulted off, consistent shell/speaker fog behavior, prism face clipping, PNG export, and inspector are usable
- object control groups appear below View Detail in the same left rail style: Object Geometry, Object Motion, Object Meter Skin, Trails, Glow Trails, and Bounds
- object controls expose default trails off, glow trails off, conservative max trail points, and fixed bounds value `5` for the `-5...+5` cube

For `mockups/sonicsphere-cube-vu-single-screen/`, verify:

- `index.html` and `notes.md` exist
- inline JavaScript parses with Node extraction
- body/page scrolling is disabled
- the fixed 1512 x 850 artboard scales to the live viewport
- the Music Meter panel is present above the cube grid and exposes a normal RMS/Peak/Bass, spectrum, and waveform view
- four cube VU variant canvases are present
- the Tune tab remains visible with audio source, Cube VU scalar, palette, and surface groups
- the Impulse tab exposes artificial Drop/Repeat controls
- the Advanced tab exposes custom palette JSON and implementation export controls without crowding the Tune tab
- the VU drive toggle enforces exclusive Music vs Impulse Test behavior
- the audio source group exposes tab capture, stop capture, local file input/playback, live RMS/Peak/Bass readouts, and idle/capturing/no-audio/permission-denied statuses
- browser-only Web Audio analysis uses captured tab audio or local file playback to drive both the normal meter and cube VU only in Music mode, with `vuScalar` equal to RMS percent, without altering Swift package audio, routing, or renderer contracts
- switching to Impulse Test stops music capture/playback, disables music controls, clears existing drops/energy, and enables impulse controls
- switching to Music disables impulse controls and clears existing impulse drops/energy
- browser measurement confirms the document fits within the viewport without scrollbars
- center-bloom performance guardrails remain present: cached cube geometry, cached palette/RGB conversion, 1024-point analyser FFT, <= 160 waveform points, 32 spectrum bars, and a 24 fps canvas redraw cap

## Required Checks

Current package:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Focused host adapter check:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbisonicOrbitalViewAdapterTests
```

Focused standalone viewer check:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewViewerTests
```

Current mockup:

```text
node -e 'const fs=require("fs"); for (const file of ["mockups/orbital-view-viewport/index.html", "mockups/sonicsphere-cube-vu-single-screen/index.html"]) { const html=fs.readFileSync(file,"utf8"); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]).join("\n"); new Function(scripts); } console.log("inline JS parses");'
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
