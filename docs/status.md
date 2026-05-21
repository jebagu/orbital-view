# Project Status

## Current Phase

```text
snappier native SwiftUI/SceneKit viewer Slice 015 complete
```

## Current Milestone

```text
Native continuation through Slice 015 is complete; the standalone SwiftPM app opens the approved Orbisonic-design-language native 3D Orbital View VU Kit screen with throttled inspector-only SwiftUI refresh, adaptive draw-on-demand SceneKit, cached SceneKit update paths, and a release-built app bundle by default
```

## Summary

Orbital View VU Kit now has `OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewOrbisonic`, an `OrbitalViewRender` MetalKit renderer seam with an offscreen-tested instanced cube/prism speaker draw path, static draw-input invariant tests, static geometry cache-key tests, channel-to-instance mapping tests, retained speaker/object buffer reuse checks, shader-side cube scalar center-bloom speaker materials, legacy checker pulse/ring/diagonal wave VU settings, platform-neutral theme tokens, Daft Punk Bow VU palette/color-scheme migration through renderer ramp uniforms, runtime meter input sanitizing and diagnostics, Codable visual presets, Sonic Sphere cube/prism speaker shape contracts, face-center VU bloom distance contracts, and host source-object overlay contracts, plus an `OrbitalViewSwiftUI` wrapper with an opt-in collapsed bottom VU settings tray. The tray has Basic, Advanced, Presets, and Diagnostics sections, including speaker height, optional preset-store actions, and sanitizer diagnostics display without making persistence mandatory for hosts. `OrbitalViewSwiftUI` also includes `OrbitalViewportMockup`, a native SwiftUI/SceneKit 3D review screen with Orbisonic-design-language native controls, fixed left/right rails, Fey 30 speaker list, fake meter stream, camera controls, color schemes, speaker shape, speaker size, fog density, speaker numbers, hidden lines, selection, spin, zoom, drag orbit, and PNG export. The standalone screen keeps the browser mockup only as a loose behavior/control-inventory reference, not as a pixel-for-pixel skin target. Its SwiftUI shell no longer uses a root animation timeline; the inspector/meter list owns its own 10 fps refresh subview, while SceneKit owns fake meter/spin animation with draw-on-demand rendering, a 30 fps cap for spin/active motion, and a 10 fps meter-only idle cadence. SceneKit shell geometry is built once, speaker nodes rebuild only on shape/size changes, and camera, shell, speaker visibility/material, and fog updates are keyed separately. The app-bundle builder now defaults to a release configuration for local review. `OrbitalViewViewer` launches that native 3D screen as `Orbital View VU Kit.app`. `OrbitalViewWavefield` exposes a runtime-safe sanitized Wavefield meter adapter. `OrbitalViewOrbisonic` defines the package-level Orbisonic seam from `renderer/output monitor -> 30 channel VU records -> SpeakerMeterFrame -> OrbitalView`, exposes Daft Punk Bow through `OrbisonicOrbitalColorScheme`, and avoids importing the Orbisonic app. The renderer maps 30 physical speaker channels from `SpeakerMeterFrame.levelsByChannel` without channel reorder, applies RMS to center fill/body glow, peak to halo/ring intensity, clip to hot flash, accepts active object frames and object meter frames keyed by source-object ID, and keeps static geometry stable under meter, settings, camera, object meter, and trail updates. The project also has renderer test harness and cache-plan docs, disposable browser mockups for the orbitable spherical monitor viewport and a single-screen Sonicsphere cube scalar VU tuner with browser-only tab/local-file audio analysis, a separate normal music meter, and tabbed tuning/export controls, an accepted MetalKit / MTKView production renderer backend decision, and an accepted canonical raw-coordinate basis for the Fey 30 sphere fixture. Production Metal parity for this standalone SceneKit screen, downstream host wiring, live object smoothing/interpolation beyond static viewer snapshots, and Splat host integration remain deferred.

The root launcher `Open Orbital View Kit.command` opens the live mockup file with a cache-busting URL so browser reloads pick up current file changes.

The root launcher `Open Native Orbital View VU Kit.command` builds a local `Orbital View VU Kit.app` bundle and opens it.

The older root launcher `Open Orbital View Viewer.command` now opens the same `Orbital View VU Kit.app` bundle for compatibility.

### Update: 2026-05-21 Snappier Native SwiftUI SceneKit Viewer

Status:

```text
complete
```

Changed:

- Added Slice 015 task/slice docs to explicitly permit the standalone SwiftUI/SceneKit performance follow-up.
- Removed the root `TimelineView(.animation)` driver from `OrbitalViewportMockup`.
- Added explicit cadence constants: 30 fps for active SceneKit viewport animation, 10 fps for meter-only SceneKit idle drawing, and 10 fps for SwiftUI inspector/meter-list refresh.
- Moved the 10 fps inspector/meter-list timer into an inspector-only subview so the root control rail, footer, and viewport wrapper are not invalidated by meter-list ticks.
- Moved spin and fake-meter frame progression into `OrbitalViewport3DSceneView.Coordinator` through `frameConfiguration(timeMS:)`.
- Changed the SceneKit view to draw on demand with `rendersContinuously = false`, `isPlaying = false`, and `preferredFramesPerSecond = 30`.
- Added a coordinator-owned capped timer that requests SceneKit renders directly while fake meters/spin are active in the review screen, with meter-only idle frames throttled below the 30 fps active-motion cap.
- Wrapped SceneKit camera/material/fog updates in disabled implicit transactions so per-frame changes do not queue SceneKit animations.
- Added retained SceneKit update keys for camera, shell, speaker geometry, speaker visibility, speaker material, and fog.
- Kept shell geometry built once and speaker nodes rebuilt only when speaker shape or speaker size changes.
- Changed `scripts/build-orbital-viewer-app.sh` to build the local review app bundle from a release binary by default, with `BUILD_CONFIGURATION` still available as an override.
- Added tests proving the root animation timeline is disabled, SceneKit defaults to draw-on-demand at 30 fps, inspector cadence is separate at 10 fps, meter-only ticks do not change static geometry keys, and coordinator speaker rebuilds occur only for shape/size changes.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=.build/clang-module-cache SWIFTPM_CACHE_DIR=.build/swiftpm-cache swift build -c release --disable-sandbox --product OrbitalViewViewer
zsh -n scripts/build-orbital-viewer-app.sh
pkill -f OrbitalViewViewer
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist
open -n Orbital\ View\ VU\ Kit.app
ps -p 13128 -o pid,%cpu,%mem,command
git diff --check
```

Results:

```text
swift build passed.
Focused SwiftUI tests passed: 22 tests, 0 failures.
Full swift test passed: 83 tests, 0 failures.
Closed the prior viewer process before rebuilding the app bundle.
App bundle build passed and produced Orbital View VU Kit.app; SwiftPM emitted user-cache permission warnings but completed successfully.
The local app-bundle builder now uses release configuration by default.
App bundle Info.plist passed plutil lint.
Live app opened through LaunchServices.
Computer Use verified the fresh app window opens with the approved left rail, 3D viewport, inspector, footer, and animated fake meter list visible.
git diff --check passed.
```

Bugs found or fixed:

```text
Fixed the slow native review screen path caused by a root SwiftUI animation timeline rebuilding the full shell, control rail, footer, inspector, and speaker rows every animation frame.
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-21 Native Orbisonic Control Skin And Camera Fog

Status:

```text
complete
```

Changed:

