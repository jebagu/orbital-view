# Work Package: Jets VU Speaker Type

## Goal

Add a new speaker VU geometry variation named `jetsVU` to Orbital View. The existing cube face-center bloom behavior remains intact and is exposed as `cubeVU`. The new `jetsVU` mode renders each speaker as a long rectangular prism whose long axis radiates away from the sphere. The VU bloom travels from the sphere outward, creating the visual impression of rainbow or fire jets firing out of the speaker shell.

## Product behavior

Add a UI control for speaker type:

- `cubeVU`: current cube speaker behavior, with the VU blooming radially on cube faces.
- `jetsVU`: new outward rectangular-prism behavior, with the VU blooming along the radial axis away from the sphere.

Add a jet length slider for `jetsVU`:

- Label: `Jet Length`
- Unit: pixels
- Suggested range: `8...180`
- Suggested default: `48`
- Suggested step: `1`
- Shortest value should be visually close to the existing cube footprint.
- Increasing the value should extend the prism farther away from the sphere origin along the speaker normal.

The existing color scheme picker must affect `jetsVU`. The jet color must come from the selected `SpeakerMeterColorScheme` ramp, not from hard-coded warm, cool, or checker colors.

## Important compatibility rule

Do not rename or remove existing public enum cases such as `SpeakerMeterVisualStyle.cubeScalarCenterBloom`. Existing presets and Codable payloads should continue to decode. Add `cubeVU` and `jetsVU` as a new speaker type setting, not as a breaking rename of the existing visual style enum.

Old settings without a speaker type should decode as `speakerType: .cubeVU`.

## Scope

Implement the feature in the core settings model, Metal renderer, SwiftUI settings tray, standalone mockup if applicable, and tests.

## Non-goals

Do not mutate `OrbitalViewSpeaker.shape` in response to meter updates, camera updates, speaker type changes, or jet length changes.

Do not rebuild static scene geometry when only `speakerType` or `jetLengthPixels` changes. This should behave like the existing display-only `speakerZScale` control.

Do not replace the existing cube bloom style. `cubeVU` must preserve the current look.

## Data model changes

Add a public speaker type enum, ideally in `Sources/OrbitalViewCore/OrbitalViewMeters.swift` or a nearby core file:

```swift
public enum SpeakerMeterSpeakerType: String, Codable, CaseIterable, Equatable, Sendable {
    case cubeVU
    case jetsVU

    public var displayName: String {
        switch self {
        case .cubeVU: return "Cube VU"
        case .jetsVU: return "Jets VU"
        }
    }
}
```

Extend `SpeakerMeterVisualSettings` with:

```swift
public static let minJetLengthPixels: Float = 8
public static let maxJetLengthPixels: Float = 180

public var speakerType: SpeakerMeterSpeakerType
public var jetLengthPixels: Float
```

Default values:

```swift
speakerType: .cubeVU
jetLengthPixels: 48
```

Validation requirements:

- `jetLengthPixels` must be finite.
- Clamp or reject outside `minJetLengthPixels...maxJetLengthPixels`, matching the existing settings validation style.
- Decode old settings that lack `speakerType` or `jetLengthPixels` by using the defaults above.
- Encode new settings so presets persist the selected speaker type and jet length.

Keep `speakerZScale` as-is for compatibility. It can still apply to `cubeVU`, and it can be ignored or secondary for `jetsVU` unless the current renderer already uses it in a way that is visually useful.

## Renderer design

Implement `jetsVU` as a display setting interpreted by the renderer. The scene speaker layout remains fixed.

### Geometry

For `cubeVU`, keep the existing speaker vertex and fragment behavior.

For `jetsVU`, render a rectangular prism per speaker:

- The inner or back face is anchored at the speaker position on the sphere surface.
- The long axis follows the speaker normal, away from the sphere origin.
- The prism cross-section uses the existing cube face size or `facePixels`-derived footprint.
- The prism depth comes from `jetLengthPixels` converted into clip-space units for the current render target.

Suggested conversion:

```swift
let minViewportPixels = Float(max(1, min(renderTargetWidth, renderTargetHeight)))
let jetLengthClip = 2 * settings.jetLengthPixels / minViewportPixels
```

