# Codex Work Package: Ribbed Speaker Sphere Still Renders Magenta in Live App

Date: 2026-05-31
Project: Orbital View Turbo / OrbitalViewViewer
Primary target: live review app behavior, not only source-level material mutation

Paste this entire work package into Codex. The goal is to diagnose and fix the live UI-to-SceneKit-to-pixel path for the Ribbed Speaker Sphere color bug.

## 1. Problem statement

The visible app still shows the Ribbed Speaker Sphere as hot pink / magenta even after source-level tests show that `SCNMaterial.diffuse.contents` changes when `geodesicRenderStyle` and `geodesicSaturation` change.

This means the current tests are proving only this:

```text
Some SceneKit material properties can change when coordinator update logic is called directly.
```

They are not proving this:

```text
The running review app receives the user-selected geodesic appearance, propagates it through SwiftUI, updates the active NSViewRepresentable and SceneKit coordinator, updates the actual visible ribbed sphere node, and renders non-magenta pixels.
```

The next work must not be another blind palette-token patch. The next work must identify the exact broken layer in the real path.

## 2. Top 3 concerns to address

1. Avoid false positives from low-level tests. A test that directly inspects `SCNMaterial.diffuse.contents` is insufficient if the live `SCNView` pixels stay magenta.
2. Avoid polluted diagnostics. Do not use dice as the first proof, and do not trust screenshots where `Geodesic Appearance` still shows `Purple` selected. In that state, pink is expected.
3. Avoid stale-state traps. The likely bug is either stale SwiftUI-to-`NSViewRepresentable` / coordinator state, a saved/default theme reasserting Purple, or a later frame-loop writer overwriting the desired material state.

## 3. Known context from prior attempts

Prior work already changed or checked the following:

- Ribbed sphere vertical ribs were moved toward `geodesicTheme.accent`.
- Horizontal rings were moved toward `geodesicTheme.accentSecondary`.
- `configuration.geodesicColor(...)` was applied so saturation affects both lanes.
- Canvas fallback was updated similarly.
- `OrbitalViewportRibbedSpeakerSphereUpdateKey` was checked and includes `geodesicRenderStyle` and `geodesicSaturation`.
- Focused Swift tests passed.
- `git diff --check` passed.
- `swift build` passed.
- Full `swift test` passed with 202 tests.
- The app was relaunched through:

```bash
/Users/jeremyguillory/Documents/vibecode projects/Open Orbital View Kit Latest.command
```

- The running process path was confirmed to come from the expected `Orbital View Turbo` tree.
- A second attempted fix moved shader/fog colors toward geodesic material colors and added tests asserting shader fog uniforms change with palette/saturation.
- Those source-level tests also passed.
- The live app was still reported as visually pink.

Interpretation: material-level implementation improved, but the live bug is not proven fixed. The real failure is likely above or after the tested material-update function.

## 4. Working hypothesis ranking

Most likely root causes, in order:

1. The live SwiftUI state is not reaching the active `NSViewRepresentable` or SceneKit coordinator.
2. The coordinator stores stale parent/configuration from `makeCoordinator` or `makeNSView` and is not refreshed inside `updateNSView`.
3. A startup/default/saved theme path reasserts Purple after the user picks another geodesic style.
4. A per-frame writer, timer, renderer delegate, meter update, animation update, or shader update reapplies old purple/pink colors after the one-shot material update.
5. The code is changing a material that is not the final visible source of color, due to duplicate nodes, overlay/fallback layer, shader modifier, emission/multiply channel, fog, technique, post-process, or stale scene graph.
6. The `SCNView` does not repaint after the change.

## 5. Hard constraints for Codex

Do not start by changing palette constants again.

Do not use dice as the first validation step. Dice changes too many things at once and may toggle `showRibbedSpeakerSphere` or unrelated view settings.

Do not accept a test that only calls coordinator update logic directly and inspects material properties.

Do not accept a screenshot where the UI still says `Purple` as evidence of failure. That is expected pink behavior.

Do not rely on breakpoints only. Add deterministic, grep-friendly logs and a visible debug overlay.

Do not ship debug probes in Release behavior. Gate all probes behind `#if DEBUG` and launch environment flags.

## 6. Initial repository search commands