- Added Slice 014 task/slice docs to explicitly permit the standalone SwiftUI protected path follow-up.
- Restyled `OrbitalViewportMockup` around package-local Orbisonic LabTheme-style tokens instead of web color-scheme skinning.
- Replaced web-like control rows with Swift-native segmented/menu pickers, native toggles, native SwiftUI sliders, and compact Orbisonic-style buttons.
- Replaced slider rows with Orbisonic's title/value plus cyan-tinted native slider composition, removing the duplicate/custom slider-track look.
- Rebuilt the desktop shell as fixed left and right rails with the SceneKit viewport flexing in the center; VU bars now fill inside fixed row tracks.
- Changed the standalone viewer window default to a native 1180 x 760 workbench size with a 980 x 680 minimum so both fixed rails are visible on the current display.
- Changed the SceneKit view to orbit the camera around static content instead of rotating the content root.
- Removed fog-driven manual material alpha fading from the SceneKit path; fog is now SceneKit camera-space fog while hidden-line visibility remains separate.
- Reworked drag/spin timing so drag uses a stable start pose, spin accumulates from an anchored yaw, and mouse-up does not change the final pose.
- Strengthened SceneKit speaker-number labels as centered, depth-independent billboards so the native Speaker Numbers switch is visibly effective.
- Added focused SwiftUI tests for Orbisonic control metrics and camera-orbit/spin math.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests/testOrbitalViewport
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=.build/clang-module-cache SWIFTPM_CACHE_DIR=.build/swiftpm-cache swift test --disable-sandbox --filter OrbitalViewSwiftUITests/testOrbitalViewport
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=.build/clang-module-cache SWIFTPM_CACHE_DIR=.build/swiftpm-cache swift test --disable-sandbox
zsh -n Open\ Native\ Orbital\ View\ VU\ Kit.command
zsh -n Open\ Orbital\ View\ Viewer.command
zsh -n scripts/build-orbital-viewer-app.sh
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist
open -n Orbital\ View\ VU\ Kit.app
git diff --check
node -e 'JSON.parse(require("fs").readFileSync("manifest.json", "utf8")); console.log("manifest parses")'
```

Results:

```text
swift build passed.
Plain focused swift test hit the known SwiftPM user cache permission issue.
Focused SwiftUI viewport tests passed with package-local caches: 5 tests, 0 failures.
Full swift test passed with package-local caches: 74 tests, 0 failures, 5 Metal-dependent renderer tests skipped because no Metal device was available in the test process.
Launcher/script syntax checks passed.
App bundle build passed and produced Orbital View VU Kit.app.
App bundle Info.plist passed plutil lint.
Live app opened through LaunchServices.
Computer Use verified the fresh native-size app window opens with both fixed rails visible, Orbisonic-native controls, native switches/sliders/pickers, and speaker-number switch state changing live.
git diff --check passed.
manifest.json parsed successfully.
```

Bugs found or fixed:

```text
Fixed native viewer control-skin drift from Orbisonic design language, duplicate-looking slider tracks, unstable panel width behavior, SceneKit fog feeling attached to model rotation, and drag/spin pose jumps.
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

### Update: 2026-05-20 Native Orbital Viewport 3D Parity

Status:

```text
complete
```

Changed:

- Removed the rejected native Cube VU workbench/launcher changes and left the VU branch back at the prior VU state before rebuilding.
- Added `OrbitalViewportMockup`, a SwiftUI screen matching the actual browser viewport mockup layout: 240px left rail, center viewport, 300px inspector, 46px footer, and the same control set.
- Implemented the viewport as native SceneKit 3D, not a WebView or flat screen port: generated Fey 3V shell, 30 Fey speaker prisms/spheres, native lighting, fog, hidden-line visibility, labels, selection, orbit drag, spin, wheel/magnification zoom, and PNG snapshot export.
- Changed the standalone executable window to `Orbital View VU Kit`.
- Added `Open Native Orbital View VU Kit.command`.
- Renamed the generated app bundle to `Orbital View VU Kit.app`.
- Added focused SwiftUI tests for the native viewport contract.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=.build/clang-module-cache SWIFTPM_CACHE_DIR=.build/swiftpm-cache swift test --disable-sandbox --filter OrbitalViewSwiftUITests/testOrbitalViewport
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=.build/clang-module-cache SWIFTPM_CACHE_DIR=.build/swiftpm-cache swift test --disable-sandbox
zsh -n Open\ Native\ Orbital\ View\ VU\ Kit.command
zsh -n Open\ Orbital\ View\ Viewer.command
zsh -n scripts/build-orbital-viewer-app.sh
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist
open -n Orbital\ View\ VU\ Kit.app
git diff --check
node -e 'JSON.parse(require("fs").readFileSync("manifest.json", "utf8")); console.log("manifest parses")'
```

Results:

```text
swift build passed.
Focused native viewport tests passed: 3 tests, 0 failures.
Full swift test passed: 72 tests, 0 failures, 5 Metal-dependent renderer tests skipped because no Metal device was available in the test process.
Launcher/script syntax checks passed.
App bundle build passed and produced Orbital View VU Kit.app.
App bundle Info.plist passed plutil lint.
Live app opened through LaunchServices.
Computer Use verified the app window opened with the native 3D viewport, matching controls, inspector, footer, animated fake meter list, and color/style controls visible.
git diff --check passed.
manifest.json parsed successfully.
```

Bugs found or fixed:

```text
Fixed the rejected native workbench direction by removing the Cube VU workbench and replacing the standalone app entrypoint with the actual browser viewport mockup contract.
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

The pinned local static server URL for the active single-screen cube VU mockup is:

```text
http://127.0.0.1:8765/OrbitalViewKit/
```

### Update: 2026-05-20 Standalone SwiftPM Viewer

Status:

```text
complete
```

Changed:

- Added `OrbitalViewViewerSupport` as a package-local support target that depends only on `OrbitalViewCore`.
- Added deterministic demo-only content: 30 channel-keyed speakers, a static speaker meter frame, source-object frames, object meters, and object visual settings.
- Added the `OrbitalViewViewer` executable product and SwiftUI target.
- Wired the executable to the public `OrbitalView` SwiftUI API, the existing VU settings tray, object overlay inputs, and local plan/front/side/isometric camera preset buttons.
- Added focused viewer support tests.

