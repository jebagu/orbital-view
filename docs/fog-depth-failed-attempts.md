# Fog Depth Failed Attempts

Status: current visual failure analysis

## Problem

Fog still does not visibly affect the Ribbed Speaker Sphere geometry in the native SceneKit review app. Speakers, source markers, and labels respond to fog enough to make the mismatch more obvious, but the sphere structure still reads flat or unchanged.

The goal remains:

```text
Fog should create a convincing depth gradient across the whole scene: speakers,
source markers, labels, glows, and the visible sphere structure.
```

## Failed Attempts

### 1. SceneKit Global Fog Retuning

What changed:

- Increased SceneKit fog strength through start distance, end distance, and exponent tuning.
- Made maximum Fog Density produce a heavier atmospheric veil.

What happened:

- The scene atmosphere changed.
- The sphere structure did not gain convincing internal depth.

Why it failed:

- SceneKit global fog was not enough to make thin, opaque, constant-material rib geometry read as depth-graded structure.
- It mostly changed the whole viewport feel, not the visible near/mid/far contrast inside the sphere.

Do not repeat:

- Do not keep retuning only `scene.fogStartDistance`, `scene.fogEndDistance`, or `scene.fogDensityExponent` as the primary fix.

### 2. Strong Fog On Speakers, Sources, And Labels

What changed:

- Added depth-based alpha, color wash, emission reduction, and label opacity changes.
- Added fog-aware speaker and source material update keys so slider changes refreshed these materials.

What happened:

- Speakers, source markers, and labels reacted visibly.
- The sphere geometry mismatch became clearer because the ribs still did not respond with comparable depth.

Why it failed:

- It improved the wrong parts first. The primary complaint is the sphere structure.
- Fog must be unified across scene primitives; otherwise responsive speakers make an unresponsive shell look flatter.

Do not repeat:

- Do not treat stronger speaker/label fog as a proxy for fixing sphere depth.

### 3. Hidden-Line And Rear-Fade Tuning

What changed:

- Made rear and hidden rib alpha respond more aggressively to fog.
- Reused the existing Hidden Lines depth rules.

What happened:

- Mostly affected hidden/rear lines.
- With Hidden Lines off, rear sphere geometry is intentionally clipped by the invisible cutaway plane, leaving little visible rear geometry to fade.

Why it failed:

- Hidden-line behavior is a visibility policy, not a depth-fog model.
- It cannot make the visible front cap, side rim, and remaining shell geometry shade by depth if the visible geometry is still handled as large material batches.

Do not repeat:

- Do not rely on Hidden Lines off/on as the main depth cue.

### 4. Adding Fog Density To Material Update Keys

What changed:

- Added fog density to ribbed-sphere and speaker/source material update keys.
- Ensured Fog Density changes trigger immediate material refreshes.

What happened:

- Necessary plumbing worked.
- The visible sphere still did not look fogged by depth.

Why it failed:

- Refreshing a material is not the same as changing how each part of the geometry shades.
- The material could update correctly while still applying one flat-looking treatment to a whole batch.

Do not repeat:

- Do not count key invalidation or material-write counters as visual proof.

### 5. Batch-Wide Ribbed-Sphere Tinting And Dimming

What changed:

- Sampled a mid/rear fog value and used it to tint and dim the vertical and horizontal rib batch materials.
- Added sphere-geometry fog alpha and color wash.

What happened:

- The whole sphere faded or tinted together.
- It did not create a near/mid/far gradient inside the visible sphere.

Why it failed:

- The ribbed sphere is represented as two large SceneKit batch materials: one for vertical ribs and one for horizontal rings.
- A single sampled fog value per material cannot express depth variation within that material.

Do not repeat:

- Do not apply one fog value to the whole vertical-rib or horizontal-ring batch and expect depth.

### 6. Advancing The Cutaway Plane Under Dense Fog

What changed:

- Dense fog advanced the hidden-line cutaway plane, leaving a shallower visible cap of the sphere.

What happened:

- Changed which portion of the shell was visible.
- Still did not make the remaining visible shell shade by depth.

Why it failed:

- Cutting away geometry is not the same as fogging geometry.
- It changes silhouette/coverage, not internal atmospheric depth.

Do not repeat:

- Do not use clipping depth as a substitute for visible fog depth.

### 7. SceneKit Shader Modifier Preview

What changed:

- Added SceneKit geometry and surface shader modifiers to the two batched ribbed-sphere materials.
- Passed camera-distance fog uniforms into the ribbed sphere material.
- Added tests asserting the shader modifiers and uniforms exist.

What happened:

- Build and tests passed.
- Headless benchmark rendered without shader failure.
- Visible user acceptance failed: fog still does not appear to affect sphere geometry.
- Later rendered pixel probes showed this path could also make the live ribbed sphere render as SceneKit's hot magenta shader fallback/error color, masking otherwise correct Rack Blue material state.

Why it failed:

- The shader attachment and uniform presence did not translate into an obvious visible effect in the actual review app.
- The test coverage proved plumbing, not visual contribution.
- Possible causes include SceneKit shader modifier failure or limitations on this geometry/material path, ineffective view-space distance math under the current SceneKit transform pipeline, constant-material lighting behavior dominating the result, global fog/cutaway interaction masking the shader contribution, or the effect simply being too subtle to read.

