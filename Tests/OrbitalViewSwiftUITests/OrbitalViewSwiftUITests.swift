import MetalKit
import SwiftUI
import XCTest
#if os(macOS)
import AppKit
#endif
@testable import OrbitalViewCore
@testable import OrbitalViewRender
@testable import OrbitalViewSwiftUI

final class OrbitalViewSwiftUITests: XCTestCase {
    func testCorrectViewerKeepsNativeSceneKitViewportContract() {
        let view = OrbitalViewportMockup()

        XCTAssertNotNil(view)
        XCTAssertTrue(OrbitalViewportMockup.correctReviewAppName.contains("Native SceneKit Geodesic Viewport Review App"))
        XCTAssertTrue(OrbitalViewportMockup.correctReviewAppName.contains("Preserved Control Rail"))
        XCTAssertEqual(OrbitalViewportMockup.sourceMockupPath, "mockups/orbital-view-viewport/index.html")
        XCTAssertEqual(OrbitalViewportMockup.controlSkinSource, "orbisonic-design-language")
        XCTAssertEqual(OrbitalViewportMockup.nativeDefaultWindowSize, CGSize(width: 1180, height: 760))
        XCTAssertEqual(OrbitalViewportMockup.leftRailWidth, 240)
        XCTAssertEqual(OrbitalViewportMockup.inspectorWidth, 300)
        XCTAssertFalse(OrbitalViewportMockup.usesRootAnimationTimeline)
        XCTAssertEqual(OrbitalViewportMockup.tuningTrayHitTargetPattern, "full-width-header-button")
        XCTAssertEqual(OrbitalViewportMockup.viewportAnimationFramesPerSecond, 60)
        XCTAssertEqual(OrbitalViewportMockup.meterOnlyViewportFramesPerSecond, 10)
        XCTAssertEqual(OrbitalViewportMockup.inspectorRefreshFramesPerSecond, 10)
        XCTAssertEqual(OrbitalViewportMockup.speakerCount, 30)
        XCTAssertEqual(OrbitalViewportMockup.feyGeodesicNodeCount, 92)
        XCTAssertEqual(OrbitalViewportMockup.feyGeodesicEdgeCount, 270)
        XCTAssertEqual(OrbitalViewportMockup.rightPanelPurpose, "tuning-debug-panel")
    }

