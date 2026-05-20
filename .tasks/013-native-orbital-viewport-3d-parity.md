# Task 013: Native Orbital Viewport 3D Parity

## Status

```text
complete
```

## Goal

Rebuild the rejected native viewer as a real native SwiftUI 3D version of `mockups/orbital-view-viewport/index.html`, preserving the web screen's controls, layout roles, defaults, and interaction contract.

## Background

The browser mockup is the visual and control source of truth for this slice. The native app must not be a flat screenshot or WebView. It should keep the same left control rail, center viewport, right inspector, footer status, Purple/Prism/Isometric defaults, Fey 30 speaker identity, fake meter stream, camera controls, color schemes, speaker shape controls, speaker size, fog density, speaker numbers, hidden lines, selection inspector, meter list, spin, zoom, drag orbit, and PNG export.

## Relevant Docs

```text
AGENTS.md
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/status.md
docs/bugs.md
work-packages/orbital-view-kit/MV.md
```

## Scope

Implement:

- A native SwiftUI shell matching the web mockup's three-column viewport layout and footer.
- A native 3D SceneKit viewport using Fey 30 speaker coordinates, 3V geodesic shell counts, prism/sphere speaker geometry, fake meter stream colors, fog, hidden-line visibility, labels, selection, orbit drag, spin, zoom, and PNG export.
- A standalone app entrypoint named `Orbital View VU Kit`.
- A double-click root launcher for the native app.

Update:

- Project docs and status.
- SwiftUI tests for the native viewport contract.

Add tests for:

- Web chrome contract constants.
- Camera/color/shape control options.
- Fey 30 snapshot and meter-stream contract.

## Out of Scope

Do not:

- Change Wavefield, Orbisonic, Splat, audio, playback, routing, MIDI, or OSC behavior.
- Replace the production `OrbitalViewRender` backend.
- Add WebView or browser dependencies.
- Treat the fake demo meter stream as production input.

## Contract References

```text
docs/contracts.md#orbitalviewswiftui-contract
docs/contracts.md#standalone-viewer-contract
```

## Protected Path Check

This task:

```text
does
```

touch protected paths.

Permitted protected paths:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

## Expected Files

```text
Sources/OrbitalViewSwiftUI/OrbitalViewportMockup.swift
Sources/OrbitalViewViewer/OrbitalViewViewer.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
scripts/build-orbital-viewer-app.sh
Open Native Orbital View VU Kit.command
docs/status.md
```

## Acceptance Criteria

- The standalone app opens to the native 3D viewport screen, not the old viewer shell.
- The visible controls match the web mockup control set.
- The viewport is actual native 3D speaker/shell geometry.
- Relevant tests pass or blockers are documented.
- Relevant docs are updated.
- `docs/status.md` is updated.

## Verification Commands

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=.build/clang-module-cache SWIFTPM_CACHE_DIR=.build/swiftpm-cache swift test --disable-sandbox --filter OrbitalViewSwiftUITests/testOrbitalViewport
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist
open -n Orbital\ View\ VU\ Kit.app
```
