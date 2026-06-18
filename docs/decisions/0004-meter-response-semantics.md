# ADR 0004: Meter Response Semantics

Status: accepted

Date: 2026-06-17

## Context

Wave Relay's JUCE meters are the current reference for readable meter feel. They treat raw RMS as the continuous body/activity signal, raw peak as transient evidence, and clip as the hard alert state. Orbital View's SceneKit review surface had a mismatch: Cube VU, Pixel Jets, and Cell Jets could feed raw peak into the broad palette heat path, so presets such as Neon Vector could look globally hot even when input calibration was low.

## Decision

Orbital View adopts Wave Relay-style meter response semantics for review speaker visuals by default.

- RMS/display drive owns body activity, bloom, palette heat, and general meter movement.
- Peak remains raw signal evidence and may drive narrow marker, edge, or diagnostic accents. In the SceneKit Cube VU review surface, that accent is a constrained rim/edge motion cue, not broad body heat.
- Clip is the only full hot/alert state.
- Input calibration and response controls operate on RMS/display drive, not on raw peak-flooded palette heat.
- No new calibration setting is added until the corrected default behavior is evaluated in the visible review app.

This decision does not change raw telemetry values, shared telemetry ABI, Wave Relay, speaker channel identity, source-lane identity, routing, or host audio behavior.

## Consequences

- Cube VU, Pixel Jets, and Cell Jets remain display-only material treatments.
- Review diagnostics continue to show raw RMS, raw peak, display drive, calibrated RMS, display scalar, hot scalar, and palette heat separately.
- Source-lane meters keep the Orbital-only `-50...0 dBFS` display normalization added for Wave Relay compatibility.
- Future trusted `vuNormalized` display intent can still override raw RMS when the telemetry record explicitly marks it valid.
- A later settings task may add a smaller response control only if visual review shows the corrected default still needs operator tuning.
