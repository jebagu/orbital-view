# Sonicsphere Cube Scalar VU · Single-Screen Tuner

This revision is cube-only. Every Sonicsphere speaker is treated as a small Minecraft-like cube whose visible faces are divided into a low-resolution tile grid. The music visualization is intentionally simple: the normal VU meter's RMS percent is the scalar, and the cube faces render that scalar directly.

## Visual rule

The effect should not read as random noise. The speaker is idle as a single tinted surface color. In **Music** mode, `vuScalar` is exactly the same number as the RMS percent shown in the normal meter. Peak and Bass stay visible as diagnostics, but they do not drive the cube bloom. The cube faces bloom outward from the center of each visible face, with the bloom color coming from the same VU palette as the normal meter.

At sustained high energy, the whole cube can flood toward the final hot color. This is the peak-state behavior: when the meter is really going, the cube itself becomes the hot color rather than only showing isolated center tiles.

The old pulse/ripple behavior remains only in **Impulse Test** mode as an artificial renderer stress test. It is no longer the music mapping.

## Single-screen prototype layout

The prototype is now a no-scroll wide-monitor workbench. It is authored as a fixed **1512 × 850 CSS-pixel stage** so the browser chrome on the current monitor does not force the entire UI into an unreadably small scale. The stage still scales uniformly to the live browser viewport instead of stacking or scrolling.

The visible layout is:

- a left preview rail with a normal **Music Meter** above the four always-visible cube viewports;
- a right tabbed control rail with **Tune** for live audio, the single Cube VU scalar, palette, and surface controls;
- an **Impulse** tab for artificial Drop/Repeat testing;
- an **Advanced** tab for custom palette JSON and implementation export so the primary tuning controls have room;
- no body scrolling and no hidden/collapsed model rail;
- no spheres anywhere.

The important implementation detail is the `fit-stage` wrapper: the dashboard does not reflow into a controls-only or stacked layout. It stays as one complete artboard and scales to the available viewport, so the music meter and model viewports cannot collapse or disappear when browser chrome reduces the usable height.

The four variants are:

1. **Soft Center Bloom** — recommended default, smooth center-out scalar bloom.
2. **Hot Core Bloom** — center bloom with stronger hot fill on peak sections.
3. **Halo Edge Bloom** — center bloom with a brighter edge at the scalar boundary.
4. **Block Center Bloom** — posterized center bloom for very small speaker sizes.

## Real music source

The mockup can now drive the VU from browser audio while staying outside the production Swift package:

- **Capture YouTube/Tab** uses `navigator.mediaDevices.getDisplayMedia()` with audio sharing. The user opens and plays YouTube in another tab, returns to this mockup, clicks capture, and selects the tab with audio enabled.
- **Local file** uses the visible `<audio>` element plus `MediaElementAudioSourceNode`, so MP3/M4A/WAV playback is audible and analyzable in the same page.
- The analyzer uses `AudioContext`, `AnalyserNode`, waveform RMS/peak, and low-frequency FFT bins. The cube VU scalar is exactly the RMS percent; Peak and Bass are diagnostics only.
- A VU drive toggle makes **Music** and **Impulse Test** mutually exclusive. Music mode uses the Web Audio analyzer; Impulse Test stops browser audio capture/playback, clears music-driven drops, and enables artificial Drop/Repeat controls.

This does not change the production contract. `OrbitalViewKit` remains a consumer of host-provided meter frames; this is a browser-only preview for tuning how a host-provided scalar should feel.

## Core math

For each tile on a cube face:

```ts
u = (x + 0.5) / facePixels;
v = (y + 0.5) / facePixels;
r = hypot(u - 0.5, v - 0.5) * sqrt(2);
```

Music mode uses the RMS meter value directly:

```ts
vuScalar = rms;
state.energy = vuScalar;
```

The default cube visualization is a center VU bloom:

```ts
radius = lerp(bloomMin, bloomMax, pow(vuScalar, radiusCurve));
distance = hypot(u - 0.5, v - 0.5) * sqrt(2);
fill = 1 - smoothstep(radius, radius + bloomEdge, distance);
tileColor = mix(idleSurface, sampleVuStops(centerHeat), fill);
```

