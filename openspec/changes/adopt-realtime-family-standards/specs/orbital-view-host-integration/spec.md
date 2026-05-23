# orbital-view-host-integration Specification Delta

## Purpose

Define how Wavefield, Orbisonic, Splat, and future realtime-family apps connect to Orbital View Kit through host-owned adapters and prepared state.

## Standards Impact Summary

```text
Touches realtime: yes, because host integrations sit near realtime systems; Orbital View Kit remains outside host callbacks.
Touches routing: no; host apps own routing and channel-map decisions.
Meter source-of-truth: host apps own measured production meters and publish prepared snapshots.
Callback reachability: host adapters must bridge out of callback paths before invoking Orbital View Kit.
Overload policy: host integrations may throttle, drop, or coalesce visual snapshots under load.
Performance gates: integration slices must test callback separation, identity preservation, and display-rate behavior before protected-path handoff.
```

## Requirements

### Requirement: Host-Owned Adapter Boundary

The system SHALL connect realtime-family host apps through host-owned adapters that publish prepared Orbital View Kit state.

#### Scenario: Wavefield local livestream test generator publishes frames

- GIVEN the local livestream test generator emits Wavefield-compatible layout or meter frames
- WHEN a host adapter forwards data to Orbital View Kit
- THEN the adapter provides prepared snapshots through the same ingress path used for external streams and labels the source as local livestream test generator
- AND generator profile names are source metadata, not audio path branches

### Requirement: Wavefield Realtime Ownership Boundary

The system SHALL treat Wavefield as the owner of livestream parsing, local generator timing, MIDI streams, realtime event queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and realtime performance gates.

#### Scenario: Wavefield publishes prepared snapshots

- GIVEN Wavefield has prepared scene, speaker meter, object frame, object meter, diagnostics, and source metadata snapshots
- WHEN Orbital View Kit receives the snapshots
- THEN Orbital View Kit visualizes them without parsing raw livestream packets, owning generator timing, reading MIDI streams, scheduling audio, validating routes, or enforcing Wavefield callback gates

### Requirement: Wavefield Identity Mapping

The system SHALL preserve Wavefield object IDs and physical speaker channels as separate identities.

#### Scenario: Object and speaker telemetry are prepared

- GIVEN Wavefield prepares object frame and object meter snapshots
- WHEN the snapshots enter Orbital View Kit
- THEN Wavefield object IDs map to `OrbitalViewObjectFrame.objectID` and `ObjectMeterFrame.levelsByObjectID`
- AND speaker channels map to `OrbitalViewSpeaker.channel` and `SpeakerMeterFrame.levelsByChannel`
- AND an object disappear event is represented by omitting that object ID from `OrbitalViewObjectFrameSet.activeObjects`
- AND missing or stale display frames may be dropped without delaying Wavefield audio

#### Scenario: Local generator profiles are used for stress input

- GIVEN Wavefield runs `smoke`, `moving-pose`, `sustained-moving-object`, `burst-reorder`, `16-object-stress`, or `32-object-should-pass-stress`
- WHEN the generator output reaches Orbital View Kit
- THEN the profile name is preserved as source metadata on prepared snapshots
- AND the profile does not create a separate Orbital View audio path

#### Scenario: Orbisonic or Splat integrates the viewport

- GIVEN Orbisonic or Splat needs a spherical monitor viewport
- WHEN it integrates Orbital View Kit
- THEN the host owns route discovery, playback, MIDI, OSC, and meter extraction, while Orbital View Kit owns only display contracts and UI telemetry
- AND Orbisonic labels prepared meter frames as Orbisonic prepared meter tap while Splat labels prepared analysis as Splat prepared analysis

### Requirement: Orbisonic Host Profile

The system SHALL treat Orbisonic as the owner of playback, transport, source selection, Core Audio device I/O, route discovery, route repair, channel mapping, output routing, render/control engines, meter extraction, explicit tap-point selection, operator state, and realtime performance gates.

#### Scenario: Orbisonic publishes prepared tap snapshots

- GIVEN Orbisonic prepares bus, object, or speaker meter snapshots from explicit tap points
- WHEN those snapshots enter Orbital View Kit
- THEN Orbital View Kit receives prepared meter, scene, object, diagnostics, and source metadata snapshots only
- AND Orbisonic tap-point names are source metadata, not routing, playback, source-selection, or channel-map instructions
- AND prepared Orbisonic meter provenance is labeled `orbisonicPreparedMeterTap` unless a future integration slice defines a narrower descriptor
- AND Orbisonic design-language defaults and palette grammar remain visual guidance only

### Requirement: Splat Host Profile

The system SHALL treat Splat as the owner of project/session state, authoring commands, renderer-kernel analysis, neutral geometry import/export decisions, file formats, persistence, and any eventual handoff to an audio/render host.

#### Scenario: Splat publishes prepared analysis snapshots

- GIVEN Splat prepares virtual speaker layouts, source objects, renderer-kernel overlays, neutral geometry review, diagnostics, camera, or selection state
- WHEN those snapshots enter Orbital View Kit
- THEN Orbital View Kit visualizes them as preparation/control telemetry
- AND Splat analysis provenance is labeled `splatPreparedAnalysis`
- AND edit/export remains preparation/control behavior until a host applies a prepared snapshot
- AND canonical 3D coordinates are not replaced by permanent flattened screen coordinates
- AND neutral geometry import/export stays separate from browser or DomeLab runtime code

### Requirement: OpenSpec For Future Host Changes

The system SHALL require OpenSpec changes for future audio-facing or architecture-facing host integrations.

#### Scenario: Integration touches protected audio behavior

- GIVEN a future task touches Wavefield, Orbisonic, Splat, or another protected downstream path
- WHEN behavior or architecture changes are proposed
- THEN a relevant OpenSpec change must define the boundary before implementation begins
- AND the task must inspect the current downstream repository and explicitly name the protected paths it is allowed to edit
