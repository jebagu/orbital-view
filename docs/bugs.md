# Bug List

## Open Bugs

```text
none
```

## Fixed Bugs

```text
2026-05-20 - Standalone Swift viewer launcher opened the SwiftPM executable through Terminal, could fail when SwiftPM tried to write user-level Clang cache files, and exposed camera buttons that only changed renderer camera state while renderer-native camera projection is still deferred, making the viewer feel broken. Fixed by generating/opening a local `Orbital View Viewer.app` bundle with build caches forced under `.build`, switching the viewer to accepted Fey 30 coordinates, and applying viewer-level Plan/Front/Side/Iso scene transforms with a lighter shell-guide overlay.

2026-05-20 - Cube VU browser mockup could feel laggy or freeze intermittently. Root cause was main-thread canvas churn: cube tile geometry, palette stop arrays, RGB conversions, and a dense waveform path were rebuilt repeatedly during redraw. Fixed by caching cube geometry and palette/RGB conversions, reducing analyser FFT size, down-sampling the visible meter waveform, reducing spectrum bars, and lowering canvas redraws to 24 fps. Also fixed scalar confusion by making `vuScalar` equal the RMS percent exactly instead of using gain/compression/release smoothing.
```

## Deferred Suspicions

```text
none
```
