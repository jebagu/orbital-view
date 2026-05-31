# Architecture

## Overview

Orbital View is the canonical head project for the layered Swift module family for spherical speaker visualization. The first layer is `OrbitalViewCore`, a pure data and validation target. Rendering, SwiftUI wrapping, review tooling, and downstream app adapters are separate layers. `Orbital View Kit` is now a non-head historical label.

## Realtime Audio Family Standards Inheritance

This project inherits the Realtime Audio Family Standards Package. The Bencina Realtime Callback Doctrine is mandatory for every callback and every callback-reachable function. Project-specific requirements may add stricter rules but may not weaken the family standard.

Orbital View currently fits the Control / UI / Telemetry Plane plus Preparation Plane adapters. It owns no Realtime Plane, no audio callback entry point, no playback scheduler, no output routing, and no MIDI or OSC transport. Its public package APIs consume host-prepared scene, meter, object, and camera state for display-rate rendering.

The shared standards package is referenced from `/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards`; it is not copied into this repository.

The closeout audit for the adoption package lives in `docs/realtime-family-compliance-audit.md`. It is the current record of inherited standards, plane ownership, callback inventory, OpenSpec status, review-only separation, host-generator boundaries, Orbisonic design-language use, and remaining risks.

## Planned Module Layers

```text
OrbitalViewCore
  Pure data contracts, validation, coordinate system, shell/speaker/meter/camera types.

OrbitalViewRender
  MetalKit / MTKView renderer seam with an initial offscreen smoke-tested draw path.

OrbitalViewSwiftUI
  Production SwiftUI wrapper and MetalKit bridge for host apps.

OrbitalViewReview
  Review/demo-only SceneKit, local-audio, theme, PNG export, and font tooling.

OrbitalViewDomeLab
  Optional neutral shell geometry import/export bridge.

OrbitalViewSplat
  Optional Splat editor overlays for virtual speakers, source objects, and renderer kernels.

OrbitalViewWavefield
  Local Wavefield speaker-layout JSON and meter-frame adapters into OrbitalViewCore.

OrbitalViewSpatGRIS
  SpatGRIS speaker/source setup XML, project metadata, OSC source-position parsing, and validation helpers.
```

`OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewSpatGRIS`, `OrbitalViewRender`, `OrbitalViewSwiftUI`, and `OrbitalViewReview` are implemented. `OrbitalViewRender` now has an instanced Metal cube/prism speaker draw path verified by offscreen smoke tests, pixel probes, retained-buffer checks, object overlay tests, and invariant tests for static draw inputs. Broad SwiftUI gestures, hit testing, shell/label visuals, and downstream app source integration remain deferred.

## Runtime Architecture

Current package:

```text
OrbitalViewCore tests and validates core scene contracts.
OrbitalViewWavefield converts Wavefield speaker-layout JSON into OrbitalViewCore scenes.
OrbitalViewWavefield converts Wavefield-style channel/rms/peak meter records into SpeakerMeterFrame.
OrbitalViewSpatGRIS imports/exports normalized SpatGRIS speaker setup XML, imports SpatGRIS project source metadata, parses /spat/serv source-position OSC messages, and exposes diagnostics without owning UDP networking.
OrbitalViewRender stores scene, speaker meters, cube VU settings, dynamic object frames, object meters, object visual settings, camera, and selection state behind a MetalKit renderer seam. Internal draw-input snapshots separate static speaker geometry from display-only speaker material inputs and object overlay inputs for invariant testing.
OrbitalViewSwiftUI wraps the renderer seam in an NSViewRepresentable MTKView bridge and can opt into native collapsible tuning trays for Orbisonic theme selection, Cube VU / Pixel Jets / Cell Jets speaker settings, object overlays, trails, fixed object bounds, presets, performance-versus-CPU controls, and diagnostics.
OrbitalViewReview owns the SceneKit review surface, local file playback, review impulse sources, app-bundle themes, SpatGRIS speaker/source layout persistence, review-only UDP OSC listening, PNG export, bundled fonts, and AppKit/CoreText label generation.
```

Future runtime shape:

```text
Host app
  -> app-owned layout, meter, selection, and camera state
  -> OrbitalViewSwiftUI
  -> OrbitalViewRender
  -> OrbitalViewCore contracts
```

Review/demo path:

```text
OrbitalViewViewer
  -> OrbitalViewReview
  -> OrbitalViewCore contracts
```

