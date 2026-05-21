import SwiftUI
import XCTest
@testable import OrbitalViewCore
@testable import OrbitalViewRender
@testable import OrbitalViewSwiftUI

final class OrbitalViewSwiftUITests: XCTestCase {
    func testOrbitalViewportMockupMatchesNativeViewportContract() {
        let view = OrbitalViewportMockup()

        XCTAssertNotNil(view)
        XCTAssertEqual(OrbitalViewportMockup.sourceMockupPath, "mockups/orbital-view-viewport/index.html")
        XCTAssertEqual(OrbitalViewportMockup.controlSkinSource, "orbisonic-design-language")
        XCTAssertEqual(OrbitalViewportMockup.desktopSize, CGSize(width: 1512, height: 850))
        XCTAssertEqual(OrbitalViewportMockup.nativeDefaultWindowSize, CGSize(width: 1180, height: 760))
        XCTAssertEqual(OrbitalViewportMockup.nativeMinimumWindowSize, CGSize(width: 980, height: 680))
        XCTAssertEqual(OrbitalViewportMockup.leftRailWidth, 240)
        XCTAssertEqual(OrbitalViewportMockup.inspectorWidth, 300)
        XCTAssertEqual(OrbitalViewportMockup.footerHeight, 46)
        XCTAssertFalse(OrbitalViewportMockup.usesRootAnimationTimeline)
        XCTAssertEqual(OrbitalViewportMockup.viewportAnimationFramesPerSecond, 30)
        XCTAssertEqual(OrbitalViewportMockup.meterOnlyViewportFramesPerSecond, 10)
        XCTAssertLessThanOrEqual(
            OrbitalViewportMockup.meterOnlyViewportFramesPerSecond,
            OrbitalViewportMockup.viewportAnimationFramesPerSecond
        )
        XCTAssertEqual(OrbitalViewportMockup.inspectorRefreshFramesPerSecond, 10)
        XCTAssertEqual(OrbitalViewportMockup.speakerCount, 30)
        XCTAssertEqual(OrbitalViewportMockup.feyGeodesicNodeCount, 92)
        XCTAssertEqual(OrbitalViewportMockup.feyGeodesicEdgeCount, 270)
    }

    #if os(macOS)
    func testOrbitalViewportSceneKitDefaultsDrawOnDemandAtThirtyFPS() {
        XCTAssertFalse(OrbitalViewport3DSceneView.rendersContinuously)
        XCTAssertEqual(OrbitalViewport3DSceneView.sceneFramesPerSecond, 30)
    }
    #endif

    func testOrbitalViewportMockupKeepsNativeControlOptions() {
        XCTAssertEqual(OrbitalViewportCameraView.allCases.map(\.title), ["Plan", "Elevation", "Isometric"])
        XCTAssertEqual(OrbitalViewportRenderStyle.allCases.map(\.title), ["Purple", "Flamingo", "Green", "B&W"])
        XCTAssertEqual(OrbitalViewportSpeakerShape.allCases, [.prism, .sphere])
    }

    func testOrbitalViewportUsesOrbisonicControlMetrics() {
        XCTAssertEqual(OrbitalViewportLabTheme.panelRadius, 8)
        XCTAssertEqual(OrbitalViewportLabTheme.controlRadius, 7)
        XCTAssertEqual(OrbitalViewportLabTheme.controlHeight, 34)
        XCTAssertEqual(OrbitalViewportLabTheme.controlFontSize, 12)
        XCTAssertEqual(OrbitalViewportLabTheme.switchColumnWidth, 54)
        XCTAssertEqual(OrbitalViewportLabTheme.toggleRowHeight, 30)
        XCTAssertTrue(OrbitalViewportLabSlider.rendersSingleTrack)
        XCTAssertFalse(OrbitalViewportLabSlider.showsInlineValue)
    }

