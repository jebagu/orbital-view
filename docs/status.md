# Project Status

## Current Phase

```text
Realtime audio family compliance baseline complete
```

## Current Milestone

```text
Final realtime-family compliance audit
```

## Summary

The active review app is the existing `OrbitalViewViewer` executable in this package, now hosting the confirmed VU Kit native SceneKit geodesic viewport surface through `OrbitalViewportMockup`. It is not the rejected bare MTKView demo surface and does not create a second standalone copied app.

Canonical 3D coordinates in this package are now Z-up: `x = right`, `y = front`, and `z = up`. Wavefield/Fey channel order remains physical channel order `1...30`; renderer and review surfaces transform canonical vectors into their own Y-up spaces only at render boundaries.

The confirmed review app keeps the left control rail focused on product identity, Camera, and View Detail. The visible rail now fills the full desktop window height, shows the plain `Orbital View` title near the top using the Wavefield Receiver player-title font treatment, and places Camera/View Detail directly underneath. The right panel now starts with a `Sound Metering Input` header above the single expandable `Input` tray, followed by `Speaker and Source Layout`, `Roll the dice on looks`, `Theme`, Speaker Appearance, Sphere Appearance, Ground Appearance, Meter Behavior, and Diagnostics. All collapsible right-panel trays start closed by default; operators expand only the tray they need. `Speaker and Source Layout` has title-only `Sonic Sphere Speakers` and `Source Speakers` trays for SpatGRIS receiver speaker setup import/save/defaults, source setup import/save/defaults, source project metadata import, and review-only `/spat/serv` OSC listening on a validated UDP port; the trays include the SPAT XML kicker copy for receiver and source layouts. The `Input` tray begins with the Orbisonic-style `Telemetry` / `Local Song` / `Impulse Test` selector and folds all input behavior into one surface: telemetry provider/status/track details with selectable advertiser buttons when multiple review advertisers exist, local song choose-file/transport/render-type controls, impulse pattern controls, and `Meter Source` status. Speaker Type lives in the right `Speaker Shape` tray. `Roll the dice on looks` is a global review-only dice action with a centered icon-only dice button that randomizes view/visual state, including Source Speaker Palette and every current Sphere Appearance control, while preserving Input state, saved/default theme metadata, selected speaker, and diagnostics. Label Font now groups fonts by Normie, Nerd, and Nostromo families and includes a review-only font size slider. Local dice randomizers still live inside Cube Surface, Bloom Style, and Meter Response. The app skin follows the Sonic Sphere speaker palette, the separate Source Speaker Palette styles source markers only, and `Sphere Geometry` owns the default-off `Ribbed Speaker Sphere` overlay plus Rib Thickness, Vertical Ribs, and Horizontal Rings controls. `Geodesic Appearance` now owns only the independent geodesic palette/saturation styling, and saturation applies to the ribbed sphere in SceneKit and canvas fallback. The old imported/Fey shell and `Hide Sphere` control are removed from the live review workflow. The review-only `Ground Appearance` tray owns the optional display-only `Grid Plane` toggle, `Grid Visibility`, `Grid Spacing`, and ground palette controls for the 10 x 10 line grid below the sphere without changing speaker geometry, labels, Cube VU materials, source markers, ribbed sphere style, or meter state. Object overlay, trails, glow trails, and bounds controls are hidden for the current review pass while the underlying object contracts remain in the package.

The SceneKit review app can load a local audio file for visual testing only when `Local Song` is selected. Local file playback uses a simple choose-file plus separate play/pause transport and reduces the file meter to one mono RMS/peak sample applied equally to all speakers. `Telemetry` defaults to `No Provider` and displays silent meters until a real Orbisonic telemetry publisher exists. This is review-app input selection only; production hosts still provide real `SpeakerMeterFrame` values keyed by physical speaker channel.

`Cube VU` speaker type now uses the VU Kit scalar center-bloom contract in the SceneKit surface with a retained 9x9 face-pixel material texture applied to the actual cube faces, selected Orbisonic theme colors, RMS-driven center bloom, peak/hot fill, clip flash, and a material-only cube outline strength control. The old review-app `Speaker Height` control is no longer visible; older saved values still decode but are normalized to the current flat cube/prism geometry path. Prism and Sphere keep the existing simpler material tint behavior while inheriting the selected viewport theme.

The production SwiftUI wrapper still targets the MetalKit renderer seam for downstream hosts. Review/demo-only SceneKit, local audio playback, file dialogs, PNG export, app-bundle theme persistence, and bundled review fonts now live in the separate `OrbitalViewReview` target. Speaker and object meter frames now carry telemetry source descriptors so displayed meters can identify speaker bus, object bus, final output, hardware tap, local livestream test generator, external Wavefield stream, Orbisonic prepared meter tap, Splat prepared analysis, review local audio, or synthetic visual stress provenance. The native review executable is intentionally a SceneKit visual-review surface because that is the UI the user confirmed as correct.

Wavefield realtime output is now specified as a host-owned prepared snapshot boundary. Wavefield owns external livestream parsing, the local livestream test generator, MIDI streams, realtime queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and performance gates. Orbital View Kit receives only prepared scene, speaker meter, object frame, object meter, diagnostics, and source metadata snapshots. Local generator profiles are source metadata and display stress inputs, not alternate Orbital View audio paths.

Orbital View UI and review-surface work now has a local design-language contract in `docs/orbisonic-design-language.md`. Future UI slices must use the Orbisonic design-language source files for shell layout, palette behavior, meter treatment, diagnostics separation, and information hierarchy while preserving Orbital View Kit's own product role and realtime boundaries.

Orbisonic and Splat host integration profiles are now specified in `docs/integrations/orbisonic-splat-host-profiles.md`. Orbisonic receives a prepared viewport for explicit bus/object/speaker meter tap points while retaining playback, routing, Core Audio device I/O, render/control, metering, operator state, and performance ownership. Splat receives a preparation/control viewport for virtual speakers, source objects, renderer-kernel overlays, and neutral geometry review while retaining project/session state, edit/export, kernel analysis, file formats, persistence, and host handoff ownership.

The Slice 9 visual telemetry stress gate is now specified in `docs/visual-telemetry-stress-gates.md` and implemented as `OrbitalViewVisualTelemetryStressScene`. The fixture models 30 physical speakers, 128 source objects, capped object trails, 120 FPS active motion, 120 FPS incoming meter cadence, 30 FPS displayed meter cadence, open diagnostics, local livestream generator provenance, and stale display-frame drops as overload diagnostics. This is viewport no-backpressure evidence only; host callback p99, callback deadline, route repair, device I/O, MIDI/OSC, and meter-extraction gates remain host-owned.

The final realtime-family adoption audit is now recorded in `docs/realtime-family-compliance-audit.md`. The package can be described as standards-aligned as a visual telemetry/preparation package: it inherits the Realtime Audio Family Standards Package, owns no callback entry points, keeps review-only code separated, uses OpenSpec for future audio-facing or architecture-facing changes, treats the Wavefield local livestream generator as a host source, and uses the Orbisonic design language as UI guidance only. Remaining risks are explicit in the audit.

The project launcher `Open Orbital View Kit.command` rebuilds the latest `OrbitalViewViewer`, refreshes the native review `.app` executable and `OrbitalViewKit_OrbitalViewReview.bundle`, restarts stale `OrbitalViewViewer` processes, and opens the refreshed review app. The parent-folder launcher `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` delegates to the project launcher so Finder access from the `vibecode projects` root stays current.

## Current Work Package

```text
orbital-view-graphics-performance-codex-work-package/orbital-view-graphics-performance-codex-work-package.md
```

## Current Tree

```text
main tree
```

## Completed

- Promoted the Codex project template into the root.
- Added OrbitalViewKit-specific project docs.
- Moved the initial work package under `work-packages/orbital-view-kit/`.
- Defined the first implementation task for `OrbitalViewCore`.
- Implemented `Package.swift`, `Sources/OrbitalViewCore/`, and `Tests/OrbitalViewCoreTests/`.
- Verified `OrbitalViewCore` with build and test commands using the full Xcode toolchain.
- Implemented `Sources/OrbitalViewWavefield/` and `Tests/OrbitalViewWavefieldTests/` using a copied Fey 30 fixture.
- Implemented Wavefield-style meter frame adaptation into `SpeakerMeterFrame`.
- Created `mockups/orbital-view-viewport/` to preview camera presets, selection, labels, cutaway, and fake meter glow before Swift renderer work.
- Accepted MetalKit / MTKView as the production renderer backend in `docs/decisions/0002-renderer-backend.md`.
- Implemented `Sources/OrbitalViewRender/` and `Tests/OrbitalViewRenderTests/` as the first compile-focused renderer seam.
- Implemented `Sources/OrbitalViewSwiftUI/` and `Tests/OrbitalViewSwiftUITests/` as the compile-only wrapper skeleton.
- Added `docs/renderer-test-harness.md` to define the verification shape for first draw-loop work.
- Implemented a minimal Metal draw pipeline and offscreen renderer smoke test.
- Added renderer invariant tests for static draw-input stability across meter and camera updates.
- Added a root `.command` launcher for the live browser mockup.
- Accepted the pasted Fey 30 raw speaker coordinates as the canonical geometry source after verifying that the existing `unitSphereCartesian` fixture matches their radial normalization.
- Updated the browser mockup with the DomeLab 3D Model control panel and behavior.
- Swapped the mockup's vertical drag axis and added a front-hemisphere sphere-edge boundary.
- Added full-surface mockup display palettes, a Speaker size slider, and 2:1:1 rectangular-prism speaker proportions.
- Removed the mockup Projection picker, made projection always axonometric, and changed prism speakers to face-clipped 3D cuboids.
- Added mockup Speaker numbers and Hidden Lines controls, moved the lower control order, strengthened max fog, and improved label color/spacing.
- Grouped the mockup controls under Camera, Color, Speaker Shape, and View Detail headings, converted Speaker numbers to a switch, and aligned hidden speaker fog fading with hidden shell-line fading.
- Updated the mockup Color selector to Green, Flamingo, Purple, and B&W, with Green using Orbisonic Lab tokens and Purple using Kimi Purple tokens.
- Reordered the mockup Color selector to Purple, Flamingo, Green, and B&W with Purple default; made Prism the default Speaker Shape; defaulted Speaker numbers and Hidden Lines off; centered the Speaker size slider at 1.95x; and remapped Fog density so the prior 30-density look sits at the slider midpoint.
- Replaced the mockup's generic latitude/spoke shell structure with a generated Fey 3V class-I icosahedron geodesic shell from the DomeLab project config values.
- Added `CHATGPT_PRO_ARCHITECTURE_BRIEF.md` and packaged `OrbitalViewKit-chatgpt-pro-architecture-context.zip` for a ChatGPT Pro production-renderer architecture brainstorm.
- Merged the native Cube VU path from Orbital View VU Kit into the Metal production renderer while preserving physical speaker channel identity and adding dynamic object frame/meter support.
- Added the native `OrbitalViewViewer` executable and testable demo-content support target for Cube VU and object overlay review outside XCTest.
- Deprecated the native Cube VU merge, viewer target, object overlay merge, and related docs produced in this chat.
- Re-activated the Cube VU/object overlay direction through an explicit merge plan, added collapsible tuning trays, and wired performance settings into the existing SwiftUI + MTKView wrapper.
- Replaced the rejected viewer executable surface with the confirmed VU Kit SceneKit geodesic viewport mockup, preserving the exact left control rail and adding tuning trays beneath View Detail.
- Split the review-only SceneKit/local-audio surface into `OrbitalViewReview` so production `OrbitalViewSwiftUI` no longer imports review playback, file, export, theme, or font resources.
- Added telemetry source descriptors to speaker/object meter frames and documented latest-complete-frame-wins display overload behavior.
- Specified the Wavefield realtime connection, including local livestream generator profile handling, object/speaker identity mapping, and no direct Wavefield package dependency.
- Added Orbisonic design-language guidance for future UI and review-surface work.
- Specified Orbisonic and Splat host integration profiles without downstream source edits.
- Added the Slice 9 visual telemetry stress fixture, stress docs, and tests for local-generator-sourced display no-backpressure behavior.
- Completed the realtime-family compliance audit and documented the remaining risks.
- Added the review-only optional `Grid Plane` toggle, SceneKit and Canvas fallback grid drawing, theme JSON persistence, and grid-isolated update-key tests.
- Added review-only `Grid Visibility` tuning and expanded the ground plane to 10 x 10 canonical units.
- Moved review-only ground plane controls into the right-panel `Ground Appearance` section and added grid spacing plus ground palette controls.
- Restored the review app icon to the archived previous gradient option 02 icon assets in the repo.
- Moved the review-app Input selector, source-specific trays, and Meter Source status to the top of the right panel; added multi-advertiser telemetry selection plus global Roll the Dice view randomization while preserving input state.
- Added `OrbitalViewSpatGRIS`, SpatGRIS speaker/source layout stores, source/project import, review-only `/spat/serv` OSC listening, layout-derived scene bounds, and separate review source markers.

## In Progress

```text
none
```

## Pending

```text
- Tune fog behavior/visual quality; current fog still needs another pass.
- Remove the two old speaker types (`Prism` and `Sphere`) if the next UI cleanup slice accepts `Cube VU` as the only retained current speaker type.
- Add a new radial-fountain VU speaker type.
- Prove live Orbisonic telemetry end-to-end with a real publisher/consumer run; current telemetry is wired and tested at source level but not proven in the visible review app.
```

## Blocked

```text
none
```

## Recent Changes

### Update: 2026-05-30 Operator Status Checkpoint

- User-visible review status: speed is excellent, the visible app is reliably running at 60 FPS, menus are solid, and `Hidden Lines` now works across the current review surface.
- Remaining visual gap: fog still needs more work before it should be considered polished.
- Desired speaker-type cleanup: delete the two older speaker types, currently `Prism` and `Sphere`, and keep the current Cube VU path while adding a new radial-fountain VU speaker type.
- Telemetry status: Orbisonic telemetry is not proven to work end-to-end yet; current source-level telemetry wiring should stay treated as unqualified until verified against a real provider in the visible review app.
- Verification: this checkpoint records the operator review notes; commit verification ran `git diff --check`, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`, and `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` with 194 tests and 0 failures. The visible app was not relaunched for this docs checkpoint.

### Update: 2026-05-30 Active Render Lock-Inversion Freeze Fix

- Fixed the native review app freeze introduced by the active-spin crash fix: the main timer path could hold the coordinator mutation lock while committing a SceneKit transaction, while SceneKit's render queue waited on that same lock from `renderer(_:updateAtTime:)`.
- Changed the SceneKit render delegate active-frame path to try the coordinator mutation lock non-blockingly and skip that one active camera frame when a main-thread SceneKit mutation is already in progress.
- Added regression coverage that holds the mutation lock from a background thread and verifies active render frames skip without camera, ribbed topology, ribbed material, or segment writes.
- Verification: `git diff --check` passed; focused `OrbitalViewSwiftUITests/testCorrectViewerActiveRenderFrame*` tests passed with 2 tests and 0 failures; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 194 tests and 0 failures; `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt/opened the current app; `pgrep -fl OrbitalViewViewer` confirmed PID `41457` running from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`; and `sample 41457 5 -mayDie` wrote `/tmp/OrbitalViewViewer_2026-05-30_215752_d0XE.sample.txt` without the render queue blocked on `NSRecursiveLock`.

### Update: 2026-05-30 Active Spin Ribbed Sphere Crash Fix

- Fixed the native SceneKit review app crash where active spin plus the ribbed speaker sphere could enter the ribbed cutaway path on both the main SwiftUI/timer path and the SceneKit render queue.
- Removed the obsolete ribbed material shader/KVC cutaway-uniform path and the shared material-state dictionary; hidden-line cutaway is now owned by the invisible depth-only bisecting plane.
- Cached the fitted ribbed sphere center/radius at topology rebuild time and serialized coordinator SceneKit mutations so active render frames update only camera/cutaway-plane state, not ribbed materials, topology, or segment loops.
- Added regression coverage for the active render delegate path proving it does not write ribbed materials, rebuild topology, visit ribbed segments, or rely on material shader/KVC cutaway uniforms.
- Verification: focused hidden-line, camera-only, and active-render crash-path regression tests passed; `git diff --check` passed; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 193 tests and 0 failures; `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt/opened the current app; and `pgrep -fl OrbitalViewViewer` confirmed PID `40479` running from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`.

### Update: 2026-05-30 True Isometric Camera Axis And Spin

- Recalculated the SceneKit review app's `Isometric` camera from canonical Z-up axes so its preset view direction is the true normalized `+X/+Y/+Z` isometric direction.
- Replaced the old tilted isometric basis with canonical yaw/pitch camera math: yaw spins around canonical `Z`, pitch controls elevation, and the screen right/up/view vectors are rebuilt as an orthonormal basis.
- Updated default review camera/export state to start from the isometric preset instead of `0,0`, and made unadjusted saved/default theme cameras resolve to the current preset while preserving adjusted saved cameras with pitch clamping.
- Added regression coverage for true isometric direction, orthonormal preset camera bases, isometric spin preserving canonical Z-axis elevation, canonical +X projection, active-spin cadence, and legacy unadjusted theme camera migration.
- Verification: focused camera regression tests passed with 8 tests and 0 failures, `git diff --check` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, and `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 188 tests and 0 failures.
- Relaunch gate: `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt and opened the current app, and `pgrep -fl OrbitalViewViewer` confirmed PID `69017` running from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`.

### Update: 2026-05-30 Right-Panel Tray Startup Defaults

- Changed the SceneKit review app so all collapsible right-panel tuning trays start closed by default, including `Input`, `Sonic Sphere Speakers`, and `Source Speakers`.
- Added an explicit test-visible default expansion list in `OrbitalViewportMockup`; it is empty by default and drives the right-panel tray `@State` initializers.
- Preserved the existing tray order, section headers, selected `Telemetry` source mode, and all manual expand/collapse behavior.
- Verification: `git diff --check` passed, `swift build` passed, and `swift test` passed with 183 tests and 0 failures.
- Relaunch gate: `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt and opened the current app, and `pgrep -fl OrbitalViewViewer` confirmed PID `27542` running from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`.

### Update: 2026-05-30 Hidden Lines Sphere Frame And Speaker Parity

