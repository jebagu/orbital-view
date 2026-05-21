# Task 012: Required Control Surface And Geodesic Shell

## Goal

Promote the mockup-only viewport control surface into the reusable native SwiftUI kit and make the default scene path use the imported Fey 3V geodesic shell with speakers anchored to shell nodes.

## Scope

- Add native display settings for speaker shape, speaker size, fog density, speaker numbers, and hidden lines.
- Add the native SwiftUI control surface with Plan, Elevation, Isometric, Export PNG, speaker shape, speaker size, fog, speaker numbers, and hidden lines controls.
- Preserve the existing VU settings tray while making the viewport control surface part of normal `OrbitalView` use.
- Add a reusable imported Fey geodesic shell builder from the accepted DomeLab/Fey config values.
- Re-anchor default Wavefield/Fey speakers to nearest imported geodesic shell nodes instead of a parametric direction shell.
- Update renderer state so display settings are tracked separately from meter visual settings.
- Update tests and docs.

## Protected Path Touch

Allowed by this task:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

No downstream Wavefield, Orbisonic, Splat, audio, playback, metering, routing, MIDI, OSC, or render-pipeline paths may be changed.

## Required Checks

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

