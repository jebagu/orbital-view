# Task 003: Wavefield Meter Frame Adapter

## Status

```text
complete
```

## Goal

Add a local adapter for Wavefield-style channel/rms/peak meter frames into `OrbitalViewCore.SpeakerMeterFrame`.

## Background

Wavefield exposes channel meter records as `channel`, `rms`, and `peak`. OrbitalViewKit should be able to consume that shape without depending on the Wavefield package or touching downstream audio paths.

## Scope

Implemented:

- `WavefieldMeterChannelFrame` DTO.
- `WavefieldMeterFrameAdapter`.
- duplicate-channel, invalid-channel, non-finite-level validation.
- clip threshold mapping into `SpeakerMeterLevel.clip`.

Out of scope:

- importing Wavefield package types directly
- editing Wavefield
- renderer or SwiftUI integration
- audio path changes

## Protected Path Check

This task:

```text
does not touch protected downstream paths
```

## Verification Commands

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

