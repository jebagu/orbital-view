# Orbital View

Orbital View is the canonical head project for the native spherical speaker viewport. It is a Swift package for rendering and reviewing spatial-audio speaker viewports while keeping scene data, speaker identity, meter telemetry, rendering, host wrappers, and review tooling separated so host applications can feed prepared viewport snapshots without giving the viewport ownership of playback, routing, or realtime audio callbacks.

Current release identity:

```text
Orbital View 1.0
```

Historical names such as Orbital View Kit, Orbital View VU Kit, Orbital View Turbo, and orbital-view-with-objects are now non-head variation labels. The canonical project identity is tracked in `docs/project-identity.md`.

The package currently includes:

- pure Swift scene and telemetry contracts
- Wavefield and SpatGRIS adapters for layout and meter/source data
- a MetalKit renderer seam for production host integration
- a SwiftUI wrapper around the renderer seam
- a native macOS SceneKit review app for tuning the visible viewport
- test fixtures and diagnostics for display-rate telemetry behavior

## Current Review App

The active visual review surface is `OrbitalViewViewer`, a native macOS app that hosts `OrbitalViewportMockup` from the `OrbitalViewReview` target.

The review app currently supports:

- a spherical 30-channel Sonic Sphere speaker viewport
- Prism, Sphere, and Cube VU speaker types
- retained SceneKit Cube VU face textures with 9x9 pixel-style faces
- Sonic Sphere speaker palette and separate Source Speaker palette controls
- ribbed speaker sphere overlay with independent geodesic palette and saturation
- optional ground grid with visibility, spacing, and palette controls
- speaker number labels with bundled review fonts and font-size tuning
- SpatGRIS speaker setup import/export and saved layout defaults
- SpatGRIS source setup and project metadata import
- review-only `/spat/serv` source movement listening on a validated UDP port
- Telemetry, Local Song, and Impulse Test source modes
- local audio file loading for visual testing
- impulse ripple, wave, and orbiting-comet meter patterns
- `Roll the dice on looks` visual randomization
- saved visual themes in app-bundle resources
- full-window PNG export
- bottom-right FPS chip with status color and actual FPS
- capped in-app Diagnostics log, including FPS samples and source/layout warnings

The review app is for visual review, tuning, and operator workflow validation. Production hosts should use `OrbitalViewSwiftUI` and `OrbitalViewRender`.

## Package Targets

```text
OrbitalViewCore
OrbitalViewWavefield
OrbitalViewSpatGRIS
OrbitalViewRender
OrbitalViewSwiftUI
OrbitalViewReview
OrbitalViewViewer
OrbitalViewViewerSupport
```

### OrbitalViewCore

Pure Swift data contracts and validation for:

- canonical Z-up 3D coordinates
- speaker anchors and physical channel identity
- scene specs
- speaker meter frames
- source object frames and source meter frames
- telemetry source descriptors
- camera and selection state
- visual stress diagnostics

`OrbitalViewCore` has no dependency on SwiftUI, AppKit, MetalKit, SceneKit, AVFoundation, MIDI, OSC, playback, routing, or downstream app targets.

### OrbitalViewWavefield

Adapter code for Wavefield-style data:

- speaker-layout JSON to `OrbitalViewCore` scene data
- channel/rms/peak records to `SpeakerMeterFrame`
- physical channel order preservation
- source descriptor labeling for external Wavefield streams and local livestream generator profiles

Wavefield remains the owner of stream parsing, realtime queues, audio rendering, route validation, meter extraction, and performance gates.

### OrbitalViewSpatGRIS

SpatGRIS layout and source parsing utilities:

- current and legacy `SPEAKER_SETUP` XML import
- normalized speaker/source setup export
- `SPAT_GRIS_PROJECT_DATA` source metadata import
- `/spat/serv` source-position message parsing
- diagnostics for unsafe XML, invalid tuples, duplicate IDs, invalid modes, invalid ports, and oversized files

This target parses payloads and validates data. It does not open sockets or own UI.

### OrbitalViewRender

The production renderer seam:

- MetalKit / MTKView direction
- retained renderer state
- separated scene, meter, camera, selection, and object update paths
- instanced cube/prism speaker draw inputs
- offscreen smoke tests and pixel probes
- retained-buffer and static-geometry invariants

The renderer consumes validated core data. It does not own audio, playback, routing, file parsing, or source transport.

### OrbitalViewSwiftUI

SwiftUI host wrapper around `OrbitalViewRender`:

- `OrbitalView`
- `NSViewRepresentable` MetalKit bridge
- camera and selection bindings
- optional tuning surface bindings for visual settings and performance controls

This is the intended production host integration surface.

### OrbitalViewReview

Review-only visual tooling:

- SceneKit viewport
- local audio file playback for visual testing
- review impulse generators
- app-bundle theme JSON
- SpatGRIS saved layout stores
- review-only UDP listener
- PNG export
- bundled font registration
- diagnostics UI

This target intentionally uses AppKit, SceneKit, AVFoundation, CoreText, UniformTypeIdentifiers, and Network APIs that production host wrappers should not inherit.

### OrbitalViewViewer

Native executable for the current review app.

Run it through SwiftPM:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run OrbitalViewViewer
```

For the local packaged review app, use:

```sh
./Open\ Orbital\ View.command
```

That launcher rebuilds `OrbitalViewViewer`, refreshes the local `.app` executable and review resource bundle, restarts stale viewer processes, and opens the latest review app. `Open Orbital View Kit.command` remains as a compatibility wrapper only.

## Coordinate System

Orbital View uses canonical Z-up coordinates:

```text
x = right / left
y = front / back
z = up / down
```

Renderer and review targets may map canonical coordinates into framework-specific spaces at render boundaries. They must not permanently flatten or reorder spatial data.

## Telemetry And Realtime Boundary

Orbital View is a viewport package, not an audio engine.

It can consume prepared display snapshots such as:

- speaker meters
- source object positions
- source object meters
- source descriptors
- display diagnostics

It must not:

- run audio callbacks
- schedule playback
- make output routing decisions
- parse raw realtime packets in the renderer
- block timing-sensitive host paths
- allocate, log, or post UI from audio callbacks
- reorder physical speaker channels

Display telemetry uses latest-complete-frame-wins semantics. Stale display frames may be dropped or decimated, and overload diagnostics are set outside realtime paths.

## Review Diagnostics

The review app includes a capped in-app Diagnostics log. It records events such as:

- source mode changes
- layout import/export issues
- OSC/source parsing diagnostics
- settings/theme save/load messages
- speaker selection changes
- FPS samples

The FPS meter measures actual review viewport render/update cadence. Status thresholds are:

```text
target:       >= 60 FPS
below target: 30..<60 FPS
under target: < 30 FPS
```

The visible chip only shows a status color dot and the current FPS value. The Diagnostics log keeps the target/status details.

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
Sources/OrbitalViewViewer/        Native review executable
Sources/OrbitalViewViewerSupport/ Testable viewer fixture support
Tests/                            Unit, renderer, wrapper, review, and adapter tests
docs/                            Architecture, contracts, status, and integration docs
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
```

## Current Next Work

- improve review viewport speed and rendering efficiency
- verify live telemetry works end to end
- qualify source movement and meter data against real host publishers
- continue keeping production host APIs separate from review-only tooling
