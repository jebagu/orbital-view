# Codex Work Package: Orbital View Graphics Diagnostics and 120 FPS / 30 FPS Performance Path

## Assignment

You are Codex working in the `OrbitalViewKit` repository. Improve graphics performance in bounded, testable slices so the visible review app and production renderer path can move from the current mostly `60 FPS` active-motion model toward:

```text
Active viewport / interaction target: 120 FPS
Displayed meter update target: 30 FPS
```

Do not start by guessing or micro-optimizing. Start by adding diagnostics, counters, and deterministic test harnesses that prove which work is happening at which cadence. Then make the cadence, material, scheduling, and retained-resource changes.

The intended result is not a new product or a different renderer architecture. It is the existing Orbital View Kit with better evidence, stronger test coverage, and a clear path to active 120 FPS interaction with 30 FPS visual meter updates.

## Current Architecture Summary

The package is a Swift package named `OrbitalViewKit`.

Important targets:

```text
OrbitalViewCore
  Pure value contracts, validation, coordinate system, scene, shell, speaker,
  meter, source, object, camera, performance, selection, and diagnostics types.

OrbitalViewWavefield
  Local Wavefield-style speaker-layout JSON and meter-frame adapters.

OrbitalViewSpatGRIS
  SpatGRIS XML import/export, source metadata, and OSC payload parsing.
  It must not own sockets in production.

OrbitalViewRender
  Production MetalKit / MTKView renderer seam with offscreen-tested Metal draw
  path, retained buffers, static/dynamic revision keys, speaker material
  updates, and object overlay draw path.

OrbitalViewSwiftUI
  Production SwiftUI wrapper and MTKView bridge for host apps.

OrbitalViewReview
  Review/demo-only SceneKit visual surface, local visual test audio, file
  dialogs, PNG export, app-bundle themes, bundled fonts, SpatGRIS layout stores,
  and review-only OSC listening.

OrbitalViewViewer
  Local native review executable that hosts OrbitalViewReview.

OrbitalViewViewerSupport
  Demo content and visual telemetry stress fixtures.
```

Keep this split intact:

```text
Visible review app today:
  OrbitalViewViewer -> OrbitalViewReview -> SceneKit OrbitalViewportMockup

Production host integration seam:
  Host app -> OrbitalViewSwiftUI -> OrbitalViewRender -> OrbitalViewCore
```

Do not confuse the SceneKit review app with the production renderer seam. The review app is the visual and tuning surface. Production host apps should import `OrbitalViewSwiftUI` and `OrbitalViewRender`, not `OrbitalViewReview`, unless a future task explicitly says otherwise.

## Required Reading Before Editing

Read these files first, in this order, and confirm current symbol names from source before editing:

```text
README.md
START_HERE.md
AGENTS.md
docs/status.md
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/renderer-test-harness.md
docs/visual-telemetry-stress-gates.md
docs/realtime-family-compliance-audit.md
docs/protected-paths.md
docs/decisions/0002-renderer-backend.md
Package.swift
Sources/OrbitalViewCore/OrbitalViewPerformanceSettings.swift
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewRender/OrbitalViewMetalRenderer.swift
Sources/OrbitalViewRender/OrbitalViewRenderState.swift
Sources/OrbitalViewSwiftUI/OrbitalViewMetalView.swift
Sources/OrbitalViewReview/OrbitalViewportMockup.swift
Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
Tests/OrbitalViewViewerTests/OrbitalViewViewerDemoContentTests.swift
```

Also review the visual references without porting browser runtime code:

```text
mockups/orbital-view-viewport/
docs/media/orbital-view-vu-1.0/
```

## Branch, Dirty State, And Baseline

Before editing:

```text
git status --short
git branch --show-current
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

If the worktree is dirty, inspect the diff and avoid overwriting unrelated user work. If baseline tests fail before your changes, record the exact failure in `docs/status.md` and only continue if the failure is clearly unrelated and the work package remains safe to execute.

## Hard Boundaries

Do not change these areas or behaviors:

```text
Audio behavior
Audio callbacks
Playback timing
Route repair
Device I/O
MIDI
OSC ownership
Output routing
Host realtime callbacks
Production meter source-of-truth
Physical speaker channel ordering
Downmixing, truncating, remapping, or faking speaker channels
Speaker geometry resizing as a VU animation technique
Canonical 3D coordinate system
Production MetalKit / MTKView renderer seam
```

Keep canonical 3D coordinates Z-up:

```text
x = right
y = front
z = up
```

Keep `OrbitalViewCore` free of SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, and downstream app targets.

Do not import WebView, browser runtime code, or DomeLab app code.

Keep review-only SceneKit, local audio, export, theme, font, file-dialog, SpatGRIS layout persistence, and review-only OSC behavior inside `OrbitalViewReview`.

Protected source paths require focused scope and tests:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewReview/
Tests/OrbitalViewSwiftUITests/
```

## Performance Problem To Solve

Current reality to verify from source:

```text
OrbitalViewPerformanceSettings.default:
  activeViewportFramesPerSecond = 60
  meterOnlyViewportFramesPerSecond = 10
  inspectorRefreshFramesPerSecond = 10
  drawsOnDemand = true

Current validation:
  activeViewportFramesPerSecond must be 30 or 60
  meterOnlyViewportFramesPerSecond must be 1...30
  inspectorRefreshFramesPerSecond must be 1...30
```

Visible review app reality to verify from source:

```text
Sources/OrbitalViewReview/OrbitalViewportMockup.swift

OrbitalViewportFrameRate has 30 and 60 only.
OrbitalViewport3DSceneView uses a Timer-based renderAnimationFrame loop.
OrbitalViewportSpeakerMaterialUpdateKey buckets meter material by activeViewportFramesPerSecond.
OrbitalViewportSourceUpdateKey mixes camera/visibility/source pose/material cadence into one key.
OrbitalViewportCubeVUSceneKitMaterial.update assigns generated NSImage textures and many SCNMaterial values.
The review FPS chip currently classifies against a 60 FPS target.
```

Visual telemetry stress fixture reality to verify from source:

```text
Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift

30 physical speakers in stable channel order 1...30
128 source objects
object trails capped at 16 points per object
activeMotionFramesPerSecond = 60
incomingMeterFramesPerSecond = 120
makePerformanceSettings() currently returns active=60, meterOnly=30, inspector=10
```

Production Metal reality to verify from source:

```text
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewRender/OrbitalViewMetalRenderer.swift
Sources/OrbitalViewRender/OrbitalViewRenderState.swift
Sources/OrbitalViewSwiftUI/OrbitalViewMetalView.swift

The renderer uses retained buffers and revision keys.
Speaker meter values affect display/material payloads only.
Static speaker identity and geometry are separated from meter material state.
Object overlays use separate retained buffers.
OrbitalViewMetalView.configure sets preferredFramesPerSecond, enableSetNeedsDisplay, and isPaused from performance settings.
```

## Main Hypothesis

At 20 FPS, the visible review app is probably main-thread or SceneKit material-bound, not speaker-count-bound.

The most likely expensive paths are:

```text
SceneKit material writes per speaker per frame
Cube VU face texture generation and texture assignment
Cube VU cache churn across high-dimensional material keys
Timer-driven frame scheduling
Meter work coupled to active camera motion
Source update keys mixing active pose/visibility with meter material updates
Ribbed sphere segment visibility/material updates during active motion
Outline node material writes across many child nodes
Texture-backed speaker label generation if it leaks into frame ticks
Diagnostics log writes if they leak into frame ticks
SwiftUI update propagation into SceneKit or Metal view updates
Metal buffer rewrites or allocations during camera-only / meter-only changes
```

Do not assume this is true. Prove it with diagnostics and tests first.

## Deliverable Shape

This work package should be implemented in staged slices. Each slice must compile and pass tests before continuing.

The required order is:

```text
Slice 1: Diagnostics and deterministic test harnesses
Slice 2: 120 FPS and 30 FPS cadence contracts
Slice 3: SceneKit cadence decoupling
Slice 4: Cube VU material and texture hot-path reduction
Slice 5: Active versus idle scheduling cleanup
Slice 6: Metal retained-resource verification and 120 FPS configuration support
Slice 7: Stress fixture and documentation update
```

If one slice exposes a bigger architectural issue, stop after documenting the evidence and leave the repository in a passing, useful state.

# Slice 1: Diagnostics And Deterministic Test Harnesses

## Goal

Create evidence before changing behavior. Add test-visible diagnostics that show which work happens on active frames, meter-only frames, camera-only frames, and static frames.

This slice must not change visible behavior except for optional diagnostics output that is disabled, test-only, or review-only.

## SceneKit Diagnostics To Add

In `Sources/OrbitalViewReview/OrbitalViewportMockup.swift`, add lightweight internal diagnostics around the review SceneKit path. Prefer small `internal` or package-visible structs that tests can inspect with `@testable import OrbitalViewReview`.

Recommended shape:

```swift
struct OrbitalViewportRenderInstrumentationSnapshot: Equatable {
    var renderAnimationFrameAttemptCount: Int
    var renderAnimationFrameDrawCount: Int
    var renderAnimationFrameSkippedForCadenceCount: Int
    var renderSceneCount: Int
    var cameraUpdateCount: Int
    var gridPlaneUpdateCount: Int
    var ribbedSphereTopologyBuildCount: Int
    var ribbedSphereMaterialUpdateCount: Int
    var speakerVisibilityUpdateCount: Int
    var speakerMaterialUpdateCount: Int
    var speakerMaterialSpeakerVisitCount: Int
    var speakerLabelMaterialUpdateCount: Int
    var sourcePoseOrVisibilityUpdateCount: Int
    var sourceMaterialUpdateCount: Int
    var fogUpdateCount: Int
    var cubeVUMaterialUpdateCount: Int
    var cubeVUFaceTextureCacheHitCount: Int
    var cubeVUFaceTextureCacheMissCount: Int
    var cubeVUFaceTextureGenerationCount: Int
    var cubeVUFaceTextureEvictionCount: Int
    var cubeVUUniformWriteCount: Int
    var cubeVUTextureAssignmentCount: Int
    var cubeOutlineMaterialUpdateCount: Int
    var needsDisplayCount: Int
    var frameRateSampleCount: Int
}
```

Do not expose this as public API unless unavoidable. This is implementation instrumentation, not a product contract.

Implementation guidance:

- Keep counters simple and deterministic.
- Do not add heavyweight logging inside the frame path.
- Do not allocate strings per frame.
- Do not write to the diagnostics log per frame.
- If adding `os_signpost`, keep it optional and do not make tests depend on it.
- Tests should assert counters, keys, and revisions, not wall-clock speed.
- Prefer injectable clock helpers for scheduler tests rather than `Date.timeIntervalSinceReferenceDate`.

Specific places to instrument:

```text
OrbitalViewport3DSceneView.Coordinator.renderAnimationFrame
OrbitalViewport3DSceneView.Coordinator.renderScene(configuration:)
updateCamera
updateGridPlane
buildRibbedSpeakerSphere
updateRibbedSpeakerSphere
updateSpeakers
updateSources or split source update functions added later
updateFog
updateCubeOutline
OrbitalViewportCubeVUSceneKitMaterial.update
OrbitalViewportCubeVUSceneKitMaterial.faceTexture
OrbitalViewportCubeVUSceneKitMaterial.makeFaceTextureImage
OrbitalViewportFrameRateMonitor.recordFrame
```

Add test helpers if useful:

```swift
extension OrbitalViewport3DSceneView.Coordinator {
    var instrumentationSnapshotForTests: OrbitalViewportRenderInstrumentationSnapshot { ... }
    func resetInstrumentationForTests() { ... }
}
```

Keep these helpers internal or test-only. Do not make them part of product documentation.

## Metal Diagnostics To Add Or Verify

The Metal path already exposes `debugBufferAllocationCount`. Add tests or targeted diagnostics to prove retained-resource behavior at the current abstraction level.

Do not expose unnecessary public state. Prefer internal helpers under `@testable` if needed.

Verify or add coverage for:

```text
camera-only updates do not allocate or rewrite static speaker geometry buffers
meter-only updates do not allocate or rewrite static speaker geometry buffers
meter visual settings changes only affect material/color payloads
object meter changes do not rebuild static object identity buffers
object pose changes reuse retained buffers when capacity is sufficient
selection changes do not rebuild static speaker geometry
```

