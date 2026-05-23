# Orbisonic And Splat Host Integration Profiles

Status: active host integration contract

## Purpose

This document defines how Orbisonic and Splat should connect to Orbital View Kit without editing either downstream app in this slice.

Orbital View Kit remains a visual telemetry and preparation package. Hosts own audio, routing, analysis, editing, file formats, and app-specific semantics.

## Shared Integration Boundary

Both profiles use the same boundary:

```text
host-owned state
  -> host-owned preparation / adapter boundary
  -> OrbitalViewCore scene, meter, object, diagnostics, source metadata snapshots
  -> OrbitalViewRender / OrbitalViewSwiftUI display
```

Orbital View Kit may emit camera, selection, and diagnostics UI state. It must not emit direct playback, routing, source-selection, render-kernel, export, or audio commands into either host.

Direct downstream source edits require:

- inspection of the current downstream repository
- explicit task permission naming the downstream app and protected paths
- an OpenSpec change when behavior or architecture changes
- specialty review when audio, routing, metering, protected rendering, performance, or reliability is touched

## Orbisonic Profile

Orbisonic owns:

- playback and transport
- source selection
- Core Audio device I/O
- route discovery and route repair
- channel mapping and output routing
- render/control engines
- meter extraction
- explicit tap-point selection
- operator state and persistence
- realtime performance gates

Orbital View Kit receives:

- prepared bus meter snapshots
- prepared object meter snapshots when Orbisonic has object-level telemetry
- prepared speaker meter snapshots
- prepared speaker/source/object scene snapshots
- diagnostics snapshots
- source metadata snapshots

Recommended telemetry source metadata:

```text
OrbitalViewTelemetrySourceDescriptor.orbisonicPreparedMeterTap
```

Hosts may provide validated source labels or detail strings to name explicit tap points such as bus, object, speaker, final output, or hardware tap. Tap-point names are metadata only. They must not change audio routing, playback state, channel order, or meter values inside Orbital View Kit.

Orbisonic integration must preserve:

- routing ownership in Orbisonic
- physical speaker channel identity in `SpeakerMeterFrame.levelsByChannel`
- source object identity in `OrbitalViewObjectFrame.objectID` and `ObjectMeterFrame.levelsByObjectID`
- Orbisonic design-language defaults and palette grammar from `docs/orbisonic-design-language.md`
- Daft Punk Bow as display-only VU color/material behavior

Orbital View Kit must not become an Orbisonic live mixer, source selector, transport, route validator, device manager, or output fallback path.

## Splat Profile

Splat owns:

- source project/session state
- authoring/edit commands
- renderer-kernel analysis and kernel-specific overlays
- neutral geometry import/export decisions
- file formats and persistence
- preparation of virtual speaker/source/object layouts
- any eventual handoff from edit state to an audio/render host

Orbital View Kit may be used for:

- virtual speaker layout review
- source object layout review
- renderer-kernel overlays
- neutral geometry review
- display diagnostics
- camera and selection events

Recommended telemetry source metadata:

```text
OrbitalViewTelemetrySourceDescriptor.splatPreparedAnalysis
```

Splat edit and export actions are Preparation Plane or Control / UI / Telemetry Plane behavior until Splat or another host applies a prepared snapshot. Orbital View Kit must not treat editor gestures as realtime audio commands.

Splat integration must preserve:

- canonical 3D source/speaker/object coordinates
- neutral geometry import/export separation from browser/DomeLab runtime code
- object identity separate from speaker channel identity
- renderer-kernel overlays as display/preparation metadata

Splat integration must avoid:

- permanent flattened screen-coordinate storage as canonical spatial state
- importing browser, DomeLab, or Splat runtime code into Orbital View Kit
- making Orbital View Kit own Splat file parsing or export semantics
- turning visual overlay selection into host audio/routing behavior

## Current Slice Scope

This slice defines the profiles only. It does not add package dependencies, downstream source edits, new host adapters, app launchers, or visible UI changes.

