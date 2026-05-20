# Object Tree Merge Compatibility

## Purpose

Slice 013 compares the current Orbital View VU Kit tree with the separate object-focused tree and records the merge-safe path before cube/prism VU feature work begins.

## Trees Compared

Current VU tree:

```text
/Users/jeremyguillory/Documents/vibecode projects/Orbital View VU Kit
branch: codex/orbital-view-vu-kit
```

Object tree found in the workspace:

```text
/Users/jeremyguillory/Documents/vibecode projects/orbital-view-with-objects
branch: codex/orbital-view-with-objects
```

The object tree was clean when inspected.

## High-Level Finding

The object tree is older than the current VU tree. It already contains the static scene-level `virtualObjects` slot, but it does not contain the current dynamic object frame, object meter, object visual settings, renderer object revision, retained object buffer, or SwiftUI object forwarding APIs.

Current VU object additions are therefore additive relative to the object tree. No source compatibility scaffolding is required for Slice 013.

## Public Symbol Comparison

Shared public contracts:

```text
OrbitalViewSceneSpec
OrbitalViewVirtualObject
OrbitalViewSelectableID.virtualObject(String)
OrbitalViewCameraState
OrbitalViewMode
OrbitalViewProjection
OrbitalViewOrbit
OrbitalViewRenderState
OrbitalViewRendering
OrbitalView
```

Current VU tree additions not present in the object tree:

```text
OrbitalViewObjectFrameSet
OrbitalViewObjectFrame
ObjectMeterFrame
ObjectMeterLevel
ObjectVisualSettings
ObjectVisualShape
ObjectVisualPalette
OrbitalViewObjectRenderBounds
OrbitalViewRenderState.objectFrames
OrbitalViewRenderState.objectMeters
OrbitalViewRenderState.objectVisualSettings
OrbitalViewRenderState.objectFrameRevision
OrbitalViewRenderState.objectMeterRevision
OrbitalViewRenderState.objectVisualSettingsRevision
OrbitalViewRendering.updateObjects(_:)
OrbitalViewRendering.updateObjectMeters(_:)
OrbitalViewRendering.updateObjectVisualSettings(_:)
OrbitalView objectFrames/objectMeters/objectVisualSettings initializer inputs
```

## Contract Notes

`OrbitalViewVirtualObject` is a static scene contract. It should continue to mean an optional scene object declared with a stable string ID and label.

`OrbitalViewObjectFrame` is a dynamic host snapshot contract. It should continue to mean a Wavefield-style live source object keyed by integer `objectID` in `1...128`, with pose, width, category, and optional capped trail samples.

`ObjectMeterFrame` is a dynamic object VU contract keyed by `objectID`. It must remain separate from `SpeakerMeterFrame`, which is keyed by physical speaker channel.

This split avoids a naming conflict between static scene objects and dynamic live source-object telemetry. Future object-tree work should bridge between the two concepts explicitly instead of collapsing them into one type.

## Renderer Layer Notes

The object tree renderer only separates scene, speaker meters, camera, and selection revisions.

The current VU renderer adds separate object revisions:

```text
objectFrameRevision
objectMeterRevision
objectVisualSettingsRevision
```

These are more specific than a single generic `objectLayerRevision`, and they preserve the performance invariant that object meter, trail, and visual-setting updates do not rebuild speaker static geometry. Do not replace them with one coarse object revision.

If a future object tree introduces a generic layer model, bridge it additively by mapping:

```text
objectLayer structural snapshot -> objectFrameRevision
objectLayer meter skin snapshot  -> objectMeterRevision
objectLayer visual settings      -> objectVisualSettingsRevision
```

## Expected Source Merge Conflicts

A textual merge is likely in these files because the VU tree has already advanced beyond the object tree:

```text
Sources/OrbitalViewCore/OrbitalViewMeters.swift
Sources/OrbitalViewCore/OrbitalViewValidationError.swift
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewRender/OrbitalViewMetalRenderer.swift
Sources/OrbitalViewRender/OrbitalViewRenderState.swift
Sources/OrbitalViewRender/OrbitalViewRendering.swift
Sources/OrbitalViewSwiftUI/OrbitalView.swift
Sources/OrbitalViewSwiftUI/OrbitalViewMetalView.swift
Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift
Tests/OrbitalViewSwiftUITests/OrbitalViewSwiftUITests.swift
```

These are expected additive conflicts, not semantic blockers.

## Merge Guidance

- Preserve physical speaker identity and `SpeakerMeterFrame.levelsByChannel[channel]`.
- Preserve `OrbitalViewSceneSpec.virtualObjects` as static/future scene metadata.
- Preserve dynamic live object contracts in `OrbitalViewObjects.swift`.
- Preserve separate object frame, object meter, and object visual setting revisions.
- Keep object rendering as a renderer layer beside speaker VU rendering, not inside speaker draw inputs.
- Prefer adapter/bridge types if the object tree later adds differently named object snapshots.
- Do not rename public speaker, meter, camera, scene, or selection types for the merge.

## Object-Tree Compatibility

Contracts added or changed:

```text
No new source contracts in Slice 013. Compatibility was documented only.
```

Symbols that may conflict:

```text
None found in the current object tree. Future names to watch: OrbitalViewObject, ObjectFrame, ObjectLayer, ObjectMeter.
```

Renderer layers affected:

```text
No source changes in Slice 013. Existing renderer already has speaker and object draw-input paths separated.
```

Whether changes are additive:

```text
Yes. The current VU object APIs are additive relative to the inspected object tree.
```