Relevant files:

```text
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewRender/OrbitalViewMetalRenderer.swift
Sources/OrbitalViewRender/OrbitalViewRenderState.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

## Tests To Add In Slice 1

Add or update tests in `Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift` and `Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift`.

Required SceneKit tests:

```text
testSceneKitInstrumentationCountsRenderPhasesWithoutDiagnosticsLogSpam
  Build a Coordinator.
  Apply a deterministic configuration.
  Assert renderSceneCount increments.
  Assert camera/material/source/rib/fog counters change only when their keys change.
  Assert diagnostics log entry count does not change because of a render tick.

testSceneKitMeterOnlyTickDoesNotRebuildStaticGeometryWithInstrumentation
  Use an initial configuration and a later timeMS-only configuration.
  Assert speakerRebuildCount does not increase.
  Assert labelRebuildCount does not increase.
  Assert ribbedSphereBuildCount does not increase.
  Assert speaker material update counter can increment, but only at the intended meter cadence after Slice 3.

testCubeVUFaceTextureDiagnosticsReportCacheHitMissAndEviction
  Reset the Cube VU face texture cache.
  Request one texture twice.
  Assert first request is a miss/generation and second is a hit.
  Drive cache past the limit.
  Assert eviction counter increments and cache count stays within the limit.

testFrameRateMonitorCanReportTargetWithoutWritingEveryFrame
  Record frames deterministically.
  Assert samples are throttled according to fpsMeterLogSamplesPerSecond.
  Assert diagnostic message creation is transition/sample based, not every frame.
```

Required Metal tests:

```text
testMetalRetainsSpeakerBuffersAcrossCameraOnlyUpdates
  Load deterministic scene.
  Draw or prepare once.
  Change only camera.
  Draw or prepare again.
  Assert static speaker draw inputs are unchanged.
  Assert debugBufferAllocationCount does not grow unexpectedly after capacity is established.

testMetalRetainsSpeakerGeometryAcrossMeterOnlyUpdates
  Load deterministic scene.
  Update meter frame.
  Assert static speaker geometry inputs are unchanged.
  Assert colors/material inputs change.
  Assert channel identity remains stable.

testMetalRetainsObjectCapacityAcrossMeterOnlyUpdates
  Load deterministic object fixture.
  Update object meters only.
  Assert object identity and static object inputs remain stable.
  Assert dynamic material/color payloads can change without static rebuilds.
```

These tests are allowed to use current 60 FPS defaults. Slice 2 and Slice 3 will introduce 120 and 30 FPS cadence assertions.

## Slice 1 Acceptance Criteria

Slice 1 is complete when:

```text
Instrumentation exists and is test-visible but not public product API.
Tests prove which paths update on baseline configuration changes.
Cube VU texture cache hit/miss/generation/eviction can be measured.
Metal retained-resource behavior is covered by source-level tests.
No visible review behavior has changed except optional test/debug-only instrumentation.
No audio, routing, MIDI, OSC, playback, or host callback behavior changed.
swift build passes.
swift test passes.
git diff --check passes.
docs/status.md records the diagnostics slice and exact verification.
```

# Slice 2: 120 FPS And 30 FPS Cadence Contracts

## Goal

Make `120 FPS active viewport` and `30 FPS displayed meters` first-class contracts without yet assuming the runtime can hit 120 FPS.

## Contract Changes

In `Sources/OrbitalViewCore/OrbitalViewPerformanceSettings.swift`:

- Allow `activeViewportFramesPerSecond` values of `30`, `60`, and `120`.
- Keep `meterOnlyViewportFramesPerSecond` valid range as `1...30`.
- Keep `inspectorRefreshFramesPerSecond` valid range as `1...30`.
- Do not casually change `OrbitalViewPerformanceSettings.default` in the same step. Prefer keeping `.default` at `60/10/10/drawsOnDemand=true` for compatibility, and add an explicit high-refresh factory if useful.
- If you do change `.default`, update docs and tests intentionally and explain the compatibility reason in `docs/status.md`.

Recommended addition:

```swift
public static let highRefreshDisplayTarget = OrbitalViewPerformanceSettings(
    uncheckedActiveViewportFramesPerSecond: 120,
    meterOnlyViewportFramesPerSecond: 30,
    inspectorRefreshFramesPerSecond: 10,
    drawsOnDemand: true
)
```

Use the current private unchecked initializer pattern or a safe equivalent. Keep naming consistent with the repository style.

In `Sources/OrbitalViewReview/OrbitalViewportMockup.swift`:

- Add `.oneTwenty = 120` to `OrbitalViewportFrameRate`.
- Make `option(for:)` and `normalized(_:)` handle 120.
- Add 120 to review UI picker labels where active FPS is selected.
- Update review constants so the visible review app can opt into `120 FPS` active target and `30 FPS` meter display target.
- Make FPS diagnostics target configurable instead of hardcoded around 60.
- Keep under-target classification relative to target, not fixed at 30.

Recommended status logic:

```text
target: fps >= target * 0.90, or fps >= target if the existing stricter behavior is required by UI wording
belowTarget: fps >= target * 0.50 and below target threshold
underTarget: fps < target * 0.50
```

Pick one rule and test it. The key change is that a 120 FPS target should not classify 60 FPS as target.

In `Sources/OrbitalViewSwiftUI/OrbitalView.swift`:

- Add `120 FPS` to the `Active Motion FPS` picker.
- Keep meter-only and inspector controls in `1...30` unless docs say otherwise.

In `Sources/OrbitalViewSwiftUI/OrbitalViewMetalView.swift`:

- Verify `OrbitalViewMetalView.configure` accepts 120 via settings and sets `view.preferredFramesPerSecond = 120`.
- Do not change draw-on-demand semantics yet unless tests in Slice 6 require it.

In `Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift`:

- Change `activeMotionFramesPerSecond` from 60 to 120.
- Keep `incomingMeterFramesPerSecond` at 120 unless there is a better documented fixture reason to change it.
- Keep `makePerformanceSettings()` at `active=120`, `meterOnly=30`, `inspector=10`.
- Update `makeSourceDescriptor().detail` so it no longer says display=60fps.
- Update tests that currently assert incoming meters are active * 2. The new fixture should model 120 incoming meter cadence, 120 active viewport target, and 30 displayed meter target. Do not claim host callback compliance.

## Tests To Add Or Update In Slice 2

Core tests:

```text
testPerformanceSettingsAccepts120ActiveViewportAnd30MeterDisplay
  Assert active=120, meterOnly=30, inspector=10 is valid.