Impulse Test mode still stores artificial impulse birth time, amplitude, sampled VU coordinate, width, attack, and speed:

```ts
amp = clamp01(impulseAmplitude * optionalAmplitudeSwing);
heat = 1 - pow(1 - clamp01(amp), vuPaletteDrive);
widthTiles = max(1.15, bandWidthTiles * lerp(1.18, 0.88, attackSharpness));
groupSpeed = outwardSpeed * lerp(0.92, 1.12, edgeSharpness);
```

The annular band is intentionally broad:

```ts
age = now - dropTime - faceIndex * facePhaseStagger;
radius = groupSpeed * age;
fullWidth = widthTiles * variant.widthMul / facePixels;
halfWidth = fullWidth * 0.54;
edgeWidth = max(0.012, fullWidth * lerp(0.08, 0.36, edgeSoftness));

band = 1 - smoothstep(halfWidth, halfWidth + edgeWidth, abs(r - radius));
band *= exp(-dampingPerSecond * age) / sqrt(1 + radius * 2.4);
bandAlpha = max(bandAlpha, band * amp);
```

Color mix:

```ts
idleBase = mix(panel, accent, idleTint);
vuColor = sampleVuStops(activePalette.vuStops, centerHeat);
hotColor = final activePalette.vuStops color;
hot = hotFillStrength * smoothstep(hotThreshold, 1.0, accumulatedEnergy);
tileColor = mix(mix(idleBase, hotColor, hot), vuColor, centerBloomFill);
```

## Controls

The prototype exposes the controls that should become renderer/preset parameters:

- **VU drive** for exclusive Music vs Impulse Test mode.
- **Impulse interval** and **Impulse amplitude** for the simulator in the Impulse tab.
- **Amplitude swing** for varying repeated impulses in Impulse Test mode.
- **Capture YouTube/Tab**, **Stop Capture**, local audio file input, source status, and live RMS/Peak/Bass readouts in both the control rail and the separate normal meter panel.
- **Cube VU scalar** readout, which should match the RMS percent exactly.
- **Face pixels**, **idle tint**, **face phase stagger**, and **checker contrast**.
- **Palette picker** in the Tune tab.
- **Custom palette JSON loader** and **selected variant export** in the Advanced tab.

The color compression formula is:

```ts
compressVu(v) = 1 - pow(1 - clamp01(v), vuPaletteDrive)
```

`1.0` is linear. Values above `1.0` make normal hits more vivid and hot sooner. Values below `1.0` reserve hot colors for only the loudest inputs.

## Tech Rainbow palette

Added **Tech Rainbow** as a first-class palette:

```css
linear-gradient(
  90deg,
  #A78BFA 0%,
  #5B8CFF 18%,
  #22D3EE 34%,
  #34D399 50%,
  #FDE047 66%,
  #FB923C 82%,
  #EF4444 100%
)
```

The palette stores explicit VU stops:

```ts
[
  { stop: 0.00, color: '#A78BFA', role: 'violet' },
  { stop: 0.18, color: '#5B8CFF', role: 'blue' },
  { stop: 0.34, color: '#22D3EE', role: 'cyan' },
  { stop: 0.50, color: '#34D399', role: 'green' },
  { stop: 0.66, color: '#FDE047', role: 'yellow' },
  { stop: 0.82, color: '#FB923C', role: 'orange' },
  { stop: 1.00, color: '#EF4444', role: 'red / hot' }
]
```

For Tech Rainbow, the simulator uses `cycleAllStops: true`. Normal repeated impulses step through the explicit stops in order, guaranteeing that violet, blue, cyan, green, yellow, orange, and red are all hit during a normal cycle. Each individual band still keeps one color while expanding.

Production can keep this behavior for a branded rainbow mode, or disable it and use the normal amplitude-driven heat path:

```ts
bandColorT = compressVu(audioAmplitude);
```

## Export contract