Run command:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run OrbitalViewViewer
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewViewerTests
```

Results:

```text
swift build passed.
Focused viewer tests passed: 3 tests, 0 failures.
```

Launcher:

```text
Open Orbital View Viewer.command
Orbital View Viewer.app
```

Documentation updated:

```text
docs/architecture.md
docs/implementation-map.md
docs/product-brief.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
No protected renderer, SwiftUI wrapper, or downstream app paths were edited. The new viewer consumes OrbitalViewSwiftUI through its public API.
```

### Update: 2026-05-20 Standalone Viewer Launch And Projection Fix

Status:

```text
complete
```

Changed:

- Replaced the Terminal-only `swift run` launcher path with a root launcher that builds and opens a local macOS app bundle.
- Added `scripts/build-orbital-viewer-app.sh` to produce `Orbital View Viewer.app` from the SwiftPM executable, with Swift/Clang caches forced under `.build` for launcher reliability.
- Switched viewer demo speakers from arbitrary Fibonacci points to the accepted Fey 30 coordinate fixture.
- Added viewer-level Plan, Front, Side, and Iso scene transforms so camera preset buttons visibly change the viewport while renderer-native camera projection remains deferred.
- Removed the full VU settings tray from the standalone viewer surface and added a lighter shell-guide/label overlay.

Commands run:

```text
zsh -n Open\ Orbital\ View\ Viewer.command
zsh -n scripts/build-orbital-viewer-app.sh
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ Viewer.app/Contents/Info.plist
open -n Orbital\ View\ Viewer.app
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewViewerTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```

Results:

```text
Launcher syntax checks passed.
App bundle build passed and produced Orbital View Viewer.app.
App bundle Info.plist passed plutil lint.
Live app opened successfully through LaunchServices.
Computer Use verified the app window opened and the Plan preset changed the visible scene/footer state.
swift build passed.
Focused viewer tests passed: 4 tests, 0 failures.
swift test passed: 69 XCTest cases, 0 failures.
git diff --check passed.
```

Bugs found or fixed:

```text
Fixed the first standalone viewer launcher/presentation bug: the launcher used command-line SwiftPM execution instead of a real app bundle, and the exposed camera buttons only updated renderer camera state even though renderer-native camera projection is still deferred.
```

### Update: 2026-05-20 Orbisonic Integration Seam And Shared Host Contract

Status:

```text
complete
```

Changed:

- Opened Slice 021 from `orbital-view-vu-kit-native-codex-work-package.md`.
- Inspected the sibling Orbisonic checkout enough to ground the seam in current concepts: renderer output speakers, `ChannelMeter`, `MeterSnapshot.danteMeters`, and Lab theme tokens.
- Added `OrbitalViewOrbisonic` as a local adapter-skeleton target that depends only on `OrbitalViewCore`.
- Defined the Orbisonic host contract: `Orbisonic renderer/output monitor -> 30 channel VU records -> SpeakerMeterFrame -> OrbitalView`.
- Added DTOs for 30 physical output speaker records and normalized Orbisonic meter records.
- Added sanitized meter adaptation through `SpeakerMeterFrameSanitizer`.
- Added `OrbisonicOrbitalColorScheme` with `Daft Punk Bow` mapping directly to `OrbitalViewTheme.daftPunkBow`.
- Renamed the private core object-ID helper from Wavefield-specific wording to source-object wording so Core/Render/SwiftUI stay host-neutral.
- Confirmed no `OrbitalViewWavefield`, `OrbitalViewOrbisonic`, `PlayerSnapshot`, or `MeterSummary` references exist in `Sources/OrbitalViewCore`, `Sources/OrbitalViewRender`, or `Sources/OrbitalViewSwiftUI`.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbisonicOrbitalViewAdapterTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
rg -n "import OrbitalViewWavefield|import OrbitalViewOrbisonic|Wavefield app targets|Orbisonic app targets|PlayerSnapshot|MeterSummary|OrbitalViewWavefield|OrbitalViewOrbisonic" Sources/OrbitalViewCore Sources/OrbitalViewRender Sources/OrbitalViewSwiftUI
```

Results:

```text
swift build passed.
Focused Orbisonic adapter tests passed: 4 tests, 0 failures.
swift test passed: 65 XCTest cases, 0 failures.
The downstream-adapter leak grep returned no matches in Core/Render/SwiftUI.
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/orbisonic-integration-contract.md
docs/product-brief.md
docs/protected-paths.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
Fixed one Slice 021 compile issue in the new adapter: the throwing default speaker-shape initializer could not sit inside nil-coalescing without an explicit branch.
```

Protected paths touched:

```text
No protected renderer, SwiftUI, or downstream app paths were touched.
Sources/OrbitalViewCore/ touched only to rename a private helper from Wavefield-specific wording to source-object wording.
Sources/OrbitalViewOrbisonic/ added as normal Slice 021 scope.
```

Specialty review:

```text
P0 blockers: none.
P1 should-fix: none found in the implemented scope.
Protected path concerns: none; no Orbisonic app, Wavefield app, renderer, SwiftUI, audio, playback, routing, MIDI, OSC, metering, or output paths were changed.
Architecture concerns: none; the new target depends only on Foundation and OrbitalViewCore, and Core/Render/SwiftUI do not import host adapter targets.
Audio concerns: none; the contract consumes normalized host meter records and does not read buffers or change output semantics.
Manual decisions needed: a future Orbisonic app slice still needs to map live Orbisonic types into the DTOs and decide how or whether to visualize 30.1 LFE separately.
Recommended action: open the separate web work package when ready.
```

### Update: 2026-05-20 Wavefield Orbital View Tab Integration

Status:

```text
complete
```

Changed:

- Opened Slice 020 from `orbital-view-vu-kit-native-codex-work-package.md`.
- Added a runtime-safe `OrbitalViewWavefield` adapter from Wavefield-style channel RMS/peak frames into sanitized `SpeakerMeterFrame` plus `OrbitalViewInputDiagnostics`.
- Wired the sibling Wavefield app to the local `OrbitalViewKit` package through a path dependency.
- Added a guarded `Orbital View` app tab while keeping the existing `Spherical VU` tab available.
- Built the Orbital View scene from Wavefield's cached Spherical VU/Fey speaker geometry and joined meter values by physical speaker channel.
- Adapted `PlayerSnapshot.meterSummary.multichannelLevels` into `SpeakerMeterFrame` for MIDI Track to Speakers, nearest-speaker, and VBAP modes when multichannel levels are available.
- Preserved Mono Equal as the only mode that mirrors mono RMS/peak to all modeled speaker channels.
- Passed Wavefield color-scheme tokens into `OrbitalViewTheme` and added `Daft Punk Bow` to Wavefield color-scheme options.
- Surfaced Orbital diagnostics for source label, signal source, active channel count, missing/extra/invalid/duplicate channels, replaced/clamped values, and timestamp fallback.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter WavefieldMeterFrameAdapterTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter 'WavefieldAppSupportTests/testTabContractMatchesDocumentedShellOrder|TabSourceActionTests/testSettingsColorSchemeOptionsMatchOrbisonicDesignLanguage|TabSourceActionTests/testSettingsColorSchemeSelectionDrivesCurrentPalette|TabSourceActionTests/testOrbitalViewModelUsesLoadedSpeakerGeometryAndMultichannelMeters|TabSourceActionTests/testOrbitalViewModelMirrorsOnlyExplicitMonoEqualMode|TabSourceActionTests/testSelectingEveryTabInstantiatesContentAndLogsSelection'
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```

Results:

```text
OrbitalViewKit swift build passed.
Wavefield Receiver swift build passed after fixing SwiftPM manifest argument order and new-tab switch exhaustiveness.
WavefieldMeterFrameAdapterTests passed: 5 tests, 0 failures.
OrbitalViewKit full swift test passed: 61 XCTest tests, 0 failures.
Focused Wavefield app integration tests passed: 6 tests, 0 failures.
Wavefield Receiver full swift test passed: 446 XCTest tests, 0 failures.
git diff --check passed in OrbitalViewKit and Wavefield Receiver.
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
Wavefield Receiver docs/status.md
Wavefield Receiver docs/architecture.md
Wavefield Receiver docs/system-flows.md
Wavefield Receiver docs/implementation-map.md
Wavefield Receiver docs/test-strategy.md
```

Bugs found or fixed:

```text
Fixed Slice 020 integration compile issues: SwiftPM dependencies must follow products, the new Wavefield tab case had to be added to a PlayerPanel source-family switch, and SwiftUI diagnostics rows needed an explicitly enumerated ForEach.
```

Protected paths touched:

```text
Wavefield app UI and adapter paths allowed by Slice 020.
Wavefield audio/playback/rendering/output/MIDI/OSC paths were not changed.
Sources/OrbitalViewWavefield/ touched for the runtime-safe sanitized meter adapter.
```

Specialty review:

```text
P0 blockers: none.
P1 should-fix: none found in the implemented scope.
Protected path concerns: none; Wavefield app UI paths were allowed, and protected Wavefield audio/playback/rendering/output/MIDI/OSC paths were not touched.
Audio concerns: none; the integration consumes existing PlayerSnapshot meter summaries and does not change playback, routing, rendering, MIDI, OSC, output, or metering semantics.
Performance concerns: the Orbital View tab reuses cached speaker geometry through the Spherical VU snapshot and does not add audio-thread work.
Manual decisions needed: future visual smoke testing in the Finder-launched Wavefield app remains useful as a follow-up.
Recommended action: proceed to Slice 021 for Orbisonic integration seam and shared host contract.
```

Next recommended task:

```text
Slice 021 - Orbisonic integration seam and shared host contract
```

### Update: 2026-05-20 SwiftUI Viewport Controls, VU Tray, And Preset Save UI

Status:

```text
complete
```

Changed:

- Opened Slice 019 from `orbital-view-vu-kit-native-codex-work-package.md`.
- Preserved the existing `OrbitalViewMetalView` placement and coordinator flow; tray-only updates do not replace the viewport surface or rebuild renderer state.
- Extended the opt-in bottom VU tray with Basic and Advanced sections.
- Added the `Speaker Height: Cube -> 2 Cubes` control through `SpeakerMeterVisualSettings.speakerZScale`.
- Added advanced controls for bloom range, bloom edge, response curve, peak hold, release, hot fill, face pixels, and diagnostics visibility while preserving existing checker controls.
- Added optional preset UI actions: Save as Default, Save Preset, Load Preset, Reset to Saved Default, and Reset to Factory.
- Added optional `OrbitalViewVisualPresetStore` injection so persistence remains host-provided and non-mandatory.
- Added optional `OrbitalViewInputDiagnostics` injection and diagnostics summary display for missing, extra, invalid, duplicate, replaced, clamped, and timestamp-fallback meter input.
- Added SwiftUI tests for the new initializer/store surfaces, preset controller behavior, diagnostics summaries, and existing coordinator no-reload behavior.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewRenderTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```

