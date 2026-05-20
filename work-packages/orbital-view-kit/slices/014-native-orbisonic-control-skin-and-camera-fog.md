# Slice 014: Native Orbisonic Control Skin And Camera Fog

## Status

```text
complete
```

## Goal

Refine the standalone native SwiftUI/SceneKit review app so it uses Orbisonic design language controls and native camera-space SceneKit behavior.

## Scope

```text
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewViewer/
Tests/OrbitalViewSwiftUITests/
project docs
```

## Completed

- Replace web-like control skin with Orbisonic-native dark lab controls.
- Restore the preferred full-width native button groups for camera, color, speaker shape, spin, reset, and export actions.
- Use Swift-native toggles and single-track cyan sliders with no extra underline and no inline numeric values for Speaker Size and Fog Density.
- Fix sliders by following Orbisonic's native title/value + tinted slider pattern.
- Keep left and right rails fixed while the SceneKit viewport flexes in the center.
- Orbit the camera around static content instead of rotating the content root, with stable start-pose drag math and swapped vertical drag direction.
- Use SceneKit fog directly, keep hidden-line visibility separate from fog, and treat density `0` as a hard disabled state.
- Fix drag, spin, speaker-number toggle, mouse-wheel zoom direction, and Desktop PNG export feedback behavior.

## Protected Paths

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

## Out of Scope

```text
Production Metal renderer replacement
Wavefield, Orbisonic, or Splat app integration
Audio callback, playback, routing, MIDI, or OSC changes
WebView/browser embedding
```
