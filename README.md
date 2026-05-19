# Orbital View Kit

Orbital View Kit is the project-control scaffold for `OrbitalViewKit`, a reusable 3D spherical speaker viewport planned for Wavefield, Orbisonic, and Splat.

The first implementation milestone is deliberately small: create `OrbitalViewCore`, a pure Swift foundation for scene contracts, shell geometry, speaker identity, meter frames, camera state, validation, and Wavefield layout adaptation tests.

## Current State

This repository currently contains docs, tasks, OpenSpec templates, reviewer guidance, and the initial work package. It does not contain Swift package source code yet.

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

## First Implementation Target

```text
OrbitalViewCore
```

The first code task should not build a renderer. It should create pure data contracts and validation that can later support native SwiftUI/MetalKit rendering and downstream app integrations.

## Out of Scope For Initial Scaffold

- Swift package source code
- Production renderer
- SwiftUI wrapper
- MetalKit integration
- WebView integration
- DomeLab code import
- Wavefield, Orbisonic, or Splat source modifications
- GitHub remote or publishing setup

## Expected Future Checks

Once Swift source exists:

```text
swift build
swift test
```

For the current scaffold-only state, those commands are not applicable.