Results:

```text
swift build passed.
swift test --filter OrbitalViewSwiftUITests passed: 8 tests, 0 failures.
swift test --filter OrbitalViewRenderTests passed: 23 tests, 0 failures.
swift test passed: 60 XCTest cases, 0 failures.
git diff --check passed.
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/ allowed by Slice 019 for the native VU tray, preset, and diagnostics surfaces.
Tests/OrbitalViewSwiftUITests/ allowed by Slice 019 for compile/action coverage.
```

Specialty review:

```text
P0 blockers: none.
P1 should-fix: none.
P2 nice-to-fix: none for Slice 019.
Safe autofixes: none.
Manual decisions needed: none; persistence remains optional and host-owned.
Protected path concerns: none; Sources/OrbitalViewSwiftUI/ and Tests/OrbitalViewSwiftUITests/ were explicitly allowed by Slice 019.
Audio concerns: none; no audio, playback, routing, MIDI, OSC, or downstream metering paths were touched.
Recommended action: proceed to Slice 020 for Wavefield Orbital View tab integration.
```

Next recommended task:

```text
Slice 020 - Wavefield Orbital View tab integration
```

### Update: 2026-05-20 Metal Cube/Prism Center-Bloom Renderer Prototype

Status:

```text
complete
```

Changed:

- Opened Slice 018 from `orbital-view-vu-kit-native-codex-work-package.md`.
- Replaced the speaker flat-quad draw path with instanced cube/prism speaker meshes using retained position, orientation, material, and ramp buffers.
- Kept object overlays on the existing simple quad path so source-object work remains out of this slice.
- Added shader-side procedural face-center bloom: RMS drives center fill/body glow, peak drives halo/ring intensity, and clip drives a hot flash.
- Added Daft Punk Bow and other color-scheme ramp stops as retained renderer uniform data rather than per-speaker textures.
- Preserved static speaker geometry across meter updates and kept channel-to-instance mapping by scene speaker order.
- Added offscreen renderer tests for cube/prism mesh metadata, RMS/peak/clip material payloads, hot/clip pixel response without geometry-bound changes, and ramp-uniform color changes without geometry changes.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewRenderTests/testOffscreenRendererSmokeProducesNonClearFrame
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewRenderTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```

Results:

```text
swift build passed.
The first offscreen smoke rerun exposed a Metal shader compile issue from using `vertex` as a local MSL variable name; renaming it to `meshVertex` fixed the runtime shader compile.
swift test --filter OrbitalViewRenderTests passed: 23 tests, 0 failures.
swift test passed: 58 XCTest cases, 0 failures.
git diff --check passed.
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/renderer-cache-plan.md
docs/renderer-test-harness.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
Fixed one Slice 018-introduced Metal shader compile issue: `vertex` was reserved/ambiguous in MSL local declaration context.
```

Protected paths touched:

```text
Sources/OrbitalViewRender/ allowed by Slice 018 for the Metal cube/prism center-bloom renderer prototype.
Tests/OrbitalViewRenderTests/ allowed by Slice 018 for offscreen smoke and pixel-probe coverage.
```

Specialty review:

```text
P0 blockers: none.
P1 should-fix: none.
P2 nice-to-fix: add real depth/culling or sorted face rendering in a future visual-polish slice once shell/strut rendering and camera projection are in scope; current back-to-front face order is acceptable for this prototype.
Safe autofixes: ramp sampling now clamps above the last stop to the last color, and the shader avoids the MSL `vertex` local-name compile issue.
Manual decisions needed: none for Slice 018.
Protected path concerns: none; Sources/OrbitalViewRender/ and Tests/OrbitalViewRenderTests/ were explicitly allowed by Slice 018.
Audio concerns: none; no live audio, playback, routing, MIDI, OSC, or downstream metering paths were touched.
Recommended action: proceed to Slice 019 for SwiftUI viewport controls, VU tray, and preset save UI.
```

Next recommended task:

```text
Slice 019 - SwiftUI viewport controls, VU tray, and preset save UI
```

### Update: 2026-05-20 Renderer Static Buffer/Cache Plan And Performance Invariants

Status:

```text
complete
```

Changed:

- Opened Slice 017 from `orbital-view-vu-kit-native-codex-work-package.md`.
- Added `docs/renderer-cache-plan.md` to define static speaker geometry keys, channel-to-instance mapping, retained buffer behavior, object-layer compatibility, and the production cube/prism cache migration path.
- Added internal `OrbitalViewSpeakerStaticGeometryCacheKey` for renderer invariant tests.
- Added `OrbitalViewSpeakerDrawInputs.channelToInstanceIndex` for channel-to-instance map tests.
- Added renderer tests proving meter-only, settings-only, camera-only, and object-layer updates do not change static speaker geometry cache keys.
- Added renderer tests proving cube and rectangular-prism scenes produce different static geometry cache keys.
- Added renderer tests proving channel-to-instance mapping follows scene speaker order and ignores extra meter channels.
- Added renderer tests proving retained speaker buffers do not allocate again for meter/settings/camera-only renders when capacity is sufficient.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewRenderTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Results:

```text
swift build passed.
swift test --filter OrbitalViewRenderTests passed: 20 tests, 0 failures.
swift test passed: 55 XCTest cases, 0 failures.
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/renderer-cache-plan.md
docs/status.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewRender/ allowed by Slice 017 for renderer cache-key and channel-map test harness additions.
Tests/OrbitalViewRenderTests/ allowed by Slice 017 for renderer performance invariant coverage.
```

Specialty review:

```text
P0 blockers: none.
P1 should-fix: none.
Protected path concerns: none; touched paths are explicitly allowed by Slice 017.
Performance concerns: none; tests now lock no new speaker buffer allocations for meter/settings/camera-only renders.
Audio concerns: none; no host app audio, routing, playback, MIDI, OSC, or metering paths were touched.
Recommended action: proceed to Slice 018 for the Metal cube/prism center-bloom renderer prototype.
```

Next recommended task:

```text
Slice 018 - Metal cube/prism center-bloom renderer prototype
```

### Update: 2026-05-20 Cube Scalar Bloom Settings, Sanitizer, Diagnostics, And Presets

Status:

```text
complete
```

Changed:

- Opened Slice 016 from `orbital-view-vu-kit-native-codex-work-package.md`.
- Added `SpeakerMeterVisualStyle.cubeScalarCenterBloom` as the default music-mode style.
- Kept checker pulse/ring/diagonal wave available as the legacy/impulse-test style and migrated legacy `checkerRipple` style aliases to it.
- Expanded `SpeakerMeterVisualSettings` with bloom min/max/edge, response curve, peak hold, release memory, hot fill, face pixels, diagnostics visibility, existing speaker z-scale, and Daft Punk Bow defaults.
- Added `SpeakerMeterSample`, `SpeakerMeterFrameSanitizer`, and `OrbitalViewInputDiagnostics` so unsafe host samples can be converted into strict `SpeakerMeterFrame` values without crashing UI surfaces.
- Added `OrbitalViewVisualPreset` and `OrbitalViewVisualPresetStore`; Core exposes only the value/protocol contract and remains persistence-free.
- Added a minimal renderer color-input branch for the new style so existing renderer code stays exhaustive; full Metal cube/prism center-bloom drawing remains deferred.
- Updated SwiftUI settings mutation to preserve the new settings fields during existing tray interactions.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewCoreTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Results:

```text
swift build passed.
swift test --filter OrbitalViewCoreTests passed: 20 tests, 0 failures.
swift test --filter OrbitalViewSwiftUITests passed: 6 tests, 0 failures.
swift test passed: 51 XCTest cases, 0 failures.
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewRender/ touched only to keep the existing renderer style switch exhaustive after adding cubeScalarCenterBloom.
Sources/OrbitalViewSwiftUI/ touched only to preserve new settings fields during existing tray updates.
Tests/OrbitalViewRenderTests/ touched only to update default-style expectations.
```

Specialty review:

```text
P0 blockers: none.
P1 should-fix: none.
Protected path concern: Slice 016 did not name OrbitalViewRender, but the enum addition required a compile-preserving switch branch; no renderer geometry, audio, timing, or full production drawing behavior was added.
Audio concerns: none; sanitizer consumes host-provided samples and does not own callbacks or routing.
Recommended action: proceed to Slice 017 for renderer static buffer/cache plan and performance invariants.
```

Next recommended task:

```text
Slice 017 - Renderer static buffer/cache plan and performance invariants
```

### Update: 2026-05-20 Daft Punk Bow Theme Tokens And Palette Migration

Status:

```text
complete
```

Changed:

- Opened Slice 015 from `orbital-view-vu-kit-native-codex-work-package.md`.
- Added platform-neutral `OrbitalColor` and `OrbitalColorStop` contracts.
- Expanded `OrbitalViewTheme` from name-only to background, panel, line, text, muted text, accent, secondary accent, success, warning, danger, and `vuRamp` tokens.
- Preserved legacy name-only theme decoding by filling missing token fields from the default theme.
- Added `SpeakerMeterColorScheme.daftPunkBow` with user-facing display name `Daft Punk Bow`.
- Added `OrbitalViewTheme.daftPunkBow` with the required seven-stop VU ramp.
- Migrated legacy encoded `techRainbow` color schemes to `daftPunkBow`.
- Added a renderer palette branch so existing checker color transforms compile with the new scheme.
- Updated docs so Wavefield and Orbisonic host UIs can offer the same `Daft Punk Bow` color scheme later.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewCoreTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Results:

```text
swift build passed.
swift test --filter OrbitalViewCoreTests passed: 18 tests, 0 failures.
swift test passed: 49 XCTest cases, 0 failures.
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/status.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
fixed a local compile issue where the custom SpeakerMeterColorScheme Codable implementation needed the enum to explicitly conform to Codable
```

Protected paths touched:

```text
Sources/OrbitalViewRender/ allowed by Slice 015 only to preserve compilation after enum changes
```

Object-tree compatibility:

```text
Contracts added are additive: OrbitalColor, OrbitalColorStop, expanded OrbitalViewTheme tokens, and SpeakerMeterColorScheme.daftPunkBow.
No object-tree symbols were renamed or removed.
Renderer layer shape is unchanged; only the existing speaker color palette switch gained a Daft Punk Bow branch.
```

Next recommended task:

```text
Slice 016 - Cube scalar bloom settings, sanitizer, diagnostics, and presets
```

### Update: 2026-05-20 Speaker Cube/Prism Shape And Face-Center VU Contract

Status:

```text
complete
```

Changed:

- Opened Slice 014 from `orbital-view-vu-kit-native-codex-work-package.md`.
- Added `SpeakerShape.cube(edgeM:)` and Sonic Sphere helper constructors for cube default and fixed rectangular-prism z scale.
- Preserved the existing generic `SpeakerShape.rectangularPrism(widthM:heightM:depthM:bevelM:)` case for source/Codable compatibility.
- Added `SpeakerFaceCenterBloom.normalizedDistanceFromFaceCenter(u:v:)` for per-face center-bloom math.
- Added `SpeakerMeterVisualSettings.speakerZScale` with validated `1...2` range and legacy decode default `1`.
- Changed the Wavefield layout adapter's default physical speaker shape from sphere to Sonic Sphere cube while preserving channel identity and caller override support.
- Added core, Wavefield, and renderer tests for cube/prism validation, face-center distance, z-scale validation, default cube speaker mapping, and shape stability under meter/settings updates.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewCoreTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Results:

```text
swift build passed.
swift test --filter OrbitalViewCoreTests passed: 15 tests, 0 failures.
swift test passed: 46 XCTest cases, 0 failures.
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Tests/OrbitalViewRenderTests/ allowed by Slice 014 for invariant coverage
```

Object-tree compatibility:

```text
Contracts added are additive: SpeakerShape.cube, SpeakerFaceCenterBloom, and SpeakerMeterVisualSettings.speakerZScale.
No object-tree symbols were renamed or removed.
Renderer source layers were unchanged; only renderer tests assert z-scale settings do not mutate speaker shape/static inputs.
```

Next recommended task:

```text
Slice 015 - Daft Punk Bow theme tokens and palette migration
```

### Update: 2026-05-20 Object Tree Merge Compatibility Review

Status:

```text
complete
```

Changed:

- Opened Slice 013 from `orbital-view-vu-kit-native-codex-work-package.md`.
- Located the separate object tree at `/Users/jeremyguillory/Documents/vibecode projects/orbital-view-with-objects`.
- Compared public scene, camera, selection, renderer, SwiftUI, and object-related API surfaces.
- Added `docs/object-tree-merge-compatibility.md` with merge findings, conflict expectations, and additive bridge guidance.
- Left source unchanged because no current object-tree symbol conflict requires scaffolding.

Commands run:

```text
find /Users/jeremyguillory/Documents -maxdepth 5 -type d -iname '*Orbital*View*Objects*'
rg public symbol/object API scans across both trees
diff -qr Sources between both trees
diff -qr Tests between both trees
```

Results:

```text
The inspected object tree is older than the current VU tree. It already shares OrbitalViewSceneSpec.virtualObjects but lacks the current dynamic object frame, object meter, object visual settings, renderer object revision, retained object buffer, and SwiftUI object forwarding APIs.
```

Documentation updated:

```text
docs/object-tree-merge-compatibility.md
docs/implementation-map.md
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