Run these from the repository root:

```bash
rg "OrbitalViewport3DSceneView|NSViewRepresentable|makeCoordinator|updateNSView|Coordinator" .
rg "OrbitalViewportRenderConfiguration|geodesicRenderStyle|geodesicSaturation|Geodesic Appearance" .
rg "OrbitalViewportRibbedSpeakerSphereUpdateKey|updateRibbedSpeakerSphere|Ribbed Speaker Sphere|ribbed" .
rg "diffuse\.contents|emission\.contents|ambient\.contents|multiply\.contents|transparent\.contents|shaderModifiers|SCNMaterial" .
rg "speakerTheme|geodesicTheme|purple|pink|magenta|accentSecondary|updateAtTime|Timer|renderer\(" .
rg "saved theme|SavedTheme|restore|default theme|onAppear|scenePhase|UserDefaults|AppStorage" .
```

Classify every color/material write into one of these categories:

- Initial topology/material creation
- User-driven configuration update
- `NSViewRepresentable.updateNSView`
- Coordinator update
- Ribbed sphere visual update
- Per-frame render delegate / timer / meter update
- Saved/default theme restore
- Canvas fallback only
- Debug/previews only

The live SceneKit path should have one authority for ribbed sphere colors. If there are multiple authorities, add tracing first, then remove or gate the wrong one.

## 7. Phase 1: add a live force-green probe

Purpose: prove whether the code is touching the actual visible node.

Add a debug-only launch flag:

```text
ORB_DEBUG_FORCE_RIBBED_GREEN=1
```

Add this function near the live ribbed speaker sphere SceneKit runtime code. Adapt node/root names to the actual project.

```swift
#if DEBUG
private func forceDebugRibbedSphereGreen(_ root: SCNNode, reason: String) {
    root.enumerateChildNodes { node, _ in
        guard let geometry = node.geometry else { return }

        node.name = [node.name, "DEBUG_FORCE_RIBBED_GREEN", reason]
            .compactMap { $0 }
            .joined(separator: ".")

        for material in geometry.materials {
            material.name = "DEBUG_FORCE_GREEN_\(reason)"
            material.diffuse.contents = NSColor.systemGreen
            material.emission.contents = NSColor.systemGreen
            material.ambient.contents = NSColor.systemGreen
            material.multiply.contents = NSColor.white
            material.transparent.contents = NSColor.white
            material.shaderModifiers = nil
        }
    }
}
#endif
```

Call it as close as possible to the actual live ribbed sphere root node, not a test-created node:

```swift
#if DEBUG
if ProcessInfo.processInfo.environment["ORB_DEBUG_FORCE_RIBBED_GREEN"] == "1" {
    forceDebugRibbedSphereGreen(ribbedSpeakerSphereRootNode, reason: "live_path_probe")
    scnView.rendersContinuously = true
    scnView.needsDisplay = true
    return
}
#endif
```

Expected interpretation:

- If the sphere turns green, this code is touching the real visible node. Continue investigating state propagation, later overwrites, saved theme restore, or repaint.
- If the sphere stays magenta, this code is not touching the visible node, or another layer dominates final pixels. Investigate duplicate nodes, overlays, shader modifiers, fog, technique, or the wrong SceneKit view.
- If the sphere flashes green and reverts to magenta, a later writer is overwriting the material state. Find the writer with Phase 2 tracing.

## 8. Phase 2: add a flight recorder through the live path

Add one debug logger. Keep it low ceremony and grep-friendly.

```swift
#if DEBUG
enum OrbitalRenderTrace {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.environment["ORB_DEBUG_RENDER_TRACE"] == "1"
    }

    static func log(
        _ stage: String,
        configuration: OrbitalViewportRenderConfiguration,
        extra: String = "",
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        guard isEnabled else { return }
        print("""
        [RIBBED_TRACE] stage=\(stage) style=\(configuration.geodesicRenderStyle) saturation=\(configuration.geodesicSaturation) extra=\(extra) at=\(file):\(line)
        """)
    }

    static func logWrite<Value>(
        _ name: String,
        old: Value,
        new: Value,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        guard isEnabled else { return }
        print("""
        [RIBBED_WRITE] \(name) old=\(old) new=\(new) at=\(file):\(line)
        \(Thread.callStackSymbols.prefix(14).joined(separator: "\n"))
        """)
    }
}
#endif
```

