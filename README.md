# Orbital View Kit

Orbital View Kit is the project-control scaffold for `OrbitalViewKit`, a reusable 3D spherical speaker viewport planned for Wavefield, Orbisonic, and Splat.

The first implementation milestone is deliberately small: create `OrbitalViewCore`, a pure Swift foundation for scene contracts, shell geometry, speaker identity, meter frames, camera state, validation, and Wavefield layout adaptation tests. A disposable viewport mockup previews the intended monitor interaction, and the native renderer now has its first offscreen smoke-tested Metal draw path with static draw-input invariant coverage.

## Current State

This repository contains docs, tasks, OpenSpec templates, reviewer guidance, the initial work package, the pure Swift `OrbitalViewCore` target, the local `OrbitalViewWavefield` adapter target, the `OrbitalViewRender` MetalKit renderer seam with an offscreen smoke-tested draw path and static draw-input invariant tests, the compile-only `OrbitalViewSwiftUI` wrapper skeleton, a static browser mockup for the spherical monitor viewport, and an accepted MetalKit renderer-backend decision.

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
```

## Implemented Targets

```text
OrbitalViewCore
OrbitalViewWavefield
OrbitalViewRender
OrbitalViewSwiftUI
```

`OrbitalViewCore` provides pure data contracts and validation that can later support native SwiftUI/MetalKit rendering and downstream app integrations.

`OrbitalViewWavefield` reads the current Wavefield speaker-layout JSON shape into `OrbitalViewCore` scenes and maps Wavefield-style channel/rms/peak records into `SpeakerMeterFrame` values without depending on or editing the Wavefield app package.

`OrbitalViewRender` establishes the first MetalKit seam with renderer state, scene/meter/camera update methods, selection events, an `MTKViewDelegate` path, and a minimal Metal draw pipeline verified by an offscreen smoke test. Renderer invariant tests verify meter and camera updates do not change static speaker draw inputs. Full production visuals remain deferred.

`OrbitalViewSwiftUI` exposes a public `OrbitalView` SwiftUI view and bridges the MetalKit renderer seam through `NSViewRepresentable`. It does not include controls, gestures, or inspector UI yet.

## Current Mockup

```text
mockups/orbital-view-viewport/index.html
```

This is a disposable static mockup with fake speaker positions and fake meter animation. It is not production renderer source.

## Renderer Backend

```text
docs/decisions/0002-renderer-backend.md
```

The accepted production renderer direction is a custom MetalKit / MTKView backend in `OrbitalViewRender`, with SwiftUI wrapping in a separate future `OrbitalViewSwiftUI` target.

## Still Out of Scope

- Full production drawing implementation
- SwiftUI controls, gestures, and inspector UI
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
