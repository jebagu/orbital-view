# Project Status

## Current Phase

```text
Corrected VU Kit SceneKit review app handoff
```

## Current Milestone

```text
Confirmed geodesic review app preserved with cube VU/object tuning trays
```

## Summary

The active review app is the existing `OrbitalViewViewer` executable in this package, now hosting the confirmed VU Kit native SceneKit geodesic viewport surface through `OrbitalViewportMockup`. It is not the rejected bare MTKView demo surface and does not create a second standalone copied app.

The confirmed review app preserves the original left control rail sections and defaults for Camera, Speaker Type, and View Detail. `Song Audio Source` now sits at the top of the left rail with side-by-side transport icon buttons for Play and Pause. Color scheme selection moved out of the left rail and into the right `Orbisonic Theme` tray. The right panel is now the tuning/debug panel for Orbisonic theme selection, speaker VU, meter calibration, surface/bloom, graphical performance versus CPU load, presets, and diagnostics. Object overlay, trails, glow trails, and bounds controls are hidden for the current review pass while the underlying object contracts remain in the package.

The SceneKit review app can load a local audio file for visual testing. Local file playback uses a simple choose-file plus separate play/pause transport and reduces the file meter to one mono RMS/peak sample applied equally to all speakers. This is a review-app input mode only; production hosts still provide real `SpeakerMeterFrame` values keyed by physical speaker channel.

`Cube VU` speaker type now uses the VU Kit scalar center-bloom contract in the SceneKit surface with a retained 9x9 face-pixel material texture applied to the actual cube faces, selected Orbisonic theme colors, RMS-driven center bloom, peak/hot fill, clip flash, and a material-only cube outline strength control. Prism and Sphere keep the existing simpler material tint behavior while inheriting the selected viewport theme.

The production SwiftUI wrapper still targets the MetalKit renderer seam for downstream hosts. The native review executable is intentionally a SceneKit visual-review surface because that is the UI the user confirmed as correct.

The root launcher `Open Orbital View Kit.command` opens the live mockup file with a cache-busting URL so browser reloads pick up current file changes.

## Current Work Package

```text
work-packages/orbital-view-kit/MV.md
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

## In Progress

```text
none
```

## Pending

- Decide the next bounded task for live host integration, camera/gesture controls, or production object smoothing.

## Blocked

```text
none
```

## Recent Changes

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

## Open Questions

- Exact downstream repository path for the first Wavefield integration.
- Exact production renderer drawing scope beyond the smoke baseline.

## Decision Log

- `docs/decisions/0001-initial-architecture.md`
- `docs/decisions/0002-renderer-backend.md`
