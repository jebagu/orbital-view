# Architecture

## Overview

Orbital View Kit will become a layered Swift module family for spherical speaker visualization. The first layer is `OrbitalViewCore`, a pure data and validation target. Rendering, SwiftUI wrapping, and downstream app adapters are future layers.

## Planned Module Layers

```text
OrbitalViewCore
  Pure data contracts, validation, coordinate system, shell/speaker/meter/camera types.

OrbitalViewRender
  MetalKit / MTKView renderer seam with an initial offscreen smoke-tested draw path.

OrbitalViewSwiftUI
  Compile-only SwiftUI wrapper skeleton for host apps.

OrbitalViewDomeLab
  Optional neutral shell geometry import/export bridge.

OrbitalViewSplat
  Optional Splat editor overlays for virtual speakers, source objects, and renderer kernels.

OrbitalViewWavefield
  Local Wavefield speaker-layout JSON and meter-frame adapters into OrbitalViewCore.
```

`OrbitalViewCore`, `OrbitalViewWavefield`, `OrbitalViewRender`, and `OrbitalViewSwiftUI` are implemented. `OrbitalViewRender` now has an instanced Metal cube/prism speaker draw path verified by offscreen smoke tests, pixel probes, retained-buffer checks, object overlay tests, and invariant tests for static draw inputs. Broad SwiftUI gestures, hit testing, shell/label visuals, and downstream app source integration remain deferred.

## Runtime Architecture

Current package:

```text
OrbitalViewCore tests and validates core scene contracts.
OrbitalViewWavefield converts Wavefield speaker-layout JSON into OrbitalViewCore scenes.
OrbitalViewWavefield converts Wavefield-style channel/rms/peak meter records into SpeakerMeterFrame.
OrbitalViewRender stores scene, speaker meters, cube VU settings, dynamic object frames, object meters, object visual settings, camera, and selection state behind a MetalKit renderer seam. Internal draw-input snapshots separate static speaker geometry from display-only speaker material inputs and object overlay inputs for invariant testing.
OrbitalViewSwiftUI wraps the renderer seam in an NSViewRepresentable MTKView bridge and can opt into native collapsible tuning trays for Orbisonic theme selection, Cube VU speaker settings, object overlays, trails, fixed object bounds, presets, performance-versus-CPU controls, and diagnostics.
```

Future runtime shape:

```text
Host app
  -> app-owned layout, meter, selection, and camera state
  -> OrbitalViewSwiftUI
  -> OrbitalViewRender
  -> OrbitalViewCore contracts
```

The viewport receives scene and meter state from the host app. It does not parse files, schedule playback, receive OSC, parse MIDI, or decide output routing.

## Renderer Backend Decision

Production rendering uses the custom MetalKit / MTKView direction in `OrbitalViewRender`, wrapped by `OrbitalViewSwiftUI` for host-app binding.

Current renderer drawing maps scene speaker anchors to one stable instanced cube/prism mesh per speaker. Meter values are looked up by physical channel and converted into display-only cube VU material scalars; shell geometry, labels, hit testing, production camera projection, and broader visual polish remain deferred.

Long-term renderer source should not be SceneKit-first, RealityKit-first, WebView-based, or DomeLab-code-based. SceneKit or HTML mockups may be used only as disposable prototypes if a future task explicitly allows that scope.

## Audio Architecture

Orbital View Kit does not own audio behavior.

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

## UI Architecture

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
- scene specs
- meter frames by channel
- camera state
- selection and events

Persistence is out of scope for core.

## Module Boundaries

Core rules:

- `OrbitalViewCore` has no dependency on SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, or downstream app targets.
- `OrbitalViewWavefield` depends only on Foundation and `OrbitalViewCore`; it must not depend on Wavefield package targets unless a future task explicitly changes that boundary.
- `OrbitalViewRender` may depend on Metal and MetalKit; it must not depend on SwiftUI, AVFoundation, CoreMIDI, or downstream app targets.
- `OrbitalViewSwiftUI` may depend on SwiftUI, MetalKit, `OrbitalViewCore`, and `OrbitalViewRender`; it must not depend on AVFoundation, CoreMIDI, or downstream app targets.
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

Future production rendering may use Apple-native rendering frameworks. A major third-party dependency requires an explicit task decision.

The accepted production rendering framework is MetalKit.

The current native review executable is a deliberately separate visual-review surface: `OrbitalViewViewer` hosts the confirmed VU Kit SceneKit geodesic `OrbitalViewportMockup` so the approved viewport controls, shell, tuning panel, PNG export, and adaptive SceneKit interaction can be tuned before downstream integration. This review app must not be confused with the rejected bare MTKView demo surface. Production host integration remains through the MetalKit renderer seam unless a later task explicitly changes that decision.

In the SceneKit review executable, the left rail is limited to song audio source, camera, and view detail controls. The song audio source uses side-by-side transport icon buttons for Play and Pause plus a `Render Type` selector: All Mono, Excite Ripple, Excite Waves, and Excite Comets. The right panel is sectioned into `Theme`, `Speaker Appearance`, `Sphere Appearance`, `Meter Behavior`, and `Diagnostics`. `Theme` contains `Saved Themes`; `Speaker Appearance` contains `Speaker Shape`, `Speaker Pattern`, `Label Font`, `Color Palette`, `Cube Surface`, and `Bloom Style`; `Sphere Appearance` contains `Sphere Geometry` and `Geodesic Appearance`; `Meter Behavior` contains `Meter Source`, `Meter Response`, and `Performance`; `Diagnostics` contains the `Diagnostics` tray. `Sphere Geometry` and `Speaker Pattern` are empty future-work placeholders for now. `Cube Surface`, `Bloom Style`, and `Meter Response` each include a local dice-icon randomizer. Source-object overlay/trail controls are hidden in this review surface until the Wavefield object work resumes.

