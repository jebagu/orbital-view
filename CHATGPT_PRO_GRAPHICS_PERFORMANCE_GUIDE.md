# ChatGPT Pro Graphics Performance Guide: Orbital View Kit

## Purpose

This guide is for a ChatGPT Pro session that needs to understand Orbital View Kit well enough to write a strong implementation prompt for improving graphical performance.

The requested output from ChatGPT Pro is not code. The requested output is an implementation-ready prompt for a coding agent to improve Orbital View graphics performance while preserving the existing architecture and visual direction.

## First Answer To Produce

After reading this bundle, write a prompt for a coding agent that can improve graphical performance in Orbital View Kit. The prompt should include:

- current architecture summary;
- performance goals and current implementation reality;
- likely hot paths to inspect first;
- staged implementation slices;
- protected boundaries and non-goals;
- test and verification commands;
- acceptance criteria;
- risks and rollback guidance.

The prompt should be direct enough that a coding agent can execute it in this repository without needing to rediscover the project from scratch.

## Product Goal

Orbital View Kit is a reusable Apple-native 3D spherical speaker viewport for Wavefield, Orbisonic, and Splat.

The viewport should show:

- a physical Sonic Sphere-style speaker array;
- 30 physical speakers now;
- a likely 52-speaker physical configuration later;
- stable physical channel identity and channel order;
- live per-speaker RMS, peak, clip, and VU material behavior;
- source markers and future moving objects;
- up to 128 source objects for stress and future authoring/diagnostic views;
- a beautiful, high-depth visual surface with fog, glow, palette control, and responsive orbit/zoom interaction.

The performance goal for future graphics work is:

```text
Active viewport / interaction target: 120 FPS
Meter display target: 30 FPS
```

Important current reality:

- The current review app and production settings mostly center around `60 FPS` active motion.
- `OrbitalViewPerformanceSettings` currently validates active viewport FPS as `30` or `60`.
- Current review-app meter-only and inspector cadences are lower, commonly `10 FPS`.
- The Slice 9 stress fixture models `120 FPS` incoming meter cadence versus `60 FPS` active viewport cadence.
- The new target is to design toward `120 FPS` graphics and `30 FPS` displayed meters, not to pretend the existing code already exposes those settings everywhere.

In this guide, "30 FPS meters" means the display-side meter update cadence. It does not mean the host audio callback, raw telemetry ingress, or meter extraction cadence.

## Current Architecture

The repository is a Swift package named `OrbitalViewKit`.

Implemented package targets:

```text
OrbitalViewCore
  Pure value contracts, validation, coordinate system, scene, shell, speaker,
  meter, source, object, camera, performance, selection, and diagnostics types.

OrbitalViewWavefield
  Local Wavefield-style speaker-layout JSON and meter-frame adapters.

OrbitalViewSpatGRIS
  SpatGRIS speaker/source setup XML import/export, project source metadata,
  and /spat/serv OSC payload parsing. It does not own sockets in production.

OrbitalViewRender
  Production MetalKit / MTKView renderer seam with offscreen-tested Metal draw
  path, retained buffers, static/dynamic revision keys, speaker material
  updates, and object overlay draw path.

OrbitalViewSwiftUI
  Production SwiftUI wrapper and MTKView bridge for host apps. It is the target
  downstream apps should import.

OrbitalViewReview
  Review/demo-only SceneKit visual surface, local visual test audio, file
  dialogs, PNG export, app-bundle themes, bundled fonts, SpatGRIS layout stores,
  and review-only OSC listening.

OrbitalViewViewer
  Local native review executable that hosts OrbitalViewReview.

OrbitalViewViewerSupport
  Demo content and visual telemetry stress fixtures.
```

The most important architectural split:

```text
Visible review app today:
  OrbitalViewViewer -> OrbitalViewReview -> SceneKit OrbitalViewportMockup

Production host integration seam:
  Host app -> OrbitalViewSwiftUI -> OrbitalViewRender -> OrbitalViewCore
```