Add logs at these exact stages:

```swift
// 1. Geodesic palette button action
OrbitalRenderTrace.log("ui_palette_click_rackBlue", configuration: currentConfiguration)

// 2. Render settings/store setter
OrbitalRenderTrace.logWrite("geodesicRenderStyle", old: oldValue, new: geodesicRenderStyle)

// 3. Render configuration creation
OrbitalRenderTrace.log("configuration_built", configuration: configuration)

// 4. NSViewRepresentable update
OrbitalRenderTrace.log("representable_updateNSView_enter", configuration: configuration)

// 5. Coordinator update
OrbitalRenderTrace.log("coordinator_update_enter", configuration: configuration)

// 6. Ribbed update key compare
OrbitalRenderTrace.log(
    "ribbed_update_key_compare",
    configuration: configuration,
    extra: "old=\(String(describing: oldKey)) new=\(newKey) changed=\(oldKey != newKey)"
)

// 7. Actual material application
OrbitalRenderTrace.log(
    "ribbed_material_apply",
    configuration: configuration,
    extra: "vertical=\(verticalColor) horizontal=\(horizontalColor) materialIDs=\(materialIDs)"
)

// 8. Any frame/timer/meter material writer
OrbitalRenderTrace.log("frame_material_writer", configuration: configuration)
```

After clicking `Rack Blue`, answer this one question from the logs:

```text
What is the first stage that still says Purple instead of Rack Blue?
```

That stage is the root-cause layer.

## 9. Phase 3: add a visible debug overlay

Add a debug overlay or accessible text labels in the live app. This should be visible in screenshots and queryable from UI tests.

Gate it behind:

```text
ORB_DEBUG_RIBBED_OVERLAY=1
```

Overlay values:

```text
build: ribbed-color-probe-2026-05-31-a
live geodesicRenderStyle: <value>
live geodesicSaturation: <value>
last ribbed apply sequence: <integer>
last ribbed writer: <stage or function>
last material names: <vertical name>, <horizontal name>
```

SwiftUI sketch:

```swift
#if DEBUG
struct RibbedDebugOverlay: View {
    let buildStamp: String
    let geodesicRenderStyle: GeodesicRenderStyle
    let geodesicSaturation: Double
    let lastApplySequence: Int
    let lastWriter: String
    let materialNames: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("build: \(buildStamp)")
                .accessibilityIdentifier("orbital-build-stamp")
            Text("live-render-style-\(String(describing: geodesicRenderStyle))")
                .accessibilityIdentifier("live-render-style")
            Text("live-saturation-\(geodesicSaturation)")
                .accessibilityIdentifier("live-geodesic-saturation")
            Text("ribbed-apply-sequence-\(lastApplySequence)")
                .accessibilityIdentifier("ribbed-apply-sequence")
            Text("ribbed-last-writer-\(lastWriter)")
                .accessibilityIdentifier("ribbed-last-writer")
            Text("ribbed-materials-\(materialNames)")
                .accessibilityIdentifier("ribbed-material-names")
        }
        .font(.caption2.monospaced())
        .padding(6)
    }
}
#endif
```

The exact UI style is irrelevant. It only needs to be deterministic, visible, and accessible to UI tests.

## 10. Phase 4: fix stale representable/coordinator state if trace points there

Search for stale coordinator patterns like these:

```swift
final class Coordinator {
    let parent: OrbitalViewport3DSceneView
    let configuration: OrbitalViewportRenderConfiguration
}
```

or:

```swift
final class Coordinator {
    var parent: OrbitalViewport3DSceneView

    init(_ parent: OrbitalViewport3DSceneView) {
        self.parent = parent
    }
}
```

If the coordinator stores `parent` or `configuration` captured during `makeCoordinator`, it may hold an obsolete render configuration forever. The coordinator persists with the hosted view, so coordinator-held state must be refreshed when the SwiftUI representable changes.

Preferred pattern:

```swift
struct OrbitalViewport3DSceneView: NSViewRepresentable {
    let configuration: OrbitalViewportRenderConfiguration

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        context.coordinator.attach(view: scnView)
        return scnView
    }

    func updateNSView(_ scnView: SCNView, context: Context) {
        #if DEBUG
        OrbitalRenderTrace.log("representable_updateNSView_enter", configuration: configuration)
        #endif

        context.coordinator.update(
            scnView: scnView,
            configuration: configuration
        )

        #if DEBUG
        if ProcessInfo.processInfo.environment["ORB_DEBUG_FORCE_CONTINUOUS_RENDER"] == "1" {
            scnView.rendersContinuously = true
        }
        scnView.needsDisplay = true
        #endif
    }

    final class Coordinator {
        private weak var scnView: SCNView?
        private var lastConfiguration: OrbitalViewportRenderConfiguration?
        private var lastRibbedKey: OrbitalViewportRibbedSpeakerSphereUpdateKey?

        func attach(view: SCNView) {
            self.scnView = view
        }

        func update(
            scnView: SCNView,
            configuration: OrbitalViewportRenderConfiguration
        ) {
            #if DEBUG
            OrbitalRenderTrace.log("coordinator_update_enter", configuration: configuration)
            #endif

            self.scnView = scnView
            self.lastConfiguration = configuration

            updateRibbedSpeakerSphereIfNeeded(
                scnView: scnView,
                configuration: configuration
            )
        }
    }
}
```

Avoid this:

```swift
context.coordinator.updateUsingCapturedParent()
```

Prefer this:

```swift
context.coordinator.update(scnView: scnView, configuration: configuration)
```

## 11. Phase 5: fix missed SwiftUI invalidation if trace points there

If the UI checkmark moves to `Rack Blue` but `updateNSView` does not run, inspect representable dependencies and equality.

Search for:

```swift
.equatable()
```

or:

```swift
static func == (...) -> Bool {
    // accidentally ignores geodesicRenderStyle or geodesicSaturation
}
```

or cached configuration outside `body`:

```swift
let configuration = initialConfiguration
```

Fix by ensuring the representable directly depends on the changing value:

```swift
OrbitalViewport3DSceneView(
    configuration: renderSettings.currentConfiguration
)
```

If there is an equality implementation, include these fields:

```swift
lhs.configuration.geodesicRenderStyle == rhs.configuration.geodesicRenderStyle
lhs.configuration.geodesicSaturation == rhs.configuration.geodesicSaturation
```

Diagnostic only:

```swift
.id("\(configuration.geodesicRenderStyle)-\(configuration.geodesicSaturation)")
```

If `.id(...)` fixes it, the invalidation/equality path is the bug. Do not keep a forced rebuild unless topology rebuild cost is acceptable and intended.

## 12. Phase 6: fix saved/default theme reassertion if trace points there

If the logs show `Rack Blue` from the picker followed by `Purple` from restore/default state, force all geodesic style writes through a named setter.

Sketch:

```swift
@MainActor
final class OrbitalRenderSettings: ObservableObject {
    @Published private(set) var geodesicRenderStyle: GeodesicRenderStyle = .purple

    func setGeodesicRenderStyle(
        _ newValue: GeodesicRenderStyle,
        source: String
    ) {
        let oldValue = geodesicRenderStyle
        geodesicRenderStyle = newValue

        #if DEBUG
        OrbitalRenderTrace.logWrite(
            "geodesicRenderStyle source=\(source)",
            old: oldValue,
            new: newValue
        )
        #endif
    }
}
```

Every caller must identify itself:

```swift
settings.setGeodesicRenderStyle(.rackBlue, source: "geodesic_picker")
settings.setGeodesicRenderStyle(savedStyle, source: "saved_theme_restore")
settings.setGeodesicRenderStyle(randomStyle, source: "global_dice")
settings.setGeodesicRenderStyle(.purple, source: "startup_default")
```

Fix restore so it runs once before user edits, not repeatedly from `onAppear`, `scenePhase`, preview reloads, panel expansion, or delayed defaults.

Sketch:

```swift
@MainActor
final class ThemeRestoreGate: ObservableObject {
    private var didRestoreTheme = false
    private var userHasEditedTheme = false

    func restoreThemeOnce(_ theme: SavedTheme, into settings: OrbitalRenderSettings) {
        guard !didRestoreTheme else { return }
        guard !userHasEditedTheme else { return }

        didRestoreTheme = true
        settings.applySavedTheme(theme, source: "saved_theme_restore_once")
    }

    func markUserEditedTheme() {
        userHasEditedTheme = true
    }
}
```

