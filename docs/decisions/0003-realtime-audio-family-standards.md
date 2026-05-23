# ADR 0003: Realtime Audio Family Standards Inheritance

Status: accepted

Date: 2026-05-23

## Context

Orbital View Kit is a reusable spherical speaker and object viewport module for Orbisonic-family realtime audio tools. It visualizes prepared speaker layouts, meter snapshots, object telemetry, camera state, and selection events.

The project is audio-adjacent but does not own audio callbacks, playback scheduling, output routing, MIDI, OSC, or realtime meter extraction. Downstream host applications remain responsible for their own realtime audio planes and for publishing prepared display snapshots to Orbital View Kit.

The shared family standards live outside this repository at:

```text
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards
```

## Decision

This project inherits the Realtime Audio Family Standards Package. The Bencina Realtime Callback Doctrine is mandatory for every callback and every callback-reachable function. Project-specific requirements may add stricter rules but may not weaken the family standard.

Orbital View Kit currently fits the Control / UI / Telemetry Plane plus Preparation Plane adapters. It owns no Realtime Plane and must not claim callback safety for public APIs unless a future OpenSpec change proves and documents that contract explicitly.

The standards package is referenced rather than copied so updates remain centralized across the realtime audio family.

## Consequences

- Orbital View Kit consumes host-prepared layout, meter, object, and selection state.
- Host applications own realtime callbacks, callback-safe queues, audio device routing, playback timing, MIDI, OSC, and meter extraction.
- Orbital View Kit renderer and SwiftUI code may render display-rate telemetry, drop frames, coalesce updates, and expose UI diagnostics, but they must not become callback-reachable.
- Future downstream integrations with Wavefield, Orbisonic, Splat, or other realtime hosts must keep callback-reachable work out of Orbital View Kit and document any stricter project-specific rules in OpenSpec.
- Visual testing inputs, including local file playback or livestream generators, are review and test harness sources only unless a future task defines a production host contract.
