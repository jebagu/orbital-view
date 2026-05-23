# Work Package: Realtime Audio Family Adoption For Orbital View Kit

Status: planning package for implementation  
Date: 2026-05-23  
Project: `OrbitalViewKit`  
Target repo: `/Users/jeremyguillory/Documents/vibecode projects/orbital-view-with-objects`  
Family standards package: `/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards`  
UI design-language reference: `/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language`  
OpenSpec reference: `openspec/README.md` and openspec.dev workflow

## Purpose

Adopt the Realtime Audio Family Standards as the governing architecture layer for Orbital View Kit without turning Orbital View Kit into an audio engine.

Orbital View Kit should remain a reusable native visual telemetry viewport:

```text
Host realtime app
  -> callback-safe tiny meter/object snapshots
  -> host preparation/control adapter
  -> OrbitalViewCore scene, speaker meters, object frames, object meters, settings
  -> OrbitalViewRender / OrbitalViewSwiftUI
  -> operator-facing viewport, diagnostics, camera and selection events
```

The kit must never own audible timing, route discovery, playback scheduling, output routing, OSC/MIDI parsing, file parsing, or realtime event queues. It consumes prepared state from Wavefield, Orbisonic, Splat, and future realtime-family apps.

## Source Of Truth

Read these Orbital View Kit files before implementation:

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

Read these family standards before implementation:

```text
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/README.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/PACKAGE-RULES.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/MIGRATION.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/docs/architecture/three-plane-realtime-audio-architecture.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/docs/architecture/reusable-system-architecture.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/docs/standards/realtime-audio-architecture-standard.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/docs/contracts/telemetry-metering-contract.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/docs/contracts/control-state-contract.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/docs/contracts/event-ingress-contract.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/docs/contracts/output-routing-contract.md
/Users/jeremyguillory/Documents/vibecode projects/All projects assets/realtime-audio-family-standards/docs/testing/realtime-performance-gates.md
```

Read these Orbisonic design-language files before UI work:

```text
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/AGENTS.md
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/README.md
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-ui-language.md
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-palette-brief.md
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/Orbisonic Design System Kit/design-system.md
```

Read these Wavefield realtime references before Wavefield connection work:

```text
/Users/jeremyguillory/Documents/vibecode projects/wavefield receiver realtime/wavefield-realtime-fork-work-package.md
/Users/jeremyguillory/Documents/vibecode projects/wavefield receiver realtime/WavefieldReceiverRealtime/AGENTS.md
```

## Plane Classification

Orbital View Kit fits primarily in the Control / UI / Telemetry Plane.

```text
Control / UI / Telemetry Plane
  OrbitalViewSwiftUI
  OrbitalViewRender
  OrbitalViewViewer and review-only surfaces
  camera and selection events
  diagnostics and display settings

Preparation Plane
  OrbitalViewCore validation
  OrbitalViewWavefield layout and meter adapters
  future host-specific snapshot adapters
  source-label and route-metadata validation

Realtime Plane
  none owned by Orbital View Kit
```

Orbital View Kit may receive prepared snapshots that originated from a realtime app, but it must not be callback-reachable. Host apps own their callback-safe queues, latest-value slots, immutable snapshots, meter extraction, output routing, and overload policy.

## OpenSpec Rule

Start using openspec.dev for behavioral and architecture changes from this package onward.

Use OpenSpec for:

- adopting the family standards;
- any public contract change;
- any host integration contract;
- telemetry source labels;
- meter/object snapshot semantics;
- Wavefield/Orbisonic/Splat integration behavior;
- review-surface separation if it changes public products;
- stress/performance acceptance gates.

Skip OpenSpec only for typo fixes, tiny copy-only edits, or implementation details that do not change behavior or architecture.

Each risky slice should create or update an OpenSpec change under:

```text
openspec/changes/<change-id>/
```

Expected files:

```text
proposal.md
design.md
tasks.md
specs/<capability>/spec.md
```

If the OpenSpec CLI is available, validate with the project-standard command before implementation. If the CLI is not installed, document that exact reason in `docs/status.md` and validate the files by review.

## Orbisonic Design Language Rule

Any UI or review-surface work must keep the Orbisonic design language as the visual guide.

Carry forward:

- fixed lab-bench control surface;
- always-on left operator rail for global controls only;
- right-side workspace/stage for primary work;
- persistent outlined top tab ribbon when the surface has tabs;
- compact, aligned technical panels;
- title-only panel headers;
- strict grids with matched peer heights and widths;
- no page-level scrollbars in active workflow tabs;
- debug and raw evidence collapsed into diagnostics trays;
- operator-facing primary UI that answers what is selected, what is happening, whether it is safe/ready, and what can be done next;
- tight radii around `8px` panels and `7px` controls;
- no root/global animation timeline for static chrome;
- Daft Punk Bow as the canonical rainbow VU palette and migration successor for old Tech Rainbow naming.

Do not copy Orbisonic product semantics blindly. Use the shell, layout, information hierarchy, component language, palette grammar, and meter visual treatment. Preserve Orbital View Kit's module contracts and host app ownership boundaries.

## Local Livestream Test Generator Rule

The Wavefield realtime fork owns the local livestream test generator. Orbital View Kit must treat it as a host input source, not a special audio path.

The generator should eventually feed the same canonical Wavefield live stream and preparation boundary as external streams. Orbital View Kit should be able to visualize prepared output from that generator through the same speaker/object snapshot contracts used for real external streams:

```text
local livestream test generator
  -> Wavefield realtime preparation boundary
  -> bounded host events and meter snapshots
  -> host-published Orbital View snapshots
  -> Orbital View viewport
```

Required implications for this package:

- source metadata can label frames as local generator, external stream, local audio review source, synthetic visual stress source, object bus, speaker bus, final output, or hardware tap;
- local generator frames use the same `SpeakerMeterFrame`, `ObjectMeterFrame`, and `OrbitalViewObjectFrameSet` path as other host frames;
- generator diagnostics never affect audio timing;
- generator-driven stress scenes may drop display frames without delaying audio;
- Orbital View must not parse raw livestream packets in production paths.

## Non-Negotiable Guardrails

- Do not add audio callbacks to Orbital View Kit.
- Do not make Orbital View Kit callback-reachable from host audio code.
- Do not parse raw OSC, MIDI, JSON streams, files, routes, or device state in callback-adjacent code.
- Do not own playback, render scheduling, route repair, downmixing, output fallback, or channel reordering.
- Do not silently fake production meter data.
- Do not let UI, rendering, diagnostics, PNG export, theme JSON, local audio review playback, or SceneKit tooling backpressure audio.
- Do not store or pass raw framework objects, parser handles, or owning heap pointers as callback-facing events.
- Do not claim realtime-family compliance until inheritance, profile, plane map, source labels, overload policy, OpenSpec coverage, and stress evidence are documented.
- Keep `OrbitalViewCore` independent of SwiftUI, AppKit, MetalKit, AVFoundation, MIDI, OSC, playback, and downstream app targets.
- Keep production `OrbitalViewSwiftUI` independent of AVFoundation and CoreMIDI.
- Keep review-only demo behavior visibly separated from production host integration.

## Target Connection Model

### Wavefield

Wavefield owns canonical live stream ingestion, the local livestream test generator, MIDI stream handling, object lifecycle, routing, realtime scheduling, meter extraction, and performance gates.

Orbital View Kit receives:

```text
OrbitalViewSceneSpec
SpeakerMeterFrame
OrbitalViewObjectFrameSet
ObjectMeterFrame
ObjectVisualSettings
OrbitalViewInputDiagnostics
source-of-truth metadata
```

Orbital View Kit emits:

```text
cameraChanged
selectionChanged
diagnostic UI state
```

It must not emit audio commands directly into Wavefield's realtime plane.

### Orbisonic

Orbisonic owns playback, Core Audio device I/O, routing, render/control engines, meter taps, and operator state.

Orbital View Kit receives prepared bus/object/speaker meter snapshots from explicit tap points. It should use Orbisonic design language for any embedded or review UI, especially Daft Punk Bow and the compact lab-bench workbench grammar.

### Splat

Splat may use Orbital View Kit for virtual speaker/source layout authoring, renderer-kernel overlays, and neutral geometry review. Splat edit actions must remain preparation/control-plane behavior until a host applies a prepared snapshot.

Orbital View Kit must not store permanent flattened screen coordinates as canonical spatial state.

## Required Completion Phrase

At the end of each implementation slice, the agent must include this exact handoff sentence with the correct slice number:

```text
Slice N complete. I'm ready to do the next slice.
```

Each slice below ends with the required handoff sentence for that slice.

## Slice 1: Adopt Family Standard In Project Docs

Goal: formally declare that Orbital View Kit inherits the Realtime Audio Family Standards while preserving its non-audio-engine role.

Tasks:

- Add an ADR under `docs/decisions/` stating that Orbital View Kit inherits the family standards.
- Add the required family-standard inheritance language near the top of audio-adjacent docs.
- Update `docs/architecture.md`, `docs/contracts.md`, `docs/protected-paths.md`, `docs/system-flows.md`, and `docs/status.md` to state that Orbital View Kit is Control / UI / Telemetry Plane plus Preparation Plane adapters, with no owned realtime plane.
- Keep the existing product constraint that Orbital View Kit visualizes measured levels only.
- Do not copy the entire standards package into the repo unless explicitly approved; reference the shared package path for now.

Tests/checks:

- `rg -n "Realtime Audio Family Standards|Bencina|callback" docs AGENTS.md`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`

Acceptance:

- Project docs clearly inherit the family standard.
- No source or public API changes are required.
- No claim of full realtime compliance is made yet.

Slice 1 complete. I'm ready to do the next slice.

## Slice 2: Activate OpenSpec For The Adoption

Goal: create the OpenSpec change package that governs this adoption before behavior-changing implementation begins.

Tasks:

- Create an OpenSpec change such as `openspec/changes/adopt-realtime-family-standards/`.
- Write `proposal.md`, `design.md`, and `tasks.md`.
- Add spec deltas for at least:
  - `orbital-view-realtime-boundary`;
  - `orbital-view-telemetry-ingress`;
  - `orbital-view-host-integration`;
  - `orbital-view-review-surface`.
- Each spec must answer whether the change touches realtime, routing, meter source-of-truth, callback reachability, overload policy, and performance gates.
- Add a note that this project uses openspec.dev workflow for future audio-facing and architecture-facing changes.

Tests/checks:

- If available: OpenSpec CLI validation for the new change.
- If unavailable: static review of proposal/design/tasks/spec files plus a status note explaining that the CLI was unavailable.
- `rg -n "openspec.dev|adopt-realtime-family-standards|realtime-boundary" openspec docs`

Acceptance:

- Future slices have a concrete OpenSpec change to implement against.
- The OpenSpec layer does not replace docs, tasks, or work packages; it controls behavioral intent.

Slice 2 complete. I'm ready to do the next slice.

## Slice 3: Add Project Profile And Plane Map

Goal: create the family-standard project profile and callback inventory for Orbital View Kit.

Tasks:

- Add `docs/project/profile.md`.
- Include:
  - product name;
  - app type: reusable visual telemetry module;
  - backend choice: MetalKit renderer with SwiftUI wrapper;
  - plugin/standalone target: library plus review executable;
  - supported sample rates: not owned by this kit;
  - block-size assumptions: not owned by this kit;
  - channel/routing model: host-owned, explicit physical channel identity preserved;
  - event sources: host prepared snapshots only;
  - control sources: SwiftUI bindings and host state only;
  - telemetry outputs: lossy visual frames and diagnostics;
  - stress scenes: display-only no-backpressure scenes;
  - inherited standard revision.
- Add a callback inventory stating Orbital View Kit owns no callback entry points.
- Add a callback-adjacent warning: host apps must not call this kit from audio callbacks.

Tests/checks:

- `rg -n "callback entry|Realtime Plane|Control / UI / Telemetry|Preparation Plane" docs/project docs`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`

Acceptance:

- A future reviewer can classify every target without reading the source.
- The profile explicitly says production `OrbitalViewSwiftUI` and `OrbitalViewRender` are not callback-safe APIs.

Slice 3 complete. I'm ready to do the next slice.

## Slice 4: Separate Review-Only Audio And File Behavior

Goal: restore a clean production wrapper boundary by moving review-only playback/file/theme/export behavior out of the production SwiftUI target.

Tasks:

- Create or plan a separate review/demo target for `OrbitalViewportMockup` and its SceneKit/local-audio surface.
- Move `AVFoundation`, local audio playback, file dialogs, PNG export, theme JSON persistence, SceneKit review tooling, and AppKit-heavy label generation out of the production `OrbitalViewSwiftUI` target unless a specific item is proven necessary for production.
- Keep production `OrbitalViewSwiftUI` focused on `OrbitalView`, `OrbitalViewMetalView`, host bindings, MetalKit bridge, and optional production-safe tuning controls.
- Preserve the current review app behavior and tests during the move.
- Update `Package.swift`, contracts, implementation map, test strategy, protected paths, and status.

Tests/checks:

- `rg -n "AVFoundation|SceneKit|NSOpenPanel|AVAudioPlayer|FileManager|PNG|theme" Sources/OrbitalViewSwiftUI`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`
- Launch review executable if this slice changes it.

Acceptance:

- Production `OrbitalViewSwiftUI` does not import `AVFoundation`.
- Review-only behavior remains available but is clearly marked as review/demo tooling.
- Production host apps can import the wrapper without inheriting local playback or file-export responsibilities.

Slice 4 complete. I'm ready to do the next slice.

## Slice 5: Define Telemetry Source Labels And Overload Policy

Goal: make meter/source provenance and lossy-display behavior explicit.

Tasks:

- Add a source descriptor contract for speaker meters and object meters.
- Support source labels such as:
  - speaker bus;
  - object bus;
  - final output;
  - hardware tap;
  - local livestream test generator;
  - external Wavefield stream;
  - Orbisonic prepared meter tap;
  - Splat prepared analysis;
  - review local audio;
  - synthetic visual stress.
- Document that display telemetry is latest-complete-frame-wins.
- Document allowed overload behavior:
  - drop stale frames;
  - decimate display refresh;
  - keep latest complete snapshot;
  - set diagnostics flags outside realtime.
- Document forbidden overload behavior:
  - audio waits for viewport;
  - callback allocates more display queue;
  - callback logs or posts UI;
  - raw packets enter renderer.
- Add tests for source-label validation and diagnostics.

Tests/checks:

- Targeted unit tests for source descriptor defaults and validation.
- Existing renderer invariant tests.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`

Acceptance:

- Every displayed meter frame can identify its source of truth.
- Orbital View Kit explicitly allows display drops without affecting audio.
- The host integration contract tells Wavefield, Orbisonic, and Splat what metadata to provide.

Slice 5 complete. I'm ready to do the next slice.

## Slice 6: Specify Wavefield Realtime Connection Including Local Livestream Generator

Goal: define exactly how Wavefield realtime output feeds Orbital View Kit, including the local livestream test generator.

Tasks:

- Add a Wavefield realtime integration spec or doc section.
- State that Wavefield owns:
  - external live stream parsing;
  - local livestream test generator;
  - local MIDI streams;
  - realtime event queues;
  - object lifecycle;
  - sample-time scheduling;
  - audio rendering;
  - route validation;
  - meter extraction;
  - performance gates.
- State that Orbital View Kit receives only prepared scene, speaker meter, object frame, object meter, diagnostics, and source metadata snapshots.
- Add mapping guidance:
  - Wavefield object ID remains source-object identity;
  - speaker channel remains physical speaker identity;
  - generator profile names are source metadata, not audio path branches;
  - object disappear removes active draw ownership in the prepared snapshot;
  - missing/stale display frames may be dropped.
- Include generator profile examples from the realtime fork as test/stress inputs: smoke, moving pose, sustained moving object, burst/reorder, 16-object stress, 32-object should-pass stress.

Tests/checks:

- No direct dependency on Wavefield package targets unless a future explicit integration slice allows it.
- Adapter tests preserve channel and object identity.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`

Acceptance:

- The local livestream test generator is treated as a normal host-prepared source.
- Orbital View Kit does not parse livestream packets or own generator timing.
- Wavefield realtime work can target this contract without ambiguity.

Slice 6 complete. I'm ready to do the next slice.

## Slice 7: Align UI And Review Surfaces With Orbisonic Design Language

Goal: make future Orbital View UI work consistent with the Orbisonic-family design system.

Tasks:

- Add a design-language reference section to Orbital View docs.
- Point future UI tasks to:
  - `/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-ui-language.md`;
  - `/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-palette-brief.md`;
  - `/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/Orbisonic Design System Kit/design-system.md`.
- Preserve the current Orbisonic palette names and Daft Punk Bow behavior already present in the kit.
- Add review criteria:
  - strict grid alignment;
  - no page-level active-workflow scrolling;
  - title-only panel headers;
  - compact status primary UI;
  - diagnostics for raw evidence;
  - no global animation timeline for static shell chrome.
- When changing the review executable, verify the visible surface against the design-language file rather than inventing one-off layout rules.

Tests/checks:

- Existing SwiftUI/review-surface tests.
- Add static tests for design-language constants only if they become source-level contracts.
- Manual visual review when UI changes are made.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`

Acceptance:

- Orbital View UI and review surfaces follow the Orbisonic family design language.
- Design language is a guideline for shell/layout/palette/information hierarchy, not an excuse to import Orbisonic product semantics.

Slice 7 complete. I'm ready to do the next slice.

