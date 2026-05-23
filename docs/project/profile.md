# Orbital View Kit Project Profile

Status: active project profile

Last updated: 2026-05-23

## Inherited Standard

```text
Family standard: Realtime Audio Family Standards Package
Inherited standard revision: 2026-05-23-family-standard
Reference path: /Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards
```

This project inherits the Realtime Audio Family Standards Package. The Bencina Realtime Callback Doctrine is mandatory for every callback and every callback-reachable function. Project-specific requirements may add stricter rules but may not weaken the family standard.

## Product Identity

```text
Product name: Orbital View Kit
App type: reusable visual telemetry module
Backend choice: MetalKit renderer with SwiftUI wrapper
Plugin / standalone target: Swift package libraries plus OrbitalViewViewer review executable
Supported sample rates: not owned by this kit
Block-size assumptions: not owned by this kit
Channel / routing model: host-owned, explicit physical channel identity preserved
Event sources: host prepared snapshots only
Control sources: SwiftUI bindings and host state only
Telemetry outputs: lossy visual frames and diagnostics
Stress scenes: display-only no-backpressure scenes
```

Orbital View Kit is not an audio engine, output router, playback scheduler, plugin host, session parser, OSC/MIDI receiver, or realtime event queue owner.

## Plane Map

```text
Realtime Plane: none owned by Orbital View Kit
Preparation Plane: validation, normalization, fixtures, host adapters, and immutable display snapshots
Control / UI / Telemetry Plane: renderer state, SwiftUI wrapper, review executable, camera/selection events, visual frames, diagnostics
```

| Target or surface | Plane | Callback entry ownership | Callback-safe API status | Notes |
| --- | --- | --- | --- | --- |
| `OrbitalViewCore` | Preparation Plane | none | not callback-safe | Validates scene, meter, object, camera, selection, and visual settings contracts. Host apps must call it outside audio callbacks. |
| `OrbitalViewWavefield` | Preparation Plane adapter | none | not callback-safe | Converts Wavefield-style prepared layouts and meter records into core contracts. It must not run inside Wavefield audio callbacks. |
| `OrbitalViewRender` | Control / UI / Telemetry Plane | none | not callback-safe | MetalKit renderer seam for display-rate visual state. It must not be called directly from audio callbacks. |
| `OrbitalViewSwiftUI` | Control / UI / Telemetry Plane | none | not callback-safe | Production SwiftUI/MTKView host wrapper. Production hosts must feed it host-prepared snapshots only. |
| `OrbitalViewReview` | Control / UI / Telemetry Plane review/demo surface | none | not callback-safe | SceneKit review surface, local file playback, impulse inputs, app-bundle themes, PNG export, and bundled font tooling. It must not be treated as production meter truth. |
| `OrbitalViewViewerSupport` | Preparation Plane for review fixtures | none | not callback-safe | Provides deterministic demo/review content and must not be treated as production meter truth. |
| `OrbitalViewViewer` | Control / UI / Telemetry Plane review surface | none | not callback-safe | Standalone executable that hosts `OrbitalViewReview` for visual tuning, local test sources, themes, and diagnostics. |
| Test targets | Test / verification plane | none | not callback-safe | Validate contracts and display invariants. They do not establish realtime callback safety. |

Production `OrbitalViewSwiftUI` and `OrbitalViewRender` are not callback-safe APIs. They are display and host-UI APIs.

## Callback Inventory

Owned callback entry points:

```text
none
```

Callback-adjacent host warning:

```text
Host apps must not call Orbital View Kit from audio callbacks or callback-reachable functions.
```

Current callback inventory:

- Orbital View Kit owns no audio render callback.
- Orbital View Kit owns no CoreAudio, AVAudioEngine, AudioUnit, JACK, JUCE, plugin, MIDI, OSC, or network realtime callback.
- Orbital View Kit owns no realtime queue that feeds audible output.
- Orbital View Kit owns no route discovery, route repair, output device selection, or channel-map mutation callback.
- Orbital View Kit may receive host-prepared snapshots after a host-owned callback-safe bridge has crossed into the Preparation Plane or Control / UI / Telemetry Plane.
- Review-only local file, impulse, fake-meter, and local livestream generator inputs are not production callback entry points and are not production meter source-of-truth.

## Source Of Truth

Production meter source-of-truth:

```text
host-owned measured meters
```

Production channel source-of-truth:

```text
host-owned physical channel identity
```

Orbital View Kit may sanitize, reject, diagnose, display, coalesce, or drop telemetry. It must not synthesize production truth, downmix production channels, reorder physical speaker channels, or backpressure host audio timing.