- Made the review-app `Hidden Lines` control apply consistently to the batched ribbed sphere frame, rear speaker bodies, and text speaker labels.
- Added a shared speaker-label visibility rule so SceneKit labels and the canvas fallback follow the same depth semantics: `Hidden Lines` off hides rear labels, `Hidden Lines` on shows them, and selected labels stay visible when speaker numbers are enabled.
- Kept the ribbed sphere as two batched SceneKit mesh nodes and added an invisible depth-only bisecting plane for rear-frame hiding, avoiding a return to per-segment cylinder nodes or camera-motion segment loops.
- Added regression coverage for rear SceneKit speaker/label visibility, selected rear label visibility, and ribbed-sphere hidden-line cutaway updates without topology rebuilds.
- Verification: `swift build` passed, `swift test` passed with 183 tests and 0 failures, and `.build/debug/OrbitalViewHeadlessBenchmark --mode both --ribbed --warmup 30 --frames 120 --target 120` reported default ribbed `segments=1152`, `nodes=2`, `idle 63.9 FPS`, and `active 222.7 FPS`.
- Relaunch gate: `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt and opened the current app, and `pgrep -fl OrbitalViewViewer` confirmed PID `25756` running from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`.

### Update: 2026-05-30 Ribbed Sphere Hidden-Line Bisecting Plane

- Corrected the headed-app regression where the ribbed sphere could disappear completely when `Hidden Lines` was off by removing the fragment-discard cutaway as the visibility mechanism.
- `Hidden Lines` off now uses an invisible depth-only SceneKit plane through the fitted ribbed sphere center, perpendicular to the current camera direction, so the rear half is hidden by depth testing while the camera-facing half remains visible.
- `Hidden Lines` on hides the cutaway plane and leaves the full two-node ribbed sphere visible.
- Regression coverage now asserts front and rear points around the fitted ribbed sphere center classify against the bisecting plane, `Hidden Lines` toggles the plane visibility, camera-only motion keeps the two ribbed mesh nodes, and camera-only motion updates only the cutaway plane without topology rebuilds, material writes, or segment visits.
- Verification: `git diff --check` passed; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 188 tests and 0 failures; focused ribbed cutaway and camera-only tests passed; `.build/debug/OrbitalViewHeadlessBenchmark --mode idle --ribbed --warmup 5 --frames 10 --target 120` rendered the ribbed hidden-lines-off path with `segments=1152`, `nodes=2`, and `idle 78.5 FPS`.
- Relaunch gate: `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt and opened the current Turbo app, and `pgrep -fl OrbitalViewViewer` confirmed PID `31691` running from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`. Manual headed screenshot verification could not be completed after the macOS session switched to the lock screen during accessibility-coordinate control attempts.

### Update: 2026-05-30 SceneKit Review No-Op Material Gate CPU Pass

- Reduced the visible SceneKit review app's idle CPU cost without changing speaker shape, Cube VU look, colors, layout, camera behavior, active cadence, or meter cadence.
- Added a no-op render gate so unchanged frames skip `SCNTransaction` setup and `needsDisplay` requests instead of committing SceneKit work every timer tick.
- Split meter cadence from actual visual material state with quantized per-speaker and per-source material signatures. Silent or unchanged displayed meter buckets now update internal cadence keys without rewriting speaker/source materials, while changed meter buckets, selected-channel changes, palette changes, source marker changes, and active spin camera frames still update immediately.
- Added SceneKit material-state caching for non-Cube-VU speaker materials, cube outlines, source markers, texture-backed labels, grid/ribbed sphere batch materials, and stable theme/VU-ramp `NSColor` conversions. Node removal now forgets only the removed nodes' material cache entries.
- Extended review-only instrumentation for skipped display requests, no-op render passes, material writes/skips, and unchanged-meter speaker/source skips.
- Added or updated SceneKit regression coverage for repeated identical renders, silent unchanged meter buckets, changed meter buckets, selected-channel changes, palette changes, source marker material changes, grid material cache skips, Cube VU unchanged bucket skips, and source pose/material cadence separation.
- Verification: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 180 tests and 0 failures, and `git diff --check` passed.
- Relaunch and CPU evidence: `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt and opened PID `23799` from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`. Against the prior visible baseline of about `35-45% CPU`, `ps` settled at `4.3% CPU` with RSS `136784`, and `top -l 5` settled at `3.3%`, `4.0%`, `5.8%`, and `6.8%` CPU after the first sample. `sample 23799 5 -mayDie` wrote `/tmp/OrbitalViewViewer_2026-05-30_190503_XqBO.sample.txt`, with physical footprint `70.3M`, peak `92.2M`, and the main thread mostly in the event loop.

### Update: 2026-05-30 Ribbed Dome SceneKit Batching And Benchmark Coverage

- Diagnosed the dense ribbed dome slowdown as a SceneKit modeling problem: the default ribbed sphere represented about `1,152` rib/ring cylinder nodes, and the max settings could reach about `8,192` nodes, with camera-driven update keys previously able to revisit per-segment visibility/material work.
- Replaced the SceneKit ribbed sphere's per-segment `SCNCylinder` node model with two batched mesh nodes: one vertical-rib mesh and one horizontal-ring mesh. Camera-only motion no longer updates ribbed sphere materials, hidden state, or segment loops; density changes rebuild the batched topology once.
- Extended review-only instrumentation with ribbed segment/node build counts, material writes, hidden-state writes, and topology rebuild counts.
- Added `OrbitalViewHeadlessBenchmark` ribbed-sphere options: `--ribbed`, `--vertical-ribs N`, `--horizontal-rings N`, `--show-hidden-lines`, and `--fog-density N`. Benchmark output now includes ribbed segment count, SceneKit node count, active/idle FPS, and process CPU percent.
- Added regression coverage for default/medium/max ribbed segment counts, the two-node SceneKit reduction, camera-only ribbed update skips, single topology rebuilds on density changes, geodesic palette material updates, and benchmark ribbed configuration flags.
- Recorded the previous failed visible-performance attempts and current verification gate in `docs/bugs.md`; code behavior changed only for the ribbed SceneKit performance path.
- Verification: `swift build` passed, `swift test` passed with 176 tests and 0 failures, and `git diff --check` passed. Ribbed benchmark evidence with 120 measured frames: ribbed off `idle 62.5 FPS / active 223.5 FPS`; default ribbed `segments=1152`, `nodes=2`, `idle 61.6 FPS / active 212.2 FPS`; medium ribbed `segments=3840`, `nodes=2`, `idle 61.3 FPS / active 210.1 FPS`; max ribbed `segments=8192`, `nodes=2`, `idle 60.8 FPS / active 210.4 FPS`.
- Relaunch gate: `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt and opened the current app, and `pgrep -fl OrbitalViewViewer` confirmed PID `8456` running from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`. Basic screenshot evidence is `/private/tmp/orbital-view-turbo-ribbed-batched-review.png`.

### Update: 2026-05-30 Headed SceneKit 120 FPS Recovery With Restored Speaker Look

- Restored the approved Cube VU speaker outline path after rejected visual experiments. The current build does not use the softer 1x backing-scale experiment and does not use a packed/single-node cube-outline mesh; Cube VU speakers are back on the original twelve separate chamfered edge-box outline child nodes per speaker.
- Added an explicit headed benchmark launch flag (`--headed-benchmark` or `ORBITAL_VIEW_HEADED_BENCHMARK=1`) that starts the review app in active spin without changing default interactive startup behavior.
- Moved active-spin camera updates and FPS sampling onto SceneKit's headed render delegate while leaving the timer-driven meter/material updates on the existing lower-rate cadence. This lets the visible FPS chip report the real headed render loop during active motion instead of the 30 FPS meter-update cadence.
- Preserved the existing speaker body geometry, Cube VU face material path, channel order, telemetry ownership, audio/routing boundaries, and production MetalKit renderer contract.
- Headed verification after the visual rollback: `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt and reopened the current app, then `open -n "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" --args --headed-benchmark` opened the active headed benchmark window. Screenshot evidence: `/private/tmp/orbital-view-headed-final-120-restored-speakers.png` shows the restored twelve-edge Cube VU speaker look with the visible FPS chip at `120.1`; `ps -p 98277 -o pid,pcpu,pmem,comm,args` reported the headed benchmark process running at about `59.1%` CPU.
- Headless sanity evidence after the same build: `.build/debug/OrbitalViewHeadlessBenchmark --mode both --warmup 30 --frames 120 --width 1360 --height 820 --target 120` reported `idle headless offscreen throughput: 57.7 FPS` and `active headless offscreen throughput: 195.9 FPS`.

### Update: 2026-05-29 Review SceneKit 120 FPS Hot-Path Pass

- Optimized the native review app's SceneKit Cube VU path for the current 120 FPS active / 30 FPS meter-display target without changing audio, routing, telemetry ownership, physical channel order, or the production MetalKit renderer seam.
- Replaced bundled font resource discovery during label creation with direct app/resource-bundle path probes before falling back to SwiftPM bundle lookup. Sampling no longer shows the previous `Bundle.module.url` / CoreFoundation bundle directory-open stall under speaker label font resolution.
- Reduced unchanged meter-bucket work by caching Cube VU outline material keys, speaker label material keys, resolved Cube VU palette colors, Cube VU material state, and ribbed-sphere colors. Camera-only active frames inside an unchanged displayed meter bucket now avoid repeated outline, label, and rib material writes.
- Disabled SceneKit multisampling for the review viewport by setting `OrbitalViewport3DSceneView.antialiasingMode = .none`, reducing renderer-thread load while preserving the review surface and draw-on-demand contract.
- Removed unused Cube VU shader-uniform KVC writes while `OrbitalViewportCubeVUSceneKitMaterial.usesSceneKitShaderModifier == false`. The retained face texture remains the visible Cube VU surface; only direct material properties such as emission intensity, transparency, and texture assignment are updated.
- Moved the visible FPS chip from SwiftUI state into the `OrbitalViewportSceneNSView` overlay so five-per-second FPS samples no longer rebuild the full SwiftUI control surface. The FPS chip still updates in the viewport and diagnostic logging still records status transitions only.
- Added the review-only `OrbitalViewHeadlessBenchmark` executable to measure the current SceneKit review surface offscreen through Metal without opening the SwiftUI window. The benchmark reuses the same Cube VU review configuration, active/idle cadence rules, and SceneKit coordinator, and does not change speaker dimensions, Cube VU face materials, channel order, or visible controls.
- Responded to the user-reported visible `35-37 FPS` state with live samples and bounded SceneKit hot-path work while preserving the approved Cube VU speaker look. The one-node SceneKit line-outline experiment was reverted after user review because it visibly changed the Cube VU speaker outlines; the current build keeps the original twelve separate chamfered edge-box outline child nodes per speaker.
- Added or updated tests for headless benchmark configuration parity, direct font resource lookup, unchanged Cube VU outline/label material skips, resolved Cube VU palette colors, shader-disabled Cube VU material write limits, SceneKit antialiasing mode, and the SceneKit-hosted FPS meter.
- Verification: focused SceneKit/review tests passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --product OrbitalViewHeadlessBenchmark` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 169 tests and 0 failures after the headless benchmark addition, and `git diff --check` passed.
- Manual launch/sample evidence: `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt and opened the current Turbo review app. Post-KVC sample `/private/tmp/orbital-view-turbo-sample-after-kvc-skip.txt` no longer shows `setValue:forKey:` under `OrbitalViewportCubeVUSceneKitMaterial.update`. Post-FPS-chip sample `/private/tmp/orbital-view-turbo-sample-after-appkit-fps-chip.txt` shows SwiftUI `NSHostingView.layout` down from 318 samples to 15 samples over a 3-second sample, with `ps -p 72198 -o pid,pcpu,pmem,comm` reporting about `31.9%` CPU immediately afterward. User-reported visible FPS remained around `35-37 FPS`; sample `/private/tmp/orbital-view-turbo-sample-user-35fps.txt` showed the SceneKit render queue as the dominant remaining cost. The later single-line-outline sample is retained only as rejected experiment evidence and no longer describes the current visible speaker implementation.
- Headless FPS evidence: `.build/debug/OrbitalViewHeadlessBenchmark --mode both --warmup 60 --frames 300 --width 1360 --height 820 --target 120` passed with Metal access and reported `idle headless offscreen throughput: 58.1 FPS over 300 frames (scheduled 30 FPS, active target 120 FPS, 1360x820)` and `active headless offscreen throughput: 205.8 FPS over 300 frames (scheduled 120 FPS, active target 120 FPS, 1360x820)`. This proves the current review SceneKit surface can exceed the active 120 FPS offscreen target while the visible idle FPS chip is expected to sit near the 30 FPS meter-only schedule unless active motion/spin is engaged.

### Update: 2026-05-29 Graphics Performance 120/30 Cadence Package

- Added review-only SceneKit instrumentation counters for render attempts, render-scene passes, camera/grid/rib/speaker/source/fog work, display requests, frame-rate samples, Cube VU cache activity, texture assignment, and material/uniform writes. These counters are internal/test-visible only and do not write to the diagnostics log per frame.
- Added a deterministic review cadence helper and scheduler helper for active viewport, displayed meter, and inspector frame buckets. Active review motion now supports a 120 FPS target while meter material/display cadence is explicit at 30 FPS.
- Split SceneKit source update keys into pose/visibility and material cadence keys, changed speaker material keys to bucket by displayed meter cadence instead of active cadence, and prevented hidden ribbed-sphere camera motion from looping through segment material updates.
- Reduced Cube VU hot-path writes by counting cache hit/miss/generation/eviction and skipping repeated SceneKit texture assignments, uniform writes, emission intensity writes, and transparency writes when the applied value is unchanged. Camera-only active frames inside the same meter bucket no longer request Cube VU textures.
- Expanded `OrbitalViewPerformanceSettings` to accept explicit 120 FPS active viewport settings while preserving `.default` at 60/10/10. Added `.highRefreshDisplayTarget` as the 120/30/10 draw-on-demand contract.
- Updated the SwiftUI performance picker and `OrbitalViewMetalView` tests so production Metal view configuration accepts 120 FPS without forcing continuous rendering when draw-on-demand is true.
- Updated `OrbitalViewVisualTelemetryStressScene` to active=120, incoming=120, displayed meter=30, with descriptor detail `incoming=120fps; display=30fps`; the fixture still preserves 30 physical speakers, 128 objects, capped trails, and display-drop diagnostics.
- Added or updated tests for SceneKit instrumentation, 120/30 cadence buckets, speaker/source key separation, Cube VU cache/write diagnostics, camera-only active frames, meter-bucket material updates, hidden ribbed-sphere camera motion, Metal 120 FPS view configuration, retained speaker buffers, retained object buffers with 128 objects, and stress fixture target assertions.
- Verification: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 164 tests and 0 failures, and `git diff --check` passed.
- Manual smoke: the parent-folder launcher initially opened the sibling `orbital-view-with-objects` app path, so `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` was repointed to this checkout's project launcher. The ignored `.app` wrapper was copied into this checkout from the source checkout, and `./Open Orbital View Kit.command` now ad-hoc signs the refreshed app after copying the executable/resources. The fixed parent launcher rebuilt and opened the current Turbo app path, and `pgrep -fl /Contents/MacOS/OrbitalViewViewer` confirmed PID `81255` running from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`.
- Manual 120 Hz presentation has not been claimed; current evidence is source-level cadence, scheduler, retained-resource, offscreen render verification, and native app launch from this checkout.

### Update: 2026-05-29 ChatGPT Pro Graphics Performance Context Bundle

- Added `CHATGPT_PRO_GRAPHICS_PERFORMANCE_GUIDE.md` as the first-read handoff for ChatGPT Pro to write a focused graphical-performance implementation prompt.
- Added `CHATGPT_PRO_GRAPHICS_PERFORMANCE_UPLOAD_MANIFEST.md` documenting included files, exclusions, performance targets, and verification commands.
- Created `OrbitalViewKit-chatgpt-pro-graphics-performance-context-2026-05-29.zip` as an upload-ready context bundle for the current working tree.
- The guide makes the future graphics target explicit: active viewport/interaction target `120 FPS`, meter display target `30 FPS`, while noting current implementation reality still centers around `60 FPS` active motion and lower meter/inspector cadences.
- The bundle includes current docs, source, tests, OpenSpec realtime-family context, work-package context, review checklists, the browser mockup, visual media, and the Fey/DomeLab configuration reference; it excludes `.git`, `.build`, `.swiftpm`, previous zip artifacts, `dist/`, app bundles, packages, and broad generated icon batches.
- Verification: `unzip -t OrbitalViewKit-chatgpt-pro-graphics-performance-context-2026-05-29.zip` passed with no archive errors; `zipinfo -1` confirmed the guide, manifest, key source files, and visual media are present; an exclusion scan found no `.git`, `.build`, `.swiftpm`, `dist/`, prior zip, app, or pkg entries. Archive size is `8.4M`.
- Verification: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 151 tests and 0 failures, and `git diff --check` passed.

### Update: 2026-05-29 Review FPS Meter And Diagnostics Logging

- Added a review-only FPS monitor inside the SceneKit viewport coordinator so samples reflect actual review viewport render/update cadence instead of telemetry cadence.
- Added bottom-right FPS chip overlay in the review viewport. The visible chip intentionally shows only the status color dot and current `FPS` value; target/status words stay out of the viewport chrome.
- Added internal target/status constants: target `60`, below target `30..<60`, under target `<30`, and steady FPS diagnostics throttled to five samples per second with immediate status-transition entries.
- Routed FPS diagnostics through the existing capped `OrbitalViewportDiagnosticLog` with messages like `FPS 58.7 target=60 status=below target`; no saved theme/settings JSON, OSLog, or file logging was added.
- Updated SwiftUI/review tests for FPS status classification, throttled sample emission, immediate status transitions, diagnostics cap behavior, and source-level UI constants.
- Verification: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests` passed with 76 tests, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 151 tests, and `git diff --check` passed. `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt/opened the current app; `pgrep -fl OrbitalViewViewer` confirmed pid `12226`. Screenshot inspection confirmed the simplified bottom-right chip with a colored status dot and `FPS 31.1` only.

### Update: 2026-05-29 Dice Icon, Split Speaker Appearance, And Sphere Dice

- Changed the global `Roll the dice on looks` action to a centered icon-only dice button while preserving the section headline and accessibility/help text.
- Split speaker appearance palettes into `Sonic Sphere Speaker Palette` for physical speakers/app skin and `Source Speaker Palette` for source markers.
- Added persisted `sourceSpeakerRenderStyle` to review theme/settings schema `9`; older JSON without the field falls back to the decoded Sonic Sphere speaker palette.
- Extended global dice randomization to include Source Speaker Palette and every current Sphere Appearance control: ribbed sphere visibility, rib thickness, vertical ribs, horizontal rings, geodesic palette, and geodesic saturation.
- Updated SceneKit and canvas fallback source-marker rendering so source palette changes are isolated from physical speaker geometry/material, labels, grid, ribbed sphere, and meter state.
- Verification: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests` passed with 72 tests, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 147 tests, and `git diff --check` passed. `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt/opened the current app. Screenshot inspection confirmed the icon-only dice button, the separate `Sonic Sphere Speaker Palette` and `Source Speaker Palette` trays, `Sphere Geometry` / `Geodesic Appearance`, visible themed ribbed sphere, and source markers.

