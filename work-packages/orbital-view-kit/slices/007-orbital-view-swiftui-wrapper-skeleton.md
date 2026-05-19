# Slice 007: OrbitalViewSwiftUI Wrapper Skeleton

## Status

```text
complete
```

## Goal

Create the first SwiftUI wrapper target above the MetalKit renderer seam.

## Scope

Do:

- Add `OrbitalViewSwiftUI` as a Swift package product and target.
- Depend on `OrbitalViewCore` and `OrbitalViewRender`.
- Provide a public `OrbitalView` SwiftUI view.
- Bridge `OrbitalViewMetalRenderer` into SwiftUI through an `NSViewRepresentable`.
- Keep wrapper updates compile-focused and state-driven.
- Add tests for wrapper construction and coordinator update behavior.

Do not:

- add SwiftUI toolbar or inspector controls
- add gestures or camera interaction
- write Metal draw-loop code
- add shaders, materials, hit testing, or picking
- touch Wavefield, Orbisonic, or Splat source
- touch audio, playback, routing, MIDI, OSC, or metering paths

## Protected Path Check

This slice:

```text
allows Sources/OrbitalViewSwiftUI/
allows Tests/OrbitalViewSwiftUITests/
does not allow downstream protected paths
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