Meter frames carry source descriptors. Production hosts should choose from speaker bus, object bus, final output, hardware tap, external Wavefield stream, Orbisonic prepared meter tap, or Splat prepared analysis. Review and test harness sources include local livestream test generator, review local audio, and synthetic visual stress; those sources are display/stress evidence only.

## Overload And Stress Profile

Telemetry overload policy:

- latest host-prepared snapshot wins;
- stale display frames may be dropped;
- display refresh may be decimated;
- only the latest complete snapshot needs to be retained;
- diagnostics flags may be set outside realtime;
- visual stress must not create backpressure into host audio;
- meter-only updates must not rebuild static speaker geometry;
- object trails and glow trails must stay capped by configured display limits.

Forbidden overload behavior:

- audio waits for viewport rendering;
- an audio callback allocates more display queue;
- an audio callback logs or posts UI;
- raw packets enter renderer paths without host preparation.

Stress scenes are display-only no-backpressure scenes. Valid stress sources include deterministic Fey 30 speaker fixtures, synthetic impulse waves/comets, local file review playback reduced to visual RMS/peak samples, object-frame churn, and the planned host-owned local livestream test generator.

The canonical Slice 9 visual telemetry stress scene is `OrbitalViewVisualTelemetryStressScene`: 30 physical speakers, 128 source objects, 16 capped trail points per object, 60 FPS active motion, 120 FPS incoming meter cadence, open diagnostics, `.localLivestreamTestGenerator` provenance, and `32-object-should-pass-stress` profile metadata. Dropped display frames are diagnostics-only overload events and must not be represented as audio failure.

Wavefield realtime connection:

- Wavefield owns external livestream parsing, the local livestream test generator, MIDI streams, realtime queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and performance gates.
- Orbital View Kit receives prepared scene, speaker meter, object frame, object meter, diagnostics, and source metadata snapshots only.
- Wavefield object IDs remain source-object identity; speaker channels remain physical speaker identity.
- Local generator profile names such as `smoke`, `moving-pose`, `sustained-moving-object`, `burst-reorder`, `16-object-stress`, and `32-object-should-pass-stress` are source metadata and display stress inputs only.

Stress evidence from these scenes proves display behavior only. It does not prove host realtime audio compliance.

Display stress gates:

- meter-only updates do not rebuild static speaker geometry;
- object meter updates do not rebuild speaker geometry;
- retained buffers remain stable for meter/camera/settings-only updates;
- diagnostics remain capped;
- stale display frames are dropped or decimated without backpressure.

Host-owned gates:

- callback deadline hit rate;
- p99 and worst-case callback duration;
- callback allocation checks;
- route repair timing;
- device I/O timing;
- MIDI/OSC/event-queue timing;
- meter extraction timing.

## Integration Rule

Host applications must bridge realtime data into host-owned prepared snapshots before invoking Orbital View Kit. Any future task that proposes callback reachability, routing ownership, production meter ownership, or protected downstream audio behavior must start with an OpenSpec change and specialty review.

Orbisonic and Splat host profiles live in `docs/integrations/orbisonic-splat-host-profiles.md`.

Orbisonic profile:

- Orbisonic owns playback, transport, Core Audio device I/O, route discovery, route repair, channel mapping, output routing, render/control engines, meter extraction, explicit tap points, operator state, and realtime performance gates.
- Orbital View Kit receives prepared bus, object, and speaker meter snapshots plus diagnostics and source metadata.
- Orbisonic tap-point labels are source metadata only and should use `orbisonicPreparedMeterTap` unless a future integration slice defines a narrower descriptor.
- Orbisonic design-language defaults and palette grammar remain visual guidance only.

Splat profile:

- Splat owns project/session state, authoring commands, renderer-kernel analysis, neutral geometry import/export decisions, file formats, persistence, and any eventual handoff to an audio/render host.
- Orbital View Kit may visualize virtual speakers, source objects, renderer-kernel overlays, neutral geometry review, camera, selection, and diagnostics.
- Splat analysis snapshots should use `splatPreparedAnalysis`.
- Edit/export remains preparation/control behavior; canonical 3D coordinates must not be replaced by permanent flattened screen coordinates.

## UI Design Language

Orbital View Kit uses `docs/orbisonic-design-language.md` as its local design-language contract for future UI and review-surface work.

The referenced Orbisonic design-language workspace is a visual and ergonomic guide for shell layout, panel density, palette behavior, diagnostics separation, and meter treatment. It does not change Orbital View Kit's product role, audio boundaries, or host ownership model.
