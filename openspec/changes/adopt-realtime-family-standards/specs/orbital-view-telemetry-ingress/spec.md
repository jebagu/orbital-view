# orbital-view-telemetry-ingress Specification Delta

## Purpose

Define how prepared layout, meter, object, and diagnostic telemetry enters Orbital View Kit without becoming a production meter source-of-truth or realtime callback path.

## Standards Impact Summary

```text
Touches realtime: yes, indirectly; ingress must stay outside callback reachability.
Touches routing: no; ingress must preserve host-provided physical channel identity without routing decisions.
Meter source-of-truth: host-owned measured levels are authoritative in production; review-only synthetic sources are not production truth.
Callback reachability: telemetry ingress APIs are display/preparation APIs, not callback-safe APIs.
Overload policy: latest snapshot wins; stale, invalid, or excess display telemetry may be dropped or diagnosed.
Performance gates: future tests must cover channel identity, bounded validation, display cadence, and no geometry rebuilds on meter-only updates.
```

## Requirements

### Requirement: Prepared Snapshot Ingress

The system SHALL accept host-prepared scene, speaker meter, object frame, object meter, camera, selection, and diagnostic snapshots as display/preparation inputs.

#### Scenario: Valid prepared telemetry arrives

- GIVEN a host has prepared layout and meter snapshots outside its audio callback
- WHEN the snapshots enter Orbital View Kit
- THEN Orbital View Kit validates and renders them without claiming ownership of their source timing

#### Scenario: Invalid telemetry arrives

- GIVEN telemetry contains non-finite values, duplicate physical channels, unknown object IDs, or unsupported bounds
- WHEN Orbital View Kit validates the snapshot
- THEN the invalid state is rejected, clamped, or diagnosed according to the relevant core contract

### Requirement: Physical Identity Preservation

The system SHALL preserve host-provided physical speaker channel identity through telemetry ingress and rendering.

#### Scenario: Extra or missing meter channels arrive

- GIVEN a meter snapshot has missing, extra, or duplicate channels
- WHEN the snapshot is adapted for display
- THEN Orbital View Kit reports diagnostics and must not reorder, downmix, or synthesize production meter truth

### Requirement: Telemetry Source Provenance

The system SHALL attach a source descriptor to every displayed speaker meter and object meter frame.

#### Scenario: Host provides production meter telemetry

- GIVEN a host adapter prepares speaker or object meter frames
- WHEN it forwards them to Orbital View Kit
- THEN the frame identifies one source kind such as speaker bus, object bus, final output, hardware tap, external Wavefield stream, Orbisonic prepared meter tap, or Splat prepared analysis

#### Scenario: Review or stress telemetry is displayed

- GIVEN a review surface, local livestream test generator, local audio file, or synthetic visual stress source emits display telemetry
- WHEN the telemetry enters Orbital View Kit
- THEN the frame labels that source as test/review/stress provenance rather than production meter truth

### Requirement: Lossy Display Overload Policy

The system SHALL treat visual telemetry as latest-complete-frame-wins.

#### Scenario: Display is overloaded

- GIVEN complete prepared snapshots arrive faster than the viewport can render
- WHEN Orbital View Kit applies display telemetry
- THEN it may drop stale frames, decimate display refresh, keep only the latest complete snapshot, and set diagnostics outside realtime paths

#### Scenario: Realtime path is under pressure

- GIVEN host audio is running
- WHEN visual telemetry or diagnostics cannot keep up
- THEN audio must not wait for the viewport, callbacks must not allocate more display queue, callbacks must not log or post UI, and raw packets must not enter renderer paths

### Requirement: Visual Telemetry Stress Gate

The system SHALL provide a display-only stress fixture that proves viewport no-backpressure behavior without claiming host audio callback compliance.

#### Scenario: Stress fixture saturates visual telemetry

- GIVEN a visual stress fixture with 30 physical speakers, 128 source objects, capped object trails, 60 FPS active motion, diagnostics open, and local livestream generator source metadata
- WHEN speaker and object meter frames arrive faster than display cadence
- THEN Orbital View Kit keeps physical speaker and object identity stable
- AND stale display frames may be dropped or decimated with overload diagnostics
- AND diagnostics must not fabricate missing-channel, invalid-channel, replacement, clamping, timestamp, or audio-failure state
- AND the passing condition is viewport no-backpressure behavior, not host callback p99 or deadline compliance
