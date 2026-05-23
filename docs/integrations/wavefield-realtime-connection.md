# Wavefield Realtime Connection

Status: active host integration contract

## Purpose

This document defines how Wavefield realtime output feeds Orbital View Kit without making Orbital View Kit part of Wavefield's realtime plane.

Wavefield remains the realtime host. Orbital View Kit remains a Preparation Plane plus Control / UI / Telemetry Plane package that receives prepared display snapshots.

## Ownership Boundary

Wavefield owns:

- external live stream parsing
- local livestream test generator
- local MIDI streams
- realtime event queues
- object lifecycle
- sample-time scheduling
- audio rendering
- route validation
- meter extraction
- performance gates

Orbital View Kit receives only host-prepared snapshots:

- `OrbitalViewSceneSpec`
- `SpeakerMeterFrame`
- `OrbitalViewObjectFrameSet`
- `ObjectMeterFrame`
- `OrbitalViewInputDiagnostics`
- `OrbitalViewTelemetrySourceDescriptor`

Orbital View Kit must not parse raw Wavefield livestream packets, own generator timing, inspect MIDI streams, schedule sample-time events, render audio, repair routes, or enforce Wavefield callback performance gates.

## Snapshot Flow

```text
external Wavefield stream
  -> Wavefield realtime/preparation boundary
  -> prepared Orbital View scene, speaker meters, object frames, object meters, diagnostics, source metadata
  -> Orbital View Kit display state

local livestream test generator
  -> Wavefield realtime/preparation boundary
  -> prepared Orbital View scene, speaker meters, object frames, object meters, diagnostics, source metadata
  -> Orbital View Kit display state
```

The local livestream test generator is a normal Wavefield host source. Its output uses the same prepared snapshot path as an external live stream.

## Identity Mapping

- Wavefield object ID remains source-object identity. It maps to `OrbitalViewObjectFrame.objectID` and `ObjectMeterFrame.levelsByObjectID`.
- Speaker channel remains physical speaker identity. It maps to `OrbitalViewSpeaker.channel` and `SpeakerMeterFrame.levelsByChannel`.
- Generator profile names are source metadata on `OrbitalViewTelemetrySourceDescriptor`; they are not audio path branches and must not change channel or object identity.
- Object disappear removes active draw ownership from the prepared snapshot by omitting that object ID from `OrbitalViewObjectFrameSet.activeObjects`.
- Missing or stale display frames may be dropped. Orbital View Kit keeps latest complete display snapshots and must not make Wavefield audio timing wait for the viewport.

## Source Metadata

External live stream frames should normally use:

```text
OrbitalViewTelemetrySourceDescriptor.externalWavefieldStream
```

Local generator frames should normally use:

```text
OrbitalViewTelemetrySourceDescriptor.localLivestreamTestGenerator
```

When profile information is useful, the host may provide a validated label or detail string. Profile names remain provenance only.

Example source details:

```text
profile=smoke
profile=moving-pose
profile=sustained-moving-object
profile=burst-reorder
profile=16-object-stress
profile=32-object-should-pass-stress
```

## Generator Profiles For Stress Input

The Wavefield realtime fork's local livestream generator profiles are accepted as display/stress inputs when Wavefield publishes prepared snapshots:

- `smoke`
- `moving-pose`
- `sustained-moving-object`
- `burst-reorder`
- `16-object-stress`
- `32-object-should-pass-stress`

These profiles test display ingestion, identity preservation, ordering tolerance, and no-backpressure behavior. They do not prove Orbital View Kit owns any audio callback compliance because Orbital View Kit owns no realtime callback.

## Dependency Rule

`OrbitalViewWavefield` may adapt local DTOs and prepared data shapes into `OrbitalViewCore` contracts. It must not depend directly on Wavefield package targets unless a future OpenSpec change and explicit implementation slice allow that dependency.