Next recommended task:

```text
Slice 014 - Speaker cube/prism shape contract and face-center VU contract
```

### Update: 2026-05-20 Native Work Package Preflight Verification

Status:

```text
complete
```

Changed:

- Began `orbital-view-vu-kit-native-codex-work-package.md`.
- Treated the package's first slice as the active preflight restore/build verification step.
- Verified the current working tree already contains the core source files and Fey 30 fixture resources that the uploaded package warned could be missing.
- Left source behavior unchanged because no restore blocker was present.

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Results:

```text
swift build passed.
swift test passed: 43 XCTest cases, 0 failures.
```

Documentation updated:

```text
docs/status.md
```

Bugs found or fixed:

```text
none; no missing source or fixture blockers were present in the current working tree
```

Protected paths touched:

```text
none
```

Next recommended task:

```text
Slice 013 - Orbital View with Objects merge compatibility review
```

### Update: 2026-05-20 Wavefield Object Overlay Performance Slice

Status:

```text
complete
```

Changed:

- Added `OrbitalViewObjectFrameSet`, `OrbitalViewObjectFrame`, `ObjectMeterFrame`, `ObjectMeterLevel`, `ObjectVisualSettings`, object visual shape/palette enums, and default `-5...+5` render/effect bounds.
- Added object ID validation in the `1...128` range, active-object caps, duplicate object rejection, non-negative width validation, and trail cap validation.
- Added renderer object frame, object meter, and object visual settings state with revisions separate from speaker scene, speaker meter, and speaker visual setting revisions.
- Added object draw inputs for object cores and capped trail samples, with glow trails sharing the same capped object draw-input stream.
- Reworked the Metal draw pipeline to retain speaker/object position and color buffers and reuse capacity across repeated draws.
- Added SwiftUI object frame, object meter, and object visual settings forwarding without SwiftUI-owned per-frame object animation state.
- Preserved the existing viewport mockup control rail and added Object Geometry, Object Motion, Object Meter Skin, Trails, Glow Trails, and Bounds groups below View Detail.
- Added task and work-package slice docs for slice 012.

Files changed:

```text
Sources/OrbitalViewCore/OrbitalViewObjects.swift
Sources/OrbitalViewCore/OrbitalViewValidationError.swift
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewCoreTests/
Tests/OrbitalViewRenderTests/
Tests/OrbitalViewSwiftUITests/
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/protected-paths.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
.tasks/012-wavefield-object-overlay-performance.md
orbital-view-vu-kit-native-codex-work-package.md
work-packages/orbital-view-kit/slices/012-wavefield-object-overlay-performance.md
```

Tests added or updated:

```text
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
docs/test-strategy.md
node object-control mockup assertions
```

Commands run:

```text
node inline JavaScript parse for both mockups -> passed
node object-control mockup assertions -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 43 tests
git diff --check -> passed
```

Documentation updated:

```text
docs/architecture.md
docs/contracts.md
docs/implementation-map.md
docs/product-brief.md
docs/protected-paths.md
docs/status.md
docs/system-flows.md
docs/test-strategy.md
mockups/orbital-view-viewport/notes.md
.tasks/012-wavefield-object-overlay-performance.md
orbital-view-vu-kit-native-codex-work-package.md
work-packages/orbital-view-kit/slices/012-wavefield-object-overlay-performance.md
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewRender/ allowed by slice 012
Tests/OrbitalViewRenderTests/ allowed by slice 012
Sources/OrbitalViewSwiftUI/ allowed by slice 012
Tests/OrbitalViewSwiftUITests/ allowed by slice 012
```

Result:

```text
Wavefield-style source-object overlay contracts, renderer draw inputs, SwiftUI forwarding, retained buffer reuse checks, and matching mockup controls are implemented without changing speaker VU ownership or channel identity.
```

Risks:

- Live object smoothing is represented as tunable settings and documented behavior, but production replay/live interpolation is still deferred.
- Current object visuals use the minimal quad renderer baseline; final materials, bloom, true shape rendering, and shader-driven glow trails remain future renderer work.

Next recommended task:

```text
Open a production live object smoothing/interpolation slice, then a production object material/trail shader slice.
```

### Update: 2026-05-20 Cube Scalar VU Simplification

Status:

```text
complete
```

Changed:

- Simplified the single-screen cube VU mockup so Music mode behaves like a normal VU meter.
- Collapsed Web Audio RMS, peak, and bass into one `vuScalar`.
- Changed cube rendering in Music mode to center-bloom scalar face fill instead of beat, transient, or ripple drops.
- Converted the four visible cube cards into Soft Center Bloom, Hot Core Bloom, Halo Edge Bloom, and Block Center Bloom variants.
- Made `vuScalar` equal the RMS percent exactly, so the Cube VU readout and the RMS readout match.
- Reduced mockup canvas work by removing mini-cube redraws, lowering default face resolution to 9 x 9, capping canvas DPR, and throttling canvas redraws to 24 fps.
- Added cached cube tile geometry, cached palette/RGB conversion, smaller analyser FFT, fewer spectrum bars, and down-sampled waveform drawing to reduce main-thread stalls.
- Reduced the visible Tune tab to audio source, Cube VU scalar, surface, and palette controls.
- Kept the old artificial pulse/ripple path only in Impulse Test mode for renderer stress testing.

Protected paths touched:

```text
none
```

## Current Work Package

```text
orbital-view-vu-kit-native-codex-work-package.md
```

## Current Tree