Then make the final depth at least cube-like:

```swift
let cubeDepthClip = speakerQuadRadius * 2
let finalJetDepthClip = max(cubeDepthClip, jetLengthClip)
```

The key visual requirement is that longer jet lengths extend the prism outward from the sphere, not equally inward and outward around the anchor.

### Uniforms

Add a small speaker geometry uniform buffer or reuse an existing settings uniform if there is space.

Suggested shape:

```swift
private struct SpeakerGeometryUniforms {
    var speakerType: Float       // 0 = cubeVU, 1 = jetsVU
    var jetLengthClip: Float
    var cubeDepthClip: Float
    var reserved: Float
}
```

If Swift and Metal struct alignment is inconvenient, use `SIMD4<Float>` with the same fields.

Changing `speakerType` or `jetLengthPixels` should increment `meterVisualSettingsRevision` only. It should not increment `structuralRevision`.

### Fragment behavior

For `jetsVU`, map the VU energy along the prism depth axis rather than radially on the cube face.

Suggested shader semantics:

- `axial = 0` at the sphere surface.
- `axial = 1` at the jet tip.
- RMS controls the body or core fill.
- Peak controls the leading bright edge or tip halo.
- Clip adds a hot cap near the tip.
- Idle tint leaves a faint, low-energy visible prism near the base.

Pseudo shader logic:

```metal
float rms = material.x;
float peak = material.y;
bool clip = material.z > 0.5;
float idle = material.w;

float axial = saturate(localJetZ01);
float body = smoothstep(axial - bloomEdge, axial + bloomEdge, rms);
float tip = smoothstep(axial - bloomEdge * 2.0, axial + bloomEdge * 2.0, peak);
float energy = saturate(idle + body * hotFill + tip * 0.35);
float rampPosition = pow(saturate(axial * 0.85 + peak * 0.15), responseCurve);
float3 color = sampleRamp(rampPosition).rgb * energy;

if (clip && axial > 0.85) {
    color = max(color, float3(1.0, 0.92, 0.72));
}
```

The exact math can be tuned, but the directionality should be clear: energy blooms from `axial = 0` to `axial = 1`, away from the sphere.

### Color scheme

`jetsVU` must use the existing ramp built from `settings.colorScheme.theme.vuRamp`.

Do not hard-code `jetsVU` colors. The Daft Punk Bow scheme should look like rainbow jets. Monochrome should stay monochrome. Other schemes should naturally follow their ramps.

## SwiftUI settings tray

In `Sources/OrbitalViewSwiftUI/OrbitalView.swift`, add bindings for:

```swift
speakerTypeBinding
jetLengthPixelsBinding
```

Update the settings update helper to carry through `speakerType` and `jetLengthPixels`.

In the Basic section, add:

```swift
Picker("Speaker Type", selection: speakerTypeBinding) {
    ForEach(SpeakerMeterSpeakerType.allCases, id: \.self) { type in
        Text(type.displayName).tag(type)
    }
}
.pickerStyle(.menu)
```

Keep the existing style picker, but consider relabeling it to `VU Style` so the new `Speaker Type` picker is not ambiguous.

Keep the existing color scheme picker.

Conditionally show the height control:

- For `cubeVU`, show the existing `Speaker Height: Cube -> 2 Cubes` slider bound to `speakerZScale`.
- For `jetsVU`, show `Jet Length` bound to `jetLengthPixels` and display the value as pixels.

Suggested UI text:

```swift
Text("Jet Length")
Slider(
    value: jetLengthPixelsBinding,
    in: SpeakerMeterVisualSettings.minJetLengthPixels...SpeakerMeterVisualSettings.maxJetLengthPixels,
    step: 1
)
Text("\(Int(settings.jetLengthPixels.rounded())) px")
    .monospacedDigit()
```

## Standalone mockup support

If `OrbitalViewportMockup` has its own speaker shape controls, add a matching speaker type control there as well.

For SceneKit preview behavior:

- `cubeVU` keeps existing cube behavior.
- `jetsVU` uses `SCNBox` or equivalent rectangular prisms.
- Set the pivot so the prism extends outward from the sphere surface rather than from its center.
- Orient the prism along the speaker normal.
- Use the selected color ramp to tint the animated VU material.

A visual approximation is acceptable in the mockup as long as the production Metal renderer has the correct behavior.

## Tests

Add or update tests in the relevant core, render, SwiftUI, and viewer test targets.

### Core tests

- `SpeakerMeterSpeakerType` Codable round trip for `cubeVU` and `jetsVU`.
- `SpeakerMeterVisualSettings` decodes old JSON without `speakerType` as `.cubeVU`.
- `SpeakerMeterVisualSettings` decodes old JSON without `jetLengthPixels` as the default value.
- Invalid, non-finite, or out-of-range `jetLengthPixels` is handled consistently with existing validation.

### Render tests

- Rendering the same scene and meters with `speakerType: .cubeVU` and `.jetsVU` produces different offscreen pixel metrics.
- Increasing `jetLengthPixels` grows the non-transparent or non-background pixel bounds outward.
- Changing `speakerType` or `jetLengthPixels` does not mutate `scene.speakers.map(\.shape)`.
- Changing `speakerType` or `jetLengthPixels` does not change static geometry cache keys.
- Changing `speakerType` or `jetLengthPixels` does not trigger new speaker buffer allocation when existing buffers have enough capacity.
- Color scheme affects `jetsVU`: compare Daft Punk Bow and Monochrome or another built-in scheme and assert different color channel totals.
- Meter updates still affect RMS, peak, and clip in `jetsVU`.

### SwiftUI tests

- Settings tray exposes the new speaker type picker.
- Selecting `jetsVU` updates `SpeakerMeterVisualSettings.speakerType`.
- The jet length slider updates `jetLengthPixels`.
- Old initializers and host usage still compile.

### Viewer and mockup tests

- Mockup includes both `Cube VU` and `Jets VU` options.
- Mockup defaults match production defaults.
- Existing speaker shape and color constants remain unchanged unless intentionally updated.

## Acceptance criteria

The change is done when all of the following are true:

- The UI has a `Speaker Type` selection with `Cube VU` and `Jets VU`.
- `Cube VU` matches the current visual behavior.
- `Jets VU` renders rectangular prisms that radiate outward from the sphere surface.
- The VU animation in `Jets VU` blooms away from the sphere, like outward jets.
- The jet length slider is in pixels and visibly controls outward prism length.
- The shortest jet length is cube-like.
- Built-in color schemes affect jet colors through the existing ramp system.
- Existing presets and Codable payloads still load.
- Display setting changes do not mutate scene speaker shapes.
- Display setting changes do not rebuild static geometry or allocate speaker buffers unnecessarily.
- Existing tests pass and new tests cover the feature.

## Suggested files to edit

- `Sources/OrbitalViewCore/OrbitalViewMeters.swift`
- `Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift`
- `Sources/OrbitalViewSwiftUI/OrbitalView.swift`
- `Sources/OrbitalViewSwiftUI/OrbitalViewportMockup.swift`
- `Tests/OrbitalViewCoreTests/*`
- `Tests/OrbitalViewRenderTests/OrbitalViewRenderTests.swift`
- `Tests/OrbitalViewSwiftUITests/*`
- `Tests/OrbitalViewViewerTests/*`, if present

## Verification commands

Run the package tests:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Run the existing inline mockup JavaScript parse check if the repo still includes the browser mockups:

```bash
node -e 'const fs=require("fs"); for (const file of ["mockups/orbital-view-viewport/index.html", "mockups/sonicsphere-cube-vu-single-screen/index.html"]) { const html=fs.readFileSync(file,"utf8"); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]).join("\n"); new Function(scripts); } console.log("inline JS parses");'
```

## Implementation notes

Prefer a shader-uniform implementation over scene mutation. The renderer already has dynamic material settings and color ramp uniforms, so `jetsVU` should be another display interpretation of the same speaker anchors and meter data.

Keep the first implementation simple. Get the outward geometry, axial bloom, color-ramp behavior, UI selection, and tests working first. Tune flame-like softness, tip halo, and idle glow after the structural feature is stable.