Do not confuse the current review executable with the production renderer seam. The review app is the confirmed visual/tuning surface. Production host apps should import `OrbitalViewSwiftUI` and `OrbitalViewRender`, not `OrbitalViewReview`, unless a future task explicitly chooses review/demo tooling.

## Read These Files First

Recommended order:

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
docs/decisions/0002-renderer-backend.md
Package.swift
Sources/OrbitalViewCore/
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewReview/OrbitalViewportMockup.swift
Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift
Tests/OrbitalViewRenderTests/
Tests/OrbitalViewSwiftUITests/
Tests/OrbitalViewViewerTests/
mockups/orbital-view-viewport/
docs/media/orbital-view-vu-1.0/
```

Use the source files to confirm current symbols. Some older docs and the older `CHATGPT_PRO_ARCHITECTURE_BRIEF.md` still mention the earlier `60 FPS` target; this guide supersedes that for the performance handoff.

## Hard Constraints

Preserve these constraints in any prompt:

- Do not change audio behavior.
- Do not own audio callbacks, playback timing, route repair, device I/O, MIDI, OSC, or output routing.
- Do not block or allocate on behalf of a host audio callback.
- Do not fake production meter data.
- Do not reorder, truncate, downmix, or remap physical speaker channels.
- Do not resize speaker geometry as a VU animation technique.
- Keep canonical 3D coordinates Z-up: `x = right`, `y = front`, `z = up`.
- Keep `OrbitalViewCore` independent of SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, and downstream app targets.
- Do not import WebView, browser runtime code, or DomeLab app code.
- Do not replace the accepted production renderer seam: MetalKit / MTKView in `OrbitalViewRender`, wrapped by `OrbitalViewSwiftUI`.
- Keep review-only SceneKit/local audio/theme/export/font behavior in `OrbitalViewReview`.
- Protected renderer/UI/review paths require focused scope and tests.

## Current Performance Model

Current documented renderer constraints:

- Do not rebuild shell or speaker geometry for every meter update.
- Smooth visual envelopes at display cadence, not in audio callbacks.
- Treat display telemetry as latest-complete-frame-wins.
- Drop stale frames and decimate display refresh under load.
- Keep only the latest complete snapshot.
- Set overload diagnostics outside realtime paths.
- Use retained resources and instancing where practical.
- Keep meter updates separate from structural scene updates.
- Keep draw-on-demand enabled by default for idle/static production viewports.
- Keep object trails and glow trails capped.

Current production performance settings:

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

Future prompt should explicitly ask the coding agent to evaluate how to move toward:

```text
activeViewportFramesPerSecond = 120 target
meterOnlyViewportFramesPerSecond = 30 target
```

That may require expanding settings contracts, review UI labels, FPS diagnostics thresholds, test coverage, and implementation behavior. It should be staged carefully because `30` and `60` are currently source-level assumptions.

## Current SceneKit Review Surface

The visible review app is:

```text
Sources/OrbitalViewReview/OrbitalViewportMockup.swift
Sources/OrbitalViewViewer/OrbitalViewViewer.swift
```

Current visual surface:

- SceneKit-based review viewport.
- Full-height left rail with `Orbital View`, Camera, and View Detail.
- Right panel with `Sound Metering Input`, `Input`, `Speaker and Source Layout`, `Roll the dice on looks`, Theme, Speaker Appearance, Sphere Appearance, Ground Appearance, Meter Behavior, and Diagnostics.
- Input modes: `Telemetry`, `Local Song`, and `Impulse Test`.
- Speaker types: `Prism`, `Sphere`, and `Cube VU`.
- Default active visual direction: Cube VU speaker type, Hot Core Bloom, Purple family styling, hidden ribbed speaker sphere, local source-marker styling, and SceneKit material updates.
- Review-only FPS chip: bottom-right status dot plus current `FPS` value.
- FPS diagnostics: capped log entries with target/below/under-target status transitions.

Current SceneKit performance surfaces to inspect:

- `OrbitalViewport3DSceneView` and its `Coordinator`.
- `activeFramesPerSecond`, `setActiveFramesPerSecond`, `startAnimationTimerIfNeeded`, `restartAnimationTimer`, and `renderAnimationFrame`.
- `renderScene(configuration:)` and its update-key comparisons.
- `OrbitalViewportFrameRateMonitor` and `OrbitalViewportFrameRateSample`.
- Speaker geometry rebuild keys versus material update keys.
- Ribbed sphere topology/update keys.
- Grid plane rebuild/update keys.
- Source update keys.
- Label font and texture-backed label rebuild paths.
- `OrbitalViewportCubeVUSceneKitMaterial` and its retained face texture cache.
- Any main-thread work inside frame ticks, material updates, label texture generation, source movement, rib/grid rebuilding, and diagnostics logging.

Current review tests already assert important invariants:

- meter-only ticks update material cadence without rebuilding shell or speaker geometry;
- font/font-size changes rebuild labels but not shell or speaker bodies;
- grid spacing changes are isolated from speaker material/labels/source markers/ribbed sphere;
- geodesic saturation updates only ribbed sphere material keys;
- source palette changes only source material;
- diagnostics log is capped and not driven by meter-only frame ticks;
- FPS diagnostics classify against current `60` target with `30..<60` below target and `<30` under target.

## Current Metal Production Renderer

Production renderer path:

```text
Sources/OrbitalViewRender/OrbitalViewMetalRenderer.swift
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewRender/OrbitalViewRenderState.swift
Sources/OrbitalViewSwiftUI/OrbitalViewMetalView.swift
```

Current Metal behavior:

- `OrbitalViewMetalRenderer` stores `OrbitalViewRenderState`.
- It exposes an `MTKViewDelegate`.
- It creates `OrbitalViewMetalDrawPipeline` per `MTLDevice`.
- The draw pipeline renders instanced cube/prism speakers.
- Speaker meter values affect display/material payloads only.
- Static speaker identity and geometry are separated from meter material state.
- Object overlays render through separate retained buffers.
- Offscreen smoke tests render deterministic frames without opening the app.

Current Metal performance surfaces to inspect:

- `prepareSpeakerDrawResources(for:)`.
- `prepareObjectDrawResources(for:)`.
- revision keys for structural, meter, meter visual settings, object frames, object meters, and object visual settings.
- retained `MTLBuffer` capacity and `debugBufferAllocationCount`.
- `reusableBuffer(existing:capacity:values:)`.
- static speaker draw-input generation.
- material/ramp update frequency.
- object position/color update frequency.
- MTKView configuration in `OrbitalViewMetalView.configure`.

Current production wrapper behavior:

```text
view.preferredFramesPerSecond = settings.activeViewportFramesPerSecond
view.enableSetNeedsDisplay = settings.drawsOnDemand
view.isPaused = settings.drawsOnDemand
```

This is a likely area to revisit for a 120 FPS active target and 30 FPS meter target, but the prompt should require proof through tests before changing public behavior.

## Visual Telemetry Stress Fixture

The stress fixture lives in:

```text
Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift
Tests/OrbitalViewViewerTests/OrbitalViewViewerDemoContentTests.swift
docs/visual-telemetry-stress-gates.md
```

Current fixture shape:

- 30 physical speakers in stable channel order `1...30`;
- 128 source objects;
- object trails capped at 16 points per object;
- active viewport motion currently modeled at `60 FPS`;
- incoming meter frames modeled at `120 FPS`;
- local livestream generator provenance;
- stale display frames represented as overload diagnostics, not audio errors.

The performance prompt should decide how to evolve this fixture toward the new goal:

```text
120 FPS active viewport target
30 FPS meter/display target
```

It should not claim host callback compliance. Host callback p99/deadline checks belong to Wavefield, Orbisonic, or Splat.

## Likely Hot Path Questions

Ask the coding agent to answer these before editing:

- Is the current SceneKit review app CPU-bound on the main thread, GPU-bound, timer-bound, or SwiftUI update-bound?
- Are material updates allocating or touching too many `SCNMaterial` properties per frame?
- Are labels, grid, ribbed sphere, or source nodes rebuilding during meter-only frames?
- Does the `Timer` loop produce stable 120 FPS timing, or would `SCNView`/display-link style scheduling be needed?
- Is `view?.needsDisplay = true` enough for 120 FPS active movement with `rendersContinuously = false`?
- Are FPS samples measuring actual display cadence or only update-loop cadence?
- Does the review app need separate active-interaction, meter-only, and inspector scheduling?
- Do source markers or future 128-object stress scenes need pooling instead of add/remove node churn?
- In Metal, are dynamic buffers rewritten only when necessary?
- Should the production Metal path move more visual work into shaders before trying to optimize SceneKit?
- Which tests can catch performance regressions without brittle screenshots?

## Recommended Prompt Shape For ChatGPT Pro

ChatGPT Pro should write a prompt that tells the coding agent to:

1. Confirm the current branch/worktree and dirty state.
2. Read the required project docs and this guide.
3. Inspect the current SceneKit review loop and production Metal path before editing.
4. Preserve the current UI/product direction.
5. Treat `120 FPS active viewport` and `30 FPS meter display` as target goals, not current truth.
6. Propose a small first implementation slice focused on measurement and low-risk scheduling/resource improvements.
7. Add source-level tests for new constants, cadence contracts, update-key isolation, retained-resource reuse, and diagnostics behavior.
8. Run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```

