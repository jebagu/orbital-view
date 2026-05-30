# Product Brief

## Project Name

Orbital View

## One-Sentence Description

The canonical head project for a reusable, native 3D spherical speaker viewport for monitoring and authoring spatial speaker arrays across Wavefield, Orbisonic, and Splat.

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
- Native `OrbitalViewRender` MetalKit renderer with an offscreen-tested instanced cube/prism speaker draw path.
- Renderer invariant tests for stable static draw inputs under meter, cube setting, camera, and object-meter updates.
- `OrbitalViewSwiftUI` wrapper with opt-in collapsible Cube VU, object overlay, trails, bounds, performance, presets, and diagnostics tuning trays.
- Disposable browser mockup for toolbar and camera interaction.

## Nice-To-Have Later

- Shell, label, hit-testing, and full production camera visuals.
- SwiftUI controls, gestures, toolbar, and inspector UI.
- DomeLab neutral geometry import.
- Splat editing mode and renderer-kernel overlays.
- Snapshot export.

## Out Of Scope For Current Package

- Shell/label/hit-testing renderer visuals.
- Downstream app integration.
- WebView embedding.
- DomeLab code import.
- Audio playback, routing, MIDI, OSC, or render-pipeline behavior.
- GitHub remote setup.

## First Usable Version

The first usable implementation already:

- Build and test a pure Swift `OrbitalViewCore` package target.
- Represent a scene with coordinate system, shell geometry, 30 physical speakers, meter levels by channel, and center-locked camera presets.
- Adapt the existing Fey 30 Wavefield layout into stable `OrbitalViewSpeaker` values without channel reorder.
- Render deterministic offscreen Metal frames with one cube/prism speaker mesh per physical speaker and display-only cube VU material updates.

## Constraints

- Tech stack: Swift package first; current renderer is native MetalKit with a compile-only SwiftUI wrapper skeleton.
- App type: reusable module consumed by local native apps.
- Audio domain: visualizes measured levels only; does not own audio timing or routing.
- Persistence: none in `OrbitalViewCore`.
- External services: none.
- Security/privacy: no network requirement.
- Performance: renderer updates must eventually avoid heavy geometry rebuilds for meter changes.
- Reliability: validation errors must be explicit and testable.

## Assumptions

- Wavefield coordinates use canonical Z-up semantics: `x = right`, `y = front`, `z = up`.
- Physical speaker channels are 1-based and must not be reordered.
- DomeLab is a reference and future geometry-export source, not a dependency.
- `OrbitalViewCore` should stay portable and independent of downstream app targets.

## Project Identity

`Orbital View` is the active head project name for version `1.0`.

The Swift package and target symbols intentionally keep the `OrbitalView*` prefix for source compatibility. Historical labels such as `Orbital View Kit`, `Orbital View VU Kit`, `Orbital View Turbo`, and `orbital-view-with-objects` are non-head variation labels and should not be used as the current product name.