### Update: 2026-05-28 Review App Copy And Dice Labels

- Added a `Sound Metering Input` header above the existing top `Input` tray.
- Renamed the SpatGRIS receiver/source layout trays to `Sonic Sphere Speakers` and `Source Speakers`.
- Added tray kicker copy: `Speaker layout in SPAT XML format.` and `Source speaker layout in SPAT XML format.`
- Renamed the global dice headline/action to `Roll the dice on looks`.
- Tightened the global dice randomizer so it explicitly changes both current `Geodesic Appearance` controls: `Geodesic Palette` and `Geodesic Saturation`.
- Updated review UI inventory tests and documentation for the new copy and dice coverage.
- Verification: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests` passed with 69 tests, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 144 tests, and `git diff --check` passed. `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt/opened the current app; `pgrep -fl OrbitalViewViewer` confirmed the refreshed process. Screenshot inspection confirmed `Sound Metering Input`, `Sonic Sphere Speakers`, the speaker SPAT XML kicker, `Roll the dice on looks`, and the themed ribbed-sphere/geodesic appearance in the current app.

### Update: 2026-05-28 Deprecate Old Shell And Promote Ribbed Sphere Controls

- Removed `Hide Sphere` and the sphere/speaker sync future-work row from visible review controls; `Sphere Geometry` now owns `Ribbed Speaker Sphere`, `Rib Thickness`, `Vertical Ribs`, and `Horizontal Rings`.
- Kept `Geodesic Appearance` as the styling tray with only `Geodesic Palette` and `Geodesic Saturation`; SceneKit and canvas rib rendering now use those controls, with chromatic vertical ribs so saturation changes are visible.
- Deprecated the old imported/Fey shell from live review rendering by removing active shell state, update keys, SceneKit shell nodes, canvas shell drawing, diagnostics rows, and old shell geometry code.
- Made ribbed sphere geometry symmetrical: the fit still uses active speaker centroid plus median radius, but vertical ribs and horizontal rings are evenly spaced rather than speaker-biased.
- Bumped review settings/theme JSON schema to `8`, exports only current ribbed sphere fields, ignores legacy `hideSphereStructure` on decode, and still maps legacy `showSpeakerCenterStruts` to ribbed sphere visibility when the new key is missing.
- Updated tests for control inventory, schema/export/decode compatibility, symmetrical rib geometry, update-key isolation, SceneKit rib toggling, and SceneKit geodesic saturation material updates.
- Verification: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests` passed with 69 tests, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 144 tests, and `git diff --check` passed. `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` still delegates to the project launcher and rebuilt/opened the current app; `pgrep -fl OrbitalViewViewer` confirmed the refreshed process. Computer Use inspection confirmed `Sphere Geometry` owns the ribbed sphere controls, `Geodesic Appearance` contains only palette/saturation styling, `Hide Sphere` is absent, and dragging `Geodesic Saturation` from 27% to 99% visibly warmed the ribbed sphere.

### Update: 2026-05-28 Ribbed Speaker Sphere Overlay

- Replaced the visible `Speaker Center Struts` overlay with a default-off `Ribbed Speaker Sphere` switch under `Sphere Appearance` > `Geodesic Appearance`.
- Added review controls for `Rib Thickness`, `Vertical Ribs`, and `Horizontal Rings`, with the ribbed overlay still using the existing Geodesic palette and Geodesic Saturation controls.
- Fit the ribbed sphere from active receiver speaker centers, including imported SpatGRIS speaker layouts, using the speaker centroid plus median speaker radius and biasing rib/ring angles toward active speaker positions before filling regular rib/ring slots.
- Added SceneKit retained rib nodes plus Canvas fallback drawing from the same ribbed-sphere segment generator. `Hide Sphere` still controls only the old Fey/imported shell.
- Persisted `showRibbedSpeakerSphere`, `ribbedSphereThickness`, `ribbedSphereVerticalRibs`, and `ribbedSphereHorizontalRings` in review theme/settings JSON, bumped the review payload schema to `7`, defaulted missing fields to hidden/default controls, and kept legacy `showSpeakerCenterStruts` decode compatibility.
- Added tests for control inventory, JSON export/decode/default fallback/legacy fallback, deterministic ribbed-sphere topology, endpoint-on-fit behavior, speaker-biased rib/ring angles, update-key isolation from old shell/speaker/grid state, and SceneKit toggling/rebuilding without speaker or label rebuilds.
- Verification: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests` passed with 70 tests, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 145 tests, and `git diff --check` passed. `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt/opened the current app, `pgrep -fl OrbitalViewViewer` confirmed the refreshed process, and Computer Use visual inspection confirmed the Geodesic Appearance tray shows `Ribbed Speaker Sphere`, `Rib Thickness`, `Vertical Ribs`, and `Horizontal Rings` with the themed ribbed sphere visible around the active speaker layout.

### Update: 2026-05-28 Hide Sphere Structure By Default

- Added a review-only `Hide Sphere` switch under `Sphere Appearance` > `Sphere Geometry`, defaulting on so the current Fey geodesic shell is hidden until sphere structure and active speaker layout stay in sync.
- Kept speakers, source markers, labels, fog, ground grid, meters, and geodesic appearance palette/saturation controls available; hiding the sphere affects only shell/boundary rendering.
- Added visible tray copy: `Future work: sync sphere structure with the active speaker layout before showing the shell by default.`
- Persisted `hideSphereStructure` in review settings/theme JSON, bumped the review payload schema to `5`, and default older JSON without the field to hidden.
- Updated review-surface tests for control inventory, default and missing-field decode behavior, JSON export, update-key isolation, and SceneKit shell hide/show behavior without rebuilding speaker geometry.
- Verification: `swift test --filter OrbitalViewSwiftUITests` passed with 63 tests, `swift build` passed, `swift test` passed with 138 tests, `git diff --check` passed, and `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt/opened the current app. Computer Use inspection confirmed the geodesic shell is hidden by default, `Hide Sphere` is on under `Sphere Appearance` > `Sphere Geometry`, and the future-work note is visible.

### Update: 2026-05-28 SpatGRIS Speaker And Source Layouts

- Added the `OrbitalViewSpatGRIS` target for SpatGRIS `SPEAKER_SETUP` import/export, `SPAT_GRIS_PROJECT_DATA` source metadata import, `/spat/serv` source-position parsing, and validation diagnostics.
- Extended Core with cartesian speaker anchors, SpatGRIS coordinate metadata, layout-derived bounds helpers, and source layout/source meter frame value types.
- Added right-panel `Speaker and Source Layout` directly after `Input`, with `Speakers` and `Source` trays matching saved-theme save/refresh/load/default row behavior.
- Added review-only saved layout stores in `Speaker Layouts` and `Source Layouts`, default metadata files, no-overwrite generated names, invalid XML rows, and manual rename default recovery.
- Added review-only source project import plus `/spat/serv` OSC listening with default port `18032` and port range `1024...65535`.
- Updated SceneKit and Canvas review rendering to use imported receiver speakers, imported/live source markers, and layout-derived scene bounds while keeping sources in a separate marker layer.
- Updated tests for SpatGRIS fixture import/export/project/OSC/diagnostics, saved layout store behavior, right-panel section/tray controls, and layout-derived bounds.

### Update: 2026-05-27 Right-Panel Input And Global Dice UI

- Moved the review source controls out of the left rail and into a single expandable right-panel `Input` tray above `Roll the Dice` and `Theme`.
- Kept the left rail focused on product identity, `Camera`, and `View Detail`.
- Corrected the desktop left rail so its visible background/border fills the full window height, with top-aligned content instead of a vertically centered floating block.
- Changed the rail title from `OrbitalViewKit` to `Orbital View` and matched the Wavefield Receiver player-panel title treatment: system font, 16 pt, black weight.
- Made `Input` start with the Orbisonic-style `Telemetry`, `Local Song`, and `Impulse Test` selector and folded telemetry details, local song choose-file/transport/render-type controls, impulse pattern controls, and `Meter Source` status into that one tray.
- Added review-only telemetry advertiser handling: zero advertisers shows `No Provider`, one advertiser shows details, and multiple advertisers render selectable full-width buttons while preserving the selected advertiser by ID.
- Added a global `Roll the Dice` panel with a dice icon and full-width action button that randomizes camera/view-detail/visual tuning, fog, speaker-number visibility, palettes, ground/grid, speaker shape, label font/size, Cube VU, bloom, meter response, and performance FPS.
- Preserved Input state during global dice rolls, including source mode, telemetry advertiser selection, local song file/playback/status/render type, and impulse pattern. Saved/default theme metadata, selected speaker, and diagnostic log also remain unchanged.
- Kept the existing review settings JSON shape for the relocation; `leftPanel.audioSource` and legacy source inference remain compatible.
- Updated review-surface tests for left/right section order, Input selector/source trays, `Meter Source` placement, multi-advertiser selection, global dice ranges, dice accessibility labels, and input-state preservation.
- Verification for the latest left-rail title/height correction: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passed with 123 tests, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build` passed, `git diff --check` passed, and `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` rebuilt and opened `OrbitalViewViewer` from this checkout. `pgrep -fl OrbitalViewViewer` confirmed the refreshed process. Pixel-level visual confirmation was blocked because the captured screen was the macOS lock screen.

### Update: 2026-05-25 Fix Review Left/Right Projection And Control Axis

Status:

```text
complete
```

Changed:

- Fixed the native SceneKit review viewport projection basis so canonical `+X = right` projects to screen right and canonical `-X = left` projects to screen left.
- Routed the visible native SceneKit drag callback and the fallback drag gesture through the corrected orbit-state helper so rightward drags increase yaw and leftward drags decrease yaw.
- Left pitch coefficients, speaker fixture coordinates, canonical Z-up semantics, and the SceneKit `(x, y, z) -> (x, z, y)` coordinate bridge unchanged.

Tests added or updated:

```text
OrbitalViewSwiftUITests.testCorrectViewerProjectsCanonicalXRightToScreenRight
OrbitalViewSwiftUITests.testCorrectViewerRightwardDragMovesHorizontalOrbitRight
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 119 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command -> passed outside sandbox and opened the review app
pgrep -fl OrbitalViewViewer -> passed, running from this checkout
git diff --check -> passed
```

Documentation updated:

```text
docs/bugs.md
docs/implementation-map.md
docs/status.md
docs/test-strategy.md
```

### Update: 2026-05-25 Restore First App Icon

Status:

```text
complete
```

Changed:

- Restored the active app icon PNG and ICNS from the archived previous gradient option 02 icon.
- Replaced the active source SVG with a small wrapper that references the archived previous gradient option 02 PNG, so the tracked source now follows the active app icon again.
- Rebuilt and reopened the review app through the parent launcher.
- Verified the app bundle `AppIcon.icns` matches both the active tracked ICNS and the archived previous gradient option 02 ICNS.

Tests added or updated:

```text
No source-level behavior changed, so no tests were added.
```

Commands run:

```text
shasum -a 256 active icon assets and archived previous gradient option 02 icon assets -> matched
file dist/app-logo/OrbitalViewKit-AppIcon-1024.png dist/app-logo/AppIcon.icns dist/app-logo/OrbitalViewKit-AppIcon-source.svg -> passed
sips -g pixelWidth -g pixelHeight dist/app-logo/OrbitalViewKit-AppIcon-1024.png -> passed, 1024 x 1024
qlmanage -t -s 1024 -o /private/tmp dist/app-logo/OrbitalViewKit-AppIcon-source.svg -> passed
zsh -n "Open Orbital View Kit.command" -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 117 tests
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command -> passed, rebuilt and opened OrbitalViewViewer pid 86835
/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' app/Contents/Info.plist -> AppIcon
shasum -a 256 tracked AppIcon.icns, app-bundle AppIcon.icns, and archived previous gradient option 02 ICNS -> matched
```

Documentation updated:

```text
docs/status.md
```

Protected paths touched:

```text
none
```

### Update: 2026-05-25 Black Planet App Icon

Status:

```text
complete
```

Changed:

- Rebuilt the tracked app icon from the corrected full planet SVG geometry, preserving the thicker planet-ring cutout stroke overlays.
- Kept the final Daft Punk Bow app-icon gradient treatment on the planet logo and placed it on a black square app-icon background.
- Tightened the planet icon crop so its colored-art bounds match the previous icon's `752 x 752` scale inside the 1024 app-icon canvas.
- Updated `dist/app-logo/OrbitalViewKit-AppIcon-1024.png` and `dist/app-logo/AppIcon.icns`.
- Added `dist/app-logo/OrbitalViewKit-AppIcon-source.svg` as the tracked source for the generated icon.
- Archived the previous gradient option 02 app icon PNG and ICNS under `dist/app-logo/archive/`.

Tests added or updated:

```text
No source-level behavior changed, so no tests were added.
```

Commands run:

```text
qlmanage -t -s 1024 -o /private/tmp dist/app-logo/OrbitalViewKit-AppIcon-source.svg -> passed
pixel-bounds check against archived previous icon -> passed, both colored-art bounds `136...887` / `752 x 752`
sips iconset resizing commands -> passed
iconutil --convert icns --output dist/app-logo/AppIcon.icns /private/tmp/OrbitalViewKit-CroppedAppIcon.iconset -> passed
file dist/app-logo/OrbitalViewKit-AppIcon-1024.png dist/app-logo/AppIcon.icns -> passed
iconutil --convert iconset --output /private/tmp/OrbitalViewKit-CroppedAppIcon-verify.iconset dist/app-logo/AppIcon.icns -> passed
zsh -n "Open Orbital View Kit.command" -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 117 tests
git diff --check -> passed
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command -> passed, rebuilt and opened OrbitalViewViewer pid 73681
/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' app/Contents/Info.plist -> AppIcon
shasum -a 256 tracked AppIcon.icns and app-bundle AppIcon.icns -> matched
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 117 tests after crop adjustment
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command -> passed after crop adjustment, rebuilt and opened OrbitalViewViewer pid 78826
shasum -a 256 tracked AppIcon.icns and app-bundle AppIcon.icns -> matched after crop adjustment
```

Documentation updated:

```text
docs/implementation-map.md
docs/status.md
```

Protected paths touched:

```text
none
```

### Update: 2026-05-25 Ground Appearance Right Panel Controls

Status:

```text
complete
```

Changed:

- Moved the review-only grid controls out of left-rail `View Detail` and into a right-panel `Ground Appearance` section/tray.
- Added `Grid Spacing` tuning with a default `0.5` canonical-unit spacing, clamped to the review-only spacing range.
- Added a separate ground palette choice using the existing Orbisonic palette button style, independent from speaker and geodesic-shell palettes.
- Persisted current ground settings in top-level `groundAppearance` theme JSON while still decoding older `leftPanel.viewDetail` grid fields for compatibility.
- Updated SceneKit and SwiftUI Canvas grid drawing to use the chosen spacing and ground palette.
- Kept grid visibility, spacing, and palette in the grid-only update key so changes do not rebuild shell, speaker geometry, labels, Cube VU materials, or meter state.

Tests added or updated:

```text
Updated review UI inventory coverage for the right-panel Ground Appearance section and tray controls.
Updated settings JSON round-trip coverage for groundAppearance show/visibility/spacing/palette values.
Added backward-compatibility coverage for older themes with only leftPanel.viewDetail grid fields.
Updated grid update-key isolation coverage for spacing and ground palette changes.
Updated deterministic grid geometry coverage for default spacing, spacing range, and alternate line counts.
```

Commands:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 117 tests
git diff --check -> passed
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command -> passed, rebuilt and opened OrbitalViewViewer pid 63049
Computer Use app inspection -> passed, Ground Appearance section/tray visible on the right panel; Grid Plane toggle, Grid Visibility, Grid Spacing, Ground Palette, and Grid Size controls visible; toggle-on grid rendered in the viewport
```

### Update: 2026-05-25 Grid Visibility And 10 x 10 Ground Plane

Status:

```text
complete
```

Changed:

- Added a `Grid Visibility` slider under the left-rail `Grid Plane` toggle.
- Persisted the slider as `leftPanel.viewDetail.gridPlaneVisibilitySlider` with a missing-field default of `70`.
- Expanded the grid plane to canonical `x/y` bounds `-5...5` at `z = -1.2`, with `0.5` spacing and 42 deterministic line segments.
- Routed the visibility slider into grid opacity only for both SceneKit and the SwiftUI Canvas fallback.
- Kept grid visibility in the grid update key so slider changes do not rebuild shell, speaker geometry, labels, Cube VU materials, or meter state.

QA note:

```text
The earlier slow/choppy graphics suspicion still needs shore-power QA. Re-check Grid Plane off, default visibility, and high visibility on shore power before classifying any larger-grid behavior as a renderer performance bug.
```

Tests added or updated:

```text
Updated review UI inventory coverage for Grid Visibility.
Updated settings JSON round-trip and missing-field default coverage for gridPlaneVisibilitySlider.
Updated grid update-key isolation coverage for visibility-only changes.
Updated deterministic grid geometry coverage for halfExtent 5.0, spacing 0.5, line count 42, and default opacity mapping.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 116 tests
git diff --check -> passed
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command -> passed, rebuilt and opened OrbitalViewViewer pid 57396
Computer Use app inspection -> passed, Grid Plane default-off visible with Grid Visibility at 70%, toggle-on default visibility visible, and high visibility verified at 97%
pgrep -fl "OrbitalViewViewer|Orbital View VU" -> passed, pid 57396
```

Documentation updated:

```text
docs/bugs.md
docs/implementation-map.md
docs/status.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewReview/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-24 Optional Grid Plane For Review Viewport

Status:

```text
complete
```

Changed:

- Added a `Grid Plane` toggle to the left-rail `View Detail` controls, defaulting off.
- Persisted the toggle as `leftPanel.viewDetail.showGridPlane` with a missing-field decode default of `false` for older saved themes.
- Added SceneKit and SwiftUI Canvas fallback line-grid drawing at canonical `z = -1.2`, with half extent `1.2`, spacing `0.2`, and geodesic palette/saturation styling.
- Kept grid updates behind a separate review-only update key so toggling or restyling the grid does not rebuild speaker geometry, labels, Cube VU materials, or meter state.

QA note:

```text
Visual verification suggested the native SceneKit graphics may have looked slow or choppy after this change. This is not confirmed as a regression because the laptop may have been on low battery. Re-QA on shore power with Grid Plane off and on before classifying it as a renderer performance bug.
```

Tests added or updated:

```text
Updated review UI inventory coverage for Grid Plane under View Detail.
Updated settings JSON round-trip coverage for showGridPlane: true.
Added backward-compatible missing-field decode coverage for showGridPlane default false.
Added grid update-key isolation coverage.
Added deterministic grid geometry coverage for offset, spacing, and line count.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 116 tests
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command -> passed, rebuilt and opened OrbitalViewViewer pid 15411
Computer Use app inspection -> passed, Grid Plane visible under View Detail, confirmed default-off after clean relaunch and toggle-on visual state
pgrep -fl "OrbitalViewViewer|Orbital View VU" -> passed, pid 15411
git diff --check -> passed
```

Documentation updated:

```text
docs/bugs.md
docs/implementation-map.md
docs/status.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewReview/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-24 App Logo From Gradient Option 02

