# Orbital View Turbo Work Package: Source-Lane Telemetry Consumer For Wave Relay

Status: ready for implementation
Date: 2026-06-17
Project/workspace: `Orbital View Turbo`
Target workspace root: `/Users/jeremyguillory/Documents/vibecode-projects/Orbital-View-Turbo`
Related producer repo: `/Users/jeremyguillory/Documents/vibecode-projects/Wave Relay JUCE`
Related telemetry package: `/Users/jeremyguillory/Documents/vibecode-projects/orbisonic-telemetry`

## Purpose

Connect Orbital View Turbo to Wave Relay's Orbisonic telemetry provider by consuming the `sourceLaneMeters` slot that Wave Relay publishes.

Wave Relay currently publishes a live provider record under:

```text
~/Library/Caches/Orbisonic/Telemetry/registry-v1/providers/
```

The live Wave Relay record advertises:

```text
appID: com.sonicsphere.waverelay
appName: Wave Relay
slotName: sourceLaneMeters
slotTypeRawValue: 101
capabilityBits: 32
recordCapacity: 30
recordStride: 48
humanSourceLabel: sourceLaneMeters CH001-CH030
```

Orbital View Turbo currently does not connect because `OrbitalViewTelemetryConsumer` only accepts `speakerMeters` providers:

```text
record.slotSummary contains TelemetrySlotType.speakerMeters
requiredSlots: [.speakerMeters]
segment.reader(for: .speakerMeters)
decodeSpeakerMeters(...)
```

This package adds a real `sourceLaneMeters` consumer path in the Orbital View Turbo workspace. Do not solve this by making Wave Relay publish fake `speakerMeters`.

## Source Of Truth

Read before implementation:

```text
AGENTS.md
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/status.md
docs/bugs.md
work-packages/orbital-view-kit/MV.md
```

Read the relevant implementation files:

```text
Sources/OrbitalViewTelemetry/OrbitalViewTelemetryConsumer.swift
Sources/OrbitalViewReview/OrbitalViewportMockup.swift
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewCore/OrbitalViewTelemetrySource.swift
Tests/OrbitalViewTelemetryTests/OrbitalViewTelemetryConsumerTests.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
```

Read the Orbisonic telemetry ABI files:

```text
/Users/jeremyguillory/Documents/vibecode-projects/orbisonic-telemetry/Sources/OrbisonicTelemetryKit/TelemetryABI.swift
/Users/jeremyguillory/Documents/vibecode-projects/orbisonic-telemetry/Sources/OrbisonicTelemetryKit/PayloadRecords.swift
/Users/jeremyguillory/Documents/vibecode-projects/orbisonic-telemetry/Sources/OrbisonicTelemetryKit/SharedMemorySegment.swift
/Users/jeremyguillory/Documents/vibecode-projects/orbisonic-telemetry/Sources/OrbisonicTelemetryDashboard/DashboardModel.swift
```

Read the Wave Relay producer docs/code for exact producer semantics:

```text
/Users/jeremyguillory/Documents/vibecode-projects/Wave Relay JUCE/docs/rt/adr/0022-orbisonic-source-lane-telemetry.md
/Users/jeremyguillory/Documents/vibecode-projects/Wave Relay JUCE/docs/rt/audio_surface_registry.md
/Users/jeremyguillory/Documents/vibecode-projects/Wave Relay JUCE/Source/ui/OrbisonicSourceLaneTelemetry.h
/Users/jeremyguillory/Documents/vibecode-projects/Wave Relay JUCE/Source/ui/OrbisonicSourceLaneTelemetry.cpp
```

## Current Diagnosis

Observed live on 2026-06-17:

- Wave Relay Release app was running and publishing a registry record.
- The registry record modification time advanced over a two-second window, so the producer heartbeat was alive.
- Orbital View Turbo was running from its existing app bundle.
- Orbital View Turbo did not show the Wave Relay provider because it filters for `speakerMeters`, not `sourceLaneMeters`.
- The Turbo launcher failed to rebuild because `Package.swift` points to a missing local dependency path:

```text
/Users/jeremyguillory/Documents/orbisonic telemetry
```

The dependency exists at:

```text
/Users/jeremyguillory/Documents/vibecode-projects/orbisonic-telemetry
```

## Goals

1. Make Orbital View Turbo discover Wave Relay providers that publish `sourceLaneMeters`.
2. Read slot type `TelemetrySlotType.sourceLaneMeters` from the shared-memory segment.
3. Decode Wave Relay's 30 source-lane records into Orbital View's meter snapshot/render path.
4. Preserve source-lane identity as lanes `1...30`; do not invent channel 31/32.
5. Surface the provider as a valid Telemetry advertiser in the Orbital View Turbo review UI.
6. Keep current `speakerMeters` behavior working for existing providers.
7. Fix the local dependency path so `Open Orbital View.command` can rebuild before launch.