The review app startup defaults are pinned to the exported tuning payload `Orbital View VU Kit Settings 2026-05-21-171537.json`: Purple speaker/app palette, Purple geodesic palette, Cube VU speaker type, Hot Core Bloom preset, Impulse Test Ripple drive, grayscale geodesic saturation, 86% pixel fill, muted idle checker opacity, cube outline strength `0.64`, and 60 fps active motion.

The SceneKit review app's Cube VU speaker type uses the shared Core cube scalar contract but implements the visible face skin locally with a retained SceneKit material. The material uses a retained 9x9 pixelated face texture cache applied directly to the actual six `SCNBox` cube faces and a Cube-VU-only readable face scale so the face grid is visible at small speaker sizes. The `Cube Surface` tray exposes `Pixel Fill` so the same material can tune from the older separated-pixel look to edge-to-edge reference-style pixels, and `Surface Checker Opacity` so the idle/unlit checkerboard can be faded without changing face count or bloom. It maps RMS to face-center bloom, maps peak/hot energy to hot fill, supports a material-only Rim Halo Edge highlight, and uses the selected speaker color palette for panels, controls, fog, labels, cube VU ramp, hot fill, outline colors, and the app skin. The `Bloom Style` tray exposes only Soft Center Bloom, Hot Core Bloom, Halo Edge Bloom, and Block Center Bloom as one-speaker-surface presets. The `Color Palette` tray uses full-width Orbisonic button rows, not a native segmented picker, and includes the current family palette set from `orbisonic-palette-brief`. Cube outlines are retained edge `SCNBox` child nodes whose material alpha is controlled by the Cube Outline slider; changing outline strength does not rebuild the speaker body. Speaker height is not an active review-app control and old saved values are ignored for geometry/material keys. This does not change the production MetalKit renderer contract.

The `Geodesic Appearance` tray gives the shell its own independent palette and saturation. Geodesic saturation at `0%` converts shell struts/nodes to grayscale, while `100%` preserves the selected geodesic palette color and leaves speaker/VU colors unchanged. The speaker palette still owns the app skin.

The `Label Font` tray controls only the SceneKit on-screen speaker-number typeface and size. It defaults to the current system font at the current visual size and groups choices as Normie, Nerd, and Nostromo. Normie contains System Default, Helvetica Black, and Futura; Nerd contains Press Start 2P, Minecraft, and Chintzy CPU BRK; Nostromo contains Archivo Black, Jost, Michroma, and Sevastopol Interface. Bundled fonts are registered offline through CoreText from SwiftPM resources. Older saved JSON values for City Light, Pump Demi, Eurostile Bold Extended, or Microgramma decode to System Default. Changing font or font size rebuilds only label text geometry, not shell or speaker body geometry.

The review app has four meter source modes. Music consumes the existing local audio/fake review meter source. Impulse Test Ripple keeps the original sphere-ripple pattern. Impulse Test Waves adds broad latitude/azimuth wave bands. Impulse Test Orbiting Comets uses exactly two larger moving comets with broader heads and longer hot VU trails so multiple speakers are active along each trail. The left-rail audio render type can also use a loaded audio file's mono RMS/peak sample as a cheap amplitude envelope for the ripple, waves, or comets patterns. Fog keeps the same 0...100 control but now has a lighter low/mid range and a denser maximum. The `Diagnostics` tray remains collapsed by default and exposes raw RMS, raw peak, calibrated RMS, display scalar, hot scalar, and diagnostic channel values when needed. The `Saved Themes` tray saves and loads visual state as app-bundle theme JSON files in `Contents/Resources/View Themes/`, gives new files unique two-word names, displays the current filename stem after manual renames, and stores default-theme metadata that resolves by stable `themeID` first. Theme load restores visual/camera/tuning/font/font-size/performance state but does not restore local audio file state or selected speaker. The JSON includes the right-panel tuning state plus a `leftPanel` block for audio source, camera/orbit/zoom/spin, speaker type, speaker size/fog sliders, speaker numbers, hidden lines, and selected channel.

## Performance Model

Renderer constraints:

- Do not rebuild shell or speaker geometry for every meter update.
- Smooth visual envelopes on display refresh, not in audio callbacks.
- Use instancing for repeated speakers, nodes, and struts when practical.
- Keep meter updates separate from structural scene updates.
- Keep draw-on-demand enabled by default for idle/static viewports.
- Use 30/60 FPS active-motion settings as viewport cadence hints without forcing meter-only or inspector UI refresh to match active-motion FPS.
- Keep object trails and glow trails capped by object count and per-object trail point settings.
- In the SceneKit review executable, preserve the adaptive loop: 60 FPS only for active motion, 10 FPS for idle fake meter-only updates, 10 FPS for the inspector, and no root SwiftUI animation timeline.

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