testPerformanceSettingsRejectsUnsupportedActiveFPS
  Assert 90 and 144 are rejected unless you intentionally choose a broader allowed set.
  If you choose a broader allowed set, document and test the reason.

testPerformanceSettingsDefaultCompatibilityIsIntentional
  Assert default remains 60/10/10 unless you intentionally change it.
```

Review tests:

```text
testReviewFrameRateOptionsInclude120
  Assert OrbitalViewportFrameRate.allCases contains 30, 60, 120.
  Assert title for 120 is "120 FPS".
  Assert normalized(120) == 120.

testReviewFPSDiagnosticsUseConfigurableTarget
  Assert 120 target classifies 120 as target.
  Assert 60 is below or under target according to the chosen threshold.
  Assert diagnostic messages include target=120 when target is 120.

testReviewActiveFPSPickerExposes120
  Assert the SwiftUI review or production settings picker exposes 120 if existing tests inspect UI labels.
```

SwiftUI / Metal tests:

```text
testMetalViewConfigures120FPSAndDrawOnDemand
  Create MTKView.
  Configure with active=120, drawsOnDemand=true.
  Assert preferredFramesPerSecond == 120.
  Assert enableSetNeedsDisplay == true.
  Assert isPaused == true.

  Configure with active=120, drawsOnDemand=false.
  Assert preferredFramesPerSecond == 120.
  Assert enableSetNeedsDisplay == false.
  Assert isPaused == false.
```

Stress fixture tests:

```text
testVisualTelemetryStressSceneUses120ActiveAnd30DisplayedMeters
  Assert scene still has 30 speakers in channel order 1...30.
  Assert virtualObjects count is still OrbitalViewObjectFrameSet.maxObjectCount.
  Assert activeMotionFramesPerSecond == 120.
  Assert incomingMeterFramesPerSecond == 120.
  Assert performance.activeViewportFramesPerSecond == 120.
  Assert performance.meterOnlyViewportFramesPerSecond == 30.
  Assert performance.inspectorRefreshFramesPerSecond == 10.
  Assert diagnostics still report display drops without audio failure.
```

## Slice 2 Acceptance Criteria

Slice 2 is complete when:

```text
120 is a valid active viewport FPS setting.
30 is the explicit displayed meter target in stress and high-refresh paths.
Review and SwiftUI controls expose 120 where active FPS is configurable.
FPS diagnostics are target-aware and tested for 120.
Stress fixture models 120 active, 120 incoming meters, 30 displayed meters.
No runtime optimization is required yet.
swift build passes.
swift test passes.
git diff --check passes.
docs/status.md records contract changes and exact verification.
```

# Slice 3: SceneKit Cadence Decoupling

## Goal

Separate active camera/source pose work from displayed meter/material work.

At 120 FPS active motion, a typical active frame should do:

```text
camera transform
source/object pose or visibility if needed
submit / request draw
```

It should not do these at 120 FPS:

```text
speaker meter material updates
Cube VU face texture generation
Cube VU texture assignment
label texture generation
diagnostics log writes
ribbed sphere topology rebuilds
grid rebuilds
inspector refresh work
```

## Add A Cadence Helper

Add a small pure helper in `OrbitalViewportMockup.swift` or a nearby review file:

```swift
struct OrbitalViewportFrameCadence: Equatable {
    let activeFramesPerSecond: Int
    let meterDisplayFramesPerSecond: Int
    let inspectorFramesPerSecond: Int

    func activeFrameIndex(timeMS: Double) -> Int
    func meterDisplayFrameIndex(timeMS: Double) -> Int
    func inspectorFrameIndex(timeMS: Double) -> Int
}
```

Rules:

```text
activeFramesPerSecond can be 30, 60, or 120.
meterDisplayFramesPerSecond is 1...30.
inspectorFramesPerSecond is 1...30.
Use Double math carefully. Avoid integer division mistakes.
Tests should cover exact boundary examples.
```

Add `meterOnlyViewportFramesPerSecond` and `inspectorRefreshFramesPerSecond` to `OrbitalViewportRenderConfiguration`, or add a nested cadence object, so update keys do not have to infer meter cadence from active FPS.

## Split Update Keys

Current keys mix too much cadence. Refactor carefully.

### Speaker material key

Current problematic behavior:

```text
OrbitalViewportSpeakerMaterialUpdateKey uses:
  meterFrame = Int(timeMS / (1000 / activeViewportFramesPerSecond))
  activeFramesPerSecond
```

Required behavior:

```text
Speaker material updates bucket by displayed meter cadence, not active cadence.
At active=120 and meterDisplay=30:
  timeMS 1000 and 1008 should be the same material frame bucket.
  timeMS 1000 and 1034 should be different material frame buckets.
```

Recommended key fields:

```swift
struct OrbitalViewportSpeakerMaterialUpdateKey: Equatable {
    let meterDisplayFrame: Int
    let meterDisplayFramesPerSecond: Int
    let renderStyle: OrbitalViewportRenderStyle
    let meterSourceMode: OrbitalViewportMeterSource.Mode
    let cubeVUSettings: OrbitalViewportCubeVUSettings
    let selectedChannel: Int?
}
```

Do not include active FPS unless it truly affects material. The current use does not.

### Source keys

Current `OrbitalViewportSourceUpdateKey` includes camera pose, hidden-lines, source palette, meter mode, meter frame, active FPS, and sources in one key. That forces material and pose work together.

Split it into at least two keys:

```swift
struct OrbitalViewportSourcePoseUpdateKey: Equatable {
    let yaw: Double
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let showHiddenLines: Bool
    let sources: [OrbitalViewportSourceMarker]
    let sceneCenter: OVVector3
    let sceneHalfExtent: Double
}