```text
codex/orbital-view-vu-kit branch
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
- Opened slice 011 on `codex/vu-meter-plumbing-tray`.
- Added `SpeakerMeterVisualSettings`, `SpeakerMeterVisualStyle`, and `SpeakerMeterColorScheme` as pure core display contracts.
- Made checker pulse/ring/diagonal wave with Kimi Purple the default VU style.
- Added renderer meter visual settings state and revision separation.
- Added 30-channel renderer draw-input mapping by physical speaker channel.
- Added an opt-in SwiftUI collapsible VU settings tray for Visual Gain, Style, Color Scheme, and checker controls.
- Imported `mockups/sonicsphere-cube-vu-single-screen/` as a no-scroll single-screen browser mockup and exposed it at `/OrbitalViewKit/` for the pinned local server.
- Added browser-only real music analysis to the cube VU mockup using tab capture for YouTube, local audio file playback, and Web Audio RMS/peak/bass-driven ripple behavior.
- Reworked the cube VU mockup layout with a separate normal music meter and tabbed Tune/Advanced controls for the active monitor.
- Added an exclusive VU drive toggle so Music and Impulse Test modes cannot run at the same time.
- Opened and completed slice 012 for Wavefield source-object overlay contracts, object VU state, capped trails, retained renderer buffers, and matching mockup controls.
- Completed Slice 013 object-tree merge compatibility documentation in `docs/object-tree-merge-compatibility.md`.
- Completed Slice 014 cube/prism speaker shape, speaker z-scale setting, and face-center VU contracts.
- Completed Slice 015 Daft Punk Bow theme tokens, VU ramp, and `techRainbow` migration.
- Completed Slice 016 cube scalar bloom settings, sanitizer diagnostics, and visual preset contracts.
- Completed Slice 017 renderer static buffer/cache plan and performance invariants.
- Completed Slice 018 Metal cube/prism center-bloom renderer prototype.
- Completed Slice 019 SwiftUI VU tray controls, optional preset store actions, and diagnostics display.

## In Progress

```text
none
```

## Pending

- Next native continuation task is Slice 020 - Wavefield Orbital View tab integration.

## Blocked

```text
none
```

## Recent Changes

### Update: 2026-05-20 Exclusive Music Or Impulse Test Drive

Status:

```text
complete
```

Changed:

- Added a VU drive switch with Music and Impulse Test modes.
- Moved artificial impulse controls from Tune into a dedicated Impulse tab.
- Made Music mode disable artificial Drop/Repeat controls and use only tab/local-file Web Audio analysis.
- Made Impulse Test mode stop active music capture/playback, decay audio meters, clear existing music-driven drops, and enable only artificial Drop/Repeat controls.
- Removed the startup artificial impulse so the default Music mode is not mixed with fake drops.

Files changed:

```text
docs/status.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
mockups/sonicsphere-cube-vu-single-screen/index.html
mockups/sonicsphere-cube-vu-single-screen/notes.md
mockups/sonicsphere-cube-vu-single-screen/sonicsphere-cube-vu-design.md
```

Tests added or updated:

```text
docs/test-strategy.md
node exclusive drive mode structure assertions
```

Commands run:

```text
node inline JavaScript parse for both mockups
node exclusive drive mode structure assertions
curl -I http://127.0.0.1:8765/OrbitalViewKit/
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```

Documentation updated:

```text
docs/status.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
mockups/sonicsphere-cube-vu-single-screen/notes.md
mockups/sonicsphere-cube-vu-single-screen/sonicsphere-cube-vu-design.md
```

Bugs found or fixed:

```text
fixed the remaining path where manual artificial impulses could be layered over live music capture
```

Protected paths touched:

```text
none
```

Result:

```text
The browser mockup now has exactly one active VU drive source: Music or Impulse Test.
```

Risks:

```text
Tab/local audio capture remains browser-permission dependent. The exclusive mode behavior was verified by static assertions; live capture permission UI was not re-run for this small control-flow change.
```

Next recommended task:

```text
Use Music mode for real track tuning and Impulse Test mode only for repeatable visual calibration.
```

### Update: 2026-05-20 Wide Music Meter Layout For Browser Mockup

Status:

```text
complete
```

Changed:

- Reworked the single-screen cube VU mockup for the active Chrome monitor viewport.
- Added a separate normal Music Meter panel above the cube previews with RMS/Peak/Bass bars, spectrum bars, waveform, and dB readout.
- Moved custom palette JSON and implementation export controls into an Advanced tab.
- Kept the Tune tab focused on live audio source, palette, ripple, hot cube, and surface controls.
- Reduced the fixed artboard from 1512 x 982 to 1512 x 850 CSS pixels so browser chrome does not force the whole workbench into a tiny scale.
- Verified live YouTube tab capture was actively driving the normal meter and the cube VU in Chrome.

Files changed:

```text
docs/status.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
mockups/sonicsphere-cube-vu-single-screen/index.html
mockups/sonicsphere-cube-vu-single-screen/notes.md
mockups/sonicsphere-cube-vu-single-screen/sonicsphere-cube-vu-design.md
```

Tests added or updated:

```text
docs/test-strategy.md
node layout/audio mockup structure assertions
```

Commands run:

```text
node inline JavaScript parse for both mockups
node layout/audio mockup structure assertions
curl -I http://127.0.0.1:8765/OrbitalViewKit/
Chrome visual inspection through Computer Use for http://127.0.0.1:8765/OrbitalViewKit/ with active YouTube tab capture
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```

Documentation updated:

```text
docs/status.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
mockups/sonicsphere-cube-vu-single-screen/notes.md
mockups/sonicsphere-cube-vu-single-screen/sonicsphere-cube-vu-design.md
```

Bugs found or fixed:

```text
fixed cramped primary control layout by tabbing advanced controls and adding a dedicated meter preview area
```

Protected paths touched:

```text
none
```

Result:

```text
The live browser mockup is easier to read on the current monitor, with a normal music meter for captured YouTube/local-file audio and less crowded tuning controls.
```

Risks:

```text
Tab audio capture still depends on browser permission and selecting a source with audio sharing enabled. The layout was visually checked in the active Chrome monitor window, but automated screenshot diffing is not part of this static mockup.
```

Next recommended task:

```text
Use the improved mockup to choose meter envelope defaults before opening a production renderer animation slice.
```

### Update: 2026-05-20 Real Music VU Browser Mockup

Status:

```text
complete
```

Changed:

- Added an Audio Source control group to the single-screen cube VU mockup.
- Added browser tab-audio capture for YouTube or other playing tabs using `getDisplayMedia`.
- Added local audio file playback and analysis for browser-supported audio files through the page's `<audio>` element.
- Added Web Audio RMS, peak, and bass analysis for live level readouts; the cube `vuScalar` now follows RMS exactly.
- Simplified Music mode so cube faces bloom from the `vuScalar`; music no longer creates beat/transient/ripple drops.
- Preserved manual `Drop one` and fake repeat impulse behavior as a fallback, later moved behind the exclusive Impulse Test mode.
- Kept the implementation limited to the disposable browser mockup and docs; no Swift package, renderer, audio, routing, or downstream app contracts changed.

Files changed:

```text
README.md
docs/status.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
mockups/README.md
mockups/sonicsphere-cube-vu-single-screen/index.html
mockups/sonicsphere-cube-vu-single-screen/notes.md
```

Tests added or updated:

```text
docs/test-strategy.md
node audio mockup structure assertions
```

Commands run:

```text
node inline JavaScript parse for both mockups
node audio mockup structure assertions
curl -I http://127.0.0.1:8765/OrbitalViewKit/
Chrome visual inspection through Computer Use for http://127.0.0.1:8765/OrbitalViewKit/
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
git diff --check
```

Documentation updated:

```text
README.md
docs/status.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
mockups/README.md
mockups/sonicsphere-cube-vu-single-screen/notes.md
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
The cube VU mockup now supports real browser music analysis via YouTube/tab capture or local audio file playback while preserving its fake/manual impulse simulator fallback behind Impulse Test mode.
```

Risks:

- Tab audio capture depends on browser support, user permission, and selecting a source with audio sharing enabled.
- Actual capture/file playback permission flows are browser-mediated and were not fully automated by the test harness; static parser/structure checks, server response, and visual layout inspection passed.

Next recommended task:

```text
Open a production renderer animation slice if the real-music behavior should be translated from the browser mockup into Metal meter envelopes.
```

### Update: 2026-05-20 Sonicsphere Cube VU Single-Screen Mockup

Status:

```text
complete
```

Changed:

- Imported the supplied `sonicsphere-cube-vu-single-screen.zip` as a disposable static mockup.
- Added `notes.md` beside the imported design note so the mockup follows the project mockup convention.
- Added a root `OrbitalViewKit` symlink entrypoint for the stable local server path.
- Pinned the local web URL to `http://127.0.0.1:8765/OrbitalViewKit/`.
- Rebalanced the mockup to an equal 50/50 model/control split and scaled up the control rail to fill its half.
- Documented the new mockup in the project docs and mockup index.

