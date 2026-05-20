# Bug List

## Open Bugs

```text
none
```

## Fixed Bugs

```text
2026-05-20 - Cube VU browser mockup could feel laggy or freeze intermittently. Root cause was main-thread canvas churn: cube tile geometry, palette stop arrays, RGB conversions, and a dense waveform path were rebuilt repeatedly during redraw. Fixed by caching cube geometry and palette/RGB conversions, reducing analyser FFT size, down-sampling the visible meter waveform, reducing spectrum bars, and lowering canvas redraws to 24 fps. Also fixed scalar confusion by making `vuScalar` equal the RMS percent exactly instead of using gain/compression/release smoothing.
```

## Deferred Suspicions

```text
none
```