    func testCorrectViewerUsesExportedSettingsFileAsStartupDefaults() {
        let settings = OrbitalViewportMockup.defaultCubeVUSettings

        XCTAssertEqual(
            OrbitalViewportMockup.defaultSettingsSourceFileName,
            "Orbital View VU Kit Settings 2026-05-21-171537.json"
        )
        XCTAssertEqual(OrbitalViewportMockup.defaultRenderStyle, .purple)
        XCTAssertEqual(OrbitalViewportMockup.defaultGeodesicSaturation, 0)
        XCTAssertEqual(OrbitalViewportMockup.defaultSpeakerShape, .cubeVU)
        XCTAssertEqual(OrbitalViewportMockup.defaultViewportFrameRate, .sixty)
        XCTAssertEqual(OrbitalViewportMockup.defaultCubeVUPreset, .hotCoreBloom)
        XCTAssertEqual(OrbitalViewportMockup.defaultVUDriveMode, .impulseTest)
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
            ["Song Audio Source", "Camera", "Speaker Type", "View Detail"]
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
            OrbitalViewportMockup.themeTrayControlTitles,
            ["Geodesic Saturation", "Shell", "Cube VU Ramp"]
        )
        XCTAssertEqual(OrbitalViewportSpeakerShape.allCases.map(\.title), ["Prism", "Sphere", "Cube VU"])
        XCTAssertEqual(OrbitalViewportFrameRate.allCases.map(\.title), ["30 FPS", "60 FPS"])
        XCTAssertEqual(
            OrbitalViewportMockup.tuningTrayTitles,
            [
                "Orbisonic Theme",
                "VU Drive",
                "Speaker Geometry",
                "Meter Calibration",
                "Surface + Bloom",
                "Presets",
                "Graphical Performance vs CPU Load",
                "Debug + Diagnostics"
            ]
        )
        XCTAssertEqual(
            OrbitalViewportMockup.surfaceBloomControlTitles,
            [
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
        XCTAssertEqual(OrbitalViewportVUDriveMode.allCases.map(\.title), ["Music", "Impulse Test"])
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
        XCTAssertEqual(OrbitalViewportMockup.audioSourcePosition, "top-left-above-title")
        XCTAssertEqual(OrbitalViewportMockup.audioTransportButtonLayout, "side-by-side-transport-icon-buttons")
        XCTAssertEqual(
            OrbitalViewportMockup.removedRightPanelCards,
            ["Scene", "No speaker selected", "30-channel VU list"]
        )
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
        XCTAssertEqual(texture.size.width, CGFloat(defaults.facePixels * OrbitalViewportCubeVUSceneKitMaterial.faceTexturePixelsPerFacePixel))
        XCTAssertEqual(texture.size.height, CGFloat(defaults.facePixels * OrbitalViewportCubeVUSceneKitMaterial.faceTexturePixelsPerFacePixel))
        XCTAssertEqual(OrbitalViewportCubeVUSceneKitMaterial.cachedFaceTextureCountForTests(), 1)

        for index in 0..<(OrbitalViewportCubeVUSceneKitMaterial.faceTextureCacheLimit + 20) {
            let rawRms = Float(index % 97) / 96
            _ = OrbitalViewportCubeVUSceneKitMaterial.faceTexture(
                settings: defaults,
                scalars: SpeakerCubeVUScalars(rawRms: rawRms, settings: defaults.coreSettings, paletteValue: rawRms),
                clip: index.isMultiple(of: 11),
                vuColor: .systemPurple,
                hotColor: .systemPink
            )
        }
        XCTAssertLessThanOrEqual(
            OrbitalViewportCubeVUSceneKitMaterial.cachedFaceTextureCountForTests(),
            OrbitalViewportCubeVUSceneKitMaterial.faceTextureCacheLimit
        )
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
            geodesicSaturation: 0.36,
            speakerShape: .cubeVU,
            leftPanel: OrbitalViewportLeftPanelSettings(
                audioSource: OrbitalViewportAudioSourceExportSettings(
                    mode: .localAudioFile,
                    hasLoadedAudio: true,
                    fileName: "reference-track.wav",
                    filePath: "/Users/example/Music/reference-track.wav",
                    isPlaying: false,
                    statusText: "Loaded"
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
                    showHiddenLines: true
                ),
                selectedChannel: 12
            ),
            driveMode: .impulseTest,
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

        XCTAssertTrue(json.contains("\"schemaVersion\" : 2"))
        XCTAssertTrue(json.contains("\"driveMode\" : \"impulseTest\""))
        XCTAssertTrue(json.contains("\"cubePreset\" : \"haloEdgeBloom\""))
        XCTAssertTrue(json.contains("\"renderStyle\" : \"daftPunkBow\""))
        XCTAssertTrue(json.contains("\"geodesicSaturation\" : 0.36"))
        XCTAssertTrue(json.contains("\"leftPanel\""))
        XCTAssertTrue(json.contains("\"cameraView\" : \"elevation\""))
        XCTAssertTrue(json.contains("\"speakerSizeSlider\" : 64"))
        XCTAssertTrue(json.contains("\"fileName\" : \"reference-track.wav\""))
        XCTAssertTrue(json.contains("\"selectedChannel\" : 12"))
        XCTAssertTrue(json.contains("\"rimHaloEdge\" : 1"))
        XCTAssertTrue(json.contains("\"pixelFill\" : 1"))
        XCTAssertTrue(json.contains("\"surfaceCheckerOpacity\" : 1"))
        XCTAssertEqual(decoded.leftPanel.audioSource.mode, .localAudioFile)
        XCTAssertEqual(decoded.leftPanel.audioSource.filePath, "/Users/example/Music/reference-track.wav")
        XCTAssertEqual(decoded.leftPanel.camera.cameraView, .elevation)
        XCTAssertEqual(decoded.leftPanel.camera.yaw, 0.42, accuracy: 0.000_001)
        XCTAssertTrue(decoded.leftPanel.camera.spin)
        XCTAssertEqual(decoded.leftPanel.speakerType, .cubeVU)
        XCTAssertEqual(decoded.leftPanel.viewDetail.speakerSizeSlider, 64)
        XCTAssertTrue(decoded.leftPanel.viewDetail.showSpeakerNumbers)
        XCTAssertTrue(decoded.leftPanel.viewDetail.showHiddenLines)
        XCTAssertEqual(decoded.leftPanel.selectedChannel, 12)
    }

    func testCorrectViewerGeodesicSaturationOnlyUpdatesShellColors() throws {
        let saturated = makeViewportConfiguration(renderStyle: .daftPunkBow, geodesicSaturation: 1)
        let desaturated = makeViewportConfiguration(renderStyle: .daftPunkBow, geodesicSaturation: 0)
        let saturatedEquator = try rgbComponents(saturated.geodesicColor(saturated.theme.equator))
        let desaturatedEquator = try rgbComponents(desaturated.geodesicColor(desaturated.theme.equator))

        XCTAssertGreaterThan(max(saturatedEquator.red, saturatedEquator.green, saturatedEquator.blue) - min(saturatedEquator.red, saturatedEquator.green, saturatedEquator.blue), 0.01)
        XCTAssertLessThan(max(desaturatedEquator.red, desaturatedEquator.green, desaturatedEquator.blue) - min(desaturatedEquator.red, desaturatedEquator.green, desaturatedEquator.blue), 0.001)
        XCTAssertNotEqual(OrbitalViewportShellUpdateKey(configuration: saturated), OrbitalViewportShellUpdateKey(configuration: desaturated))
        XCTAssertEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: saturated), OrbitalViewportSpeakerMaterialUpdateKey(configuration: desaturated))
        XCTAssertEqual(saturated.theme.cubeVUHotColor, desaturated.theme.cubeVUHotColor)
    }

    func testCorrectViewerKeepsMeterOnlyTicksOutOfStaticGeometry() {
        let base = makeViewportConfiguration(timeMS: 1_000)
        let meterOnly = base.frameConfiguration(timeMS: 1_200)

        XCTAssertEqual(OrbitalViewportShellUpdateKey(configuration: base), OrbitalViewportShellUpdateKey(configuration: meterOnly))
        XCTAssertEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: meterOnly))
        XCTAssertEqual(OrbitalViewportSpeakerVisibilityUpdateKey(configuration: base), OrbitalViewportSpeakerVisibilityUpdateKey(configuration: meterOnly))
        XCTAssertNotEqual(OrbitalViewportSpeakerMaterialUpdateKey(configuration: base), OrbitalViewportSpeakerMaterialUpdateKey(configuration: meterOnly))
    }

    func testCorrectViewerSeparatesGeometryAndMaterialTuningKeys() {
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
        XCTAssertNotEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: heightChange))
        XCTAssertNotEqual(OrbitalViewportSpeakerGeometryUpdateKey(configuration: base), OrbitalViewportSpeakerGeometryUpdateKey(configuration: cubeVUType))
    }

    #if os(macOS)
    func testCorrectViewerSceneKitDefaultsDrawOnDemandAtSixtyFPS() {
        XCTAssertFalse(OrbitalViewport3DSceneView.rendersContinuously)
        XCTAssertEqual(OrbitalViewport3DSceneView.sceneFramesPerSecond, 60)
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

        let continuous = try OrbitalViewPerformanceSettings(
            activeViewportFramesPerSecond: 30,
            drawsOnDemand: false
        )

        OrbitalViewMetalView.configure(view, with: continuous)

        XCTAssertEqual(view.preferredFramesPerSecond, 30)
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
        geodesicSaturation: Double = 1,
        speakerShape: OrbitalViewportSpeakerShape = .prism,
        speakerSize: Double = 1.95,
        fogDensity: Double = 30,
        cubeVUSettings: OrbitalViewportCubeVUSettings = .default,
        activeViewportFramesPerSecond: Int = OrbitalViewportMockup.viewportAnimationFramesPerSecond,
        meterSource: OrbitalViewportMeterSource = .fake,
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
            geodesicSaturation: geodesicSaturation,
            speakerShape: speakerShape,
            speakerSize: speakerSize,
            fogDensity: fogDensity,
            meterSource: meterSource,
            cubeVUSettings: cubeVUSettings,
            activeViewportFramesPerSecond: activeViewportFramesPerSecond,
            showSpeakerNumbers: showSpeakerNumbers,
            showHiddenLines: showHiddenLines,
            selectedChannel: selectedChannel,
            spin: spin,
            spinStartYaw: spinStartYaw,
            spinStartTimeMS: spinStartTimeMS
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
