# Bug List

## Open Bugs

```text
none
```

## Fixed Bugs

```text
2026-05-22: Excite Comets and Impulse Test Orbiting Comets were too narrow and did not read clearly as moving VU trails. Fixed by replacing the old three-hotspot pattern with exactly two larger comets with broader heads and longer hot tails, shared by both the impulse source and audio-excited comet mode. Regression coverage now asserts two broad hot trails, multiple active speakers, and mono-envelope excitation.

2026-05-22: Speaker Height was visible in the Speaker Shape tray even though it no longer provided a useful review-app control. Fixed by removing the control, normalizing old saved `speakerHeight` values to the current flat cube geometry path, and excluding height from review-app geometry/material update keys.

2026-05-22: In the SceneKit review app's Meter Source tray, choosing Music could appear to leave the active source on the impulse mode. Fixed by simplifying the source setter, expanding explicit source states, and verifying in the relaunched app that the Active Meter row and footer switch to Music source after clicking Music. Regression coverage now asserts the updated source inventory and deterministic impulse variants.

2026-05-22: Jost speaker labels sometimes rendered 6/9 as dot-like glyph fragments in SceneKit. Root cause was the Jost digit outlines being brittle in the `SCNText` geometry path; switching from the variable TTF to the static `Jost-Regular.ttf` resource was necessary but not sufficient. Fixed by keeping `Jost-Regular.ttf` and rendering Jost speaker labels as AppKit-generated text textures on billboard planes, bypassing SceneKit glyph tessellation for that font. Regression coverage now asserts the Jost font resource, numeric label strings for channels containing 6 and 9, and the texture-backed label path.

2026-05-22: Minecraft speaker-label zeroes rendered like colon glyphs after the bundled Minecraft font started loading correctly. Root cause was the font's digit-zero glyph rendering poorly in the SceneKit label path. Fixed by using a Minecraft-only display-text fallback that substitutes `O` for `0` in speaker labels while preserving channel identity and leaving all other label fonts numeric.

2026-05-22: Speaker Labels font selector changed the selected setting but on-screen labels stayed in the system font. Root cause was SwiftPM flattening processed font resources into the resource bundle root while the CoreText font registry only searched a Fonts subdirectory, so all non-system font selections fell back silently. Fixed by resolving font resources from either the Fonts subdirectory or the bundle root and adding a regression test that verifies the actual NSFont PostScript names for Press Start 2P, Minecraft, and Chintzy CPU BRK.

2026-05-21: Cube VU speakers in the SceneKit review app appeared as solid purple cubes and showed an unintended cubical halo. Fixed by removing the separate halo SCNBox child nodes and driving the actual six SCNBox cube faces with a retained 9x9 pixelated face texture cache, while preserving material-only meter updates and avoiding overlay face planes.
```

## Deferred Suspicions

```text
none
```
