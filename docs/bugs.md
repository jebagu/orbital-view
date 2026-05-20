# Bug List

## Open Bugs

```text
none
```

## Fixed Bugs

```text
2026-05-21 - Standalone native Orbital View VU Kit polish regressions remained after the first native-control pass: fog density 0 could hide the model instead of disabling fog, spin could drift vertically in non-front presets, Speaker Size and Fog Density still exposed an unwanted extra slider line/value treatment, switches were not column-aligned, export feedback was unclear, vertical drag direction and mouse-wheel zoom direction did not match the requested feel, and full-width buttons had been replaced with compact controls. Fixed by adding an explicit disabled fog configuration, screen-space camera-basis spin, a single-track Orbisonic slider row, aligned native switch rows, restored full-width button groups, asynchronous Desktop PNG export confirmation, swapped vertical drag, and swapped wheel zoom.

2026-05-21 - Standalone native Orbital View VU Kit controls drifted toward the web mockup skin, sliders showed a duplicate/custom track look, right-side rows could visually resize with meter fills, spin/drag could jump because spin was derived from absolute time, and SceneKit fog felt attached to the model because the content root rotated and manual depth alpha fading was applied. Fixed by using Orbisonic-design-language native controls, fixed rails, row-local meter fills, anchored spin/drag math, camera orbit around static content, and SceneKit camera-space fog without fog-driven material fades.

2026-05-20 - Rejected native Cube VU workbench/launcher did not match the requested Orbital viewport web screen and was not the desired native 3D implementation. Fixed by removing the Cube VU workbench/launcher changes, adding a native SwiftUI/SceneKit 3D `OrbitalViewportMockup` matched to `mockups/orbital-view-viewport/index.html`, changing the standalone app to `Orbital View VU Kit.app`, and adding `Open Native Orbital View VU Kit.command`.

2026-05-20 - Standalone Swift viewer launcher opened the SwiftPM executable through Terminal, could fail when SwiftPM tried to write user-level Clang cache files, and exposed camera buttons that only changed renderer camera state while renderer-native camera projection is still deferred, making the viewer feel broken. Fixed by generating/opening a local `Orbital View Viewer.app` bundle with build caches forced under `.build`, switching the viewer to accepted Fey 30 coordinates, and applying viewer-level Plan/Front/Side/Iso scene transforms with a lighter shell-guide overlay.

2026-05-20 - Cube VU browser mockup could feel laggy or freeze intermittently. Root cause was main-thread canvas churn: cube tile geometry, palette stop arrays, RGB conversions, and a dense waveform path were rebuilt repeatedly during redraw. Fixed by caching cube geometry and palette/RGB conversions, reducing analyser FFT size, down-sampling the visible meter waveform, reducing spectrum bars, and lowering canvas redraws to 24 fps. Also fixed scalar confusion by making `vuScalar` equal the RMS percent exactly instead of using gain/compression/release smoothing.
```

## Deferred Suspicions

```text
none
```