## Slice 8: Specify Orbisonic And Splat Host Integration Profiles

Goal: define how Orbisonic and Splat should connect without changing their downstream apps yet.

Tasks:

- Add host integration profiles for Orbisonic and Splat.
- Orbisonic profile:
  - receives prepared bus/object/speaker meter snapshots;
  - labels explicit tap points;
  - preserves routing ownership in Orbisonic;
  - keeps Orbisonic design-language defaults and palette grammar.
- Splat profile:
  - uses Orbital View for virtual speakers, source objects, and renderer-kernel overlays;
  - treats edit/export as preparation/control behavior;
  - avoids permanent screen-coordinate storage;
  - keeps neutral geometry import/export separate from browser/DomeLab runtime code.
- Document that direct downstream source edits require separate protected-path permission and host repo inspection.

Tests/checks:

- Documentation review only unless code contracts change.
- If code contracts change, run full Swift build/test.
- `rg -n "Orbisonic|Splat|host integration|tap point|screen coordinates" docs work-packages`

Acceptance:

- Future Orbisonic/Splat work has a clear connection model.
- No downstream repo is edited in this slice.

Slice 8 complete. I'm ready to do the next slice.

## Slice 9: Add Visual Telemetry Stress Scene And Gates

Goal: prove Orbital View can absorb realistic display/update pressure without implying audio callback compliance.

Tasks:

- Define a visual telemetry stress scene:
  - 30 physical speakers;
  - 128 source objects max;
  - object trails capped;
  - 60 FPS active motion;
  - diagnostics open;
  - meter frames arriving faster than display cadence;
  - local livestream generator source metadata included;
  - stale display frames dropped.
- Add tests or harnesses that prove:
  - meter-only updates do not rebuild static speaker geometry;
  - object meter updates do not rebuild speaker geometry;
  - retained buffer capacity does not grow for meter/camera/settings-only updates;
  - diagnostics log is capped;
  - display update drops are visible as diagnostics but never represented as audio failure.
- Add docs separating host callback p99/deadline gates from Orbital View UI/render no-backpressure gates.

Tests/checks:

- Existing renderer retained-buffer tests.
- New stress/harness tests where practical.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`
- Manual review app check if stress scene is visible.

Acceptance:

- Orbital View Kit can present a family-standard no-backpressure story for telemetry.
- It does not claim audio callback p99 compliance because it owns no callback.

Slice 9 complete. I'm ready to do the next slice.

## Slice 10: Final Compliance Audit And Documentation Refresh

Goal: close the adoption package with a clear current-state audit and remaining risks.

Tasks:

- Update `docs/status.md` with the completed adoption status.
- Update `docs/implementation-map.md`, `docs/system-flows.md`, `docs/contracts.md`, `docs/test-strategy.md`, and `docs/protected-paths.md` where relevant.
- Update `docs/bugs.md` only if this work discovers a bug.
- Add a final compliance section that states:
  - which standards are inherited;
  - which targets live in which plane;
  - no callback entry points are owned;
  - review-only code is separated or explicitly marked;
  - OpenSpec is active for future audio-facing changes;
  - Wavefield local livestream generator is a host source, not an Orbital View special path;
  - Orbisonic design language is the UI guideline.
- Run full verification.

Tests/checks:

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`
- OpenSpec validation if available.
- `git diff --check`

Acceptance:

- The repo can honestly say Orbital View Kit has adopted the family standards as a visual telemetry/preparation package.
- Any remaining noncompliance is listed as an explicit risk, not hidden in prose.
- The next implementation package can begin from a stable standard-compliant baseline.

Slice 10 complete. I'm ready to do the next slice.

## Current Risks

- The current checkout has review-only SceneKit/local-audio behavior compiled inside `OrbitalViewSwiftUI`; Slice 4 should separate or harden that boundary.
- OpenSpec exists only as a lightweight layer in this repo today; Slice 2 must install real change content before risky implementation starts.
- The local livestream test generator belongs to Wavefield realtime. Orbital View Kit should not accidentally absorb generator semantics or timing ownership.
- The family standards package is currently referenced from shared project assets, not copied into this repo. That is acceptable for planning but must be made explicit in docs.
- The repo already has unrelated dirty worktree changes. Future implementation slices must preserve user changes and avoid broad cleanup.

## Recommended Next Task

Start with Slice 1, then Slice 2. The adoption docs should come before any source movement or public contract changes so the OpenSpec and family-standard boundaries are visible to future workers.
