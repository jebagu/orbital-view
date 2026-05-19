# Slice 002: Wavefield Layout JSON Adapter

## Status

```text
complete
```

## Goal

Convert Wavefield speaker layout JSON into an `OrbitalViewCore` scene in this repo.

## Scope

Do:

- Add `OrbitalViewWavefield`.
- Parse the Wavefield speaker-layout JSON shape.
- Validate `unitSphereCartesian` axes.
- Preserve speaker channel order and labels.
- Test against Fey 30 fixture.

Do not:

- edit Wavefield
- depend on Wavefield package targets
- implement renderer or SwiftUI integration
- adapt live meter snapshots yet

## Protected Path Check

This slice:

```text
does not
```

touch a protected path.

## Verification

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