struct OrbitalViewportSourceMaterialUpdateKey: Equatable {
    let sourceSpeakerRenderStyle: OrbitalViewportRenderStyle
    let meterSourceMode: OrbitalViewportMeterSource.Mode
    let meterDisplayFrame: Int
    let meterDisplayFramesPerSecond: Int
    let sources: [OrbitalViewportSourceMarker]
}
```

Then split `updateSources` into pose/visibility and material portions if needed:

```text
ensure source nodes exist / remove stale nodes
update source position and visibility
update source material
```

If a source node is newly created, apply both pose and material once.

### Ribbed sphere key

`OrbitalViewportRibbedSpeakerSphereUpdateKey` currently includes yaw/pitch/camera, which can cause ribbed sphere material/visibility work at active cadence. This may be necessary if the ribbed sphere is visible and depth-hidden. But it should not rebuild topology at active cadence.

Required behavior:

```text
Topology only changes when speakers, ribs, rings, thickness, or fallback radius changes.
Material/visibility can update with camera if visible.
If hidden, active camera changes should not do per-segment material writes.
```

Add tests that assert hidden ribbed sphere camera motion does not loop over segment material updates.

### Speaker visibility key

Speaker visibility currently depends on yaw/pitch/camera and selected channel. It may update at active cadence during orbit because depth/visibility changes. That is acceptable.

Do not let visibility updates also force material updates. The call site currently computes:

```text
shouldUpdateSpeakerVisibility || shouldUpdateSpeakerMaterial -> updateSpeakers(...)
```

Inside `updateSpeakers`, make sure material work only runs when `updateMaterial == true`, and visibility work only runs when `updateVisibility == true`. Counters from Slice 1 should prove this.

## Scheduler Cadence

In `renderAnimationFrame`, keep active frame scheduling separate from meter material cadence.

Current behavior:

```text
if spin:
  framesPerSecond = activeFramesPerSecond
else:
  framesPerSecond = OrbitalViewportMockup.meterOnlyViewportFramesPerSecond
```

Required behavior:

```text
Active motion draw attempts target activeFramesPerSecond.
Idle meter-only draw attempts target meterOnlyViewportFramesPerSecond.
Material keys use meterOnlyViewportFramesPerSecond regardless of active draw attempts.
Inspector/diagnostics updates remain capped separately.
```

If adding `OrbitalViewportFrameCadence`, use it for both scheduling and update-key tests.

## Tests To Add Or Update In Slice 3

Required tests:

```text
testFrameCadenceBuckets120ActiveAnd30MeterDisplay
  active=120, meter=30, inspector=10.
  Assert active frames advance around 8.33ms.
  Assert meter display frames advance around 33.33ms.
  Assert inspector frames advance around 100ms.

testSpeakerMaterialKeyUsesMeterDisplayCadenceNotActiveCadence
  Base config active=120, meter=30, timeMS=1000.
  Compare to timeMS=1008.
  Assert material key is equal.
  Compare to timeMS=1034.
  Assert material key is not equal.

testCameraOnlyActiveFrameDoesNotUpdateSpeakerMaterialAt120
  Use Coordinator instrumentation.
  Render base config.
  Render camera-only config within same 30 FPS meter bucket.
  Assert cameraUpdateCount increments.
  Assert speakerVisibilityUpdateCount may increment.
  Assert speakerMaterialUpdateCount does not increment.
  Assert Cube VU texture generation count does not increment.

testMeterDisplayBucketUpdatesSpeakerMaterialWithoutStaticRebuild
  Use active=120, meter=30.
  Render base config.
  Render same camera config in next meter display bucket.
  Assert speakerMaterialUpdateCount increments.
  Assert speakerRebuildCount, labelRebuildCount, ribbedSphereBuildCount do not increment.

testSourcePoseAndSourceMaterialCadenceAreSeparated
  Camera-only change inside same meter bucket updates source pose/visibility but not source material.
  Meter-bucket change with same camera updates source material but not source pose.

testHiddenRibbedSphereDoesNotDoSegmentMaterialLoopDuringCameraOnlyMotion
  Base config with showRibbedSpeakerSphere=false.
  Camera-only change.
  Assert ribbed sphere topology build and material update counters do not increment.
