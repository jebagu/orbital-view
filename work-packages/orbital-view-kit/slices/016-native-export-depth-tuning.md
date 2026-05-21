# Slice 016: Native Export And Depth Tuning

## Status

```text
complete
```

## Goal

Refine the standalone native SwiftUI/SceneKit review app export and depth rendering after visual review.

## Scope

Done when this slice:

- Exports the whole visible native application window as PNG.
- Does not export only the transparent SceneKit viewport.
- Keeps the approved UI layout and visual language unchanged.
- Makes speaker number labels visually larger, with their font contract tied to the left-rail control-button size.
- Makes shell struts and node markers 1.5x thicker.
- Keeps rear shell struts faintly visible under fog instead of clipping them completely by default.
- Attenuates rear speaker alpha/emission more strongly so rear speakers do not overpower rear shell structure.
- Adds focused tests for export scope, scene tuning constants, and fog/depth balance.

Out of scope:

- UI redesign.
- Public API changes.
- Browser mockup edits.
- Production Metal renderer work.
- Downstream host, audio, routing, MIDI, OSC, or playback changes.

## Protected Path Check

This slice explicitly permits:

```text
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

This slice does not permit:

```text
Sources/OrbitalViewRender/
downstream app source paths
audio, playback, routing, MIDI, OSC, or metering paths
```

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter OrbitalViewSwiftUITests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
zsh -n scripts/build-orbital-viewer-app.sh
scripts/build-orbital-viewer-app.sh
plutil -lint Orbital\ View\ VU\ Kit.app/Contents/Info.plist
open -n Orbital\ View\ VU\ Kit.app
git diff --check
```

## Result

```text
Implemented. The native app keeps the approved UI while exporting the visible window and improving rear-depth visual balance.
```
