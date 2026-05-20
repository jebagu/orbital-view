# Orbital View VU Kit

Orbital View VU Kit is the project-control scaffold for `OrbitalViewKit`, a reusable 3D spherical speaker viewport planned for Wavefield, Orbisonic, and Splat.

The first implementation milestone is deliberately small: create `OrbitalViewCore`, a pure Swift foundation for scene contracts, shell geometry, speaker identity, meter frames, camera state, validation, display-only VU settings, and Wavefield layout adaptation tests. Disposable browser mockups preview viewport and cube-VU directions, and the native renderer now has its first offscreen smoke-tested Metal draw path with static draw-input invariant coverage, 30-channel VU mapping, and the default checker pulse/ring/diagonal wave style.

## Current State

This repository contains docs, tasks, OpenSpec templates, reviewer guidance, the initial work package, the pure Swift `OrbitalViewCore` target, local `OrbitalViewWavefield` and `OrbitalViewOrbisonic` adapter targets, the `OrbitalViewRender` MetalKit renderer seam with an offscreen smoke-tested draw path, static draw-input invariant tests, and checker VU visual settings, the `OrbitalViewSwiftUI` wrapper with an opt-in settings tray and native 3D Orbisonic-style review screen, static browser mockups for the spherical monitor viewport and single-screen cube VU tuner, a standalone `OrbitalViewViewer` executable, and an accepted MetalKit renderer-backend decision.

## Main References

```text
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/renderer-test-harness.md
docs/test-strategy.md
docs/status.md
docs/decisions/0002-renderer-backend.md
work-packages/orbital-view-kit/MV.md
work-packages/orbital-view-kit/orbital-view-kit-codex-work-package.md
mockups/orbital-view-viewport/index.html
mockups/orbital-view-viewport/notes.md
mockups/sonicsphere-cube-vu-single-screen/index.html
mockups/sonicsphere-cube-vu-single-screen/notes.md
```

## Implemented Targets

```text
OrbitalViewCore
OrbitalViewWavefield
OrbitalViewRender
OrbitalViewSwiftUI
OrbitalViewViewerSupport
OrbitalViewViewer
```

`OrbitalViewCore` provides pure data contracts and validation that can later support native SwiftUI/MetalKit rendering and downstream app integrations.

`OrbitalViewWavefield` reads the current Wavefield speaker-layout JSON shape into `OrbitalViewCore` scenes and maps Wavefield-style channel/rms/peak records into `SpeakerMeterFrame` values without depending on or editing the Wavefield app package.

`OrbitalViewRender` establishes the first MetalKit seam with renderer state, scene/meter/meter-visual-settings/camera update methods, selection events, an `MTKViewDelegate` path, and a minimal Metal draw pipeline verified by an offscreen smoke test. Renderer invariant tests verify meter, meter visual settings, and camera updates do not change static speaker draw inputs. Full production visuals and animation remain deferred.

`OrbitalViewSwiftUI` exposes a public `OrbitalView` SwiftUI view and bridges the MetalKit renderer seam through `NSViewRepresentable`. It includes an opt-in collapsed bottom VU settings tray for display gain, style, color scheme, and checker controls. Gestures, toolbar controls, and inspector UI remain deferred.

`OrbitalViewViewer` launches `Orbital View VU Kit.app`, a native SwiftUI/SceneKit 3D version of `mockups/orbital-view-viewport/index.html` with the same controls, inspector, footer, Fey 30 fake meter stream, and local app launcher.

## Current Mockup

```text
mockups/orbital-view-viewport/index.html
mockups/sonicsphere-cube-vu-single-screen/index.html
```

These are disposable static mockups. The cube VU mockup can optionally analyze browser audio from a shared YouTube/tab capture or local audio file playback, but that path is still prototype-only and is not production renderer or Swift package source.

The pinned local server URL for the active single-screen cube VU mockup is:

```text
http://127.0.0.1:8765/OrbitalViewKit/
```

Double-click the launcher to open the live mockup file with a cache-busting URL:

```text
Open Orbital View Kit.command
```

Double-click the native launcher to open the SwiftUI/SceneKit 3D app:

```text
Open Native Orbital View VU Kit.command
```

## Renderer Backend

```text
docs/decisions/0002-renderer-backend.md
```

The accepted production renderer direction is a custom MetalKit / MTKView backend in `OrbitalViewRender`, with SwiftUI wrapping in a separate future `OrbitalViewSwiftUI` target.

## Still Out of Scope

- Full production Metal drawing implementation and VU animation/materials
- Production SwiftUI controls, gestures, and inspector UI beyond the current VU settings tray and standalone native mockup screen
- WebView integration
- DomeLab code import
- Wavefield, Orbisonic, or Splat source modifications
- GitHub remote or publishing setup

## Checks

Use the full Xcode toolchain when this shell's Command Line Tools install cannot find XCTest:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Current static mockup JavaScript parse checks:

```text
node -e 'const fs=require("fs"); for (const file of ["mockups/orbital-view-viewport/index.html", "mockups/sonicsphere-cube-vu-single-screen/index.html"]) { const html=fs.readFileSync(file,"utf8"); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]).join("\n"); new Function(scripts); } console.log("inline JS parses");'
```