## Non-Goals

- Do not edit Wave Relay in this package.
- Do not make Wave Relay publish `speakerMeters`.
- Do not relabel source-lane meters as destination speaker/output truth.
- Do not add audio callbacks, audio playback, route discovery, device I/O, OSC, MIDI, or realtime queues to Orbital View Turbo.
- Do not add LUFS, true peak, PPM, custom VU ballistics, or any new metering dependency.
- Do not consume LFE/source channel 31 or unused channel 32 from Wave Relay; Wave Relay intentionally publishes only 30 lanes.
- Do not require immediate speaker topology support for Wave Relay source lanes.

## Data Contract

Wave Relay source-lane record layout is 48 bytes:

```text
offset 0:  UInt32 sourceLaneID
offset 4:  UInt32 streamID
offset 8:  UInt32 midiChannel
offset 12: UInt32 primaryMappedObjectID
offset 16: UInt32 primaryMappedChannelID
offset 20: Float32 rms
offset 24: Float32 peak
offset 28: UInt8 clip
offset 32: UInt64 flags
```

Required interpretation:

- `sourceLaneID` maps to Orbital View Turbo meter key `1...30`.
- `rms` is the default visual/display drive unless a later schema supplies trusted `vuNormalized`.
- `peak` remains a signal fact.
- `clip` remains a signal fact.
- `flags` may be preserved for diagnostics, but do not depend on new flag semantics in this slice.
- `streamID`, `midiChannel`, `primaryMappedObjectID`, and `primaryMappedChannelID` may be retained for future diagnostics, but the first implementation may omit them from the visual model if no existing type supports them cleanly.

Ballistics semantics:

- Peak reacts immediately to sample maximums.
- RMS is smoother energy-style level.
- Wave Relay reuses existing JUCE RMS ballistics for display-friendly smoothing.
- Orbital-style visual drive should use RMS until a later shared schema adds trusted source-lane `vuNormalized`.

## Implementation Plan

### Slice 1: Fix Local Telemetry Dependency Path

Update `Package.swift` to point at the actual local package path:

```text
/Users/jeremyguillory/Documents/vibecode-projects/orbisonic-telemetry
```

