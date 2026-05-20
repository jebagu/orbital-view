# Renderer Cache Plan

## Purpose

Lock the renderer cache boundaries for production-direction cube/prism center-bloom drawing.

The renderer must keep static speaker geometry separate from dynamic color, meter, camera, and object-layer state. Meter, settings, and camera changes may update uniforms or color buffers, but they must not rebuild speaker geometry or resize speaker objects.

## Current State

Current renderer drawing now separates speaker mesh data from material data:

- speakers render as instanced cube/prism meshes projected from canonical speaker anchors
- object cores and trail samples render through the same minimal quad path
- speaker position buffers are keyed by scene structural revision
- speaker orientation buffers are keyed by scene structural revision
- speaker material buffers are keyed by scene structural, meter, and meter-visual-settings revisions
- speaker ramp buffers are keyed by meter-visual-settings revision and reused when capacity is sufficient
- object position buffers are keyed by object frame and object visual settings revisions
- object color buffers are keyed by object frame, object meter, and object visual settings revisions
- Metal buffers are retained and reused when existing capacity is sufficient

Current debug tests count buffer allocations, not offscreen texture allocation. Offscreen textures are still created per smoke render and are not the long-term frame resource model.

## Static Speaker Geometry Key

Production speaker geometry must be invalidated by changes to:

- speaker ID
- physical channel
- speaker anchor
- speaker shape, including cube versus rectangular prism
- visual role
- future shell mesh topology inputs

It must not be invalidated by:

- `SpeakerMeterFrame`
- `SpeakerMeterVisualSettings`
- camera state
- selection state
- object meter state
- object trail color state

The current internal `OrbitalViewSpeakerStaticGeometryCacheKey` records speaker ID, channel, anchor, shape, and visual role so tests can prove cube and rectangular-prism scenes produce different static geometry keys.

## Channel-To-Instance Map

Production instanced drawing should preserve a stable channel-to-instance map:

```text
scene.speakers index -> render instance index
physical channel -> render instance index lookup
meter frame channel -> render instance color/material data
```

Extra meter channels are ignored by speaker drawing. Missing channels produce idle speaker color. Physical channel order is never reordered to match meter frame dictionary order.

## Buffer Model

Current retained buffers:

```text
speaker positions: structural speaker geometry only
speaker orientations: structural speaker normal/depth data only
speaker materials: structural + meter + meter visual settings
speaker ramp uniforms: meter visual settings
object positions: object frame + object visual settings
object colors: object frame + object meter + object visual settings
```

The production cube/prism path should continue to evolve these retained static mesh/instance buffers:

```text
speaker static mesh/cache: shape + anchor + channel identity
speaker instance uniforms: transform + face-local basis + channel index
speaker dynamic material: RMS/peak/clip envelope + palette/ramp values
object static cache: object ID + visual shape
object dynamic stream: object pose + width + trail samples + meter skin
```

If capacity is sufficient, dynamic writes should reuse existing Metal buffers. If capacity grows, buffers may reallocate upward. Shrinking active object or trail counts should not immediately shrink buffers.

## Object-Layer Compatibility

Future object rendering must stay independent of speaker static geometry:

- object frame updates must not rebuild speaker buffers
- object meter updates must not rebuild speaker buffers
- object trails and glow trails share object draw-input streams
- object static caches may use separate object IDs and shapes
- object buffers may grow independently from speaker buffers

The speaker cache key deliberately excludes object frame, object meter, and object visual setting revisions.

## Migration Path

Slice 018 implements the first shader-side cube/prism center-bloom path. It does not implement postprocess bloom, mesh tessellation beyond the cube/prism face mesh, shell/strut rendering, hit testing, or visual polish.

Next production renderer slices should:

1. Add shell/strut geometry without coupling it to meter material updates.
2. Refine face-local material animation and camera projection without changing channel identity.
3. Keep RMS/peak/clip in dynamic material buffers or uniforms.
4. Reuse the current structural/material/object revision split.
5. Extend cache-key tests before adding each new static input.
6. Keep offscreen smoke tests as blank-frame guards, not snapshot tests.

## Required Invariants

- Meter-only updates do not change static speaker draw inputs.
- Settings-only updates do not change static speaker draw inputs.
- Camera-only updates do not change static speaker draw inputs.
- Cube and rectangular-prism scenes produce different static geometry cache keys.
- Channel-to-instance mapping follows scene speaker order and ignores extra meter channels.
- Repeated meter/settings/camera-only renders do not allocate new speaker buffers when capacity is sufficient.
- Hot and clipped meter updates change material output without moving or resizing speaker geometry.
- Ramp/color-scheme updates change material output without changing static speaker geometry.
- Object-layer updates remain compatible with the speaker cache key.