Status:

```text
complete
```

Changed:

- Promoted gradient option 02 from the Daft Punk Bow logo exploration to the review app logo.
- Added tracked app-logo artifacts under `dist/app-logo/`: `OrbitalViewKit-AppIcon-1024.png` and `AppIcon.icns`.
- Copied `AppIcon.icns` into the local review `.app` bundle's `Contents/Resources/` directory.
- Set the ignored local app bundle's `CFBundleIconFile` to `AppIcon`.
- Updated `Open Orbital View Kit.command` so future launcher refreshes keep copying `dist/app-logo/AppIcon.icns` into the app bundle and preserve the icon plist setting.

Tests added or updated:

```text
No source-level behavior changed, so no tests were added.
```

Commands run:

```text
sips/icon generation and verification commands -> generated 1024 PNG and iconset sizes
iconutil --convert iconset --output /private/tmp/OrbitalViewKit-AppIcon-verify.iconset dist/app-logo/AppIcon.icns -> passed
file dist/app-logo/AppIcon.icns -> passed
/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' app/Contents/Info.plist -> AppIcon
zsh -n "Open Orbital View Kit.command" -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 113 tests
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command -> passed outside sandbox, rebuilt and opened OrbitalViewViewer pid 11888
pgrep -fl OrbitalViewViewer -> passed, pid 11888
```

Documentation updated:

```text
docs/implementation-map.md
docs/status.md
```

Protected paths touched:

```text
none
```

### Update: 2026-05-24 Canonical Z-Up Coordinate System

Status:

```text
complete
```

Changed:

- Changed the canonical Wavefield coordinate contract to `x = right`, `y = front`, and `z = up`.
- Preserved FEY physical channel order `1...30` while validating FEY ring groups by rising canonical `z`: `1-5`, `6-10`, `11-15`, `16-20`, `21-25`, and `26-30`.
- Updated core default shell helpers so top/bottom are `+Z/-Z` and front/back are `+Y/-Y`.
- Updated Metal draw inputs so canonical `x` drives screen horizontal, canonical `z` drives screen vertical, and canonical `y` is treated as depth/front.
- Updated the SceneKit review surface and browser mockup to keep speaker data canonical Z-up and transform into Y-up renderer spaces at render boundaries.
- Replaced stale hardcoded FEY speaker copies in the native review surface and browser mockup for channels `21...30`.
- Added the durable `AGENTS.md` operating rule that canonical 3D coordinates in this repo are always Z-up.

Tests added or updated:

```text
OrbitalViewCoreTests.testWavefieldCoordinateSystemIsZUp
WavefieldSpeakerLayoutSceneAdapterTests.testFeyLayoutUsesZUpRingNumbering
Updated renderer draw-input expectations for canonical z-driven vertical projection
Updated SceneKit review impulse-pattern test to avoid the old y-up peak-channel assumption
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> initial compile error in SceneKit transform helper, fixed; rerun passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> initial review comet peak-channel assertion failed after Z-up correction, fixed; rerun passed, 113 tests
node -e 'const fs=require("fs"); const html=fs.readFileSync("mockups/orbital-view-viewport/index.html","utf8"); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]).join("\n"); new Function(scripts); console.log("inline JS parses");' -> passed
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command -> initial sandboxed run failed on SwiftPM user cache access; rerun outside sandbox passed and opened OrbitalViewViewer pid 1847
pgrep -fl OrbitalViewViewer -> passed, pid 1847
```

Documentation updated:

```text
AGENTS.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/status.md
docs/test-strategy.md
work-packages/orbital-view-kit/orbital-view-kit-codex-work-package.md
```

### Update: 2026-05-24 Latest Launcher Refresh

Status:

```text
complete
```

Changed:

- Updated `Open Orbital View Kit.command` to rebuild `OrbitalViewViewer` before launch.
- The launcher now refreshes the native review app executable and `OrbitalViewKit_OrbitalViewReview.bundle` from the current SwiftPM build output.
- Removed the stale `OrbitalViewKit_OrbitalViewSwiftUI.bundle` from the app resources during launcher refresh.
- Added a parent-folder launcher at `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command` that delegates to this checkout's project launcher.
- Updated `AGENTS.md` with the durable rule that visible review-app changes must keep the project launcher current, confirm the parent launcher still delegates to it, and launch through the parent launcher before reporting completion.

Tests added or updated:

```text
No source-level behavior changed in this slice, so no tests were added.
```

Commands run:

```text
zsh -n "Open Orbital View Kit.command" -> passed
zsh -n "/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command" -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 111 tests
"/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command" -> initial sandboxed run failed because SwiftPM could not write /Users/jeremyguillory/.cache/clang/ModuleCache; rerun outside sandbox passed and launched OrbitalViewViewer pid 90619
pgrep -fl OrbitalViewViewer -> passed, pid 90619
```

Documentation updated:

```text
AGENTS.md
docs/implementation-map.md
docs/status.md
docs/test-strategy.md
```

Protected paths touched:

```text
none
```

### Update: 2026-05-23 Final Realtime-Family Compliance Audit

Status:

```text
complete
```

Changed:

- Added `docs/realtime-family-compliance-audit.md` as the final adoption closeout record.
- Documented the inherited Realtime Audio Family Standards Package and `2026-05-23-family-standard` revision label.
- Documented target plane ownership for `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewRender`, `OrbitalViewSwiftUI`, `OrbitalViewReview`, `OrbitalViewViewerSupport`, `OrbitalViewViewer`, and test targets.
- Confirmed that Orbital View Kit owns no callback entry points and no public target is callback-safe by default.
- Confirmed review-only SceneKit, local audio, impulse, file dialog, PNG export, theme persistence, and font behavior is separated in `OrbitalViewReview`.
- Confirmed OpenSpec is active for future audio-facing, architecture-facing, and protected-path changes.
- Confirmed the Wavefield local livestream generator is a host source and profile metadata provider, not an Orbital View special audio path.
- Confirmed Orbisonic design language is the UI guideline, not Orbisonic product behavior.
- Listed remaining risks explicitly: host callback p99/deadline proof remains host-owned, downstream integrations remain future work, OpenSpec CLI validation is unavailable in this checkout, and the visual stress fixture is not exposed as a manual review-app mode yet.
- Updated architecture, contracts, implementation map, system flows, test strategy, protected paths, and status with the final compliance audit link and closeout state.
- Updated the OpenSpec proposal to point at the final compliance audit instead of leaving the activation-slice status stale.

Tests added or updated:

```text
No source-level behavior changed in this slice, so no tests were added.
```

Commands run:

```text
command -v openspec -> not available
command -v opsx -> not available
find . -maxdepth 3 -name package.json -o -name pnpm-lock.yaml -o -name package-lock.json -o -name yarn.lock -> no local JS package manager manifest found
rg -n "Realtime Family Compliance Audit|realtime-family compliance|2026-05-23-family-standard|callback entry|no callback|OrbitalViewReview|OpenSpec|local livestream generator|Orbisonic design language|callback p99|deadline|remaining risks" docs openspec/changes/adopt-realtime-family-standards -> passed
rg -n "does not claim full realtime-family compliance yet|Realtime Family Compliance Audit|docs/realtime-family-compliance-audit.md|OpenSpec CLI validation|callback p99|local livestream generator" docs openspec/changes/adopt-realtime-family-standards -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 111 tests
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/protected-paths.md
docs/realtime-family-compliance-audit.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
openspec/changes/adopt-realtime-family-standards/proposal.md
```

OpenSpec validation:

```text
not run; no openspec or opsx CLI is installed in this checkout environment. Static reference checks and full Swift verification are required for this closeout.
```

Protected paths touched:

```text
none
```

### Update: 2026-05-23 Visual Telemetry Stress Scene And Gates

Status:

```text
complete
```

Changed:

- Added `OrbitalViewVisualTelemetryStressScene` in `OrbitalViewViewerSupport`.
- Defined the display stress fixture as 30 physical speakers, 128 source objects, 16 trail points per object, 60 FPS active motion, 120 FPS incoming meter cadence, diagnostics open, and local livestream generator provenance for `32-object-should-pass-stress`.
- Added stress diagnostics that model stale display drops through overload actions only: drop stale frames, decimate display refresh, keep latest complete snapshot, and set diagnostics outside realtime.
- Added viewer-support tests for speaker identity, object identity, trail caps, local generator source metadata, faster-than-display meter cadence, and display-drop diagnostics without fabricated audio failure fields.
- Added `docs/visual-telemetry-stress-gates.md` to separate Orbital View UI/render no-backpressure gates from host callback p99/deadline gates.
- Updated architecture, contracts, implementation map, system flows, test strategy, project profile, protected paths, and OpenSpec ingress docs for the stress gate.

Tests added or updated:

```text
Tests/OrbitalViewViewerTests/OrbitalViewViewerDemoContentTests.swift
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewViewerTests -> passed, 6 tests
rg -n "Visual Telemetry Stress|visual telemetry stress|no-backpressure|p99|deadline|32-object-should-pass-stress|localLivestreamTestGenerator|dropStaleFrames|128 source objects|60 FPS|120 FPS" docs Sources Tests openspec/changes/adopt-realtime-family-standards -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 111 tests
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/project/profile.md
docs/protected-paths.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
docs/visual-telemetry-stress-gates.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-telemetry-ingress/spec.md
```

Manual visual review:

```text
not run; this slice added a source-level stress fixture and tests, but did not expose the stress scene in the visible review app.
```

Protected paths touched:

```text
none
```

### Update: 2026-05-23 Orbisonic And Splat Host Integration Profiles

Status:

```text
complete
```

Changed:

- Added `docs/integrations/orbisonic-splat-host-profiles.md` as the active Orbisonic/Splat host integration contract.
- Defined the shared host-owned preparation boundary for Orbisonic and Splat.
- Documented that Orbisonic owns playback, transport, source selection, Core Audio device I/O, route discovery, route repair, channel mapping, output routing, render/control engines, meter extraction, explicit tap-point selection, operator state, and realtime performance gates.
- Documented that Orbital View Kit receives prepared Orbisonic bus/object/speaker meter snapshots, diagnostics, and source metadata only, with `orbisonicPreparedMeterTap` provenance.
- Documented that Splat owns project/session state, authoring/edit commands, renderer-kernel analysis, neutral geometry import/export, file formats, persistence, and any eventual handoff to an audio/render host.
- Documented that Orbital View Kit may visualize Splat virtual speakers, source objects, renderer-kernel overlays, neutral geometry review, camera, selection, and diagnostics, with `splatPreparedAnalysis` provenance.
- Reinforced that Splat edit/export remains preparation/control behavior, canonical 3D coordinates must not become permanent flattened screen coordinates, and browser/DomeLab runtime code must stay out of Orbital View Kit.
- Updated the OpenSpec host-integration delta with Orbisonic profile, Splat profile, and downstream protected-path inspection requirements.

Tests added or updated:

```text
No source-level behavior changed in this slice, so no tests were added.
```

Commands run:

```text
rg -n "Orbisonic|Splat|host integration|tap point|screen coordinates|orbisonicPreparedMeterTap|splatPreparedAnalysis|DomeLab runtime" docs work-packages openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 109 tests
```

Documentation updated:

```text
docs/integrations/orbisonic-splat-host-profiles.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/project/profile.md
docs/protected-paths.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md
```

Protected paths touched:

```text
none
```

### Update: 2026-05-23 Orbisonic Design-Language Alignment

Status:

```text
complete
```

Changed:

- Added `docs/orbisonic-design-language.md` as the local UI guideline for Orbital View Kit.
- Pointed future UI work to the current Orbisonic design-language files:
  - `/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-ui-language.md`
  - `/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-palette-brief.md`
  - `/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/Orbisonic Design System Kit/design-system.md`
- Added review criteria for strict grid alignment, no page-level active-workflow scrolling, title-only headers, compact primary status UI, diagnostics for raw evidence, and no global animation timeline for static shell chrome.
- Documented that Daft Punk Bow remains display-only VU color/material behavior and the canonical Tech Rainbow successor in this kit.
- Clarified that the Orbisonic design language is a shell/layout/palette/information-hierarchy guide, not permission to import Orbisonic product semantics.
- Updated the OpenSpec review-surface delta with design-language references, criteria, and palette behavior scenarios.

Tests added or updated:

```text
No source-level constants were added in this slice, so no new static tests were required. Existing SwiftUI/review-surface tests already cover the current source-level design hooks, palette inventory, and Daft Punk Bow behavior.
```

Commands run:

```text
rg -n "orbisonic-ui-language.md|orbisonic-palette-brief.md|Orbisonic Design System Kit/design-system.md|strict grid alignment|no page-level active-workflow scrolling|title-only panel|compact status primary UI|diagnostics for raw evidence|no global animation timeline|Daft Punk Bow" docs openspec/changes/adopt-realtime-family-standards/specs/orbital-view-review-surface/spec.md Tests Sources -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 45 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 109 tests
```

Documentation updated:

```text
docs/orbisonic-design-language.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/project/profile.md
docs/protected-paths.md
docs/status.md
docs/test-strategy.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-review-surface/spec.md
```

Manual visual review:

```text
not run; this slice changed documentation and OpenSpec guidance only, with no visible UI behavior changes.
```

Protected paths touched:

```text
none
```

### Update: 2026-05-23 Wavefield Realtime Connection Specification

Status:

```text
complete
```

Changed:

- Added `docs/integrations/wavefield-realtime-connection.md` as the active Wavefield host integration contract.
- Documented that Wavefield owns external live stream parsing, the local livestream test generator, local MIDI streams, realtime event queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and performance gates.
- Documented that Orbital View Kit receives only prepared scene, speaker meter, object frame, object meter, diagnostics, and source metadata snapshots.
- Added identity mapping guidance: Wavefield object IDs remain source-object identity, speaker channels remain physical speaker identity, generator profile names stay source metadata, disappeared objects are omitted from active object snapshots, and stale display frames may be dropped.
- Added local livestream generator profile examples: `smoke`, `moving-pose`, `sustained-moving-object`, `burst-reorder`, `16-object-stress`, and `32-object-should-pass-stress`.
- Updated the OpenSpec host-integration delta with Wavefield ownership, identity mapping, generator profile, and stale-frame scenarios.

Tests added or updated:

```text
Added Core coverage for object disappear as absent active-object ownership.
Added Wavefield adapter coverage proving local livestream generator source metadata preserves physical channel identity.
```

Commands run:

```text
rg -n "import Wavefield|WavefieldReceiver|WavefieldRealtime|WavefieldPackage|WavefieldAudio|WavefieldMIDI|WavefieldOSC" Package.swift Sources Tests -> no matches, exit 1 as expected
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 109 tests
git diff --check -> passed
rg -n "Wavefield owns|local livestream test generator|smoke|moving-pose|sustained-moving-object|burst-reorder|16-object-stress|32-object-should-pass-stress|Object disappear|source metadata" docs/integrations docs/contracts.md docs/system-flows.md docs/implementation-map.md docs/test-strategy.md docs/project/profile.md docs/architecture.md openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md Tests/OrbitalViewWavefieldTests Tests/OrbitalViewCoreTests -> passed
```

Documentation updated:

```text
docs/integrations/wavefield-realtime-connection.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/project/profile.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md
```

Protected paths touched:

```text
none
```

### Update: 2026-05-22 Review App Visual Tuning Tweaks

Status:

```text
complete
```

Changed:

- Replaced the narrow orbiting-comet impulse pattern with exactly two larger comet regions, each with a wider head and longer hot VU tail.
- Applied the same two-comet shape to `Impulse Test Orbiting Comets` and audio `Excite Comets`; ripple and waves remain unchanged.
- Retuned fog so low slider values are cleaner, midpoint density is lighter, and max fog has a heavier SceneKit distance/veil effect.
- Removed the visible `Speaker Height` control from `Speaker Shape`; old saved `speakerHeight` values decode but normalize to flat review-app cube/prism geometry.
- Reworked `Label Font` into Normie, Nerd, and Nostromo groups and added a review-only `Font Size` slider saved with theme/settings JSON.
- Added local dice icon randomizers inside `Cube Surface`, `Bloom Style`, and `Meter Response`; they do not auto-save themes.
- Refreshed and relaunched the local review `.app` bundle.

Tests added or updated:

```text
SwiftUI review-app tests now assert the updated tray inventory, removed Speaker Height control, new font groups and Font Size slider, dice randomizer scope/ranges, two-comet impulse shape, Excite Comets mono-envelope behavior, fog curve tuning, label font size JSON round trips/fallback, and ignored speakerHeight geometry/material keys.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 45 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 105 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
pkill -f OrbitalViewViewer -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed
Computer Use UI smoke check -> passed, Label Font shows Font Size plus Normie/Nerd/Nostromo groups; Cube Surface, Bloom Style, and Meter Response dice controls are visible; Speaker Shape no longer exposes Speaker Height.
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/system-flows.md
docs/contracts.md
docs/test-strategy.md
docs/bugs.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-22 Speaker/Sphere Appearance And Meter Source Pass

Status:

```text
complete
```

Changed:

- Moved `Color Palette` under `Speaker Appearance`; that palette now drives speaker colors and the app skin.
- Added a separate `Sphere Appearance` section with `Sphere Geometry` and `Geodesic Appearance`.
- Moved `Geodesic Saturation` into `Geodesic Appearance` and added an independent geodesic palette using the same Orbisonic palette list as speakers.
- Moved speaker type selection out of the left rail and into the right `Speaker Shape` tray.
- Renamed `Surface Presets` to `Bloom Style` and removed `Reset Cube VU` and `Export Settings JSON`; the tray now contains only the four bloom styles.
- Expanded `Meter Source` from Music plus one impulse mode to Music, Impulse Test Ripple, Impulse Test Waves, and Impulse Test Orbiting Comets.
- Fixed the live UI issue where selecting Music could visually remain on the impulse source; the refreshed app now switches `Active Meter` to `Music source`.
- Added left-rail audio `Render Type` options: All Mono, Excite Ripple, Excite Waves, and Excite Comets. The exciter modes use the mono RMS/peak sample as an amplitude envelope over deterministic spatial patterns, avoiding FFTs, per-channel audio analysis, or extra render passes.
- Saved theme/settings JSON now includes `geodesicRenderStyle` and audio render mode while defaulting older JSON to the speaker palette and All Mono.
- Refreshed and relaunched the local review `.app` bundle.

Tests added or updated:

```text
SwiftUI review-app tests now assert the new section/tray order, removed preset controls, speaker/app palette versus geodesic palette separation, the three impulse variants, and audio-excited impulse envelopes.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 40 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 100 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
pkill -f OrbitalViewViewer -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed, relaunched as pid 14668
Computer Use UI smoke check -> passed, new sections visible, Bloom Style has only four choices, and Music switches Active Meter to Music source
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/system-flows.md
docs/contracts.md
docs/test-strategy.md
docs/bugs.md
```

### Update: 2026-05-22 Right Panel Organization Pass

Status:

```text
complete
```

Changed:

- Added right-panel section headers for `Theme`, `Speaker Appearance`, `Meter Behavior`, and `Diagnostics`.
- Renamed the review-app trays for clearer usage: `Saved Themes`, `Color Palette`, `Speaker Shape`, `Label Font`, `Cube Surface`, `Surface Presets`, `Meter Source`, `Meter Response`, `Performance`, and `Diagnostics`.
- Reordered the trays so saved theme management and color palette controls come first, speaker appearance controls stay together, meter controls stay together, and diagnostics remain last.
- Added empty `Sphere Geometry` and `Speaker Pattern` trays that expand to `Future work`.
- Removed the unavailable `City Light`, `Pump Demi`, `Eurostile Bold Extended`, and `Microgramma` font choices from the label font selector.
- Added decode fallback so saved theme/settings JSON containing one of the removed font raw values loads with `System Default` instead of failing.
- Refreshed and relaunched the local review `.app` bundle with the updated executable and SwiftUI resource bundle.

Tests added or updated:

```text
SwiftUI review-app tests now assert the new right-panel section headers, renamed tray order, future-work placeholder trays, removed font inventory, and removed-font decode fallback.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 37 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 97 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
pkill -f OrbitalViewViewer -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed, relaunched as pid 3399
Computer Use UI smoke check -> passed, section headers and renamed trays visible; Sphere Geometry expands to Future work
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/system-flows.md
docs/contracts.md
docs/test-strategy.md
```

### Update: 2026-05-22 View Theme JSON Panel

Status:

```text
complete
```

Changed:

- Added a right-panel `View Theme` tray with Save Theme, Refresh Themes, Load, and Set Default controls.
- Theme JSON files are stored under `Contents/Resources/View Themes/` in the review `.app` bundle.
- New theme saves use unique random two-word filenames such as `Turbo Comet.json`; the app displays the current filename stem after manual renames.
- Saved theme payloads include an optional stable `themeID`; default-theme metadata resolves by `themeID` first and filename fallback second so defaults survive manual renames.
- Theme load restores visual/camera/view-detail, speaker type, speaker-label font, VU drive, Cube VU preset/settings, and performance FPS.
- Theme load intentionally does not restore local audio file path, playback state, or selected speaker.
- Refreshed the local review `.app` executable/resource bundle and created the app-bundle `View Themes` directory.

Tests added or updated:

```text
SwiftUI review-app tests now assert the View Theme tray inventory, unique two-word filenames, manual rename display behavior, save/list/load JSON round trips, selected speaker-label font persistence, default-theme rename survival by themeID, and safe fallback for invalid defaults.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 36 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 96 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
mkdir -p "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/View Themes" -> passed
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
pkill -f OrbitalViewViewer -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed, relaunched as pid 97364
Computer Use UI smoke check -> passed, View Theme tray visible with save/load/default controls
find "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/View Themes" -maxdepth 1 -type f -print -> passed, found Turbo Comet.json from smoke test
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/system-flows.md
docs/contracts.md
docs/test-strategy.md
```

### Update: 2026-05-22 Jost Speaker Label 6/9 Glyph Fix

Status:

```text
complete
```

Changed:

- Replaced the bundled Jost variable font resource with the static Google Fonts regular TTF, `Jost-Regular.ttf`.
- Kept the `Jost` speaker-label setting and visible label strings unchanged.
- Switched Jost label rendering away from `SCNText` geometry and onto AppKit-generated text textures on billboard planes, because live visual inspection showed static Jost still rendered 6/9 as dot fragments through SceneKit glyph tessellation.
- Added regression coverage for speaker labels containing `6` and `9` and for the Jost texture-backed label path.

Tests added or updated:

```text
SwiftUI review-app tests now assert that the Jost label font uses Jost-Regular.ttf, uses the texture-backed SceneKit label path, and preserves readable two-digit labels for channels 06, 09, 16, and 29.
```

Commands run:

```text
curl -s https://fonts.googleapis.com/css2?family=Jost:wght@400 -> passed, found the static Jost Regular TTF URL
file Sources/OrbitalViewSwiftUI/Resources/Fonts/Jost[wght].ttf -> passed, confirmed the old bundled Jost file was a variable font
curl -L -o Sources/OrbitalViewSwiftUI/Resources/Fonts/Jost-Regular.ttf https://fonts.gstatic.com/s/jost/v20/92zPtBhPNqw79Ij1E865zBUv7myjJQVG.ttf -> passed
rm Sources/OrbitalViewSwiftUI/Resources/Fonts/Jost[wght].ttf -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> failed initially because a stale SwiftPM resource bundle still contained the removed variable font
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift package clean -> passed with SwiftPM user-cache warnings
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 31 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 91 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
rm -rf "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed, removed stale merged app resource bundle before recopying
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
find "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -maxdepth 1 -type f -print -> passed, confirmed Jost-Regular.ttf is present and Jost[wght].ttf is absent
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
pkill -f OrbitalViewViewer -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed, relaunched as pid 79286
Computer Use visual inspection -> failed, running app still showed Jost 6/9 as dot fragments through SCNText
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests/testCorrectViewerJostUsesStaticRegularFontForReadableSixAndNine -> passed after adding texture-backed Jost label path
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
pkill -f OrbitalViewViewer -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed, relaunched as pid 89276
Computer Use visual inspection -> passed, Jost selected and labels containing 6/9 render as full numerals instead of dot fragments
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 91 tests
```

Documentation updated:

```text
docs/status.md
docs/bugs.md
docs/implementation-map.md
docs/test-strategy.md
```

### Update: 2026-05-22 Alien / Nostromo Speaker Label Fonts

Status:

```text
complete
```

Changed:

- Added grouped Speaker Labels sections for Current, Bundled, Alien / Nostromo, and Installed / Licensed.
- Added bundled Alien/Nostromo-inspired label fonts: Archivo Black, Jost, Michroma, and Sevastopol Interface.
- Added install-only exact commercial selectors for Helvetica Black, Futura, City Light, Pump Demi, Eurostile Bold Extended, and Microgramma; missing fonts save normally and render with System Default.
- Kept the SceneKit label rendering path and label-only rebuild behavior intact.

Tests added or updated:

```text
SwiftUI review-app tests now assert grouped font inventory, bundled font resource resolution, install-only fallback behavior, settings JSON round trips for every font case, and label-only rebuild behavior.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 30 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 90 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
pkill -f OrbitalViewViewer -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed, relaunched as pid 71533
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

### Update: 2026-05-22 Minecraft Speaker Label Zero Glyph Fix

Status:

```text
complete
```

Changed:

- Added a Minecraft-only speaker-label display fallback so zeroes render as readable round glyphs instead of colon-like glyphs in SceneKit.
- Kept all other speaker label fonts on normal numeric two-digit labels.
- Preserved channel identity; this only changes the visible `SCNText` string for the Minecraft label font.

Tests added or updated:

```text
SwiftUI review-app tests now assert the Minecraft label font maps displayed zeroes to `O` while System Default, Press Start 2P, and Chintzy CPU BRK keep numeric zeroes.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 28 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 88 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
pkill -f OrbitalViewViewer -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed, relaunched as pid 62868
```

Documentation updated:

```text
docs/status.md
docs/bugs.md
```

### Update: 2026-05-22 Speaker Label Font Resource Lookup Fix

Status:

```text
complete
```

Changed:

- Fixed speaker label font resource lookup so bundled fonts resolve from the SwiftPM resource bundle root as well as a `Fonts` subdirectory.
- Added regression coverage that verifies Press Start 2P, Minecraft, and Chintzy CPU BRK resolve to their actual `NSFont` PostScript names instead of silently falling back to the system font.

Tests added or updated:

```text
SwiftUI review-app tests now assert bundled speaker label font resource URLs and resolved NSFont names.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 27 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 87 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
pkill -f OrbitalViewViewer -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed, relaunched as pid 59433
```

Documentation updated:

```text
docs/status.md
docs/bugs.md
```

### Update: 2026-05-22 Speaker Label Font Selector

Status:

```text
complete
```

Changed:

- Added a right-panel `Speaker Labels` tray after `Speaker Geometry`.
- Added System Default, Press Start 2P, Minecraft, and Chintzy CPU BRK speaker-number label font options.
- Bundled font files and source/license notes as `OrbitalViewSwiftUI` SwiftPM resources and registered them offline through CoreText.
- Added `speakerLabelFont` to the settings JSON export payload.
- Split speaker label geometry rebuilds from shell and speaker body geometry rebuilds so font-only changes rebuild only `SCNText` labels.
- Documented that manual `.app` refresh/package steps must copy `OrbitalViewKit_OrbitalViewSwiftUI.bundle` into `Contents/Resources/`.

Tests added or updated:

```text
SwiftUI review-app tests now assert the Speaker Labels tray inventory, font options, settings JSON export field, label-only geometry key behavior, and SceneKit label rebuild counters.
```

Commands run:

```text
curl -L https://raw.githubusercontent.com/google/fonts/main/ofl/pressstart2p/PressStart2P-Regular.ttf -> passed
curl -L https://raw.githubusercontent.com/google/fonts/main/ofl/pressstart2p/OFL.txt -> passed
curl -L https://dl.dafont.com/dl/?f=minecraft -> passed
curl -L https://dl.dafont.com/dl/?f=chintzy_cpu_brk -> passed
unzip Minecraft.ttf, chintzy.ttf, chintzys.ttf, chintzycpu.txt -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 26 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 86 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
ditto .build/arm64-apple-macosx/debug/OrbitalViewKit_OrbitalViewSwiftUI.bundle "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Resources/OrbitalViewKit_OrbitalViewSwiftUI.bundle" -> passed
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 README Media Gallery

Status:

```text
complete
```

Changed:

- Added the two desktop PNG captures to `docs/media/orbital-view-vu-1.0/`.
- Added a repo-friendly H.264 MP4 demo derived from the desktop screen recording because the original MOV is 176 MB.
- Added a README `Visuals` section with inline screenshots, an embedded demo video element for GitHub rendering, and a direct fallback demo-video link.

Tests added or updated:

```text
none; documentation/media-only change
```

Commands run:

```text
cp "/Users/jeremyguillory/Desktop/Screenshot 2026-05-21 at 4.29.49 PM.png" docs/media/orbital-view-vu-1.0/orbital-view-vu-reference-ui.png -> passed
cp "/Users/jeremyguillory/Desktop/Orbital View VU Kit 2026-05-21-110651 Purple copy.png" docs/media/orbital-view-vu-1.0/orbital-view-vu-purple-cube-vu.png -> passed
ffmpeg -y -i "/Users/jeremyguillory/Desktop/Screen Recording 2026-05-21 at 5.12.52 PM.mov" -vf "scale=1920:-2" -c:v libx264 -preset slow -crf 28 -pix_fmt yuv420p -movflags +faststart -an docs/media/orbital-view-vu-1.0/orbital-view-vu-1.0-demo.mp4 -> passed
ffprobe docs/media/orbital-view-vu-1.0/orbital-view-vu-1.0-demo.mp4 -> passed
git diff --check -> passed
```

Documentation updated:

```text
README.md
docs/status.md
```

### Update: 2026-05-21 README 1.0 Positioning

Status:

```text
complete
```

Changed:

- Updated the README opening to position Orbital View VU as a high-performance native macOS 3D spatial VU meter for monitoring and authoring spatial music.
- Documented that it was written for the author's own workflow while originally targeting SonicSphere.

Tests added or updated:

```text
none; documentation-only change
```

Commands run:

```text
not run; documentation-only change
```

Documentation updated:

```text
README.md
docs/status.md
```

### Update: 2026-05-21 Full Left Panel Settings JSON Export

Status:

```text
complete
```

Changed:

- Expanded settings export to schema version 2.
- Added a `leftPanel` export block covering audio source mode/file metadata/play state, camera view, yaw, pitch, zoom, spin, adjusted-camera state, speaker type, speaker size/fog sliders and resolved values, speaker numbers, hidden lines, and selected channel.
- Kept existing top-level theme, Cube VU, drive, preset, and performance fields so the exported tuning state remains easy to inspect.

Tests added or updated:

```text
SwiftUI review-app settings JSON tests now assert schema version 2 and round-trip the full left-panel export block.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 24 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 84 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer" -> passed
plutil -lint "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist" -> passed
open "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app" -> passed, relaunched as pid 35979
git diff --check -> passed
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Exported Settings As Review App Defaults

Status:

```text
complete
```

Changed:

- Made `Orbital View VU Kit Settings 2026-05-21-171537.json` the pinned startup default for the SceneKit review app.
- Startup now defaults to Purple, Cube VU, Hot Core Bloom, impulse test drive, geodesic saturation `0`, 86% pixel fill, 0% surface checker opacity, cube outline strength `0.64`, and 60 fps active motion.
- Kept the Core `OrbitalViewportCubeVUSettings.default` contract unchanged; the exported look is stored as explicit review-app defaults on `OrbitalViewportMockup`.

Tests added or updated:

```text
SwiftUI review-app tests now assert every startup default value from the exported settings payload.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 24 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 84 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer -> passed
plutil -lint Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist -> passed
git diff --check -> passed
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> passed, relaunched as pid 31771
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Geodesic Saturation Theme Control

Status:

```text
complete
```

Changed:

- Added `Geodesic Saturation` to the SceneKit review app's `Orbisonic Theme` tray.
- The low end desaturates only the geodesic shell struts/nodes to grayscale; the high end restores the selected theme color.
- Routed the control through the shell update key and settings JSON export so speaker and Cube VU material updates stay independent.

Tests added or updated:

```text
SwiftUI review-app tests now assert the theme tray control inventory, exported geodesic saturation value, grayscale desaturation behavior, shell-key invalidation, and unchanged speaker material key.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 23 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 83 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer -> passed
plutil -lint Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist -> passed
git diff --check -> passed
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> passed, relaunched as pid 23132
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Cube VU Pixel Fill And Checker Opacity Controls

Status:

```text
complete
```

Changed:

- Added `Pixel Fill` to the SceneKit review app's `Surface + Bloom` tray so Cube VU face pixels can tune from the older separated-pixel look to the new edge-to-edge reference-like surface.
- Added `Surface Checker Opacity` to fade the idle/unlit checkerboard without changing face pixel count, bloom, or meter response.
- Kept both controls material/texture-only so slider changes do not rebuild speaker geometry.

Tests added or updated:

```text
SwiftUI review-app tests now assert the new Surface + Bloom control inventory, default Pixel Fill and Surface Checker Opacity values, separated-pixel recovery at 50% fill, and checkerboard muting at 0% opacity.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 22 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 82 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer -> passed
plutil -lint Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist -> passed
git diff --check -> passed
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> passed, relaunched as pid 16420
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Gapless Cube VU Face Checkerboard

Status:

```text
complete
```

Changed:

- Removed the generated face-texture tile inset so Cube VU face pixels draw edge-to-edge without dark gaps between tiles.
- Disabled antialiasing during face texture generation so the pixel grid stays crisp.
- Made the idle/unlit Cube VU surface read as a pixel checkerboard by keeping an explicit checker contrast floor even when the user-facing checker slider is low.

Tests added or updated:

```text
SwiftUI review-app tests now sample the generated idle face texture to assert adjacent tiles differ and the shared tile edge does not collapse into a dark gap.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 21 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 81 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer -> passed
plutil -lint Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist -> passed
git diff --check -> passed
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> passed, relaunched as pid 6201
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Cube VU Presets, Sphere Impulse Drive, And Settings Export

Status:

```text
complete
```

Changed:

- Reorganized the SceneKit review app right panel into Orbisonic Theme, VU Drive, Speaker Geometry, Meter Calibration, Surface + Bloom, Presets, Graphical Performance versus CPU Load, and Debug + Diagnostics trays.
- Added a `VU Drive` tray with mutually exclusive Music and Impulse Test modes. Music uses the existing local-audio/fake-meter source, while Impulse Test takes meter focus and drives all speakers with a deterministic sphere-ripple pattern across the Sonic Sphere surface.
- Added Cube VU preset selection for Soft Center Bloom, Hot Core Bloom, Halo Edge Bloom, and Block Center Bloom without adding the old four-up preview.
- Added a Rim Halo Edge control in Surface + Bloom, preserved no face-phase-stagger control, moved Idle Tint into Surface + Bloom, and limited the review-app face-pixel control to the visually useful 6...14 range.
- Added `Export Settings JSON` to the Presets tray. The export records the active Orbisonic theme, speaker type, VU drive, Cube VU preset, Cube VU settings, and performance cadence settings.
- Expanded the hidden-by-default Debug + Diagnostics tray with raw RMS, raw peak, calibrated RMS, display scalar, hot scalar, and the selected/peak diagnostic channel.

Tests added or updated:

```text
SwiftUI review-app tests now assert the new right-panel tray inventory, Cube VU preset names, deterministic spatial impulse pattern, raw/display diagnostic scalar separation, Rim Halo Edge material contract, and settings JSON payload contents.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 20 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 80 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer -> refreshed app executable
plutil -lint Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist -> passed
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> launched refreshed native review app
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Orbisonic Family Theme Tray Consolidation

Status:

```text
complete
```

Changed:

- Removed the duplicate `Color Scheme` section from the left rail so the left rail now stays focused on Song Audio Source, Camera, Speaker Type, and View Detail.
- Expanded the right `Orbisonic Theme` tray from the four local review colors to the Orbisonic family palette set sourced from `orbisonic-palette-brief`: Purple, Flamingo, Green, B&W, Daft Punk Bow, Rack Mint, Rack Pink, Rack Blue, Ember Console, Graphite, Flamingo Green, and Dusty Rose.
- Replaced the system segmented picker with full-width Orbisonic-style theme buttons with fixed-height rows, compact subtitles, active borders, and palette swatches.
- Routed review-app shell, panels, controls, fog, labels, speaker colors, Cube VU ramps, hot color, and outline color through the selected palette.
- Made the Cube Outline edge bars thinner and less opaque so the strongest setting reads as a delicate cube edge treatment rather than a heavy cage.

Tests added or updated:

```text
SwiftUI review-app tests now assert the left rail no longer includes Color Scheme, the theme tray uses full-width Orbisonic theme buttons, the expanded palette list is present, and cube outline constants stay delicate.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 17 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 77 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer -> refreshed app executable
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> launched refreshed native review app
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Orbisonic Theme And Cube Outline Controls

