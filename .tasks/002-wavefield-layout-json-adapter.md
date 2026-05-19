# Task 002: Wavefield Layout JSON Adapter

## Status

```text
complete
```

## Goal

Add a local adapter target that converts Wavefield speaker layout JSON into an `OrbitalViewCore` monitor scene without touching the Wavefield app repo.

## Background

The actual Wavefield package exposes a `WavefieldSpeakerLayout` target and the Fey fixture uses `unitSphereCartesian` axes with `x = right`, `y = up`, `z = front`. The safest next step is to prove `OrbitalViewKit` can consume that layout shape while keeping dependencies one-way and local.

## Scope

Implemented:

- `OrbitalViewWavefield` library target.
- `WavefieldSpeakerLayoutSceneAdapter`.
- Tests using a copied Fey 30 fixture.

Out of scope:

- Editing Wavefield.
- Depending on Wavefield package targets.
- SwiftUI or renderer integration.
- Meter snapshot integration.

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