The production viewport receives scene and meter state from the host app. It does not parse files, schedule playback, receive OSC, parse MIDI, or decide output routing.

## Renderer Backend Decision

Production rendering uses the custom MetalKit / MTKView direction in `OrbitalViewRender`, wrapped by `OrbitalViewSwiftUI` for host-app binding.

Current renderer drawing maps scene speaker anchors to one stable instanced cube/prism mesh per speaker. Meter values are looked up by physical channel and converted into display-only cube VU material scalars; shell geometry, labels, hit testing, production camera projection, and broader visual polish remain deferred.

Long-term renderer source should not be SceneKit-first, RealityKit-first, WebView-based, or DomeLab-code-based. SceneKit or HTML mockups may be used only as disposable prototypes if a future task explicitly allows that scope.

## Audio Architecture

Orbital View does not own audio behavior.

Current plane fit:

```text
Realtime Plane: none owned by Orbital View
Preparation Plane: scene, layout, meter, object, and host-adapter normalization
Control / UI / Telemetry Plane: renderer state, SwiftUI wrapper, camera/selection events, diagnostics, and review surfaces
```

Host applications must extract meters and publish prepared snapshots from their own realtime-safe paths. Orbital View may coalesce, drop, or interpolate display updates, but it must not be called directly from an audio callback unless a future task establishes an explicit callback-safe contract.

It may consume already-computed meter frames:

```text
channel -> rms / peak / clip
```

It must not:

- run audio callbacks
- perform playback or rendering
- downmix or reorder channels
- make routing decisions
- block timing-sensitive host paths

## Wavefield Realtime Host Boundary

The Wavefield realtime connection is specified in `docs/integrations/wavefield-realtime-connection.md`.

Wavefield owns external live stream parsing, the local livestream test generator, local MIDI streams, realtime event queues, object lifecycle, sample-time scheduling, audio rendering, route validation, meter extraction, and performance gates. Orbital View receives prepared scene, speaker meter, object frame, object meter, diagnostics, and source metadata snapshots only.

The local livestream test generator is a normal Wavefield host source. Generator profile names such as `smoke`, `moving-pose`, `sustained-moving-object`, `burst-reorder`, `16-object-stress`, and `32-object-should-pass-stress` are source metadata and stress inputs only, not alternate audio paths.

## Visual Telemetry Stress Boundary

The canonical display stress gate is specified in `docs/visual-telemetry-stress-gates.md`.

`OrbitalViewVisualTelemetryStressScene` defines a display-only fixture with 30 physical speakers, 128 source objects, capped object trails, 120 FPS active motion, 120 FPS incoming meter cadence, 30 FPS displayed meter cadence, open diagnostics, local livestream generator provenance, and stale display frame diagnostics. This fixture proves Control / UI / Telemetry Plane no-backpressure behavior only.

Host callback p99, callback deadline, route repair timing, device I/O timing, MIDI/OSC timing, and meter extraction timing remain host-owned performance gates. Orbital View cannot claim host realtime callback compliance because it owns no callback entry point.

## Orbisonic And Splat Host Profiles

The Orbisonic and Splat host profiles are specified in `docs/integrations/orbisonic-splat-host-profiles.md`.

Orbisonic connects through prepared bus, object, and speaker meter snapshots from explicit tap points. Orbisonic owns playback, transport, Core Audio device I/O, route discovery, route repair, channel mapping, output routing, render/control engines, meter extraction, operator state, and realtime performance gates. Orbital View labels the prepared provenance, preserves physical channel/object identity, and follows the Orbisonic design-language palette grammar without becoming an Orbisonic source selector, route validator, or live mixer.

Splat connects through prepared virtual speaker/source/object layouts, renderer-kernel overlays, neutral geometry review snapshots, diagnostics, camera, and selection. Splat owns project/session state, authoring commands, kernel analysis, file formats, persistence, neutral geometry import/export, and any later handoff to an audio/render host. Orbital View must not store permanent flattened screen coordinates as canonical spatial state or import browser/DomeLab runtime code.

## UI Architecture

Orbital View UI and review surfaces follow `docs/orbisonic-design-language.md`. Future UI work must read the Orbisonic design-language references before changing shell layout, tuning trays, diagnostics, palette behavior, or visible meter treatment.