Status:

```text
complete
```

Changed:

- Added an `Orbisonic Theme` tray at the top of the right tuning panel so Purple, Flamingo, Green, and B&W can drive shell, viewport, and Cube VU color treatment from one review-app theme picker.
- Changed local audio Play and Pause controls to side-by-side transport icon buttons while keeping `Choose File` at the top of the left rail.
- Routed Cube VU face colors, hot colors, fog, shell accents, labels, and selection color through the selected theme instead of a fixed Daft Punk Bow-only ramp in the SceneKit review surface.
- Added a `Cube Outline` slider in `Speaker VU`; `0.00` hides the retained cube-edge nodes and `1.00` draws clear edge outlines along the cube speaker edges.
- Kept the cube outline and theme changes material-only so meter/theme/outline ticks do not rebuild speaker body geometry or the shell.

Tests added or updated:

```text
SwiftUI review-app tests now assert the Orbisonic Theme tray exists, transport uses icon buttons, Cube Outline defaults to zero, and outline/theme tuning stays outside speaker geometry rebuild keys.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 17 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 77 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer -> refreshed app executable
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> launched refreshed native review app
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Cube VU Face Grid Visibility Fix

Status:

```text
complete
```

Changed:

- Removed the separate oversized Cube VU halo `SCNBox` child nodes that created an unintended cubical fog aura around speakers.
- Added a retained 9x9 pixelated face texture cache to the SceneKit Cube VU material path and applied the texture to the actual six `SCNBox` cube faces instead of overlaying a separate plane.
- Increased only the Cube VU speaker visual scale relative to Prism/Sphere so the default 9x9 face has enough screen pixels to read.
- Kept meter changes material-only: Cube VU meter updates swap retained texture/material state and do not rebuild speaker geometry.

Tests added or updated:

```text
SwiftUI review-app tests now assert Cube VU uses retained face textures on actual cube faces, caps the texture cache, and does not use a separate halo node or front-face overlay plane.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 17 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 77 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer -> refreshed app executable
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> launched refreshed native review app
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
docs/bugs.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 SceneKit Review Cleanup And Cube VU 9x9 Face Bloom

Status:

```text
complete
```

Changed:

- Moved `Song Audio Source` to the top of the left rail and split the transport into side-by-side `Play` and `Pause` buttons.
- Kept the left rail focused on Audio Source, Camera, Color Scheme, Speaker Type, and View Detail.
- Moved active tuning trays to the right panel and removed the old Scene summary, selected-speaker copy, and 30-channel VU list from that panel.
- Hid object overlay, trails, glow trails, and bounds trays for this review pass without deleting object contracts.
- Kept the single visible Motion FPS selector in Graphical Performance vs CPU Load.
- Added a capped diagnostic log in Debug + Diagnostics for discrete UI/audio/export events.
- Added a SceneKit Cube VU material path that quantizes cube-face UVs into a 9x9 grid, uses the Core `SpeakerCubeVUScalars` display/hot/palette values, and drives a retained pixelated face texture cache so the cube faces remain visibly tiled at small speaker sizes.

Tests added or updated:

```text
SwiftUI review-app tests now cover the left/right panel inventory, inactive object trays, top audio transport, removed right-panel cards, Cube VU shader/texture defaults, retained face texture cache, and diagnostic log cap.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 16 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 76 tests
cp .build/arm64-apple-macosx/debug/OrbitalViewViewer Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/MacOS/OrbitalViewViewer -> refreshed app executable
plutil -lint Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist -> passed
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> launched refreshed native review app
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Corrected VU Kit SceneKit Geodesic Viewer

Status:

```text
complete
```

Changed:

- Repointed `OrbitalViewViewer` at the confirmed native SceneKit `OrbitalViewportMockup` surface instead of the rejected bare MTKView demo.
- Gave the window a deliberately verbose identity: `Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail, Right Inspector, Motion FPS Toggle, Full-Window PNG Export, and Cube VU Speaker Surface`.
- Preserved the existing Camera, Color Scheme, Speaker Shape, and View Detail rail sections, then added matching collapsible tuning trays below View Detail.
- Added local review controls for Cube VU calibration, bloom/surface, object overlay, trails, glow trails, fixed `-5...+5` bounds, performance-vs-CPU load, presets, and diagnostics.
- Fed SceneKit speaker material updates through the shared `SpeakerCubeVUScalars` contract and kept speaker height as a geometry-only rebuild trigger.

Files changed:

```text
.gitignore
Sources/OrbitalViewSwiftUI/OrbitalViewportMockup.swift
Sources/OrbitalViewViewer/OrbitalViewViewer.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
Correct viewer identity and SceneKit/geodesic contract.
Existing viewport controls remain intact.
Tuning tray inventory.
Cube VU defaults match the Core scalar contract.
Meter-only ticks do not rebuild shell or speaker geometry.
Material-only tuning and geometry tuning are separated.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 14 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 74 tests
plutil -lint Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app/Contents/Info.plist -> passed
open Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail.app -> launched
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
Corrected the viewer identity mismatch that launched the rejected bare MTKView demo instead of the confirmed SceneKit geodesic app.
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

Risks:

```text
The SceneKit review app uses a fake meter stream and local tuning controls for visual review. Production hosts still own real meter and object frame input.
```

### Update: 2026-05-21 Speaker Type Cube VU Option And Tray Hit Targets

Status:

```text
complete
```

Changed:

- Renamed the review-app rail section from `Speaker Shape` to `Speaker Type`.
- Added `Cube VU` as a third speaker type beside `Prism` and `Sphere`.
- Kept `Prism` as the default, while `Cube VU` uses square cube speaker geometry and the same Cube VU scalar/material path.
- Replaced tiny disclosure-only tray activation with full-width tray header buttons, matching the OrbiSonic collapsible-tray interaction pattern.

Tests added or updated:

```text
Updated SwiftUI review-app tests for the three speaker types, full-width tray hit-target pattern, and Cube VU geometry-key separation.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests
```

Documentation updated:

```text
docs/status.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Local Audio File Meter Input For Review App

Status:

```text
complete
```

Changed:

- Added an `Audio Source` rail section to the confirmed SceneKit review app.
- Added `Choose File` and `Play`/`Pause` controls using native macOS local audio file playback.
- Added a local-audio meter source that reduces file metering to one mono RMS/peak sample and applies that sample equally to all speakers.
- Kept fake meters as the fallback when no file is loaded; loaded-but-paused local audio reports silence.
- Kept the meter read path pulled by the SceneKit render cadence rather than publishing per-frame SwiftUI state.

Tests added or updated:

```text
Added equal-mono local audio meter conversion coverage for dB-to-display scalar, averaged RMS, and max peak.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests -> passed, 15 tests
```

Documentation updated:

```text
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Cube VU Speaker Merge With Collapsible Tuning Trays

Status:

```text
complete
```

Changed:

- Added `OrbitalViewPerformanceSettings` with adaptive 30/60 active-motion FPS, meter-only cadence, inspector cadence, and draw-on-demand controls.
- Wired `OrbitalViewMetalView` to apply MTKView `preferredFramesPerSecond`, `enableSetNeedsDisplay`, and `isPaused` from performance settings.
- Extended `OrbitalView` with host-bindable object visual settings and performance settings while preserving value-based compatibility initializers.
- Replaced the single VU settings disclosure body with collapsible trays for Speaker VU, Meter Calibration, Surface + Bloom, Object Overlay, Trails, Bounds, Graphical Performance vs CPU Load, Presets, and Debug + Diagnostics.
- Updated the demo viewer to pass live object/performance bindings into the existing wrapper rather than creating a new app surface.

Files changed:

```text
Sources/OrbitalViewCore/OrbitalViewPerformanceSettings.swift
Sources/OrbitalViewSwiftUI/OrbitalView.swift
Sources/OrbitalViewSwiftUI/OrbitalViewMetalView.swift
Sources/OrbitalViewViewer/OrbitalViewViewer.swift
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
docs/status.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
```

Tests added or updated:

```text
OrbitalViewPerformanceSettings defaults and validation.
OrbitalView binding initializer for object/performance settings.
MTKView adaptive FPS and draw-on-demand configuration.
Updated SwiftUI renderer configuration tests for performance settings.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 68 tests
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

Risks:

```text
The demo viewer still uses generated demo meter/object frames for review. Production hosts remain responsible for real meter/object timing and should drive updates without per-frame SwiftUI root animation.
```

### Update: 2026-05-21 Deprecate Native Cube VU Chat Work

Status:

```text
complete
```

Changed:

- Killed the running `OrbitalViewViewer` process from this repository.
- Marked all native Cube VU merge and viewer-target work produced in this chat as deprecated.
- Added an explicit deprecation record so the next pass can start over without treating the current work as active direction.

Files changed:

```text
docs/status.md
docs/deprecated/native-cube-vu-chat-work.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
none
```

Commands run:

```text
pgrep -fl OrbitalViewViewer -> found PID 95449
kill 95449 -> passed
pgrep -fl OrbitalViewViewer -> no running viewer
```

Documentation updated:

```text
docs/status.md
docs/deprecated/native-cube-vu-chat-work.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Risks:

```text
Deprecated implementation files still exist in the worktree until an explicit cleanup or revert task removes them.
```

### Update: 2026-05-21 Native Cube VU Viewer Target

Status:

```text
complete
```

Changed:

- Added `OrbitalViewViewer`, a small native SwiftUI executable that hosts the production `OrbitalView` MTKView path.
- Added `OrbitalViewViewerSupport` with deterministic 30-speaker cube scene data, demo speaker meter frames keyed by physical channel, dynamic object frames, object meters, and viewer visual defaults.
- Added an inspector side panel for selected speaker/channel diagnostics and demo data-source context while preserving the Cube VU settings tray below the viewport.

Files changed:

```text
Package.swift
Sources/OrbitalViewViewer/
Sources/OrbitalViewViewerSupport/
Tests/OrbitalViewViewerTests/
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
OrbitalViewViewerDemoContentTests cover one cube per speaker, physical channel order, demo meter coverage, object frame/meter identity, and viewer visual defaults.
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 65 tests
```

Documentation updated:

```text
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none - the viewer consumes OrbitalViewSwiftUI but does not edit protected renderer/UI source
```

Risks:

```text
The viewer uses deterministic demo data only. It is a native review surface, not a host audio or downstream app integration.
```

### Update: 2026-05-21 Native Cube VU Merge

Status:

```text
complete
```

Changed:

- Ported Sonic Sphere cube speaker shapes, cube/prism Metal instancing, Daft Punk Bow/palette settings, visual presets, sanitized meter diagnostics, dynamic object frames/meters, and retained renderer buffer paths from Orbital View VU Kit.
- Added browser cube scalar settings to the native contract: input calibration, level compression, display ceiling, hot response, hot threshold, hot fill strength, palette drive, idle tint, checker contrast, and face pixels.
- Updated the Metal speaker material payload so raw RMS remains raw while display VU scalar, hot scalar, and palette heat are display-only values.
- Added a SwiftUI Cube VU settings and diagnostics tray with host meter/object source indicators and selected-speaker scalar readouts.

Files changed:

```text
Sources/OrbitalViewCore/
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewWavefield/
Tests/OrbitalViewCoreTests/
Tests/OrbitalViewRenderTests/
Tests/OrbitalViewSwiftUITests/
Tests/OrbitalViewWavefieldTests/
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
docs/contracts.md
```

Tests added or updated:

```text
cube VU scalar math, default/range validation, one cube/prism mesh per speaker, channel order preservation, material scalar payloads, meter-only geometry stability, dynamic object frame/meter rendering, SwiftUI settings forwarding, Wavefield sanitized meters
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 61 tests
```

Documentation updated:

```text
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
docs/contracts.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

Risks:

```text
The standalone SceneKit viewer from Orbital View VU Kit was intentionally not ported. No native app launcher exists in this destination package, so visual verification was limited to Metal offscreen smoke/pixel-probe tests.
```

### Update: 2026-05-21 ChatGPT Pro Architecture Context Bundle

Status:

```text
complete
```

Changed:

- Added `CHATGPT_PRO_ARCHITECTURE_BRIEF.md` at the project root.
- Created `OrbitalViewKit-chatgpt-pro-architecture-context.zip` as a compact ChatGPT Pro planning bundle.
- Framed the next renderer architecture brainstorm around 30/52 physical speakers, per-speaker VU animation, up to 128 moving objects, fog, visual polish, and 60 FPS Metal performance.

Files changed:

```text
CHATGPT_PRO_ARCHITECTURE_BRIEF.md
docs/status.md
OrbitalViewKit-chatgpt-pro-architecture-context.zip
```

Tests added or updated:

```text
none - planning brief and bundle only
```

Commands run:

```text
unzip -l OrbitalViewKit-chatgpt-pro-architecture-context.zip -> passed, 78 files listed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
```

Documentation updated:

```text
docs/status.md
CHATGPT_PRO_ARCHITECTURE_BRIEF.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Risks:

```text
The zip is a planning snapshot; regenerate it after any source or docs changes before giving it to another model.
```

### Update: 2026-05-19 Project Initiation

Status:

```text
complete after baseline commit
```

Changed:

- Root project-control scaffold created.
- Active docs customized for OrbitalViewKit.
- Work package and first slice docs created.

Files changed:

```text
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
docs/
.tasks/
work-packages/orbital-view-kit/
.gitignore
```

Tests added or updated:

```text
none - scaffold only
```

Commands run:

```text
swift build -> not run during scaffold initiation; package did not exist yet
swift test -> not run during scaffold initiation; package did not exist yet
```

Documentation updated:

```text
docs/status.md
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/bugs.md
docs/decisions/0001-initial-architecture.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
Project is ready for the first bounded OrbitalViewCore implementation task.
```

Risks:

- Downstream Wavefield adapter placement still depends on inspecting the actual Wavefield package.
- Production renderer backend was not yet selected at this point; later resolved by Decision 0002.

Next recommended task:

```text
.tasks/001-orbital-view-core-foundation.md
```

### Update: 2026-05-19 OrbitalViewCore Foundation

Status:

```text
complete
```

Changed:

- Added Swift package manifest.
- Added pure `OrbitalViewCore` target.
- Added value types and validation for coordinate systems, vectors, shell geometry, speakers, meters, camera, selection, scene specs, and scene builders.
- Added XCTest coverage for validation, meter channel identity, 30-speaker identity/order, and center-locked camera presets.

Files changed:

```text
Package.swift
Sources/OrbitalViewCore/
Tests/OrbitalViewCoreTests/
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
.tasks/001-orbital-view-core-foundation.md
work-packages/orbital-view-kit/MV.md
work-packages/orbital-view-kit/slices/001-orbital-view-core-foundation.md
manifest.json
```

Tests added or updated:

```text
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
```

Commands run:

```text
swift build -> passed with Command Line Tools XCTest path warning
swift test -> failed before compiling tests because XCTest was unavailable from Command Line Tools
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 8 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
OrbitalViewCore foundation is implemented and verified.
```

Risks:

- Wavefield layout adapter still requires downstream package inspection.
- Renderer backend remains intentionally deferred.

Next recommended task:

```text
Plan the Wavefield layout adapter or renderer visual mockup as a new bounded task.
```

### Update: 2026-05-19 Wavefield Layout JSON Adapter

Status:

```text
complete
```

Changed:

- Inspected the Wavefield package read-only at `/Users/jeremyguillory/Documents/vibecode projects/wavefield osx`.
- Added `OrbitalViewWavefield` as a local adapter target.
- Added `WavefieldSpeakerLayoutSceneAdapter` to convert Wavefield speaker-layout JSON into `OrbitalViewCore` scenes.
- Copied the real Fey 30 fixture into the test bundle.
- Added tests for channel order, labels, coordinates, caller-provided shell use, unsupported axes, invalid speaker count, and invalid direction rejection.

Files changed:

```text
Package.swift
Sources/OrbitalViewWavefield/
Tests/OrbitalViewWavefieldTests/
.tasks/002-wavefield-layout-json-adapter.md
work-packages/orbital-view-kit/slices/002-wavefield-layout-json-adapter.md
docs/status.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/test-strategy.md
manifest.json
```

Tests added or updated:

```text
Tests/OrbitalViewWavefieldTests/WavefieldSpeakerLayoutSceneAdapterTests.swift
Tests/OrbitalViewWavefieldTests/Fixtures/fey-30-layout.json
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 13 tests
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
Fixed test resource lookup after SwiftPM flattened the processed fixture path.
```

Protected paths touched:

```text
none
```

Result:

```text
Wavefield Fey layout JSON maps into an OrbitalViewCore monitor scene without channel reorder.
```

Risks:

- This adapter reads Wavefield JSON shape directly; a future downstream package adapter may still be useful when integrating with Wavefield types.
- Meter snapshot adaptation remains a separate decision.

Next recommended task:

```text
Choose renderer visual mockup, renderer backend decision, or Wavefield meter-frame adapter.
```

### Update: 2026-05-19 Wavefield Meter Frame Adapter

Status:

```text
complete
```

Changed:

- Added `WavefieldMeterChannelFrame` DTO.
- Added `WavefieldMeterFrameAdapter`.
- Mapped Wavefield-style channel/rms/peak records into `SpeakerMeterFrame`.
- Added duplicate-channel, invalid-channel, non-finite-level, and clip-threshold tests.

Files changed:

```text
Sources/OrbitalViewWavefield/WavefieldMeterFrameAdapter.swift
Tests/OrbitalViewWavefieldTests/WavefieldMeterFrameAdapterTests.swift
.tasks/003-wavefield-meter-frame-adapter.md
work-packages/orbital-view-kit/slices/003-wavefield-meter-frame-adapter.md
docs/status.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/test-strategy.md
manifest.json
```

Tests added or updated:

```text
Tests/OrbitalViewWavefieldTests/WavefieldMeterFrameAdapterTests.swift
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 17 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
Wavefield-style meter frames map into OrbitalViewCore SpeakerMeterFrame without channel reorder.
```

Risks:

- This is a local DTO adapter, not a direct import of Wavefield package types.
- Full app-level VUMeterSnapshot adaptation remains out of scope.

Next recommended task:

```text
Renderer visual mockup or renderer backend decision.
```

### Update: 2026-05-19 Orbital Viewport Visual Mockup

Status:

```text
complete
```

Changed:

- Added a disposable static HTML/CSS/JS mockup for the OrbitalViewKit monitor viewport.
- Added fake Fey-style speaker positions with animated fake meter glow, rings, labels, and selection state.
- Added camera preset controls, reset, projection toggle, structure/speaker/label/cutaway toggles, and an inspector panel.
- Added mockup notes capturing product questions and Swift implementation implications.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
.tasks/004-orbital-viewport-visual-mockup.md
work-packages/orbital-view-kit/slices/004-orbital-viewport-visual-mockup.md
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
```

Tests added or updated:

```text
none - static mockup and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 17 tests
```

Documentation updated:

```text
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
mockups/orbital-view-viewport/notes.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
Renderer-facing behavior can be reviewed visually without committing to Swift renderer code yet.
```

Risks:

- The mockup uses fake positions and fake meters, so it is interaction guidance only.
- Production renderer backend was not yet selected at this point; later resolved by Decision 0002.

Next recommended task:

```text
Renderer backend decision, now complete, or first native OrbitalViewSwiftUI/Metal prototype slice.
```

### Update: 2026-05-19 Renderer Backend Decision

Status:

```text
complete
```

Changed:

- Added `docs/decisions/0002-renderer-backend.md`.
- Accepted MetalKit / MTKView as the production renderer backend.
- Documented `OrbitalViewRender` as the future renderer target and `OrbitalViewSwiftUI` as the wrapper layer.
- Rejected WebView, DomeLab code import, SceneKit-first, and RealityKit-first as long-term renderer paths.
- Updated active architecture, contract, flow, test, status, and work-package docs.

Files changed:

```text
docs/decisions/0002-renderer-backend.md
.tasks/005-renderer-backend-decision.md
work-packages/orbital-view-kit/slices/005-renderer-backend-decision.md
docs/status.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/product-brief.md
work-packages/orbital-view-kit/MV.md
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
```

Tests added or updated:

```text
none - decision/documentation slice only
```

Commands run:

```text
manifest parse -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 17 tests
```

Documentation updated:

```text
docs/decisions/0002-renderer-backend.md
docs/status.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/product-brief.md
work-packages/orbital-view-kit/MV.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
Renderer backend is no longer open-ended; future production renderer work should start with a MetalKit / MTKView target seam.
```

Risks:

- MetalKit is more engineering work than SceneKit or a browser prototype.
- First renderer source slice should stay compile-focused to avoid overbuilding.

Next recommended task:

```text
Minimal OrbitalViewRender target seam, now complete.
```

### Update: 2026-05-19 OrbitalViewRender Target Seam

Status:

```text
complete
```

Changed:

- Added `OrbitalViewRender` package product and target.
- Added `OrbitalViewRendering`, `OrbitalViewRenderState`, and `OrbitalViewMetalRenderer`.
- Added an `MTKViewDelegate` seam without production drawing.
- Kept scene, meter, camera, and selection update paths separate.
- Added renderer seam tests for revision separation, event emission, and MTKView delegate conformance.

Files changed:

```text
Package.swift
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
.tasks/006-orbital-view-render-target-seam.md
work-packages/orbital-view-kit/slices/006-orbital-view-render-target-seam.md
docs/status.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/product-brief.md
work-packages/orbital-view-kit/MV.md
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
```

Tests added or updated:

```text
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

Commands run:

```text
manifest parse -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 20 tests
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/product-brief.md
work-packages/orbital-view-kit/MV.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewRender/ allowed by this slice
Tests/OrbitalViewRenderTests/ allowed by this slice
```

Result:

```text
OrbitalViewRender now has a compile-focused MetalKit seam with state/event tests, but no production drawing yet.
```

Risks:

- The renderer is currently a no-op `MTKViewDelegate`; draw-loop behavior remains unimplemented.
- The next source slice should avoid pulling SwiftUI, audio, or host-app dependencies into `OrbitalViewRender`.

Next recommended task:

```text
Compile-only OrbitalViewSwiftUI wrapper skeleton, now complete, or first Metal draw-loop implementation plan.
```

### Update: 2026-05-19 OrbitalViewSwiftUI Wrapper Skeleton

Status:

```text
complete
```

Changed:

- Added `OrbitalViewSwiftUI` package product and target.
- Added public `OrbitalView` SwiftUI view.
- Added internal `OrbitalViewMetalView` `NSViewRepresentable` bridge around `MTKView`.
- Added coordinator logic that applies scene, meter, camera, and selection configuration into `OrbitalViewMetalRenderer`.
- Added SwiftUI wrapper tests for initialization, duplicate-update suppression, meter-only update behavior, and camera/selection event emission.

Files changed:

```text
Package.swift
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
.tasks/007-orbital-view-swiftui-wrapper-skeleton.md
work-packages/orbital-view-kit/slices/007-orbital-view-swiftui-wrapper-skeleton.md
docs/status.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/product-brief.md
work-packages/orbital-view-kit/MV.md
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
```

Tests added or updated:

```text
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
```

Commands run:

```text
manifest parse -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 23 tests
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/product-brief.md
work-packages/orbital-view-kit/MV.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/ allowed by this slice
Tests/OrbitalViewSwiftUITests/ allowed by this slice
```

Result:

```text
OrbitalViewSwiftUI now exposes a compile-only SwiftUI wrapper around the MetalKit renderer seam, with tests, but no controls or gestures yet.
```

Risks:

- The wrapper currently bridges state into a no-op renderer delegate.
- Camera gestures, picking, inspector controls, and draw-loop behavior remain unimplemented.

Next recommended task:

```text
Renderer test harness plan, first Metal draw-loop implementation plan, or SwiftUI control/gesture binding plan.
```

### Update: 2026-05-19 Renderer Test Harness Plan

Status:

```text
complete
```

Changed:

- Added `docs/renderer-test-harness.md`.
- Defined renderer harness layers from contract tests through offscreen smoke tests, invariant tests, pixel probes, and optional interactive harness.
- Defined first Metal draw-loop acceptance criteria.
- Updated active test strategy, system flows, implementation map, status, and work-package docs.

Files changed:

```text
docs/renderer-test-harness.md
.tasks/008-renderer-test-harness-plan.md
work-packages/orbital-view-kit/slices/008-renderer-test-harness-plan.md
docs/status.md
docs/test-strategy.md
docs/system-flows.md
docs/implementation-map.md
work-packages/orbital-view-kit/MV.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
```

Tests added or updated:

```text
none - planning/documentation slice only
```

Commands run:

```text
manifest parse -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 23 tests
```

Documentation updated:

```text
docs/renderer-test-harness.md
docs/status.md
docs/test-strategy.md
docs/system-flows.md
docs/implementation-map.md
work-packages/orbital-view-kit/MV.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
The first Metal draw-loop implementation now has explicit verification criteria before code starts.
```

Risks:

- Offscreen Metal tests can be machine-dependent; future tests must skip clearly when no Metal device is available.
- Full-frame snapshots are intentionally deferred until the visual design stabilizes.

Next recommended task:

```text
First Metal draw-loop implementation plan or offscreen renderer smoke tests.
```

### Update: 2026-05-19 Offscreen Renderer Smoke Test

Status:

```text
complete
```

Changed:

- Added `OrbitalViewMetalDrawPipeline` with a minimal Metal render pipeline.
- Added `OrbitalViewMetalRenderer.draw(in:)` command encoding for `MTKView`.
- Added an internal offscreen renderer helper that renders to a BGRA texture and reads pixels back for tests.
- Rendered fixed-size speaker quads from scene speaker anchors.
- Applied meter values to color/intensity without resizing speaker geometry.
- Added an XCTest smoke test that asserts a deterministic scene produces non-clear pixels, with a clear skip when no Metal device exists.

Files changed:

```text
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewRender/OrbitalViewMetalRenderer.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
.tasks/009-offscreen-renderer-smoke-test.md
work-packages/orbital-view-kit/slices/009-offscreen-renderer-smoke-test.md
docs/status.md
docs/architecture.md
docs/contracts.md
docs/renderer-test-harness.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
```

Tests added or updated:

```text
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 24 tests
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/contracts.md
docs/renderer-test-harness.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewRender/ allowed by this slice
Tests/OrbitalViewRenderTests/ allowed by this slice
```

Result:

```text
OrbitalViewRender can now issue a minimal Metal draw command and prove non-empty offscreen output without opening a host app window.
```

Risks:

- Current drawing is only a smoke baseline: fixed-size speaker quads, no shell geometry, no production camera projection, no labels, and no hit testing.
- Metal availability remains machine-dependent; the test skips clearly when no Metal device exists.

Next recommended task:

```text
Renderer invariant tests or pixel-probe renderer tests.
```

### Update: 2026-05-19 Renderer Invariant Tests

Status:

```text
complete
```

Changed:

- Added internal static speaker draw-input snapshots.
- Separated static draw inputs from meter color inputs for testability.
- Added tests proving meter-only updates leave speaker ID, channel, projected position, and quad radius unchanged.
- Added tests proving camera-only updates leave static speaker draw inputs unchanged.
- Added tests proving renderer draw inputs preserve ID/channel order and stable quad dimensions.

Files changed:

```text
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
.tasks/010-renderer-invariant-tests.md
work-packages/orbital-view-kit/slices/010-renderer-invariant-tests.md
docs/status.md
docs/architecture.md
docs/contracts.md
docs/renderer-test-harness.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/product-brief.md
work-packages/orbital-view-kit/MV.md
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
```

Tests added or updated:

```text
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/contracts.md
docs/renderer-test-harness.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewRender/ allowed by this slice
Tests/OrbitalViewRenderTests/ allowed by this slice
```

Result:

```text
Renderer tests now prove meter and camera updates do not mutate static speaker draw inputs or physical channel identity.
```

Risks:

- Current invariant tests compare static draw-input values, not Metal buffer rebuild counters. Explicit buffer/cache assertions should wait until static Metal buffers exist.

Next recommended task:

```text
Pixel-probe renderer tests or renderer static buffer/cache plan.
```

### Update: 2026-05-19 Fey Sphere Coordinate Acceptance

Status:

```text
complete
```

Changed:

- Accepted the pasted Fey 30 raw speaker coordinates as the current canonical Fey sphere geometry source.
- Historical note: this accepted the Fey 30 raw coordinates before the 2026-05-24 Z-up contract change superseded the axis semantics.
- Confirmed the existing `Tests/OrbitalViewWavefieldTests/Fixtures/fey-30-layout.json` positions are the raw coordinates projected radially onto the unit sphere.
- Preserved one-based speaker channel order `1...30` with no position-based reordering.

Files changed:

```text
docs/status.md
```

Tests added or updated:

```text
none - existing adapter tests already cover Fey 30 loading, channel order, labels, fixture directions, and invalid non-unit directions
```

Commands run:

```text
node coordinate verification -> passed, 30 coordinates, max fixture delta 4.440892098500626e-16
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
```

Documentation updated:

```text
docs/status.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
The existing Fey 30 fixture is accepted as the normalized unit-sphere form of the pasted canonical raw speaker coordinates.
```

Risks:

- The source raw coordinates are recorded in conversation context, while the repository fixture stores normalized unit-sphere positions for loader validation.

Next recommended task:

```text
Pixel-probe renderer tests or renderer static buffer/cache plan.
```

### Update: 2026-05-19 DomeLab Control Panel Mockup

Status:

```text
complete
```

Changed:

- Replaced the browser mockup's top toolbar with a full-height left control rail modeled on DomeLab's 3D Model panel.
- Added Plan, Elevation, Isometric, Reset, Spin, Export PNG, Projection, Display, Front hemisphere only, and Fog density controls.
- Matched DomeLab-style drag and spin direction, reset-to-current-preset behavior, axonometric projection, front-hemisphere clipping, fog depth fading, display palettes, and canvas PNG export.
- Kept the change limited to the disposable mockup and notes; no Swift, renderer, or package interface changed.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
docs/status.md
```

Tests added or updated:

```text
none - static mockup behavior and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
headless Playwright layout render -> passed, rail height 900px at 1440x900 viewport, canvas 900x854
headless Playwright control interaction/export check -> passed, no page errors, PNG filename orbital-view-isometric-axonometric.png
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
```

Documentation updated:

```text
docs/status.md
mockups/orbital-view-viewport/notes.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
fixed mockup layout overflow caught during headless render verification
```

Protected paths touched:

```text
none
```

Result:

```text
The browser mockup now mirrors the requested DomeLab 3D Model control panel on the left side of the screen.
```

Risks:

- The mockup still uses fake meter animation and canvas approximations; production SwiftUI/Metal control and renderer behavior remains deferred.

Next recommended task:

```text
Open a protected SwiftUI control-surface slice when production controls should move beyond the mockup.
```

### Update: 2026-05-19 Mockup Drag Axis And Front-Half Boundary

Status:

```text
complete
```

Changed:

- Swapped only the mockup's vertical pointer-drag pitch mapping; horizontal yaw behavior is unchanged.
- Added a structure-style circular boundary around the visible sphere edge when `Front hemisphere only` is enabled.
- Kept the boundary tied to the same viewport sphere radius and zoom scale used for projected structure geometry.
- Kept the work limited to the disposable browser mockup and docs; no Swift renderer, SwiftUI wrapper, public API, or protected source path changed.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
docs/status.md
```

Tests added or updated:

```text
none - static mockup behavior and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
Chrome visual review -> passed, front-half boundary visible in Green, Pink, and B&W styles; vertical drag moved the sphere and changed the camera label to adjusted
```

Documentation updated:

```text
docs/status.md
mockups/orbital-view-viewport/notes.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
The live browser mockup now has the requested vertical drag behavior and front-half sphere-edge boundary.
```

Risks:

- This remains a browser mockup with fake meter animation; production SwiftUI/Metal drag and shell-boundary behavior remains deferred.

Next recommended task:

```text
Open a protected SwiftUI control-surface slice when production controls should move beyond the mockup.
```

### Update: 2026-05-19 Mockup Palette And Speaker Size Controls

Status:

```text
complete
```

Changed:

- Moved the mockup Display palette onto shared UI tokens so Green, Pink, and B&W theme the left rail, buttons, sliders, right inspector, status bar, meter bars, and viewport.
- Added a `Speaker size` slider with a `1.35x` default and `0.75x...2.25x` range.
- Applied speaker size to both sphere radius and prism geometry while leaving fake RMS/peak values responsible only for glow, color, and meter fill.
- Changed prism geometry to a 2:1:1 visual cabinet proportion, with the long axis following the local tangential arc and the two short dimensions kept equal.
- Kept the work limited to the disposable browser mockup and docs; no Swift renderer, SwiftUI wrapper, public API, or protected source path changed.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
none - static mockup behavior and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
node Playwright availability check -> unavailable in this checkout
Chrome visual review -> passed; Green, Pink, and B&W themed the full UI; Prism showed 2:1:1 cabinets; Speaker size changed to 2.25x; Front hemisphere and existing display/shape controls worked
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
```

Documentation updated:

```text
docs/status.md
mockups/orbital-view-viewport/notes.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
fixed mockup Display palette not applying to the full UI surface
```

Protected paths touched:

```text
none
```

Result:

```text
The browser mockup now applies Display color changes across the whole UI and supports larger 2:1:1 prism speaker cabinets.
```

Risks:

- This remains a browser mockup with fake meter animation and canvas approximations; production SwiftUI/Metal controls and cabinet rendering remain deferred.

Next recommended task:

```text
Open a protected SwiftUI control-surface slice when production controls should move beyond the mockup.
```

### Update: 2026-05-19 Mockup Axonometric Prism Clipping

Status:

```text
complete
```

Changed:

- Removed the browser mockup's Projection picker and deleted the perspective projection state path.
- Made viewport projection always axonometric/orthographic while preserving Plan, Elevation, and Isometric camera presets.
- Replaced the prior prism approximation with an 8-vertex rectangular-prism cuboid using 2:1:1 length/width/height proportions.
- Oriented each prism with its long axis along the local tangential sphere direction, its radial short axis outward, and its second short axis from the orthogonal cross product.
- Clipped prism faces against the front-hemisphere plane so cabinets transition by visible faces instead of disappearing as whole center-point objects.
- Kept the work limited to the disposable browser mockup and docs; no Swift renderer, SwiftUI wrapper, public API, or protected source path changed.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
none - static mockup behavior and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
node mockup structure assertions -> passed, Projection/perspective state absent and cuboid clipping code present
Chrome visual review -> passed for no Projection picker, Green/Pink/B&W full-surface palettes, 3D cuboid prism rendering, and front-hemisphere clipping state; deeper gesture clicking was limited by Chrome tab-focus instability
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
```

Documentation updated:

```text
docs/status.md
mockups/orbital-view-viewport/notes.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
fixed mockup prism speakers reading as flat 2D shapes
fixed front-hemisphere prism popping by clipping prism faces instead of filtering whole speakers by center depth
```

Protected paths touched:

```text
none
```

Result:

```text
The browser mockup has no perspective option and renders prism speakers as true 3D cuboids with face-level front-hemisphere clipping.
```

Risks:

- This remains a browser mockup with fake meter animation and canvas approximations; production SwiftUI/Metal cuboid clipping remains deferred.

Next recommended task:

```text
Open a protected SwiftUI/Metal renderer slice when production cuboid speaker rendering should move beyond the mockup.
```

### Update: 2026-05-19 Mockup Labels Hidden Lines Fog Controls

Status:

```text
complete
```

Changed:

- Added a `Speaker numbers` checkbox that hides or shows viewport labels without changing speaker selection or inspector behavior.
- Replaced `Front hemisphere only` with a switch-style `Hidden Lines` control using positive semantics: on shows hidden/back-half lines, off hides them.
- Reordered the lower control panel so `Speaker size` and `Fog density` sit together, followed by `Speaker numbers`, with `Hidden Lines` last.
- Strengthened depth fog so `Fog density` at 100 hides back-half structure and speakers similarly to turning `Hidden Lines` off.
- Made B&W speaker labels black and moved speaker-number text farther from spheres and prism cuboids.
- Kept the work limited to the disposable browser mockup and docs; no Swift renderer, SwiftUI wrapper, public API, or protected source path changed.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
none - static mockup behavior and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
node mockup structure assertions -> passed, Projection/perspective and Front hemisphere state absent; Speaker numbers and Hidden Lines controls present
Chrome visual review -> passed for Hidden Lines switch on/off, Speaker numbers on/off, B&W black labels, prism label spacing, prism mode, and Fog density 100 hidden-line suppression
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
```

Documentation updated:

```text
docs/status.md
mockups/orbital-view-viewport/notes.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
fixed B&W speaker labels being unreadable when labels were drawn in a light color
fixed prism speaker labels overlapping cuboids by moving labels farther from speaker geometry
```

Protected paths touched:

```text
none
```

Result:

```text
The browser mockup now has explicit speaker-label visibility, positive Hidden Lines behavior, and stronger max-fog hidden-line suppression.
```

Risks:

- This remains a browser mockup with fake meter animation and canvas approximations; production SwiftUI/Metal hidden-line and fog behavior remains deferred.

Next recommended task:

```text
Open a protected SwiftUI/Metal renderer slice when production label and hidden-line controls should move beyond the mockup.
```

### Update: 2026-05-19 Mockup Grouped Controls And Fog Parity

Status:

```text
complete
```

Changed:

- Added a `Camera` heading above Plan, Elevation, Isometric, Reset, Spin, and Export PNG.
- Renamed the `Display` heading to `Color`.
- Added a `View Detail` heading for Speaker size, Fog density, Speaker numbers, and Hidden Lines.
- Converted `Speaker numbers` from a checkbox to a switch matching `Hidden Lines`.
- Increased control spacing in the left panel.
- Removed the hidden-depth alpha floor from speaker spheres and prism faces so mid-range fog fades hidden speaker geometry like hidden shell lines.
- Kept the work limited to the disposable browser mockup and docs; no Swift renderer, SwiftUI wrapper, public API, or protected source path changed.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
none - static mockup behavior and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
node mockup structure assertions -> passed, Camera/Color/View Detail headings and switch controls present
Chrome visual review -> passed for grouped headings, Speaker numbers switch, Hidden Lines switch, prism mode, and fog 77 shell/speaker hidden-geometry fade parity
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
```

