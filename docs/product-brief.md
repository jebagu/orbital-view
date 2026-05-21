# Product Brief

## Project Name

Orbital View VU Kit

## One-Sentence Description

A reusable, native 3D spherical speaker viewport for monitoring and authoring spatial speaker arrays across Wavefield, Orbisonic, and Splat.

## Problem

Wavefield needs a real spherical Sonic Sphere monitor view, not a flat VU chart or fake placeholder. Orbisonic and Splat will need related visualizations, so the foundation should be reusable instead of tied to one app tab.

## Target Users

- Sonic Sphere operators monitoring live speaker activity.
- Wavefield and Orbisonic users inspecting spatial output.
- Splat users authoring renderer kernels and virtual speaker/source layouts.
- Developers integrating a shared viewport into native Swift apps.

## Primary Use Cases

1. Visualize a physical Sonic Sphere shell with 30 ordered speakers.
2. Show live per-speaker RMS, peak, and clip activity through material/glow/ring intensity without resizing speaker geometry.
3. Orbit, zoom, and switch camera presets while keeping the sphere centered.
4. Later, overlay virtual speakers, source objects, and renderer-kernel gain paths for Splat.

## Must-Have Features For First Code Slice

- Pure `OrbitalViewCore` target.
- Data contracts for scene, coordinate system, shell, speakers, meters, camera, selection, and validation.
- Center-locked camera presets.
- Imported shell reference validation.
- Speaker validation that preserves channel identity and rejects invalid dimensions or IDs.
- Meter frame representation by physical channel.
- Tests for the core validation and identity rules.

## Implemented Foundation

- Pure `OrbitalViewCore` data and validation target.
- Local `OrbitalViewWavefield` JSON layout and meter-frame adapters.
- Local `OrbitalViewOrbisonic` adapter skeleton for Orbisonic renderer/output monitor speaker and meter records.
- Native `OrbitalViewRender` MetalKit seam with an offscreen-tested instanced cube/prism speaker draw path.
- Renderer invariant tests for stable static draw inputs under meter and camera updates.
- Display-only VU visual settings for gain, checker pulse/ring/diagonal wave style, color scheme, and 30-channel renderer meter mapping.
- Sonic Sphere speaker shape contracts for cube defaults, fixed rectangular-prism z scale from one to two cubes, and face-center VU bloom distance.
- Platform-neutral theme tokens and Daft Punk Bow as the first-class rainbow VU palette, with legacy `Tech Rainbow` settings migrating to Daft Punk Bow.
- Music-mode cube scalar center-bloom defaults, validated bloom/response/peak-hold/release/hot-fill/face-pixel settings, diagnostics visibility, and legacy checker/ripple style migration.
- Runtime-safe speaker meter sanitizing that replaces non-finite input, clamps finite host levels, and reports missing/extra/invalid/duplicate channel diagnostics.
- Codable visual presets plus a persistence protocol contract, while keeping concrete storage out of `OrbitalViewCore`.
- Renderer static cache plan and invariant tests for static speaker geometry keys, channel-to-instance mapping, cube/prism shape invalidation, and retained speaker buffer reuse.
- Metal cube/prism center-bloom prototype that maps RMS to center fill/body glow, peak to halo/ring intensity, clip to hot flash, and Daft Punk Bow to retained ramp uniforms without resizing speaker geometry.
- Host source-object frames, object meters keyed by `objectId`, capped trails/glow-trail settings, and `-5...+5` render/effect bounds.
- `OrbitalViewSwiftUI` wrapper with an opt-in collapsed VU settings tray, optional preset store actions, speaker height control, diagnostics display, and a dedicated graphical performance versus CPU load settings section.
- Standalone `OrbitalViewViewer` SwiftPM executable that opens `Orbital View VU Kit.app`, a native SwiftUI/SceneKit 3D review surface with Orbisonic-design-language controls, inspector, footer, Fey 30 shell/speakers, fake meter stream, and local launcher.
- Runtime-safe Wavefield meter adapter plus a guarded Wavefield app Orbital View tab that joins cached Fey speaker geometry to `PlayerSnapshot.meterSummary.multichannelLevels` by physical channel while preserving the existing Spherical VU tab.
- Runtime-safe Orbisonic host adapter skeleton that defines `Orbisonic renderer/output monitor -> 30 channel VU records -> SpeakerMeterFrame -> OrbitalView` without importing the Orbisonic app.
- Disposable browser mockup for toolbar and camera interaction.

## Nice-To-Have Later

- Shell/strut rendering and full production MetalKit visual polish.
- Production checker facet animation/materials.
- Production SwiftUI gestures, toolbar, hit testing, and inspector UI beyond the current VU settings tray and standalone native review app.
- DomeLab neutral geometry import.
- Splat editing mode and renderer-kernel overlays.
- Production snapshot export.

## Out Of Scope For Current Package

- Full downstream production renderer integration.
- Additional downstream app integration beyond the current Wavefield tab and Orbisonic contract skeleton.
- WebView embedding.
- DomeLab code import.
- Audio playback, routing, MIDI, OSC, or render-pipeline behavior.
- GitHub remote setup.

## First Usable Version

The first usable implementation already:

- Build and test a pure Swift `OrbitalViewCore` package target.
- Represent a scene with coordinate system, shell geometry, 30 physical speakers, meter levels by channel, and center-locked camera presets.
- Adapt the existing Fey 30 Wavefield layout into stable `OrbitalViewSpeaker` values without channel reorder.
- Render an offscreen Metal frame for deterministic renderer smoke and center-bloom pixel-probe coverage.
- Apply display-only cube scalar center-bloom material settings to renderer speaker meshes without changing speaker geometry, while keeping checker pulse/ring/diagonal wave as a legacy/impulse-test style.
- Keep Sonic Sphere speaker geometry fixed as cube/prism scene shape data while VU settings expose only validated display z scale.
- Accept active source-object frames and object meter frames separately from speaker scene and speaker meter state.
- Launch a standalone native 3D SwiftUI/SceneKit viewer from the package without opening a downstream host app.

## Constraints

- Tech stack: Swift package first; current production renderer is native MetalKit with a SwiftUI wrapper and optional VU settings tray. The standalone native review app uses SceneKit for native 3D review only and Orbisonic design language for controls.
- App type: reusable module consumed by local native apps.
- Audio domain: visualizes measured levels only; does not own audio timing or routing.
- Persistence: none in `OrbitalViewCore`.
- External services: none.
- Security/privacy: no network requirement.
- Performance: renderer updates must avoid heavy geometry rebuilds for meter, object meter, and object trail changes.
- Reliability: validation errors must be explicit and testable, and host-facing unsafe meter input should be sanitized before it reaches strict frame constructors.

## Assumptions

- Wavefield coordinates use `x = right`, `y = up`, `z = front`.
- Orbisonic monitor coordinates use the same `x = right`, `y = up`, `z = front` basis for the current adapter skeleton.
- Physical speaker channels are 1-based and must not be reordered.
- Wavefield presents the shared `Daft Punk Bow` color scheme in its host-level color-scheme options; the Orbisonic contract exposes the same shared color scheme through `OrbisonicOrbitalColorScheme.daftPunkBow`.
- Source-object IDs are 1-based, valid in `1...128`, and separate from physical speaker channels.
- DomeLab is a reference and future geometry-export source, not a dependency.
- `OrbitalViewCore` should stay portable and independent of downstream app targets.