The design-language rule is intentionally visual and ergonomic. Orbital View should reuse Orbisonic-family shell grammar, compact technical panels, palette behavior, title-only panel headers, diagnostics separation, and Daft Punk Bow meter treatment without importing Orbisonic product semantics, playback controls, routing ownership, or realtime behavior.

The production wrapper now includes an optional native tuning surface. Hosts can keep the renderer as a plain viewport or opt into collapsible trays for:

- speaker VU shape/style/color/outline controls
- meter calibration controls
- surface, bloom, checker, and face-pixel controls
- Orbisonic design language theme selection for shell, speaker, label, fog, and VU color treatment
- Cube VU outline strength controls for retained edge-line materials
- object overlay, trail, glow-trail, and fixed `-5...+5` bounds controls
- graphical performance versus CPU load controls for active FPS, meter-only cadence, inspector cadence, draw-on-demand, face-pixel cost, and trail caps
- presets and debug diagnostics

Future host UI should still provide center-locked orbit camera controls, plan/front/side/isometric presets, projection controls, structure/speaker/label/cutaway toggles, and speaker selection events around the reusable viewport.

Wavefield and Orbisonic use monitor mode. Splat may enable edit modes later.

## Data Architecture

`OrbitalViewCore` owns value types for:

- coordinate systems
- 3D vectors and unit-sphere directions
- shell nodes, edges, and faces
- speaker anchors, shapes, and visual roles
- cartesian speaker anchors for imported layouts
- scene specs
- meter frames by channel
- telemetry source descriptors for speaker/object meter provenance
- source layout and source meter snapshots keyed by source ID
- camera state
- selection and events

Persistence is out of scope for core.

## Module Boundaries

Core rules:

- `OrbitalViewCore` has no dependency on SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, or downstream app targets.
- `OrbitalViewWavefield` depends only on Foundation and `OrbitalViewCore`; it must not depend on Wavefield package targets unless a future task explicitly changes that boundary.
- `OrbitalViewSpatGRIS` depends only on Foundation and `OrbitalViewCore`; it parses files and OSC payloads but does not open sockets or touch UI.
- `OrbitalViewRender` may depend on Metal and MetalKit; it must not depend on SwiftUI, AVFoundation, CoreMIDI, or downstream app targets.
- `OrbitalViewSwiftUI` may depend on SwiftUI, MetalKit, `OrbitalViewCore`, and `OrbitalViewRender`; it must not depend on AVFoundation, SceneKit, CoreMIDI, or downstream app targets.
- `OrbitalViewReview` may depend on SwiftUI, AppKit, AVFoundation, SceneKit, CoreText, UniformTypeIdentifiers, and `OrbitalViewCore` for review/demo tooling; it must not be required by production host integrations.
- Host apps adapt their own layouts and meters into core scene contracts.
- Renderer backends consume core types but do not change their semantic meaning.
- App integrations must preserve speaker channel identity and order.

## External Dependencies

Current implementation dependencies:

```text
Foundation
Metal
MetalKit
SwiftUI
```

Review-only dependencies live in `OrbitalViewReview`:

```text
AVFoundation
AppKit
SceneKit
CoreText
UniformTypeIdentifiers
Network
```

Future production rendering may use Apple-native rendering frameworks. A major third-party dependency requires an explicit task decision.

The accepted production rendering framework is MetalKit.

The current native review executable is a deliberately separate visual-review surface: `OrbitalViewViewer` hosts the confirmed VU Kit SceneKit `OrbitalViewportMockup` so the approved viewport controls, ribbed sphere overlay, tuning panel, PNG export, and adaptive SceneKit interaction can be tuned before downstream integration. The old imported/Fey geodesic shell is deprecated out of the live review path. This review app must not be confused with the rejected bare MTKView demo surface. Production host integration remains through the MetalKit renderer seam unless a later task explicitly changes that decision.

