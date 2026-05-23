# Visual Telemetry Stress Gates

Status: active Slice 9 stress profile

## Purpose

This document defines the display-side stress gate for Orbital View Kit. It proves that the viewport can absorb realistic visual telemetry pressure without implying audio callback compliance.

Orbital View Kit owns no audio callback, playback scheduler, route validator, realtime queue, or output path. Host applications own callback p99 and deadline gates.

## Stress Scene

The canonical visual telemetry stress fixture lives in:

```text
Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift
Tests/OrbitalViewViewerTests/OrbitalViewViewerDemoContentTests.swift
```

Fixture shape:

- 30 physical speakers in stable channel order `1...30`;
- 128 source objects, matching `OrbitalViewObjectFrameSet.maxObjectCount`;
- object trails capped at 16 points per object;
- active viewport motion at 60 FPS;
- incoming meter frames modeled at 120 FPS, faster than display cadence;
- diagnostics open for the stress profile;
- speaker and object meter frames labeled with `.localLivestreamTestGenerator`;
- source metadata includes the Wavefield local generator profile `32-object-should-pass-stress`;
- stale display frames are represented by overload diagnostics, not audio errors.

## UI And Render No-Backpressure Gates

Orbital View Kit passes the display no-backpressure gate when:

- meter-only updates do not rebuild static speaker geometry;
- object meter updates do not rebuild speaker geometry;
- retained speaker/object buffer capacity does not grow for meter-only, camera-only, or settings-only updates;
- object trails stay capped by configured display limits;
- diagnostics logs stay capped;
- display overload reports allowed actions: drop stale frames, decimate display refresh, keep the latest complete snapshot, and set diagnostics outside realtime;
- overload diagnostics do not report missing channels, duplicate channels, invalid channels, clamped values, replacement values, or timestamp replacement unless those faults are actually present in the prepared input;
- no visual path blocks host audio, asks host callbacks to allocate display queue, logs from callbacks, posts UI from callbacks, or feeds raw packets into renderer paths.

This is a Control / UI / Telemetry Plane gate. It is allowed to be lossy.

## Host Callback Gates

Host callback gates are different and stay outside this package:

- callback deadline hit rate;
- p99 and worst-case callback duration;
- callback allocation checks;
- route repair timing;
- audio device I/O timing;
- MIDI, OSC, or network event queue timing;
- meter extraction timing before the prepared snapshot boundary.

Orbital View Kit can document and consume host-prepared snapshots from these systems, but it cannot certify that a host meets realtime callback p99 or deadline gates.

## Evidence

Current source-level evidence:

- `OrbitalViewVisualTelemetryStressScene` builds the 30-speaker, 128-object, local-generator-sourced stress fixture.
- Viewer tests assert speaker identity, object identity, trail caps, 120 FPS ingress versus 60 FPS viewport cadence, local generator provenance, diagnostics-open profile intent, and display-drop diagnostics without audio-failure fields.
- Existing renderer retained-buffer tests cover static speaker geometry and retained buffer capacity under meter, object-meter, camera, and settings-only changes.
- Existing SwiftUI/review tests cover capped diagnostics behavior.

Manual visual review is required only when a future task exposes this stress scene in the review executable or production host UI.
