# Slice 005: Renderer Backend Decision

## Status

```text
complete
```

## Goal

Choose the production renderer backend so the next implementation slice can add native renderer scaffolding without reopening the backend question.

## Scope

Do:

- Accept MetalKit / MTKView as the production renderer backend.
- Keep `OrbitalViewCore` backend-neutral.
- Place SwiftUI in a wrapper target above the renderer.
- Keep DomeLab as visual reference and future neutral geometry source only.
- Update project-control docs.

Do not:

- write renderer source
- write SwiftUI wrapper source
- add Metal shader files
- add SceneKit, RealityKit, WebView, or third-party renderer dependencies
- touch downstream app paths

## Protected Path Check

This slice:

```text
does not touch protected paths
```

## Verification

```text
docs/decisions/0002-renderer-backend.md exists
manifest.json parses
Swift package still builds and tests
```