Also add a launch environment kill switch for deterministic tests:

```text
ORB_DISABLE_SAVED_THEME=1
```

## 13. Phase 7: eliminate competing material writers if trace points there

If the material becomes `Rack Blue` and then reverts to magenta, search all later writers:

```bash
rg "renderer\(|updateAtTime|Timer|CADisplayLink|DispatchQueue|Task|diffuse\.contents|emission\.contents|shaderModifiers|fog|speakerTheme|purple|magenta" .
```

For the live SceneKit path, there should be exactly one function that writes ribbed sphere palette colors.

Preferred model:

```swift
struct RibbedSpeakerSphereVisualState: Equatable {
    var renderStyle: GeodesicRenderStyle
    var saturation: Double
    var verticalColor: NSColor
    var horizontalColor: NSColor
    var fogNearColor: SIMD4<Float>
    var fogFarColor: SIMD4<Float>
}
```

Preferred single writer:

```swift
private func applyRibbedSpeakerSphereVisualState(
    _ visualState: RibbedSpeakerSphereVisualState,
    to sphere: RibbedSpeakerSphereRuntime
) {
    sphere.verticalMaterial.diffuse.contents = visualState.verticalColor
    sphere.verticalMaterial.emission.contents = visualState.verticalColor

    sphere.horizontalMaterial.diffuse.contents = visualState.horizontalColor
    sphere.horizontalMaterial.emission.contents = visualState.horizontalColor

    sphere.verticalMaterial.name =
        "ribbed.vertical.\(visualState.renderStyle).sat.\(visualState.saturation)"

    sphere.horizontalMaterial.name =
        "ribbed.horizontal.\(visualState.renderStyle).sat.\(visualState.saturation)"

    updateRibbedFogUniforms(visualState)
}
```

Frame loops should update meter values, animation scalars, transforms, or shader uniforms that are truly time-dependent. They should not restore palette colors from `speakerTheme`, `.purple`, `.pink`, stale `geodesicTheme`, or default theme state.

If a frame loop must call a visual update, it must use the current live configuration, not captured startup configuration:

```swift
func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    updateMetersOnly(time)

    if let configuration = latestConfiguration {
        applyRibbedSpeakerSphereVisualStateIfNeeded(configuration)
    }
}
```

But prefer not writing palette colors from the frame loop at all.

## 14. Phase 8: inspect final visible material authority if pixels stay magenta

If `ribbed_material_apply` logs `Rack Blue`, material names say `Rack Blue`, and pixels stay magenta, inspect all non-diffuse visual sources.

Temporarily neutralize material channels during the debug probe:

```swift
material.diffuse.contents = rackBlueColor
material.emission.contents = NSColor.black
material.ambient.contents = NSColor.black
material.multiply.contents = NSColor.white
material.transparent.contents = NSColor.white
material.shaderModifiers = nil
```

Then inspect:

```swift
scene.fogColor
scnView.technique
node.filters
node.categoryBitMask
geometry.firstMaterial
geometry.materials
node.opacity
node.isHidden
node.renderingOrder
duplicate ribbed sphere nodes
canvas fallback overlay
material.lightingModel
shader modifier uniforms
post-processing layers
```

Name every live node and material with the applied style:

```swift
material.name = "ribbed.vertical.style.\(configuration.geodesicRenderStyle)"
node.name = "ribbedSphere.runtime.style.\(configuration.geodesicRenderStyle)"
```

Add a debug scene dump:

```swift
#if DEBUG
private func dumpRibbedSceneGraph(_ root: SCNNode) {
    guard OrbitalRenderTrace.isEnabled else { return }

    root.enumerateChildNodes { node, _ in
        let materialSummary = node.geometry?.materials.map { material in
            "name=\(material.name ?? "nil") diffuse=\(String(describing: material.diffuse.contents)) emission=\(String(describing: material.emission.contents))"
        }.joined(separator: " | ") ?? "no-geometry"

        print("[RIBBED_SCENE_DUMP] node=\(node.name ?? "nil") hidden=\(node.isHidden) opacity=\(node.opacity) materials=\(materialSummary)")
    }
}
#endif
```