```

Update existing tests that currently assert meter-only ticks update material cadence under the 60 FPS active model. They should now assert material cadence under explicit meter display FPS.

## Slice 3 Acceptance Criteria

Slice 3 is complete when:

```text
Update keys distinguish active frame cadence from displayed meter cadence.
Speaker materials update at 30 FPS in high-refresh active mode.
Camera-only active frames no longer generate Cube VU textures or speaker material writes inside the same meter display bucket.
Source pose/visibility and source material updates are separated.
Hidden ribbed sphere does not loop over segment materials during active camera-only motion.
Existing rebuild-isolation tests still pass.
swift build passes.
swift test passes.
git diff --check passes.
docs/status.md records cadence decoupling and exact verification.
```

# Slice 4: Cube VU Material And Texture Hot-Path Reduction

## Goal

Reduce the largest likely SceneKit hot path: Cube VU texture generation, texture assignment, and repeated `SCNMaterial` property writes.

The target behavior is:

```text
No dynamic NSImage generation on 120 FPS active camera-only frames.
No speaker Cube VU texture assignment unless the relevant static visual texture key changes.
Meter-driven Cube VU material updates capped to displayed meter cadence, normally 30 FPS.
Visual direction preserved: Cube VU, Hot Core Bloom, Purple family styling, readable pixel surface, bloom, clip behavior, and outline styling.
```

## Current Behavior To Verify

`OrbitalViewportCubeVUSceneKitMaterial.update` currently:

```text
resolves vuColor and hotColor
requests faceTexture(settings:scalars:clip:vuColor:hotColor)
assigns material.diffuse.contents = texture
assigns material.emission.contents = texture
sets emission intensity
sets transparency
sets many KVC uniforms via material.setValue(NSNumber(...), forKey: ...)
```

`faceTexture` currently keys by many scalar/settings/color fields, including display/hot/clip and colors, and creates `NSImage` on a cache miss.

This can be correct visually but expensive if called often.

## Implementation Options

Prefer the lowest-risk option that tests can prove.

### Option A: Skip redundant material writes with per-channel material state

Add a per-channel retained material state in `Coordinator`:

```swift
struct OrbitalViewportCubeVUMaterialAppliedState: Equatable {
    let quantizedDisplay: Int
    let quantizedHot: Int
    let clip: Bool
    let alpha: Int
    let settingsKey: ...
    let vuColorKey: Int
    let hotColorKey: Int
    let selected: Bool
}
```

Then skip `OrbitalViewportCubeVUSceneKitMaterial.update` when the state is unchanged.

This is a safe interim improvement, but it does not remove dynamic texture generation at 30 FPS.

### Option B: Static texture plus shader uniforms

The file already contains `surfaceShader` with uniforms like `displayVuScalar`, `hotScalar`, `clipState`, `bloomMin`, `bloomMax`, `facePixels`, and `alphaValue`. If SceneKit shader modifiers are stable enough in this app, prefer moving the scalar animation into the shader.

Target behavior:

```text
Static texture key excludes display/hot/clip meter scalars.
Texture changes only when static visual settings or palette texture basis changes.
displayVuScalar/hotScalar/clipState/alpha are uniforms.
Material update writes uniforms at meter display cadence only.
Camera-only active frames do not touch Cube VU material.
```

Implementation details:

- Attach the shader modifier intentionally if using it.
- Update `usesSceneKitShaderModifier` test constant from `false` to `true` only if the modifier is actually used.
- Keep a fallback path if shader modifiers prove unreliable.
- Preserve existing face texture tests by reclassifying them as legacy/fallback/static texture tests as appropriate.
- Do not remove visual tests for tile gaps, checker surface, separated pixels, idle texture readability, and cache limits unless replaced by equivalent tests.

### Option C: Metal-first visual migration

If SceneKit shader modifiers are too risky, leave SceneKit with a reduced write path and focus production work in `OrbitalViewRender`, where Cube VU-style material behavior can become shader math over retained buffers.

This option is acceptable only if SceneKit tests still prove no Cube VU work on camera-only active frames and production Metal tests prove retained-resource behavior.

## Required Changes Regardless Of Option

- Add material-state deduplication so unchanged material values do not cause repeated SceneKit writes.
- Use Slice 3 cadence so Cube VU material updates cannot run at 120 FPS merely because the camera is active.
- Keep cache hit/miss/generation counters.
- Keep cache count bounded.
- Do not allocate `NSImage` on active camera-only frames.
- Avoid `NSNumber` churn for uniforms if a value has not changed since the last applied state.

## Tests To Add Or Update In Slice 4

Required tests:

```text
testCubeVUMaterialUpdateSkipsUnchangedState
  Create material.
  Apply same settings/scalars/clip/alpha/colors twice.
  Assert second apply does not increment texture assignment or uniform write counters.

testCubeVUCameraOnlyActiveFrameDoesNotRequestFaceTexture
  Use Coordinator with cubeVU speaker shape, active=120, meter=30.
  Render base config.
  Reset instrumentation.
  Render camera-only config inside same meter bucket.
  Assert cubeVUFaceTextureCacheHitCount == 0.
  Assert cubeVUFaceTextureCacheMissCount == 0.
  Assert cubeVUFaceTextureGenerationCount == 0.
  Assert cubeVUTextureAssignmentCount == 0.

testCubeVUMeterBucketCanUpdateMaterialWithoutGeometryRebuild
  Use active=120, meter=30.
  Render base config.
  Reset instrumentation.
  Render next meter display bucket.
  Assert material updates happen as expected.
  Assert speaker geometry, labels, grid, and ribbed sphere topology do not rebuild.

testCubeVUTextureCacheStillBoundedAndReusable
  Existing cache limit test must still pass.
  If texture key changes to static-only, update the test to exercise static settings variation instead of meter scalar variation.

testCubeVUVisualConstantsReflectImplementationTruth
  If shader modifiers are now used, assert usesSceneKitShaderModifier == true.
  If retained static texture is used, assert the static texture cache behavior accurately.
```

## Slice 4 Acceptance Criteria

Slice 4 is complete when:

```text
Camera-only active frames do not request, generate, or assign Cube VU face textures.
Repeated identical Cube VU material state does not rewrite all material properties.
Meter-driven Cube VU updates are capped to displayed meter cadence.
Visual tests for Cube VU readability and checker/pixel behavior still pass or are replaced with equivalent tests.
No speaker geometry is resized for VU behavior.
swift build passes.
swift test passes.
git diff --check passes.
docs/status.md records Cube VU hot-path changes and exact verification.
```

# Slice 5: Active Versus Idle Scheduling Cleanup

## Goal

Make the review SceneKit loop intentional about active 120 FPS motion, idle draw-on-demand behavior, and 30 FPS displayed meter updates.

Do not make scheduling changes until Slices 1 through 4 provide counters and tests. The scheduler should use the new cadence helpers and prove behavior without relying on wall-clock speed tests.

## Current Scheduling To Verify

In `OrbitalViewport3DSceneView.Coordinator`:

```text
startAnimationTimerIfNeeded creates Timer(timeInterval: 1 / activeFramesPerSecond)
renderAnimationFrame chooses activeFramesPerSecond when spin=true
renderAnimationFrame chooses OrbitalViewportMockup.meterOnlyViewportFramesPerSecond when spin=false
renderScene calls view?.needsDisplay = true
FPS monitor records from renderScene timing, not necessarily actual SceneKit rendered frames
```

In `OrbitalViewport3DSceneView.makeNSView`:

```text
view.rendersContinuously = false
view.isPlaying = false
view.preferredFramesPerSecond = activeFramesPerSecond
view.antialiasingMode = .multisampling4X
```

## Required Scheduler Behavior

Implement this behavior:

```text
Active interaction or spin:
  target activeFramesPerSecond, including 120.
  camera/source pose can update at active cadence.
  meter material updates still use meter display cadence.

Idle with meter changes:
  target meterOnlyViewportFramesPerSecond, normally 30.
  no active camera work unless camera changed.

Inspector/diagnostics:
  cap to inspectorRefreshFramesPerSecond.
  do not log every render frame.

