# System Flows

## Current Scaffold Flow

```mermaid
flowchart TD
  WorkPackage["OrbitalViewKit work package"] --> Docs["Project docs"]
  Docs --> Task["First bounded task"]
  Task --> FutureCode["Future OrbitalViewCore source"]
```

## Future Monitor Data Flow

```mermaid
flowchart LR
  HostLayout["Host speaker layout"] --> Adapter["App adapter"]
  HostMeters["Host meter frames"] --> Adapter
  Adapter --> Core["OrbitalViewCore scene + meters"]
  Core --> Renderer["OrbitalView renderer"]
  Renderer --> UI["Host app viewport"]
```

## Future Camera Flow

```mermaid
flowchart TD
  User["User drag or preset click"] --> Wrapper["SwiftUI wrapper"]
  Wrapper --> Camera["OrbitalViewCameraState"]
  Camera --> Validate["Center-lock validation"]
  Validate --> Renderer["Renderer camera update"]
  Renderer --> Event["cameraChanged event"]
```

## Boundary Flow

```mermaid
flowchart TD
  Audio["Host audio and metering"] --> Snapshot["Measured meter snapshot"]
  Snapshot --> Viewport["OrbitalViewKit"]
  Viewport --> Selection["Selection and camera events"]
  Selection --> HostUI["Host UI diagnostics"]
```

Orbital View Kit consumes measured state and emits UI-facing events. It does not own audio timing, playback, routing, MIDI, OSC, or output behavior.

