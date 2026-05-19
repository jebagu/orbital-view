# Orbital View Kit

Orbital View Kit is the project-control scaffold for `OrbitalViewKit`, a reusable 3D spherical speaker viewport planned for Wavefield, Orbisonic, and Splat.

The first implementation milestone is deliberately small: create `OrbitalViewCore`, a pure Swift foundation for scene contracts, shell geometry, speaker identity, meter frames, camera state, validation, and Wavefield layout adaptation tests.

## Current State

This repository contains docs, tasks, OpenSpec templates, reviewer guidance, the initial work package, the pure Swift `OrbitalViewCore` target, and the local `OrbitalViewWavefield` layout JSON adapter target.

## Main References

```text
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/test-strategy.md
docs/status.md
work-packages/orbital-view-kit/MV.md
work-packages/orbital-view-kit/orbital-view-kit-codex-work-package.md
```

## Implemented Core Target

```text
OrbitalViewCore
```

`OrbitalViewCore` provides pure data contracts and validation that can later support native SwiftUI/MetalKit rendering and downstream app integrations.

`OrbitalViewWavefield` reads the current Wavefield speaker-layout JSON shape into `OrbitalViewCore` scenes without depending on or editing the Wavefield app package.

## Still Out of Scope

- Production renderer
- SwiftUI wrapper
- MetalKit integration
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
