# Bug List

## Open Bugs

```text
2026-05-30: Visible SceneKit review app performance remains below target after 120/30 hot-path work.

Current status: prior 120/30 and Cube VU hot-path work did not produce a sufficient user-visible performance improvement. The dense ribbed dome root cause is now addressed in code by replacing thousands of per-segment SceneKit cylinder nodes with two batched mesh nodes, but this bug remains open until the normal visible review app is relaunched from the Turbo checkout and the user-visible FPS/feel is confirmed.

Latest verification: the 2026-05-30 ribbed batching pass relaunched through `/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command`, and `pgrep -fl OrbitalViewViewer` confirmed PID `8456` running from `/Users/jeremyguillory/Documents/vibecode projects/Orbital View Turbo/.../OrbitalViewViewer`. The remaining open condition is user-visible interactive confirmation, especially with the ribbed sphere visible at default, medium, and max density.

Failed attempts and non-representative evidence to avoid repeating:
- 120/30 cadence contract work did not produce the user-visible performance improvement: instrumentation, 120 FPS active settings, 30 FPS meter cadence, source/material key splitting, and Cube VU material cadence decoupling improved source-level behavior but did not make the visible app feel faster enough.
- Cube VU material-write reduction did not solve visible FPS: caching material keys, skipping repeated texture assignments/uniform writes, removing unused KVC shader-uniform writes, and avoiding camera-only Cube VU texture requests reduced known hot paths but left visible performance unsatisfactory.
- Moving the FPS chip out of SwiftUI did not solve the visible issue: SwiftUI layout samples improved, but the user still reported roughly `35-37 FPS`, with sampling pointing at SceneKit render queue cost.
- Disabling SceneKit multisampling did not produce enough visible improvement, even though it reduced one renderer setting.
- Headless/offscreen benchmark results were not representative of user-visible performance: active offscreen SceneKit rendered around `200 FPS`, but the actual windowed app still felt slow.
- `--headed-benchmark` showed an active-spin FPS chip around `120`, but that did not prove normal interactive/default review-app performance was fixed.
- Packed/single-node cube-outline and softer backing-scale visual experiments were rejected because they changed the approved Cube VU speaker look; the app was restored to the twelve-edge outline look.
- A live process check found `OrbitalViewViewer` running from sibling `orbital-view-with-objects`, so future performance verification must first prove the running app path is `/Orbital View Turbo/`.

Next required verification gate:
- Test normal interactive/default review-app behavior with the ribbed sphere visible at default, medium, and max density before closing this bug.
```

## Fixed Bugs

```text
2026-05-30: Dense Ribbed Speaker Sphere caused avoidable SceneKit render/update cost. Root cause was the review app modeling the ribbed dome as one SceneKit cylinder node per generated rib/ring segment, with default density about 1,152 segments and max density about 8,192 segments. Fixed the source-level model by batching ribs into two SceneKit mesh nodes, one for vertical ribs and one for horizontal rings, and by removing camera state from the ribbed material update key so camera-only motion no longer loops through segment visibility/material writes. Added benchmark flags for ribbed default/medium/max density and regression tests for segment counts, two-node batching, camera-only update skips, topology rebuilds, and batched material writes.

2026-05-27: The native SceneKit review app's left rail could clip the `Source` header and first source-selector segment at the physical window edge after adding the top-left Telemetry / Local Song / Impulse Test selector. Root cause was that the hidden-titlebar review window kept the left rail tight to the window edge while the new three-segment selector needed more horizontal room than the old local-song block. Fixed by widening the review rail and adding an explicit left window-edge inset before rail controls render. Regression coverage now asserts the wider rail and edge inset constants.

2026-05-27: The refreshed app could reopen on `Impulse Test` even though the new review default source is `Telemetry`, because the default saved theme was older JSON without `sourceMode` and its legacy impulse `driveMode` was used as the source fallback during startup. Fixed by tracking whether `sourceMode` was explicit in decoded settings and preferring the review default only for missing-source default-theme startup, while preserving legacy inference for explicit old-theme loads. Regression coverage now asserts both paths.

2026-05-25: The native SceneKit review viewport projected the canonical left/right axis backward after the Z-up conversion, and the visible SceneKit drag callback still used the old horizontal yaw sign. Fixed by computing the review projection horizontal basis from view direction cross up after pitch is applied and routing native/fallback drag handling through the corrected orbit-state helper, leaving speaker data, the Z-up contract, and the SceneKit coordinate bridge unchanged. Regression coverage now asserts canonical `+X` projects to screen right and `-X` projects to screen left for all review camera presets, plus rightward and leftward drags move yaw in the expected directions.

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
2026-05-24: After the optional Grid Plane review-viewport change, the native SceneKit graphics may have looked slow or choppy during visual verification. This is not yet confirmed as a regression because the laptop may have been on low battery. Re-QA the relaunched review app on shore power with Grid Plane off, default visibility, high visibility, spacing extremes, and alternate ground palettes before treating it as a renderer performance bug, especially now that the ground plane is 10 x 10 canonical units.
```