Static idle with no changes:
  draw on demand only.
```

## Actual Render FPS Measurement

The current FPS chip may measure update-loop cadence rather than actual rendered frames. Improve this if feasible without invasive changes.

Preferred approach:

- Use `SCNSceneRendererDelegate` callbacks on the `SCNView` to record actual render completions.
- Keep the existing frame-rate monitor if useful, but label or separate update-loop samples versus actual render samples.
- Do not make tests depend on real display refresh. Tests can assert that callbacks feed the monitor and that diagnostic messages include the configured target.

If actual render callback integration is too risky, at minimum rename or document the current metric as update-loop FPS and leave a TODO in `docs/status.md`. Do not pretend it proves actual 120 Hz presentation.

## Timer Versus Continuous Rendering

Evaluate these approaches after instrumentation:

### Approach A: Improved Timer / scheduler helper

Keep `Timer`, but use the cadence helper and counter tests. This is lower risk but may not hit 120 consistently.

### Approach B: Active continuous SceneKit rendering

During active interaction or spin:

```text
view.rendersContinuously = true
view.isPlaying = true or equivalent if needed
view.preferredFramesPerSecond = activeFramesPerSecond
```

At idle:

```text
view.rendersContinuously = false
view.isPlaying = false
view.needsDisplay = true only when content changes
```

Only choose this if tests prove state transitions and the review app remains visually correct.

### Approach C: Display-link style scheduling

Use a macOS display-link approach only if necessary and bounded. Avoid adding major dependencies. Keep behavior review-only and testable with injectable timing logic.

## Antialiasing Quality Gate

Do not permanently reduce antialiasing as the main solution unless the result is explicitly documented and manually verified.

Allowed diagnostic experiment:

```text
Compare multisampling4X, 2X, and none manually.
Record the result in docs/status.md.
```

Do not silently degrade visual quality.

## Tests To Add Or Update In Slice 5

Required tests:

```text
testSchedulerTargetsActiveFPSOnlyDuringActiveMotion
  Use pure scheduler helper with active=120, meter=30.
  Assert active frames draw at active cadence when spin/interaction is active.
  Assert idle frames draw at meter cadence.

testSchedulerDoesNotAdvanceMeterMaterialAtActiveCadence
  Use Coordinator instrumentation or cadence helper.
  Simulate active frame times inside one meter bucket.
  Assert material frame index does not advance.

testFrameRateSamplesIncludeConfiguredTarget
  Use target=120.
  Assert emitted sample diagnostic message includes target=120.

testSceneKitViewCanTransitionActiveAndIdleDrawModes
  If implementing dynamic rendersContinuously/isPlaying behavior, assert:
    active mode sets the expected view flags.
    idle mode restores draw-on-demand flags.
    preferredFramesPerSecond remains configured.
```

## Slice 5 Acceptance Criteria

Slice 5 is complete when:

```text
Scheduler explicitly distinguishes active, meter-only, inspector, and static idle behavior.
Active target can be 120 without forcing 120 FPS material updates.
FPS diagnostics are honest about target and measurement source.
Review app remains visually consistent.
If visible review behavior changes, launch the native review app through the parent launcher.
swift build passes.
swift test passes.
git diff --check passes.
docs/status.md records scheduler changes, manual review result if applicable, and exact verification.
```

# Slice 6: Metal Retained-Resource Verification And 120 FPS Configuration Support

## Goal

Keep the production Metal path ready for 120 FPS without overfitting to the SceneKit review app.

Do not replace the accepted production renderer seam:

```text
OrbitalViewSwiftUI -> OrbitalViewRender -> OrbitalViewCore
```

## Required Work

In `OrbitalViewMetalView.configure`:

- Ensure active=120 settings configure `preferredFramesPerSecond` correctly.
- Preserve draw-on-demand behavior for idle/static production viewports unless tests and docs support a change.
- Do not make production viewports render continuously by default just because the review app is active.

In `OrbitalViewMetalDrawPipeline`:

- Verify static speaker geometry buffers are keyed by structural revision only.
- Verify speaker material/color buffers are keyed by meter revision and visual settings revision.
- Verify camera changes do not rebuild static speaker buffers.
- Verify object meters do not rebuild static object identity buffers.
- Verify object frame updates reuse retained capacity when object count stays under existing capacity.
- If instrumentation shows unnecessary rewrites, separate revision keys further.

## Tests To Add Or Update In Slice 6

Required tests:

```text
testMetalViewConfiguresHighRefreshWithoutForcingContinuousDraw
  active=120, drawsOnDemand=true.
  Assert preferredFramesPerSecond == 120.
  Assert enableSetNeedsDisplay == true.
  Assert isPaused == true.

testMetalViewCanOptIntoContinuousHighRefresh
  active=120, drawsOnDemand=false.
  Assert preferredFramesPerSecond == 120.
  Assert enableSetNeedsDisplay == false.
  Assert isPaused == false.

testMetalSpeakerStaticInputsStableAcross120FPSCameraSequence
  Load three-speaker or thirty-speaker deterministic scene.
  Generate a sequence of camera states that would represent 120 FPS motion.
  Assert static speaker draw inputs stay equal across camera sequence.

testMetalSpeakerMaterialInputsAdvanceAtMeterCadence
  If Metal gains explicit meter display cadence, assert meter material payloads advance at 30 FPS display cadence, not 120 FPS active cadence.
  If this remains host-driven by updateMeters calls, document that host/wrapper cadence must supply decimated display meter frames.

testMetalStressFixtureRetainsBuffersFor128Objects
  Use the visual telemetry stress fixture or a deterministic equivalent.
  Render or prepare object overlays with 128 objects and capped trails.
  Update object meters only.
  Assert retained buffer allocation count does not grow after capacity is established.
