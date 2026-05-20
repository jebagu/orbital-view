# Orbisonic Integration Contract

## Status

```text
adapter skeleton implemented; Orbisonic app integration deferred
```

## Contract

```text
Orbisonic renderer/output monitor
  -> 30 channel VU records
  -> SpeakerMeterFrame
  -> OrbitalView
```

Orbisonic remains the owner of source selection, live loopback capture, renderer/output monitor state, Dante output, Roon/Spotify/Aux routing, and meter production. OrbitalViewKit consumes only host-provided scene and meter snapshots.

## Current Orbisonic Source Shape

The sibling Orbisonic checkout currently exposes relevant app concepts in:

```text
../Orbisonic/Sources/Orbisonic/RendererModule.swift
../Orbisonic/Sources/Orbisonic/OrbisonicViewModel.swift
../Orbisonic/Sources/AudioContracts/AudioContracts.swift
../Orbisonic/Sources/AudioCore/MeteringTelemetry.swift
```

The package-level `OrbitalViewOrbisonic` target intentionally does not import those modules. A future Orbisonic app slice can map Orbisonic-owned values such as renderer output speakers, `ChannelMeter`, or `MeterSnapshot.danteMeters` into the DTOs defined here.

## Adapter DTOs

```text
OrbisonicOutputSpeakerRecord
  physicalChannel: 1...30
  x/y/z: unit-sphere-capable output speaker position
  label: host display label

OrbisonicMeterRecord
  physicalChannel: 1...30
  rms: normalized display RMS, 0...1
  peak: normalized display peak, 0...1
  clip: host clip flag
```

`OrbisonicOrbitalViewAdapter.makeScene(...)` validates the physical speaker contract and returns an `OrbitalViewSceneSpec`.

`OrbisonicOrbitalViewAdapter.makeSanitizedSpeakerMeterFrame(...)` uses `SpeakerMeterFrameSanitizer` and returns both a display-safe `SpeakerMeterFrame` and `OrbitalViewInputDiagnostics`.

## Channel Rules

- Physical speaker channels are 1-based and must be exactly `1...30`.
- The adapter must not remap, downmix, truncate, or synthesize physical channel data.
- Missing or extra meter channels are diagnostics, not a reason to create fake activity.
- The Orbisonic LFE/subwoofer channel is outside the current 30-speaker Orbital View contract.
- A future 30.1 view requires an explicit contract change.

## Theme Rules

`OrbisonicOrbitalColorScheme` defines the current package-level color scheme contract:

```text
Orbisonic Lab
Kimi Purple
Daft Punk Bow
Monochrome
```

`Daft Punk Bow` maps directly to `OrbitalViewTheme.daftPunkBow` so Wavefield and Orbisonic can share the same rainbow VU ramp.

## Boundary Rules

`OrbitalViewCore`, `OrbitalViewRender`, and `OrbitalViewSwiftUI` must not import `OrbitalViewWavefield`, `OrbitalViewOrbisonic`, Wavefield app targets, or Orbisonic app targets.

`OrbitalViewOrbisonic` may depend only on:

```text
Foundation
OrbitalViewCore
```

Orbisonic app code should remain responsible for any app-specific mapping from renderer, output, telemetry, or UI settings into these DTOs.
