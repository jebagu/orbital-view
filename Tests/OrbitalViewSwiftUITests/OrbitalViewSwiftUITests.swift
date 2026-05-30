import MetalKit
import SwiftUI
import XCTest
#if os(macOS)
import AppKit
import SceneKit
#endif
@testable import OrbitalViewCore
@testable import OrbitalViewRender
@testable import OrbitalViewReview
@testable import OrbitalViewSpatGRIS
@testable import OrbitalViewSwiftUI
@testable import OrbitalViewTelemetry

final class OrbitalViewSwiftUITests: XCTestCase {
    func testCorrectViewerKeepsNativeSceneKitViewportContract() {
        let view = OrbitalViewportMockup()

        XCTAssertNotNil(view)
        XCTAssertTrue(OrbitalViewportMockup.correctReviewAppName.contains("Orbital View 1.0"))
        XCTAssertTrue(OrbitalViewportMockup.correctReviewAppName.contains("Native SceneKit Review App"))
        XCTAssertTrue(OrbitalViewportMockup.correctReviewAppName.contains("Preserved Control Rail"))
        XCTAssertEqual(OrbitalViewportMockup.sourceMockupPath, "mockups/orbital-view-viewport/index.html")
        XCTAssertEqual(OrbitalViewportMockup.controlSkinSource, "orbisonic-design-language")
        XCTAssertEqual(OrbitalViewportMockup.nativeDefaultWindowSize, CGSize(width: 1180, height: 760))
        XCTAssertEqual(OrbitalViewportMockup.leftRailWidth, 268)
        XCTAssertEqual(OrbitalViewportMockup.leftRailWindowEdgeInset, 18)
        XCTAssertEqual(OrbitalViewportMockup.leftRailTitleText, "Orbital View")
        XCTAssertEqual(OrbitalViewportMockup.leftRailTitleFontSource, "Wavefield Receiver PlayerPanelView title")
        XCTAssertEqual(OrbitalViewportMockup.leftRailTitleFontPointSize, 16)
        XCTAssertEqual(OrbitalViewportMockup.leftRailTitleFontWeight, "black")
        XCTAssertEqual(OrbitalViewportMockup.leftRailDesktopHeightPolicy, "full-height-desktop-rail")
        XCTAssertEqual(OrbitalViewportMockup.inspectorWidth, 300)
        XCTAssertFalse(OrbitalViewportMockup.usesRootAnimationTimeline)
        XCTAssertEqual(OrbitalViewportMockup.tuningTrayHitTargetPattern, "full-width-header-button")
        XCTAssertEqual(OrbitalViewportMockup.viewportAnimationFramesPerSecond, 120)
        XCTAssertEqual(OrbitalViewportMockup.meterOnlyViewportFramesPerSecond, 30)
        XCTAssertEqual(OrbitalViewportMockup.inspectorRefreshFramesPerSecond, 10)
        XCTAssertEqual(OrbitalViewportMockup.fpsMeterLocation, "viewport-bottom-right")
        XCTAssertEqual(OrbitalViewportMockup.fpsMeterTargetFramesPerSecond, 120)
        XCTAssertEqual(OrbitalViewportMockup.fpsMeterUnderTargetFramesPerSecond, 60)
        XCTAssertEqual(OrbitalViewportMockup.fpsMeterLogSamplesPerSecond, 5)
        #if os(macOS)
        XCTAssertEqual(OrbitalViewport3DSceneView.antialiasingMode, .none)
        #endif
        XCTAssertEqual(OrbitalViewportMockup.speakerCount, 30)
        XCTAssertEqual(OrbitalViewportMockup.rightPanelPurpose, "tuning-debug-panel")
    }