Do not repeat:

- Do not treat `shaderModifiers` presence, KVC uniform values, or headless render success as acceptance.
- Do not keep tuning the same SceneKit shader modifier path without a visual proof harness that isolates the rib material effect.
- Do not reintroduce ribbed-sphere shader modifiers while fixing palette color; retained SceneKit material diffuse/emission state is the current color authority.

## Core Lesson

The sphere cannot feel deep while the implementation is effectively controlled at the batch-material level or hidden-line level. Depth must be visible across the actual displayed rib geometry.

Current failure statement:

```text
The review app has fog plumbing, fog keys, speaker/label fog, batch material fog,
cutaway fog behavior, and a rejected SceneKit shader modifier attempt, but none
of those has produced an accepted visible fog effect on the Ribbed Speaker Sphere.
```

## What Evidence Counts Next

Acceptable evidence:

- A visible screenshot or live review where the near cap, side rim, and deeper visible sphere structure show clearly different fog intensity.
- A debug mode or isolated material preview proving near/mid/far ribs receive different final colors in the visible app.
- Pixel probes from a rendered image that compare near/mid/far rib samples, not just material state or shader presence.

Insufficient evidence:

- Passing build/test only.
- SceneKit material update counters.
- Shader modifier existence.
- Uniform values attached to a material.
- Global fog settings changing.
- The sphere disappearing or being clipped more aggressively.

## Recommended Direction

Stop treating the existing two SceneKit rib batches as the visual unit for depth. The next useful pass should either split the visible sphere into depth-addressable geometry groups, add explicit fog geometry/volume that visibly crosses the shell, or move the effect to the production Metal renderer where per-fragment depth is under direct control.

## Brainstorm Output

Product direction:

Make fog read as an actual depth layer across the Sonic Sphere structure, not as atmosphere around everything except the shell. The operator problem is spatial trust: the viewport should make it obvious what is near, what is receding, and how speakers/source markers sit inside the structure.

Recommended approach:

Use a visible proof-first approach before another production-style shader attempt. The smallest credible next pass is a SceneKit review-only segmented rib-depth renderer: keep the current welded rib geometry generation, but split the rendered ribs into several camera-depth bands or curve groups with distinct fog materials. This is less elegant than true per-fragment fog, but it directly attacks the failed batch-material problem and should be visibly reviewable.

Possible approaches:

1. Depth-banded rib geometry in SceneKit

Split rib/ring output into near, mid, far, and rear-visible material groups based on camera-depth samples. Each group gets a clearly different fog tint/brightness. Rebuild or regroup when camera view changes, but keep density low enough for review.

Tradeoff: likely to work visibly in the current app; less elegant and may cost more CPU during active camera motion. Good as a review proof, not necessarily production architecture.

2. Explicit volumetric fog shell

Add translucent camera-facing fog planes, rings, or a subtle internal sphere volume that crosses the ribbed structure. Instead of depending on rib material response, the fog layer visually occludes and washes depth.

Tradeoff: could create the strongest perceived depth quickly, but risks looking decorative or cloudy if overdone. Needs careful art direction so it does not hide speaker identity.

3. Production Metal unified fog

Move fog to `OrbitalViewRender` as a shared shader function for shell, speakers, labels, sources, glows, and hidden-line treatment.

Tradeoff: architecturally correct and durable, but bigger. It should not be attempted until the exact visible target is proven in a small review harness or mockup.

Smallest useful version:

Create one review-only depth-banded rib renderer preset or debug path with four bands:

```text
near = crisp / bright
mid = slightly fog washed
far = visibly dimmer and closer to fog color
rear-visible = very soft, only when Hidden Lines is on
```

Acceptance should be a screenshot or live review where sphere geometry visibly changes between low and high Fog Density.

Out of scope:

- Audio, meters, channel order, routing, telemetry, and source identity.
- More label/speaker fog tuning as the primary fix.
- Another shader-plumbing-only pass without visible evidence.
- Production Metal work until the visual target is accepted.

Open questions:

- Is it acceptable for active camera motion to rebuild/regroup rib depth bands, or should the review app update bands only when the camera stops?
- Should Hidden Lines off still show only the front cap, or should dense fog reveal soft rear hints to create more depth?
- Should fog be neutral gray/black atmospheric wash, or palette-colored haze from the current theme?

Should we create a visual mockup:

Yes. The fastest useful mockup is not a new web app; it is either a SceneKit debug mode or a small screenshot-driven harness that compares current batch ribs against depth-banded ribs at Fog Density 0, 50, and 100.

Should we create an OpenSpec proposal:

Not for the next visual proof. Create OpenSpec only when moving the accepted fog model into `OrbitalViewRender` or changing public renderer behavior.

Summary for Architect:

The SceneKit shader-modifier preview failed visible acceptance. The next step should not be more shader plumbing. Prove the desired sphere-depth read with explicit depth-banded rib geometry or visible fog-volume occlusion in the review surface, then port the accepted behavior to Metal as a protected renderer slice.