Documentation updated:

```text
docs/status.md
mockups/orbital-view-viewport/notes.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
fixed mid-range fog fading hidden shell lines more aggressively than hidden speaker geometry
```

Protected paths touched:

```text
none
```

Result:

```text
The browser mockup now has grouped controls, switch-style speaker numbers, and matching fog fade behavior for hidden shell and speaker geometry.
```

Risks:

- This remains a browser mockup with fake meter animation and canvas approximations; production SwiftUI/Metal hidden-line and fog behavior remains deferred.

Next recommended task:

```text
Open a protected SwiftUI/Metal renderer slice when production label and hidden-line controls should move beyond the mockup.
```

### Update: 2026-05-19 Mockup Color Palette Update

Status:

```text
complete
```

Changed:

- Updated the mockup Color selector to exactly `Green`, `Flamingo`, `Purple`, and `B&W`.
- Mapped Green to the supplied Orbisonic Lab tokens across the UI shell, canvas background, shell lines, labels, glow, meter bars, buttons, panels, toolbar, status bar, and sliders.
- Added Purple using the supplied Kimi Purple tokens across the same surfaces.
- Kept Flamingo visually matched to the previous pink palette and B&W visually matched to the previous B&W palette.
- Updated Green and Purple meter threshold colors to use their palette accent/success/warning/danger colors.
- Kept the work limited to the disposable browser mockup and docs; no Swift renderer, SwiftUI wrapper, public API, or protected source path changed.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
none - static mockup behavior and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
node mockup palette assertions -> passed, Color buttons were Green, Flamingo, Purple, B&W and palette keys were green, flamingo, purple, bw
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
python3 -m http.server 8765 --bind 127.0.0.1 -> used as temporary local HTTP server for browser review, then stopped
Browser visual review -> passed for Green, Flamingo, Purple, and B&W active states, body style keys, and palette CSS variables
```

Documentation updated:

```text
docs/status.md
mockups/orbital-view-viewport/notes.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
The browser mockup now offers the requested four Color palettes in order: Green, Flamingo, Purple, and B&W.
```

Risks:

- This remains a browser mockup with fake meter animation and canvas approximations; production SwiftUI/Metal palette support remains deferred.

Next recommended task:

```text
Open a protected SwiftUI/Metal renderer slice when production palette controls should move beyond the mockup.
```

### Update: 2026-05-19 Mockup Defaults And Slider Scale Update

Status:

```text
complete
```

Changed:

- Reordered the mockup Color buttons to `Purple`, `Flamingo`, `Green`, and `B&W`, with Purple as the default active palette.
- Reordered Speaker Shape to `Prism`, then `Sphere`, with Prism as the default.
- Set Speaker size to default at the slider midpoint, mapping midpoint to 1.95x, left edge to half size, and right edge to double size.
- Kept Fog density defaulting to 38 while remapping the slider so the previous 30-density look is at the midpoint.
- Defaulted Speaker numbers off and Hidden Lines off.
- Increased the control rail section gap slightly so the Color and View Detail sections have more breathing room.
- Kept the work limited to the disposable browser mockup and docs; no Swift renderer, SwiftUI wrapper, public API, or protected source path changed.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
none - static mockup behavior and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
node mockup defaults and slider assertions -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
node Playwright availability check -> Playwright not installed; rendered browser automation skipped
```

Documentation updated:

```text
docs/status.md
mockups/orbital-view-viewport/notes.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
The browser mockup now opens with the requested Purple/Prism/off-switch defaults and remapped slider behavior.
```

Risks:

- This remains a browser mockup with fake meter animation and canvas approximations; production SwiftUI/Metal control defaults remain deferred.
- Rendered browser automation was not available in this workspace because Playwright is not installed; verification used static DOM/script assertions plus the Swift package checks.

Next recommended task:

```text
Open a protected SwiftUI/Metal renderer slice when these controls should move beyond the mockup.
```

### Update: 2026-05-19 Mockup Fey Geodesic Shell Update

Status:

```text
complete
```

Changed:

- Replaced the mockup's generic latitude rings and spokes with a generated Fey 3V class-I icosahedron geodesic shell.
- Sourced the shell settings from `fey sphere - domelab-configuration.json`: full sphere, 7.166739952475426 m diameter, icosahedron base, frequency 3, class-I subdivision, vertex-up orientation.
- Generated 92 geodesic nodes, 270 edges, and 3 strut-length groups for the normalized viewport shell.
- Kept the geodesic as data-driven mockup behavior, not a DomeLab runtime dependency or production renderer implementation.
- Kept speakers, fake meter animation, color defaults, shape defaults, and slider behavior unchanged.

Files changed:

```text
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
```

Tests added or updated:

```text
none - static mockup behavior and docs only
```

Commands run:

```text
node inline-script parse for mockup -> passed
node Fey geodesic generator count assertion -> passed, 92 nodes, 270 edges, 3 length groups
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 27 tests
```

Documentation updated:

```text
docs/status.md
mockups/orbital-view-viewport/notes.md
docs/implementation-map.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
The browser mockup shell now uses the Fey 3V geodesic structure instead of a generic spherical grid.
```

Risks:

- This remains a browser mockup with fake meter animation and normalized unit-sphere shell coordinates; production SwiftUI/Metal geodesic import remains deferred.

Next recommended task:

```text
Open a protected SwiftUI/Metal renderer slice when the Fey geodesic shell should move beyond the mockup.
```

## Open Questions

- Exact downstream repository path for the first Wavefield integration.
- Exact production renderer drawing scope beyond the smoke baseline.

## Decision Log

- `docs/decisions/0001-initial-architecture.md`
- `docs/decisions/0002-renderer-backend.md`
- `docs/decisions/0003-realtime-audio-family-standards.md`

### Update: 2026-05-23 Realtime Family Adoption Work Package

Status:

```text
planned
```

Changed:

- Added a planning work package for adopting the Realtime Audio Family Standards as Orbital View Kit's governing architecture layer.
- Classified Orbital View Kit as Control / UI / Telemetry Plane plus Preparation Plane adapters, with no owned Realtime Plane.
- Added OpenSpec usage expectations for future audio-facing and architecture-facing changes.
- Added Orbisonic design-language guidance as the UI reference for future review-surface and host-UI work.
- Added the Wavefield local livestream test generator as a host-owned input source that Orbital View Kit should visualize through the same prepared snapshot contracts as external streams.

Files changed:

```text
work-packages/orbital-view-kit/realtime-family-adoption-work-package.md
docs/status.md
```

Tests added or updated:

```text
none - planning documentation only
```

Commands run:

```text
rg -n "Slice [0-9]+ complete\\. I'm ready to do the next slice\\.|openspec.dev|Orbisonic design language|local livestream test generator|Realtime Audio Family Standards" work-packages/orbital-view-kit/realtime-family-adoption-work-package.md docs/status.md -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 105 tests
```

Documentation updated:

```text
docs/status.md
work-packages/orbital-view-kit/realtime-family-adoption-work-package.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
The realtime-family adoption plan is now captured as a sliced work package.
```

Risks:

- This work package is planning only; the repo is not compliant until the slices are implemented and verified.
- The current review-only SceneKit/local-audio surface still needs a later boundary cleanup slice before production wrapper compliance is clean.

### Update: 2026-05-23 Realtime Family Adoption Slice 1

Status:

```text
complete
```

Changed:

- Added ADR 0003 to accept Realtime Audio Family Standards inheritance for Orbital View Kit.
- Added the required family-standard inheritance language to the architecture, contracts, protected-path, and system-flow docs.
- Documented the current plane fit as Control / UI / Telemetry Plane plus Preparation Plane adapters, with no owned Realtime Plane.
- Kept the existing measured-level-only visual contract and clarified that host apps own callback-safe bridges, realtime callbacks, routing, playback timing, MIDI, OSC, and meter extraction.
- Referenced the shared standards package path instead of copying the standards package into this repository.

Files changed:

```text
docs/architecture.md
docs/contracts.md
docs/decisions/0003-realtime-audio-family-standards.md
docs/protected-paths.md
docs/status.md
docs/system-flows.md
```

Tests added or updated:

```text
none - documentation and ADR slice only
```

Commands run:

```text
rg -n "Realtime Audio Family Standards|Bencina|callback" docs AGENTS.md -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 105 tests
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/decisions/0003-realtime-audio-family-standards.md
docs/protected-paths.md
docs/status.md
docs/system-flows.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
Slice 1 is complete. Orbital View Kit now formally inherits the Realtime Audio Family Standards in project docs without claiming full realtime compliance or changing source/API behavior.
```

Risks:

- Later slices still need OpenSpec structure, standards profile docs, boundary review, and test/stress-gate definitions.

### Update: 2026-05-23 Realtime Family Adoption Slice 2

Status:

```text
complete
```

Changed:

- Created the OpenSpec change package `openspec/changes/adopt-realtime-family-standards/`.
- Added `proposal.md`, `design.md`, and `tasks.md` for the realtime-family adoption.
- Added spec deltas for `orbital-view-realtime-boundary`, `orbital-view-telemetry-ingress`, `orbital-view-host-integration`, and `orbital-view-review-surface`.
- Each spec delta answers realtime impact, routing impact, meter source-of-truth, callback reachability, overload policy, and performance gates.
- Added an `openspec.dev` workflow note to `openspec/README.md` for future audio-facing and architecture-facing changes.

Files changed:

```text
docs/status.md
openspec/README.md
openspec/changes/adopt-realtime-family-standards/proposal.md
openspec/changes/adopt-realtime-family-standards/design.md
openspec/changes/adopt-realtime-family-standards/tasks.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-realtime-boundary/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-telemetry-ingress/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-review-surface/spec.md
```

Tests added or updated:

```text
none - OpenSpec and documentation slice only
```

Commands run:

```text
command -v openspec -> unavailable, no installed OpenSpec CLI found
rg -n "openspec.dev|adopt-realtime-family-standards|realtime-boundary" openspec docs -> passed
rg -n "Touches realtime|Touches routing|Meter source-of-truth|Callback reachability|Overload policy|Performance gates" openspec/changes/adopt-realtime-family-standards/specs -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 105 tests
```

Documentation updated:

```text
docs/status.md
openspec/README.md
openspec/changes/adopt-realtime-family-standards/
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
Slice 2 is complete. Future realtime-family adoption slices now have a concrete OpenSpec change package to implement against.
```

Risks:

- OpenSpec CLI validation was not run because the `openspec` executable is not installed in this environment.
- Later slices must keep the OpenSpec change, docs, tests, and implementation synchronized.

### Update: 2026-05-23 Realtime Family Adoption Slice 3

Status:

```text
complete
```

Changed:

- Added `docs/project/profile.md` as the Orbital View Kit family-standard project profile.
- Recorded the inherited Realtime Audio Family Standards Package revision as `2026-05-23-family-standard`.
- Added product identity, app type, backend choice, library/review executable shape, sample-rate and block-size ownership, channel/routing ownership, event/control sources, telemetry outputs, stress scenes, and overload policy.
- Added a target-by-target plane map for package libraries, review executable/support target, and test targets.
- Added a callback inventory stating Orbital View Kit owns no callback entry points.
- Added the callback-adjacent warning that host apps must not call Orbital View Kit from audio callbacks or callback-reachable functions.
- Explicitly stated production `OrbitalViewSwiftUI` and `OrbitalViewRender` are not callback-safe APIs.

Files changed:

```text
docs/project/profile.md
docs/status.md
```

Tests added or updated:

```text
none - documentation and project profile slice only
```

Commands run:

```text
rg -n "callback entry|Realtime Plane|Control / UI / Telemetry|Preparation Plane" docs/project docs -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 105 tests
```

Documentation updated:

```text
docs/project/profile.md
docs/status.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
none
```

Result:

```text
Slice 3 is complete. A future reviewer can classify every package target from the project profile without reading source code.
```

Risks:

- The profile documents current ownership boundaries only; later source movement and stress gates still need their own slices.

### Update: 2026-05-23 Realtime Family Adoption Slice 4

Status:

```text
complete
```

Changed:

- Added the `OrbitalViewReview` library target for review/demo-only tooling.
- Moved `OrbitalViewportMockup` and its bundled font resources from `Sources/OrbitalViewSwiftUI/` into `Sources/OrbitalViewReview/`.
- Updated `OrbitalViewViewer` to import `OrbitalViewReview` instead of the production SwiftUI wrapper.
- Kept `OrbitalViewSwiftUI` focused on `OrbitalView`, `OrbitalViewMetalView`, host bindings, the MetalKit bridge, and production-safe tuning controls.
- Kept the existing review-surface tests in `OrbitalViewSwiftUITests`, now importing the separate review target for `OrbitalViewportMockup` assertions.
- Updated contracts, architecture, implementation map, system flows, test strategy, protected paths, project profile, and status to document the production/review split.

Files changed:

```text
Package.swift
Sources/OrbitalViewReview/
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewViewer/OrbitalViewViewer.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/project/profile.md
docs/protected-paths.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
```

Tests added or updated:

```text
Updated SwiftUI/review test imports so production wrapper tests exercise OrbitalViewSwiftUI and review-surface tests exercise OrbitalViewReview.
```

Commands run:

```text
rg -n "AVFoundation|SceneKit|NSOpenPanel|AVAudioPlayer|FileManager|PNG|theme" Sources/OrbitalViewSwiftUI -> passed, no production SwiftUI matches
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 105 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run OrbitalViewViewer -> first sandboxed launch failed on user clang cache permissions; escalated launch built and started the executable, then was stopped with Ctrl-C
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/project/profile.md
docs/protected-paths.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
Fixed the production wrapper boundary by removing review-only AVFoundation, SceneKit, local file playback, PNG export, theme persistence, and font-resource ownership from OrbitalViewSwiftUI.
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewReview/
Tests/OrbitalViewSwiftUITests/
```

Result:

```text
Slice 4 is complete. Production OrbitalViewSwiftUI no longer imports AVFoundation or SceneKit, while review-only behavior remains available through OrbitalViewReview and OrbitalViewViewer.
```

Risks:

- `OrbitalViewSwiftUITests` still covers both production wrapper and review target behavior; a future cleanup could split review tests into a dedicated `OrbitalViewReviewTests` target if the suite becomes harder to scan.
- Existing historical status entries still reference the old `OrbitalViewKit_OrbitalViewSwiftUI.bundle`; current implementation-map instructions now use `OrbitalViewKit_OrbitalViewReview.bundle`.

### Update: 2026-05-23 Realtime Family Adoption Slice 5

Status:

```text
complete
```

Changed:

- Added `OrbitalViewTelemetrySourceKind`, `OrbitalViewTelemetrySourceDescriptor`, and `OrbitalViewTelemetryOverloadAction` to `OrbitalViewCore`.
- Added source descriptors to `SpeakerMeterFrame` and `ObjectMeterFrame`, with source defaults of `speakerBus` and `objectBus`.
- Added supported source labels for speaker bus, object bus, final output, hardware tap, local livestream test generator, external Wavefield stream, Orbisonic prepared meter tap, Splat prepared analysis, review local audio, and synthetic visual stress.
- Added allowed overload diagnostics for dropped stale frames, decimated display refresh, latest complete snapshot retention, and diagnostics set outside realtime.
- Updated `WavefieldMeterFrameAdapter` so Wavefield-style meters default to `.externalWavefieldStream`.
- Updated viewer demo speaker/object meters so deterministic review fixtures are labeled `.syntheticVisualStress`.
- Updated OpenSpec and project docs to define latest-complete-frame-wins display telemetry, allowed display drops/decimation, and forbidden callback/display backpressure behavior.

Files changed:

```text
Sources/OrbitalViewCore/OrbitalViewTelemetrySource.swift
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewCore/OrbitalViewObjects.swift
Sources/OrbitalViewCore/OrbitalViewMeterInput.swift
Sources/OrbitalViewWavefield/WavefieldMeterFrameAdapter.swift
Sources/OrbitalViewViewerSupport/OrbitalViewViewerDemoContent.swift
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Tests/OrbitalViewWavefieldTests/WavefieldMeterFrameAdapterTests.swift
Tests/OrbitalViewViewerTests/OrbitalViewViewerDemoContentTests.swift
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/project/profile.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-telemetry-ingress/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-review-surface/spec.md
```

Tests added or updated:

```text
Added targeted Core tests for telemetry source labels, source descriptor validation, diagnostics overload actions, and legacy diagnostics decoding. Updated Wavefield and viewer demo tests for source descriptors.
```

Commands run:

```text
rg -n "OrbitalViewTelemetrySource|Telemetry source|latest-complete|drop stale|local livestream test generator|Orbisonic prepared meter tap|Splat prepared analysis|raw packets" Sources Tests docs openspec/changes/adopt-realtime-family-standards -> passed
git diff --check -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 107 tests
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/project/profile.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-telemetry-ingress/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-host-integration/spec.md
openspec/changes/adopt-realtime-family-standards/specs/orbital-view-review-surface/spec.md
```

Bugs found or fixed:

```text
Fixed the provenance gap where displayed speaker/object meter frames could carry levels without saying which source-of-truth produced them.
```

Protected paths touched:

```text
none
```

Result:

```text
Slice 5 is complete. Displayed meter frames now carry source descriptors, and Orbital View Kit's lossy display overload policy is explicit in source contracts, tests, OpenSpec, and docs.
```

Risks:

- This slice adds metadata to public frame structs while preserving existing initializer call sites through defaults; downstream code that constructs frames positionally should still compile, but source-aware host integrations should now pass explicit descriptors.