    func testOrbitalViewportWindowExportAndSceneTuningConstants() {
        XCTAssertEqual(OrbitalViewportPNGExporter.exportScope, "application-window")
        XCTAssertFalse(OrbitalViewportPNGExporter.exportsTransparentViewportOnly)
        XCTAssertEqual(OrbitalViewportSceneMetrics.speakerLabelFontPointSize, OrbitalViewportLabTheme.controlFontSize)
        XCTAssertEqual(OrbitalViewportSceneMetrics.shellStrutScale, 1.5, accuracy: 0.000_001)
        XCTAssertEqual(OrbitalViewportSceneMetrics.shellStrutRadius, 0.0036, accuracy: 0.000_001)
        XCTAssertEqual(OrbitalViewportSceneMetrics.shellEquatorStrutRadius, 0.0048, accuracy: 0.000_001)
    }

    func testOrbitalViewportOrbitStateUsesCameraOrbitAndStableSpin() {
        let isometric = OrbitalViewportOrbitState.preset(.isometric)
        XCTAssertEqual(isometric.yaw, 0, accuracy: 0.000_001)
        XCTAssertEqual(isometric.pitch, 0, accuracy: 0.000_001)
        XCTAssertEqual(isometric.cameraPosition.length, OrbitalViewportOrbitState.defaultDistance, accuracy: 0.000_001)

        let dragged = isometric.applyingDrag(translation: CGSize(width: 20, height: -10))
        XCTAssertEqual(dragged.yaw, isometric.yaw - 0.12, accuracy: 0.000_001)
        XCTAssertEqual(dragged.pitch, isometric.pitch + 0.06, accuracy: 0.000_001)

        let spun = isometric.spinning(deltaMS: 1_000)
        XCTAssertEqual(spun.yaw, isometric.yaw - 0.075, accuracy: 0.000_001)
        XCTAssertEqual(spun.pitch, isometric.pitch, accuracy: 0.000_001)
    }

    func testOrbitalViewportFrameConfigurationMovesSpinWithoutRootTimeline() {
        let configuration = makeRenderConfiguration(
            timeMS: 1_000,
            yaw: 0.4,
            spin: true,
            spinStartYaw: 0.4,
            spinStartTimeMS: 1_000
        )
        let frame = configuration.frameConfiguration(timeMS: 2_000)

        XCTAssertEqual(frame.timeMS, 2_000)
        XCTAssertEqual(frame.yaw, 0.4 - OrbitalViewportOrbitState.spinRadiansPerMS * 1_000, accuracy: 0.000_001)
        XCTAssertEqual(frame.pitch, configuration.pitch)
    }