Files changed:

```text
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
mockups/README.md
mockups/sonicsphere-cube-vu-single-screen/
OrbitalViewKit
```

Tests added or updated:

```text
docs/test-strategy.md
```

Commands run:

```text
node inline JavaScript parse for both mockups
browser viewport measurement for http://127.0.0.1:8765/OrbitalViewKit/
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Documentation updated:

```text
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
docs/status.md
docs/implementation-map.md
docs/test-strategy.md
mockups/README.md
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
The cube VU mockup is locally hosted at the permanent project URL and verified as a no-scroll one-page layout with equal model/control columns.
```

Risks:

- The mockup uses fake impulse/meter behavior and should not be treated as production renderer code.

Next recommended task:

```text
Decide which center-bloom cube VU variant should inform the production Metal checker/facet animation task.
```

### Update: 2026-05-19 VU Meter Plumbing And Settings Tray

Status:

```text
complete
```

Changed:

- Added pure core `SpeakerMeterVisualSettings`, `SpeakerMeterVisualStyle`, and `SpeakerMeterColorScheme`.
- Made checker pulse/ring/diagonal wave the default style for every speaker, with Kimi Purple as the default color scheme.
- Added display gain validation for finite `-24...24` dB values.
- Added validated checker settings for ring/front density, band softness, tile detail, idle tint, memory carryover, band velocity, and band width.
- Added renderer visual settings state, update method, and separate revision counter.
- Updated draw inputs to map meter levels by each speaker's physical channel and ignore extra frame channels.
- Added visual gain/style/color-scheme/checker color transforms without resizing speaker geometry.
- Added an opt-in SwiftUI `OrbitalView` initializer with a collapsed bottom VU settings tray and checker controls.
- Preserved the existing tray-free `OrbitalView` initializer.
- Added task and work-package slice docs for slice 011.

Files changed:

```text
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewCoreTests/
Tests/OrbitalViewRenderTests/
Tests/OrbitalViewSwiftUITests/
.tasks/011-vu-meter-plumbing-tray.md
work-packages/orbital-view-kit/slices/011-vu-meter-plumbing-tray.md
work-packages/orbital-view-kit/MV.md
docs/status.md
docs/architecture.md
docs/contracts.md
docs/product-brief.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
```

Tests added or updated:

```text
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
```

Commands run:

```text
git diff --check -> passed
node manifest JSON parse -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test -> passed, 35 tests
```

Documentation updated:

```text
docs/status.md
docs/architecture.md
docs/contracts.md
docs/product-brief.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
.tasks/011-vu-meter-plumbing-tray.md
work-packages/orbital-view-kit/slices/011-vu-meter-plumbing-tray.md
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
manifest.json
```

Bugs found or fixed:

```text
none
```

Protected paths touched:

```text
Sources/OrbitalViewRender/ allowed by slice 011
Tests/OrbitalViewRenderTests/ allowed by slice 011
Sources/OrbitalViewSwiftUI/ allowed by slice 011
Tests/OrbitalViewSwiftUITests/ allowed by slice 011
```

Result:

```text
Checker VU display settings and 30-channel renderer mapping are implemented and verified without touching downstream audio or app paths.
```

Risks:

- Current checker VU visuals are color/intensity transforms only; true per-facet checker cells, bloom, rings, and materials remain deferred.
- The SwiftUI tray is compile-tested but not visually reviewed in a host app yet.

Next recommended task:

```text
Production checker facet animation/materials or pixel-probe renderer tests.
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
- Confirmed axes remain `x = right`, `y = up`, and `z = front`.
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

### Update: 2026-05-21 Native VU Interaction, Fog, Zoom, And Export Polish

Status:

```text
complete
```

Changed:

- Restored the preferred full-width button groups for camera, color, speaker shape, spin, reset, and export actions.
- Replaced the remaining Speaker Size and Fog Density slider rows with a single-track Orbisonic-native SwiftUI slider composition and removed inline numeric values.
- Aligned Speaker Numbers and Hidden Lines switches to a fixed trailing native-switch column.
- Added an explicit fog disabled state so density `0` leaves the model fully visible and bypasses fallback fade paths.
- Kept Hidden Lines independent of fog density.
- Reworked spin to sweep horizontally in screen space for Plan, Elevation, and Isometric presets.
- Kept drag anchored to its start pose, swapped vertical drag direction, and swapped mouse-wheel zoom direction.
- Made Export PNG save a timestamped `.png` to Desktop and show transient footer success/failure feedback.

Files changed:

```text
.tasks/014-native-orbisonic-control-skin-and-camera-fog.md
Sources/OrbitalViewSwiftUI/OrbitalViewportMockup.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
docs/status.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
docs/protected-paths.md
docs/bugs.md
work-packages/orbital-view-kit/slices/014-native-orbisonic-control-skin-and-camera-fog.md
```

Tests added or updated:

```text
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
```

Commands run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -> passed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests/testOrbitalViewport -> failed in the default environment because SwiftPM tried to write Clang module cache files under the user cache path
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=.build/clang-module-cache SWIFTPM_CACHE_DIR=.build/swiftpm-cache swift test --disable-sandbox --filter OrbitalViewSwiftUITests/testOrbitalViewport -> passed, 9 tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=.build/clang-module-cache SWIFTPM_CACHE_DIR=.build/swiftpm-cache swift test --disable-sandbox -> passed, 78 tests executed, 5 skipped
scripts/build-orbital-viewer-app.sh -> passed
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist -> passed
zsh -n Open\ Native\ Orbital\ View\ VU\ Kit.command -> passed
zsh -n Open\ Orbital\ View\ Viewer.command -> passed
git diff --check -> passed
open -n Orbital\ View\ VU\ Kit.app -> passed
Computer Use visual check -> passed for full-width buttons, hidden slider values, aligned switches, visible model, and Desktop PNG confirmation
```

Documentation updated:

```text
docs/status.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
docs/protected-paths.md
docs/bugs.md
.tasks/014-native-orbisonic-control-skin-and-camera-fog.md
work-packages/orbital-view-kit/slices/014-native-orbisonic-control-skin-and-camera-fog.md
```

Bugs found or fixed:

```text
Fixed fog density 0 hiding the model, non-horizontal spin drift across presets, unwanted slider line/value treatment, unaligned switches, unclear Export PNG feedback, inverted-feeling vertical drag, inverted-feeling mouse-wheel zoom, and compact controls replacing the preferred full-width buttons.
```

Protected paths touched:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

Result:

```text
The native Orbital View VU Kit app keeps the Orbisonic-native skin, uses stable rails and controls, leaves the model visible at fog 0, spins horizontally across camera presets, uses the requested drag and wheel directions, and saves PNG exports to Desktop with visible confirmation.
```

Risks:

- This remains a standalone SwiftUI/SceneKit review app with deterministic fake meter animation; downstream Orbisonic/Wavefield integration and production Metal renderer behavior are unchanged.
- The default unsandboxed `swift test` path still needs local cache overrides on this machine because SwiftPM attempts to use a user-level Clang module cache.

Next recommended task:

```text
Open a downstream integration slice when Orbisonic or Wavefield should embed the native VU kit surface against real host meter data.
```

## Open Questions

- Exact downstream repository path for the first Wavefield integration.
- Exact production renderer drawing scope beyond the smoke baseline.

## Decision Log

- `docs/decisions/0001-initial-architecture.md`
- `docs/decisions/0002-renderer-backend.md`