    func testCorrectViewerUsesExportedSettingsFileAsStartupDefaults() {
        let settings = OrbitalViewportMockup.defaultCubeVUSettings

        XCTAssertEqual(
            OrbitalViewportMockup.defaultSettingsSourceFileName,
            "Orbital View Settings 2026-05-21-171537.json"
        )
        XCTAssertEqual(OrbitalViewportMockup.defaultRenderStyle, .purple)
        XCTAssertEqual(OrbitalViewportMockup.defaultGeodesicRenderStyle, .purple)
        XCTAssertEqual(OrbitalViewportMockup.defaultGeodesicSaturation, 0)
        XCTAssertFalse(OrbitalViewportMockup.defaultShowRibbedSpeakerSphere)
        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereGeometry.thicknessRange.lowerBound, 0.70, accuracy: 0.000_001)
        XCTAssertEqual(OrbitalViewportMockup.defaultRibbedSphereThickness, 1, accuracy: 0.000_001)
        XCTAssertEqual(OrbitalViewportMockup.defaultRibbedSphereVerticalRibs, 16)
        XCTAssertEqual(OrbitalViewportMockup.defaultRibbedSphereHorizontalRings, 8)
        XCTAssertEqual(OrbitalViewportMockup.defaultSpeakerShape, .cubeVU)
        XCTAssertEqual(OrbitalViewportMockup.defaultViewportFrameRate, .oneTwenty)
        XCTAssertEqual(OrbitalViewportMockup.defaultCubeVUPreset, .hotCoreBloom)
        XCTAssertEqual(OrbitalViewportMockup.defaultSourceMode, .telemetry)
        XCTAssertEqual(OrbitalViewportMockup.defaultVUDriveMode, .impulseRipple)
        XCTAssertEqual(settings.bloomEdge, 0.18, accuracy: 0.000_001)
        XCTAssertEqual(settings.bloomMax, 0.98, accuracy: 0.000_001)
        XCTAssertEqual(settings.bloomMin, 0.11, accuracy: 0.000_001)
        XCTAssertEqual(settings.checkerContrast, 0.08, accuracy: 0.000_001)
        XCTAssertEqual(settings.cubeOutlineStrength, 0.64, accuracy: 0.000_001)
        XCTAssertEqual(settings.displayCeiling, 1, accuracy: 0.000_001)
        XCTAssertEqual(settings.facePixels, 9)
        XCTAssertEqual(settings.hotFillStrength, 0.94, accuracy: 0.000_001)
        XCTAssertEqual(settings.hotResponse, 2.25, accuracy: 0.000_001)
        XCTAssertEqual(settings.hotThreshold, 0.58, accuracy: 0.000_001)
        XCTAssertEqual(settings.idleTint, 0.12, accuracy: 0.000_001)
        XCTAssertEqual(settings.inputCalibration, 1, accuracy: 0.000_001)
        XCTAssertEqual(settings.levelCompression, 1, accuracy: 0.000_001)
        XCTAssertEqual(settings.paletteDrive, 2, accuracy: 0.000_001)
        XCTAssertEqual(settings.pixelFill, 0.86, accuracy: 0.000_001)
        XCTAssertEqual(settings.responseCurve, 0.72, accuracy: 0.000_001)
        XCTAssertEqual(settings.rimHaloEdge, 0.12, accuracy: 0.000_001)
        XCTAssertEqual(settings.speakerHeight, 1, accuracy: 0.000_001)
        XCTAssertEqual(settings.surfaceCheckerOpacity, 0, accuracy: 0.000_001)
    }

    func testCorrectViewerKeepsLeftRailFocusedAndMovesTuningTraysRight() {
        XCTAssertEqual(
            OrbitalViewportMockup.leftRailSectionTitles,
            ["Camera", "View Detail"]
        )
        XCTAssertEqual(OrbitalViewportMockup.leftRailCameraPanelPlacement, "top-aligned-under-title")
        XCTAssertEqual(
            OrbitalViewportMockup.sourceSelectorControlTitles,
            ["Telemetry", "Local Song", "Impulse Test"]
        )
        XCTAssertEqual(OrbitalViewportMockup.inputSectionHeaderTitle, "Sound Metering Input")
        XCTAssertEqual(OrbitalViewportMockup.inputTrayTitle, "Input")
        XCTAssertEqual(
            OrbitalViewportMockup.inputTrayControlTitles,
            [
                "Telemetry",
                "Local Song",
                "Impulse Test",
                "Provider",
                "Status",
                "Track",
                "Choose File",
                "Play",
                "Pause",
                "Render Type",
                "Ripple",
                "Waves",
                "Orbiting Comets",
                "Selected Source",
                "Telemetry Status",
                "Displayed Meter",
                "Active Meter",
                "Music Render",
                "Music Source",
                "Impulse Pattern"
            ]
        )
        XCTAssertEqual(OrbitalViewportMockup.telemetryTrayControlTitles, ["Provider", "Status", "Track"])
        XCTAssertEqual(
            OrbitalViewportMockup.localSongTrayControlTitles,
            ["Choose File", "Play", "Pause", "Render Type"]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.impulseTestTrayControlTitles,
            ["Ripple", "Waves", "Orbiting Comets"]
        )
        XCTAssertEqual(OrbitalViewportCameraView.allCases.map(\.title), ["Plan", "Elevation", "Isometric"])
        XCTAssertEqual(
            OrbitalViewportRenderStyle.allCases.map(\.title),
            [
                "Purple",
                "Flamingo",
                "Green",
                "B&W",
                "Daft Punk Bow",
                "Rack Mint",
                "Rack Pink",
                "Rack Blue",
                "Ember Console",
                "Graphite",
                "Flamingo Green",
                "Dusty Rose"
            ]
        )
        XCTAssertEqual(OrbitalViewportMockup.themeControlPattern, "full-width-orbisonic-theme-buttons")
        XCTAssertEqual(OrbitalViewportMockup.themePaletteSource, "orbisonic-palette-brief")
        XCTAssertEqual(
            OrbitalViewportMockup.colorPaletteControlTitles,
            ["Sonic Sphere Speaker Palette", "Source Speaker Palette", "App Skin", "Cube VU Ramp"]
        )
        XCTAssertEqual(OrbitalViewportMockup.globalDiceButtonStyle, "icon-only-centered-dice")
        XCTAssertEqual(
            OrbitalViewportMockup.viewDetailControlTitles,
            ["Speaker Size", "Fog Density", "Speaker Numbers", "Hidden Lines"]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.geodesicAppearanceControlTitles,
            [
                "Geodesic Palette",
                "Geodesic Saturation"
            ]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.sphereGeometryControlTitles,
            [
                "Ribbed Speaker Sphere",
                "Rib Thickness",
                "Vertical Ribs",
                "Horizontal Rings"
            ]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.groundAppearanceControlTitles,
            ["Ground Palette", "Grid Plane", "Grid Visibility", "Grid Spacing", "Grid Size"]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.audioRenderTypeTitles,
            ["All Mono", "Excite Ripple", "Excite Waves", "Excite Comets"]
        )
        XCTAssertEqual(OrbitalViewportSpeakerShape.allCases.map(\.title), ["Prism", "Sphere", "Cube VU"])
        XCTAssertEqual(OrbitalViewportFrameRate.allCases.map(\.title), ["30 FPS", "60 FPS", "120 FPS"])
        XCTAssertEqual(
            OrbitalViewportMockup.tuningTrayTitles,
            [
                "Input",
                "Sonic Sphere Speakers",
                "Source Speakers",
                "Roll the dice on looks",
                "Saved Themes",
                "Speaker Shape",
                "Speaker Pattern",
                "Label Font",
                "Sonic Sphere Speaker Palette",
                "Source Speaker Palette",
                "Cube Surface",
                "Bloom Style",
                "Sphere Geometry",
                "Geodesic Appearance",
                "Ground Appearance",
                "Meter Response",
                "Performance",
                "Diagnostics"
            ]
        )
        XCTAssertEqual(OrbitalViewportMockup.defaultExpandedRightPanelTrayTitles, [])
        XCTAssertEqual(
            OrbitalViewportMockup.tuningTrayTitles.filter(OrbitalViewportMockup.defaultRightPanelTrayExpanded),
            []
        )
        XCTAssertFalse(OrbitalViewportMockup.defaultRightPanelTrayExpanded(OrbitalViewportMockup.inputTrayTitle))
        XCTAssertFalse(OrbitalViewportMockup.defaultRightPanelTrayExpanded(OrbitalViewportMockup.speakerLayoutTrayTitle))
        XCTAssertFalse(OrbitalViewportMockup.defaultRightPanelTrayExpanded(OrbitalViewportMockup.sourceLayoutTrayTitle))
        XCTAssertEqual(
            OrbitalViewportMockup.rightPanelSectionTitles,
            ["Sound Metering Input", "Speaker and Source Layout", "Roll the dice on looks", "Theme", "Speaker Appearance", "Sphere Appearance", "Ground Appearance", "Meter Behavior", "Diagnostics"]
        )
        XCTAssertEqual(OrbitalViewportMockup.futureWorkTrayTitles, ["Speaker Pattern"])
        XCTAssertEqual(OrbitalViewportMockup.futureWorkLabel, "Future work")
        XCTAssertEqual(OrbitalViewportMockup.viewThemeDirectoryName, "View Themes")
        XCTAssertEqual(
            OrbitalViewportMockup.viewThemeTrayControlTitles,
            ["Save Theme", "Refresh Themes", "Load", "Set Default"]
        )
        XCTAssertEqual(OrbitalViewportMockup.speakerSourceLayoutSectionTitle, "Speaker and Source Layout")
        XCTAssertEqual(OrbitalViewportMockup.speakerLayoutTrayTitle, "Sonic Sphere Speakers")
        XCTAssertEqual(OrbitalViewportMockup.sourceLayoutTrayTitle, "Source Speakers")
        XCTAssertEqual(OrbitalViewportMockup.speakerLayoutKickerText, "Speaker layout in SPAT XML format.")
        XCTAssertEqual(OrbitalViewportMockup.sourceLayoutKickerText, "Source speaker layout in SPAT XML format.")
        XCTAssertEqual(OrbitalViewportMockup.speakerLayoutDirectoryName, "Speaker Layouts")
        XCTAssertEqual(OrbitalViewportMockup.sourceLayoutDirectoryName, "Source Layouts")
        XCTAssertEqual(
            OrbitalViewportMockup.speakerLayoutTrayControlTitles,
            ["Import...", "Save", "Refresh", "Load", "Set Default"]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.sourceLayoutTrayControlTitles,
            ["Import Setup...", "Import Project...", "Save", "Refresh", "Listen OSC", "Load", "Set Default"]
        )
        XCTAssertEqual(OrbitalViewportMockup.spatGRISOSCAddress, "/spat/serv")
        XCTAssertEqual(OrbitalViewportMockup.spatGRISDefaultOSCPort, 18032)
        XCTAssertEqual(OrbitalViewportMockup.spatGRISOSCPortRange, "1024...65535")
        XCTAssertEqual(OrbitalViewportMockup.speakerLabelFontSizeControlTitle, "Font Size")
        XCTAssertEqual(
            OrbitalViewportMockup.diceRandomizerAccessibilityLabels,
            ["Roll the dice on looks", "Randomize Cube Surface", "Randomize Bloom Style", "Randomize Meter Response"]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.speakerLabelFontControlTitles,
            [
                "System Default",
                "Helvetica Black",
                "Futura",
                "Press Start 2P",
                "Minecraft",
                "Chintzy CPU BRK",
                "Archivo Black",
                "Jost",
                "Michroma",
                "Sevastopol Interface"
            ]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.speakerLabelFontGroupTitles,
            ["Normie", "Nerd", "Nostromo"]
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerLabelFont.fonts(in: .normie).map(\.title),
            ["System Default", "Helvetica Black", "Futura"]
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerLabelFont.fonts(in: .nerd).map(\.title),
            ["Press Start 2P", "Minecraft", "Chintzy CPU BRK"]
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerLabelFont.fonts(in: .nostromo).map(\.title),
            ["Archivo Black", "Jost", "Michroma", "Sevastopol Interface"]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.surfaceBloomControlTitles,
            [
                "Randomize Cube Surface",
                "Bloom Min",
                "Bloom Max",
                "Bloom Edge",
                "Rim Halo Edge",
                "Response Curve",
                "Face Pixels",
                "Pixel Fill",
                "Idle Tint",
                "Surface Checker Opacity",
                "Checker Contrast"
            ]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.meterResponseControlTitles,
            [
                "Randomize Meter Response",
                "Input Calibration",
                "Level Compression",
                "Display Ceiling",
                "Hot Response",
                "Hot Threshold",
                "Hot Fill Strength",
                "Palette Drive"
            ]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.bloomStyleControlTitles,
            ["Randomize Bloom Style", "Soft Center Bloom", "Hot Core Bloom", "Halo Edge Bloom", "Block Center Bloom"]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.removedPresetControlTitles,
            ["Reset Cube VU", "Export Settings JSON"]
        )
        XCTAssertEqual(
            OrbitalViewportVUDriveMode.allCases.map(\.title),
            ["Music", "Impulse Test Ripple", "Impulse Test Waves", "Impulse Test Orbiting Comets"]
        )
        XCTAssertEqual(
            OrbitalViewportVUDriveMode.impulseCases.map(\.impulseTitle),
            ["Ripple", "Waves", "Orbiting Comets"]
        )
        XCTAssertEqual(
            OrbitalViewportCubeVUPreset.allCases.map(\.title),
            ["Soft Center Bloom", "Hot Core Bloom", "Halo Edge Bloom", "Block Center Bloom"]
        )
        XCTAssertFalse(OrbitalViewportMockup.objectTuningTraysVisible)
        XCTAssertEqual(
            OrbitalViewportMockup.inactiveObjectTrayTitles,
            ["Object Overlay", "Trails", "Glow Trails", "Bounds"]
        )
        XCTAssertEqual(OrbitalViewportMockup.motionFPSControlLocation, "right-performance-tray")
        XCTAssertEqual(OrbitalViewportMockup.fpsMeterLocation, "viewport-bottom-right")
        XCTAssertEqual(OrbitalViewportMockup.fpsMeterTargetFramesPerSecond, 120)
        XCTAssertEqual(OrbitalViewportMockup.fpsMeterUnderTargetFramesPerSecond, 60)
        XCTAssertEqual(OrbitalViewportMockup.fpsMeterLogSamplesPerSecond, 5)
        XCTAssertEqual(OrbitalViewportMockup.audioSourcePosition, "right-panel-single-input-tray-above-theme")
        XCTAssertEqual(OrbitalViewportMockup.audioTransportButtonLayout, "inside-expanded-input-tray-local-song-mode")
        XCTAssertEqual(OrbitalViewportMockup.meterSourceControlLocation, "inside-right-panel-input-tray")
        XCTAssertEqual(
            OrbitalViewportMockup.removedRightPanelCards,
            ["Scene", "No speaker selected", "30-channel VU list"]
        )
    }

    func testCorrectViewerSourceSelectorSeparatesTelemetrySongAndImpulseControls() {
        XCTAssertEqual(OrbitalViewportMockup.defaultSourceMode, .telemetry)
        XCTAssertEqual(OrbitalViewportSourceMode.telemetry.trayControlTitles, ["Provider", "Status", "Track"])
        XCTAssertEqual(
            OrbitalViewportSourceMode.localSong.trayControlTitles,
            ["Choose File", "Play", "Pause", "Render Type"]
        )
        XCTAssertEqual(
            OrbitalViewportSourceMode.impulseTest.trayControlTitles,
            ["Ripple", "Waves", "Orbiting Comets"]
        )
        XCTAssertEqual(OrbitalViewportSourceMode.legacyMode(for: .music), .localSong)
        XCTAssertEqual(OrbitalViewportSourceMode.legacyMode(for: .impulseWaves), .impulseTest)

        XCTAssertEqual(
            OrbitalViewportMeterSource.telemetryNoProvider.meter(channel: 1, timeMS: 0),
            .silent
        )
        let telemetryMeters = OrbitalViewTelemetryMeterSnapshot(
            sequence: 9,
            producerHostTime: 10,
            levelsByChannel: [
                3: OrbitalViewTelemetryMeterLevel(rms: 0.25, peak: 0.75)
            ]
        )
        XCTAssertEqual(
            OrbitalViewportMeterSource.telemetry(telemetryMeters).meter(channel: 3, timeMS: 0),
            OrbitalViewportMeterSample(rms: 0.25, peak: 0.75)
        )
        XCTAssertEqual(
            OrbitalViewportMeterSource.telemetry(telemetryMeters).meter(channel: 4, timeMS: 0),
            .silent
        )
        XCTAssertEqual(
            OrbitalViewportMeterSource.localSongNoFile.meter(channel: 1, timeMS: 0),
            .silent
        )
        XCTAssertGreaterThan(
            OrbitalViewportMeterSource.impulse(.waves).meter(channel: 1, timeMS: 1_000).peak,
            0
        )
    }

    func testCorrectViewerTelemetryAdvertiserSelectionHandlesZeroOneAndManyProviders() {
        XCTAssertNil(OrbitalViewportTelemetryAdvertiserSelection.selectedAdvertiser(in: [], selectedID: nil))
        XCTAssertEqual(OrbitalViewportTelemetryAdvertiserSelection.advertiserButtonTitles(for: []), [])

        let single = [
            OrbitalViewportTelemetryAdvertiser(
                id: "orbisonic-main",
                provider: "Orbisonic Main",
                status: "Ready",
                track: "Helios"
            )
        ]
        XCTAssertEqual(
            OrbitalViewportTelemetryAdvertiserSelection.selectedAdvertiser(in: single, selectedID: nil),
            single[0]
        )
        XCTAssertEqual(OrbitalViewportTelemetryAdvertiserSelection.advertiserButtonTitles(for: single), [])

        let many = [
            single[0],
            OrbitalViewportTelemetryAdvertiser(
                id: "wavefield-sidecar",
                provider: "Wavefield Sidecar",
                status: "Live",
                track: "Cassini"
            )
        ]
        XCTAssertEqual(
            OrbitalViewportTelemetryAdvertiserSelection.selectedAdvertiser(in: many, selectedID: "wavefield-sidecar"),
            many[1]
        )
        XCTAssertEqual(
            OrbitalViewportTelemetryAdvertiserSelection.selectedAdvertiser(in: many, selectedID: "missing"),
            many[0]
        )
        XCTAssertEqual(
            OrbitalViewportTelemetryAdvertiserSelection.advertiserButtonTitles(for: many),
            ["Orbisonic Main", "Wavefield Sidecar"]
        )
    }

    func testCorrectViewerIsometricPresetUsesTrueCanonicalDirection() {
        let basis = OrbitalViewportOrbitState.preset(.isometric).cameraBasis
        let expected = OVVector3(x: 1, y: 1, z: 1).normalized()

        XCTAssertEqual(basis.viewDirection.x, expected.x, accuracy: 0.000_001)
        XCTAssertEqual(basis.viewDirection.y, expected.y, accuracy: 0.000_001)
        XCTAssertEqual(basis.viewDirection.z, expected.z, accuracy: 0.000_001)
    }

    func testCorrectViewerCameraPresetBasesAreOrthonormal() {
        for view in OrbitalViewportCameraView.allCases {
            let basis = OrbitalViewportOrbitState.preset(view).cameraBasis

            XCTAssertEqual(basis.viewDirection.length, 1, accuracy: 0.000_001, "\(view.title) view length")
            XCTAssertEqual(basis.right.length, 1, accuracy: 0.000_001, "\(view.title) right length")
            XCTAssertEqual(basis.up.length, 1, accuracy: 0.000_001, "\(view.title) up length")
            XCTAssertEqual(abs(basis.viewDirection.dot(basis.right)), 0, accuracy: 0.000_001, "\(view.title) view/right")
            XCTAssertEqual(abs(basis.viewDirection.dot(basis.up)), 0, accuracy: 0.000_001, "\(view.title) view/up")
            XCTAssertEqual(abs(basis.right.dot(basis.up)), 0, accuracy: 0.000_001, "\(view.title) right/up")
        }
    }

    func testCorrectViewerIsometricSpinKeepsCanonicalZAxisElevation() {
        let base = OrbitalViewportOrbitState.preset(.isometric)
        let spun = base.spinning(deltaMS: 2_000)

        XCTAssertNotEqual(spun.yaw, base.yaw)
        XCTAssertEqual(spun.pitch, base.pitch, accuracy: 0.000_001)
        XCTAssertEqual(spun.cameraBasis.viewDirection.z, base.cameraBasis.viewDirection.z, accuracy: 0.000_001)
        XCTAssertEqual(
            hypot(spun.cameraBasis.viewDirection.x, spun.cameraBasis.viewDirection.y),
            hypot(base.cameraBasis.viewDirection.x, base.cameraBasis.viewDirection.y),
            accuracy: 0.000_001
        )
    }

    func testCorrectViewerProjectsCanonicalXRightToScreenRight() {
        for view in OrbitalViewportCameraView.allCases {
            let preset = OrbitalViewportOrbitState.preset(view)
            let configuration = makeViewportConfiguration(
                size: CGSize(width: 1_000, height: 800),
                yaw: preset.yaw,
                pitch: preset.pitch,
                cameraView: view
            )
            let centerX = configuration.size.width * 0.5
            let right = configuration.project(configuration.rotate(OVVector3(x: 1, y: 0, z: 0)))
            let left = configuration.project(configuration.rotate(OVVector3(x: -1, y: 0, z: 0)))

            XCTAssertGreaterThan(right.x, centerX, "\(view.title) should project canonical +X to screen right")
            XCTAssertLessThan(left.x, centerX, "\(view.title) should project canonical -X to screen left")
        }
    }

    func testCorrectViewerDragUsesDomeLabOrbitDirections() {
        let base = OrbitalViewportOrbitState.preset(.isometric)
        let draggedRight = base.applyingDrag(translation: CGSize(width: 24, height: 0))
        let draggedLeft = base.applyingDrag(translation: CGSize(width: -24, height: 0))
        let draggedDown = base.applyingDrag(translation: CGSize(width: 0, height: 24))
        let draggedUp = base.applyingDrag(translation: CGSize(width: 0, height: -24))

        XCTAssertLessThan(draggedRight.yaw, base.yaw)
        XCTAssertGreaterThan(draggedLeft.yaw, base.yaw)
        XCTAssertEqual(draggedRight.pitch, base.pitch)
        XCTAssertEqual(draggedLeft.pitch, base.pitch)
        XCTAssertGreaterThan(draggedDown.pitch, base.pitch)
        XCTAssertLessThan(draggedUp.pitch, base.pitch)
        XCTAssertEqual(draggedDown.yaw, base.yaw)
        XCTAssertEqual(draggedUp.yaw, base.yaw)
    }

    func testCorrectViewerUsesCubeVUDefaultsFromCoreContract() {
        let defaults = OrbitalViewportCubeVUSettings.default
        let core = SpeakerMeterVisualSettings.default

        XCTAssertEqual(defaults.inputCalibration, Double(core.inputCalibration), accuracy: 0.000_001)
        XCTAssertEqual(defaults.levelCompression, Double(core.levelCompression), accuracy: 0.000_001)
        XCTAssertEqual(defaults.displayCeiling, Double(core.displayCeiling), accuracy: 0.000_001)
        XCTAssertEqual(defaults.hotResponse, Double(core.hotResponse), accuracy: 0.000_001)
        XCTAssertEqual(defaults.hotThreshold, Double(core.hotThreshold), accuracy: 0.000_001)
        XCTAssertEqual(defaults.hotFillStrength, Double(core.hotFillStrength), accuracy: 0.000_001)
        XCTAssertEqual(defaults.paletteDrive, Double(core.vuPaletteDrive), accuracy: 0.000_001)
        XCTAssertEqual(defaults.facePixels, core.facePixels)
        XCTAssertEqual(defaults.idleTint, 0.10, accuracy: 0.000_001)
        XCTAssertEqual(defaults.responseCurve, 0.82, accuracy: 0.000_001)
        XCTAssertEqual(defaults.rimHaloEdge, 0, accuracy: 0.000_001)
        XCTAssertEqual(defaults.pixelFill, 1)
        XCTAssertEqual(defaults.surfaceCheckerOpacity, 1)
        XCTAssertEqual(defaults.cubeOutlineStrength, 0)

        let scalars = SpeakerCubeVUScalars(rawRms: 0.5, settings: defaults.coreSettings, paletteValue: 0.75)
        XCTAssertGreaterThan(scalars.displayVuScalar, 0)
        XCTAssertGreaterThan(scalars.paletteHeat, scalars.displayVuScalar)
        XCTAssertEqual(OrbitalViewportCubeVUSceneKitMaterial.defaultFacePixels, 9)
        XCTAssertFalse(OrbitalViewportCubeVUSceneKitMaterial.usesSceneKitShaderModifier)
        XCTAssertTrue(OrbitalViewportCubeVUSceneKitMaterial.shaderQuantizesFacePixels)
        XCTAssertTrue(OrbitalViewportCubeVUSceneKitMaterial.usesRetainedFaceTextureCache)
        XCTAssertFalse(OrbitalViewportCubeVUSceneKitMaterial.usesSeparateHaloNode)
        XCTAssertFalse(OrbitalViewportCubeVUSceneKitMaterial.usesFrontFacePixelPlane)
        XCTAssertTrue(OrbitalViewportCubeVUSceneKitMaterial.usesActualCubeFaceMaterials)
        XCTAssertGreaterThan(OrbitalViewportCubeVUSceneKitMaterial.cubeVUReadableFaceScale, 2)
        XCTAssertLessThan(OrbitalViewportCubeVUSceneKitMaterial.cubeOutlineEdgeThicknessRatio, 0.03)
        XCTAssertLessThan(OrbitalViewportCubeVUSceneKitMaterial.cubeOutlineNormalAlphaMultiplier, 0.6)
        XCTAssertEqual(OrbitalViewportCubeVUSceneKitMaterial.faceTextureTileGapPixels, 0)
        XCTAssertGreaterThan(OrbitalViewportCubeVUSceneKitMaterial.idleCheckerContrastFloor, defaults.checkerContrast)
        XCTAssertTrue(OrbitalViewportCubeVUSceneKitMaterial.surfaceShader.contains("floor(uv * pixels)"))
        XCTAssertTrue(OrbitalViewportCubeVUSceneKitMaterial.surfaceShader.contains("centerFill"))
        XCTAssertTrue(OrbitalViewportCubeVUSceneKitMaterial.surfaceShader.contains("gridLine"))
        XCTAssertTrue(OrbitalViewportCubeVUSceneKitMaterial.surfaceShader.contains("rimHaloEdge"))
    }

    func testCorrectViewerCubeVUUsesRetainedPixelFaceTextures() {
        let defaults = OrbitalViewportCubeVUSettings.default
        let scalars = SpeakerCubeVUScalars(rawRms: 0.42, settings: defaults.coreSettings, paletteValue: 0.65)
        OrbitalViewportCubeVUSceneKitMaterial.resetFaceTextureCacheForTests()
        let material = OrbitalViewportCubeVUSceneKitMaterial.makeMaterial()

        XCTAssertEqual(material.lightingModel, .constant)
        XCTAssertEqual(material.diffuse.magnificationFilter, .nearest)
        XCTAssertEqual(material.diffuse.minificationFilter, .nearest)
        XCTAssertNil(material.shaderModifiers)

        let texture = OrbitalViewportCubeVUSceneKitMaterial.faceTexture(
            settings: defaults,
            scalars: scalars,
            clip: false,
            vuColor: .systemPurple,
            hotColor: .systemPink
        )
        let repeated = OrbitalViewportCubeVUSceneKitMaterial.faceTexture(
            settings: defaults,
            scalars: scalars,
            clip: false,
            vuColor: .systemPurple,
            hotColor: .systemPink
        )
        XCTAssertTrue(texture === repeated)
        var diagnostics = OrbitalViewportCubeVUSceneKitMaterial.diagnosticsSnapshotForTests()
        XCTAssertEqual(diagnostics.faceTextureCacheMissCount, 1)
        XCTAssertEqual(diagnostics.faceTextureGenerationCount, 1)
        XCTAssertEqual(diagnostics.faceTextureCacheHitCount, 1)
        XCTAssertEqual(texture.size.width, CGFloat(defaults.facePixels * OrbitalViewportCubeVUSceneKitMaterial.faceTexturePixelsPerFacePixel))
        XCTAssertEqual(texture.size.height, CGFloat(defaults.facePixels * OrbitalViewportCubeVUSceneKitMaterial.faceTexturePixelsPerFacePixel))
        XCTAssertEqual(OrbitalViewportCubeVUSceneKitMaterial.cachedFaceTextureCountForTests(), 1)

        for index in 0..<(OrbitalViewportCubeVUSceneKitMaterial.faceTextureCacheLimit + 20) {
            var variedSettings = defaults
            variedSettings.facePixels = 4 + (index % 61)
            variedSettings.pixelFill = Double(index) / Double(OrbitalViewportCubeVUSceneKitMaterial.faceTextureCacheLimit + 20)
            let rawRms = Float(index) / Float(OrbitalViewportCubeVUSceneKitMaterial.faceTextureCacheLimit + 20)
            _ = OrbitalViewportCubeVUSceneKitMaterial.faceTexture(
                settings: variedSettings,
                scalars: SpeakerCubeVUScalars(rawRms: rawRms, settings: variedSettings.coreSettings, paletteValue: rawRms),
                clip: index.isMultiple(of: 11),
                vuColor: .systemPurple,
                hotColor: .systemPink
            )
        }
        XCTAssertLessThanOrEqual(
            OrbitalViewportCubeVUSceneKitMaterial.cachedFaceTextureCountForTests(),
            OrbitalViewportCubeVUSceneKitMaterial.faceTextureCacheLimit
        )
        diagnostics = OrbitalViewportCubeVUSceneKitMaterial.diagnosticsSnapshotForTests()
        XCTAssertGreaterThan(diagnostics.faceTextureEvictionCount, 0)
        XCTAssertGreaterThan(diagnostics.faceTextureGenerationCount, 1)
    }

    func testCorrectViewerDiceRandomizersStayInsideTheirTrays() {
        var generator = SeededGenerator(seed: 0xC0FFEE)
        var base = OrbitalViewportCubeVUSettings.default
        base.inputCalibration = 1.23
        base.levelCompression = 1.45
        base.displayCeiling = 0.86
        base.hotResponse = 2.1
        base.hotThreshold = 0.7
        base.hotFillStrength = 0.77
        base.paletteDrive = 2.4
        base.bloomMin = 0.1
        base.bloomMax = 0.88
        base.bloomEdge = 0.12
        base.rimHaloEdge = 0.3
        base.responseCurve = 0.9
        base.facePixels = 9
        base.pixelFill = 0.86
        base.idleTint = 0.12
        base.surfaceCheckerOpacity = 0.2
        base.checkerContrast = 0.08
        base.speakerHeight = 1.8

        let cubeSurface = OrbitalViewportDiceRandomizer.randomizedCubeSurfaceSettings(
            from: base,
            using: &generator
        )
        XCTAssertEqual(cubeSurface.inputCalibration, base.inputCalibration)
        XCTAssertEqual(cubeSurface.levelCompression, base.levelCompression)
        XCTAssertEqual(cubeSurface.displayCeiling, base.displayCeiling)
        XCTAssertEqual(cubeSurface.hotResponse, base.hotResponse)
        XCTAssertLessThanOrEqual(cubeSurface.bloomMin, cubeSurface.bloomMax)
        XCTAssertTrue((6...14).contains(cubeSurface.facePixels))
        XCTAssertEqual(cubeSurface.speakerHeight, 1)

        let meterResponse = OrbitalViewportDiceRandomizer.randomizedMeterResponseSettings(
            from: base,
            using: &generator
        )
        XCTAssertEqual(meterResponse.bloomMin, base.bloomMin)
        XCTAssertEqual(meterResponse.bloomMax, base.bloomMax)
        XCTAssertEqual(meterResponse.facePixels, base.facePixels)
        XCTAssertEqual(meterResponse.pixelFill, base.pixelFill)
        XCTAssertGreaterThanOrEqual(meterResponse.inputCalibration, 0.5)
        XCTAssertLessThanOrEqual(meterResponse.paletteDrive, 3.4)
        XCTAssertEqual(meterResponse.speakerHeight, 1)

        let randomPreset = OrbitalViewportDiceRandomizer.randomBloomPreset(
            current: .hotCoreBloom,
            using: &generator
        )
        XCTAssertNotEqual(randomPreset, .hotCoreBloom)
    }

    func testCorrectViewerGlobalDiceRandomizesViewStateButPreservesInputState() {
        XCTAssertEqual(
            OrbitalViewportMockup.globalDicePreservedInputStateTitles,
            [
                "Source Mode",
                "Telemetry Advertiser",
                "Local Song File",
                "Local Song Playback",
                "Local Song Render Type",
                "Impulse Pattern"
            ]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.globalDiceRandomizedControlTitles,
            [
                "Camera",
                "Zoom",
                "Spin",
                "Speaker Size",
                "Fog Density",
                "Speaker Numbers",
                "Hidden Lines",
                "Sonic Sphere Speaker Palette",
                "Source Speaker Palette",
                "Ribbed Speaker Sphere",
                "Rib Thickness",
                "Vertical Ribs",
                "Horizontal Rings",
                "Geodesic Palette",
                "Geodesic Saturation",
                "Ground Appearance",
                "Speaker Shape",
                "Label Font",
                "Cube Surface",
                "Bloom Style",
                "Meter Response",
                "Performance"
            ]
        )
        for title in OrbitalViewportMockup.geodesicAppearanceControlTitles {
            XCTAssertTrue(
                OrbitalViewportMockup.globalDiceRandomizedControlTitles.contains(title),
                "Global dice should randomize \(title)"
            )
        }
        for title in OrbitalViewportMockup.sphereGeometryControlTitles {
            XCTAssertTrue(
                OrbitalViewportMockup.globalDiceRandomizedControlTitles.contains(title),
                "Global dice should randomize \(title)"
            )
        }

        var generator = SeededGenerator(seed: 0xD1CE)
        let roll = OrbitalViewportDiceRandomizer.globalViewRoll(
            currentBloomPreset: .hotCoreBloom,
            currentSourceSpeakerRenderStyle: .purple,
            currentShowRibbedSpeakerSphere: false,
            currentRibbedSphereThickness: 1,
            currentRibbedSphereVerticalRibs: 16,
            currentRibbedSphereHorizontalRings: 8,
            currentGeodesicRenderStyle: .purple,
            currentGeodesicSaturation: 0.25,
            using: &generator
        )

        XCTAssertTrue(OrbitalViewportCameraView.allCases.contains(roll.cameraView))
        XCTAssertGreaterThanOrEqual(roll.yaw, -Double.pi)
        XCTAssertLessThanOrEqual(roll.yaw, Double.pi)
        XCTAssertGreaterThanOrEqual(roll.pitch, -OrbitalViewportOrbitState.maxPitch)
        XCTAssertLessThanOrEqual(roll.pitch, OrbitalViewportOrbitState.maxPitch)
        XCTAssertGreaterThanOrEqual(roll.zoom, 0.62)
        XCTAssertLessThanOrEqual(roll.zoom, 1.75)
        XCTAssertGreaterThanOrEqual(roll.speakerSizeSlider, 0)
        XCTAssertLessThanOrEqual(roll.speakerSizeSlider, 100)
        XCTAssertGreaterThanOrEqual(roll.fogDensitySlider, 0)
        XCTAssertLessThanOrEqual(roll.fogDensitySlider, 100)
        XCTAssertTrue(OrbitalViewportRenderStyle.allCases.contains(roll.renderStyle))
        XCTAssertTrue(OrbitalViewportRenderStyle.allCases.contains(roll.sourceSpeakerRenderStyle))
        XCTAssertNotEqual(roll.sourceSpeakerRenderStyle, .purple)
        XCTAssertTrue(roll.showRibbedSpeakerSphere)
        XCTAssertGreaterThanOrEqual(
            roll.ribbedSphereThickness,
            OrbitalViewportRibbedSpeakerSphereGeometry.thicknessRange.lowerBound
        )
        XCTAssertLessThanOrEqual(
            roll.ribbedSphereThickness,
            OrbitalViewportRibbedSpeakerSphereGeometry.thicknessRange.upperBound
        )
        XCTAssertGreaterThanOrEqual(abs(roll.ribbedSphereThickness - 1), 0.08)
        XCTAssertTrue(OrbitalViewportRibbedSpeakerSphereGeometry.verticalRibRange.contains(roll.ribbedSphereVerticalRibs))
        XCTAssertTrue(OrbitalViewportRibbedSpeakerSphereGeometry.horizontalRingRange.contains(roll.ribbedSphereHorizontalRings))
        XCTAssertNotEqual(roll.ribbedSphereVerticalRibs, 16)
        XCTAssertNotEqual(roll.ribbedSphereHorizontalRings, 8)
        XCTAssertTrue(OrbitalViewportRenderStyle.allCases.contains(roll.geodesicRenderStyle))
        XCTAssertTrue(OrbitalViewportRenderStyle.allCases.contains(roll.gridPlaneRenderStyle))
        XCTAssertNotEqual(roll.geodesicRenderStyle, .purple)
        XCTAssertGreaterThanOrEqual(abs(roll.geodesicSaturation - 0.25), 0.08)
        XCTAssertGreaterThanOrEqual(roll.geodesicSaturation, 0)
        XCTAssertLessThanOrEqual(roll.geodesicSaturation, 1)
        XCTAssertGreaterThanOrEqual(roll.gridPlaneVisibilitySlider, 0)
        XCTAssertLessThanOrEqual(roll.gridPlaneVisibilitySlider, 100)
        XCTAssertGreaterThanOrEqual(roll.gridPlaneSpacing, OrbitalViewportGridPlaneGeometry.spacingRange.lowerBound)
        XCTAssertLessThanOrEqual(roll.gridPlaneSpacing, OrbitalViewportGridPlaneGeometry.spacingRange.upperBound)
        XCTAssertTrue(OrbitalViewportSpeakerShape.allCases.contains(roll.speakerShape))
        XCTAssertTrue(OrbitalViewportSpeakerLabelFont.allCases.contains(roll.speakerLabelFont))
        XCTAssertGreaterThanOrEqual(roll.speakerLabelFontSizeSlider, 0)
        XCTAssertLessThanOrEqual(roll.speakerLabelFontSizeSlider, 100)
        XCTAssertTrue(OrbitalViewportCubeVUPreset.allCases.contains(roll.cubePreset))
        XCTAssertGreaterThanOrEqual(roll.cubeSettings.inputCalibration, 0.5)
        XCTAssertLessThanOrEqual(roll.cubeSettings.paletteDrive, 3.4)
        XCTAssertGreaterThanOrEqual(roll.cubeSettings.cubeOutlineStrength, 0)
        XCTAssertLessThanOrEqual(roll.cubeSettings.cubeOutlineStrength, 1)
        XCTAssertEqual(roll.cubeSettings.speakerHeight, 1)
        XCTAssertTrue(OrbitalViewportFrameRate.allCases.contains(roll.viewportFrameRate))
    }

    func testCorrectViewerCubeVUIdleTextureHasNoTileGapsAndCheckerSurface() throws {
        var settings = OrbitalViewportCubeVUSettings.default
        settings.checkerContrast = 0
        settings.pixelFill = 1
        settings.surfaceCheckerOpacity = 1
        let scalars = SpeakerCubeVUScalars(rawRms: 0, settings: settings.coreSettings, paletteValue: 0)
        let texture = OrbitalViewportCubeVUSceneKitMaterial.faceTexture(
            settings: settings,
            scalars: scalars,
            clip: false,
            vuColor: .systemPurple,
            hotColor: .systemPink
        )
        let tilePixels = OrbitalViewportCubeVUSceneKitMaterial.faceTexturePixelsPerFacePixel
        let backingScale = try bitmapScale(texture)
        let firstTile = try pixelBrightness(texture, x: tilePixels / 2, y: tilePixels / 2, scale: backingScale)
        let secondTile = try pixelBrightness(texture, x: tilePixels + tilePixels / 2, y: tilePixels / 2, scale: backingScale)
        let sharedEdge = try pixelBrightness(texture, x: tilePixels, y: tilePixels / 2, scale: backingScale)

        XCTAssertGreaterThan(abs(secondTile - firstTile), 0.01)
        XCTAssertGreaterThan(sharedEdge, min(firstTile, secondTile) * 0.95)
    }

    func testCorrectViewerCubeVUTextureControlsRecoverSeparatedPixelsAndMuteChecker() throws {
        var settings = OrbitalViewportCubeVUSettings.default
        settings.checkerContrast = 0
        settings.surfaceCheckerOpacity = 0
        let scalars = SpeakerCubeVUScalars(rawRms: 0, settings: settings.coreSettings, paletteValue: 0)

        let mutedCheckerTexture = OrbitalViewportCubeVUSceneKitMaterial.faceTexture(
            settings: settings,
            scalars: scalars,
            clip: false,
            vuColor: .systemPurple,
            hotColor: .systemPink
        )
        let tilePixels = OrbitalViewportCubeVUSceneKitMaterial.faceTexturePixelsPerFacePixel
        let mutedScale = try bitmapScale(mutedCheckerTexture)
        let mutedFirstTile = try pixelBrightness(mutedCheckerTexture, x: tilePixels / 2, y: tilePixels / 2, scale: mutedScale)
        let mutedSecondTile = try pixelBrightness(mutedCheckerTexture, x: tilePixels + tilePixels / 2, y: tilePixels / 2, scale: mutedScale)
        XCTAssertLessThan(abs(mutedSecondTile - mutedFirstTile), 0.001)

        settings.pixelFill = 0.5
        let separatedTexture = OrbitalViewportCubeVUSceneKitMaterial.faceTexture(
            settings: settings,
            scalars: scalars,
            clip: false,
            vuColor: .systemPurple,
            hotColor: .systemPink
        )
        let separatedScale = try bitmapScale(separatedTexture)
        let filledTile = try pixelBrightness(separatedTexture, x: tilePixels / 2, y: tilePixels / 2, scale: separatedScale)
        let tileGap = try pixelBrightness(separatedTexture, x: tilePixels, y: tilePixels / 2, scale: separatedScale)
        XCTAssertLessThan(tileGap, filledTile * 0.8)
    }

    func testCorrectViewerDiagnosticLogIsCappedAndIndependentFromMeterTicks() {
        var entries = OrbitalViewportDiagnosticLog.initialEntries()
        for index in 0..<140 {
            OrbitalViewportDiagnosticLog.append("event \(index)", to: &entries)
        }

        XCTAssertEqual(entries.count, OrbitalViewportDiagnosticLog.maximumEntries)
        XCTAssertEqual(entries.first?.message, "event 139")
        XCTAssertEqual(entries.last?.message, "event 40")

        let beforeMeterTick = entries
        _ = makeViewportConfiguration(timeMS: 1_000).frameConfiguration(timeMS: 1_200)
        XCTAssertEqual(entries, beforeMeterTick)
    }

    func testCorrectViewerFrameRateStatusUsesTargetAndUnderTargetThresholds() {
        XCTAssertEqual(OrbitalViewportFrameRateStatus.status(for: 120), .target)
        XCTAssertEqual(OrbitalViewportFrameRateStatus.status(for: 108), .target)
        XCTAssertEqual(OrbitalViewportFrameRateStatus.status(for: 60), .belowTarget)
        XCTAssertEqual(OrbitalViewportFrameRateStatus.status(for: 72.5), .belowTarget)
        XCTAssertEqual(OrbitalViewportFrameRateStatus.status(for: 59.9), .underTarget)
        XCTAssertEqual(OrbitalViewportFrameRateStatus.status(for: 12.2), .underTarget)
        XCTAssertEqual(
            OrbitalViewportFrameRateStatus.status(for: 60, targetFramesPerSecond: 60),
            .target
        )
    }

    func testCorrectViewerFrameRateMonitorEmitsNoFasterThanFiveSamplesPerSecond() {
        var monitor = OrbitalViewportFrameRateMonitor()
        var emittedSamples: [OrbitalViewportFrameRateSample] = []

        for frameIndex in 0...120 {
            let timeMS = Double(frameIndex) * 1_000 / 120
            if let sample = monitor.recordFrame(at: timeMS) {
                emittedSamples.append(sample)
            }
        }

        XCTAssertFalse(emittedSamples.isEmpty)
        XCTAssertLessThanOrEqual(
            emittedSamples.filter { $0.timestampMS < 1_000 }.count,
            OrbitalViewportMockup.fpsMeterLogSamplesPerSecond
        )
        for (previous, next) in zip(emittedSamples, emittedSamples.dropFirst()) {
            XCTAssertGreaterThanOrEqual(next.timestampMS - previous.timestampMS, 199.999)
            XCTAssertEqual(next.status, .target)
            XCTAssertTrue(next.shouldLog)
        }
    }

    func testCorrectViewerFrameRateMonitorEmitsStatusTransitionsImmediately() {
        var monitor = OrbitalViewportFrameRateMonitor()

        XCTAssertNil(monitor.recordFrame(at: 0))
        let targetSample = monitor.recordFrame(at: 1_000.0 / 120)
        XCTAssertEqual(targetSample?.status, .target)

        let belowTargetSample = monitor.recordFrame(at: 25)
        XCTAssertEqual(belowTargetSample?.status, .belowTarget)
        XCTAssertLessThan((belowTargetSample?.timestampMS ?? 0) - (targetSample?.timestampMS ?? 0), 200)
        XCTAssertEqual(belowTargetSample?.diagnosticMessage, "FPS 80.0 target=120 status=below target")

        let underTargetSample = monitor.recordFrame(at: 75)
        XCTAssertEqual(underTargetSample?.status, .underTarget)
        XCTAssertLessThan((underTargetSample?.timestampMS ?? 0) - (belowTargetSample?.timestampMS ?? 0), 200)
        XCTAssertEqual(underTargetSample?.diagnosticMessage, "FPS 40.0 target=120 status=under target")
    }

    func testCorrectViewerFrameRateLogEntriesUseDiagnosticsCap() {
        var entries = OrbitalViewportDiagnosticLog.initialEntries()

        for index in 0..<140 {
            let sample = OrbitalViewportFrameRateSample(
                timestampMS: Double(index),
                framesPerSecond: 10 + Double(index) / 10,
                targetFramesPerSecond: OrbitalViewportMockup.fpsMeterTargetFramesPerSecond,
                status: .underTarget,
                shouldLog: true
            )
            OrbitalViewportDiagnosticLog.append(sample.diagnosticMessage, to: &entries)
        }

        XCTAssertEqual(entries.count, OrbitalViewportDiagnosticLog.maximumEntries)
        XCTAssertEqual(entries.first?.message, "FPS 23.9 target=120 status=under target")
        XCTAssertEqual(entries.last?.message, "FPS 14.0 target=120 status=under target")
    }

    #if os(macOS)
    func testCorrectViewerFrameRateMeterUpdatesInsideSceneKitView() {
        let view = OrbitalViewportSceneNSView(frame: NSRect(x: 0, y: 0, width: 320, height: 240))
        let sample = OrbitalViewportFrameRateSample(
            timestampMS: 1_000,
            framesPerSecond: 118.4,
            targetFramesPerSecond: 120,
            status: .target,
            shouldLog: true
        )

        XCTAssertTrue(OrbitalViewport3DSceneView.usesContinuousRenderDuringActiveMotion)
        view.configureFrameRateMeter(theme: OrbitalViewportTheme(style: .purple), sample: .pending)
        XCTAssertEqual(view.frameRateMeterTextForTests, "FPS --")

        view.updateFrameRateMeter(sample: sample)

        XCTAssertEqual(view.frameRateMeterTextForTests, "FPS 118.4")
        XCTAssertEqual(view.frameRateMeterAccessibilityValueForTests, sample.accessibilityValue)
    }

    func testHeadlessBenchmarkUsesReviewCubeVUConfigurationWithoutChangingSpeakerLook() {
        let activeOptions = OrbitalViewportHeadlessBenchmarkOptions(
            mode: .active,
            warmupFrames: 1,
            measuredFrames: 1,
            width: 320,
            height: 240,
            targetFramesPerSecond: 120
        )
        let activeConfiguration = OrbitalViewportHeadlessBenchmark.makeConfiguration(
            options: activeOptions,
            timeMS: 0
        )

        XCTAssertEqual(activeConfiguration.speakerShape, OrbitalViewportMockup.defaultSpeakerShape)
        XCTAssertEqual(activeConfiguration.speakerSize, OrbitalViewportMath.speakerSize(fromSlider: 50))
        XCTAssertEqual(activeConfiguration.renderStyle, OrbitalViewportMockup.defaultRenderStyle)
        XCTAssertEqual(activeConfiguration.cubeVUSettings, OrbitalViewportMockup.defaultCubeVUSettings)
        XCTAssertTrue(activeConfiguration.spin)
        XCTAssertEqual(activeConfiguration.activeViewportFramesPerSecond, 120)
        XCTAssertEqual(activeConfiguration.meterOnlyViewportFramesPerSecond, 30)

        let idleConfiguration = OrbitalViewportHeadlessBenchmark.makeConfiguration(
            options: OrbitalViewportHeadlessBenchmarkOptions(mode: .idle),
            timeMS: 0
        )
        XCTAssertFalse(idleConfiguration.spin)

        let ribbedConfiguration = OrbitalViewportHeadlessBenchmark.makeConfiguration(
            options: OrbitalViewportHeadlessBenchmarkOptions(
                mode: .active,
                showRibbedSpeakerSphere: true,
                ribbedSphereVerticalRibs: 32,
                ribbedSphereHorizontalRings: 16,
                showHiddenLines: true,
                fogDensity: 42
            ),
            timeMS: 0
        )
        XCTAssertTrue(ribbedConfiguration.showRibbedSpeakerSphere)
        XCTAssertEqual(ribbedConfiguration.ribbedSphereVerticalRibs, 32)
        XCTAssertEqual(ribbedConfiguration.ribbedSphereHorizontalRings, 16)
        XCTAssertTrue(ribbedConfiguration.showHiddenLines)
        XCTAssertEqual(ribbedConfiguration.fogDensity, 42)
    }

    func testHeadedBenchmarkSpinRequiresExplicitLaunchFlag() {
        XCTAssertFalse(
            OrbitalViewportMockup.shouldStartHeadedBenchmarkSpin(
                environment: [:],
                arguments: ["OrbitalViewViewer"]
            )
        )
        XCTAssertTrue(
            OrbitalViewportMockup.shouldStartHeadedBenchmarkSpin(
                environment: [:],
                arguments: [
                    "OrbitalViewViewer",
                    OrbitalViewportMockup.headedBenchmarkLaunchArgument
                ]
            )
        )
        XCTAssertTrue(
            OrbitalViewportMockup.shouldStartHeadedBenchmarkSpin(
                environment: [OrbitalViewportMockup.headedBenchmarkEnvironmentKey: "1"],
                arguments: ["OrbitalViewViewer"]
            )
        )
        XCTAssertFalse(
            OrbitalViewportMockup.shouldStartHeadedBenchmarkSpin(
                environment: [OrbitalViewportMockup.headedBenchmarkEnvironmentKey: "0"],
                arguments: ["OrbitalViewViewer"]
            )
        )
    }
    #endif

    func testCorrectViewerLocalAudioMeterConvertsToEqualMonoSample() {
        XCTAssertEqual(OrbitalViewportMeterSample.displayScalar(powerDB: -80), 0)
        XCTAssertEqual(OrbitalViewportMeterSample.displayScalar(powerDB: 0), 1, accuracy: 0.000_001)

        let sample = OrbitalViewportMeterSample.monoSample(
            averagePowerDB: [-12, -6],
            peakPowerDB: [-3, -9]
        )
        let expectedRMS = (
            OrbitalViewportMeterSample.displayScalar(powerDB: -12) +
            OrbitalViewportMeterSample.displayScalar(powerDB: -6)
        ) / 2

        XCTAssertEqual(sample.rms, expectedRMS, accuracy: 0.000_001)
        XCTAssertEqual(sample.peak, OrbitalViewportMeterSample.displayScalar(powerDB: -3), accuracy: 0.000_001)
    }

    func testCorrectViewerSphereImpulseTestIsDeterministicAndSpatial() {
        let source = OrbitalViewportMeterSource.sphereImpulseTest
        let sameA = source.meter(channel: 4, timeMS: 1_500)
        let sameB = source.meter(channel: 4, timeMS: 1_500)
        let channels = (1...30).map { source.meter(channel: $0, timeMS: 1_500).rms }
        let changedTime = source.meter(channel: 4, timeMS: 2_250)

        XCTAssertEqual(sameA, sameB)
        XCTAssertNotEqual(sameA, changedTime)
        XCTAssertGreaterThan(channels.max() ?? 0, 0.4)
        XCTAssertLessThan(channels.min() ?? 1, 0.25)
    }

    func testCorrectViewerFogSliderHasLighterMiddleAndDenseMaximum() {
        XCTAssertEqual(OrbitalViewportMath.fogDensity(fromSlider: 0), 0)
        XCTAssertEqual(OrbitalViewportMath.fogDensity(fromSlider: 50), 20)
        XCTAssertLessThan(OrbitalViewportMath.fogDensity(fromSlider: 25), 8)
        XCTAssertEqual(OrbitalViewportMath.fogDensity(fromSlider: 100), 100)

        let low = OrbitalViewportFogConfiguration.make(density: 20, cameraDistance: 4)
        let high = OrbitalViewportFogConfiguration.make(density: 100, cameraDistance: 4)

        XCTAssertGreaterThan(low.endDistance - low.startDistance, high.endDistance - high.startDistance)
        XCTAssertGreaterThan(high.densityExponent, low.densityExponent)
    }

    func testCorrectViewerFogCreatesAtmosphericDepthRamp() {
        let clear = makeViewportConfiguration(fogDensity: 0, showHiddenLines: true)
        let heavy = makeViewportConfiguration(fogDensity: 100, showHiddenLines: true)
        let frontDepth = heavy.sceneScale
        let middleDepth = 0.0
        let rearDepth = -heavy.sceneScale

        XCTAssertEqual(clear.depthFogAmount(rearDepth), 0, accuracy: 0.000_001)
        XCTAssertLessThan(heavy.depthFogAmount(frontDepth), heavy.depthFogAmount(middleDepth))
        XCTAssertLessThan(heavy.depthFogAmount(middleDepth), heavy.depthFogAmount(rearDepth))
        XCTAssertLessThan(
            heavy.foggedAlpha(depth: rearDepth, baseAlpha: 0.94),
            heavy.foggedAlpha(depth: middleDepth, baseAlpha: 0.94)
        )
        XCTAssertLessThan(
            heavy.speakerAlpha(depth: rearDepth, selected: false),
            lowFogSpeakerAlpha(at: rearDepth)
        )
        XCTAssertLessThan(
            heavy.speakerEmissionScale(depth: rearDepth),
            heavy.speakerEmissionScale(depth: middleDepth)
        )
        XCTAssertLessThan(
            heavy.speakerLabelAlpha(depth: rearDepth, selected: false),
            heavy.speakerLabelAlpha(depth: middleDepth, selected: false)
        )
        XCTAssertLessThan(
            heavy.sphereGeometryFogAlpha(depth: rearDepth),
            heavy.sphereGeometryFogAlpha(depth: middleDepth)
        )
        XCTAssertLessThan(
            heavy.sphereGeometryFogAlpha(depth: middleDepth),
            heavy.sphereGeometryFogAlpha(depth: frontDepth)
        )
        XCTAssertLessThan(
            heavy.ribbedSphereDepthAlpha(startDepth: rearDepth, endDepth: rearDepth),
            heavy.ribbedSphereDepthAlpha(startDepth: middleDepth, endDepth: middleDepth)
        )
        XCTAssertLessThan(heavy.ribbedSphereSceneMaterialAlpha, clear.ribbedSphereSceneMaterialAlpha)
        XCTAssertGreaterThan(
            heavy.ribbedSphereCutawayPlaneOffset(radius: 2),
            clear.ribbedSphereCutawayPlaneOffset(radius: 2)
        )
        XCTAssertEqual(heavy.speakerAlpha(depth: rearDepth, selected: true), 1)
        XCTAssertEqual(heavy.speakerLabelAlpha(depth: rearDepth, selected: true), 1)

        func lowFogSpeakerAlpha(at depth: Double) -> Double {
            makeViewportConfiguration(fogDensity: 20, showHiddenLines: true)
                .speakerAlpha(depth: depth, selected: false)
        }
    }

    func testCorrectViewerImpulseVariantsAreDeterministicAndDistinct() {
        let ripple = OrbitalViewportMeterSource.impulse(.ripple)
        let waves = OrbitalViewportMeterSource.impulse(.waves)
        let comets = OrbitalViewportMeterSource.impulse(.orbitingComets)

        XCTAssertEqual(waves.meter(channel: 8, timeMS: 1_900), waves.meter(channel: 8, timeMS: 1_900))
        XCTAssertNotEqual(ripple.meter(channel: 8, timeMS: 1_900), waves.meter(channel: 8, timeMS: 1_900))
        XCTAssertNotEqual(waves.meter(channel: 8, timeMS: 1_900), comets.meter(channel: 8, timeMS: 1_900))
        XCTAssertGreaterThan((1...30).map { comets.meter(channel: $0, timeMS: 1_900).rms }.max() ?? 0, 0.35)
    }

    func testCorrectViewerOrbitingCometsUseTwoBroadHotTrails() {
        let source = OrbitalViewportMeterSource.impulse(.orbitingComets)
        let firstFrame = (1...30).map { channel in
            (channel: channel, sample: source.meter(channel: channel, timeMS: 1_900))
        }
        let secondFrame = (1...30).map { channel in
            (channel: channel, sample: source.meter(channel: channel, timeMS: 2_650))
        }
        let activeCount = firstFrame.filter { $0.sample.rms > 0.22 }.count
        let hotTrailCount = firstFrame.filter { $0.sample.peak > 0.34 }.count

        XCTAssertEqual(OrbitalViewportImpulsePattern.orbitingCometCount, 2)
        XCTAssertGreaterThanOrEqual(activeCount, 8)
        XCTAssertLessThanOrEqual(activeCount, 14)
        XCTAssertGreaterThanOrEqual(hotTrailCount, 4)
        XCTAssertNotEqual(firstFrame.map(\.sample.rms), secondFrame.map(\.sample.rms))
    }

    func testCorrectViewerAudioExcitationUsesMonoSampleAsCheapEnvelope() {
        let quiet = OrbitalViewportImpulsePattern.meter(
            kind: .waves,
            channel: 9,
            timeMS: 1_250,
            excitation: OrbitalViewportMeterSample(rms: 0.04, peak: 0.08)
        )
        let loud = OrbitalViewportImpulsePattern.meter(
            kind: .waves,
            channel: 9,
            timeMS: 1_250,
            excitation: OrbitalViewportMeterSample(rms: 0.72, peak: 0.91)
        )

        XCTAssertGreaterThan(loud.rms, quiet.rms)
        XCTAssertGreaterThan(loud.peak, quiet.peak)
    }

    func testCorrectViewerExciteCometsUsesMonoEnvelopeOverSameCometPattern() {
        let quiet = OrbitalViewportImpulsePattern.meter(
            kind: .orbitingComets,
            channel: 6,
            timeMS: 1_900,
            excitation: OrbitalViewportMeterSample(rms: 0.04, peak: 0.08)
        )
        let loud = OrbitalViewportImpulsePattern.meter(
            kind: .orbitingComets,
            channel: 6,
            timeMS: 1_900,
            excitation: OrbitalViewportMeterSample(rms: 0.72, peak: 0.91)
        )
        let excitedActiveChannels = (1...30).filter {
            OrbitalViewportImpulsePattern.meter(
                kind: .orbitingComets,
                channel: $0,
                timeMS: 1_900,
                excitation: OrbitalViewportMeterSample(rms: 0.72, peak: 0.91)
            ).rms > 0.22
        }

        XCTAssertEqual(OrbitalViewportImpulsePattern.orbitingCometCount, 2)
        XCTAssertGreaterThan(loud.rms, quiet.rms)
        XCTAssertGreaterThan(loud.peak, quiet.peak)
        XCTAssertGreaterThanOrEqual(excitedActiveChannels.count, 8)
    }

    func testCorrectViewerDiagnosticsSeparateRawAndDisplayScalars() {
        let settings = OrbitalViewportCubeVUPreset.hotCoreBloom.settings
        let diagnostics = OrbitalViewportMeterDiagnostics.make(
            channel: 7,
            source: .sphereImpulseTest,
            settings: settings,
            timeMS: 1_500
        )

        XCTAssertEqual(diagnostics.channel, 7)
        XCTAssertGreaterThanOrEqual(diagnostics.rawPeak, diagnostics.rawRMS)
        XCTAssertGreaterThanOrEqual(diagnostics.displayScalar, 0)
        XCTAssertGreaterThanOrEqual(diagnostics.hotScalar, 0)
    }

    func testCorrectViewerSettingsJSONExportPayloadContainsPresetDriveAndTheme() throws {
        let payload = OrbitalViewportSettingsExportPayload(
            renderStyle: .daftPunkBow,
            sourceSpeakerRenderStyle: .flamingoGreen,
            geodesicRenderStyle: .rackBlue,
            geodesicSaturation: 0.36,
            showRibbedSpeakerSphere: true,
            ribbedSphereThickness: 1.4,
            ribbedSphereVerticalRibs: 24,
            ribbedSphereHorizontalRings: 12,
            speakerShape: .cubeVU,
            speakerLabelFont: .pressStart2P,
            speakerLabelFontSizeSlider: 72,
            speakerLabelFontSizeScale: 1.17,
            leftPanel: OrbitalViewportLeftPanelSettings(
                audioSource: OrbitalViewportAudioSourceExportSettings(
                    mode: .localAudioFile,
                    hasLoadedAudio: true,
                    fileName: "reference-track.wav",
                    filePath: "/Users/example/Music/reference-track.wav",
                    isPlaying: false,
                    statusText: "Loaded",
                    renderMode: .exciteWaves
                ),
                camera: OrbitalViewportCameraExportSettings(
                    cameraView: .elevation,
                    yaw: 0.42,
                    pitch: -0.2,
                    zoom: 1.24,
                    spin: true,
                    cameraAdjusted: true
                ),
                speakerType: .cubeVU,
                viewDetail: OrbitalViewportViewDetailExportSettings(
                    speakerSizeSlider: 64,
                    speakerSize: 2.35,
                    fogDensitySlider: 38,
                    fogDensity: 24,
                    showSpeakerNumbers: true,
                    showHiddenLines: true,
                    showGridPlane: true,
                    gridPlaneVisibilitySlider: 86
                ),
                selectedChannel: 12
            ),
            groundAppearance: OrbitalViewportGroundAppearanceExportSettings(
                showGridPlane: true,
                gridPlaneVisibilitySlider: 86,
                gridPlaneSpacing: 0.75,
                gridPlaneRenderStyle: .rackMint
            ),
            sourceMode: .localSong,
            driveMode: .impulseRipple,
            cubePreset: .haloEdgeBloom,
            cubeSettings: OrbitalViewportCubeVUPreset.haloEdgeBloom.settings,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
        let json = String(data: data, encoding: .utf8) ?? ""
        let decoded = try JSONDecoder().decode(OrbitalViewportSettingsExportPayload.self, from: data)

        XCTAssertTrue(json.contains("\"schemaVersion\" : 9"))
        XCTAssertTrue(json.contains("\"sourceMode\" : \"localSong\""))
        XCTAssertTrue(json.contains("\"driveMode\" : \"impulseTest\""))
        XCTAssertTrue(json.contains("\"cubePreset\" : \"haloEdgeBloom\""))
        XCTAssertTrue(json.contains("\"renderStyle\" : \"daftPunkBow\""))
        XCTAssertTrue(json.contains("\"sourceSpeakerRenderStyle\" : \"flamingoGreen\""))
        XCTAssertTrue(json.contains("\"geodesicRenderStyle\" : \"rackBlue\""))
        XCTAssertTrue(json.contains("\"geodesicSaturation\" : 0.36"))
        XCTAssertFalse(json.contains("\"hideSphereStructure\""))
        XCTAssertTrue(json.contains("\"showRibbedSpeakerSphere\" : true"))
        XCTAssertTrue(json.contains("\"ribbedSphereThickness\" : 1.4"))
        XCTAssertTrue(json.contains("\"ribbedSphereVerticalRibs\" : 24"))
        XCTAssertTrue(json.contains("\"ribbedSphereHorizontalRings\" : 12"))
        XCTAssertFalse(json.contains("\"showSpeakerCenterStruts\""))
        XCTAssertTrue(json.contains("\"renderMode\" : \"exciteWaves\""))
        XCTAssertTrue(json.contains("\"speakerLabelFont\" : \"pressStart2P\""))
        XCTAssertTrue(json.contains("\"speakerLabelFontSizeSlider\" : 72"))
        XCTAssertTrue(json.contains("\"speakerLabelFontSizeScale\" : 1.17"))
        XCTAssertTrue(json.contains("\"leftPanel\""))
        XCTAssertTrue(json.contains("\"cameraView\" : \"elevation\""))
        XCTAssertTrue(json.contains("\"speakerSizeSlider\" : 64"))
        XCTAssertTrue(json.contains("\"showGridPlane\" : true"))
        XCTAssertTrue(json.contains("\"gridPlaneVisibilitySlider\" : 86"))
        XCTAssertTrue(json.contains("\"groundAppearance\""))
        XCTAssertTrue(json.contains("\"gridPlaneSpacing\" : 0.75"))
        XCTAssertTrue(json.contains("\"gridPlaneRenderStyle\" : \"rackMint\""))
        XCTAssertTrue(json.contains("\"fileName\" : \"reference-track.wav\""))
        XCTAssertTrue(json.contains("\"selectedChannel\" : 12"))
        XCTAssertTrue(json.contains("\"rimHaloEdge\" : 1"))
        XCTAssertTrue(json.contains("\"pixelFill\" : 1"))
        XCTAssertTrue(json.contains("\"surfaceCheckerOpacity\" : 1"))
        XCTAssertEqual(decoded.leftPanel.audioSource.mode, .localAudioFile)
        XCTAssertEqual(decoded.leftPanel.audioSource.filePath, "/Users/example/Music/reference-track.wav")
        XCTAssertEqual(decoded.leftPanel.audioSource.renderMode, .exciteWaves)
        XCTAssertEqual(decoded.sourceMode, .localSong)
        XCTAssertTrue(decoded.sourceModeWasExplicit)
        XCTAssertEqual(decoded.sourceSpeakerRenderStyle, .flamingoGreen)
        XCTAssertEqual(decoded.geodesicRenderStyle, .rackBlue)
        XCTAssertTrue(decoded.showRibbedSpeakerSphere)
        XCTAssertEqual(decoded.ribbedSphereThickness, 1.4, accuracy: 0.000_001)
        XCTAssertEqual(decoded.ribbedSphereVerticalRibs, 24)
        XCTAssertEqual(decoded.ribbedSphereHorizontalRings, 12)
        XCTAssertEqual(decoded.leftPanel.camera.cameraView, .elevation)
        XCTAssertEqual(decoded.leftPanel.camera.yaw, 0.42, accuracy: 0.000_001)
        XCTAssertTrue(decoded.leftPanel.camera.spin)
        XCTAssertEqual(decoded.leftPanel.speakerType, .cubeVU)
        XCTAssertEqual(decoded.leftPanel.viewDetail.speakerSizeSlider, 64)
        XCTAssertTrue(decoded.leftPanel.viewDetail.showSpeakerNumbers)
        XCTAssertTrue(decoded.leftPanel.viewDetail.showHiddenLines)
        XCTAssertTrue(decoded.leftPanel.viewDetail.showGridPlane)
        XCTAssertEqual(decoded.leftPanel.viewDetail.gridPlaneVisibilitySlider, 86)
        XCTAssertTrue(decoded.groundAppearance.showGridPlane)
        XCTAssertEqual(decoded.groundAppearance.gridPlaneVisibilitySlider, 86)
        XCTAssertEqual(decoded.groundAppearance.gridPlaneSpacing, 0.75, accuracy: 0.000_001)
        XCTAssertEqual(decoded.groundAppearance.gridPlaneRenderStyle, .rackMint)
        XCTAssertEqual(decoded.leftPanel.selectedChannel, 12)
        XCTAssertEqual(decoded.speakerLabelFont, .pressStart2P)
        XCTAssertEqual(decoded.speakerLabelFontSizeSlider, 72)
        XCTAssertEqual(decoded.speakerLabelFontSizeScale, 1.17, accuracy: 0.000_001)
    }

    func testCorrectViewerUnadjustedLegacyIsometricCameraResolvesToPresetOrbit() throws {
        let legacyCamera = OrbitalViewportCameraExportSettings(
            cameraView: .isometric,
            yaw: 0,
            pitch: 0,
            zoom: 1,
            spin: true,
            cameraAdjusted: false
        )
        let payload = makeViewThemePayload(
            themeID: "legacy-isometric",
            leftPanel: OrbitalViewportLeftPanelSettings(
                audioSource: .default,
                camera: legacyCamera,
                speakerType: .cubeVU,
                viewDetail: .default,
                selectedChannel: nil
            )
        )
        let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
        let decoded = try JSONDecoder().decode(OrbitalViewportSettingsExportPayload.self, from: data)
        let resolved = decoded.leftPanel.camera.resolvedOrbitState
        let preset = OrbitalViewportOrbitState.preset(.isometric)

        XCTAssertEqual(resolved.yaw, preset.yaw, accuracy: 0.000_001)
        XCTAssertEqual(resolved.pitch, preset.pitch, accuracy: 0.000_001)
        XCTAssertTrue(decoded.leftPanel.camera.spin)
        XCTAssertFalse(decoded.leftPanel.camera.cameraAdjusted)
    }

    func testCorrectViewerAdjustedSavedCameraPreservesStoredOrbitWithPitchClamp() {
        let adjustedCamera = OrbitalViewportCameraExportSettings(
            cameraView: .isometric,
            yaw: 0.42,
            pitch: Double.pi,
            zoom: 1,
            spin: false,
            cameraAdjusted: true
        )
        let resolved = adjustedCamera.resolvedOrbitState

        XCTAssertEqual(resolved.yaw, 0.42, accuracy: 0.000_001)
        XCTAssertEqual(resolved.pitch, OrbitalViewportOrbitState.maxPitch, accuracy: 0.000_001)
    }

    func testCorrectViewerSettingsJSONRoundTripsEverySpeakerLabelFont() throws {
        for font in OrbitalViewportSpeakerLabelFont.allCases {
            let payload = OrbitalViewportSettingsExportPayload(
                renderStyle: .purple,
                speakerShape: .cubeVU,
                speakerLabelFont: font,
                driveMode: .music,
                cubePreset: .softCenterBloom,
                cubeSettings: .default,
                activeViewportFramesPerSecond: 60,
                meterOnlyViewportFramesPerSecond: 10,
                inspectorRefreshFramesPerSecond: 10,
                drawsOnDemand: true,
                exportedAt: Date(timeIntervalSince1970: 0)
            )
            let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
            let decoded = try JSONDecoder().decode(OrbitalViewportSettingsExportPayload.self, from: data)

            XCTAssertEqual(decoded.speakerLabelFont, font)
        }
    }

    func testCorrectViewerSettingsJSONInfersLegacySourceModeFromDriveMode() throws {
        let localSongPayload = OrbitalViewportSettingsExportPayload(
            renderStyle: .purple,
            speakerShape: .cubeVU,
            sourceMode: .telemetry,
            driveMode: .music,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        var localSongObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: OrbitalViewportSettingsJSONExporter.jsonData(payload: localSongPayload))
                as? [String: Any]
        )
        localSongObject.removeValue(forKey: "sourceMode")
        let localSongData = try JSONSerialization.data(withJSONObject: localSongObject)

        let impulsePayload = OrbitalViewportSettingsExportPayload(
            renderStyle: .purple,
            speakerShape: .cubeVU,
            sourceMode: .telemetry,
            driveMode: .impulseWaves,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        var impulseObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: OrbitalViewportSettingsJSONExporter.jsonData(payload: impulsePayload))
                as? [String: Any]
        )
        impulseObject.removeValue(forKey: "sourceMode")
        let impulseData = try JSONSerialization.data(withJSONObject: impulseObject)

        let legacyLocalSong = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: localSongData
        )
        let legacyImpulse = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: impulseData
        )

        XCTAssertEqual(legacyLocalSong.sourceMode, .localSong)
        XCTAssertFalse(legacyLocalSong.sourceModeWasExplicit)
        XCTAssertEqual(
            legacyLocalSong.sourceModeForThemeLoad(defaultMode: .telemetry, preferDefaultWhenMissing: true),
            .telemetry
        )
        XCTAssertEqual(
            legacyLocalSong.sourceModeForThemeLoad(defaultMode: .telemetry, preferDefaultWhenMissing: false),
            .localSong
        )
        XCTAssertEqual(legacyImpulse.sourceMode, .impulseTest)
        XCTAssertFalse(legacyImpulse.sourceModeWasExplicit)
        XCTAssertEqual(
            legacyImpulse.sourceModeForThemeLoad(defaultMode: .telemetry, preferDefaultWhenMissing: true),
            .telemetry
        )
    }

    func testCorrectViewerSettingsJSONDefaultsMissingSpeakerLabelSize() throws {
        let payload = OrbitalViewportSettingsExportPayload(
            renderStyle: .purple,
            speakerShape: .cubeVU,
            speakerLabelFont: .minecraft,
            driveMode: .music,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        var json = String(data: try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload), encoding: .utf8) ?? ""
        json = json.replacingOccurrences(
            of: #"  "speakerLabelFontSizeSlider" : 50,\#n"#,
            with: ""
        )
        json = json.replacingOccurrences(
            of: #"  "speakerLabelFontSizeScale" : 1,\#n"#,
            with: ""
        )

        let decoded = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: Data(json.utf8)
        )

        XCTAssertEqual(decoded.speakerLabelFont, .minecraft)
        XCTAssertEqual(decoded.speakerLabelFontSizeSlider, OrbitalViewportMath.speakerLabelFontSizeSliderCenter)
        XCTAssertEqual(decoded.speakerLabelFontSizeScale, 1, accuracy: 0.000_001)
    }

    func testCorrectViewerSettingsJSONDefaultsMissingSourceSpeakerPaletteToSpeakerPalette() throws {
        let payload = OrbitalViewportSettingsExportPayload(
            renderStyle: .rackPink,
            sourceSpeakerRenderStyle: .rackBlue,
            speakerShape: .cubeVU,
            driveMode: .music,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object.removeValue(forKey: "sourceSpeakerRenderStyle")
        let olderData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: olderData
        )

        XCTAssertEqual(decoded.renderStyle, .rackPink)
        XCTAssertEqual(decoded.sourceSpeakerRenderStyle, .rackPink)
    }

    func testCorrectViewerSettingsJSONIgnoresLegacySphereVisibility() throws {
        let payload = OrbitalViewportSettingsExportPayload(
            renderStyle: .purple,
            speakerShape: .cubeVU,
            driveMode: .music,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object["hideSphereStructure"] = false
        let olderData = try JSONSerialization.data(withJSONObject: object)
        object["hideSphereStructure"] = true
        let alternateOlderData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: olderData
        )
        let alternateDecoded = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: alternateOlderData
        )

        XCTAssertEqual(decoded.renderStyle, .purple)
        XCTAssertFalse(decoded.showRibbedSpeakerSphere)
        XCTAssertEqual(decoded, alternateDecoded)
    }

    func testCorrectViewerSettingsJSONDefaultsMissingRibbedSpeakerSphereFields() throws {
        let payload = OrbitalViewportSettingsExportPayload(
            renderStyle: .purple,
            showRibbedSpeakerSphere: true,
            ribbedSphereThickness: 1.8,
            ribbedSphereVerticalRibs: 22,
            ribbedSphereHorizontalRings: 14,
            speakerShape: .cubeVU,
            driveMode: .music,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object.removeValue(forKey: "showRibbedSpeakerSphere")
        object.removeValue(forKey: "ribbedSphereThickness")
        object.removeValue(forKey: "ribbedSphereVerticalRibs")
        object.removeValue(forKey: "ribbedSphereHorizontalRings")
        let olderData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: olderData
        )

        XCTAssertFalse(decoded.showRibbedSpeakerSphere)
        XCTAssertEqual(decoded.ribbedSphereThickness, 1, accuracy: 0.000_001)
        XCTAssertEqual(decoded.ribbedSphereVerticalRibs, 16)
        XCTAssertEqual(decoded.ribbedSphereHorizontalRings, 8)
    }

    func testCorrectViewerSettingsJSONClampsLegacyThinRibbedSphereThickness() throws {
        let payload = OrbitalViewportSettingsExportPayload(
            renderStyle: .purple,
            showRibbedSpeakerSphere: true,
            ribbedSphereThickness: 1.8,
            ribbedSphereVerticalRibs: 22,
            ribbedSphereHorizontalRings: 14,
            speakerShape: .cubeVU,
            driveMode: .music,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object["ribbedSphereThickness"] = 0.25
        let olderData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: olderData
        )

        XCTAssertEqual(decoded.ribbedSphereThickness, 0.70, accuracy: 0.000_001)
    }

    func testCorrectViewerSettingsJSONFallsBackFromLegacySpeakerCenterStrutsVisibility() throws {
        let payload = OrbitalViewportSettingsExportPayload(
            renderStyle: .purple,
            showRibbedSpeakerSphere: false,
            speakerShape: .cubeVU,
            driveMode: .music,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object.removeValue(forKey: "showRibbedSpeakerSphere")
        object["showSpeakerCenterStruts"] = true
        let olderData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: olderData
        )

        XCTAssertTrue(decoded.showRibbedSpeakerSphere)
    }

    func testCorrectViewerSettingsJSONFallsBackFromLegacyViewDetailGridPlaneFields() throws {
        let payload = OrbitalViewportSettingsExportPayload(
            renderStyle: .purple,
            geodesicRenderStyle: .rackBlue,
            speakerShape: .cubeVU,
            leftPanel: OrbitalViewportLeftPanelSettings(
                audioSource: .default,
                camera: .default,
                speakerType: .cubeVU,
                viewDetail: OrbitalViewportViewDetailExportSettings(
                    speakerSizeSlider: 52,
                    speakerSize: 2,
                    fogDensitySlider: 42,
                    fogDensity: 27,
                    showSpeakerNumbers: true,
                    showHiddenLines: true,
                    showGridPlane: true,
                    gridPlaneVisibilitySlider: 88
                ),
                selectedChannel: nil
            ),
            groundAppearance: OrbitalViewportGroundAppearanceExportSettings(
                showGridPlane: true,
                gridPlaneVisibilitySlider: 88,
                gridPlaneSpacing: 0.75,
                gridPlaneRenderStyle: .rackMint
            ),
            driveMode: .music,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object.removeValue(forKey: "groundAppearance")
        let olderData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: olderData
        )

        XCTAssertTrue(decoded.leftPanel.viewDetail.showSpeakerNumbers)
        XCTAssertTrue(decoded.leftPanel.viewDetail.showHiddenLines)
        XCTAssertTrue(decoded.leftPanel.viewDetail.showGridPlane)
        XCTAssertEqual(decoded.leftPanel.viewDetail.gridPlaneVisibilitySlider, 88)
        XCTAssertTrue(decoded.groundAppearance.showGridPlane)
        XCTAssertEqual(decoded.groundAppearance.gridPlaneVisibilitySlider, 88)
        XCTAssertEqual(decoded.groundAppearance.gridPlaneSpacing, OrbitalViewportGridPlaneGeometry.defaultSpacing)
        XCTAssertEqual(decoded.groundAppearance.gridPlaneRenderStyle, .rackBlue)
    }

    func testCorrectViewerSettingsJSONDefaultsMissingGridPlaneFields() throws {
        let payload = OrbitalViewportSettingsExportPayload(
            renderStyle: .purple,
            speakerShape: .cubeVU,
            leftPanel: OrbitalViewportLeftPanelSettings(
                audioSource: .default,
                camera: .default,
                speakerType: .cubeVU,
                viewDetail: OrbitalViewportViewDetailExportSettings(
                    speakerSizeSlider: 52,
                    speakerSize: 2,
                    fogDensitySlider: 42,
                    fogDensity: 27,
                    showSpeakerNumbers: true,
                    showHiddenLines: true,
                    showGridPlane: true,
                    gridPlaneVisibilitySlider: 88
                ),
                selectedChannel: nil
            ),
            groundAppearance: OrbitalViewportGroundAppearanceExportSettings(
                showGridPlane: true,
                gridPlaneVisibilitySlider: 88,
                gridPlaneSpacing: 0.75,
                gridPlaneRenderStyle: .rackMint
            ),
            driveMode: .music,
            cubePreset: .softCenterBloom,
            cubeSettings: .default,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
        let data = try OrbitalViewportSettingsJSONExporter.jsonData(payload: payload)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object.removeValue(forKey: "groundAppearance")
        var leftPanel = try XCTUnwrap(object["leftPanel"] as? [String: Any])
        var viewDetail = try XCTUnwrap(leftPanel["viewDetail"] as? [String: Any])
        viewDetail.removeValue(forKey: "showGridPlane")
        viewDetail.removeValue(forKey: "gridPlaneVisibilitySlider")
        leftPanel["viewDetail"] = viewDetail
        object["leftPanel"] = leftPanel
        let olderData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(
            OrbitalViewportSettingsExportPayload.self,
            from: olderData
        )

        XCTAssertTrue(decoded.leftPanel.viewDetail.showSpeakerNumbers)
        XCTAssertTrue(decoded.leftPanel.viewDetail.showHiddenLines)
        XCTAssertFalse(decoded.leftPanel.viewDetail.showGridPlane)
        XCTAssertEqual(
            decoded.leftPanel.viewDetail.gridPlaneVisibilitySlider,
            OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider
        )
        XCTAssertFalse(decoded.groundAppearance.showGridPlane)
        XCTAssertEqual(
            decoded.groundAppearance.gridPlaneVisibilitySlider,
            OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider
        )
        XCTAssertEqual(decoded.groundAppearance.gridPlaneSpacing, OrbitalViewportGridPlaneGeometry.defaultSpacing)
        XCTAssertEqual(decoded.groundAppearance.gridPlaneRenderStyle, .purple)
    }

    func testCorrectViewerRemovedSpeakerLabelFontsDecodeToSystemDefault() throws {
        for rawFont in ["cityLight", "pumpDemi", "eurostileBoldExtended", "microgramma"] {
            let data = Data("\"\(rawFont)\"".utf8)
            let decoded = try JSONDecoder().decode(OrbitalViewportSpeakerLabelFont.self, from: data)

            XCTAssertEqual(decoded, .systemDefault)
        }
    }

    func testCorrectViewerViewThemeGeneratedNamesAreTwoWordsAndAvoidOverwrite() throws {
        let fileManager = FileManager.default
        let root = try makeTemporaryDirectory()
        defer { try? fileManager.removeItem(at: root) }
        let directoryURL = try OrbitalViewportViewThemeStore.themeDirectoryURL(
            resourcesURL: root,
            fileManager: fileManager
        )

        let firstURL = try OrbitalViewportViewThemeStore.uniqueThemeFileURL(
            in: directoryURL,
            fileManager: fileManager,
            nameProvider: { "Neon Circuit" }
        )
        XCTAssertEqual(firstURL.lastPathComponent, "Neon Circuit.json")
        XCTAssertEqual(firstURL.deletingPathExtension().lastPathComponent.split(separator: " ").count, 2)
        try Data("{}".utf8).write(to: firstURL)

        var names = ["Neon Circuit", "Chrome Horizon"].makeIterator()
        let secondURL = try OrbitalViewportViewThemeStore.uniqueThemeFileURL(
            in: directoryURL,
            fileManager: fileManager,
            nameProvider: { names.next() ?? "Velvet Pulse" }
        )
        XCTAssertEqual(secondURL.lastPathComponent, "Chrome Horizon.json")
        XCTAssertFalse(fileManager.fileExists(atPath: secondURL.path))
    }

    func testCorrectViewerViewThemeListUsesRenamedFileStem() throws {
        let fileManager = FileManager.default
        let root = try makeTemporaryDirectory()
        defer { try? fileManager.removeItem(at: root) }
        let payload = makeViewThemePayload(themeID: "theme-renamed", speakerLabelFont: .jost)
        let saved = try OrbitalViewportViewThemeStore.writeTheme(
            payload: payload,
            resourcesURL: root,
            fileManager: fileManager,
            nameProvider: { "Neon Circuit" }
        )
        let renamedURL = saved.url.deletingLastPathComponent().appendingPathComponent("Manual Rename.json")
        try fileManager.moveItem(at: saved.url, to: renamedURL)

        let themes = try OrbitalViewportViewThemeStore.savedThemes(
            in: renamedURL.deletingLastPathComponent(),
            fileManager: fileManager
        )

        XCTAssertEqual(themes.count, 1)
        XCTAssertEqual(themes[0].displayName, "Manual Rename")
        XCTAssertEqual(themes[0].fileName, "Manual Rename.json")
        XCTAssertEqual(themes[0].themeID, "theme-renamed")
        XCTAssertEqual(themes[0].payload?.speakerLabelFont, .jost)
    }

    func testCorrectViewerViewThemeSaveListLoadRoundTripsSelectedFont() throws {
        let fileManager = FileManager.default
        let root = try makeTemporaryDirectory()
        defer { try? fileManager.removeItem(at: root) }
        let payload = makeViewThemePayload(
            themeID: "theme-font",
            renderStyle: .daftPunkBow,
            speakerLabelFont: .sevastopolInterface,
            speakerLabelFontSizeSlider: 76
        )

        let saved = try OrbitalViewportViewThemeStore.writeTheme(
            payload: payload,
            resourcesURL: root,
            fileManager: fileManager,
            nameProvider: { "Velvet Matrix" }
        )
        let themes = try OrbitalViewportViewThemeStore.savedThemes(
            in: saved.url.deletingLastPathComponent(),
            fileManager: fileManager
        )

        XCTAssertEqual(saved.displayName, "Velvet Matrix")
        XCTAssertEqual(themes.first?.displayName, "Velvet Matrix")
        XCTAssertEqual(themes.first?.payload?.themeID, "theme-font")
        XCTAssertEqual(themes.first?.payload?.renderStyle, .daftPunkBow)
        XCTAssertEqual(themes.first?.payload?.geodesicRenderStyle, .rackBlue)
        XCTAssertEqual(themes.first?.payload?.speakerLabelFont, .sevastopolInterface)
        XCTAssertEqual(themes.first?.payload?.speakerLabelFontSizeSlider, 76)
        XCTAssertEqual(
            themes.first?.payload?.speakerLabelFontSizeScale,
            OrbitalViewportMath.speakerLabelSizeScale(fromSlider: 76)
        )
    }

    func testCorrectViewerViewThemeDefaultSurvivesManualRenameByThemeID() throws {
        let fileManager = FileManager.default
        let root = try makeTemporaryDirectory()
        defer { try? fileManager.removeItem(at: root) }
        let payload = makeViewThemePayload(themeID: "theme-default", speakerLabelFont: .michroma)
        let saved = try OrbitalViewportViewThemeStore.writeTheme(
            payload: payload,
            resourcesURL: root,
            fileManager: fileManager,
            nameProvider: { "Prism Orbit" }
        )
        let metadata = try OrbitalViewportViewThemeStore.writeDefaultTheme(saved, fileManager: fileManager)
        let renamedURL = saved.url.deletingLastPathComponent().appendingPathComponent("Renamed Default.json")
        try fileManager.moveItem(at: saved.url, to: renamedURL)
        let themes = try OrbitalViewportViewThemeStore.savedThemes(
            in: renamedURL.deletingLastPathComponent(),
            fileManager: fileManager
        )
        let defaultTheme = try XCTUnwrap(OrbitalViewportViewThemeStore.defaultTheme(in: themes, metadata: metadata))

        XCTAssertEqual(defaultTheme.displayName, "Renamed Default")
        XCTAssertEqual(defaultTheme.themeID, "theme-default")
        XCTAssertEqual(defaultTheme.payload?.speakerLabelFont, .michroma)
        XCTAssertTrue(OrbitalViewportViewThemeStore.isDefaultTheme(defaultTheme, metadata: metadata))
    }

    func testCorrectViewerViewThemeInvalidDefaultFallsBackWithoutCrash() throws {
        let fileManager = FileManager.default
        let root = try makeTemporaryDirectory()
        defer { try? fileManager.removeItem(at: root) }
        let directoryURL = try OrbitalViewportViewThemeStore.themeDirectoryURL(
            resourcesURL: root,
            fileManager: fileManager
        )
        let invalidThemeURL = directoryURL.appendingPathComponent("Broken Theme.json")
        try Data("not valid json".utf8).write(to: invalidThemeURL)
        try Data("not valid json".utf8).write(to: OrbitalViewportViewThemeStore.defaultThemeURL(in: directoryURL))

        let themes = try OrbitalViewportViewThemeStore.savedThemes(in: directoryURL, fileManager: fileManager)

        XCTAssertEqual(themes.count, 1)
        XCTAssertEqual(themes[0].displayName, "Broken Theme")
        XCTAssertFalse(themes[0].isValid)
        XCTAssertNil(try? OrbitalViewportViewThemeStore.readDefaultTheme(in: directoryURL))
        XCTAssertNil(
            OrbitalViewportViewThemeStore.defaultTheme(
                in: themes,
                metadata: OrbitalViewportDefaultThemeMetadata(themeID: "missing", fileName: "Missing.json")
            )
        )
    }

    func testCorrectViewerSpatGRISLayoutGeneratedNamesAvoidOverwrite() throws {
        let fileManager = FileManager.default
        let root = try makeTemporaryDirectory()
        defer { try? fileManager.removeItem(at: root) }
        let directoryURL = try OrbitalViewportSpatGRISLayoutStore.layoutDirectoryURL(
            kind: .speakers,
            resourcesURL: root,
            fileManager: fileManager
        )

        let firstURL = try OrbitalViewportSpatGRISLayoutStore.uniqueLayoutFileURL(
            kind: .speakers,
            in: directoryURL,
            fileManager: fileManager,
            nameProvider: { "Receiver Main" }
        )
        XCTAssertEqual(firstURL.lastPathComponent, "Receiver Main.xml")
        try Data("<broken/>".utf8).write(to: firstURL)

        var names = ["Receiver Main", "Receiver Alt"].makeIterator()
        let secondURL = try OrbitalViewportSpatGRISLayoutStore.uniqueLayoutFileURL(
            kind: .speakers,
            in: directoryURL,
            fileManager: fileManager,
            nameProvider: { names.next() ?? "Receiver Third" }
        )
        XCTAssertEqual(secondURL.lastPathComponent, "Receiver Alt.xml")
        XCTAssertFalse(fileManager.fileExists(atPath: secondURL.path))
    }

    func testCorrectViewerSpatGRISLayoutSaveListAndInvalidRows() throws {
        let fileManager = FileManager.default
        let root = try makeTemporaryDirectory()
        defer { try? fileManager.removeItem(at: root) }
        let first = try OrbitalViewportSpatGRISLayoutStore.writeLayout(
            setup: makeSpatGRISSetup(uuid: "layout-a", x: 1),
            kind: .speakers,
            resourcesURL: root,
            fileManager: fileManager,
            nameProvider: { "Receiver A" }
        )
        let second = try OrbitalViewportSpatGRISLayoutStore.writeLayout(
            setup: makeSpatGRISSetup(uuid: "layout-b", x: -1),
            kind: .speakers,
            resourcesURL: root,
            fileManager: fileManager,
            nameProvider: { "Receiver B" }
        )
        let invalidURL = first.url.deletingLastPathComponent().appendingPathComponent("Broken Layout.xml")
        try Data("not xml".utf8).write(to: invalidURL)
        try fileManager.setAttributes([.modificationDate: Date(timeIntervalSince1970: 2)], ofItemAtPath: first.url.path)
        try fileManager.setAttributes([.modificationDate: Date(timeIntervalSince1970: 3)], ofItemAtPath: second.url.path)
        try fileManager.setAttributes([.modificationDate: Date(timeIntervalSince1970: 1)], ofItemAtPath: invalidURL.path)

        let layouts = try OrbitalViewportSpatGRISLayoutStore.savedLayouts(
            in: first.url.deletingLastPathComponent(),
            fileManager: fileManager
        )

        XCTAssertEqual(layouts.map(\.displayName), ["Receiver B", "Receiver A", "Broken Layout"])
        XCTAssertEqual(layouts[0].layoutID, "layout-b")
        XCTAssertEqual(try XCTUnwrap(layouts[1].setup?.sortedSpeakers.first?.position.x), 1, accuracy: 0.000_001)
        XCTAssertFalse(layouts[2].isValid)
    }

    func testCorrectViewerSpatGRISLayoutDefaultSurvivesManualRenameByLayoutID() throws {
        let fileManager = FileManager.default
        let root = try makeTemporaryDirectory()
        defer { try? fileManager.removeItem(at: root) }
        let saved = try OrbitalViewportSpatGRISLayoutStore.writeLayout(
            setup: makeSpatGRISSetup(uuid: "default-layout", x: 0.5),
            kind: .sources,
            resourcesURL: root,
            fileManager: fileManager,
            nameProvider: { "Source Main" }
        )
        let metadata = try OrbitalViewportSpatGRISLayoutStore.writeDefaultLayout(
            saved,
            kind: .sources,
            fileManager: fileManager
        )
        let renamedURL = saved.url.deletingLastPathComponent().appendingPathComponent("Renamed Source.xml")
        try fileManager.moveItem(at: saved.url, to: renamedURL)
        let layouts = try OrbitalViewportSpatGRISLayoutStore.savedLayouts(
            in: renamedURL.deletingLastPathComponent(),
            fileManager: fileManager
        )
        let defaultLayout = try XCTUnwrap(
            OrbitalViewportSpatGRISLayoutStore.defaultLayout(in: layouts, metadata: metadata)
        )

        XCTAssertEqual(defaultLayout.displayName, "Renamed Source")
        XCTAssertEqual(defaultLayout.layoutID, "default-layout")
        XCTAssertTrue(OrbitalViewportSpatGRISLayoutStore.isDefaultLayout(defaultLayout, metadata: metadata))
    }

    func testCorrectViewerSpatGRISLayoutInvalidDefaultFallsBackWithoutCrash() throws {
        let fileManager = FileManager.default
        let root = try makeTemporaryDirectory()
        defer { try? fileManager.removeItem(at: root) }
        let directoryURL = try OrbitalViewportSpatGRISLayoutStore.layoutDirectoryURL(
            kind: .sources,
            resourcesURL: root,
            fileManager: fileManager
        )
        try Data("not valid json".utf8).write(
            to: OrbitalViewportSpatGRISLayoutStore.defaultLayoutURL(kind: .sources, in: directoryURL)
        )
        let invalidURL = directoryURL.appendingPathComponent("Broken Source.xml")
        try Data("<bad/>".utf8).write(to: invalidURL)

        let layouts = try OrbitalViewportSpatGRISLayoutStore.savedLayouts(in: directoryURL, fileManager: fileManager)

        XCTAssertEqual(layouts.count, 1)
        XCTAssertEqual(layouts[0].displayName, "Broken Source")
        XCTAssertFalse(layouts[0].isValid)
        XCTAssertNil(try? OrbitalViewportSpatGRISLayoutStore.readDefaultLayout(kind: .sources, in: directoryURL))
        XCTAssertNil(
            OrbitalViewportSpatGRISLayoutStore.defaultLayout(
                in: layouts,
                metadata: OrbitalViewportDefaultSpatGRISLayoutMetadata(layoutID: "missing", fileName: "Missing.xml")
            )
        )
    }

    func testCorrectViewerSceneBoundsIncludeImportedSources() throws {
        let speakers = [
            OrbitalViewportSpeaker(channel: 1, label: "One", x: -2, y: 0, z: 0),
            OrbitalViewportSpeaker(channel: 2, label: "Two", x: 2, y: 0, z: 0)
        ]
        let source = OrbitalViewportSourceMarker(
            sourceID: 1,
            label: "Source 01",
            position: try OrbitalViewVector3(x: 0, y: 4, z: 0)
        )

        let bounds = OrbitalViewportSceneBounds3D.enclosing(speakers: speakers, sources: [source])

        XCTAssertEqual(bounds.center.x, 0, accuracy: 0.000_001)
        XCTAssertEqual(bounds.center.y, 2, accuracy: 0.000_001)
        XCTAssertEqual(bounds.halfExtent, 2, accuracy: 0.000_001)
    }

    func testCorrectViewerRibbedSpeakerSphereFitsActiveSpeakerCenters() {
        let speakers = [
            OrbitalViewportSpeaker(channel: 10, label: "A", x: 1, y: 1, z: 1),
            OrbitalViewportSpeaker(channel: 20, label: "B", x: -1, y: -1, z: 1),
            OrbitalViewportSpeaker(channel: 30, label: "C", x: -1, y: 1, z: -1),
            OrbitalViewportSpeaker(channel: 40, label: "D", x: 1, y: -1, z: -1)
        ]
        let fit = OrbitalViewportRibbedSpeakerSphereGeometry.fit(for: speakers)
        let segments = OrbitalViewportRibbedSpeakerSphereGeometry.segments(
            for: speakers,
            verticalRibs: 4,
            horizontalRings: 2
        )

        XCTAssertEqual(fit.center, .zero)
        XCTAssertEqual(fit.radius, sqrt(3), accuracy: 0.000_001)
        XCTAssertFalse(segments.isEmpty)
        XCTAssertTrue(segments.allSatisfy { segment in
            (segment.start - fit.center).length > 0 &&
                (segment.end - fit.center).length > 0
        })
        for segment in segments {
            XCTAssertEqual((segment.start - fit.center).length, fit.radius, accuracy: 0.000_001)
            XCTAssertEqual((segment.end - fit.center).length, fit.radius, accuracy: 0.000_001)
        }
    }

    func testCorrectViewerRibbedSpeakerSphereGeometryIsDeterministicAndDeduplicated() {
        let segments = OrbitalViewportRibbedSpeakerSphereGeometry.segments(
            for: OrbitalViewportSpeaker.referenceSpeakers,
            verticalRibs: 16,
            horizontalRings: 8
        )
        let repeated = OrbitalViewportRibbedSpeakerSphereGeometry.segments(
            for: OrbitalViewportSpeaker.referenceSpeakers,
            verticalRibs: 16,
            horizontalRings: 8
        )
        let keys = segments.map { segment in
            [
                segment.kind.rawValue,
                segment.index,
                Int((segment.start.x * 1_000_000).rounded()),
                Int((segment.start.y * 1_000_000).rounded()),
                Int((segment.start.z * 1_000_000).rounded()),
                Int((segment.end.x * 1_000_000).rounded()),
                Int((segment.end.y * 1_000_000).rounded()),
                Int((segment.end.z * 1_000_000).rounded())
            ]
                .map { String($0) }
                .joined(separator: ":")
        }

        XCTAssertGreaterThan(segments.count, OrbitalViewportSpeaker.referenceSpeakers.count)
        XCTAssertEqual(segments, repeated)
        XCTAssertEqual(Set(keys).count, segments.count)
        XCTAssertTrue(segments.allSatisfy { ($0.end - $0.start).length > 0.000_001 })
    }

    func testCorrectViewerRibbedSpeakerSphereSegmentCountsMatchDefaultMediumAndMaxDensities() {
        let defaultCounts = OrbitalViewportRibbedSpeakerSphereGeometry.segmentCounts(
            verticalRibs: 16,
            horizontalRings: 8
        )
        let mediumCounts = OrbitalViewportRibbedSpeakerSphereGeometry.segmentCounts(
            verticalRibs: 32,
            horizontalRings: 16
        )
        let maxCounts = OrbitalViewportRibbedSpeakerSphereGeometry.segmentCounts(
            verticalRibs: 64,
            horizontalRings: 32
        )

        XCTAssertEqual(defaultCounts.vertical, 768)
        XCTAssertEqual(defaultCounts.horizontal, 384)
        XCTAssertEqual(defaultCounts.total, 1_152)
        XCTAssertEqual(mediumCounts.vertical, 2_304)
        XCTAssertEqual(mediumCounts.horizontal, 1_536)
        XCTAssertEqual(mediumCounts.total, 3_840)
        XCTAssertEqual(maxCounts.vertical, 5_120)
        XCTAssertEqual(maxCounts.horizontal, 3_072)
        XCTAssertEqual(maxCounts.total, 8_192)
    }

    func testCorrectViewerRibbedSpeakerSphereCurvesPreserveDiagnosticSegmentCounts() {
        let curves = OrbitalViewportRibbedSpeakerSphereGeometry.curves(
            for: OrbitalViewportSpeaker.referenceSpeakers,
            verticalRibs: 16,
            horizontalRings: 8
        )
        let verticalCurves = curves.filter { $0.kind == .verticalRib }
        let horizontalCurves = curves.filter { $0.kind == .horizontalRing }
        let counts = OrbitalViewportRibbedSpeakerSphereGeometry.segmentCounts(
            verticalRibs: 16,
            horizontalRings: 8
        )

        XCTAssertEqual(verticalCurves.count, 16)
        XCTAssertEqual(horizontalCurves.count, 8)
        XCTAssertTrue(verticalCurves.allSatisfy { !$0.isClosed })
        XCTAssertTrue(horizontalCurves.allSatisfy { $0.isClosed })
        XCTAssertTrue(verticalCurves.allSatisfy { $0.points.count == 49 })
        XCTAssertTrue(horizontalCurves.allSatisfy { $0.points.count == 48 })
        XCTAssertEqual(verticalCurves.reduce(0) { $0 + $1.segmentCount }, counts.vertical)
        XCTAssertEqual(horizontalCurves.reduce(0) { $0 + $1.segmentCount }, counts.horizontal)
        XCTAssertEqual(curves.reduce(0) { $0 + $1.segmentCount }, counts.total)
    }

    func testCorrectViewerRibbedSpeakerSphereCountsUseEvenSymmetricSpacing() {
        let asymmetricSpeakers = [
            OrbitalViewportSpeaker(channel: 1, label: "Near E", x: 1.2, y: 0.1, z: 0.4),
            OrbitalViewportSpeaker(channel: 2, label: "High N", x: 0.2, y: 1.3, z: 0.8),
            OrbitalViewportSpeaker(channel: 3, label: "Low W", x: -1.1, y: 0.3, z: -0.7),
            OrbitalViewportSpeaker(channel: 4, label: "Rear", x: 0.3, y: -0.9, z: -0.2)
        ]
        let verticalLongitudes = OrbitalViewportRibbedSpeakerSphereGeometry.verticalRibLongitudes(
            for: asymmetricSpeakers,
            count: 4
        )
        XCTAssertEqual(verticalLongitudes.count, 4)
        XCTAssertEqual(verticalLongitudes[0], 0, accuracy: 0.000_001)
        XCTAssertEqual(verticalLongitudes[1], Double.pi * 0.5, accuracy: 0.000_001)
        XCTAssertEqual(verticalLongitudes[2], Double.pi, accuracy: 0.000_001)
        XCTAssertEqual(verticalLongitudes[3], Double.pi * 1.5, accuracy: 0.000_001)

        let latitudes = OrbitalViewportRibbedSpeakerSphereGeometry.horizontalRingLatitudes(
            for: asymmetricSpeakers,
            count: 3
        )
        XCTAssertEqual(latitudes.count, 3)
        XCTAssertEqual(latitudes[0], -Double.pi * 0.25, accuracy: 0.000_001)
        XCTAssertEqual(latitudes[1], 0, accuracy: 0.000_001)
        XCTAssertEqual(latitudes[2], Double.pi * 0.25, accuracy: 0.000_001)

        let fewerSegments = OrbitalViewportRibbedSpeakerSphereGeometry.segments(
            for: asymmetricSpeakers,
            verticalRibs: 4,
            horizontalRings: 1
        )
        let moreSegments = OrbitalViewportRibbedSpeakerSphereGeometry.segments(
            for: asymmetricSpeakers,
            verticalRibs: 8,
            horizontalRings: 4
        )
        XCTAssertGreaterThan(moreSegments.count, fewerSegments.count)
    }

    func testCorrectViewerGeodesicSaturationOnlyUpdatesGeodesicOverlayColors() throws {
        let saturated = makeViewportConfiguration(
            renderStyle: .purple,
            geodesicRenderStyle: .daftPunkBow,
            geodesicSaturation: 1
        )
        let desaturated = makeViewportConfiguration(
            renderStyle: .purple,
            geodesicRenderStyle: .daftPunkBow,
            geodesicSaturation: 0
        )
        let saturatedEquator = try rgbComponents(saturated.geodesicColor(saturated.geodesicTheme.equator))
        let desaturatedEquator = try rgbComponents(desaturated.geodesicColor(desaturated.geodesicTheme.equator))

        XCTAssertGreaterThan(max(saturatedEquator.red, saturatedEquator.green, saturatedEquator.blue) - min(saturatedEquator.red, saturatedEquator.green, saturatedEquator.blue), 0.01)
        XCTAssertLessThan(max(desaturatedEquator.red, desaturatedEquator.green, desaturatedEquator.blue) - min(desaturatedEquator.red, desaturatedEquator.green, desaturatedEquator.blue), 0.001)
        XCTAssertNotEqual(
            OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: saturated),
            OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: desaturated)
        )
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: saturated), OrbitalViewportSpeakerMaterialUpdateKey(configuration: desaturated))
        XCTAssertEqual(saturated.theme.cubeVUHotColor, desaturated.theme.cubeVUHotColor)
    }

    func testCorrectViewerSeparatesSonicSphereSpeakerPaletteFromGeodesicPaletteAndAppSkin() {
        let base = makeViewportConfiguration(renderStyle: .rackMint, geodesicRenderStyle: .purple)
        let speakerPaletteOnly = makeViewportConfiguration(renderStyle: .rackPink, geodesicRenderStyle: .purple)
        let geodesicPaletteOnly = makeViewportConfiguration(renderStyle: .rackMint, geodesicRenderStyle: .rackBlue)

        XCTAssertNotEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: speakerPaletteOnly))
        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: base), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: speakerPaletteOnly))
        XCTAssertNotEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: base), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: geodesicPaletteOnly))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: geodesicPaletteOnly))
        XCTAssertEqual(base.theme.accent, OrbitalViewportTheme(style: .rackMint).accent)
        XCTAssertEqual(geodesicPaletteOnly.geodesicTheme.accent, OrbitalViewportTheme(style: .rackBlue).accent)
    }

    func testCorrectViewerGridPlaneTuningStaysOutOfSpeakerAndRibbedKeys() {
        let base = makeViewportConfiguration(renderStyle: .rackMint, geodesicRenderStyle: .purple, showGridPlane: false)
        let gridShown = makeViewportConfiguration(renderStyle: .rackMint, geodesicRenderStyle: .purple, showGridPlane: true)
        let gridVisibility = makeViewportConfiguration(
            renderStyle: .rackMint,
            geodesicRenderStyle: .purple,
            showGridPlane: true,
            gridPlaneVisibility: 0.92
        )
        let gridSpacing = makeViewportConfiguration(
            renderStyle: .rackMint,
            geodesicRenderStyle: .purple,
            showGridPlane: true,
            gridPlaneSpacing: 0.75
        )
        let groundPalette = makeViewportConfiguration(
            renderStyle: .rackMint,
            geodesicRenderStyle: .purple,
            showGridPlane: true,
            gridPlaneRenderStyle: .rackBlue
        )
        let geodesicPalette = makeViewportConfiguration(
            renderStyle: .rackMint,
            geodesicRenderStyle: .rackBlue,
            geodesicSaturation: 0.3,
            showGridPlane: true
        )

        XCTAssertNotEqual(OrbitalViewportGridPlaneUpdateKey(configuration: base), OrbitalViewportGridPlaneUpdateKey(configuration: gridShown))
        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: base), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: gridShown))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: gridShown))
        XCTAssertEqual(OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: gridShown))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: gridShown))

        XCTAssertNotEqual(OrbitalViewportGridPlaneUpdateKey(configuration: gridShown), OrbitalViewportGridPlaneUpdateKey(configuration: gridVisibility))
        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: gridShown), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: gridVisibility))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: gridShown), OrbitalViewportSpeakerGeometryUpdateKey(configuration: gridVisibility))
        XCTAssertEqual(OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: gridShown), OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: gridVisibility))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: gridShown), OrbitalViewportSpeakerMaterialUpdateKey(configuration: gridVisibility))

        XCTAssertNotEqual(OrbitalViewportGridPlaneUpdateKey(configuration: gridShown), OrbitalViewportGridPlaneUpdateKey(configuration: gridSpacing))
        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: gridShown), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: gridSpacing))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: gridShown), OrbitalViewportSpeakerGeometryUpdateKey(configuration: gridSpacing))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: gridShown), OrbitalViewportSpeakerMaterialUpdateKey(configuration: gridSpacing))

        XCTAssertNotEqual(OrbitalViewportGridPlaneUpdateKey(configuration: gridShown), OrbitalViewportGridPlaneUpdateKey(configuration: groundPalette))
        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: gridShown), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: groundPalette))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: gridShown), OrbitalViewportSpeakerGeometryUpdateKey(configuration: groundPalette))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: gridShown), OrbitalViewportSpeakerMaterialUpdateKey(configuration: groundPalette))

        XCTAssertEqual(OrbitalViewportGridPlaneUpdateKey(configuration: gridShown), OrbitalViewportGridPlaneUpdateKey(configuration: geodesicPalette))
        XCTAssertNotEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: gridShown), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: geodesicPalette))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: gridShown), OrbitalViewportSpeakerGeometryUpdateKey(configuration: geodesicPalette))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: gridShown), OrbitalViewportSpeakerMaterialUpdateKey(configuration: geodesicPalette))
    }

    func testCorrectViewerRibbedSpeakerSphereUsesGeodesicThemeAndStaysIndependentFromDeprecatedShell() {
        let base = makeViewportConfiguration(
            geodesicRenderStyle: .purple,
            showRibbedSpeakerSphere: false,
            showGridPlane: true
        )
        let ribbedShown = makeViewportConfiguration(
            geodesicRenderStyle: .purple,
            showRibbedSpeakerSphere: true,
            showGridPlane: true
        )
        let geodesicPalette = makeViewportConfiguration(
            geodesicRenderStyle: .rackBlue,
            geodesicSaturation: 0.42,
            showRibbedSpeakerSphere: true,
            showGridPlane: true
        )
        let thicker = makeViewportConfiguration(
            geodesicRenderStyle: .purple,
            showRibbedSpeakerSphere: true,
            ribbedSphereThickness: 1.8,
            showGridPlane: true
        )
        let moreRibs = makeViewportConfiguration(
            geodesicRenderStyle: .purple,
            showRibbedSpeakerSphere: true,
            ribbedSphereVerticalRibs: 24,
            ribbedSphereHorizontalRings: 12,
            showGridPlane: true
        )

        XCTAssertNotEqual(
            OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: base),
            OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: ribbedShown)
        )
        XCTAssertNotEqual(
            OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: ribbedShown),
            OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: geodesicPalette)
        )
        XCTAssertNotEqual(
            OrbitalViewportRibbedSpeakerSphereTopologyKey(configuration: ribbedShown),
            OrbitalViewportRibbedSpeakerSphereTopologyKey(configuration: thicker)
        )
        XCTAssertNotEqual(
            OrbitalViewportRibbedSpeakerSphereTopologyKey(configuration: ribbedShown),
            OrbitalViewportRibbedSpeakerSphereTopologyKey(configuration: moreRibs)
        )
        XCTAssertEqual(
            OrbitalViewportGridPlaneUpdateKey(configuration: ribbedShown),
            OrbitalViewportGridPlaneUpdateKey(configuration: geodesicPalette)
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerGeometryUpdateKey(configuration: ribbedShown),
            OrbitalViewportSpeakerGeometryUpdateKey(configuration: geodesicPalette)
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: ribbedShown),
            OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: geodesicPalette)
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerMaterialUpdateKey(configuration: ribbedShown),
            OrbitalViewportSpeakerMaterialUpdateKey(configuration: geodesicPalette)
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerGeometryUpdateKey(configuration: ribbedShown),
            OrbitalViewportSpeakerGeometryUpdateKey(configuration: thicker)
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerMaterialUpdateKey(configuration: ribbedShown),
            OrbitalViewportSpeakerMaterialUpdateKey(configuration: moreRibs)
        )
    }

    func testCorrectViewerSourceSpeakerPaletteIsIndependentFromSonicSphereSpeakerPalette() throws {
        let source = OrbitalViewportSourceMarker(
            sourceID: 1,
            label: "Source 01",
            position: try OrbitalViewVector3(x: 0.4, y: 0.2, z: 0.6)
        )
        let base = makeViewportConfiguration(
            renderStyle: .purple,
            sourceSpeakerRenderStyle: .purple,
            sources: [source]
        )
        let sourcePalette = makeViewportConfiguration(
            renderStyle: .purple,
            sourceSpeakerRenderStyle: .rackBlue,
            sources: [source]
        )
        let speakerPalette = makeViewportConfiguration(
            renderStyle: .rackBlue,
            sourceSpeakerRenderStyle: .purple,
            sources: [source]
        )

        XCTAssertNotEqual(
            OrbitalViewportSourceMaterialUpdateKey(configuration: base),
            OrbitalViewportSourceMaterialUpdateKey(configuration: sourcePalette)
        )
        XCTAssertEqual(
            OrbitalViewportSourcePoseUpdateKey(configuration: base),
            OrbitalViewportSourcePoseUpdateKey(configuration: sourcePalette)
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerMaterialUpdateKey(configuration: base),
            OrbitalViewportSpeakerMaterialUpdateKey(configuration: sourcePalette)
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerGeometryUpdateKey(configuration: base),
            OrbitalViewportSpeakerGeometryUpdateKey(configuration: sourcePalette)
        )
        XCTAssertEqual(
            OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: base),
            OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: sourcePalette)
        )
        XCTAssertEqual(
            OrbitalViewportRibbedSpeakerSphereTopologyKey(configuration: base),
            OrbitalViewportRibbedSpeakerSphereTopologyKey(configuration: sourcePalette)
        )

        XCTAssertNotEqual(
            OrbitalViewportSpeakerMaterialUpdateKey(configuration: base),
            OrbitalViewportSpeakerMaterialUpdateKey(configuration: speakerPalette)
        )
        XCTAssertEqual(
            OrbitalViewportSourceMaterialUpdateKey(configuration: base),
            OrbitalViewportSourceMaterialUpdateKey(configuration: speakerPalette)
        )
    }

    func testCorrectViewerGridPlaneGeometryUsesCanonicalOffsetAndStableLineCount() {
        let lines = OrbitalViewportGridPlaneGeometry.lineSegments

        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.canonicalZ, -1.2, accuracy: 0.000_001)
        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.halfExtent, 5.0, accuracy: 0.000_001)
        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.defaultSpacing, 0.5, accuracy: 0.000_001)
        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.spacingRange, 0.25...1.0)
        XCTAssertEqual(lines.count, 42)
        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.lineSegments(spacing: 0.25).count, 82)
        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.lineSegments(spacing: 1.0).count, 22)
        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.normalizedSpacing(0.1), 0.25)
        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.normalizedSpacing(2.0), 1.0)
        XCTAssertEqual(lines.filter(\.isMajor).count, 2)
        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider, 70, accuracy: 0.000_001)
        XCTAssertEqual(OrbitalViewportGridPlaneGeometry.defaultVisibility, 0.7, accuracy: 0.000_001)
        XCTAssertEqual(
            OrbitalViewportGridPlaneGeometry.alpha(for: lines.first { !$0.isMajor }!, visibility: 0.7),
            0.315,
            accuracy: 0.000_001
        )
        XCTAssertEqual(
            OrbitalViewportGridPlaneGeometry.alpha(for: lines.first { $0.isMajor }!, visibility: 0.7),
            0.56,
            accuracy: 0.000_001
        )
        XCTAssertTrue(lines.allSatisfy { line in
            abs(line.start.z + 1.2) < 0.000_001 &&
                abs(line.end.z + 1.2) < 0.000_001
        })
        XCTAssertTrue(lines.contains { line in
            line.isMajor &&
                abs(line.start.x) < 0.000_001 &&
                abs(line.end.x) < 0.000_001 &&
                abs(line.start.y + 5.0) < 0.000_001 &&
                abs(line.end.y - 5.0) < 0.000_001
        })
        XCTAssertTrue(lines.contains { line in
            line.isMajor &&
                abs(line.start.x + 5.0) < 0.000_001 &&
                abs(line.end.x - 5.0) < 0.000_001 &&
                abs(line.start.y) < 0.000_001 &&
                abs(line.end.y) < 0.000_001
        })
    }

    func testCorrectViewerKeepsMeterOnlyTicksOutOfStaticGeometry() {
        let base = makeViewportConfiguration(timeMS: 1_000)
        let meterOnly = base.frameConfiguration(timeMS: 1_200)

        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: base), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: meterOnly))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: meterOnly))
        XCTAssertEqual(OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: meterOnly))
        XCTAssertEqual(OrbitalViewportSpeakerVisibilityUpdateKey(configuration: base), OrbitalViewportSpeakerVisibilityUpdateKey(configuration: meterOnly))
        XCTAssertNotEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: meterOnly))
    }

    func testReviewFrameRateOptionsInclude120() {
        XCTAssertEqual(OrbitalViewportFrameRate.allCases.map(\.framesPerSecond), [30, 60, 120])
        XCTAssertEqual(OrbitalViewportFrameRate.oneTwenty.title, "120 FPS")
        XCTAssertEqual(OrbitalViewportFrameRate.normalized(120), 120)
        XCTAssertEqual(OrbitalViewportFrameRate.normalized(90), 120)
    }

    func testFrameCadenceBuckets120ActiveAnd30MeterDisplay() {
        let cadence = OrbitalViewportFrameCadence(
            activeFramesPerSecond: 120,
            meterDisplayFramesPerSecond: 30,
            inspectorFramesPerSecond: 10
        )

        XCTAssertEqual(cadence.activeFrameIndex(timeMS: 1_000), 120)
        XCTAssertEqual(cadence.activeFrameIndex(timeMS: 1_008), 120)
        XCTAssertEqual(cadence.activeFrameIndex(timeMS: 1_009), 121)
        XCTAssertEqual(cadence.meterDisplayFrameIndex(timeMS: 1_000), 30)
        XCTAssertEqual(cadence.meterDisplayFrameIndex(timeMS: 1_008), 30)
        XCTAssertEqual(cadence.meterDisplayFrameIndex(timeMS: 1_034), 31)
        XCTAssertEqual(cadence.inspectorFrameIndex(timeMS: 1_000), 10)
        XCTAssertEqual(cadence.inspectorFrameIndex(timeMS: 1_099), 10)
        XCTAssertEqual(cadence.inspectorFrameIndex(timeMS: 1_100), 11)
    }

    func testSchedulerTargetsActiveFPSOnlyDuringActiveMotion() {
        XCTAssertEqual(
            OrbitalViewportRenderScheduler.targetFramesPerSecond(
                activeFramesPerSecond: 120,
                meterOnlyFramesPerSecond: 30,
                isActiveMotion: true
            ),
            120
        )
        XCTAssertEqual(
            OrbitalViewportRenderScheduler.targetFramesPerSecond(
                activeFramesPerSecond: 120,
                meterOnlyFramesPerSecond: 30,
                isActiveMotion: false
            ),
            30
        )
    }

    func testSpeakerMaterialKeyUsesMeterDisplayCadenceNotActiveCadence() {
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30
        )
        let sameMeterBucket = base.frameConfiguration(timeMS: 1_008)
        let nextMeterBucket = base.frameConfiguration(timeMS: 1_034)

        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: sameMeterBucket))
        XCTAssertNotEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: nextMeterBucket))
    }

    func testSpeakerMaterialKeyRefreshesFogWithoutBreakingActiveSpinCadence() {
        let base = makeViewportConfiguration(timeMS: 1_000, showRibbedSpeakerSphere: true, fogDensity: 20)
        let fogOnly = makeViewportConfiguration(timeMS: 1_000, showRibbedSpeakerSphere: true, fogDensity: 100)
        let spinning = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true,
            fogDensity: 20,
            spin: true,
            spinStartYaw: 0,
            spinStartTimeMS: 1_000
        )
        let sameSpinBucket = spinning.frameConfiguration(timeMS: 1_008)
        let nextSpinBucket = spinning.frameConfiguration(timeMS: 1_034)

        XCTAssertNotEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: fogOnly))
        XCTAssertNotEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: base), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: fogOnly))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: spinning), OrbitalViewportSpeakerMaterialUpdateKey(configuration: sameSpinBucket))
        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: spinning), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: sameSpinBucket))
        XCTAssertNotEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: spinning), OrbitalViewportSpeakerMaterialUpdateKey(configuration: nextSpinBucket))
        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: spinning), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: nextSpinBucket))
    }

    func testSourcePoseAndSourceMaterialKeysTrackDepthAndCadence() throws {
        let source = OrbitalViewportSourceMarker(
            sourceID: 1,
            label: "Source 01",
            position: try OrbitalViewVector3(x: 0.25, y: 0.15, z: 0.7)
        )
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            sources: [source]
        )
        let cameraOnly = makeViewportConfiguration(
            timeMS: 1_008,
            yaw: 0.02,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            sources: [source]
        )
        let meterOnly = makeViewportConfiguration(
            timeMS: 1_034,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            sources: [source]
        )

        XCTAssertNotEqual(OrbitalViewportSourcePoseUpdateKey(configuration: base), OrbitalViewportSourcePoseUpdateKey(configuration: cameraOnly))
        XCTAssertEqual(OrbitalViewportSourceMaterialUpdateKey(configuration: base), OrbitalViewportSourceMaterialUpdateKey(configuration: cameraOnly))
        XCTAssertEqual(OrbitalViewportSourcePoseUpdateKey(configuration: base), OrbitalViewportSourcePoseUpdateKey(configuration: meterOnly))
        XCTAssertNotEqual(OrbitalViewportSourceMaterialUpdateKey(configuration: base), OrbitalViewportSourceMaterialUpdateKey(configuration: meterOnly))
    }

    func testCorrectViewerSeparatesSpeakerLabelFontFromSpeakerGeometry() {
        let base = makeViewportConfiguration(timeMS: 1_000, speakerLabelFont: .systemDefault)
        let fontOnly = makeViewportConfiguration(timeMS: 1_000, speakerLabelFont: .minecraft)
        let sizeOnly = makeViewportConfiguration(timeMS: 1_000, speakerLabelSizeScale: 1.24)

        XCTAssertEqual(OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: base), OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: fontOnly))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: fontOnly))
        XCTAssertNotEqual(OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: fontOnly))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: fontOnly))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: sizeOnly))
        XCTAssertNotEqual(OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: sizeOnly))
    }

    func testCorrectViewerSeparatesGeometryMaterialAndIgnoredHeightTuningKeys() {
        let base = makeViewportConfiguration(timeMS: 1_000)
        var materialOnlySettings = OrbitalViewportCubeVUSettings.default
        materialOnlySettings.paletteDrive = 2.6
        materialOnlySettings.cubeOutlineStrength = 0.7
        materialOnlySettings.pixelFill = 0.5
        materialOnlySettings.surfaceCheckerOpacity = 0.35
        var heightSettings = OrbitalViewportCubeVUSettings.default
        heightSettings.speakerHeight = 1.35

        let materialOnly = makeViewportConfiguration(timeMS: 1_000, cubeVUSettings: materialOnlySettings)
        let heightChange = makeViewportConfiguration(timeMS: 1_000, cubeVUSettings: heightSettings)
        let cubeVUType = makeViewportConfiguration(timeMS: 1_000, speakerShape: .cubeVU)

        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: materialOnly))
        XCTAssertNotEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: materialOnly))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: heightChange))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: heightChange))
        XCTAssertNotEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: cubeVUType))
    }

    #if os(macOS)
    func testCorrectViewerSceneKitDefaultsDrawOnDemandAtSixtyFPS() {
        XCTAssertFalse(OrbitalViewport3DSceneView.rendersContinuously)
        XCTAssertEqual(OrbitalViewport3DSceneView.sceneFramesPerSecond, 120)
    }

    func testCorrectViewerBundledSpeakerLabelFontsResolveFromResourceBundle() {
        XCTAssertNotNil(OrbitalViewportFontRegistry.resourceURL(fileName: "PressStart2P-Regular.ttf"))
        XCTAssertNotNil(OrbitalViewportFontRegistry.resourceURL(fileName: "Minecraft.ttf"))
        XCTAssertNotNil(OrbitalViewportFontRegistry.resourceURL(fileName: "chintzy.ttf"))
        XCTAssertNotNil(OrbitalViewportFontRegistry.resourceURL(fileName: "ArchivoBlack-Regular.ttf"))
        XCTAssertNotNil(OrbitalViewportFontRegistry.resourceURL(fileName: "Jost-Regular.ttf"))
        XCTAssertNotNil(OrbitalViewportFontRegistry.resourceURL(fileName: "Michroma-Regular.ttf"))
        XCTAssertNotNil(OrbitalViewportFontRegistry.resourceURL(fileName: "Sevastopol-Interface.ttf"))
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.pressStart2P.nsFont(pointSize: 12).fontName, "PressStart2P-Regular")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.minecraft.nsFont(pointSize: 12).fontName, "Minecraft")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.chintzyCPU.nsFont(pointSize: 12).fontName, "ChintzyCPUBRK")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.archivoBlack.nsFont(pointSize: 12).fontName, "ArchivoBlack-Regular")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.jost.nsFont(pointSize: 12).fontName, "Jost-Regular")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.michroma.nsFont(pointSize: 12).fontName, "Michroma-Regular")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.sevastopolInterface.nsFont(pointSize: 12).fontName, "Sevastopol-Interface")
    }

    func testCorrectViewerFontRegistryUsesDirectResourceBundlePaths() throws {
        let baseURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fontsURL = baseURL.appendingPathComponent("Fonts", isDirectory: true)
        try FileManager.default.createDirectory(at: fontsURL, withIntermediateDirectories: true)
        try Data("font".utf8).write(to: fontsURL.appendingPathComponent("Nested-Regular.ttf"))
        try Data("root".utf8).write(to: baseURL.appendingPathComponent("Root-Regular.ttf"))
        defer {
            try? FileManager.default.removeItem(at: baseURL)
        }

        XCTAssertEqual(
            OrbitalViewportFontRegistry.resourceURL(fileName: "Nested-Regular.ttf", baseURL: baseURL),
            fontsURL.appendingPathComponent("Nested-Regular.ttf")
        )
        XCTAssertEqual(
            OrbitalViewportFontRegistry.resourceURL(fileName: "Root-Regular.ttf", baseURL: baseURL),
            baseURL.appendingPathComponent("Root-Regular.ttf")
        )
        XCTAssertNil(OrbitalViewportFontRegistry.resourceURL(fileName: "Missing-Regular.ttf", baseURL: baseURL))
    }

    func testCorrectViewerCommercialSpeakerLabelFontsAreInstallOnlyAndFallbackSafe() {
        let installOnlyFonts: [OrbitalViewportSpeakerLabelFont] = [
            .helveticaBlack,
            .futura
        ]

        for font in installOnlyFonts {
            XCTAssertEqual(font.group, .normie)
            XCTAssertTrue(font.resourceFileNames.isEmpty)
            XCTAssertFalse(font.postScriptNameCandidates.isEmpty)
            XCTAssertTrue(["Installed", "Not installed - uses System Default"].contains(font.availabilityNote))
            XCTAssertGreaterThan(font.nsFont(pointSize: 12).pointSize, 0)
        }
    }

    func testCorrectViewerMinecraftSpeakerLabelZeroUsesReadableGlyphFallback() {
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.systemDefault.speakerLabelText(channel: 1), "01")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.pressStart2P.speakerLabelText(channel: 10), "10")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.minecraft.speakerLabelText(channel: 1), "O1")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.minecraft.speakerLabelText(channel: 10), "1O")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.chintzyCPU.speakerLabelText(channel: 20), "20")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.sevastopolInterface.speakerLabelText(channel: 10), "10")
    }

    func testCorrectViewerJostUsesStaticRegularFontForReadableSixAndNine() {
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.jost.resourceFileNames, ["Jost-Regular.ttf"])
        XCTAssertTrue(OrbitalViewportSpeakerLabelFont.jost.usesTextureBackedSceneKitLabel)
        XCTAssertLessThanOrEqual(OrbitalViewportSpeakerLabelFont.jost.sceneKitTextFlatness, 0.025)
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.jost.speakerLabelText(channel: 6), "06")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.jost.speakerLabelText(channel: 9), "09")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.jost.speakerLabelText(channel: 16), "16")
        XCTAssertEqual(OrbitalViewportSpeakerLabelFont.jost.speakerLabelText(channel: 29), "29")
        XCTAssertFalse(OrbitalViewportSpeakerLabelFont.systemDefault.usesTextureBackedSceneKitLabel)
        XCTAssertGreaterThan(OrbitalViewportSceneMetrics.speakerLabelTextureWidth, 0)
        XCTAssertGreaterThan(OrbitalViewportSceneMetrics.speakerLabelTextureHeight, 0)
    }

    func testCorrectViewerFontOnlyUpdateRebuildsLabelsOnly() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(timeMS: 1_000)
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        let speakerRebuildCount = coordinator.speakerRebuildCount
        let labelRebuildCount = coordinator.labelRebuildCount

        let fontOnly = makeViewportConfiguration(timeMS: 1_000, speakerLabelFont: .chintzyCPU)
        coordinator.update(
            configuration: fontOnly,
            snapshot: OrbitalViewportSnapshot(configuration: fontOnly)
        )

        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertGreaterThan(coordinator.labelRebuildCount, labelRebuildCount)

        let labelsAfterFontChange = coordinator.labelRebuildCount
        let sizeOnly = makeViewportConfiguration(
            timeMS: 1_000,
            speakerLabelFont: .chintzyCPU,
            speakerLabelSizeScale: 1.28
        )
        coordinator.update(
            configuration: sizeOnly,
            snapshot: OrbitalViewportSnapshot(configuration: sizeOnly)
        )

        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertGreaterThan(coordinator.labelRebuildCount, labelsAfterFontChange)

        let labelsAfterSizeChange = coordinator.labelRebuildCount
        let meterOnly = sizeOnly.frameConfiguration(timeMS: 1_250)
        coordinator.update(
            configuration: meterOnly,
            snapshot: OrbitalViewportSnapshot(configuration: meterOnly)
        )

        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertEqual(coordinator.labelRebuildCount, labelsAfterSizeChange)
    }

    func testCorrectViewerSceneKitRibbedSphereToggleDoesNotRebuildSpeakersOrLabels() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let hidden = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: false
        )
        coordinator.update(
            configuration: hidden,
            snapshot: OrbitalViewportSnapshot(configuration: hidden)
        )

        let ribbedSphereBuildCount = coordinator.ribbedSphereBuildCount
        let speakerRebuildCount = coordinator.speakerRebuildCount
        let labelRebuildCount = coordinator.labelRebuildCount

        XCTAssertTrue(coordinator.ribbedSphereNode.isHidden)

        let shown = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true
        )
        coordinator.update(
            configuration: shown,
            snapshot: OrbitalViewportSnapshot(configuration: shown)
        )

        XCTAssertFalse(coordinator.ribbedSphereNode.isHidden)
        XCTAssertEqual(coordinator.ribbedSphereBuildCount, ribbedSphereBuildCount)
        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertEqual(coordinator.labelRebuildCount, labelRebuildCount)

        let moreRibs = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true,
            ribbedSphereThickness: 1.6,
            ribbedSphereVerticalRibs: 24,
            ribbedSphereHorizontalRings: 12
        )
        coordinator.update(
            configuration: moreRibs,
            snapshot: OrbitalViewportSnapshot(configuration: moreRibs)
        )

        XCTAssertFalse(coordinator.ribbedSphereNode.isHidden)
        XCTAssertGreaterThan(coordinator.ribbedSphereBuildCount, ribbedSphereBuildCount)
        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertEqual(coordinator.labelRebuildCount, labelRebuildCount)
    }

    func testCorrectViewerSceneKitGeodesicSaturationUpdatesRibbedSphereMaterial() throws {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let saturated = makeViewportConfiguration(
            timeMS: 1_000,
            geodesicRenderStyle: .daftPunkBow,
            geodesicSaturation: 1,
            showRibbedSpeakerSphere: true
        )
        coordinator.update(
            configuration: saturated,
            snapshot: OrbitalViewportSnapshot(configuration: saturated)
        )

        let ribbedSphereBuildCount = coordinator.ribbedSphereBuildCount
        let speakerRebuildCount = coordinator.speakerRebuildCount
        let labelRebuildCount = coordinator.labelRebuildCount
        let saturatedSpread = try rgbSpread(firstRibbedSphereDiffuseColor(in: coordinator))

        let desaturated = makeViewportConfiguration(
            timeMS: 1_000,
            geodesicRenderStyle: .daftPunkBow,
            geodesicSaturation: 0,
            showRibbedSpeakerSphere: true
        )
        coordinator.update(
            configuration: desaturated,
            snapshot: OrbitalViewportSnapshot(configuration: desaturated)
        )
        let desaturatedSpread = try rgbSpread(firstRibbedSphereDiffuseColor(in: coordinator))

        XCTAssertGreaterThan(saturatedSpread, 0.01)
        XCTAssertLessThan(desaturatedSpread, 0.001)
        XCTAssertEqual(coordinator.ribbedSphereBuildCount, ribbedSphereBuildCount)
        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertEqual(coordinator.labelRebuildCount, labelRebuildCount)
    }

    func testCorrectViewerSceneKitRibbedSphereUsesBatchedSceneNodes() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let shown = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true
        )

        coordinator.resetInstrumentationForTests()
        coordinator.update(
            configuration: shown,
            snapshot: OrbitalViewportSnapshot(configuration: shown)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertFalse(coordinator.ribbedSphereNode.isHidden)
        XCTAssertEqual(coordinator.ribbedSphereSceneNodeCountForTests, 2)
        XCTAssertEqual(coordinator.ribbedSphereSegmentCountForTests, 1_152)
        XCTAssertEqual(snapshot.ribbedSphereTopologyBuildCount, 1)
        XCTAssertEqual(snapshot.ribbedSphereSegmentNodeBuildCount, 2)
        XCTAssertEqual(snapshot.ribbedSphereMaterialWriteCount, 2)
    }

    func testCorrectViewerSceneKitRibbedSphereUsesWeldedCurveTubeBatches() throws {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let shown = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true
        )

        coordinator.update(
            configuration: shown,
            snapshot: OrbitalViewportSnapshot(configuration: shown)
        )

        let verticalNode = try XCTUnwrap(
            coordinator.ribbedSphereNode.childNodes.first { $0.name == "ribbed-speaker-sphere-vertical-ribs" }
        )
        let horizontalNode = try XCTUnwrap(
            coordinator.ribbedSphereNode.childNodes.first { $0.name == "ribbed-speaker-sphere-horizontal-rings" }
        )
        let verticalVertexCount = try XCTUnwrap(verticalNode.geometry?.sources(for: .vertex).first?.vectorCount)
        let horizontalVertexCount = try XCTUnwrap(horizontalNode.geometry?.sources(for: .vertex).first?.vectorCount)

        XCTAssertEqual(coordinator.ribbedSphereSceneNodeCountForTests, 2)
        XCTAssertEqual(coordinator.ribbedSphereSegmentCountForTests, 1_152)
        XCTAssertEqual(verticalVertexCount, 16 * ((49 * 6) + 2))
        XCTAssertEqual(horizontalVertexCount, 8 * 48 * 6)
    }

    func testCorrectViewerSceneKitRibbedSphereUsesOpaqueBrightnessMaterialForCutawayDepth() throws {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let shown = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true,
            showHiddenLines: false
        )

        coordinator.update(
            configuration: shown,
            snapshot: OrbitalViewportSnapshot(configuration: shown)
        )

        let material = try XCTUnwrap(coordinator.ribbedSphereNode.childNodes.first?.geometry?.firstMaterial)
        let diffuse = try XCTUnwrap(material.diffuse.contents as? NSColor)
        let rgb = try XCTUnwrap(diffuse.usingColorSpace(.deviceRGB) ?? diffuse.usingColorSpace(.sRGB))

        XCTAssertEqual(material.transparency, 1, accuracy: 0.000_001)
        XCTAssertEqual(rgb.alphaComponent, 1, accuracy: 0.000_001)
        XCTAssertTrue(material.readsFromDepthBuffer)
        XCTAssertTrue(material.writesToDepthBuffer)
        XCTAssertTrue(
            material.shaderModifiers?[.geometry]?.contains("orbitalRibbedFogDistance") == true
        )
        XCTAssertTrue(
            material.shaderModifiers?[.surface]?.contains("orbitalRibbedFogAmount") == true
        )
        XCTAssertNotNil(material.value(forKey: "orbitalRibbedFogStartDistance"))
        XCTAssertNotNil(material.value(forKey: "orbitalRibbedFogColor"))
        XCTAssertEqual(coordinator.ribbedSphereCutawayPlaneHiddenForTests, false)
    }

    func testCorrectViewerHiddenLinesToggleControlsRearSceneKitSpeakersAndLabels() throws {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let hidden = makeViewportConfiguration(
            timeMS: 1_000,
            showSpeakerNumbers: true,
            showHiddenLines: false
        )
        let hiddenSnapshot = OrbitalViewportSnapshot(configuration: hidden)
        let rearSpeaker = try XCTUnwrap(
            hiddenSnapshot.speakers.first { $0.depth < hidden.frontClipPlane - 0.02 }
        )
        coordinator.update(configuration: hidden, snapshot: hiddenSnapshot)

        XCTAssertEqual(coordinator.speakerNodeHiddenForTests(channel: rearSpeaker.channel), true)
        XCTAssertEqual(coordinator.speakerLabelNodeHiddenForTests(channel: rearSpeaker.channel), true)
        XCTAssertFalse(hidden.speakerLabelVisible(depth: rearSpeaker.depth, selected: false))

        coordinator.resetInstrumentationForTests()
        let shown = makeViewportConfiguration(
            timeMS: 1_000,
            showSpeakerNumbers: true,
            showHiddenLines: true
        )
        coordinator.update(
            configuration: shown,
            snapshot: OrbitalViewportSnapshot(configuration: shown)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(coordinator.speakerNodeHiddenForTests(channel: rearSpeaker.channel), false)
        XCTAssertEqual(coordinator.speakerLabelNodeHiddenForTests(channel: rearSpeaker.channel), false)
        XCTAssertTrue(shown.speakerLabelVisible(depth: rearSpeaker.depth, selected: false))
        XCTAssertEqual(snapshot.speakerVisibilityUpdateCount, 1)
        XCTAssertEqual(snapshot.needsDisplayCount, 1)
    }

    func testCorrectViewerSelectedRearSpeakerLabelStaysVisibleWhenHiddenLinesAreOff() throws {
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            showSpeakerNumbers: true,
            showHiddenLines: false
        )
        let rearSpeaker = try XCTUnwrap(
            OrbitalViewportSnapshot(configuration: base).speakers.first { $0.depth < base.frontClipPlane - 0.02 }
        )

        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let selected = makeViewportConfiguration(
            timeMS: 1_000,
            showSpeakerNumbers: true,
            showHiddenLines: false,
            selectedChannel: rearSpeaker.channel
        )
        coordinator.update(
            configuration: selected,
            snapshot: OrbitalViewportSnapshot(configuration: selected)
        )

        XCTAssertEqual(coordinator.speakerNodeHiddenForTests(channel: rearSpeaker.channel), true)
        XCTAssertEqual(coordinator.speakerLabelNodeHiddenForTests(channel: rearSpeaker.channel), false)
        XCTAssertTrue(selected.speakerLabelVisible(depth: rearSpeaker.depth, selected: true))
    }

    func testCorrectViewerHiddenLinesToggleUpdatesRibbedSphereCutawayWithoutTopologyRebuild() throws {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let hidden = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true,
            showHiddenLines: false
        )
        coordinator.update(
            configuration: hidden,
            snapshot: OrbitalViewportSnapshot(configuration: hidden)
        )

        let ribbedSphereBuildCount = coordinator.ribbedSphereBuildCount
        XCTAssertTrue(
            coordinator.firstRibbedSphereCutawayShaderForTests?.contains("orbitalRibbedFogAmount") == true
        )
        XCTAssertTrue(
            coordinator.firstRibbedSphereCutawayGeometryShaderForTests?.contains("orbitalRibbedFogDistance") == true
        )
        XCTAssertEqual(coordinator.firstRibbedSphereCutawayHiddenLinesVisibleForTests, false)
        XCTAssertEqual(coordinator.ribbedSphereCutawayPlaneHiddenForTests, false)
        XCTAssertEqual(coordinator.ribbedSphereSceneNodeCountForTests, 2)

        let viewDirection = hidden.orbitState.cameraBasis.viewDirection
        let fit = OrbitalViewportRibbedSpeakerSphereGeometry.fit(
            for: hidden.speakers,
            fallbackRadius: hidden.sceneScale
        )
        let frontPoint = fit.center + (viewDirection * fit.radius)
        let rearPoint = fit.center - (viewDirection * fit.radius)
        let frontDepth = try XCTUnwrap(coordinator.firstRibbedSphereCutawayDepthForTests(point: frontPoint))
        let rearDepth = try XCTUnwrap(coordinator.firstRibbedSphereCutawayDepthForTests(point: rearPoint))

        XCTAssertGreaterThan(frontDepth, 0)
        XCTAssertLessThan(rearDepth, 0)
        XCTAssertEqual(coordinator.firstRibbedSphereCutawayVisibleForTests(point: frontPoint), true)
        XCTAssertEqual(coordinator.firstRibbedSphereCutawayVisibleForTests(point: rearPoint), false)

        coordinator.resetInstrumentationForTests()
        let shown = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true,
            showHiddenLines: true
        )
        coordinator.update(
            configuration: shown,
            snapshot: OrbitalViewportSnapshot(configuration: shown)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(coordinator.firstRibbedSphereCutawayHiddenLinesVisibleForTests, true)
        XCTAssertEqual(coordinator.ribbedSphereCutawayPlaneHiddenForTests, true)
        XCTAssertEqual(coordinator.firstRibbedSphereCutawayVisibleForTests(point: rearPoint), true)
        XCTAssertEqual(coordinator.ribbedSphereBuildCount, ribbedSphereBuildCount)
        XCTAssertEqual(coordinator.ribbedSphereSceneNodeCountForTests, 2)
        XCTAssertEqual(snapshot.ribbedSphereTopologyBuildCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereSegmentVisitCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialUpdateCount, 1)
        XCTAssertEqual(snapshot.ribbedSphereMaterialWriteCount, 2)
    }

    func testCorrectViewerFogUpdatesRibbedSphereMaterialAndCutawayWithoutTopologyRebuild() throws {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true,
            fogDensity: 20,
            showHiddenLines: false
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )
        let basePlane = try XCTUnwrap(coordinator.firstRibbedSphereCutawayFrontClipPlaneForTests)

        coordinator.resetInstrumentationForTests()
        let dense = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true,
            fogDensity: 100,
            showHiddenLines: false
        )
        coordinator.update(
            configuration: dense,
            snapshot: OrbitalViewportSnapshot(configuration: dense)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests
        let densePlane = try XCTUnwrap(coordinator.firstRibbedSphereCutawayFrontClipPlaneForTests)

        XCTAssertGreaterThan(densePlane, basePlane)
        XCTAssertEqual(snapshot.ribbedSphereTopologyBuildCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereSegmentVisitCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialUpdateCount, 1)
        XCTAssertEqual(snapshot.ribbedSphereMaterialWriteCount, 2)
        XCTAssertEqual(snapshot.ribbedSphereHiddenStateWriteCount, 0)
        XCTAssertEqual(snapshot.fogUpdateCount, 1)
    }

    func testCorrectViewerVisibleRibbedSphereCameraMotionUpdatesOnlyCutawayPlane() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            yaw: 0,
            showRibbedSpeakerSphere: true,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let cameraOnly = makeViewportConfiguration(
            timeMS: 1_008,
            yaw: 0.04,
            showRibbedSpeakerSphere: true,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30
        )
        coordinator.update(
            configuration: cameraOnly,
            snapshot: OrbitalViewportSnapshot(configuration: cameraOnly)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.cameraUpdateCount, 1)
        XCTAssertEqual(snapshot.ribbedSphereTopologyBuildCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialUpdateCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereSegmentVisitCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialWriteCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereHiddenStateWriteCount, 0)
        XCTAssertEqual(coordinator.ribbedSphereSceneNodeCountForTests, 2)
    }

    func testCorrectViewerActiveRenderFrameDoesNotEnterRibbedMaterialPath() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            yaw: 0,
            showRibbedSpeakerSphere: true,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            showHiddenLines: false,
            spin: true,
            spinStartYaw: 0,
            spinStartTimeMS: 1_000
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let didRender = coordinator.renderActiveFrameForTests(configuration: base, timeMS: 1_008)
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertTrue(didRender)
        XCTAssertEqual(snapshot.cameraUpdateCount, 1)
        XCTAssertEqual(snapshot.ribbedSphereTopologyBuildCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialUpdateCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialWriteCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereSegmentVisitCount, 0)
        XCTAssertEqual(coordinator.ribbedSphereSceneNodeCountForTests, 2)
        XCTAssertEqual(coordinator.ribbedSphereCutawayPlaneHiddenForTests, false)
    }

    func testCorrectViewerActiveRenderFrameSkipsWhenSceneMutationIsInProgress() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            yaw: 0,
            showRibbedSpeakerSphere: true,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            showHiddenLines: false,
            spin: true,
            spinStartYaw: 0,
            spinStartTimeMS: 1_000
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        var didRender = true
        coordinator.withSceneMutationLockHeldByBackgroundThreadForTests {
            didRender = coordinator.renderActiveFrameForTests(configuration: base, timeMS: 1_008)
        }
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertFalse(didRender)
        XCTAssertEqual(snapshot.cameraUpdateCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereTopologyBuildCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialUpdateCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialWriteCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereSegmentVisitCount, 0)
    }

    func testCorrectViewerRibbedSphereDensityChangeRebuildsBatchedTopologyOnce() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let medium = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true,
            ribbedSphereVerticalRibs: 32,
            ribbedSphereHorizontalRings: 16
        )
        coordinator.update(
            configuration: medium,
            snapshot: OrbitalViewportSnapshot(configuration: medium)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.ribbedSphereTopologyBuildCount, 1)
        XCTAssertEqual(snapshot.ribbedSphereSegmentNodeBuildCount, 2)
        XCTAssertEqual(snapshot.ribbedSphereMaterialUpdateCount, 1)
        XCTAssertEqual(snapshot.ribbedSphereMaterialWriteCount, 2)
        XCTAssertEqual(coordinator.ribbedSphereSceneNodeCountForTests, 2)
        XCTAssertEqual(coordinator.ribbedSphereSegmentCountForTests, 3_840)
    }

    func testCorrectViewerGeodesicPaletteUpdatesOnlyBatchedRibbedMaterials() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            geodesicRenderStyle: .purple,
            showRibbedSpeakerSphere: true
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let palette = makeViewportConfiguration(
            timeMS: 1_000,
            geodesicRenderStyle: .rackBlue,
            geodesicSaturation: 0.42,
            showRibbedSpeakerSphere: true
        )
        coordinator.update(
            configuration: palette,
            snapshot: OrbitalViewportSnapshot(configuration: palette)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.ribbedSphereTopologyBuildCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialUpdateCount, 1)
        XCTAssertEqual(snapshot.ribbedSphereMaterialWriteCount, 2)
        XCTAssertEqual(snapshot.ribbedSphereSegmentVisitCount, 0)
        XCTAssertEqual(coordinator.ribbedSphereSceneNodeCountForTests, 2)
    }

    func testCorrectViewerSceneKitSourceSpeakerPaletteUpdatesOnlySourceMaterial() throws {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let source = OrbitalViewportSourceMarker(
            sourceID: 1,
            label: "Source 01",
            position: try OrbitalViewVector3(x: 0.25, y: 0.15, z: 0.7)
        )
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            renderStyle: .purple,
            sourceSpeakerRenderStyle: .purple,
            sources: [source]
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        let speakerRebuildCount = coordinator.speakerRebuildCount
        let labelRebuildCount = coordinator.labelRebuildCount
        let ribbedSphereBuildCount = coordinator.ribbedSphereBuildCount
        let sourceUpdateCount = coordinator.sourceUpdateCount
        let baseColor = try firstSourceDiffuseColor(in: coordinator)

        let sourcePalette = makeViewportConfiguration(
            timeMS: 1_000,
            renderStyle: .purple,
            sourceSpeakerRenderStyle: .rackBlue,
            sources: [source]
        )
        coordinator.update(
            configuration: sourcePalette,
            snapshot: OrbitalViewportSnapshot(configuration: sourcePalette)
        )
        let updatedColor = try firstSourceDiffuseColor(in: coordinator)

        XCTAssertGreaterThan(try rgbDistance(baseColor, updatedColor), 0.01)
        XCTAssertGreaterThan(coordinator.sourceUpdateCount, sourceUpdateCount)
        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertEqual(coordinator.labelRebuildCount, labelRebuildCount)
        XCTAssertEqual(coordinator.ribbedSphereBuildCount, ribbedSphereBuildCount)
    }

    func testSceneKitInstrumentationCountsRenderPhasesWithoutDiagnosticsLogSpam() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            showRibbedSpeakerSphere: true,
            showGridPlane: true
        )
        let entries = OrbitalViewportDiagnosticLog.initialEntries()

        coordinator.resetInstrumentationForTests()
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )
        let first = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(first.renderSceneCount, 1)
        XCTAssertEqual(first.cameraUpdateCount, 1)
        XCTAssertEqual(first.gridPlaneUpdateCount, 1)
        XCTAssertEqual(first.ribbedSphereMaterialUpdateCount, 1)
        XCTAssertEqual(first.speakerVisibilityUpdateCount, 1)
        XCTAssertEqual(first.speakerMaterialUpdateCount, 1)
        XCTAssertEqual(first.fogUpdateCount, 1)

        let beforeEntries = entries
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )
        let repeated = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(repeated.renderSceneCount, 2)
        XCTAssertEqual(repeated.cameraUpdateCount, first.cameraUpdateCount)
        XCTAssertEqual(repeated.speakerMaterialUpdateCount, first.speakerMaterialUpdateCount)
        XCTAssertEqual(repeated.needsDisplayCount, 1)
        XCTAssertEqual(repeated.needsDisplaySkippedCount, 1)
        XCTAssertEqual(repeated.renderSceneNoOpCount, 1)
        XCTAssertEqual(entries, beforeEntries)
    }

    func testSceneKitMeterOnlyTickDoesNotRebuildStaticGeometryWithInstrumentation() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        let speakerRebuildCount = coordinator.speakerRebuildCount
        let labelRebuildCount = coordinator.labelRebuildCount
        let ribbedSphereBuildCount = coordinator.ribbedSphereBuildCount

        coordinator.resetInstrumentationForTests()
        let sameBucket = base.frameConfiguration(timeMS: 1_008)
        coordinator.update(
            configuration: sameBucket,
            snapshot: OrbitalViewportSnapshot(configuration: sameBucket)
        )
        var snapshot = coordinator.instrumentationSnapshotForTests
        XCTAssertEqual(snapshot.speakerMaterialUpdateCount, 0)
        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertEqual(coordinator.labelRebuildCount, labelRebuildCount)
        XCTAssertEqual(coordinator.ribbedSphereBuildCount, ribbedSphereBuildCount)

        coordinator.resetInstrumentationForTests()
        let nextBucket = base.frameConfiguration(timeMS: 1_034)
        coordinator.update(
            configuration: nextBucket,
            snapshot: OrbitalViewportSnapshot(configuration: nextBucket)
        )
        snapshot = coordinator.instrumentationSnapshotForTests
        XCTAssertEqual(snapshot.speakerMaterialUpdateCount, 0)
        XCTAssertEqual(snapshot.speakerMaterialUnchangedFrameSkipCount, 1)
        XCTAssertEqual(snapshot.needsDisplayCount, 0)
        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertEqual(coordinator.labelRebuildCount, labelRebuildCount)
        XCTAssertEqual(coordinator.ribbedSphereBuildCount, ribbedSphereBuildCount)
    }

    func testSceneKitSelectedChannelChangeStillUpdatesSpeakerMaterialImmediately() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            selectedChannel: nil
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let selected = makeViewportConfiguration(
            timeMS: 1_000,
            selectedChannel: 1
        )
        coordinator.update(
            configuration: selected,
            snapshot: OrbitalViewportSnapshot(configuration: selected)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.speakerMaterialUpdateCount, 1)
        XCTAssertGreaterThan(snapshot.sceneMaterialWriteCount, 0)
        XCTAssertEqual(snapshot.speakerMaterialUnchangedFrameSkipCount, 0)
        XCTAssertEqual(snapshot.needsDisplayCount, 1)
    }

    func testSceneKitSpeakerPaletteChangeStillUpdatesSpeakerMaterialImmediately() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            renderStyle: .purple
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let palette = makeViewportConfiguration(
            timeMS: 1_000,
            renderStyle: .rackBlue
        )
        coordinator.update(
            configuration: palette,
            snapshot: OrbitalViewportSnapshot(configuration: palette)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.speakerMaterialUpdateCount, 1)
        XCTAssertGreaterThan(snapshot.sceneMaterialWriteCount, 0)
        XCTAssertEqual(snapshot.speakerMaterialUnchangedFrameSkipCount, 0)
        XCTAssertEqual(snapshot.needsDisplayCount, 1)
    }

    func testSceneKitGridPlaneMaterialStateCacheSkipsEquivalentWrites() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            showGridPlane: true,
            gridPlaneVisibility: 0.5
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let equivalent = makeViewportConfiguration(
            timeMS: 1_000,
            showGridPlane: true,
            gridPlaneVisibility: 0.500_000_000_001
        )
        coordinator.update(
            configuration: equivalent,
            snapshot: OrbitalViewportSnapshot(configuration: equivalent)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.gridPlaneUpdateCount, 1)
        XCTAssertEqual(snapshot.sceneMaterialWriteCount, 0)
        XCTAssertGreaterThan(snapshot.sceneMaterialSkipCount, 0)
        XCTAssertEqual(snapshot.needsDisplayCount, 0)
        XCTAssertEqual(snapshot.needsDisplaySkippedCount, 1)
    }

    func testCameraOnlyActiveFrameDoesNotUpdateSpeakerMaterialAt120() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            yaw: 0,
            speakerShape: .cubeVU,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let cameraOnly = makeViewportConfiguration(
            timeMS: 1_008,
            yaw: 0.04,
            speakerShape: .cubeVU,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30
        )
        coordinator.update(
            configuration: cameraOnly,
            snapshot: OrbitalViewportSnapshot(configuration: cameraOnly)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.cameraUpdateCount, 1)
        XCTAssertEqual(snapshot.speakerVisibilityUpdateCount, 1)
        XCTAssertEqual(snapshot.speakerMaterialUpdateCount, 0)
        XCTAssertEqual(snapshot.cubeVUFaceTextureCacheHitCount, 0)
        XCTAssertEqual(snapshot.cubeVUFaceTextureCacheMissCount, 0)
        XCTAssertEqual(snapshot.cubeVUFaceTextureGenerationCount, 0)
        XCTAssertEqual(snapshot.cubeVUTextureAssignmentCount, 0)
    }

    func testActiveSpinFrameDoesNotUpdateSpeakerVisibilityInsideMeterBucket() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            yaw: 0,
            speakerShape: .cubeVU,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            spin: true,
            spinStartYaw: 0,
            spinStartTimeMS: 1_000
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let sameMeterBucket = base.frameConfiguration(timeMS: 1_008)
        coordinator.update(
            configuration: sameMeterBucket,
            snapshot: OrbitalViewportSnapshot(configuration: sameMeterBucket)
        )
        var snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.cameraUpdateCount, 1)
        XCTAssertEqual(snapshot.speakerVisibilityUpdateCount, 0)
        XCTAssertEqual(snapshot.speakerMaterialUpdateCount, 0)

        coordinator.resetInstrumentationForTests()
        let nextMeterBucket = base.frameConfiguration(timeMS: 1_034)
        coordinator.update(
            configuration: nextMeterBucket,
            snapshot: OrbitalViewportSnapshot(configuration: nextMeterBucket)
        )
        snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.cameraUpdateCount, 1)
        XCTAssertEqual(snapshot.speakerVisibilityUpdateCount, 1)
        XCTAssertEqual(snapshot.speakerMaterialUpdateCount, 1)
    }

    func testMeterDisplayBucketUpdatesSpeakerMaterialWithoutStaticRebuild() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            speakerShape: .cubeVU,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            meterSource: .sphereImpulseTest
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )
        let speakerRebuildCount = coordinator.speakerRebuildCount
        let labelRebuildCount = coordinator.labelRebuildCount
        let gridPlaneBuildCount = coordinator.gridPlaneBuildCount
        let ribbedSphereBuildCount = coordinator.ribbedSphereBuildCount

        coordinator.resetInstrumentationForTests()
        let nextBucket = base.frameConfiguration(timeMS: 1_034)
        coordinator.update(
            configuration: nextBucket,
            snapshot: OrbitalViewportSnapshot(configuration: nextBucket)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.speakerMaterialUpdateCount, 1)
        XCTAssertGreaterThan(snapshot.cubeVUMaterialUpdateCount, 0)
        XCTAssertEqual(coordinator.speakerRebuildCount, speakerRebuildCount)
        XCTAssertEqual(coordinator.labelRebuildCount, labelRebuildCount)
        XCTAssertEqual(coordinator.gridPlaneBuildCount, gridPlaneBuildCount)
        XCTAssertEqual(coordinator.ribbedSphereBuildCount, ribbedSphereBuildCount)
    }

    func testCubeVUOutlineMaterialSkipsUnchangedMeterBuckets() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            speakerShape: .cubeVU,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let nextMeterBucket = base.frameConfiguration(timeMS: 1_034)
        coordinator.update(
            configuration: nextMeterBucket,
            snapshot: OrbitalViewportSnapshot(configuration: nextMeterBucket)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.speakerMaterialUpdateCount, 0)
        XCTAssertEqual(snapshot.speakerMaterialUnchangedFrameSkipCount, 1)
        XCTAssertEqual(snapshot.cubeVUMaterialUpdateCount, 0)
        XCTAssertEqual(snapshot.speakerLabelMaterialUpdateCount, 0)
        XCTAssertEqual(snapshot.cubeOutlineMaterialUpdateCount, 0)
        XCTAssertEqual(snapshot.needsDisplayCount, 0)
    }

    func testCubeVUResolvedMaterialColorsMatchThemeRamp() throws {
        let theme = OrbitalViewportTheme(style: .daftPunkBow)
        let heat = 0.42
        let referenceColor = NSColor(theme.cubeVUColor(heat: heat))
        let referenceHotColor = NSColor(theme.cubeVUHotColor)

        XCTAssertLessThan(try rgbDistance(theme.cubeVUNSColor(heat: heat), referenceColor), 0.000_1)
        XCTAssertLessThan(try rgbDistance(theme.cubeVUHotNSColor, referenceHotColor), 0.000_001)
    }

    func testSourcePoseAndSourceMaterialCadenceAreSeparatedByCoordinator() throws {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let source = OrbitalViewportSourceMarker(
            sourceID: 1,
            label: "Source 01",
            position: try OrbitalViewVector3(x: 0.25, y: 0.15, z: 0.7)
        )
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            yaw: 0,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            sources: [source]
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let cameraOnly = makeViewportConfiguration(
            timeMS: 1_008,
            yaw: 0.04,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            sources: [source]
        )
        coordinator.update(
            configuration: cameraOnly,
            snapshot: OrbitalViewportSnapshot(configuration: cameraOnly)
        )
        var snapshot = coordinator.instrumentationSnapshotForTests
        XCTAssertEqual(snapshot.sourcePoseOrVisibilityUpdateCount, 1)
        XCTAssertEqual(snapshot.sourceMaterialUpdateCount, 0)

        coordinator.resetInstrumentationForTests()
        let meterBucket = makeViewportConfiguration(
            timeMS: 1_034,
            yaw: 0.04,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            sources: [source]
        )
        coordinator.update(
            configuration: meterBucket,
            snapshot: OrbitalViewportSnapshot(configuration: meterBucket)
        )
        snapshot = coordinator.instrumentationSnapshotForTests
        XCTAssertEqual(snapshot.sourcePoseOrVisibilityUpdateCount, 0)
        XCTAssertEqual(snapshot.sourceMaterialUpdateCount, 1)
        XCTAssertEqual(snapshot.sourceMaterialUnchangedFrameSkipCount, 0)
    }

    func testChangedSourceMeterBucketUpdatesSourceMaterial() throws {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let source = OrbitalViewportSourceMarker(
            sourceID: 1,
            label: "Source 01",
            position: try OrbitalViewVector3(x: 0.25, y: 0.15, z: 0.7)
        )
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            meterSource: .sphereImpulseTest,
            sources: [source]
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let changedBucket = makeViewportConfiguration(
            timeMS: 1_200,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30,
            meterSource: .sphereImpulseTest,
            sources: [source]
        )
        coordinator.update(
            configuration: changedBucket,
            snapshot: OrbitalViewportSnapshot(configuration: changedBucket)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.sourcePoseOrVisibilityUpdateCount, 0)
        XCTAssertEqual(snapshot.sourceMaterialUpdateCount, 1)
        XCTAssertGreaterThan(snapshot.sceneMaterialWriteCount, 0)
        XCTAssertEqual(snapshot.sourceMaterialUnchangedFrameSkipCount, 0)
    }

    func testHiddenRibbedSphereDoesNotDoSegmentMaterialLoopDuringCameraOnlyMotion() {
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        let base = makeViewportConfiguration(
            timeMS: 1_000,
            yaw: 0,
            showRibbedSpeakerSphere: false,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30
        )
        coordinator.update(
            configuration: base,
            snapshot: OrbitalViewportSnapshot(configuration: base)
        )

        coordinator.resetInstrumentationForTests()
        let cameraOnly = makeViewportConfiguration(
            timeMS: 1_008,
            yaw: 0.04,
            showRibbedSpeakerSphere: false,
            activeViewportFramesPerSecond: 120,
            meterOnlyViewportFramesPerSecond: 30
        )
        coordinator.update(
            configuration: cameraOnly,
            snapshot: OrbitalViewportSnapshot(configuration: cameraOnly)
        )
        let snapshot = coordinator.instrumentationSnapshotForTests

        XCTAssertEqual(snapshot.ribbedSphereTopologyBuildCount, 0)
        XCTAssertEqual(snapshot.ribbedSphereMaterialUpdateCount, 0)
    }

    func testCubeVUMaterialUpdateSkipsUnchangedState() {
        let defaults = OrbitalViewportCubeVUSettings.default
        let scalars = SpeakerCubeVUScalars(rawRms: 0.42, settings: defaults.coreSettings, paletteValue: 0.65)
        let material = OrbitalViewportCubeVUSceneKitMaterial.makeMaterial()
        OrbitalViewportCubeVUSceneKitMaterial.resetFaceTextureCacheForTests()

        OrbitalViewportCubeVUSceneKitMaterial.update(
            material: material,
            settings: defaults,
            scalars: scalars,
            clip: false,
            alpha: 0.9,
            vuColor: .purple,
            hotColor: .pink
        )
        let first = OrbitalViewportCubeVUSceneKitMaterial.diagnosticsSnapshotForTests()

        XCTAssertFalse(OrbitalViewportCubeVUSceneKitMaterial.usesSceneKitShaderModifier)
        XCTAssertLessThanOrEqual(first.uniformWriteCount, 2)

        OrbitalViewportCubeVUSceneKitMaterial.update(
            material: material,
            settings: defaults,
            scalars: scalars,
            clip: false,
            alpha: 0.9,
            vuColor: .purple,
            hotColor: .pink
        )
        let repeated = OrbitalViewportCubeVUSceneKitMaterial.diagnosticsSnapshotForTests()

        XCTAssertEqual(repeated.materialUpdateCount, first.materialUpdateCount + 1)
        XCTAssertEqual(repeated.textureAssignmentCount, first.textureAssignmentCount)
        XCTAssertEqual(repeated.uniformWriteCount, first.uniformWriteCount)
        XCTAssertEqual(repeated.faceTextureCacheHitCount, first.faceTextureCacheHitCount + 1)
    }
    #endif

    func testOrbitalViewInitializesWithBindings() throws {
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let view = OrbitalView(
            scene: scene,
            camera: .constant(camera),
            selection: .constant(nil)
        )

        XCTAssertEqual(view.scene, scene)
        XCTAssertNil(view.meters)
        XCTAssertNil(view.objectFrames)
        XCTAssertNil(view.objectMeters)
        XCTAssertEqual(view.objectVisualSettings, .default)
        XCTAssertEqual(view.inputDiagnostics, .empty)
        XCTAssertFalse(view.showsMeterSettingsTray)
        XCTAssertNil(view.visualPresetStore)
    }

    func testOrbitalViewSettingsInitializerOptsIntoCubeVUTray() throws {
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let diagnostics = OrbitalViewInputDiagnostics(missingChannels: [2])
        let settings = try SpeakerMeterVisualSettings(inputCalibration: 1.2, levelCompression: 1.6)
        let store = InMemoryVisualPresetStore()
        let view = OrbitalView(
            scene: scene,
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

    func testOrbitalViewSettingsInitializerAcceptsObjectAndPerformanceBindings() throws {
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let objectSettings = try ObjectVisualSettings(trailsEnabled: true, maxTrailPointsPerObject: 12)
        let performanceSettings = try OrbitalViewPerformanceSettings(
            activeViewportFramesPerSecond: 30,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: false
        )

        let view = OrbitalView(
            scene: scene,
            objectVisualSettings: .constant(objectSettings),
            performanceSettings: .constant(performanceSettings),
            meterVisualSettings: .constant(.default),
            camera: .constant(camera),
            selection: .constant(nil)
        )

        XCTAssertEqual(view.objectVisualSettings, objectSettings)
        XCTAssertEqual(view.performanceSettings, performanceSettings)
        XCTAssertTrue(view.showsMeterSettingsTray)
    }

    func testMetalViewConfiguresAdaptiveFPSAndDrawOnDemand() throws {
        let view = MTKView()

        OrbitalViewMetalView.configure(view, with: .default)

        XCTAssertEqual(view.preferredFramesPerSecond, 60)
        XCTAssertTrue(view.enableSetNeedsDisplay)
        XCTAssertTrue(view.isPaused)

        let highRefresh = try OrbitalViewPerformanceSettings(
            activeViewportFramesPerSecond: 120,
            drawsOnDemand: true
        )

        OrbitalViewMetalView.configure(view, with: highRefresh)

        XCTAssertEqual(view.preferredFramesPerSecond, 120)
        XCTAssertTrue(view.enableSetNeedsDisplay)
        XCTAssertTrue(view.isPaused)

        let continuous = try OrbitalViewPerformanceSettings(
            activeViewportFramesPerSecond: 120,
            drawsOnDemand: false
        )

        OrbitalViewMetalView.configure(view, with: continuous)

        XCTAssertEqual(view.preferredFramesPerSecond, 120)
        XCTAssertFalse(view.enableSetNeedsDisplay)
        XCTAssertFalse(view.isPaused)
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
            performanceSettings: .default,
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
                performanceSettings: .default,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 2)
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
                performanceSettings: .default,
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
                performanceSettings: .default,
                camera: camera,
                selection: selection
            )
        ), [])
    }

    func testCoordinatorAppliesCubeSettingsWithoutReloadingScene() throws {
        let coordinator = OrbitalViewMetalView.Coordinator(renderer: OrbitalViewMetalRenderer())
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let boostedSettings = try SpeakerMeterVisualSettings(
            inputCalibration: 1.4,
            levelCompression: 2,
            displayCeiling: 0.9,
            hotResponse: 2.1,
            hotThreshold: 0.72,
            hotFillStrength: 0.7,
            vuPaletteDrive: 2.2
        )

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: .default,
                objectFrames: nil,
                objectMeters: nil,
                objectVisualSettings: .default,
                performanceSettings: .default,
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
                performanceSettings: .default,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.scene, scene)
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
                performanceSettings: .default,
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
    }

    private func makeViewportConfiguration(
        size: CGSize = CGSize(width: 972, height: 804),
        timeMS: Double = 1_200,
        yaw: Double = 0,
        pitch: Double = 0,
        cameraView: OrbitalViewportCameraView = .isometric,
        zoom: Double = 1,
        renderStyle: OrbitalViewportRenderStyle = .purple,
        sourceSpeakerRenderStyle: OrbitalViewportRenderStyle? = nil,
        geodesicRenderStyle: OrbitalViewportRenderStyle? = nil,
        geodesicSaturation: Double = 1,
        showRibbedSpeakerSphere: Bool = false,
        ribbedSphereThickness: Double = OrbitalViewportMockup.defaultRibbedSphereThickness,
        ribbedSphereVerticalRibs: Int = OrbitalViewportMockup.defaultRibbedSphereVerticalRibs,
        ribbedSphereHorizontalRings: Int = OrbitalViewportMockup.defaultRibbedSphereHorizontalRings,
        speakerShape: OrbitalViewportSpeakerShape = .prism,
        speakerSize: Double = 1.95,
        fogDensity: Double = 30,
        cubeVUSettings: OrbitalViewportCubeVUSettings = .default,
        activeViewportFramesPerSecond: Int = OrbitalViewportMockup.viewportAnimationFramesPerSecond,
        meterOnlyViewportFramesPerSecond: Int = OrbitalViewportMockup.meterOnlyViewportFramesPerSecond,
        inspectorRefreshFramesPerSecond: Int = OrbitalViewportMockup.inspectorRefreshFramesPerSecond,
        speakerLabelFont: OrbitalViewportSpeakerLabelFont = .systemDefault,
        speakerLabelSizeScale: Double = 1,
        meterSource: OrbitalViewportMeterSource = .telemetryNoProvider,
        showSpeakerNumbers: Bool = false,
        showHiddenLines: Bool = false,
        showGridPlane: Bool = false,
        gridPlaneVisibility: Double = OrbitalViewportGridPlaneGeometry.defaultVisibility,
        gridPlaneSpacing: Double = OrbitalViewportGridPlaneGeometry.defaultSpacing,
        gridPlaneRenderStyle: OrbitalViewportRenderStyle? = nil,
        selectedChannel: Int? = nil,
        speakers: [OrbitalViewportSpeaker] = OrbitalViewportSpeaker.referenceSpeakers,
        sources: [OrbitalViewportSourceMarker] = [],
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
            sourceSpeakerRenderStyle: sourceSpeakerRenderStyle,
            geodesicRenderStyle: geodesicRenderStyle,
            geodesicSaturation: geodesicSaturation,
            showRibbedSpeakerSphere: showRibbedSpeakerSphere,
            ribbedSphereThickness: ribbedSphereThickness,
            ribbedSphereVerticalRibs: ribbedSphereVerticalRibs,
            ribbedSphereHorizontalRings: ribbedSphereHorizontalRings,
            speakerShape: speakerShape,
            speakerSize: speakerSize,
            fogDensity: fogDensity,
            meterSource: meterSource,
            cubeVUSettings: cubeVUSettings,
            activeViewportFramesPerSecond: activeViewportFramesPerSecond,
            meterOnlyViewportFramesPerSecond: meterOnlyViewportFramesPerSecond,
            inspectorRefreshFramesPerSecond: inspectorRefreshFramesPerSecond,
            speakerLabelFont: speakerLabelFont,
            speakerLabelSizeScale: speakerLabelSizeScale,
            showSpeakerNumbers: showSpeakerNumbers,
            showHiddenLines: showHiddenLines,
            showGridPlane: showGridPlane,
            gridPlaneVisibility: gridPlaneVisibility,
            gridPlaneSpacing: gridPlaneSpacing,
            gridPlaneRenderStyle: gridPlaneRenderStyle,
            selectedChannel: selectedChannel,
            speakers: speakers,
            sources: sources,
            spin: spin,
            spinStartYaw: spinStartYaw,
            spinStartTimeMS: spinStartTimeMS
        )
    }

    private func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "OrbitalViewSwiftUITests-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private struct SeededGenerator: RandomNumberGenerator {
        var state: UInt64

        init(seed: UInt64) {
            self.state = seed
        }

        mutating func next() -> UInt64 {
            state = state &* 6_364_136_223_846_793_005 &+ 1
            return state
        }
    }

    private func makeSpatGRISSetup(uuid: String, x: Double) throws -> SpatGRISSpeakerSetup {
        try SpatGRISSpeakerSetup(
            spatMode: .cube,
            uuid: uuid,
            speakers: [
                SpatGRISSpeaker(
                    patchID: 1,
                    position: try OrbitalViewVector3(x: x, y: 0, z: 0)
                )
            ]
        )
    }

    private func makeViewThemePayload(
        themeID: String,
        renderStyle: OrbitalViewportRenderStyle = .purple,
        speakerLabelFont: OrbitalViewportSpeakerLabelFont = .pressStart2P,
        speakerLabelFontSizeSlider: Double = 64,
        leftPanel: OrbitalViewportLeftPanelSettings? = nil
    ) -> OrbitalViewportSettingsExportPayload {
        let panel = leftPanel ?? OrbitalViewportLeftPanelSettings(
            audioSource: .default,
            camera: OrbitalViewportCameraExportSettings(
                cameraView: .isometric,
                yaw: 0.2,
                pitch: -0.1,
                zoom: 1.12,
                spin: false,
                cameraAdjusted: true
            ),
            speakerType: .cubeVU,
            viewDetail: OrbitalViewportViewDetailExportSettings(
                speakerSizeSlider: 58,
                speakerSize: 2.1,
                fogDensitySlider: 44,
                fogDensity: 28,
                showSpeakerNumbers: true,
                showHiddenLines: false,
                showGridPlane: false,
                gridPlaneVisibilitySlider: OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider
            ),
            selectedChannel: nil
        )

        return OrbitalViewportSettingsExportPayload(
            themeID: themeID,
            renderStyle: renderStyle,
            geodesicRenderStyle: .rackBlue,
            geodesicSaturation: 0.42,
            speakerShape: .cubeVU,
            speakerLabelFont: speakerLabelFont,
            speakerLabelFontSizeSlider: speakerLabelFontSizeSlider,
            speakerLabelFontSizeScale: OrbitalViewportMath.speakerLabelSizeScale(fromSlider: speakerLabelFontSizeSlider),
            leftPanel: panel,
            groundAppearance: OrbitalViewportGroundAppearanceExportSettings(
                showGridPlane: false,
                gridPlaneVisibilitySlider: OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider,
                gridPlaneSpacing: OrbitalViewportGridPlaneGeometry.defaultSpacing,
                gridPlaneRenderStyle: .rackBlue
            ),
            driveMode: .impulseRipple,
            cubePreset: .hotCoreBloom,
            cubeSettings: OrbitalViewportMockup.defaultCubeVUSettings,
            activeViewportFramesPerSecond: 60,
            meterOnlyViewportFramesPerSecond: 10,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true,
            exportedAt: Date(timeIntervalSince1970: 0)
        )
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

    private func bitmapScale(_ image: NSImage) throws -> Double {
        var rect = NSRect(origin: .zero, size: image.size)
        let cgImage = try XCTUnwrap(image.cgImage(forProposedRect: &rect, context: nil, hints: nil))
        return Double(cgImage.width) / max(1, Double(image.size.width))
    }

    private func pixelBrightness(_ image: NSImage, x: Int, y: Int, scale: Double) throws -> Double {
        var rect = NSRect(origin: .zero, size: image.size)
        let cgImage = try XCTUnwrap(image.cgImage(forProposedRect: &rect, context: nil, hints: nil))
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        let pixelX = min(bitmap.pixelsWide - 1, max(0, Int((Double(x) * scale).rounded(.down))))
        let pixelY = min(bitmap.pixelsHigh - 1, max(0, Int((Double(y) * scale).rounded(.down))))
        let color = try XCTUnwrap(bitmap.colorAt(x: pixelX, y: pixelY)?.usingColorSpace(.deviceRGB))
        return (Double(color.redComponent) + Double(color.greenComponent) + Double(color.blueComponent)) / 3
    }

    private func rgbComponents(_ color: Color) throws -> (red: Double, green: Double, blue: Double) {
        let nsColor = NSColor(color)
        let rgb = try XCTUnwrap(nsColor.usingColorSpace(.deviceRGB) ?? nsColor.usingColorSpace(.sRGB))
        return (Double(rgb.redComponent), Double(rgb.greenComponent), Double(rgb.blueComponent))
    }

    private func firstRibbedSphereDiffuseColor(
        in coordinator: OrbitalViewport3DSceneView.Coordinator
    ) throws -> NSColor {
        let material = try XCTUnwrap(coordinator.ribbedSphereNode.childNodes.first?.geometry?.firstMaterial)
        return try XCTUnwrap(material.diffuse.contents as? NSColor)
    }

    private func firstSourceDiffuseColor(
        in coordinator: OrbitalViewport3DSceneView.Coordinator
    ) throws -> NSColor {
        let material = try XCTUnwrap(coordinator.sourceRoot.childNodes.first?.geometry?.firstMaterial)
        return try XCTUnwrap(material.diffuse.contents as? NSColor)
    }

    private func rgbSpread(_ color: NSColor) throws -> Double {
        let rgb = try XCTUnwrap(color.usingColorSpace(.deviceRGB) ?? color.usingColorSpace(.sRGB))
        return max(rgb.redComponent, rgb.greenComponent, rgb.blueComponent) -
            min(rgb.redComponent, rgb.greenComponent, rgb.blueComponent)
    }

    private func rgbDistance(_ lhs: NSColor, _ rhs: NSColor) throws -> Double {
        let left = try XCTUnwrap(lhs.usingColorSpace(.deviceRGB) ?? lhs.usingColorSpace(.sRGB))
        let right = try XCTUnwrap(rhs.usingColorSpace(.deviceRGB) ?? rhs.usingColorSpace(.sRGB))
        return abs(left.redComponent - right.redComponent) +
            abs(left.greenComponent - right.greenComponent) +
            abs(left.blueComponent - right.blueComponent)
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