    func testOrbitalViewportUpdateKeysKeepMeterTicksOutOfStaticGeometry() {
        let base = makeRenderConfiguration(timeMS: 1_000)
        let meterOnly = base.frameConfiguration(timeMS: 1_200)

        XCTAssertEqual(OrbitalViewportShellUpdateKey(configuration: base), OrbitalViewportShellUpdateKey(configuration: meterOnly))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: meterOnly))
        XCTAssertEqual(OrbitalViewportSpeakerVisibilityUpdateKey(configuration: base), OrbitalViewportSpeakerVisibilityUpdateKey(configuration: meterOnly))
        XCTAssertNotEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: meterOnly))
    }

    func testOrbitalViewportGeometryKeyChangesOnlyForShapeOrSpeakerSize() {
        let base = makeRenderConfiguration(timeMS: 1_000, speakerShape: .prism, speakerSize: 1.0)
        let meterOnly = makeRenderConfiguration(timeMS: 1_200, speakerShape: .prism, speakerSize: 1.0)
        let shapeChange = makeRenderConfiguration(timeMS: 1_000, speakerShape: .sphere, speakerSize: 1.0)
        let sizeChange = makeRenderConfiguration(timeMS: 1_000, speakerShape: .prism, speakerSize: 1.2)

        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: meterOnly))
        XCTAssertNotEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: shapeChange))
        XCTAssertNotEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: sizeChange))
    }

    #if os(macOS)
    func testOrbitalViewportCoordinatorRebuildsSpeakersOnlyForShapeOrSize() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let initialShellBuilds = coordinator.shellBuildCount
        let initialSpeakerRebuilds = coordinator.speakerRebuildCount
        let defaultSize = OrbitalViewportMath.speakerSize(fromSlider: 50)
        let base = makeRenderConfiguration(timeMS: 1_000, speakerShape: .prism, speakerSize: defaultSize)

        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )
        XCTAssertEqual(coordinator.shellBuildCount, initialShellBuilds)
        XCTAssertEqual(coordinator.speakerRebuildCount, initialSpeakerRebuilds)

        let meterOnly = base.frameConfiguration(timeMS: 1_200)
        coordinator.update(
            configuration: meterOnly,
            snapshot: OrbitalViewportSnapshot(configuration: meterOnly)
        )
        XCTAssertEqual(coordinator.shellBuildCount, initialShellBuilds)
        XCTAssertEqual(coordinator.speakerRebuildCount, initialSpeakerRebuilds)

        let shapeChange = makeRenderConfiguration(timeMS: 1_200, speakerShape: .sphere, speakerSize: defaultSize)
        coordinator.update(
            configuration: shapeChange,
            snapshot: OrbitalViewportSnapshot(configuration: shapeChange)
        )
        XCTAssertEqual(coordinator.speakerRebuildCount, initialSpeakerRebuilds + 1)

        let sizeChange = makeRenderConfiguration(timeMS: 1_200, speakerShape: .sphere, speakerSize: defaultSize * 1.1)
        coordinator.update(
            configuration: sizeChange,
            snapshot: OrbitalViewportSnapshot(configuration: sizeChange)
        )
        XCTAssertEqual(coordinator.speakerRebuildCount, initialSpeakerRebuilds + 2)
    }
    #endif

    func testOrbitalViewportSpinMovesEveryPresetHorizontallyInScreenSpace() {
        for view in OrbitalViewportCameraView.allCases {
            let state = OrbitalViewportOrbitState.preset(view)
            let spun = state.spinning(deltaMS: 1_000)
            let movement = spun.cameraPosition - state.cameraPosition

            XCTAssertGreaterThan(movement.length, 0.001, "\(view.title) should move while spinning")
            XCTAssertEqual(
                movement.dot(state.cameraBasis.up),
                0,
                accuracy: 0.000_001,
                "\(view.title) spin should not move along the screen-vertical axis"
            )
        }
    }

    func testOrbitalViewportMouseWheelZoomDirectionIsSwapped() {
        XCTAssertEqual(OrbitalViewportMath.zoomDelta(forScrollDeltaY: 4), 1)
        XCTAssertEqual(OrbitalViewportMath.zoomDelta(forScrollDeltaY: -4), -1)
    }

    func testOrbitalViewportFogZeroIsHardDisabledAndHiddenLinesIgnoreFog() {
        let disabled = OrbitalViewportFogConfiguration.make(
            density: 0,
            cameraDistance: OrbitalViewportOrbitState.defaultDistance
        )

        XCTAssertFalse(disabled.isEnabled)
        XCTAssertEqual(disabled.normalizedDensity, 0)
        XCTAssertEqual(disabled.startDistance, OrbitalViewportFogConfiguration.disabledStartDistance)
        XCTAssertEqual(disabled.endDistance, OrbitalViewportFogConfiguration.disabledEndDistance)
        XCTAssertEqual(disabled.densityExponent, 1)

        var configuration = OrbitalViewportRenderConfiguration(
            size: CGSize(width: 972, height: 804),
            timeMS: 1200,
            yaw: 0,
            pitch: 0,
            cameraView: .isometric,
            zoom: 1,
            renderStyle: .purple,
            speakerShape: .prism,
            speakerSize: 1.95,
            fogDensity: 0,
            showSpeakerNumbers: false,
            showHiddenLines: true,
            selectedChannel: nil
        )
        XCTAssertFalse(configuration.fogConfiguration.isEnabled)
        XCTAssertTrue(configuration.hiddenLinesVisible)
        XCTAssertEqual(configuration.foggedAlpha(depth: -1, baseAlpha: 0.42), 0.42)

        let unfoggedDefault = OrbitalViewportRenderConfiguration(
            size: configuration.size,
            timeMS: configuration.timeMS,
            yaw: configuration.yaw,
            pitch: configuration.pitch,
            cameraView: configuration.cameraView,
            zoom: configuration.zoom,
            renderStyle: configuration.renderStyle,
            speakerShape: configuration.speakerShape,
            speakerSize: configuration.speakerSize,
            fogDensity: 0,
            showSpeakerNumbers: configuration.showSpeakerNumbers,
            showHiddenLines: false,
            selectedChannel: configuration.selectedChannel
        )
        XCTAssertFalse(unfoggedDefault.shellEdgeVisible(startDepth: -0.9, endDepth: -0.8))

        configuration = OrbitalViewportRenderConfiguration(
            size: configuration.size,
            timeMS: configuration.timeMS,
            yaw: configuration.yaw,
            pitch: configuration.pitch,
            cameraView: configuration.cameraView,
            zoom: configuration.zoom,
            renderStyle: configuration.renderStyle,
            speakerShape: configuration.speakerShape,
            speakerSize: configuration.speakerSize,
            fogDensity: 100,
            showSpeakerNumbers: configuration.showSpeakerNumbers,
            showHiddenLines: true,
            selectedChannel: configuration.selectedChannel
        )
        XCTAssertTrue(configuration.fogConfiguration.isEnabled)
        XCTAssertTrue(configuration.hiddenLinesVisible)

        let foggedDefault = OrbitalViewportRenderConfiguration(
            size: configuration.size,
            timeMS: configuration.timeMS,
            yaw: configuration.yaw,
            pitch: configuration.pitch,
            cameraView: configuration.cameraView,
            zoom: configuration.zoom,
            renderStyle: configuration.renderStyle,
            speakerShape: configuration.speakerShape,
            speakerSize: configuration.speakerSize,
            fogDensity: 30,
            showSpeakerNumbers: configuration.showSpeakerNumbers,
            showHiddenLines: false,
            selectedChannel: configuration.selectedChannel
        )
        XCTAssertTrue(foggedDefault.shellEdgeVisible(startDepth: -0.9, endDepth: -0.8))
        XCTAssertGreaterThan(foggedDefault.shellDepthAlpha(startDepth: -0.9, endDepth: -0.8), 0)
        XCTAssertLessThan(
            foggedDefault.speakerAlpha(depth: -0.9, selected: false),
            foggedDefault.speakerAlpha(depth: 0.6, selected: false)
        )
        XCTAssertLessThan(
            foggedDefault.speakerEmissionScale(depth: -0.9),
            foggedDefault.speakerEmissionScale(depth: 0.6)
        )
    }

    func testOrbitalViewportPNGExportTargetsDesktopWithPNGName() {
        let desktop = URL(fileURLWithPath: "/Users/example/Desktop", isDirectory: true)
        let date = Date(timeIntervalSince1970: 1_798_588_800)
        let url = OrbitalViewportPNGExporter.destinationURL(
            style: .purple,
            date: date,
            desktopDirectory: desktop
        )

        XCTAssertEqual(url.deletingLastPathComponent(), desktop)
        XCTAssertEqual(url.pathExtension, "png")
        XCTAssertTrue(url.lastPathComponent.hasPrefix("Orbital View VU Kit "))
        XCTAssertTrue(url.lastPathComponent.contains("Purple"))
    }

    #if os(macOS)
    func testOrbitalViewportPNGExporterEncodesCGBackedImages() throws {
        let image = NSImage(size: NSSize(width: 12, height: 12))
        image.lockFocus()
        NSColor.black.setFill()
        NSRect(x: 0, y: 0, width: 12, height: 12).fill()
        image.unlockFocus()

        let png = try XCTUnwrap(OrbitalViewportPNGExporter.pngData(from: image))
        XCTAssertGreaterThan(png.count, 0)
        let bitmap = try XCTUnwrap(NSBitmapImageRep(data: png))
        XCTAssertFalse(bitmap.hasAlpha)
    }
    #endif

    func testOrbitalViewportSnapshotUsesThirtyFeySpeakersAndMeterStream() {
        let configuration = OrbitalViewportRenderConfiguration(
            size: CGSize(width: 972, height: 804),
            timeMS: 1200,
            yaw: 0,
            pitch: 0,
            cameraView: .isometric,
            zoom: 1,
            renderStyle: .purple,
            speakerShape: .prism,
            speakerSize: 1.95,
            fogDensity: 30,
            showSpeakerNumbers: false,
            showHiddenLines: false,
            selectedChannel: nil
        )
        let snapshot = OrbitalViewportSnapshot(configuration: configuration)

        XCTAssertEqual(snapshot.speakers.count, 30)
        XCTAssertEqual(snapshot.speakers.map(\.channel), Array(1...30))
        XCTAssertEqual(snapshot.speakers.first?.label, "Fey 01")
        XCTAssertTrue(snapshot.activeCount >= 0)
        XCTAssertTrue(snapshot.peakSpeaker.peak >= snapshot.peakSpeaker.rms)
    }

    func testOrbitalViewInitializesWithBindings() throws {
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let diagnostics = OrbitalViewInputDiagnostics(missingChannels: [2])
        let view = OrbitalView(
            scene: scene,
            inputDiagnostics: diagnostics,
            camera: .constant(camera),
            selection: .constant(nil)
        )

        XCTAssertEqual(view.scene, scene)
        XCTAssertNil(view.meters)
        XCTAssertNil(view.objectFrames)
        XCTAssertNil(view.objectMeters)
        XCTAssertEqual(view.objectVisualSettings, .default)
        XCTAssertEqual(view.inputDiagnostics, diagnostics)
        XCTAssertFalse(view.showsMeterSettingsTray)
        XCTAssertNil(view.visualPresetStore)
    }

    func testOrbitalViewSettingsInitializerOptsIntoTray() throws {
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let settings = try SpeakerMeterVisualSettings(visualGainDB: 3, style: .coolPulse)
        let diagnostics = OrbitalViewInputDiagnostics(extraChannels: [31])
        let store = InMemoryVisualPresetStore()
        let view = OrbitalView(
            scene: scene,
            meters: nil,
            inputDiagnostics: diagnostics,
            visualPresetStore: store,
            meterVisualSettings: .constant(settings),
            camera: .constant(camera),
            selection: .constant(nil)
        )

        XCTAssertEqual(view.scene, scene)
        XCTAssertEqual(view.inputDiagnostics, diagnostics)
        XCTAssertTrue(view.showsMeterSettingsTray)
        XCTAssertNotNil(view.visualPresetStore)
    }

    func testVisualPresetControllerUsesOptionalStoreAndKeepsPersistenceOptional() throws {
        let controllerWithoutStore = OrbitalViewVisualPresetController(store: nil)
        XCTAssertNil(try controllerWithoutStore.saveAsDefault(settings: .default))
        XCTAssertNil(try controllerWithoutStore.savePreset(displayName: "Ignored", settings: .default))
        XCTAssertNil(try controllerWithoutStore.loadPreset())
        XCTAssertEqual(try controllerWithoutStore.resetToFactory(), .default)

        let store = InMemoryVisualPresetStore()
        let controller = OrbitalViewVisualPresetController(store: store)
        let customSettings = try SpeakerMeterVisualSettings(
            visualGainDB: 4,
            style: .cubeScalarCenterBloom,
            colorScheme: .daftPunkBow,
            speakerZScale: 1.8,
            bloomMin: 0.1,
            bloomMax: 0.88,
            bloomEdge: 0.2,
            responseCurve: 0.9,
            peakHoldSeconds: 0.45,
            releaseMemory: 0.4,
            hotFill: 0.92,
            facePixels: 14,
            showsDiagnostics: true
        )

        let defaultPreset = try XCTUnwrap(controller.saveAsDefault(settings: customSettings))
        XCTAssertEqual(defaultPreset.id, "default-music")
        XCTAssertEqual(defaultPreset.displayName, "Default Music")
        XCTAssertEqual(store.savedPreset, defaultPreset)

        let customPreset = try XCTUnwrap(controller.savePreset(displayName: "  Stage Bow  ", settings: customSettings))
        XCTAssertEqual(customPreset.id, "stage-bow")
        XCTAssertEqual(customPreset.displayName, "Stage Bow")
        XCTAssertEqual(try controller.loadPreset(), customPreset)
        XCTAssertEqual(try controller.resetToSavedDefault(), customPreset)

        XCTAssertEqual(try controller.resetToFactory(), .default)
        XCTAssertTrue(store.didReset)
    }

    func testDiagnosticsSummaryReportsMissingExtraAndSanitizedChannels() {
        let diagnostics = OrbitalViewInputDiagnostics(
            missingChannels: [2, 4],
            extraChannels: [31],
            invalidChannels: [0],
            duplicateChannels: [3],
            replacedValues: [
                OrbitalViewInputDiagnostics.ValueReplacement(channel: 1, field: "rms", replacement: 0)
            ],
            clampedValues: [
                OrbitalViewInputDiagnostics.ValueClamp(channel: 5, field: "peak", original: 1.7, clamped: 1)
            ],
            timestampReplaced: true
        )

        XCTAssertEqual(
            OrbitalViewInputDiagnosticsSummary.lines(for: diagnostics),
            [
                "Missing channels: 2, 4",
                "Extra channels: 31",
                "Invalid channels: 0",
                "Duplicate channels: 3",
                "Sanitized values: 1 replaced",
                "Sanitized values: 1 clamped",
                "Timestamp fallback used."
            ]
        )
        XCTAssertEqual(
            OrbitalViewInputDiagnosticsSummary.lines(for: .empty),
            ["No channel diagnostics."]
        )
    }

    func testCoordinatorAppliesConfigurationWithoutRepeatedStructuralUpdates() throws {
        let coordinator = OrbitalViewMetalView.Coordinator(renderer: OrbitalViewMetalRenderer())
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let firstFrame = try SpeakerMeterFrame(
            timestamp: 1,
            levelsByChannel: [
                1: SpeakerMeterLevel(rms: 0.2, peak: 0.3, clip: false)
            ]
        )
        let configuration = OrbitalViewRenderConfiguration(
            scene: scene,
            meters: firstFrame,
            meterVisualSettings: .default,
            objectFrames: nil,
            objectMeters: nil,
            objectVisualSettings: .default,
            camera: camera,
            selection: nil
        )

        _ = coordinator.apply(configuration)
        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 1)

        _ = coordinator.apply(configuration)
        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 1)

        let secondFrame = try SpeakerMeterFrame(
            timestamp: 2,
            levelsByChannel: [
                1: SpeakerMeterLevel(rms: 0.5, peak: 0.7, clip: false)
            ]
        )
        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: secondFrame,
                meterVisualSettings: .default,
                objectFrames: nil,
                objectMeters: nil,
                objectVisualSettings: .default,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 2)
    }

    func testCoordinatorAppliesMeterVisualSettingsWithoutReloadingScene() throws {
        let coordinator = OrbitalViewMetalView.Coordinator(renderer: OrbitalViewMetalRenderer())
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let initialSettings = SpeakerMeterVisualSettings.default
        let boostedSettings = try SpeakerMeterVisualSettings(visualGainDB: 6, style: .warmPulse)

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: initialSettings,
                objectFrames: nil,
                objectMeters: nil,
                objectVisualSettings: .default,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterVisualSettingsRevision, 0)

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: boostedSettings,
                objectFrames: nil,
                objectMeters: nil,
                objectVisualSettings: .default,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.scene, scene)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 0)
        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterVisualSettings, boostedSettings)
        XCTAssertEqual(coordinator.renderer.renderState.meterVisualSettingsRevision, 1)
    }

    func testCoordinatorForwardsObjectStateWithoutReloadingScene() throws {
        let coordinator = OrbitalViewMetalView.Coordinator(renderer: OrbitalViewMetalRenderer())
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let objectFrames = try OrbitalViewObjectFrameSet(
            timestamp: 1,
            activeObjects: [
                OrbitalViewObjectFrame(
                    objectID: 3,
                    label: "Object 3",
                    pose: UnitSphereDirection(x: 1, y: 0, z: 0)
                )
            ]
        )
        let objectMeters = try ObjectMeterFrame(
            timestamp: 1,
            levelsByObjectID: [
                3: ObjectMeterLevel(rms: 0.2, peak: 0.8, clip: false)
            ]
        )
        let objectSettings = try ObjectVisualSettings(trailsEnabled: true, maxTrailPointsPerObject: 8)

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: .default,
                objectFrames: objectFrames,
                objectMeters: objectMeters,
                objectVisualSettings: objectSettings,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.scene, scene)
        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.objectFrames, objectFrames)
        XCTAssertEqual(coordinator.renderer.renderState.objectMeters, objectMeters)
        XCTAssertEqual(coordinator.renderer.renderState.objectVisualSettings, objectSettings)
        XCTAssertEqual(coordinator.renderer.renderState.objectFrameRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.objectMeterRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.objectVisualSettingsRevision, 1)

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: .default,
                objectFrames: objectFrames,
                objectMeters: objectMeters,
                objectVisualSettings: objectSettings,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.objectFrameRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.objectMeterRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.objectVisualSettingsRevision, 1)
    }

    func testCoordinatorEmitsCameraAndSelectionEvents() throws {
        let coordinator = OrbitalViewMetalView.Coordinator(renderer: OrbitalViewMetalRenderer())
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.frontElevation)
        let selection = OrbitalViewSelection(id: .speaker("speaker-1"))

        let events = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: .default,
                objectFrames: nil,
                objectMeters: nil,
                objectVisualSettings: .default,
                camera: camera,
                selection: selection
            )
        )

        XCTAssertEqual(events, [.cameraChanged(camera), .selected(selection)])
        XCTAssertEqual(coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: .default,
                objectFrames: nil,
                objectMeters: nil,
                objectVisualSettings: .default,
                camera: camera,
                selection: selection
            )
        ), [])
    }

    private func makeScene() throws -> OrbitalViewSceneSpec {
        let direction = try UnitSphereDirection(x: 1, y: 0, z: 0)
        let speaker = try OrbitalViewSpeaker(
            id: "speaker-1",
            channel: 1,
            label: "Fey 01",
            anchor: .direction(direction, offsetM: 0.05),
            shape: try SpeakerShape.sonicSphereDefault()
        )

        return try OrbitalViewSceneBuilder.makeMonitorScene(
            id: "swiftui-test",
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
            speakers: [speaker]
        )
    }

    private func makeRenderConfiguration(
        size: CGSize = CGSize(width: 972, height: 804),
        timeMS: Double = 1_200,
        yaw: Double = 0,
        pitch: Double = 0,
        cameraView: OrbitalViewportCameraView = .isometric,
        zoom: Double = 1,
        renderStyle: OrbitalViewportRenderStyle = .purple,
        speakerShape: OrbitalViewportSpeakerShape = .prism,
        speakerSize: Double = 1.95,
        fogDensity: Double = 30,
        showSpeakerNumbers: Bool = false,
        showHiddenLines: Bool = false,
        selectedChannel: Int? = nil,
        spin: Bool = false,
        spinStartYaw: Double = 0,
        spinStartTimeMS: Double = 0
    ) -> OrbitalViewportRenderConfiguration {
        OrbitalViewportRenderConfiguration(
            size: size,
            timeMS: timeMS,
            yaw: yaw,
            pitch: pitch,
            cameraView: cameraView,
            zoom: zoom,
            renderStyle: renderStyle,
            speakerShape: speakerShape,
            speakerSize: speakerSize,
            fogDensity: fogDensity,
            showSpeakerNumbers: showSpeakerNumbers,
            showHiddenLines: showHiddenLines,
            selectedChannel: selectedChannel,
            spin: spin,
            spinStartYaw: spinStartYaw,
            spinStartTimeMS: spinStartTimeMS
        )
    }
}

private final class InMemoryVisualPresetStore: OrbitalViewVisualPresetStore, @unchecked Sendable {
    private(set) var savedPreset: OrbitalViewVisualPreset?
    private(set) var didReset = false

    func loadVisualPreset() throws -> OrbitalViewVisualPreset? {
        savedPreset
    }

    func saveVisualPreset(_ preset: OrbitalViewVisualPreset) throws {
        savedPreset = preset
    }

    func resetVisualPreset() throws {
        savedPreset = nil
        didReset = true
    }
}
