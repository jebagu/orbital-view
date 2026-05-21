# Slice 015: Native VU Interaction And Fog Regression

## Status

```text
in progress
```

## Goal

Polish the standalone native SwiftUI/SceneKit review app by fixing hard-off fog, horizontal spin, slider chrome, switch alignment, and PNG export feedback.

## Scope

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
project docs
```

## Planned

- Add explicit disabled/enabled fog configuration, where slider `0` disables all fog and visibility fading.
- Rework camera basis math so all view presets spin horizontally in screen space.
- Replace visible-value slider rows with a Swift-native single-track Orbisonic slider.
- Align toggle switches in a fixed trailing column.
- Save PNG exports to Desktop and surface success/failure state.

## Protected Paths

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

## Out of Scope

```text
Production Metal renderer replacement
Wavefield, Orbisonic, or Splat app integration
Audio callback, playback, routing, MIDI, OSC, or output changes
WebView/browser embedding
```
