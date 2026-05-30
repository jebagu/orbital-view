# Orbital View

Orbital View is a native 3D spherical speaker and VU meter viewport for Sonic Sphere-style spatial audio systems.

It renders speaker layouts as orbitable 3D spheres and maps meter activity onto the speakers, making a spatial mix readable as a physical field rather than as a flat channel list. The current review app has been operator-confirmed at a reliable 60 FPS on an M1 MacBook, with solid menus and working Hidden Lines behavior.

Orbital View can run standalone as an ambient visual monitor for a speaker sphere. In Local Song mode, it can load and play an audio file so the metering behavior can be inspected without a host app. Its larger role is host integration: Orbital View is built to connect to the SonicSphere app family and display prepared speaker, source, and meter telemetry from Orbisonic, Wavefield, and Splat.

The current release identity is:

```text
Orbital View 1.0
```

The repository and Swift package still use `OrbitalView*` target and type names for source compatibility. Historical labels such as `Orbital View Kit`, `Orbital View VU Kit`, `Orbital View Turbo`, and `orbital-view-with-objects` are non-head variation labels. The canonical identity record is `docs/project-identity.md`.

## What It Does

- Renders a native 3D spherical viewport for physical speaker layouts.
- Displays per-speaker VU activity with the current Cube VU speaker style.
- Supports local song playback for standalone visual metering review.
- Includes impulse-pattern test modes for visual stress and movement checks.
- Imports and exports SpatGRIS/SPAT speaker-layout XML files.
- Imports SpatGRIS source-layout XML and project source metadata.
- Can listen to review-only `/spat/serv` source-position movement for layout review.
- Preserves physical speaker channel identity instead of sorting or reordering channels.
- Keeps local review playback separate from production host audio and routing.
- Provides Swift package targets for host-app integration.

## Current App

The active user-facing app is the native macOS review app:

```text
OrbitalViewViewer
```

Run the packaged local app with:

```sh
./Open\ Orbital\ View.command
```

That launcher rebuilds the viewer, refreshes the local `.app` executable and resource bundle, restarts stale viewer processes, and opens the current app. `Open Orbital View Kit.command` remains only as a compatibility wrapper.

You can also run the executable directly through SwiftPM:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run OrbitalViewViewer
```

## Standalone Modes

Orbital View can be useful without any host app connected.

Telemetry mode is the intended live-host mode. It defaults to no provider until a real publisher is available, so it should not be treated as proven live Orbisonic telemetry yet.

Local Song mode lets you choose an audio file and play it through the review app. The app reduces the file's audio energy into a visual meter signal so you can inspect how the speaker VU behavior feels.

Impulse Test mode generates deterministic meter patterns such as ripples, waves, and orbiting comets. These are visual test signals, not production audio.

## Host Integration

Orbital View is designed to connect to the SonicSphere app family through prepared viewport data.

Host apps own playback, routing, realtime callbacks, hardware I/O, channel mapping, source selection, meter extraction, and transport. Orbital View consumes already-prepared display snapshots:

- speaker layouts
- speaker meter frames
- source object positions
- source object meters
- source metadata
- camera and selection state
- diagnostics

This keeps the viewport responsive without putting audio timing or routing decisions inside the graphics package.

## Layout Files

The current layout path centers on SpatGRIS/SPAT XML:

- receiver speaker `SPEAKER_SETUP` XML import
- source-position `SPEAKER_SETUP` XML import
- normalized speaker/source XML export
- `SPAT_GRIS_PROJECT_DATA` source metadata import
- review-only `/spat/serv` source movement parsing

The parser rejects unsafe or malformed XML, oversized files, duplicate IDs, invalid coordinate tuples, invalid modes, and invalid UDP ports. Receiver speaker IDs are preserved as physical channel IDs.

## Graphics And Performance

The current visible review app is a native SceneKit surface tuned for interactive review. Recent performance work keeps the ribbed sphere batched, avoids unnecessary material rewrites, and keeps meter updates separate from static speaker geometry.

Current operator status:

```text
60 FPS on an M1 MacBook: confirmed
Menus: solid
Hidden Lines: working across the current review surface
Fog: needs another visual pass
Live Orbisonic telemetry: wired at source/test level, not yet proven end to end
```

## Current Gaps

- Fog needs more visual polish.
- The older `Prism` and `Sphere` speaker types are still present and should be removed if Cube VU remains the current speaker path.
- A new radial-fountain VU speaker type is planned.
- Live Orbisonic telemetry still needs a real provider-to-review-app verification run.

## Swift Package Targets

```text
OrbitalViewCore            Pure scene, speaker, meter, camera, and validation contracts
OrbitalViewWavefield       Wavefield-style layout and meter adapters
OrbitalViewSpatGRIS        SpatGRIS XML/project/OSC payload parsing helpers
OrbitalViewRender          MetalKit production renderer seam
OrbitalViewSwiftUI         SwiftUI host wrapper around the renderer seam
OrbitalViewReview          Review-only SceneKit, local audio, theme, export, and layout UI
OrbitalViewTelemetry       Telemetry consumer path for prepared meter sources
OrbitalViewViewerSupport   Testable viewer and stress fixture support
OrbitalViewViewer          Native macOS review executable
```

Production hosts should integrate through `OrbitalViewSwiftUI` and `OrbitalViewRender`. The review app is intentionally separate because it owns local playback, file dialogs, PNG export, bundled fonts, app-bundle themes, and review-only network listening.

## Build And Test

This package targets macOS 13 or newer and uses Swift tools version 5.9.

Use the full Xcode toolchain:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Useful focused checks:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSpatGRISTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewRenderTests
git diff --check
```

## Repository Guide

```text
Sources/OrbitalViewCore/          Core contracts and validation
Sources/OrbitalViewWavefield/     Wavefield data adapters
Sources/OrbitalViewSpatGRIS/      SpatGRIS XML/project/OSC parsers
Sources/OrbitalViewRender/        MetalKit renderer seam
Sources/OrbitalViewSwiftUI/       SwiftUI production wrapper
Sources/OrbitalViewReview/        SceneKit review app surface
Sources/OrbitalViewTelemetry/     Prepared telemetry consumer support
Sources/OrbitalViewViewer/        Native review executable
Sources/OrbitalViewViewerSupport/ Testable viewer fixture support
Tests/                            Unit, renderer, wrapper, review, and adapter tests
docs/                             Architecture, contracts, status, and integration docs
mockups/                          Disposable browser mockup
work-packages/                    Project planning packages
openspec/                         OpenSpec change records
```

Start with:

```text
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/implementation-map.md
docs/test-strategy.md
docs/status.md
docs/project-identity.md
```