In the SceneKit review executable, the desktop left rail is a full-height always-on operator rail with plain product identity, Camera, and View Detail only. Its title reads `Orbital View` and uses the Wavefield Receiver player-panel title treatment; Camera and View Detail sit directly underneath near the top. `View Detail` owns Speaker Size, Fog Density, Speaker Numbers, Hidden Lines, and the display-only Ground Plane on/off switch. The right panel starts with a `Sound Metering Input` header above one expanded `Input` tray containing the `Telemetry`, `Local Song`, and `Impulse Test` selector, source-specific controls, and `Meter Source` rows. `Speaker and Source Layout` follows with `Sonic Sphere Speakers` and `Source Speakers` trays, each carrying SPAT XML kicker copy; `Roll the dice on looks` follows as a global view/visual randomizer with a centered icon-only dice button; `Theme` contains `Saved Themes`; `Speaker Appearance` contains `Speaker Shape`, `Speaker Pattern`, `Label Font`, `Sonic Sphere Speaker Palette`, `Source Speaker Palette`, `Cube Surface`, and `Bloom Style`; `Sphere Appearance` contains `Sphere Geometry` and `Geodesic Appearance`; `Ground Appearance` contains ground palette, visibility, spacing, and size controls; `Meter Behavior` contains `Meter Response` and `Performance`; `Diagnostics` contains the `Diagnostics` tray. `Sphere Geometry` owns the default-off `Ribbed Speaker Sphere` switch plus `Rib Thickness`, `Vertical Ribs`, and `Horizontal Rings`. `Geodesic Appearance` owns only the independent geodesic palette and saturation styling controls, and the global dice action changes every current `Sphere Appearance` control plus both speaker/source palette selectors. `Speaker Pattern` remains an empty future-work placeholder for now. `Cube Surface`, `Bloom Style`, and `Meter Response` each include a local dice-icon randomizer. Source-object overlay/trail controls are hidden in this review surface until the Wavefield object work resumes.

The review app startup defaults are pinned to the exported tuning payload `Orbital View Settings 2026-05-21-171537.json`: Purple speaker/app palette, Source Speaker palette falling back to the speaker palette for older JSON, Purple geodesic palette, hidden ribbed speaker sphere, Rib Thickness `100%`, `16` vertical ribs, `8` horizontal rings, Cube VU speaker type, Hot Core Bloom preset, Impulse Test Ripple drive, grayscale geodesic saturation, 86% pixel fill, muted idle checker opacity, cube outline strength `0.64`, and 60 fps active motion.

The SceneKit review app's Cube VU speaker type uses the shared Core cube scalar contract but implements the visible face skin locally with a retained SceneKit material. The material uses a retained 1...9 pixelated face texture cache applied directly to the actual six `SCNBox` cube faces and a Cube-VU-only readable face scale so the face grid is visible at small speaker sizes. The surface tray is titled `Cube Surface` for Cube VU and `Jet Surface` for Pixel Jets or Cell Jets; its first control is the `Pixel Density` slider capped at `1...9`. The tray also exposes `Pixel Fill` so the same material can tune from the older separated-pixel look to edge-to-edge reference-style pixels, and `Surface Checker Opacity` so the idle/unlit checkerboard can be faded without changing face count or bloom. Pixel Jets is the face-pixel jet path: it uses retained axial pixel textures on the long jet faces, selected VU-ramp colors, near-dark silent/no-provider materials, simple base/tip caps, and no autonomous time-phase pulse. Cell Jets is the separate coarse low-CPU path: one retained material per five-face cell, selected VU-ramp colors, a Cell Jets-only Idle Opacity control for silent cell visibility, a dark final end-capped cell until full-scale/clip, no SceneKit shader modifiers, no generated textures, no per-meter geometry rebuild, and no clock-driven pulse. The shared scalar path maps RMS to face-center bloom or jet intensity, maps peak/hot energy to hot fill, supports a material-only Rim Halo Edge highlight where relevant, and uses the selected Sonic Sphere speaker palette for panels, controls, fog, labels, VU ramp, hot fill, outline colors, jet colors, and the app skin. The separate `Source Speaker Palette` tray applies only to source-marker rendering in SceneKit and the canvas fallback while preserving source layout/project metadata. Both palette trays use full-width Orbisonic button rows, not native segmented pickers, and include the current family palette set from `orbisonic-palette-brief`. The `Bloom Style` tray exposes only Soft Center Bloom, Hot Core Bloom, Halo Edge Bloom, and Block Center Bloom as one-speaker-surface presets. Cube outlines are retained edge `SCNBox` child nodes whose material alpha is controlled by the Cube Outline slider; they apply to Cube VU, Pixel Jets, and Cell Jets without rebuilding the speaker body. Speaker labels are offset from the furthest visible speaker/meter extremity. Speaker height is not an active review-app control and old saved values are ignored for geometry/material keys. This does not change the production MetalKit renderer contract.