```

Do not rely on brittle full-frame snapshots. Use internal draw inputs, retained buffer allocation counts, and existing offscreen smoke tests.

## Slice 6 Acceptance Criteria

Slice 6 is complete when:

```text
Production Metal wrapper accepts and configures 120 FPS.
Draw-on-demand remains the production idle default unless intentionally changed.
Retained-resource tests cover camera-only, meter-only, and object-meter-only paths.
Offscreen smoke tests still pass.
No production audio or host integration behavior changed.
swift build passes.
swift test passes.
git diff --check passes.
docs/status.md records Metal verification and exact checks.
```

# Slice 7: Stress Fixture, Manual Verification, And Documentation

## Goal

Make the stress fixture and docs reflect the new target clearly without claiming more than tests prove.

## Stress Fixture Requirements

In `Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift`:

```text
speakerCount remains 30
objectCount remains OrbitalViewObjectFrameSet.maxObjectCount
maxTrailPointsPerObject remains 16
activeMotionFramesPerSecond becomes 120
incomingMeterFramesPerSecond remains 120 unless intentionally changed
makePerformanceSettings() returns active=120, meterOnly=30, inspector=10
source descriptor detail names incoming=120fps and display/meter=30fps if it mentions display cadence
```

In `Tests/OrbitalViewViewerTests/OrbitalViewViewerDemoContentTests.swift`:

- Preserve channel order assertions.
- Preserve 128 object assertions.
- Preserve capped trails assertions.
- Replace obsolete `incoming == active * 2` assertion with explicit target assertions.
- Preserve diagnostics assertions that display drops are not audio failures.

## Manual Verification

If visible review behavior changed, launch the review app:

```text
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command
```

Manual checks:

```text
Review app opens and shows native SceneKit viewport.
Left rail and right inspector still match existing visual direction.
Cube VU speaker type still renders with Hot Core Bloom / Purple family styling.
Speaker count remains 30 and labels/channels are stable.
Orbit/drag/zoom remain responsive.
FPS chip target text/status reflects 120 target when high-refresh is active.
Meter visual updates remain smooth but visibly decimated to 30 FPS.
No visible geometry resizing is used for VU.
Ribbed sphere hidden default remains hidden unless user enables it.
Diagnostics log remains capped and does not spam during meter-only ticks.
```

If the machine or display cannot actually present 120 Hz, document that in `docs/status.md` and still prove source-level cadence behavior with tests.

## Documentation Updates

Update `docs/status.md` after each slice.

Update other docs only if their content becomes stale:

```text
docs/contracts.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
docs/renderer-test-harness.md
docs/visual-telemetry-stress-gates.md
docs/protected-paths.md
```

Do not rewrite broad docs unnecessarily.

## Final Verification Commands

Run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```

If visible review behavior changed, also run:

```text
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command
```

Record all commands and results in `docs/status.md`.

# Acceptance Criteria For The Whole Work Package

The work package is complete when all of this is true:

```text
Diagnostics and tests exist before behavior changes.
120 FPS is a valid active viewport setting.
30 FPS is the explicit displayed meter target in high-refresh paths.
Review and SwiftUI controls expose 120 where active FPS is configurable.
FPS diagnostics are target-aware and tested for 120.
Visual telemetry stress fixture models 120 active, 120 incoming meters, and 30 displayed meters.
SceneKit update keys separate active camera/source pose from meter material cadence.
At active=120 and meter=30, camera-only active frames do not update speaker materials inside the same meter bucket.
At active=120 and meter=30, camera-only active frames do not generate or assign Cube VU face textures.
Meter-bucket changes update Cube VU material without rebuilding speaker geometry, labels, grid, or ribbed sphere topology.
Source pose/visibility updates are separated from source material updates.
Hidden ribbed sphere does not do per-segment material work during camera-only active motion.
Metal wrapper accepts 120 and retained-resource tests pass.
Offscreen Metal smoke tests still pass or skip cleanly without Metal device.
30 physical speakers preserve channel order 1...30.
128 object stress fixture remains intact with capped trails.
Diagnostics log remains capped and is not driven by render-frame spam.
No audio, routing, playback, MIDI, OSC, host realtime callback, or production meter source-of-truth behavior changed.
No WebView/browser/DomeLab runtime path was imported.
Docs/status.md records exact verification.
swift build passes.
swift test passes.
git diff --check passes.
```

# Risks And Rollback Guidance

## Risk: 120 FPS support changes public defaults unexpectedly

Preferred rollback:

```text
Keep active=120 as an accepted/explicit high-refresh setting.
Restore OrbitalViewPerformanceSettings.default to previous 60/10/10 behavior.
Keep tests proving explicit 120 works.
Document compatibility choice in docs/status.md.
```

## Risk: SceneKit shader modifiers break Cube VU visuals

Preferred rollback:

```text
Disable shader modifier path.
Keep material-state deduplication and 30 FPS material cadence.
Keep face texture cache bounded.
Keep tests proving no texture requests on camera-only active frames.
Document shader modifier attempt and reason for rollback.
```

## Risk: Dynamic scheduling with rendersContinuously causes idle battery drain or UI side effects

Preferred rollback:

```text
Return idle to draw-on-demand.
Keep active-only scheduling changes behind a clear active interaction flag.
Keep cadence and material decoupling.
Document actual render FPS limitation if Timer remains the only safe scheduler.
```

## Risk: Actual 120 FPS cannot be manually confirmed on available hardware

Preferred rollback:

```text
Do not fake confirmation.
Keep source-level cadence tests and instrumentation.
Document hardware/display limitation in docs/status.md.
Leave a manual verification note that 120 Hz display confirmation is still needed.
```

## Risk: Retained-resource tests require too much internal exposure

Preferred rollback:

```text
Use existing draw-input comparison helpers and debugBufferAllocationCount.
Avoid public API expansion.
Keep any new diagnostics internal/test-visible only.
```

## Risk: Tests become brittle because they depend on wall clock or display refresh

Preferred rollback:

```text
Move timing logic into pure helpers with injected timeMS.
Assert frame bucket indices, counters, and update keys.
Do not assert real elapsed time in unit tests.
```

# Final Response Format For Codex

When finished, respond using this structure:

```text
Summary:
Files changed:
Tests added or updated:
Commands run:
Results:
Documentation updated:
Bugs found or fixed:
Protected paths touched:
Assumptions:
Risks or blockers:
Recommended next task:
```

Be explicit if 120 FPS was source-level enabled but not manually confirmed on a 120 Hz display. Do not claim actual 120 Hz presentation unless the review app was launched on suitable hardware and the measured actual-render FPS supports it.