Use it immediately after palette apply and again a few frames later.

## 15. Deterministic manual repro protocol

Use this exact protocol before using dice:

1. Launch the app with:

```bash
ORB_DISABLE_SAVED_THEME=1 \
ORB_FORCE_RIBBED_SPHERE_VISIBLE=1 \
ORB_DISABLE_RANDOM_ANIMATION=1 \
ORB_DEBUG_RENDER_TRACE=1 \
ORB_DEBUG_RIBBED_OVERLAY=1 \
ORB_DEBUG_FORCE_CONTINUOUS_RENDER=1 \
/Users/jeremyguillory/Documents/vibecode\ projects/Open\ Orbital\ View\ Kit\ Latest.command
```

2. Confirm the debug overlay shows the build stamp.
3. Confirm the starting geodesic style is known, preferably `Purple`.
4. Open `Geodesic Appearance`.
5. Click one deterministic non-pink style, preferably `Rack Blue`.
6. Confirm the UI checkmark moves to `Rack Blue`.
7. Confirm the debug overlay says `live-render-style-rackBlue` or equivalent.
8. Confirm logs show:

```text
ui_palette_click_rackBlue
geodesicRenderStyle source=geodesic_picker old=Purple new=Rack Blue
configuration_built style=Rack Blue
representable_updateNSView_enter style=Rack Blue
coordinator_update_enter style=Rack Blue
ribbed_update_key_compare changed=true
ribbed_material_apply style=Rack Blue
```

9. Confirm the visible sphere changes away from magenta and does not revert after several frames.

Failure diagnosis:

- Checkmark does not move: button binding is wrong or local-only state is being mutated.
- Checkmark moves, overlay still says Purple: UI setting is not writing the shared render settings/configuration.
- Overlay says Rack Blue, but `updateNSView` does not run: representable invalidation/equality/dependency problem.
- `updateNSView` says Rack Blue, coordinator says Purple: stale coordinator/parent/configuration problem.
- Coordinator says Rack Blue, ribbed update key unchanged: live update key or cache invalidation problem.
- Material apply says Rack Blue, pixels stay magenta: final visible material authority, shader, overlay, fog, duplicate node, or repaint problem.
- Pixels change then revert: later writer or saved/default restore problem.

## 16. Required UI-to-pixel regression test

Keep the existing source-level tests, but add a test that fails on the current live bug.

Launch flags:

```swift
app.launchEnvironment["ORB_DISABLE_SAVED_THEME"] = "1"
app.launchEnvironment["ORB_FORCE_RIBBED_SPHERE_VISIBLE"] = "1"
app.launchEnvironment["ORB_DISABLE_RANDOM_ANIMATION"] = "1"
app.launchEnvironment["ORB_DEBUG_RIBBED_OVERLAY"] = "1"
app.launchEnvironment["ORB_DEBUG_FORCE_CONTINUOUS_RENDER"] = "1"
```

UI test shape:

```swift
func testRackBlueChangesVisibleRibbedSpherePixels() throws {
    let app = XCUIApplication()
    app.launchEnvironment["ORB_DISABLE_SAVED_THEME"] = "1"
    app.launchEnvironment["ORB_FORCE_RIBBED_SPHERE_VISIBLE"] = "1"
    app.launchEnvironment["ORB_DISABLE_RANDOM_ANIMATION"] = "1"
    app.launchEnvironment["ORB_DEBUG_RIBBED_OVERLAY"] = "1"
    app.launchEnvironment["ORB_DEBUG_FORCE_CONTINUOUS_RENDER"] = "1"
    app.launch()

    XCTAssertTrue(app.staticTexts["orbital-build-stamp"].waitForExistence(timeout: 3))

    app.buttons["Geodesic Appearance"].click()
    app.buttons["Rack Blue"].click()

    XCTAssertTrue(app.staticTexts["live-render-style"].label.contains("rackBlue"))

    let screenshot = app.windows.firstMatch.screenshot()
    let sample = try averageColorInRibbedSphereRegion(screenshot.image)

    XCTAssertFalse(sample.isMagentaDominant)
    XCTAssertTrue(sample.isBlueOrMintDominant)
}
```

