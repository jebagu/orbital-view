# Slice 003: Wavefield Meter Frame Adapter

## Status

```text
complete
```

## Goal

Map Wavefield-style meter channel records into `OrbitalViewCore.SpeakerMeterFrame`.

## Scope

Do:

- Add local DTOs for `channel`, `rms`, and `peak`.
- Preserve channel identity in `levelsByChannel`.
- Reject duplicate and invalid channels.
- Reject non-finite RMS and peak values.
- Derive clip flags from a configurable peak threshold.

Do not:

- import Wavefield package targets
- edit Wavefield
- implement rendering or SwiftUI
- touch audio, playback, MIDI, OSC, routing, or output paths

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

