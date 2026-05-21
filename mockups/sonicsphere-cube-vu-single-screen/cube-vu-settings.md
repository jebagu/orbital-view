# Cube VU Settings Reference

This file records the browser mockup settings that control the cube VU behavior in
`index.html`. It is a tuning and implementation reference for the single-screen
Sonicsphere cube VU mockup, not a production Swift contract.

## Signal Path

Music mode keeps raw audio diagnostics separate from the cube display path:

```text
rawRms -> calibratedRms -> displayVuScalar -> cube bloom radius
rawRms -> calibratedRms -> hotScalar -> whole-cube hot fill
rawRms or impulse amplitude -> vuPaletteDrive -> palette heat
```

Formulas:

```text
calibratedRms = clamp01(rawRms * inputCalibration)
displayVuScalar = min(1 - pow(1 - calibratedRms, levelCompression), displayCeiling)
hotScalar = 1 - pow(1 - calibratedRms, hotResponse)
paletteHeat = 1 - pow(1 - clamp01(value), vuPaletteDrive)
```

At the default `inputCalibration = 1.00`, `levelCompression = 1.00`, and
`displayCeiling = 1.00`, `displayVuScalar` equals raw RMS exactly. The exported
`vuScalar` field remains a compatibility alias for `displayVuScalar`.

## Runtime Values

| Key | Meaning |
| --- | --- |
| `rawRms` | Raw Web Audio RMS value from the analyzer. |
| `rmsPercent` | Compatibility name for raw RMS. It is still a 0...1 scalar. |
| `calibratedRms` | Raw RMS after `inputCalibration` and clamping. |
| `displayVuScalar` | Display-only bloom scalar after level compression and display ceiling. |
| `vuScalar` | Compatibility alias for `displayVuScalar`. |
| `hotScalar` | Whole-cube hot-fill scalar from calibrated RMS and `hotResponse`. |
| `driveMode` | Exclusive source mode: `music` or `impulse`. |
| `audioSourceMode` | Browser-only audio source status such as idle, tab capture, or local file. |
| `paletteName` | Active palette used for cube chassis, panel, and VU colors. |
| `exportVariant` | Selected cube rendering variant for export. |

Peak and Bass are visible readouts in the browser UI, but they remain raw
diagnostics and do not drive cube bloom.

## Primary Music Controls

| UI label | Export key | Range | Default | Effect |
| --- | --- | --- | --- | --- |
| Input calibration | `inputCalibration` | `0.25...2.00` | `1.00` | Pre-compression RMS trim. Lower it when a source keeps the cubes too full. |
| Level compression | `levelCompression` | `1.00...4.00` | `1.00` | Lifts quiet and mid-level material for bloom detail while preserving raw RMS diagnostics. |
| Display ceiling | `displayCeiling` | `0.50...1.00` | `1.00` | Caps cube bloom after level compression without changing raw RMS or hot fill. |
| Hot response | `hotResponse` | `0.50...3.00` | `1.70` | Curves calibrated RMS into whole-cube hot-fill pressure. |
| Hot fill strength | `hotFillStrength` | `0.00...1.00` | `0.86` | Maximum strength of whole-cube hot-color takeover. |
| Hot threshold | `hotThreshold` | `0.35...0.98` | `0.68` | `hotScalar` level where whole-cube hot fill begins. |

Tuning workflow:

1. Raise `levelCompression` until quiet music has enough bloom detail.
2. Lower `inputCalibration` if ordinary RMS is calibrated too hot.
3. Lower `displayCeiling` if bloom radius should never reach full-face coverage.
4. Use `hotResponse`, `hotThreshold`, and `hotFillStrength` to decide when the
   whole cube should turn hot.
5. Use `vuPaletteDrive` only for palette heat; it should not fix level or hot
   fill calibration.

## Color And Surface Controls

| UI label | Export key | Range | Default | Effect |
| --- | --- | --- | --- | --- |
| Color range / compression | `vuPaletteDrive` | `0.50...4.00` | `1.70` | Compresses palette heat only. It does not change raw RMS, bloom radius, or hot fill. |
| Face pixels | `facePixels` | `6...14` | `9` | Tile grid resolution per visible cube face. |
| Idle tint | `idleTint` | `0.00...0.62` | `0.25` | Mix from panel color toward palette accent for idle cube faces. |
| Face phase stagger | `facePhaseStagger` | `0.000...0.180` | `0.040` | Small per-face time offset for dimensional movement. |
| Checker contrast | `checkerContrast` | `0.00...0.40` | `0.08` | Subtle tile-to-tile contrast. Keep low so the cube does not read as random noise. |
| Palette picker | `paletteName` | named palettes | `Tech Rainbow` | Active chassis, panel, accent, and VU stop set. |

## Impulse Test Controls

Impulse Test mode is an artificial renderer stress test. It stops browser audio
capture/playback and uses synthetic expanding bands instead of Music-mode RMS.

| UI label | Export key | Range | Default | Effect |
| --- | --- | --- | --- | --- |
| VU drive | `driveMode` | `music`, `impulse` | `music` | Selects Music mode or exclusive Impulse Test mode. |
| Repeat | `repeat` | boolean | `true` | Repeats artificial impulses in Impulse Test mode. |
| Impulse interval | `periodSeconds` | `0.00...2.00` | `0.85` | Seconds between repeated impulses; runtime clamps zero for safety. |
| Impulse amplitude | `impulseAmplitude` | `0.00...1.00` | `0.78` | Base synthetic impulse strength. |
| Amplitude swing | `amplitudeSwing` | `0.00...0.65` | `0.12` | Random plus/minus variation for repeated impulses. |
| Band width / fatness | `bandWidthTiles` | `1.00...9.00` | `4.20` | Width of the artificial expanding annular band in face pixels. |
| Attack sharpness | `attackSharpness` | `0.00...1.00` | `0.42` | Edge definition and small speed lift for sharper hits. |
| Outward speed | `outwardSpeedFaceRadiusPerSecond` | `0.15...0.95` | `0.43` | Ripple radius speed across each cube face. |
| Damping | `dampingPerSecond` | `0.05...1.10` | `0.32` | Exponential decay of each artificial band. |
| Edge softness | `edgeSoftness` | `0.00...1.00` | `0.55` | Soft edge width around each band. |
| Whole-cube memory | `wholeCubeMemory` | `0.08...0.95` | `0.64` | Decay rate for accumulated cube energy and peak memory. |

## Variants

| Variant key | Display name | Purpose |
| --- | --- | --- |
| `packetXL` | Soft Center Bloom | Recommended default center-out scalar bloom. |
| `hotFlood` | Hot Core Bloom | Center bloom with stronger peak hot-fill character. |
| `capillaryEdge` | Halo Edge Bloom | Center bloom with a brighter edge at the scalar boundary. |
| `tinyBold` | Block Center Bloom | Posterized center bloom for very small speaker sizes. |

## Export Notes

The export JSON includes both live settings and `controlDefinitions`. For
downstream implementation, treat `displayVuScalar` as the cube bloom input,
`hotScalar` as the whole-cube hot-fill input, and `vuPaletteDrive` as palette
heat only. Keep `rawRms` and `rmsPercent` available for diagnostics so the meter
continues to tell the truth even when the cube display is calibrated for
readability.