If `SCNView` can be reached in an app/integration test, prefer a direct SceneKit snapshot for the rendered viewport:

```swift
let image = scnView.snapshot()
```

Then sample a stable region inside the sphere. Do not sample the whole window. Crop to a deterministic bounding region or expose a debug method that returns the ribbed sphere projected screen bounds.

Pixel classification sketch:

```swift
struct RGBSample {
    let red: Double
    let green: Double
    let blue: Double

    var isMagentaDominant: Bool {
        red > 0.55 && blue > 0.45 && green < 0.38
    }

    var isBlueOrMintDominant: Bool {
        blue > 0.42 && green > 0.35 && red < 0.55
    }
}
```

Tune thresholds to the actual rendered palette and lighting, but ensure the test distinguishes pink/purple from Rack Blue under deterministic launch flags.

## 17. Acceptance criteria

Do not call this fixed until all of these are true:

- Clean launch with saved theme disabled starts from a known geodesic baseline.
- Clicking `Rack Blue` visibly moves the UI selection to `Rack Blue`.
- Debug overlay shows `geodesicRenderStyle == rackBlue` or equivalent.
- `updateNSView` logs `rackBlue`.
- Coordinator logs `rackBlue`.
- Ribbed update key logs `changed=true` after the click.
- Live attached ribbed materials are named with `rackBlue`, not `purple`.
- Scene dump after the click shows the visible ribbed sphere subtree carries `rackBlue` material state.
- Captured `SCNView.snapshot()` or UI screenshot shows sphere pixels changed away from magenta.
- Pixels do not revert to magenta after several frames.
- Existing focused tests still pass.
- `swift build` passes.
- Full `swift test` passes.
- The new UI-to-pixel regression test fails before the fix and passes after the fix.

## 18. Suggested verification commands

Adapt scheme and destination names to the actual project.

```bash
git diff --check
swift build
swift test
```

For Xcode UI tests, use the actual workspace/scheme:

```bash
xcodebuild test \
  -workspace OrbitalViewViewer.xcworkspace \
  -scheme OrbitalViewViewer \
  -destination 'platform=macOS' \
  -only-testing:OrbitalViewViewerUITests/testRackBlueChangesVisibleRibbedSpherePixels
```

If this project uses only Swift Package Manager or a different workspace/scheme, adjust accordingly. Do not skip the UI-to-pixel test because `swift test` passes.

## 19. External references for implementation reasoning

Use official Apple documentation where needed:

- `NSViewRepresentable`: https://developer.apple.com/documentation/swiftui/nsviewrepresentable
- `updateNSView(_:context:)`: https://developer.apple.com/documentation/swiftui/nsviewrepresentable/updatensview(_:context:)
- Apple WWDC22 `Use SwiftUI with AppKit`, especially coordinator lifetime and keeping coordinator properties up to date: https://developer.apple.com/videos/play/wwdc2022/10075/
- `SCNMaterial`: https://developer.apple.com/documentation/scenekit/scnmaterial
- `SCNMaterial.diffuse`: https://developer.apple.com/documentation/scenekit/scnmaterial/diffuse
- `SCNSceneRendererDelegate.renderer(_:updateAtTime:)`: https://developer.apple.com/documentation/scenekit/scnscenerendererdelegate/renderer(_:updateattime:)
- `SCNView.snapshot()`: https://developer.apple.com/documentation/scenekit/scnview/snapshot()
- `XCUIScreenshot`: https://developer.apple.com/documentation/xcuiautomation/xcuiscreenshot

## 20. Final instruction to Codex

Make the smallest code change that proves the live path and fixes the first broken layer found by the trace. Do not chase all hypotheses at once.

The expected root cause is probably one of these:

1. Stale coordinator/representable configuration.
2. SwiftUI invalidation/equality does not include `geodesicRenderStyle` or `geodesicSaturation`.
3. Saved/default theme reasserts Purple after user interaction.
4. A frame-loop or timer writer reapplies purple/pink material or shader state.
5. The visible node is not the node currently being updated.

The force-green probe should split the problem quickly. The trace should identify the first layer where `Rack Blue` becomes `Purple`, or where `Rack Blue` is applied but pixels stay magenta.
