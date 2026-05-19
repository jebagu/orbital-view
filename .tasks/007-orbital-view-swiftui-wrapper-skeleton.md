# Task 007: OrbitalViewSwiftUI Wrapper Skeleton

## Status

```text
complete
```

## Goal

Add a compile-only SwiftUI wrapper target above `OrbitalViewRender` without implementing production UI controls or renderer drawing.

## Scope

Implemented:

- `OrbitalViewSwiftUI` package product and target.
- Public `OrbitalView` SwiftUI view.
- Internal `OrbitalViewMetalView` `NSViewRepresentable` bridge around `MTKView`.
- Coordinator that applies scene, meter, camera, and selection configuration into `OrbitalViewMetalRenderer`.
- Tests proving wrapper initialization, no repeated structural updates for identical configuration, and event emission for camera/selection changes.

Out of scope:

- SwiftUI toolbar, controls, gestures, labels, or inspector UI.
- Production Metal draw loop.
- Metal shaders.
- Hit testing, picking, or camera drag behavior.
- Downstream app integration.
- Audio, playback, routing, MIDI, OSC, or metering changes.

## Protected Path Check

This task:

```text
touches Sources/OrbitalViewSwiftUI/ and Tests/OrbitalViewSwiftUITests/ as explicitly permitted by this wrapper skeleton task
does not touch downstream protected paths
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