The `Sphere Geometry` tray owns the ribbed sphere overlay. It fits the active receiver speaker centers, including imported SpatGRIS layouts, from the speaker centroid and median speaker radius, then generates symmetrical evenly spaced longitude ribs and latitude rings. The `Geodesic Appearance` tray gives the ribbed sphere its independent palette and saturation styling. Geodesic saturation at `0%` converts both ribbed sphere color lanes to grayscale, while `100%` preserves the selected geodesic palette accent colors and leaves speaker/VU colors unchanged. The old imported/Fey shell is not user-visible, is not rendered by SceneKit or the canvas fallback, and its legacy JSON keys are ignored on load. The speaker palette still owns the app skin.

The `Label Font` tray controls only the SceneKit on-screen speaker-number typeface and size. It defaults to the current system font at the current visual size and groups choices as Normie, Nerd, and Nostromo. Normie contains System Default, Helvetica Black, and Futura; Nerd contains Press Start 2P, Minecraft, and Chintzy CPU BRK; Nostromo contains Archivo Black, Jost, Michroma, and Sevastopol Interface. Bundled fonts are registered offline through CoreText from SwiftPM resources. Older saved JSON values for City Light, Pump Demi, Eurostile Bold Extended, or Microgramma decode to System Default. Changing font or font size rebuilds only label text geometry, not shell or speaker body geometry.

The review app has four meter source modes. Music consumes the existing local audio/fake review meter source. Impulse Test Ripple keeps the original sphere-ripple pattern. Impulse Test Waves adds broad latitude/azimuth wave bands. Impulse Test Orbiting Comets uses exactly two larger moving comets with broader heads and longer hot VU trails so multiple speakers are active along each trail. The left-rail audio render type can also use a loaded audio file's mono RMS/peak sample as a cheap amplitude envelope for the ripple, waves, or comets patterns. Fog keeps the same 0...100 control but now has a lighter low/mid range and a denser maximum. The `Diagnostics` tray remains collapsed by default and exposes raw RMS, raw peak, calibrated RMS, display scalar, hot scalar, and diagnostic channel values when needed. The `Saved Themes` tray saves and loads visual state as app-bundle theme JSON files in `Contents/Resources/View Themes/`, gives new files unique two-word names, displays the current filename stem after manual renames, and stores default-theme metadata that resolves by stable `themeID` first. Theme load restores visual/camera/tuning/font/font-size/performance state, source speaker palette, and ribbed sphere visibility/settings, but does not restore local audio file state or selected speaker. The schema `9` JSON includes the right-panel tuning state plus `sourceSpeakerRenderStyle`, current ribbed sphere fields, and a `leftPanel` block for audio source, camera/orbit/zoom/spin, speaker type, speaker size/fog sliders, speaker numbers, hidden lines, and selected channel.

## Performance Model

Renderer constraints:

- Do not rebuild shell or speaker geometry for every meter update.
- Smooth visual envelopes on display refresh, not in audio callbacks.
- Treat display telemetry as latest-complete-frame-wins.
- Drop stale frames, decimate display refresh, and keep only the latest complete snapshot under load.
- Set overload diagnostics outside realtime paths.
- Never make audio wait for the viewport, allocate display queue from a callback, log from a callback, post UI from a callback, or feed raw packets directly into the renderer.
- Use instancing for repeated speakers, nodes, and struts when practical.
- Keep meter updates separate from structural scene updates.
- Keep draw-on-demand enabled by default for idle/static viewports.
- Use 30/60/120 FPS active-motion settings as viewport cadence hints without forcing meter-only or inspector UI refresh to match active-motion FPS.
- Keep object trails and glow trails capped by object count and per-object trail point settings.
- Use the visual telemetry stress gate for viewport no-backpressure evidence, not for host callback p99 or deadline claims.
- In the SceneKit review executable, preserve the adaptive loop: 120 FPS for active motion, 30 FPS for displayed meter updates, 10 FPS for the inspector, and no root SwiftUI animation timeline.

## Reliability Model

Validation should reject invalid scene data early:

- non-finite vectors
- invalid unit directions
- duplicate speaker IDs
- invalid physical channel identities
- invalid shell references
- non-origin monitor camera targets

## Known Risks

- MetalKit gives the needed long-term control but costs more implementation effort than a high-level 3D framework.
- DomeLab geometry import must use a neutral schema to avoid porting browser app internals.
- Downstream Wavefield adapter location depends on actual package visibility when implementation starts.
