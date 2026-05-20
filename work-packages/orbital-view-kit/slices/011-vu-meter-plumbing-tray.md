# Slice 011: VU Meter Plumbing And Settings Tray

## Status

```text
complete
```

## Goal

Add reusable VU meter visual plumbing for physical speaker channels and expose a SwiftUI collapsible display-settings tray.

## Scope

Done:

- Add pure core display settings for meter visual gain, default checker pulse/ring/diagonal wave style, color scheme, and checker controls.
- Keep visual gain as display-only state, not audio gain.
- Add renderer state and draw-input plumbing for the meter visual settings.
- Preserve physical channel identity when mapping 30 channel-keyed meter levels to scene speakers.
- Keep missing channels silent/default and ignore extra meter channels not represented in the scene.
- Add a source-compatible tray-free `OrbitalView` path.
- Add a new settings-bound `OrbitalView` initializer with a collapsed bottom tray containing Visual Gain, Style, Color Scheme, and checker controls.
- Update active docs and work-package state.

Do not:

- add production VU animation
- resize speaker geometry for meter behavior
- add shell rendering, labels, hit testing, gestures, or toolbar controls
- touch Wavefield, Orbisonic, or Splat source
- touch audio, playback, routing, MIDI, OSC, or host metering paths
- add new dependencies

## Protected Path Check

This slice explicitly permits:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

This slice does not permit:

```text
downstream app source paths
audio, playback, routing, MIDI, OSC, or metering paths
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