Then verify:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
```

If this path should stay machine-local, document that in `docs/status.md` rather than hiding the assumption.

### Slice 2: Add Source-Lane Decode Model

In `Sources/OrbitalViewTelemetry/OrbitalViewTelemetryConsumer.swift`, add a decoder for `sourceLaneMeters` frames.

Expected behavior:

- Require `recordStride >= SourceLaneMeterPayloadRecord.byteSize`.
- Reject truncated payloads.
- Skip lane IDs less than 1.
- Preserve lanes `1...30`.
- Ignore absent 31/32 rather than treating them as missing speaker channels.
- Decode `rms`, `peak`, and `clip`.
- Use `rms` as display drive through the existing `OrbitalViewTelemetryMeterLevel` fallback behavior.

Use the shared ABI constants from `OrbisonicTelemetryKit` where possible:

```text
TelemetrySlotType.sourceLaneMeters
SourceLaneMeterPayloadRecord.byteSize
TelemetryCapabilityBits.sourceLaneMeters
```

### Slice 3: Teach Provider Selection About Meter Slot Kinds

Update provider discovery so it accepts compatible meter providers from either:

```text
speakerMeters
sourceLaneMeters
```

Preserve existing speaker-meter priority if both are available, unless the UI selection explicitly chooses the source-lane provider.

Recommended approach:

- Add an internal selected/attached slot type beside `attachedProviderID`.
- Select candidate records when they contain at least one supported meter slot.
- For each selected provider, attach the matching reader:

```text
segment.reader(for: .speakerMeters)
segment.reader(for: .sourceLaneMeters)
```

- Decode with the matching decoder.
- Keep status text clear enough to distinguish `Speaker meters` from `Source lane meters`.

### Slice 4: Surface Source-Lane Providers In Review UI

Update the Telemetry section in `Sources/OrbitalViewReview/OrbitalViewportMockup.swift` so source-lane providers are not shown as "No Provider" in Orbital View Turbo.

Expected UI behavior:

- Provider button/title should show Wave Relay as a telemetry advertiser.
- `Telemetry Status` should read as connected/live when frames are readable.
- `Displayed Meter` should identify source-lane telemetry, not DVS/speaker output.
- The grid title should not say `32ch VU` for Wave Relay source lanes; use copy like `30 Source Lanes` or `Source Lane VU`.
- Channel count should show `30 / 30` when Wave Relay is publishing all lanes.

### Slice 5: Tests

Add or update tests in:

```text
Tests/OrbitalViewTelemetryTests/OrbitalViewTelemetryConsumerTests.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
```

Required test coverage:

- A registry provider with only `sourceLaneMeters` is considered compatible.
- Provider selection can select source-lane-only Wave Relay records.
- Consumer attaches `reader(for: .sourceLaneMeters)`.
- Decoder maps source lane IDs `1...30` into 30 meter levels.
- LFE/31/32 absence is not an error.
- RMS/peak/clip decode correctly.
- Existing `speakerMeters` tests still pass unchanged.
- UI advertiser selection handles one source-lane provider.
- UI copy distinguishes `Source lane` from `Speaker/DVS` output.

### Slice 6: Launcher Verification

Run the project launcher after the dependency path is fixed:

```text
/Users/jeremyguillory/Documents/vibecode-projects/Open Orbital View Kit Latest.command
```

Expected:

- Launcher rebuilds `OrbitalViewViewer`.
- App bundle is refreshed and signed.
- Any stale `OrbitalViewViewer` process is restarted.
- The launched app sees Wave Relay when Wave Relay is already running and publishing telemetry.

## Protected Path Check

This package may touch protected UI/review paths:

```text
Sources/OrbitalViewReview/OrbitalViewportMockup.swift
```

This is explicitly permitted for the purpose of surfacing source-lane telemetry in the current visible review app.

This package may touch telemetry/control paths:

```text
Sources/OrbitalViewTelemetry/OrbitalViewTelemetryConsumer.swift
Tests/OrbitalViewTelemetryTests/OrbitalViewTelemetryConsumerTests.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
Package.swift
docs/status.md
docs/contracts.md
docs/implementation-map.md
docs/test-strategy.md
docs/bugs.md
```

Do not touch:

```text
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Wave Relay source files
Orbisonic telemetry package source files
```

unless the implementation discovers a documented contract bug and the human explicitly approves widening scope.

## Documentation Updates

Update after implementation:

```text
docs/status.md
docs/contracts.md
docs/implementation-map.md
docs/test-strategy.md
```

Update `docs/bugs.md` with the dependency-path issue if it is not fixed in this package.

Document:

- `sourceLaneMeters` is a source-origin meter, not speaker/output truth.
- Wave Relay publishes exactly 30 source lanes.
- Current source-lane display drive uses RMS.
- `speakerMeters` remains supported for existing final-output providers.
- Orbital View owns no realtime callback and does not backpressure producer apps.

## Verification Commands

Run:

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
/Users/jeremyguillory/Documents/vibecode-projects/Open Orbital View Kit Latest.command
```

Manual verification:

1. Launch Wave Relay Release build.
2. Confirm Settings > Meter Outputs shows `Source lane meters`.
3. Confirm Wave Relay creates a live provider JSON under:

```text
~/Library/Caches/Orbisonic/Telemetry/registry-v1/providers/
```

4. Launch Orbital View Turbo through the parent launcher.
5. Select Telemetry mode in the review app.
6. Confirm Wave Relay appears as a provider.
7. Confirm the app shows 30 lanes, not 31/32.
8. Confirm RMS-driven visual response when Wave Relay is playing a source.

## Acceptance Criteria

- `Open Orbital View.command` can rebuild against the local telemetry dependency.
- Orbital View Turbo discovers a Wave Relay `sourceLaneMeters` provider.
- Orbital View Turbo attaches to slot type `101`.
- Orbital View Turbo reads 30 lane records and renders them through the existing meter path.
- The UI labels Wave Relay telemetry as source-lane telemetry.
- Existing `speakerMeters` telemetry providers still work.
- `swift build` passes.
- `swift test` passes.
- No audio callback, playback, routing, device I/O, MIDI, OSC, or realtime queue code is added.

## Risks

- The existing app bundle may contain older code; always rebuild and relaunch before validating.
- Provider selection currently assumes `speakerMeters`; changing it carelessly could regress existing speaker-meter providers.
- `sourceLaneMeters` record layout is wider than `speakerMeters`; using the speaker decoder will produce incorrect values.
- Wave Relay may show no active levels until a source is opened/playing, but provider discovery should still work while idle.

## Recommended Implementation Order

1. Fix `Package.swift` dependency path and verify build.
2. Add source-lane decoder tests.
3. Add source-lane provider selection.
4. Add UI copy/status support.
5. Run full tests.
6. Launch Wave Relay and Orbital View together for live proof.
