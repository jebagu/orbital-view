# Sonicsphere Cube Pond Ripple VU · Single-Screen Tuner

This revision is cube-only. Every Sonicsphere speaker is treated as a small Minecraft-like cube whose visible faces are divided into a low-resolution tile grid. The visualization is designed for tiny on-screen readability: broad, vivid pond-ripple bands expand from the center of each face, and each band keeps one stable color while it moves outward.

## Visual rule

The effect should not read as random noise. The speaker is idle as a single tinted surface color. An impulse creates one fat annular band on each visible cube face. The band is wider than one face pixel, has a soft edge, and uses a single VU color sampled at impulse birth.

At sustained high energy, the whole cube can flood toward the final hot color. This is the peak-state behavior: when the music is really going, the cube itself becomes the hot color rather than only showing isolated stripes.

## Single-screen prototype layout

The prototype is now a no-scroll wide-monitor workbench. It is authored as a fixed **1512 × 850 CSS-pixel stage** so the browser chrome on the current monitor does not force the entire UI into an unreadably small scale. The stage scales uniformly to the live browser viewport instead of stacking or scrolling.

The visible layout is:

- a left preview rail with a normal **Music Meter** above all four cube viewports in a 2 × 2 grid;
- a right tabbed control rail with **Tune** for live audio/palette/ripple/hot/surface controls;
- an **Impulse** tab for artificial Drop/Repeat testing;
- an **Advanced** tab for custom palette JSON and implementation export so the primary tuning controls have room;
- no body scrolling and no hidden/collapsed model rail;
- no spheres anywhere.

The important implementation detail is the `fit-stage` wrapper: the dashboard does not reflow into a controls-only or stacked layout. It stays as one complete artboard and scales to the available viewport, so the music meter and model viewports cannot collapse or disappear when browser chrome reduces the usable height.

The four variants are:

1. **Pond Packet XL** — recommended default, fat stable-color ripple bands.
2. **Hot Flood Packet** — stronger full-cube hot fill for peak sections.
3. **Broad Capillary Edge** — same band color with a subtle brighter leading rim for attack cues.
4. **Tiny Speaker Bold** — posterized stress test for very small speaker sizes.

## Core math

For each tile on a cube face:

```ts
u = (x + 0.5) / facePixels;
v = (y + 0.5) / facePixels;
r = hypot(u - 0.5, v - 0.5) * sqrt(2);
```

Each impulse stores its birth time, amplitude, sampled VU coordinate, width, attack, and speed:

```ts
amp = clamp01(max(audioPeak, bassEnergy, rmsEnergy, impulseAmplitude * (1 + randomSwing)));
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
vuColor = sampleVuStops(activePalette.vuStops, bandColorT);
hotColor = final activePalette.vuStops color;
hot = hotFillStrength * smoothstep(hotThreshold, 1.0, accumulatedEnergy);
tileColor = mix(mix(idleBase, hotColor, hot), vuColor, bandAlpha);
```

## Controls

The prototype exposes the controls that should become renderer/preset parameters:

- **VU drive** for exclusive Music vs Impulse Test mode.
- **Impulse interval** and **Impulse amplitude** for the simulator in the Impulse tab.
- **Amplitude swing** for varying repeated impulses in Impulse Test mode.
- **Capture YouTube/Tab**, **Stop Capture**, local audio file input, source status, and live RMS/Peak/Bass readouts in both the control rail and the separate normal meter panel.
- **Band width / fatness**, measured in face tiles. This is the key small-screen readability control.
- **Color range / compression** (`vuPaletteDrive`), the low-to-hot drive control. Higher values push medium amplitudes farther through the palette.
- **Attack sharpness**, **outward speed**, **damping**, and **edge softness**.
- **Hot fill strength**, **hot threshold**, and **whole-cube memory**.
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

The intended app implementation can translate this JSON into the real Sonicsphere renderer. The runtime work is lightweight: precompute cube-face tile UVs, then evaluate active impulses against visible tiles. There are no sphere UVs, no texture allocation requirement, and no high-frequency noise layer.

## Latest layout fix

This pass fixes the issue where the control rail was too crowded on the active monitor. The `.app` grid now gives the left side a music-meter-plus-cube preview column and the right side a tabbed control column. Tune keeps only the frequently used music audio, palette, ripple, hot cube, and surface controls. Impulse holds artificial Drop/Repeat testing. Advanced holds the custom palette and export implementation controls.

The left column adds `meterCanvas`, a normal horizontal VU/spectrum/waveform view driven by the same captured YouTube/tab or local-file audio as the cubes. Each model card still has an explicit grid height path (`main -> four-up -> study -> study-canvas`) so the canvases keep measurable dimensions in Safari/Chrome instead of disappearing. The `fitStage()` function scales the entire 1512 × 850 artboard to the current viewport and stores the scale on `#fitStage.dataset.scale` for canvas DPR sizing.

## Latest drive-mode pass

This pass makes the source exclusive. The VU drive control has two modes:

- **Music**: tab capture/local-file Web Audio analysis drives the meter and cubes. Artificial Drop/Repeat controls are disabled.
- **Impulse Test**: active capture/playback is stopped, audio meters decay, music-generated drops are cleared, and Drop/Repeat controls become active.

Switching modes clears existing drops and energy so music and artificial impulses are never layered together.
