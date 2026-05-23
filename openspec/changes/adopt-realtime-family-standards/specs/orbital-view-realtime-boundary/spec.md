# orbital-view-realtime-boundary Specification Delta

## Purpose

Define the boundary that keeps Orbital View Kit out of realtime callback ownership while it adopts the Realtime Audio Family Standards.

## Standards Impact Summary

```text
Touches realtime: yes, by defining a negative boundary; no realtime code is added.
Touches routing: no; routing remains host-owned.
Meter source-of-truth: host-owned measured meter data only.
Callback reachability: Orbital View Kit APIs are not callback-reachable unless a future OpenSpec change proves a narrower callback-safe contract.
Overload policy: host may drop, coalesce, or decimate visual telemetry before Orbital View Kit; Orbital View Kit may drop/coalesce display updates.
Performance gates: future source changes must prove no callback blocking and must keep display work out of realtime paths.
```

## Requirements

### Requirement: Realtime Plane Exclusion

The system SHALL classify Orbital View Kit as Control / UI / Telemetry Plane plus Preparation Plane adapters, with no owned Realtime Plane.

#### Scenario: Host publishes prepared meter snapshots

- GIVEN a host app has measured speaker meters in its own realtime-safe path
- WHEN it sends prepared snapshots to Orbital View Kit
- THEN Orbital View Kit may validate, store, and render those snapshots outside the realtime callback path

#### Scenario: Callback-reachable call is proposed

- GIVEN a future task proposes calling Orbital View Kit from an audio callback or callback-reachable function
- WHEN the task is reviewed
- THEN the task must stop unless a new OpenSpec change defines and verifies a callback-safe contract

### Requirement: No Audio Ownership

The system SHALL keep playback scheduling, device routing, MIDI, OSC, file parsing, and realtime event queues outside Orbital View Kit.

#### Scenario: Route decision is requested

- GIVEN a host app needs to select, reorder, downmix, or route audio channels
- WHEN Orbital View Kit displays that host state
- THEN Orbital View Kit must not decide or mutate the route