9. Launch the review app only if visible review behavior changes:

```text
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command
```

10. Update `docs/status.md` with exact verification.

## Ready-To-Use ChatGPT Pro Request

Paste this into ChatGPT Pro after uploading the zip:

```text
You are helping write an implementation prompt for a coding agent working in the Orbital View Kit repository.

Read CHATGPT_PRO_GRAPHICS_PERFORMANCE_GUIDE.md first, then read the repo files it points to. Your task is not to write code. Your task is to write one implementation-ready prompt that tells a coding agent how to improve Orbital View graphical performance while preserving the current architecture and visual direction.

Hard goals:
- active viewport / interaction target is 120 FPS;
- displayed meter update target is 30 FPS;
- current implementation mostly exposes 30/60 FPS active settings and lower idle/meter cadences, so the prompt must treat 120 FPS as a target to design toward, not current truth;
- preserve 30 physical speakers now, future 52 speakers, up to 128 objects, physical channel identity, and the current SceneKit review-app visual direction;
- do not change audio, routing, playback, MIDI, OSC, host realtime callbacks, or production meter source-of-truth;
- do not replace the accepted production MetalKit / MTKView seam.

The prompt you write should include:
- what files the coding agent should inspect first;
- how to profile or instrument the current review app and Metal path;
- likely hot paths in OrbitalViewportMockup.swift, OrbitalViewMetalDrawPipeline.swift, OrbitalViewMetalView.swift, and related tests;
- a staged first implementation slice with exact scope;
- source-level tests to add or update;
- manual verification expectations if visible review behavior changes;
- acceptance criteria and stopping conditions;
- documentation updates required in docs/status.md.

Keep the prompt grounded in the current files. Do not invent a new app, WebView path, downstream host integration, or audio feature.
```

## Expected Output Quality

The best ChatGPT Pro output will avoid a vague "make it faster" prompt. It should produce a coding-agent prompt that is narrow, measurable, and respectful of the existing package:

- first measure or expose evidence;
- then improve cadence/resource behavior;
- then verify with tests and, if needed, the native review app;
- keep the production Metal seam and review SceneKit surface distinct;
- keep audio and host callback behavior out of scope.