The live export JSON includes:

- current values for every control;
- definitions for every control;
- browser-only audio source mode and analyzer notes;
- every palette and its VU mapping;
- Tech Rainbow gradient stops and cycle rule;
- all four variant definitions;
- the selected variant definition;
- the cube-face coordinate, annular band, VU compression, hot-fill, and color-mix math.

The intended app implementation can translate this JSON into the real Sonicsphere renderer. The runtime work is lightweight: precompute cube-face tile UVs, then fill visible tiles from one scalar in Music mode. There are no sphere UVs, no texture allocation requirement, and no high-frequency noise layer.

## Latest layout fix

This pass fixes the issue where the control rail was too crowded on the active monitor. The `.app` grid now gives the left side a music-meter-plus-cube preview column and the right side a tabbed control column. Tune keeps only the frequently used music audio, Cube VU scalar, palette, and surface controls. Impulse holds artificial Drop/Repeat testing. Advanced holds the custom palette and export implementation controls.

The left column adds `meterCanvas`, a normal horizontal VU/spectrum/waveform view driven by the same captured YouTube/tab or local-file audio as the cubes. Each model card still has an explicit grid height path (`main -> four-up -> study -> study-canvas`) so the canvases keep measurable dimensions in Safari/Chrome instead of disappearing. The `fitStage()` function scales the entire 1512 × 850 artboard to the current viewport and stores the scale on `#fitStage.dataset.scale` for canvas DPR sizing.

## Latest music-source pass

This pass adds real browser audio analysis to the single-screen mockup. The right rail now includes an Audio Source group with tab capture for YouTube, stop capture, local file playback, live RMS/Peak/Bass readouts, and explicit idle/capturing/no-audio/permission-denied status messages. Music mode uses RMS as the Cube VU scalar. Manual `Drop one` is available only in Impulse Test mode.

## Latest drive-mode pass

This pass makes the source exclusive. The VU drive control has two modes:

- **Music**: tab capture/local-file Web Audio analysis drives the meter and cubes. Artificial Drop/Repeat controls are disabled.
- **Impulse Test**: active capture/playback is stopped, audio meters decay, music-generated drops are cleared, and Drop/Repeat controls become active.

Switching modes clears existing drops and energy so music and artificial impulses are never layered together.

## Latest scalar simplification

This pass removes the visible rhythm-lock framework. Music mode now behaves like a normal VU meter:

```text
RMS -> vuScalar -> center bloom radius
```

The Tune tab exposes only the audio source, the Cube VU scalar controls, the surface controls, and the palette. The cube renderer no longer creates music-driven pulse drops. It blooms each cube face directly from `vuScalar`, so the cube motion should track the normal meter instead of feeling like a separate animation.

## Latest center-bloom and performance pass

This pass makes all four visible cards variations of the center bloom:

1. **Soft Center Bloom**
2. **Hot Core Bloom**
3. **Halo Edge Bloom**
4. **Block Center Bloom**

To reduce CPU load, the mockup now removes the four extra mini-cubes from each panel, lowers the default face grid from 11 x 11 to 9 x 9, caps canvas DPR at 1.35, and redraws the meter/cube canvases at 24 fps while continuing to sample audio every animation frame.

## Latest freeze fix

The sluggish/freezing behavior came from main-thread canvas work rather than the scalar idea itself. The draw loop was recreating projected tile geometry and color-stop arrays every frame, and the normal meter waveform was drawing too many samples for a small preview.

This pass:

- caches cube face/tile geometry by size and tile count;
- caches palette stop and RGB conversions;
- reduces analyser `fftSize` from 2048 to 1024;
- down-samples the visible waveform to at most 160 points;
- reduces spectrum bars from 44 to 32;
- lowers the visual redraw cap from 30 fps to 24 fps.
- makes `vuScalar` exactly equal to the RMS percent, removing the earlier gain/compression/release smoothing path.

Audio analysis still runs in the page, but the expensive canvas paint work now creates far fewer short-lived objects, which should reduce periodic garbage-collection stalls.
