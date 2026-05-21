import Foundation
import OrbitalViewCore
import AVFoundation
import Combine
#if os(macOS)
import AppKit
import SceneKit
import simd
import UniformTypeIdentifiers
#endif
import SwiftUI

public struct OrbitalViewportMockup: View {
    public static let correctReviewAppName = "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail, Right Tuning Panel, Motion FPS Toggle, Full-Window PNG Export, and Cube VU Speaker Surface"
    public static let sourceMockupPath = "mockups/orbital-view-viewport/index.html"
    public static let desktopSize = CGSize(width: 1512, height: 850)
    public static let nativeDefaultWindowSize = CGSize(width: 1180, height: 760)
    public static let nativeMinimumWindowSize = CGSize(width: 980, height: 680)
    public static let leftRailWidth: CGFloat = 240
    public static let inspectorWidth: CGFloat = 300
    public static let footerHeight: CGFloat = 46
    public static let controlSkinSource = "orbisonic-design-language"
    static let usesRootAnimationTimeline = false
    static let tuningTrayHitTargetPattern = "full-width-header-button"
    static let viewportAnimationFramesPerSecond = OrbitalViewportFrameRate.sixty.framesPerSecond
    static let meterOnlyViewportFramesPerSecond = 10
    static let inspectorRefreshFramesPerSecond = 10
    public static let speakerCount = OrbitalViewportSpeaker.referenceSpeakers.count
    public static let feyGeodesicNodeCount = OrbitalViewportGeodesic.structure.nodes.count
    public static let feyGeodesicEdgeCount = OrbitalViewportGeodesic.structure.edges.count
    static let leftRailSectionTitles = [
        "Song Audio Source",
        "Camera",
        "Speaker Type",
        "View Detail"
    ]
    static let themeControlPattern = "full-width-orbisonic-theme-buttons"
    static let themePaletteSource = "orbisonic-palette-brief"
    static let themeTrayControlTitles = [
        "Geodesic Saturation",
        "Shell",
        "Cube VU Ramp"
    ]
    static let tuningTrayTitles = [
        "Orbisonic Theme",
        "VU Drive",
        "Speaker Geometry",
        "Meter Calibration",
        "Surface + Bloom",
        "Presets",
        "Graphical Performance vs CPU Load",
        "Debug + Diagnostics"
    ]
    static let surfaceBloomControlTitles = [
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
    static let inactiveObjectTrayTitles = [
        "Object Overlay",
        "Trails",
        "Glow Trails",
        "Bounds"
    ]
    static let objectTuningTraysVisible = false
    static let audioSourcePosition = "top-left-above-title"
    static let audioTransportButtonLayout = "side-by-side-transport-icon-buttons"
    static let motionFPSControlLocation = "right-performance-tray"
    static let removedRightPanelCards = [
        "Scene",
        "No speaker selected",
        "30-channel VU list"
    ]
    static let rightPanelPurpose = "tuning-debug-panel"
    static let defaultSettingsSourceFileName = "Orbital View VU Kit Settings 2026-05-21-171537.json"
    static let defaultRenderStyle: OrbitalViewportRenderStyle = .purple
    static let defaultGeodesicSaturation = 0.0
    static let defaultSpeakerShape: OrbitalViewportSpeakerShape = .cubeVU
    static let defaultViewportFrameRate: OrbitalViewportFrameRate = .sixty
    static let defaultCubeVUPreset: OrbitalViewportCubeVUPreset = .hotCoreBloom
    static let defaultVUDriveMode: OrbitalViewportVUDriveMode = .impulseTest
    static let defaultCubeVUSettings: OrbitalViewportCubeVUSettings = {
        var settings = OrbitalViewportCubeVUPreset.hotCoreBloom.settings
        settings.cubeOutlineStrength = 0.64
        settings.pixelFill = 0.86
        settings.surfaceCheckerOpacity = 0
        return settings
    }()

    @State private var yaw = 0.0
    @State private var pitch = 0.0
    @State private var zoom = 1.0
    @State private var cameraView: OrbitalViewportCameraView = .isometric
    @State private var renderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultRenderStyle
    @State private var geodesicSaturation = OrbitalViewportMockup.defaultGeodesicSaturation
    @State private var speakerShape: OrbitalViewportSpeakerShape = OrbitalViewportMockup.defaultSpeakerShape
    @State private var speakerSizeSlider = 50.0
    @State private var fogDensitySlider = 50.0
    @State private var viewportFrameRate: OrbitalViewportFrameRate = OrbitalViewportMockup.defaultViewportFrameRate
    @State private var spin = false
    @State private var showSpeakerNumbers = false
    @State private var showHiddenLines = false
    @State private var selectedChannel: Int?
    @State private var dragStartYaw: Double?
    @State private var dragStartPitch: Double?
    @State private var spinStartYaw = 0.0
    @State private var spinStartTimeMS = Date.timeIntervalSinceReferenceDate * 1000
    @State private var isDragging = false
    @State private var cameraAdjusted = false
    @State private var exportInProgress = false
    @State private var exportStatus: OrbitalViewportExportStatus?
    @State private var magnificationStartZoom: Double?
    @StateObject private var localAudio = OrbitalViewportLocalAudioController()
    @State private var cubeVUSettings = OrbitalViewportMockup.defaultCubeVUSettings
    @State private var cubeVUPreset: OrbitalViewportCubeVUPreset = OrbitalViewportMockup.defaultCubeVUPreset
    @State private var vuDriveMode: OrbitalViewportVUDriveMode = OrbitalViewportMockup.defaultVUDriveMode
    @State private var objectTuning = OrbitalViewportObjectTuning.default
    @State private var themeExpanded = false
    @State private var vuDriveExpanded = false
    @State private var speakerGeometryExpanded = false
    @State private var meterCalibrationExpanded = false
    @State private var surfaceBloomExpanded = false
    @State private var objectOverlayExpanded = false
    @State private var trailsExpanded = false
    @State private var glowTrailsExpanded = false
    @State private var boundsExpanded = false
    @State private var performanceExpanded = false
    @State private var presetsExpanded = false
    @State private var diagnosticsExpanded = false
    @State private var diagnosticLogEntries = OrbitalViewportDiagnosticLog.initialEntries()

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            if proxy.size.width < 900 {
                compactLayout(totalSize: proxy.size)
            } else {
                desktopLayout(totalSize: proxy.size)
            }
        }
        .background(theme.pageBackground)
        .foregroundStyle(theme.text)
        .onReceive(localAudio.$latestDiagnosticEvent) { event in
            guard let event else {
                return
            }
            recordDiagnostic(event.message)
        }
    }

    private var theme: OrbitalViewportTheme {
        OrbitalViewportTheme(style: renderStyle)
    }

    private var speakerSize: Double {
        OrbitalViewportMath.speakerSize(fromSlider: speakerSizeSlider)
    }

    private var fogDensity: Double {
        OrbitalViewportMath.fogDensity(fromSlider: fogDensitySlider)
    }

    private func configuration(size: CGSize, timeMS: Double) -> OrbitalViewportRenderConfiguration {
        let effectiveYaw = displayedYaw(timeMS: timeMS)
        return OrbitalViewportRenderConfiguration(
            size: size,
            timeMS: timeMS,
            yaw: effectiveYaw,
            pitch: pitch,
            cameraView: cameraView,
            zoom: zoom,
            renderStyle: renderStyle,
            geodesicSaturation: geodesicSaturation,
            speakerShape: speakerShape,
            speakerSize: speakerSize,
            fogDensity: fogDensity,
            meterSource: activeMeterSource,
            cubeVUSettings: cubeVUSettings,
            activeViewportFramesPerSecond: viewportFrameRate.framesPerSecond,
            showSpeakerNumbers: showSpeakerNumbers,
            showHiddenLines: showHiddenLines,
            selectedChannel: selectedChannel,
            spin: spin && !isDragging,
            spinStartYaw: spinStartYaw,
            spinStartTimeMS: spinStartTimeMS
        )
    }

    private var activeMeterSource: OrbitalViewportMeterSource {
        switch vuDriveMode {
        case .music:
            return localAudio.meterSource
        case .impulseTest:
            return .sphereImpulseTest
        }
    }

    private func desktopLayout(totalSize: CGSize) -> some View {
        let footerHeight = Self.footerHeight
        let viewportSize = CGSize(
            width: max(1, totalSize.width - Self.leftRailWidth - Self.inspectorWidth),
            height: max(1, totalSize.height - footerHeight)
        )
        let timeMS = currentTimeMS()
        let renderConfiguration = configuration(size: viewportSize, timeMS: timeMS)
        let snapshot = OrbitalViewportSnapshot(configuration: renderConfiguration)

        return HStack(spacing: 0) {
            controlRail
                .frame(width: Self.leftRailWidth)

            VStack(spacing: 0) {
                viewport(renderConfiguration: renderConfiguration, snapshot: snapshot)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                footer()
                    .frame(height: footerHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tuningPanel
                .frame(width: Self.inspectorWidth)
        }
        .frame(width: totalSize.width, height: totalSize.height)
        .clipped()
    }

    private func compactLayout(totalSize: CGSize) -> some View {
        let viewportSize = CGSize(width: totalSize.width, height: max(360, totalSize.height * 0.62))
        let timeMS = currentTimeMS()
        let renderConfiguration = configuration(size: viewportSize, timeMS: timeMS)
        let snapshot = OrbitalViewportSnapshot(configuration: renderConfiguration)

        return ScrollView {
            VStack(spacing: 0) {
                controlRail
                    .frame(minHeight: 620)
                viewport(renderConfiguration: renderConfiguration, snapshot: snapshot)
                    .frame(height: viewportSize.height)
                tuningPanel
                    .frame(minHeight: 420)
                footer()
                    .frame(height: Self.footerHeight)
            }
        }
        .background(theme.pageBackground)
    }

    private var controlRail: some View {
        VStack(alignment: .leading, spacing: 12) {
            audioSection
                .padding(.horizontal, 2)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 3) {
                Text("OrbitalViewKit")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(theme.text)
                Text("Fey 30 / 3V Shell")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.muted)
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    cameraSection
                    shapeSection
                    viewDetailSection
                }
                .padding(10)
            }
            .scrollIndicators(.hidden)
            .background(theme.toolbarBackground)
            .overlay(
                RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.panelRadius, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.panelRadius, style: .continuous))
        }
        .padding(12)
        .background(theme.railBackground)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(theme.line)
                .frame(width: 1)
        }
    }

    private var cameraSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Camera")
            controlButtonGroup(
                OrbitalViewportCameraView.allCases,
                selection: cameraView,
                title: \.title,
                action: setView
            )

            VStack(spacing: 8) {
                controlButton("Reset", active: false) { resetView() }
                controlButton("Spin", active: spin) { toggleSpin() }
                controlButton(exportInProgress ? "PNG..." : "Export PNG", active: false, disabled: exportInProgress) {
                    exportCurrentPNG()
                }
            }
        }
    }

    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Song Audio Source")
            controlButton("Choose File", active: localAudio.hasLoadedAudio) {
                localAudio.chooseAudioFile()
            }
            HStack(spacing: 8) {
                transportButton(
                    systemName: "play.fill",
                    title: "Play",
                    active: localAudio.isPlaying,
                    disabled: !localAudio.hasLoadedAudio || localAudio.isPlaying
                ) {
                    localAudio.play()
                }
                transportButton(
                    systemName: "pause.fill",
                    title: "Pause",
                    active: localAudio.isPlaying,
                    disabled: !localAudio.isPlaying
                ) {
                    localAudio.pause()
                }
            }
            Text(localAudio.fileDisplayName ?? "Fake meter stream")
                .font(.system(size: 11))
                .foregroundStyle(theme.muted)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var shapeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Speaker Type")
            controlButtonGroup(
                OrbitalViewportSpeakerShape.allCases,
                selection: speakerShape,
                title: \.title
            ) { shape in
                if speakerShape != shape {
                    speakerShape = shape
                    recordDiagnostic("Speaker type set to \(shape.title)")
                }
            }
        }
    }

    private var viewDetailSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("View Detail")
            labSliderRow(
                title: "Speaker Size",
                value: $speakerSizeSlider,
                accessibilityValue: "\(speakerSize.formatted(.number.precision(.fractionLength(2))))x"
            )
            labSliderRow(
                title: "Fog Density",
                value: $fogDensitySlider,
                accessibilityValue: fogDensity.formatted(.number.precision(.fractionLength(0)))
            )
            toggleRow("Speaker Numbers", isOn: $showSpeakerNumbers)
            toggleRow("Hidden Lines", isOn: $showHiddenLines)
        }
    }

    private var orbisonicThemeTray: some View {
        tuningTray("Orbisonic Theme", isExpanded: $themeExpanded) {
            VStack(spacing: 6) {
                ForEach(OrbitalViewportRenderStyle.allCases) { style in
                    themeButton(style)
                }
            }
            tuningSliderRow(
                "Geodesic Saturation",
                value: $geodesicSaturation,
                range: 0...1,
                step: 0.01,
                valueText: "\((geodesicSaturation * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningValueRow("Shell", value: renderStyle.title)
            tuningValueRow("Cube VU Ramp", value: renderStyle.title)
        }
    }

    private var vuDriveTray: some View {
        tuningTray("VU Drive", isExpanded: $vuDriveExpanded) {
            controlButtonGroup(
                OrbitalViewportVUDriveMode.allCases,
                selection: vuDriveMode,
                title: \.title
            ) { mode in
                setVUDriveMode(mode)
            }
            tuningValueRow("Active Meter", value: vuDriveMode.statusTitle)
            tuningValueRow("Music Source", value: localAudio.hasLoadedAudio ? "local mono file" : "fake review stream")
        }
    }

    private var speakerGeometryTray: some View {
        tuningTray("Speaker Geometry", isExpanded: $speakerGeometryExpanded) {
            tuningValueRow("Speaker Type", value: speakerShape.title)
            tuningValueRow("VU Skin", value: speakerShape == .cubeVU ? "9x9 cube faces" : "simple meter tint")
            tuningValueRow("Channels", value: "30 physical")
            tuningSliderRow(
                "Cube Outline",
                value: $cubeVUSettings.cubeOutlineStrength,
                range: 0...1,
                step: 0.01,
                valueText: cubeVUSettings.cubeOutlineStrength.formatted(.number.precision(.fractionLength(2)))
            )
            tuningSliderRow(
                "Speaker Height",
                value: $cubeVUSettings.speakerHeight,
                range: 1...2,
                step: 0.01,
                valueText: cubeVUSettings.speakerHeight.formatted(.number.precision(.fractionLength(2)))
            )
        }
    }

    private var meterCalibrationTray: some View {
        tuningTray("Meter Calibration", isExpanded: $meterCalibrationExpanded) {
            tuningSliderRow(
                "Input Calibration",
                value: $cubeVUSettings.inputCalibration,
                range: 0.25...2,
                step: 0.05,
                valueText: "\(cubeVUSettings.inputCalibration.formatted(.number.precision(.fractionLength(2))))x"
            )
            tuningSliderRow(
                "Level Compression",
                value: $cubeVUSettings.levelCompression,
                range: 1...4,
                step: 0.05,
                valueText: "\(cubeVUSettings.levelCompression.formatted(.number.precision(.fractionLength(2))))x"
            )
            tuningSliderRow(
                "Display Ceiling",
                value: $cubeVUSettings.displayCeiling,
                range: 0.5...1,
                step: 0.01,
                valueText: "\((cubeVUSettings.displayCeiling * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningSliderRow(
                "Hot Response",
                value: $cubeVUSettings.hotResponse,
                range: 0.5...3,
                step: 0.05,
                valueText: "\(cubeVUSettings.hotResponse.formatted(.number.precision(.fractionLength(2))))x"
            )
            tuningSliderRow(
                "Hot Threshold",
                value: $cubeVUSettings.hotThreshold,
                range: 0.35...0.98,
                step: 0.01,
                valueText: "\((cubeVUSettings.hotThreshold * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningSliderRow(
                "Hot Fill Strength",
                value: $cubeVUSettings.hotFillStrength,
                range: 0...1,
                step: 0.01,
                valueText: cubeVUSettings.hotFillStrength.formatted(.number.precision(.fractionLength(2)))
            )
            tuningSliderRow(
                "Palette Drive",
                value: $cubeVUSettings.paletteDrive,
                range: 0.5...4,
                step: 0.05,
                valueText: "\(cubeVUSettings.paletteDrive.formatted(.number.precision(.fractionLength(2))))x"
            )
        }
    }

    private var surfaceBloomTray: some View {
        tuningTray("Surface + Bloom", isExpanded: $surfaceBloomExpanded) {
            tuningSliderRow(
                "Bloom Min",
                value: $cubeVUSettings.bloomMin,
                range: 0...cubeVUSettings.bloomMax,
                step: 0.01,
                valueText: cubeVUSettings.bloomMin.formatted(.number.precision(.fractionLength(2)))
            )
            tuningSliderRow(
                "Bloom Max",
                value: $cubeVUSettings.bloomMax,
                range: cubeVUSettings.bloomMin...1,
                step: 0.01,
                valueText: cubeVUSettings.bloomMax.formatted(.number.precision(.fractionLength(2)))
            )
            tuningSliderRow(
                "Bloom Edge",
                value: $cubeVUSettings.bloomEdge,
                range: 0.001...1,
                step: 0.001,
                valueText: cubeVUSettings.bloomEdge.formatted(.number.precision(.fractionLength(3)))
            )
            tuningSliderRow(
                "Rim Halo Edge",
                value: $cubeVUSettings.rimHaloEdge,
                range: 0...1,
                step: 0.01,
                valueText: cubeVUSettings.rimHaloEdge.formatted(.number.precision(.fractionLength(2)))
            )
            tuningSliderRow(
                "Response Curve",
                value: $cubeVUSettings.responseCurve,
                range: 0.2...4,
                step: 0.01,
                valueText: cubeVUSettings.responseCurve.formatted(.number.precision(.fractionLength(2)))
            )
            tuningStepperRow("Face Pixels", value: $cubeVUSettings.facePixels, range: 6...14)
            tuningSliderRow(
                "Pixel Fill",
                value: $cubeVUSettings.pixelFill,
                range: 0.5...1,
                step: 0.01,
                valueText: "\((cubeVUSettings.pixelFill * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningSliderRow(
                "Idle Tint",
                value: $cubeVUSettings.idleTint,
                range: 0...1,
                step: 0.01,
                valueText: cubeVUSettings.idleTint.formatted(.number.precision(.fractionLength(2)))
            )
            tuningSliderRow(
                "Surface Checker Opacity",
                value: $cubeVUSettings.surfaceCheckerOpacity,
                range: 0...1,
                step: 0.01,
                valueText: "\((cubeVUSettings.surfaceCheckerOpacity * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningSliderRow(
                "Checker Contrast",
                value: $cubeVUSettings.checkerContrast,
                range: 0...0.4,
                step: 0.01,
                valueText: cubeVUSettings.checkerContrast.formatted(.number.precision(.fractionLength(2)))
            )
        }
    }

    private var objectOverlayTray: some View {
        tuningTray("Object Overlay", isExpanded: $objectOverlayExpanded) {
            Picker("Object Shape", selection: $objectTuning.shape) {
                ForEach(OrbitalViewportObjectShape.allCases) { shape in
                    Text(shape.title).tag(shape)
                }
            }
            .pickerStyle(.menu)

            Picker("Object Palette", selection: $objectTuning.palette) {
                ForEach(OrbitalViewportObjectPalette.allCases) { palette in
                    Text(palette.title).tag(palette)
                }
            }
            .pickerStyle(.menu)

            tuningSliderRow("Core Size", value: $objectTuning.coreSize, range: 0.01...0.24, step: 0.005, valueText: objectTuning.coreSize.formatted(.number.precision(.fractionLength(3))))
            tuningSliderRow("Width Scale", value: $objectTuning.widthScale, range: 0...5, step: 0.05, valueText: objectTuning.widthScale.formatted(.number.precision(.fractionLength(2))))
            tuningSliderRow("Smoothing", value: $objectTuning.smoothingHalfLifeSeconds, range: 0...1, step: 0.01, valueText: "\(objectTuning.smoothingHalfLifeSeconds.formatted(.number.precision(.fractionLength(2))))s")
            tuningSliderRow("Visual Lookbehind", value: $objectTuning.visualLookbehindMilliseconds, range: 0...120, step: 1, valueText: "\(objectTuning.visualLookbehindMilliseconds.formatted(.number.precision(.fractionLength(0)))) ms")
            tuningSliderRow("Snap Threshold", value: $objectTuning.snapThresholdRadians, range: 0...Double.pi, step: 0.01, valueText: objectTuning.snapThresholdRadians.formatted(.number.precision(.fractionLength(2))))
            tuningSliderRow("Glow", value: $objectTuning.glowIntensity, range: 0...2, step: 0.01, valueText: objectTuning.glowIntensity.formatted(.number.precision(.fractionLength(2))))
            tuningSliderRow("Clip Flash", value: $objectTuning.clipFlashIntensity, range: 0...2, step: 0.01, valueText: objectTuning.clipFlashIntensity.formatted(.number.precision(.fractionLength(2))))
        }
    }

    private var trailsTray: some View {
        tuningTray("Trails", isExpanded: $trailsExpanded) {
            toggleRow("Trails", isOn: $objectTuning.trailsEnabled)
            tuningSliderRow("Trail Length", value: $objectTuning.trailLengthSeconds, range: 0...10, step: 0.1, valueText: "\(objectTuning.trailLengthSeconds.formatted(.number.precision(.fractionLength(1))))s")
            tuningSliderRow("Trail Decay", value: $objectTuning.trailDecay, range: 0...1, step: 0.01, valueText: objectTuning.trailDecay.formatted(.number.precision(.fractionLength(2))))
            tuningStepperRow("Max Trail Points", value: $objectTuning.maxTrailPointsPerObject, range: 0...256)
        }
    }

    private var glowTrailsTray: some View {
        tuningTray("Glow Trails", isExpanded: $glowTrailsExpanded) {
            toggleRow("Glow Trails", isOn: $objectTuning.glowTrailsEnabled)
            tuningSliderRow("Glow Intensity", value: $objectTuning.glowTrailIntensity, range: 0...2, step: 0.01, valueText: objectTuning.glowTrailIntensity.formatted(.number.precision(.fractionLength(2))))
            tuningSliderRow("Glow Width", value: $objectTuning.glowTrailWidth, range: 0...0.5, step: 0.005, valueText: objectTuning.glowTrailWidth.formatted(.number.precision(.fractionLength(3))))
            tuningSliderRow("Glow Decay", value: $objectTuning.glowTrailDecay, range: 0...1, step: 0.01, valueText: objectTuning.glowTrailDecay.formatted(.number.precision(.fractionLength(2))))
        }
    }

    private var boundsTray: some View {
        tuningTray("Bounds", isExpanded: $boundsExpanded) {
            tuningValueRow("X Bounds", value: "-5...+5")
            tuningValueRow("Y Bounds", value: "-5...+5")
            tuningValueRow("Z Bounds", value: "-5...+5")
            toggleRow("Show Bounds", isOn: $objectTuning.showsBounds)
            toggleRow("Clip Diagnostics", isOn: $objectTuning.showsClipDiagnostics)
        }
    }

    private var performanceTray: some View {
        tuningTray("Graphical Performance vs CPU Load", isExpanded: $performanceExpanded) {
            Picker("Motion FPS", selection: viewportFrameRateBinding) {
                ForEach(OrbitalViewportFrameRate.allCases) { frameRate in
                    Text(frameRate.title).tag(frameRate)
                }
            }
            .pickerStyle(.segmented)
            tuningValueRow("Meter-only FPS", value: "\(Self.meterOnlyViewportFramesPerSecond)")
            tuningValueRow("Inspector FPS", value: "\(Self.inspectorRefreshFramesPerSecond)")
            tuningValueRow("Draw Mode", value: OrbitalViewport3DSceneView.rendersContinuously ? "continuous" : "on demand")
            tuningStepperRow("Face Pixels Cost", value: $cubeVUSettings.facePixels, range: 6...14)
        }
    }

    private var presetsTray: some View {
        tuningTray("Presets", isExpanded: $presetsExpanded) {
            tuningValueRow("Cube VU Preset", value: cubeVUPreset.title)
            VStack(spacing: 6) {
                ForEach(OrbitalViewportCubeVUPreset.allCases) { preset in
                    controlButton(preset.title, active: cubeVUPreset == preset) {
                        applyCubeVUPreset(preset)
                    }
                }
            }
            controlButton("Reset Cube VU", active: false) {
                applyCubeVUPreset(.softCenterBloom)
                recordDiagnostic("Cube VU settings reset to default")
            }
            controlButton("Export Settings JSON", active: false) {
                exportSettingsJSON()
            }
        }
    }

    private var diagnosticsTray: some View {
        tuningTray("Debug + Diagnostics", isExpanded: $diagnosticsExpanded) {
            let diagnostics = currentMeterDiagnostics()
            tuningValueRow("Correct Surface", value: "SceneKit geodesic")
            tuningValueRow("Geodesic Nodes", value: "\(Self.feyGeodesicNodeCount)")
            tuningValueRow("Geodesic Edges", value: "\(Self.feyGeodesicEdgeCount)")
            tuningValueRow("Static Speaker Rebuilds", value: "shape/size only")
            tuningValueRow("Meter Source", value: vuDriveMode.statusTitle)
            tuningValueRow("Diagnostic Channel", value: String(format: "%02d", diagnostics.channel))
            tuningValueRow("Raw RMS", value: diagnostics.rawRMS.percentText)
            tuningValueRow("Raw Peak", value: diagnostics.rawPeak.percentText)
            tuningValueRow("Calibrated RMS", value: diagnostics.calibratedRMS.percentText)
            tuningValueRow("Display Scalar", value: diagnostics.displayScalar.percentText)
            tuningValueRow("Hot Scalar", value: diagnostics.hotScalar.percentText)
            tuningValueRow("Log Cap", value: "\(OrbitalViewportDiagnosticLog.maximumEntries)")
            controlButton("Clear Log", active: false) {
                diagnosticLogEntries.removeAll()
                recordDiagnostic("Diagnostic log cleared")
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(diagnosticLogEntries) { entry in
                    Text(entry.line)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(theme.muted)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var viewportFrameRateBinding: Binding<OrbitalViewportFrameRate> {
        Binding(
            get: { viewportFrameRate },
            set: { frameRate in
                if viewportFrameRate != frameRate {
                    viewportFrameRate = frameRate
                    recordDiagnostic("Motion FPS set to \(frameRate.title)")
                }
            }
        )
    }

    private var themeBinding: Binding<OrbitalViewportRenderStyle> {
        Binding(
            get: { renderStyle },
            set: { style in
                if renderStyle != style {
                    renderStyle = style
                    recordDiagnostic("Orbisonic theme set to \(style.title)")
                }
            }
        )
    }

    private func setVUDriveMode(_ mode: OrbitalViewportVUDriveMode) {
        guard vuDriveMode != mode else {
            return
        }
        vuDriveMode = mode
        recordDiagnostic("VU drive set to \(mode.title)")
    }

    private func applyCubeVUPreset(_ preset: OrbitalViewportCubeVUPreset) {
        cubeVUPreset = preset
        cubeVUSettings = preset.settings
        recordDiagnostic("Cube VU preset set to \(preset.title)")
    }

    private func currentMeterDiagnostics() -> OrbitalViewportMeterDiagnostics {
        OrbitalViewportMeterDiagnostics.make(
            channel: selectedChannel,
            source: activeMeterSource,
            settings: cubeVUSettings,
            timeMS: currentTimeMS()
        )
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .textCase(.uppercase)
            .foregroundStyle(theme.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func controlButton(
        _ title: String,
        active: Bool,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: OrbitalViewportLabTheme.controlFontSize, weight: .semibold))
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: OrbitalViewportLabTheme.controlHeight)
                .padding(.horizontal, 9)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .foregroundStyle(active ? theme.text : theme.muted)
        .background(active ? theme.buttonActiveBackground : theme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(active ? theme.buttonActiveBorder : theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
        .opacity(disabled ? 0.62 : 1)
    }

    private func transportButton(
        systemName: String,
        title: String,
        active: Bool,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .heavy))
                .frame(maxWidth: .infinity, minHeight: OrbitalViewportLabTheme.controlHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(title)
        .foregroundStyle(active ? theme.text : theme.muted)
        .background(active ? theme.buttonActiveBackground : theme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(active ? theme.buttonActiveBorder : theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
        .opacity(disabled ? 0.62 : 1)
    }

    private func controlButtonGroup<Value: Identifiable & Equatable>(
        _ values: [Value],
        selection: Value,
        title: KeyPath<Value, String>,
        action: @escaping (Value) -> Void
    ) -> some View {
        VStack(spacing: 6) {
            ForEach(values) { value in
                controlButton(value[keyPath: title], active: selection == value) {
                    action(value)
                }
            }
        }
    }

    private func themeButton(_ style: OrbitalViewportRenderStyle) -> some View {
        let isActive = renderStyle == style
        let optionTheme = OrbitalViewportTheme(style: style)
        return Button {
            themeBinding.wrappedValue = style
        } label: {
            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    themeSwatch(optionTheme.accent)
                    themeSwatch(optionTheme.accentSecondary)
                    themeSwatch(optionTheme.vuHot)
                }
                .frame(width: 42, alignment: .leading)

                VStack(alignment: .leading, spacing: 1) {
                    Text(style.title)
                        .font(.system(size: 11, weight: .heavy))
                        .lineLimit(1)
                    Text(style.subtitle)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(isActive ? optionTheme.text.opacity(0.74) : theme.muted)
                }

                Spacer(minLength: 6)

                if isActive {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(optionTheme.accent)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
            .padding(.horizontal, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isActive ? optionTheme.text : theme.muted)
        .background(isActive ? optionTheme.buttonActiveBackground : theme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(isActive ? optionTheme.buttonActiveBorder : theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
    }

    private func themeSwatch(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(color)
            .frame(width: 11, height: 18)
            .overlay(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 0.6)
            )
    }

    private func labSliderRow(
        title: String,
        value: Binding<Double>,
        accessibilityValue: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(theme.text)
            OrbitalViewportLabSlider(
                title: title,
                value: value,
                range: 0...100,
                step: 1,
                theme: theme,
                accessibilityValue: accessibilityValue
            )
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(theme.text)
                .lineLimit(1)
            Spacer(minLength: 8)
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(theme.accent)
                .frame(width: OrbitalViewportLabTheme.switchColumnWidth, alignment: .trailing)
        }
        .frame(minHeight: OrbitalViewportLabTheme.toggleRowHeight)
    }

    private func tuningTray<Content: View>(
        _ title: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.12)) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(theme.accent)
                        .frame(width: 12)
                    Text(title)
                        .font(.system(size: 11, weight: .heavy))
                        .textCase(.uppercase)
                        .foregroundStyle(theme.text)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, minHeight: OrbitalViewportLabTheme.controlHeight, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(title)
            .accessibilityValue(isExpanded.wrappedValue ? "expanded" : "collapsed")

            if isExpanded.wrappedValue {
                VStack(alignment: .leading, spacing: 10) {
                    content()
                }
                .padding(.top, 8)
            }
        }
        .padding(9)
        .background(theme.panelSecondaryBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
    }

    private func tuningValueRow(_ title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(theme.text)
                .lineLimit(1)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(theme.muted)
                .monospacedDigit()
                .lineLimit(1)
        }
        .frame(minHeight: 22)
    }

    private func tuningSliderRow(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        valueText: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            tuningValueRow(title, value: valueText)
            OrbitalViewportLabSlider(
                title: title,
                value: value,
                range: range,
                step: step,
                theme: theme,
                accessibilityValue: valueText
            )
        }
    }

    private func tuningStepperRow(
        _ title: String,
        value: Binding<Int>,
        range: ClosedRange<Int>
    ) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(theme.text)
            Spacer(minLength: 8)
            Stepper(value: value, in: range) {
                Text("\(value.wrappedValue)")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.muted)
                    .monospacedDigit()
            }
            .labelsHidden()
        }
        .frame(minHeight: OrbitalViewportLabTheme.toggleRowHeight)
    }

    private func viewport(
        renderConfiguration: OrbitalViewportRenderConfiguration,
        snapshot: OrbitalViewportSnapshot
    ) -> some View {
        OrbitalViewport3DSceneView(
            activeFramesPerSecond: renderConfiguration.activeViewportFramesPerSecond,
            configuration: renderConfiguration,
            snapshot: snapshot,
            onDragStarted: {
                beginViewportDrag()
            },
            onDrag: { delta in
                let startYaw = dragStartYaw ?? yaw
                let startPitch = dragStartPitch ?? pitch
                yaw = startYaw - Double(delta.width) * 0.006
                pitch = min(
                    OrbitalViewportOrbitState.maxPitch,
                    max(-OrbitalViewportOrbitState.maxPitch, startPitch - Double(delta.height) * 0.006)
                )
                cameraAdjusted = true
            },
            onDragEnded: {
                dragStartYaw = nil
                dragStartPitch = nil
                isDragging = false
                anchorSpin(to: yaw)
            },
            onZoom: { delta in
                zoom = min(1.75, max(0.62, zoom * (delta > 0 ? 1.06 : 0.94)))
            },
            onSelect: { channel in
                if selectedChannel != channel {
                    selectedChannel = channel
                    if let channel {
                        recordDiagnostic("Selected speaker \(String(format: "%02d", channel))")
                    } else {
                        recordDiagnostic("Cleared speaker selection")
                    }
                }
            }
        )
            .accessibilityLabel("Orbital 3D Sonic Sphere viewport")
            .simultaneousGesture(magnificationGesture())
    }

    private var tuningPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                orbisonicThemeTray
                vuDriveTray
                speakerGeometryTray
                meterCalibrationTray
                surfaceBloomTray
                presetsTray
                performanceTray
                diagnosticsTray
            }
            .padding(12)
        }
        .scrollIndicators(.hidden)
        .background(theme.panelBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(theme.line)
                .frame(width: 1)
        }
    }

    private func footer() -> some View {
        HStack(spacing: 16) {
            HStack(spacing: 0) {
                Text(cameraText)
                    .foregroundStyle(theme.text)
                    .fontWeight(.semibold)
                Text(" / Center locked / DomeLab panel")
            }
            .font(.system(size: 12))
            .lineLimit(1)
            Spacer()
            chip {
                Circle()
                    .fill(theme.dot)
                    .shadow(color: theme.dot.opacity(0.72), radius: renderStyle == .bw ? 0 : 6)
                    .frame(width: 8, height: 8)
                Text(vuDriveMode == .impulseTest ? "Impulse test: sphere ripple" : localAudio.footerLabel)
            }
            chip {
                Text("Zoom \(zoom.formatted(.number.precision(.fractionLength(2))))x")
                    .monospacedDigit()
            }
            if let exportStatus {
                chip {
                    Text(exportStatus.message)
                        .foregroundStyle(exportStatus.isError ? OrbitalViewportLabTheme.red : theme.text)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(theme.statusBackground)
        .foregroundStyle(theme.muted)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.line)
                .frame(height: 1)
        }
    }

    private var cameraText: String {
        cameraAdjusted ? "\(cameraView.title) adjusted" : cameraView.title
    }

    private func displayedYaw(at date: Date) -> Double {
        displayedYaw(timeMS: date.timeIntervalSinceReferenceDate * 1000)
    }

    private func displayedYaw(timeMS: Double) -> Double {
        guard spin && !isDragging else {
            return yaw
        }
        return spinStartYaw - ((timeMS - spinStartTimeMS) * OrbitalViewportOrbitState.spinRadiansPerMS)
    }

    private func currentTimeMS() -> Double {
        Date.timeIntervalSinceReferenceDate * 1000
    }

    private func anchorSpin(to currentYaw: Double, at date: Date = Date()) {
        spinStartYaw = currentYaw
        spinStartTimeMS = date.timeIntervalSinceReferenceDate * 1000
    }

    private func commitDisplayedYaw(at date: Date = Date()) {
        let currentYaw = displayedYaw(at: date)
        yaw = currentYaw
        anchorSpin(to: currentYaw, at: date)
    }

    private func chip<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 7, content: content)
            .font(.system(size: 12))
            .foregroundStyle(theme.text)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(theme.chipBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(theme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    private func setView(_ view: OrbitalViewportCameraView) {
        commitDisplayedYaw()
        cameraView = view
        cameraAdjusted = false
        let preset = view.preset
        yaw = preset.yaw
        pitch = preset.pitch
        anchorSpin(to: preset.yaw)
    }

    private func resetView() {
        commitDisplayedYaw()
        zoom = 1
        setView(cameraView)
    }

    private func toggleSpin() {
        commitDisplayedYaw()
        spin.toggle()
        anchorSpin(to: yaw)
    }

    private func beginViewportDrag() {
        commitDisplayedYaw()
        dragStartYaw = yaw
        dragStartPitch = pitch
        isDragging = true
    }

    private func dragGesture(snapshot: OrbitalViewportSnapshot) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if dragStartYaw == nil {
                    dragStartYaw = yaw
                    dragStartPitch = pitch
                    isDragging = true
                }

                let dx = value.translation.width
                let dy = value.translation.height
                if abs(dx) > 2 || abs(dy) > 2 {
                    yaw = (dragStartYaw ?? yaw) - Double(dx) * 0.006
                    pitch = min(
                        OrbitalViewportOrbitState.maxPitch,
                        max(-OrbitalViewportOrbitState.maxPitch, (dragStartPitch ?? pitch) - Double(dy) * 0.006)
                    )
                    cameraAdjusted = true
                }
            }
            .onEnded { value in
                defer {
                    dragStartYaw = nil
                    dragStartPitch = nil
                    isDragging = false
                }

                if abs(value.translation.width) < 4 && abs(value.translation.height) < 4 {
                    selectSpeaker(at: value.location, snapshot: snapshot)
                }
            }
    }

    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if magnificationStartZoom == nil {
                    magnificationStartZoom = zoom
                }
                zoom = min(1.75, max(0.62, (magnificationStartZoom ?? zoom) * value))
            }
            .onEnded { _ in
                magnificationStartZoom = nil
            }
    }

    private func selectSpeaker(at point: CGPoint, snapshot: OrbitalViewportSnapshot) {
        let visibleSpeakers = snapshot.speakers.filter(\.visible)
        guard let best = visibleSpeakers.min(by: {
            hypot($0.screen.x - point.x, $0.screen.y - point.y) < hypot($1.screen.x - point.x, $1.screen.y - point.y)
        }) else {
            selectedChannel = nil
            return
        }

        let distance = hypot(best.screen.x - point.x, best.screen.y - point.y)
        selectedChannel = distance < 18 * speakerSize ? best.channel : nil
    }

    private func exportCurrentPNG() {
        exportInProgress = true
        exportStatus = OrbitalViewportExportStatus(message: "Exporting PNG...", isError: false)
        recordDiagnostic("PNG export started")

        #if os(macOS)
        DispatchQueue.main.async {
            let result: Result<URL, Error>
            do {
                let url = try OrbitalViewportPNGExporter.writeApplicationWindowSnapshot(style: renderStyle)
                result = .success(url)
            } catch {
                result = .failure(error)
            }
            handleExportResult(result)
        }
        #else
        DispatchQueue.main.async {
            handleExportResult(.failure(OrbitalViewportExportError.missingView))
        }
        #endif
    }

    private func exportSettingsJSON() {
        exportStatus = OrbitalViewportExportStatus(message: "Exporting JSON...", isError: false)
        recordDiagnostic("Settings JSON export started")

        DispatchQueue.main.async {
            let payload = OrbitalViewportSettingsExportPayload(
                renderStyle: renderStyle,
                geodesicSaturation: geodesicSaturation,
                speakerShape: speakerShape,
                leftPanel: OrbitalViewportLeftPanelSettings(
                    audioSource: OrbitalViewportAudioSourceExportSettings(
                        mode: localAudio.hasLoadedAudio ? .localAudioFile : .fakeMeterStream,
                        hasLoadedAudio: localAudio.hasLoadedAudio,
                        fileName: localAudio.fileDisplayName,
                        filePath: localAudio.filePath,
                        isPlaying: localAudio.isPlaying,
                        statusText: localAudio.statusText
                    ),
                    camera: OrbitalViewportCameraExportSettings(
                        cameraView: cameraView,
                        yaw: yaw,
                        pitch: pitch,
                        zoom: zoom,
                        spin: spin,
                        cameraAdjusted: cameraAdjusted
                    ),
                    speakerType: speakerShape,
                    viewDetail: OrbitalViewportViewDetailExportSettings(
                        speakerSizeSlider: speakerSizeSlider,
                        speakerSize: speakerSize,
                        fogDensitySlider: fogDensitySlider,
                        fogDensity: fogDensity,
                        showSpeakerNumbers: showSpeakerNumbers,
                        showHiddenLines: showHiddenLines
                    ),
                    selectedChannel: selectedChannel
                ),
                driveMode: vuDriveMode,
                cubePreset: cubeVUPreset,
                cubeSettings: cubeVUSettings,
                activeViewportFramesPerSecond: viewportFrameRate.framesPerSecond,
                meterOnlyViewportFramesPerSecond: Self.meterOnlyViewportFramesPerSecond,
                inspectorRefreshFramesPerSecond: Self.inspectorRefreshFramesPerSecond,
                drawsOnDemand: !OrbitalViewport3DSceneView.rendersContinuously
            )
            let result: Result<URL, Error>
            do {
                result = .success(try OrbitalViewportSettingsJSONExporter.writeSettings(payload: payload))
            } catch {
                result = .failure(error)
            }
            handleSettingsExportResult(result)
        }
    }

    private func handleExportResult(_ result: Result<URL, Error>) {
        exportInProgress = false
        let status: OrbitalViewportExportStatus
        switch result {
        case .success:
            status = OrbitalViewportExportStatus(message: "Saved PNG to Desktop", isError: false)
            recordDiagnostic("PNG export saved to Desktop")
        case .failure(let error):
            status = OrbitalViewportExportStatus(
                message: "PNG export failed: \(error.localizedDescription)",
                isError: true
            )
            recordDiagnostic("PNG export failed: \(error.localizedDescription)")
        }
        exportStatus = status
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if exportStatus?.id == status.id {
                exportStatus = nil
            }
        }
    }

    private func handleSettingsExportResult(_ result: Result<URL, Error>) {
        let status: OrbitalViewportExportStatus
        switch result {
        case .success:
            status = OrbitalViewportExportStatus(message: "Saved JSON to Desktop", isError: false)
            recordDiagnostic("Settings JSON saved to Desktop")
        case .failure(let error):
            status = OrbitalViewportExportStatus(
                message: "JSON export failed: \(error.localizedDescription)",
                isError: true
            )
            recordDiagnostic("Settings JSON export failed: \(error.localizedDescription)")
        }
        exportStatus = status
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if exportStatus?.id == status.id {
                exportStatus = nil
            }
        }
    }

    private func recordDiagnostic(_ message: String) {
        OrbitalViewportDiagnosticLog.append(message, to: &diagnosticLogEntries)
    }
}

struct OrbitalViewportExportStatus: Equatable {
    let id = UUID()
    let message: String
    let isError: Bool
}

struct OrbitalViewportDiagnosticLogEntry: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let message: String

    var line: String {
        "\(Self.formatter.string(from: timestamp))  \(message)"
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

enum OrbitalViewportDiagnosticLog {
    static let maximumEntries = 100

    static func initialEntries() -> [OrbitalViewportDiagnosticLogEntry] {
        [
            OrbitalViewportDiagnosticLogEntry(
                timestamp: Date(),
                message: "Viewer started"
            )
        ]
    }

    static func append(_ message: String, to entries: inout [OrbitalViewportDiagnosticLogEntry]) {
        entries.insert(
            OrbitalViewportDiagnosticLogEntry(timestamp: Date(), message: message),
            at: 0
        )
        if entries.count > maximumEntries {
            entries.removeLast(entries.count - maximumEntries)
        }
    }
}

struct OrbitalViewportAudioDiagnosticEvent: Equatable {
    let id = UUID()
    let message: String
}

struct OrbitalViewportMeterSample: Equatable {
    let rms: Double
    let peak: Double

    static let silent = OrbitalViewportMeterSample(rms: 0, peak: 0)

    init(rms: Double, peak: Double) {
        self.rms = OrbitalViewportMath.clamp01(rms)
        self.peak = OrbitalViewportMath.clamp01(max(peak, rms))
    }

    static func displayScalar(powerDB: Float) -> Double {
        guard powerDB.isFinite, powerDB > -80 else {
            return 0
        }
        let linear = pow(10, Double(powerDB) / 20)
        return OrbitalViewportMath.clamp01(pow(linear, 0.65))
    }

    static func monoSample(
        averagePowerDB: [Float],
        peakPowerDB: [Float]
    ) -> OrbitalViewportMeterSample {
        let channelCount = max(1, averagePowerDB.count)
        let rmsTotal = averagePowerDB.reduce(0.0) { partial, power in
            partial + displayScalar(powerDB: power)
        }
        let peak = peakPowerDB.reduce(0.0) { partial, power in
            max(partial, displayScalar(powerDB: power))
        }
        return OrbitalViewportMeterSample(
            rms: rmsTotal / Double(channelCount),
            peak: peak
        )
    }
}

struct OrbitalViewportMeterSource: Equatable {
    enum Mode: Equatable {
        case fake
        case localAudio(UUID)
        case impulseTest
    }

    let mode: Mode
    private let localAudio: OrbitalViewportLocalAudioController?

    static let fake = OrbitalViewportMeterSource(mode: .fake, localAudio: nil)
    static let sphereImpulseTest = OrbitalViewportMeterSource(mode: .impulseTest, localAudio: nil)

    static func localAudio(_ controller: OrbitalViewportLocalAudioController) -> OrbitalViewportMeterSource {
        OrbitalViewportMeterSource(mode: .localAudio(controller.sourceID), localAudio: controller)
    }

    static func == (lhs: OrbitalViewportMeterSource, rhs: OrbitalViewportMeterSource) -> Bool {
        lhs.mode == rhs.mode
    }

    func meter(channel: Int, timeMS: Double) -> OrbitalViewportMeterSample {
        switch mode {
        case .fake:
            let meter = OrbitalViewportMath.fakeMeter(channel: channel, timeMS: timeMS)
            return OrbitalViewportMeterSample(rms: meter.rms, peak: meter.peak)
        case .localAudio:
            return localAudio?.currentMeterSample() ?? .silent
        case .impulseTest:
            return OrbitalViewportImpulsePattern.meter(channel: channel, timeMS: timeMS)
        }
    }
}

enum OrbitalViewportImpulsePattern {
    static let patternName = "sphere-ripple-impulse"

    static func meter(channel: Int, timeMS: Double) -> OrbitalViewportMeterSample {
        let speaker = OrbitalViewportSpeaker.referenceSpeakers[safe: channel - 1]
        let position = speaker.map { OVVector3($0).normalized() } ?? OVVector3(x: 0, y: 0, z: 1)
        let seconds = timeMS / 1000
        let primaryOrigin = movingOrigin(seconds: seconds, phase: 0)
        let secondaryOrigin = movingOrigin(seconds: seconds * 0.73, phase: 1.7)
        let primary = expandingRing(
            angle: angularDistance(position, primaryOrigin),
            seconds: seconds,
            period: 1.65,
            speedBias: 0
        )
        let secondary = expandingRing(
            angle: angularDistance(position, secondaryOrigin),
            seconds: seconds + 0.54,
            period: 2.25,
            speedBias: 0.42
        ) * 0.62
        let sweep = pow(max(0, 0.5 + 0.5 * sin(seconds * 2.3 + position.y * 3.7 + position.x * 1.4)), 3) * 0.14
        let meridian = pow(max(0, 0.5 + 0.5 * cos(seconds * 2.1 + atan2(position.z, position.x) * 2.0)), 4) * 0.18
        let coreFlash = gaussian(angularDistance(position, primaryOrigin), width: 0.22) * 0.34
        let rms = OrbitalViewportMath.clamp01(0.03 + primary * 1.05 + secondary * 0.62 + sweep + meridian + coreFlash)
        let peak = OrbitalViewportMath.clamp01(rms + max(primary, secondary) * 0.22)
        return OrbitalViewportMeterSample(rms: rms, peak: peak)
    }

    private static func movingOrigin(seconds: Double, phase: Double) -> OVVector3 {
        let latitude = sin(seconds * 0.41 + phase) * 0.72
        let longitude = seconds * 0.77 + sin(seconds * 0.19 + phase) * 0.65 + phase
        let horizontal = sqrt(max(0.0001, 1 - latitude * latitude))
        return OVVector3(
            x: cos(longitude) * horizontal,
            y: latitude,
            z: sin(longitude) * horizontal
        ).normalized()
    }

    private static func expandingRing(
        angle: Double,
        seconds: Double,
        period: Double,
        speedBias: Double
    ) -> Double {
        let phase = positiveRemainder(seconds + speedBias, period) / period
        let radius = phase * Double.pi
        let fade = pow(max(0, 1 - phase), 0.45)
        return gaussian(abs(angle - radius), width: 0.16 + phase * 0.05) * fade
    }

    private static func angularDistance(_ lhs: OVVector3, _ rhs: OVVector3) -> Double {
        acos(min(1, max(-1, lhs.normalized().dot(rhs.normalized()))))
    }

    private static func gaussian(_ distance: Double, width: Double) -> Double {
        exp(-pow(distance / max(0.001, width), 2))
    }

    private static func positiveRemainder(_ value: Double, _ divisor: Double) -> Double {
        let remainder = value.truncatingRemainder(dividingBy: divisor)
        return remainder >= 0 ? remainder : remainder + divisor
    }
}

struct OrbitalViewportMeterDiagnostics: Equatable {
    let channel: Int
    let rawRMS: Double
    let rawPeak: Double
    let calibratedRMS: Double
    let displayScalar: Double
    let hotScalar: Double
    let paletteHeat: Double

    static func make(
        channel requestedChannel: Int?,
        source: OrbitalViewportMeterSource,
        settings: OrbitalViewportCubeVUSettings,
        timeMS: Double
    ) -> OrbitalViewportMeterDiagnostics {
        let channel = requestedChannel ?? peakChannel(source: source, timeMS: timeMS)
        let sample = source.meter(channel: channel, timeMS: timeMS)
        let scalars = SpeakerCubeVUScalars(
            rawRms: Float(sample.rms),
            settings: settings.coreSettings,
            paletteValue: Float(sample.peak)
        )
        return OrbitalViewportMeterDiagnostics(
            channel: channel,
            rawRMS: sample.rms,
            rawPeak: sample.peak,
            calibratedRMS: Double(scalars.calibratedRms),
            displayScalar: Double(scalars.displayVuScalar),
            hotScalar: Double(scalars.hotScalar),
            paletteHeat: Double(scalars.paletteHeat)
        )
    }

    private static func peakChannel(source: OrbitalViewportMeterSource, timeMS: Double) -> Int {
        OrbitalViewportSpeaker.referenceSpeakers.max {
            source.meter(channel: $0.channel, timeMS: timeMS).peak <
            source.meter(channel: $1.channel, timeMS: timeMS).peak
        }?.channel ?? 1
    }
}

final class OrbitalViewportLocalAudioController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var fileDisplayName: String?
    @Published private(set) var filePath: String?
    @Published private(set) var isPlaying = false
    @Published private(set) var statusText = "Fake meter stream"
    @Published private(set) var latestDiagnosticEvent: OrbitalViewportAudioDiagnosticEvent?

    private var player: AVAudioPlayer?
    private(set) var sourceID = UUID()

    var hasLoadedAudio: Bool {
        player != nil
    }

    var meterSource: OrbitalViewportMeterSource {
        guard player != nil else {
            return .fake
        }
        return .localAudio(self)
    }

    var footerLabel: String {
        guard let fileDisplayName else {
            return "Fake meter stream"
        }
        return isPlaying ? "Local audio: \(fileDisplayName)" : "Local audio paused"
    }

    func chooseAudioFile() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.title = "Choose Audio File"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.audio]
        guard panel.runModal() == .OK,
              let url = panel.url
        else {
            return
        }
        load(url: url)
        #endif
    }

    func play() {
        guard let player else {
            return
        }
        guard !player.isPlaying else {
            return
        }
        player.play()
        isPlaying = true
        statusText = "Playing"
        publish("Audio playback started")
    }

    func pause() {
        guard let player, player.isPlaying else {
            return
        }
        player.pause()
        isPlaying = false
        statusText = "Paused"
        publish("Audio playback paused")
    }

    func currentMeterSample() -> OrbitalViewportMeterSample {
        guard let player else {
            return .silent
        }
        guard player.isPlaying else {
            return .silent
        }

        player.updateMeters()
        let channelCount = max(1, player.numberOfChannels)
        var averagePowerDB: [Float] = []
        var peakPowerDB: [Float] = []
        averagePowerDB.reserveCapacity(channelCount)
        peakPowerDB.reserveCapacity(channelCount)
        for channel in 0..<channelCount {
            averagePowerDB.append(player.averagePower(forChannel: channel))
            peakPowerDB.append(player.peakPower(forChannel: channel))
        }
        return OrbitalViewportMeterSample.monoSample(
            averagePowerDB: averagePowerDB,
            peakPowerDB: peakPowerDB
        )
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        statusText = flag ? "Finished" : "Stopped"
        publish(flag ? "Audio playback finished" : "Audio playback stopped")
    }

    private func load(url: URL) {
        do {
            let nextPlayer = try AVAudioPlayer(contentsOf: url)
            nextPlayer.delegate = self
            nextPlayer.isMeteringEnabled = true
            nextPlayer.prepareToPlay()
            player?.stop()
            player = nextPlayer
            sourceID = UUID()
            fileDisplayName = url.lastPathComponent
            filePath = url.path
            isPlaying = false
            statusText = "Loaded"
            publish("Loaded audio file: \(url.lastPathComponent)")
        } catch {
            player = nil
            sourceID = UUID()
            fileDisplayName = nil
            filePath = nil
            isPlaying = false
            statusText = "Audio load failed"
            publish("Audio load failed: \(url.lastPathComponent)")
        }
    }

    private func publish(_ message: String) {
        latestDiagnosticEvent = OrbitalViewportAudioDiagnosticEvent(message: message)
    }
}

struct OrbitalViewportLabSlider: View {
    static let rendersSingleTrack = true
    static let showsInlineValue = false
    static let trackHeight: CGFloat = 4
    static let thumbSize: CGFloat = 14

    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let theme: OrbitalViewportTheme
    let accessibilityValue: String

    var body: some View {
        GeometryReader { proxy in
            let width = max(1, proxy.size.width)
            let progress = CGFloat(normalizedValue)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.line)
                    .frame(height: Self.trackHeight)
                Capsule()
                    .fill(theme.accent)
                    .frame(width: max(Self.trackHeight, width * progress), height: Self.trackHeight)
                Circle()
                    .fill(theme.text)
                    .overlay(
                        Circle()
                            .stroke(theme.accent, lineWidth: 2)
                    )
                    .shadow(color: theme.accent.opacity(0.34), radius: 4)
                    .frame(width: Self.thumbSize, height: Self.thumbSize)
                    .offset(x: min(width - Self.thumbSize, max(0, width * progress - Self.thumbSize * 0.5)))
            }
            .frame(width: width, height: proxy.size.height, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateValue(locationX: gesture.location.x, width: width)
                    }
            )
        }
        .frame(height: 24)
        .accessibilityElement()
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(accessibilityValue))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                setValue(value + step)
            case .decrement:
                setValue(value - step)
            @unknown default:
                break
            }
        }
    }

    private var normalizedValue: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else {
            return 0
        }
        return OrbitalViewportMath.clamp01((value - range.lowerBound) / span)
    }

    private func updateValue(locationX: CGFloat, width: CGFloat) {
        let progress = OrbitalViewportMath.clamp01(Double(locationX / max(1, width)))
        let rawValue = range.lowerBound + progress * (range.upperBound - range.lowerBound)
        setValue(rawValue)
    }

    private func setValue(_ newValue: Double) {
        let stepped = step > 0
            ? (round((newValue - range.lowerBound) / step) * step) + range.lowerBound
            : newValue
        value = min(range.upperBound, max(range.lowerBound, stepped))
    }
}

enum OrbitalViewportExportError: Error, Equatable {
    case missingView
    case missingPNGData
    case missingDesktopDirectory
    case timedOut
}

extension OrbitalViewportExportError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingView:
            return "missing app window"
        case .missingPNGData:
            return "missing PNG data"
        case .missingDesktopDirectory:
            return "missing Desktop folder"
        case .timedOut:
            return "timed out"
        }
    }
}

enum OrbitalViewportPNGExporter {
    static let exportScope = "application-window"
    static let exportsTransparentViewportOnly = false

    static func fileName(style: OrbitalViewportRenderStyle, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return "Orbital View VU Kit \(formatter.string(from: date)) \(style.title).png"
    }

    static func destinationURL(
        style: OrbitalViewportRenderStyle,
        date: Date,
        desktopDirectory: URL
    ) -> URL {
        desktopDirectory.appendingPathComponent(fileName(style: style, date: date))
    }

    #if os(macOS)
    static func writeApplicationWindowSnapshot(
        style: OrbitalViewportRenderStyle,
        date: Date = Date(),
        fileManager: FileManager = .default,
        windowProvider: () -> NSWindow? = { activeApplicationWindow() }
    ) throws -> URL {
        guard let window = windowProvider() else {
            throw OrbitalViewportExportError.missingView
        }
        guard let image = applicationWindowSnapshot(window: window) else {
            throw OrbitalViewportExportError.missingPNGData
        }
        return try writeSnapshot(image: image, style: style, date: date, fileManager: fileManager)
    }

    static func activeApplicationWindow() -> NSWindow? {
        NSApp.keyWindow
            ?? NSApp.mainWindow
            ?? NSApp.windows.first { $0.isVisible && $0.title == OrbitalViewportMockup.correctReviewAppName }
            ?? NSApp.windows.first { $0.isVisible }
    }

    static func applicationWindowSnapshot(window: NSWindow) -> NSImage? {
        window.displayIfNeeded()

        let windowID = CGWindowID(window.windowNumber)
        if let cgImage = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowID,
            [.bestResolution]
        ) {
            return NSImage(
                cgImage: cgImage,
                size: NSSize(width: cgImage.width, height: cgImage.height)
            )
        }

        guard let contentView = window.contentView else {
            return nil
        }
        let bounds = contentView.bounds
        guard let bitmap = contentView.bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        contentView.cacheDisplay(in: bounds, to: bitmap)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmap)
        return image
    }

    static func writeSnapshot(
        image: NSImage,
        style: OrbitalViewportRenderStyle,
        date: Date = Date(),
        fileManager: FileManager = .default
    ) throws -> URL {
        guard let png = pngData(from: image) else {
            throw OrbitalViewportExportError.missingPNGData
        }
        guard let desktop = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            throw OrbitalViewportExportError.missingDesktopDirectory
        }
        let url = destinationURL(style: style, date: date, desktopDirectory: desktop)
        try png.write(to: url, options: .atomic)
        return url
    }

    static func pngData(from image: NSImage) -> Data? {
        var rect = NSRect(origin: .zero, size: image.size)
        if let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) {
            return opaquePNGData(from: cgImage)
        }

        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let cgImage = bitmap.cgImage
        else {
            return nil
        }
        return opaquePNGData(from: cgImage)
    }

    static func opaquePNGData(from image: CGImage) -> Data? {
        let width = image.width
        let height = image.height
        guard width > 0, height > 0,
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
              )
        else {
            return nil
        }

        context.setFillColor(NSColor(red: 2 / 255, green: 7 / 255, blue: 10 / 255, alpha: 1).cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let flattened = context.makeImage() else {
            return nil
        }
        return NSBitmapImageRep(cgImage: flattened).representation(using: .png, properties: [:])
    }
    #endif
}

struct OrbitalViewportSettingsExportPayload: Codable, Equatable {
    let schemaVersion: Int
    let appName: String
    let exportedAt: String
    let renderStyle: OrbitalViewportRenderStyle
    let geodesicSaturation: Double
    let speakerShape: OrbitalViewportSpeakerShape
    let leftPanel: OrbitalViewportLeftPanelSettings
    let driveMode: OrbitalViewportVUDriveMode
    let cubePreset: OrbitalViewportCubeVUPreset
    let cubeSettings: OrbitalViewportCubeVUSettings
    let activeViewportFramesPerSecond: Int
    let meterOnlyViewportFramesPerSecond: Int
    let inspectorRefreshFramesPerSecond: Int
    let drawsOnDemand: Bool

    init(
        renderStyle: OrbitalViewportRenderStyle,
        geodesicSaturation: Double = 1,
        speakerShape: OrbitalViewportSpeakerShape,
        leftPanel: OrbitalViewportLeftPanelSettings = .default,
        driveMode: OrbitalViewportVUDriveMode,
        cubePreset: OrbitalViewportCubeVUPreset,
        cubeSettings: OrbitalViewportCubeVUSettings,
        activeViewportFramesPerSecond: Int,
        meterOnlyViewportFramesPerSecond: Int,
        inspectorRefreshFramesPerSecond: Int,
        drawsOnDemand: Bool,
        exportedAt date: Date = Date()
    ) {
        self.schemaVersion = 2
        self.appName = OrbitalViewportMockup.correctReviewAppName
        self.exportedAt = OrbitalViewportSettingsJSONExporter.timestampString(date: date)
        self.renderStyle = renderStyle
        self.geodesicSaturation = OrbitalViewportMath.clamp01(geodesicSaturation)
        self.speakerShape = speakerShape
        self.leftPanel = leftPanel
        self.driveMode = driveMode
        self.cubePreset = cubePreset
        self.cubeSettings = cubeSettings
        self.activeViewportFramesPerSecond = activeViewportFramesPerSecond
        self.meterOnlyViewportFramesPerSecond = meterOnlyViewportFramesPerSecond
        self.inspectorRefreshFramesPerSecond = inspectorRefreshFramesPerSecond
        self.drawsOnDemand = drawsOnDemand
    }
}

struct OrbitalViewportLeftPanelSettings: Codable, Equatable {
    static let `default` = OrbitalViewportLeftPanelSettings(
        audioSource: .default,
        camera: .default,
        speakerType: .prism,
        viewDetail: .default,
        selectedChannel: nil
    )

    let audioSource: OrbitalViewportAudioSourceExportSettings
    let camera: OrbitalViewportCameraExportSettings
    let speakerType: OrbitalViewportSpeakerShape
    let viewDetail: OrbitalViewportViewDetailExportSettings
    let selectedChannel: Int?
}

enum OrbitalViewportAudioSourceMode: String, Codable, Equatable {
    case fakeMeterStream
    case localAudioFile
}

struct OrbitalViewportAudioSourceExportSettings: Codable, Equatable {
    static let `default` = OrbitalViewportAudioSourceExportSettings(
        mode: .fakeMeterStream,
        hasLoadedAudio: false,
        fileName: nil,
        filePath: nil,
        isPlaying: false,
        statusText: "Fake meter stream"
    )

    let mode: OrbitalViewportAudioSourceMode
    let hasLoadedAudio: Bool
    let fileName: String?
    let filePath: String?
    let isPlaying: Bool
    let statusText: String
}

struct OrbitalViewportCameraExportSettings: Codable, Equatable {
    static let `default` = OrbitalViewportCameraExportSettings(
        cameraView: .isometric,
        yaw: 0,
        pitch: 0,
        zoom: 1,
        spin: false,
        cameraAdjusted: false
    )

    let cameraView: OrbitalViewportCameraView
    let yaw: Double
    let pitch: Double
    let zoom: Double
    let spin: Bool
    let cameraAdjusted: Bool
}

struct OrbitalViewportViewDetailExportSettings: Codable, Equatable {
    static let `default` = OrbitalViewportViewDetailExportSettings(
        speakerSizeSlider: 50,
        speakerSize: OrbitalViewportMath.speakerSize(fromSlider: 50),
        fogDensitySlider: 50,
        fogDensity: OrbitalViewportMath.fogDensity(fromSlider: 50),
        showSpeakerNumbers: false,
        showHiddenLines: false
    )

    let speakerSizeSlider: Double
    let speakerSize: Double
    let fogDensitySlider: Double
    let fogDensity: Double
    let showSpeakerNumbers: Bool
    let showHiddenLines: Bool
}

enum OrbitalViewportSettingsJSONExporter {
    static let filePrefix = "Orbital View VU Kit Settings"

    static func timestampString(date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    static func fileName(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return "\(filePrefix) \(formatter.string(from: date)).json"
    }

    static func jsonData(payload: OrbitalViewportSettingsExportPayload) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(payload)
    }

    static func writeSettings(
        payload: OrbitalViewportSettingsExportPayload,
        date: Date = Date(),
        fileManager: FileManager = .default
    ) throws -> URL {
        guard let desktop = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            throw OrbitalViewportExportError.missingDesktopDirectory
        }
        let url = desktop.appendingPathComponent(fileName(date: date))
        try jsonData(payload: payload).write(to: url, options: .atomic)
        return url
    }
}

public enum OrbitalViewportCameraView: String, CaseIterable, Identifiable, Equatable, Codable {
    case plan
    case elevation
    case isometric

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .plan:
            return "Plan"
        case .elevation:
            return "Elevation"
        case .isometric:
            return "Isometric"
        }
    }

    fileprivate var preset: (yaw: Double, pitch: Double) {
        (0, 0)
    }

    fileprivate var baseViewDirection: OVVector3 {
        switch self {
        case .plan:
            return OVVector3(x: 0, y: 1, z: 0)
        case .elevation:
            return OVVector3(x: 0, y: 0, z: 1)
        case .isometric:
            let yaw = Double.pi * 0.25
            let pitch = Double.pi * 0.22
            let horizontal = cos(pitch)
            return OVVector3(
                x: sin(yaw) * horizontal,
                y: sin(pitch),
                z: cos(yaw) * horizontal
            ).normalized()
        }
    }

    fileprivate var baseUp: OVVector3 {
        switch self {
        case .plan:
            return OVVector3(x: 0, y: 0, z: -1)
        case .elevation:
            return OVVector3(x: 0, y: 1, z: 0)
        case .isometric:
            let direction = baseViewDirection
            let worldUp = OVVector3(x: 0, y: 1, z: 0)
            return (worldUp - (direction * worldUp.dot(direction)))
                .normalized(fallback: OVVector3(x: 0, y: 1, z: 0))
        }
    }
}

public enum OrbitalViewportRenderStyle: String, CaseIterable, Identifiable, Equatable, Codable {
    case purple
    case flamingo
    case green
    case bw
    case daftPunkBow
    case rackMint
    case rackPink
    case rackBlue
    case ember
    case graphite
    case flamingoGreen
    case dustyRose

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .purple:
            return "Purple"
        case .flamingo:
            return "Flamingo"
        case .green:
            return "Green"
        case .bw:
            return "B&W"
        case .daftPunkBow:
            return "Daft Punk Bow"
        case .rackMint:
            return "Rack Mint"
        case .rackPink:
            return "Rack Pink"
        case .rackBlue:
            return "Rack Blue"
        case .ember:
            return "Ember Console"
        case .graphite:
            return "Graphite"
        case .flamingoGreen:
            return "Flamingo Green"
        case .dustyRose:
            return "Dusty Rose"
        }
    }

    var subtitle: String {
        switch self {
        case .purple:
            return "Kimi Purple"
        case .flamingo:
            return "Flamingo Pink"
        case .green:
            return "Orbisonic Lab"
        case .bw:
            return "Neutral review"
        case .daftPunkBow:
            return "Rainbow VU"
        case .rackMint:
            return "Mint rack"
        case .rackPink:
            return "Pink rack"
        case .rackBlue:
            return "Blue rack"
        case .ember:
            return "Warm console"
        case .graphite:
            return "Silver graphite"
        case .flamingoGreen:
            return "Green lead"
        case .dustyRose:
            return "Rose lead"
        }
    }

    var palette: OrbitalViewportPalette {
        switch self {
        case .green:
            return OrbitalViewportPalette(
                backgroundTop: Self.rgb(7, 16, 20),
                backgroundBottom: Self.rgb(2, 7, 10),
                panel: Self.rgb(13, 24, 29).opacity(0.9),
                panelSoft: Color.white.opacity(0.045),
                toolbar: Self.rgb(5, 12, 15).opacity(0.7),
                line: Self.rgb(217, 251, 255).opacity(0.14),
                text: Self.rgb(239, 252, 255),
                textSoft: Self.rgb(159, 185, 189),
                accent: Self.rgb(94, 234, 212),
                accentSecondary: Self.rgb(170, 136, 255),
                success: Self.rgb(24, 206, 15),
                warning: Self.rgb(250, 204, 21),
                danger: Self.rgb(251, 113, 133)
            )
        case .purple:
            return Self.kimiPurplePalette
        case .daftPunkBow:
            return OrbitalViewportPalette(
                base: Self.kimiPurplePalette,
                vuRamp: [
                    OrbitalViewportVURampStop(position: 0.00, color: Self.rgb(167, 139, 250)),
                    OrbitalViewportVURampStop(position: 0.18, color: Self.rgb(91, 140, 255)),
                    OrbitalViewportVURampStop(position: 0.34, color: Self.rgb(34, 211, 238)),
                    OrbitalViewportVURampStop(position: 0.50, color: Self.rgb(52, 211, 153)),
                    OrbitalViewportVURampStop(position: 0.66, color: Self.rgb(253, 224, 71)),
                    OrbitalViewportVURampStop(position: 0.82, color: Self.rgb(251, 146, 60)),
                    OrbitalViewportVURampStop(position: 1.00, color: Self.rgb(239, 68, 68))
                ],
                compressedRainbowWell: Self.rgb(52, 64, 71)
            )
        case .rackMint:
            return Self.rackPalette(accent: Self.rackMintColor, accentSecondary: Self.rackPinkColor, warning: Self.rackBlueColor, danger: Self.rackPinkColor)
        case .rackPink:
            return Self.rackPalette(accent: Self.rackPinkColor, accentSecondary: Self.rackMintColor, warning: Self.rackBlueColor, danger: Self.rackPinkColor)
        case .rackBlue:
            return Self.rackPalette(accent: Self.rackBlueColor, accentSecondary: Self.rackMintColor, warning: Self.rackPinkColor, danger: Self.rgb(255, 109, 122))
        case .ember:
            return OrbitalViewportPalette(
                backgroundTop: Self.rgb(20, 13, 8),
                backgroundBottom: Self.rgb(6, 5, 4),
                panel: Self.rgb(27, 22, 18).opacity(0.92),
                panelSoft: Self.rgb(255, 178, 54).opacity(0.075),
                toolbar: Self.rgb(18, 13, 10).opacity(0.78),
                line: Self.rgb(255, 226, 177).opacity(0.16),
                text: Self.rgb(255, 246, 232),
                textSoft: Self.rgb(203, 180, 151),
                accent: Self.rgb(255, 178, 54),
                accentSecondary: Self.rgb(94, 234, 212),
                success: Self.rgb(77, 212, 132),
                warning: Self.rgb(250, 204, 21),
                danger: Self.rgb(251, 113, 133)
            )
        case .graphite:
            return OrbitalViewportPalette(
                backgroundTop: Self.rgb(15, 16, 18),
                backgroundBottom: Self.rgb(4, 5, 6),
                panel: Self.rgb(25, 27, 30).opacity(0.94),
                panelSoft: Color.white.opacity(0.055),
                toolbar: Self.rgb(16, 18, 21).opacity(0.8),
                line: Color.white.opacity(0.16),
                text: Self.rgb(245, 247, 250),
                textSoft: Self.rgb(170, 176, 184),
                accent: Self.rgb(229, 231, 235),
                accentSecondary: Self.rgb(94, 234, 212),
                success: Self.rgb(52, 211, 153),
                warning: Self.rgb(251, 191, 36),
                danger: Self.rgb(248, 113, 113)
            )
        case .flamingoGreen:
            return Self.flamingoPalette(accent: Self.flamingoPrimaryGreen, accentSecondary: Self.flamingoPinkColor, warning: Self.flamingoDeepGreen, danger: Self.flamingoDustyRose)
        case .flamingo:
            return Self.flamingoPalette(accent: Self.flamingoPinkColor, accentSecondary: Self.flamingoPrimaryGreen, warning: Self.flamingoDustyRose, danger: Self.flamingoPinkColor)
        case .dustyRose:
            return Self.flamingoPalette(accent: Self.flamingoDustyRose, accentSecondary: Self.flamingoPrimaryGreen, warning: Self.flamingoDeepGreen, danger: Self.flamingoPinkColor)
        case .bw:
            return OrbitalViewportPalette(
                backgroundTop: Self.rgb(9, 9, 10),
                backgroundBottom: Self.rgb(0, 0, 0),
                panel: Self.rgb(18, 18, 20).opacity(0.92),
                panelSoft: Color.white.opacity(0.055),
                toolbar: Self.rgb(14, 14, 16).opacity(0.78),
                line: Color.white.opacity(0.16),
                text: Self.rgb(248, 248, 248),
                textSoft: Self.rgb(178, 178, 178),
                accent: Self.rgb(235, 235, 235),
                accentSecondary: Self.rgb(150, 150, 150),
                success: Self.rgb(160, 160, 160),
                warning: Self.rgb(205, 205, 205),
                danger: Self.rgb(255, 255, 255)
            )
        }
    }

    private static var kimiPurplePalette: OrbitalViewportPalette {
        OrbitalViewportPalette(
            backgroundTop: rgb(10, 8, 17),
            backgroundBottom: rgb(0, 0, 0),
            panel: rgb(20, 24, 28).opacity(0.92),
            panelSoft: rgb(170, 136, 255).opacity(0.09),
            toolbar: rgb(29, 33, 37).opacity(0.82),
            line: Color.white.opacity(0.12),
            text: rgb(242, 242, 242),
            textSoft: rgb(170, 172, 173),
            accent: rgb(170, 136, 255),
            accentSecondary: rgb(50, 214, 191),
            success: rgb(24, 206, 15),
            warning: rgb(255, 178, 54),
            danger: rgb(255, 54, 54)
        )
    }

    private static func rackPalette(accent: Color, accentSecondary: Color, warning: Color, danger: Color) -> OrbitalViewportPalette {
        OrbitalViewportPalette(
            backgroundTop: rackPageBackground,
            backgroundBottom: rackWell,
            panel: rackSurface.opacity(0.94),
            panelSoft: rackCard.opacity(0.92),
            toolbar: rackDivider.opacity(0.88),
            line: rackTextSecondary.opacity(0.18),
            text: rackText,
            textSoft: rackTextSecondary,
            accent: accent,
            accentSecondary: accentSecondary,
            success: rackMintColor,
            warning: warning,
            danger: danger
        )
    }

    private static func flamingoPalette(accent: Color, accentSecondary: Color, warning: Color, danger: Color) -> OrbitalViewportPalette {
        OrbitalViewportPalette(
            backgroundTop: flamingoSecondaryDark,
            backgroundBottom: flamingoPrimaryDark,
            panel: flamingoPrimaryDark.opacity(0.94),
            panelSoft: accent.opacity(0.09),
            toolbar: flamingoSecondaryDark.opacity(0.82),
            line: accent.opacity(0.22),
            text: rgb(255, 247, 250),
            textSoft: rgb(206, 184, 194),
            accent: accent,
            accentSecondary: accentSecondary,
            success: flamingoPrimaryGreen,
            warning: warning,
            danger: danger
        )
    }

    private static func rgb(_ red: Double, _ green: Double, _ blue: Double) -> Color {
        Color(.sRGB, red: red / 255, green: green / 255, blue: blue / 255)
    }

    private static let flamingoPrimaryDark = rgb(30, 33, 42)
    private static let flamingoSecondaryDark = rgb(42, 46, 56)
    private static let flamingoPrimaryGreen = rgb(46, 204, 138)
    private static let flamingoDeepGreen = rgb(25, 123, 103)
    private static let flamingoPinkColor = rgb(244, 143, 170)
    private static let flamingoDustyRose = rgb(167, 84, 114)

    private static let rackPageBackground = rgb(38, 41, 44)
    private static let rackSurface = rgb(76, 79, 82)
    private static let rackDivider = rgb(62, 65, 68)
    private static let rackCard = rgb(47, 50, 53)
    private static let rackWell = rgb(32, 34, 38)
    private static let rackText = rgb(252, 255, 255)
    private static let rackTextSecondary = rgb(208, 212, 216)
    private static let rackMintColor = rgb(121, 228, 184)
    private static let rackPinkColor = rgb(238, 164, 230)
    private static let rackBlueColor = rgb(118, 203, 248)
}

struct OrbitalViewportVURampStop {
    let position: Double
    let color: Color
}

struct OrbitalViewportPalette {
    let backgroundTop: Color
    let backgroundBottom: Color
    let panel: Color
    let panelSoft: Color
    let toolbar: Color
    let line: Color
    let text: Color
    let textSoft: Color
    let accent: Color
    let accentSecondary: Color
    let success: Color
    let warning: Color
    let danger: Color
    let vuRamp: [OrbitalViewportVURampStop]
    let compressedRainbowWell: Color?

    init(
        backgroundTop: Color,
        backgroundBottom: Color,
        panel: Color,
        panelSoft: Color,
        toolbar: Color,
        line: Color,
        text: Color,
        textSoft: Color,
        accent: Color,
        accentSecondary: Color,
        success: Color,
        warning: Color,
        danger: Color,
        vuRamp: [OrbitalViewportVURampStop]? = nil,
        compressedRainbowWell: Color? = nil
    ) {
        self.backgroundTop = backgroundTop
        self.backgroundBottom = backgroundBottom
        self.panel = panel
        self.panelSoft = panelSoft
        self.toolbar = toolbar
        self.line = line
        self.text = text
        self.textSoft = textSoft
        self.accent = accent
        self.accentSecondary = accentSecondary
        self.success = success
        self.warning = warning
        self.danger = danger
        self.vuRamp = vuRamp ?? [
            OrbitalViewportVURampStop(position: 0, color: success),
            OrbitalViewportVURampStop(position: 0.5, color: warning),
            OrbitalViewportVURampStop(position: 1, color: danger)
        ]
        self.compressedRainbowWell = compressedRainbowWell
    }

    init(base: OrbitalViewportPalette, vuRamp: [OrbitalViewportVURampStop], compressedRainbowWell: Color? = nil) {
        self.init(
            backgroundTop: base.backgroundTop,
            backgroundBottom: base.backgroundBottom,
            panel: base.panel,
            panelSoft: base.panelSoft,
            toolbar: base.toolbar,
            line: base.line,
            text: base.text,
            textSoft: base.textSoft,
            accent: base.accent,
            accentSecondary: base.accentSecondary,
            success: base.success,
            warning: base.warning,
            danger: base.danger,
            vuRamp: vuRamp,
            compressedRainbowWell: compressedRainbowWell
        )
    }

    var vuGradientStops: [Gradient.Stop] {
        vuRamp
            .sorted { $0.position < $1.position }
            .map { Gradient.Stop(color: $0.color, location: $0.position) }
    }

    func vuColor(for level: Double) -> Color {
        let normalized = OrbitalViewportMath.clamp01(level)
        let stops = vuRamp.sorted { $0.position < $1.position }
        guard let first = stops.first else {
            return success
        }

        var lower = first
        var upper = first
        for stop in stops {
            if stop.position <= normalized {
                lower = stop
            }
            if stop.position >= normalized {
                upper = stop
                break
            }
        }

        #if os(macOS)
        let span = max(upper.position - lower.position, 0.000_001)
        let t = (normalized - lower.position) / span
        let lowerColor = (NSColor(lower.color).usingColorSpace(.deviceRGB) ?? NSColor(lower.color))
        let upperColor = (NSColor(upper.color).usingColorSpace(.deviceRGB) ?? NSColor(upper.color))
        return Color(
            .sRGB,
            red: Double(lowerColor.redComponent + (upperColor.redComponent - lowerColor.redComponent) * CGFloat(t)),
            green: Double(lowerColor.greenComponent + (upperColor.greenComponent - lowerColor.greenComponent) * CGFloat(t)),
            blue: Double(lowerColor.blueComponent + (upperColor.blueComponent - lowerColor.blueComponent) * CGFloat(t))
        )
        #else
        return lower.color
        #endif
    }
}

public enum OrbitalViewportSpeakerShape: String, CaseIterable, Identifiable, Equatable, Codable {
    case prism
    case sphere
    case cubeVU

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .prism:
            return "Prism"
        case .sphere:
            return "Sphere"
        case .cubeVU:
            return "Cube VU"
        }
    }
}

enum OrbitalViewportVUDriveMode: String, CaseIterable, Identifiable, Equatable, Codable {
    case music
    case impulseTest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .music:
            return "Music"
        case .impulseTest:
            return "Impulse Test"
        }
    }

    var statusTitle: String {
        switch self {
        case .music:
            return "Music source"
        case .impulseTest:
            return "Sphere ripple impulse"
        }
    }
}

struct OrbitalViewportCubeVUSettings: Equatable, Codable, Sendable {
    static let `default` = OrbitalViewportCubeVUSettings()

    var inputCalibration = 1.0
    var levelCompression = 1.0
    var displayCeiling = 1.0
    var hotResponse = 1.7
    var hotThreshold = 0.68
    var hotFillStrength = 0.86
    var paletteDrive = 1.7
    var idleTint = 0.10
    var bloomMin = 0.08
    var bloomMax = 0.92
    var bloomEdge = 0.16
    var rimHaloEdge = 0.0
    var responseCurve = 0.82
    var facePixels = 9
    var checkerContrast = 0.08
    var pixelFill = 1.0
    var surfaceCheckerOpacity = 1.0
    var cubeOutlineStrength = 0.0
    var speakerHeight = 1.0

    var coreSettings: SpeakerMeterVisualSettings {
        try! SpeakerMeterVisualSettings(
            inputCalibration: Float(inputCalibration),
            levelCompression: Float(levelCompression),
            displayCeiling: Float(displayCeiling),
            hotResponse: Float(hotResponse),
            hotThreshold: Float(hotThreshold),
            hotFillStrength: Float(hotFillStrength),
            vuPaletteDrive: Float(paletteDrive),
            idleTint: Float(idleTint),
            checkerContrast: Float(checkerContrast),
            speakerZScale: Float(speakerHeight),
            bloomMin: Float(bloomMin),
            bloomMax: Float(bloomMax),
            bloomEdge: Float(bloomEdge),
            responseCurve: Float(responseCurve),
            hotFill: Float(hotFillStrength),
            facePixels: facePixels
        )
    }
}

enum OrbitalViewportCubeVUPreset: String, CaseIterable, Identifiable, Equatable, Codable {
    case softCenterBloom
    case hotCoreBloom
    case haloEdgeBloom
    case blockCenterBloom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .softCenterBloom:
            return "Soft Center Bloom"
        case .hotCoreBloom:
            return "Hot Core Bloom"
        case .haloEdgeBloom:
            return "Halo Edge Bloom"
        case .blockCenterBloom:
            return "Block Center Bloom"
        }
    }

    var settings: OrbitalViewportCubeVUSettings {
        var settings = OrbitalViewportCubeVUSettings.default
        switch self {
        case .softCenterBloom:
            break
        case .hotCoreBloom:
            settings.hotResponse = 2.25
            settings.hotThreshold = 0.58
            settings.hotFillStrength = 0.94
            settings.paletteDrive = 2.0
            settings.idleTint = 0.12
            settings.bloomMin = 0.11
            settings.bloomMax = 0.98
            settings.bloomEdge = 0.18
            settings.rimHaloEdge = 0.12
            settings.responseCurve = 0.72
        case .haloEdgeBloom:
            settings.hotResponse = 1.85
            settings.hotThreshold = 0.64
            settings.hotFillStrength = 0.82
            settings.paletteDrive = 1.8
            settings.idleTint = 0.10
            settings.bloomMin = 0.07
            settings.bloomMax = 0.94
            settings.bloomEdge = 0.10
            settings.rimHaloEdge = 1.0
            settings.responseCurve = 0.88
        case .blockCenterBloom:
            settings.hotResponse = 1.95
            settings.hotThreshold = 0.62
            settings.hotFillStrength = 0.88
            settings.paletteDrive = 1.85
            settings.idleTint = 0.08
            settings.bloomMin = 0.10
            settings.bloomMax = 0.90
            settings.bloomEdge = 0.07
            settings.rimHaloEdge = 0.0
            settings.responseCurve = 0.82
            settings.facePixels = 6
            settings.checkerContrast = 0.14
        }
        return settings
    }
}

enum OrbitalViewportCubeVUSceneKitMaterial {
    static let defaultFacePixels = SpeakerMeterVisualSettings.default.facePixels
    static let shaderQuantizesFacePixels = true
    static let usesSceneKitShaderModifier = false
    static let usesRetainedFaceTextureCache = true
    static let usesSeparateHaloNode = false
    static let usesFrontFacePixelPlane = false
    static let usesActualCubeFaceMaterials = true
    static let cubeVUReadableFaceScale = 2.35
    static let cubeOutlineEdgeThicknessRatio = 0.026
    static let cubeOutlineNormalAlphaMultiplier = 0.58
    static let cubeOutlineSelectedAlphaMultiplier = 0.78
    static let cubeOutlineEmissionMultiplier = 0.18
    static let faceTexturePixelsPerFacePixel = 8
    static let faceTextureTileGapPixels = 0
    static let idleCheckerContrastFloor = 0.24
    static let faceTextureCacheLimit = 160

    private struct FaceTextureKey: Hashable {
        var facePixels: Int
        var display: Int
        var hot: Int
        var clip: Bool
        var pixelFill: Int
        var surfaceCheckerOpacity: Int
        var bloomMin: Int
        var bloomMax: Int
        var bloomEdge: Int
        var rimHaloEdge: Int
        var responseCurve: Int
        var idleTint: Int
        var checkerContrast: Int
        var hotFillStrength: Int
        var hotThreshold: Int
        var vuColor: Int
        var hotColor: Int
    }

    private static var faceTextureCache: [FaceTextureKey: NSImage] = [:]
    private static var faceTextureOrder: [FaceTextureKey] = []

    static let surfaceShader = """
    #pragma arguments
    float displayVuScalar;
    float hotScalar;
    float clipState;
    float bloomMin;
    float bloomMax;
    float bloomEdge;
    float rimHaloEdge;
    float responseCurve;
    float idleTint;
    float checkerContrast;
    float hotFillStrength;
    float hotThreshold;
    float facePixels;
    float alphaValue;
    #pragma body
    vec2 uv = _surface.diffuseTexcoord;
    float pixels = max(facePixels, 1.0);
    vec2 cell = (floor(uv * pixels) + vec2(0.5)) / pixels;
    vec2 grid = abs(fract(uv * pixels) - vec2(0.5));
    float gridLine = smoothstep(0.30, 0.5, max(grid.x, grid.y));
    float centerDistance = length(cell - vec2(0.5)) * 1.41421356;
    float bloomRadius = mix(bloomMin, bloomMax, pow(max(displayVuScalar, 0.0), max(responseCurve, 0.001)));
    float centerFill = 1.0 - smoothstep(bloomRadius, bloomRadius + max(bloomEdge, 0.001), centerDistance);
    float rimDistance = abs(centerDistance - bloomRadius);
    float rimFill = rimHaloEdge * displayVuScalar * (1.0 - smoothstep(bloomEdge * 0.32, bloomEdge * 0.74, rimDistance));
    float hotFill = hotFillStrength * smoothstep(hotThreshold, 1.0, hotScalar);
    float parity = mod(floor(cell.x * pixels) + floor(cell.y * pixels), 2.0);
    float checker = mix(1.0 - checkerContrast, 1.0 + checkerContrast, parity);
    vec3 vuColor = _surface.diffuse.rgb;
    vec3 hotColor = max(_surface.emission.rgb, vuColor);
    vec3 idleColor = mix(vec3(0.018, 0.022, 0.028), vuColor * 0.48, idleTint);
    float body = clamp((displayVuScalar * 0.22) + (centerFill * displayVuScalar * 1.08), 0.0, 1.0);
    vec3 rgb = mix(idleColor, vuColor, body) * checker;
    rgb += vuColor * centerFill * displayVuScalar * 0.38;
    rgb = mix(rgb, mix(vuColor, hotColor, 0.18), clamp(rimFill, 0.0, 1.0));
    rgb = mix(rgb, hotColor, clamp(hotFill, 0.0, 1.0));
    if (clipState > 0.5) {
        rgb = mix(rgb, vec3(1.0, 0.08, 0.02), 0.86);
        rgb += vec3(0.38, 0.08, 0.02) * centerFill;
    }
    rgb = mix(rgb, vec3(0.004, 0.006, 0.010), gridLine * 0.86);
    _surface.diffuse.rgb = clamp(rgb, 0.0, 1.0);
    _surface.diffuse.a *= alphaValue;
    _surface.emission.rgb = clamp(rgb * (0.16 + centerFill * 0.62 + hotFill * 0.58), 0.0, 1.0);
    """

    static func makeMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.isDoubleSided = true
        configurePixelatedMaterialProperty(material.diffuse)
        configurePixelatedMaterialProperty(material.emission)
        material.setValue(NSNumber(value: 0), forKey: "displayVuScalar")
        material.setValue(NSNumber(value: 0), forKey: "hotScalar")
        material.setValue(NSNumber(value: 0), forKey: "clipState")
        material.setValue(NSNumber(value: Float(OrbitalViewportCubeVUSettings.default.bloomMin)), forKey: "bloomMin")
        material.setValue(NSNumber(value: Float(OrbitalViewportCubeVUSettings.default.bloomMax)), forKey: "bloomMax")
        material.setValue(NSNumber(value: Float(OrbitalViewportCubeVUSettings.default.bloomEdge)), forKey: "bloomEdge")
        material.setValue(NSNumber(value: Float(OrbitalViewportCubeVUSettings.default.rimHaloEdge)), forKey: "rimHaloEdge")
        material.setValue(NSNumber(value: Float(OrbitalViewportCubeVUSettings.default.responseCurve)), forKey: "responseCurve")
        material.setValue(NSNumber(value: Float(OrbitalViewportCubeVUSettings.default.idleTint)), forKey: "idleTint")
        material.setValue(NSNumber(value: Float(OrbitalViewportCubeVUSettings.default.checkerContrast)), forKey: "checkerContrast")
        material.setValue(NSNumber(value: Float(OrbitalViewportCubeVUSettings.default.hotFillStrength)), forKey: "hotFillStrength")
        material.setValue(NSNumber(value: Float(OrbitalViewportCubeVUSettings.default.hotThreshold)), forKey: "hotThreshold")
        material.setValue(NSNumber(value: Float(defaultFacePixels)), forKey: "facePixels")
        material.setValue(NSNumber(value: 1), forKey: "alphaValue")
        return material
    }

    static func update(
        material: SCNMaterial?,
        settings: OrbitalViewportCubeVUSettings,
        scalars: SpeakerCubeVUScalars,
        clip: Bool,
        alpha: Double,
        vuColor: Color,
        hotColor: Color
    ) {
        guard let material else {
            return
        }
        let vuNSColor = resolvedColor(vuColor)
        let hotNSColor = resolvedColor(hotColor)
        let texture = faceTexture(
            settings: settings,
            scalars: scalars,
            clip: clip,
            vuColor: vuNSColor,
            hotColor: hotNSColor
        )
        material.diffuse.contents = texture
        material.emission.contents = texture
        material.emission.intensity = CGFloat(
            OrbitalViewportMath.clamp01(
                0.24 +
                Double(scalars.displayVuScalar) * 0.46 +
                Double(scalars.hotScalar) * 0.24 +
                (clip ? 0.36 : 0)
            )
        )
        material.transparency = alpha
        material.setValue(NSNumber(value: scalars.displayVuScalar), forKey: "displayVuScalar")
        material.setValue(NSNumber(value: scalars.hotScalar), forKey: "hotScalar")
        material.setValue(NSNumber(value: clip ? 1 : 0), forKey: "clipState")
        material.setValue(NSNumber(value: settings.bloomMin), forKey: "bloomMin")
        material.setValue(NSNumber(value: settings.bloomMax), forKey: "bloomMax")
        material.setValue(NSNumber(value: settings.bloomEdge), forKey: "bloomEdge")
        material.setValue(NSNumber(value: settings.rimHaloEdge), forKey: "rimHaloEdge")
        material.setValue(NSNumber(value: settings.responseCurve), forKey: "responseCurve")
        material.setValue(NSNumber(value: settings.idleTint), forKey: "idleTint")
        material.setValue(NSNumber(value: settings.checkerContrast), forKey: "checkerContrast")
        material.setValue(NSNumber(value: settings.hotFillStrength), forKey: "hotFillStrength")
        material.setValue(NSNumber(value: settings.hotThreshold), forKey: "hotThreshold")
        material.setValue(NSNumber(value: settings.facePixels), forKey: "facePixels")
        material.setValue(NSNumber(value: alpha), forKey: "alphaValue")
    }

    static func rampColor(heat: Double) -> Color {
        let ramp = SpeakerMeterColorScheme.daftPunkBow.theme.vuRamp.sorted { $0.position < $1.position }
        guard let first = ramp.first else {
            let clamped = OrbitalViewportMath.clamp01(heat)
            return Color(red: clamped, green: clamped, blue: clamped)
        }

        let position = OrbitalViewportMath.clamp01(heat)
        var lower = first
        var upper = first
        for stop in ramp {
            if stop.position <= position {
                lower = stop
            }
            if stop.position >= position {
                upper = stop
                break
            }
        }

        let span = max(upper.position - lower.position, 0.000_001)
        let t = (position - lower.position) / span
        return Color(
            red: lower.color.red + ((upper.color.red - lower.color.red) * t),
            green: lower.color.green + ((upper.color.green - lower.color.green) * t),
            blue: lower.color.blue + ((upper.color.blue - lower.color.blue) * t)
        )
    }

    static func faceTexture(
        settings: OrbitalViewportCubeVUSettings,
        scalars: SpeakerCubeVUScalars,
        clip: Bool,
        vuColor: NSColor,
        hotColor: NSColor
    ) -> NSImage {
        let key = FaceTextureKey(
            facePixels: max(4, min(64, settings.facePixels)),
            display: quantized(Double(scalars.displayVuScalar), scale: 96),
            hot: quantized(Double(scalars.hotScalar), scale: 96),
            clip: clip,
            pixelFill: quantized(settings.pixelFill, scale: 128),
            surfaceCheckerOpacity: quantized(settings.surfaceCheckerOpacity, scale: 128),
            bloomMin: quantized(settings.bloomMin, scale: 128),
            bloomMax: quantized(settings.bloomMax, scale: 128),
            bloomEdge: quantized(settings.bloomEdge, scale: 128),
            rimHaloEdge: quantized(settings.rimHaloEdge, scale: 128),
            responseCurve: quantized(settings.responseCurve / 4, scale: 128),
            idleTint: quantized(settings.idleTint, scale: 96),
            checkerContrast: quantized(settings.checkerContrast, scale: 128),
            hotFillStrength: quantized(settings.hotFillStrength, scale: 96),
            hotThreshold: quantized(settings.hotThreshold, scale: 96),
            vuColor: rgbaKey(vuColor),
            hotColor: rgbaKey(hotColor)
        )

        if let cached = faceTextureCache[key] {
            return cached
        }

        let image = makeFaceTextureImage(
            key: key,
            settings: settings,
            scalars: scalars,
            clip: clip,
            vuColor: vuColor,
            hotColor: hotColor
        )
        faceTextureCache[key] = image
        faceTextureOrder.append(key)
        while faceTextureOrder.count > faceTextureCacheLimit, let oldest = faceTextureOrder.first {
            faceTextureOrder.removeFirst()
            faceTextureCache.removeValue(forKey: oldest)
        }
        return image
    }

    static func cachedFaceTextureCountForTests() -> Int {
        faceTextureCache.count
    }

    static func resetFaceTextureCacheForTests() {
        faceTextureCache.removeAll()
        faceTextureOrder.removeAll()
    }

    private static func makeFaceTextureImage(
        key: FaceTextureKey,
        settings: OrbitalViewportCubeVUSettings,
        scalars: SpeakerCubeVUScalars,
        clip: Bool,
        vuColor: NSColor,
        hotColor: NSColor
    ) -> NSImage {
        let facePixels = key.facePixels
        let tilePixels = faceTexturePixelsPerFacePixel
        let imagePixels = facePixels * tilePixels
        let imageSize = NSSize(width: imagePixels, height: imagePixels)
        let image = NSImage(size: imageSize)
        let display = OrbitalViewportMath.clamp01(Double(scalars.displayVuScalar))
        let hot = OrbitalViewportMath.clamp01(Double(scalars.hotScalar))
        let curvedDisplay = pow(display, max(0.001, settings.responseCurve))
        let radius = settings.bloomMin + (settings.bloomMax - settings.bloomMin) * curvedDisplay
        let edge = max(0.001, settings.bloomEdge)
        let hotMix = OrbitalViewportMath.clamp01(
            settings.hotFillStrength * smoothstep(settings.hotThreshold, 1, hot)
        )
        let base = mix(
            resolvedColor(red: 0.018, green: 0.022, blue: 0.028),
            multiply(vuColor, by: 0.48),
            amount: settings.idleTint
        )
        let gap = mix(base, resolvedColor(red: 0.005, green: 0.007, blue: 0.011), amount: 0.78)
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .none
        NSGraphicsContext.current?.shouldAntialias = false
        let pixelFill = min(1, max(0.5, settings.pixelFill))
        let surfaceCheckerOpacity = OrbitalViewportMath.clamp01(settings.surfaceCheckerOpacity)
        (pixelFill < 0.999 ? gap : base).setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: imageSize)).fill()

        for y in 0..<facePixels {
            for x in 0..<facePixels {
                let u = (Double(x) + 0.5) / Double(facePixels)
                let v = (Double(y) + 0.5) / Double(facePixels)
                let centerDistance = hypot(u - 0.5, v - 0.5) * 1.414_213_562_37
                let fill = 1 - smoothstep(radius, radius + edge, centerDistance)
                let core = 1 - smoothstep(radius * 0.34, radius * 0.34 + edge * 0.9, centerDistance)
                let rimDistance = abs(centerDistance - radius)
                let rim = settings.rimHaloEdge *
                    display *
                    (1 - smoothstep(edge * 0.32, edge * 0.74, rimDistance))
                let active = fill *
                    smoothstep(0.015, 0.18, display) *
                    (0.36 + (1 - 0.36) * display)
                let bloomMix = OrbitalViewportMath.clamp01(active + core * display * 0.22)
                let hotBase = mix(base, hotColor, amount: hotMix)
                var tileColor = mix(hotBase, vuColor, amount: smoothstep(0.02, 0.92, bloomMix))
                tileColor = mix(tileColor, mix(vuColor, hotColor, amount: 0.18), amount: rim)
                if clip {
                    tileColor = mix(tileColor, resolvedColor(red: 1, green: 0.08, blue: 0.02), amount: 0.86)
                }
                let visibleCheckerContrast = max(settings.checkerContrast, idleCheckerContrastFloor) *
                    surfaceCheckerOpacity
                let checker = ((x + y) % 2 == 0)
                    ? max(0, 1 - visibleCheckerContrast)
                    : 1 + visibleCheckerContrast
                tileColor = multiply(tileColor, by: checker)
                tileColor.setFill()
                let fillInset = Int(((1 - pixelFill) * Double(tilePixels) / 2).rounded(.toNearestOrAwayFromZero))
                let tileInset = max(faceTextureTileGapPixels, fillInset)
                let rect = NSRect(
                    x: x * tilePixels + tileInset,
                    y: y * tilePixels + tileInset,
                    width: max(1, tilePixels - tileInset * 2),
                    height: max(1, tilePixels - tileInset * 2)
                )
                NSBezierPath(rect: rect).fill()
            }
        }
        image.unlockFocus()
        return image
    }

    private static func configurePixelatedMaterialProperty(_ property: SCNMaterialProperty) {
        property.magnificationFilter = .nearest
        property.minificationFilter = .nearest
        property.mipFilter = .none
        property.wrapS = .clamp
        property.wrapT = .clamp
    }

    private static func resolvedColor(_ color: Color) -> NSColor {
        resolvedColor(NSColor(color))
    }

    private static func resolvedColor(_ color: NSColor) -> NSColor {
        color.usingColorSpace(.deviceRGB) ?? color
    }

    private static func resolvedColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> NSColor {
        NSColor(deviceRed: red, green: green, blue: blue, alpha: 1)
    }

    private static func mix(_ first: NSColor, _ second: NSColor, amount: Double) -> NSColor {
        let first = resolvedColor(first)
        let second = resolvedColor(second)
        let t = CGFloat(OrbitalViewportMath.clamp01(amount))
        return NSColor(
            deviceRed: first.redComponent + (second.redComponent - first.redComponent) * t,
            green: first.greenComponent + (second.greenComponent - first.greenComponent) * t,
            blue: first.blueComponent + (second.blueComponent - first.blueComponent) * t,
            alpha: first.alphaComponent + (second.alphaComponent - first.alphaComponent) * t
        )
    }

    private static func multiply(_ color: NSColor, by factor: Double) -> NSColor {
        let color = resolvedColor(color)
        let factor = CGFloat(max(0, factor))
        return NSColor(
            deviceRed: min(1, color.redComponent * factor),
            green: min(1, color.greenComponent * factor),
            blue: min(1, color.blueComponent * factor),
            alpha: color.alphaComponent
        )
    }

    private static func smoothstep(_ edge0: Double, _ edge1: Double, _ value: Double) -> Double {
        guard edge0 != edge1 else {
            return value < edge0 ? 0 : 1
        }
        let t = OrbitalViewportMath.clamp01((value - edge0) / (edge1 - edge0))
        return t * t * (3 - 2 * t)
    }

    private static func quantized(_ value: Double, scale: Double) -> Int {
        Int((OrbitalViewportMath.clamp01(value) * scale).rounded())
    }

    private static func rgbaKey(_ color: NSColor) -> Int {
        let color = resolvedColor(color)
        let r = Int((color.redComponent * 255).rounded())
        let g = Int((color.greenComponent * 255).rounded())
        let b = Int((color.blueComponent * 255).rounded())
        let a = Int((color.alphaComponent * 255).rounded())
        return (r << 24) | (g << 16) | (b << 8) | a
    }
}

enum OrbitalViewportObjectShape: String, CaseIterable, Identifiable, Equatable, Sendable {
    case orb
    case halo
    case comet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .orb:
            return "Orb"
        case .halo:
            return "Halo"
        case .comet:
            return "Comet"
        }
    }
}

enum OrbitalViewportObjectPalette: String, CaseIterable, Identifiable, Equatable, Sendable {
    case objectPurple
    case sourceGold
    case spectralBlue
    case monochrome

    var id: String { rawValue }

    var title: String {
        switch self {
        case .objectPurple:
            return "Object Purple"
        case .sourceGold:
            return "Source Gold"
        case .spectralBlue:
            return "Spectral Blue"
        case .monochrome:
            return "Monochrome"
        }
    }
}

struct OrbitalViewportObjectTuning: Equatable, Sendable {
    static let `default` = OrbitalViewportObjectTuning()

    var shape: OrbitalViewportObjectShape = .orb
    var palette: OrbitalViewportObjectPalette = .objectPurple
    var coreSize = 0.055
    var widthScale = 1.0
    var smoothingHalfLifeSeconds = 0.08
    var visualLookbehindMilliseconds = 30.0
    var snapThresholdRadians = 0.95
    var glowIntensity = 0.65
    var clipFlashIntensity = 1.0
    var trailsEnabled = false
    var trailLengthSeconds = 1.2
    var trailDecay = 0.72
    var maxTrailPointsPerObject = 24
    var glowTrailsEnabled = false
    var glowTrailIntensity = 0.5
    var glowTrailWidth = 0.09
    var glowTrailDecay = 0.65
    var showsBounds = false
    var showsClipDiagnostics = true
}

enum OrbitalViewportFrameRate: Int, CaseIterable, Identifiable, Equatable {
    case thirty = 30
    case sixty = 60

    var id: Int { rawValue }

    var framesPerSecond: Int { rawValue }

    var title: String {
        "\(rawValue) FPS"
    }

    static func normalized(_ framesPerSecond: Int) -> Int {
        allCases.first(where: { $0.framesPerSecond == framesPerSecond })?.framesPerSecond ?? sixty.framesPerSecond
    }
}

public struct OrbitalViewportSpeaker: Identifiable, Equatable, Sendable {
    public let channel: Int
    public let label: String
    public let x: Double
    public let y: Double
    public let z: Double

    public var id: Int { channel }

    public static let referenceSpeakers: [OrbitalViewportSpeaker] = [
        OrbitalViewportSpeaker(channel: 1, label: "Fey 01", x: 0, y: 0.554700196225229, z: -0.832050294337844),
        OrbitalViewportSpeaker(channel: 2, label: "Fey 02", x: 0.545454545454545, y: 0.181818181818182, z: -0.818181818181818),
        OrbitalViewportSpeaker(channel: 3, label: "Fey 03", x: 0.331448998468967, y: -0.45113891458276, z: -0.828622496172417),
        OrbitalViewportSpeaker(channel: 4, label: "Fey 04", x: -0.331448998468967, y: -0.45113891458276, z: -0.828622496172417),
        OrbitalViewportSpeaker(channel: 5, label: "Fey 05", x: -0.545454545454545, y: 0.181818181818182, z: -0.818181818181818),
        OrbitalViewportSpeaker(channel: 6, label: "Fey 06", x: -0.548614782048403, y: 0.630906999355663, z: -0.548614782048403),
        OrbitalViewportSpeaker(channel: 7, label: "Fey 07", x: 0.548614782048403, y: 0.630906999355663, z: -0.548614782048403),
        OrbitalViewportSpeaker(channel: 8, label: "Fey 08", x: 0.774258005430618, y: -0.251633851764951, z: -0.580693504072963),
        OrbitalViewportSpeaker(channel: 9, label: "Fey 09", x: 0, y: -0.8, z: -0.6),
        OrbitalViewportSpeaker(channel: 10, label: "Fey 10", x: -0.774258005430618, y: -0.251633851764951, z: -0.580693504072963),
        OrbitalViewportSpeaker(channel: 11, label: "Fey 11", x: -0.923947703083417, y: 0.304902742017528, z: -0.230986925770854),
        OrbitalViewportSpeaker(channel: 12, label: "Fey 12", x: 0, y: 0.970142500145332, z: -0.242535625036333),
        OrbitalViewportSpeaker(channel: 13, label: "Fey 13", x: 0.923947703083417, y: 0.304902742017528, z: -0.230986925770854),
        OrbitalViewportSpeaker(channel: 14, label: "Fey 14", x: 0.577947069890345, y: -0.791708314918281, z: -0.19792707872957),
        OrbitalViewportSpeaker(channel: 15, label: "Fey 15", x: -0.577947069890345, y: -0.791708314918281, z: -0.19792707872957),
        OrbitalViewportSpeaker(channel: 16, label: "Fey 16", x: -0.923947703083417, y: -0.304902742017528, z: 0.230986925770854),
        OrbitalViewportSpeaker(channel: 17, label: "Fey 17", x: -0.572638174674189, y: 0.795330798158596, z: 0.198832699539649),
        OrbitalViewportSpeaker(channel: 18, label: "Fey 18", x: 0.572638174674189, y: 0.795330798158596, z: 0.198832699539649),
        OrbitalViewportSpeaker(channel: 19, label: "Fey 19", x: 0.923947703083417, y: -0.304902742017528, z: 0.230986925770854),
        OrbitalViewportSpeaker(channel: 20, label: "Fey 20", x: 0, y: -0.970142500145332, z: 0.242535625036333),
        OrbitalViewportSpeaker(channel: 21, label: "Fey 21", x: -0.548614782048403, y: -0.630906999355663, z: 0.548614782048403),
        OrbitalViewportSpeaker(channel: 22, label: "Fey 22", x: 0.548614782048403, y: -0.630906999355663, z: 0.548614782048403),
        OrbitalViewportSpeaker(channel: 23, label: "Fey 23", x: 0.545454545454545, y: -0.181818181818182, z: 0.818181818181818),
        OrbitalViewportSpeaker(channel: 24, label: "Fey 24", x: 0, y: 0.8, z: 0.6),
        OrbitalViewportSpeaker(channel: 25, label: "Fey 25", x: -0.545454545454545, y: -0.181818181818182, z: 0.818181818181818),
        OrbitalViewportSpeaker(channel: 26, label: "Fey 26", x: -0.331448998468967, y: 0.45113891458276, z: 0.828622496172417),
        OrbitalViewportSpeaker(channel: 27, label: "Fey 27", x: 0.331448998468967, y: 0.45113891458276, z: 0.828622496172417),
        OrbitalViewportSpeaker(channel: 28, label: "Fey 28", x: 0, y: -0.554700196225229, z: 0.832050294337844),
        OrbitalViewportSpeaker(channel: 29, label: "Fey 29", x: -0.774258005430618, y: 0.251633851764951, z: 0.580693504072963),
        OrbitalViewportSpeaker(channel: 30, label: "Fey 30", x: 0.774258005430618, y: 0.251633851764951, z: 0.580693504072963)
    ]
}

struct OrbitalViewportOrbitState: Equatable {
    static let spinRadiansPerMS = 0.000075
    static let defaultDistance = 4.15
    static let maxPitch = 1.25

    var view: OrbitalViewportCameraView = .isometric
    var yaw: Double
    var pitch: Double
    var distance: Double = Self.defaultDistance

    static func preset(_ view: OrbitalViewportCameraView) -> OrbitalViewportOrbitState {
        let pose = view.preset
        return OrbitalViewportOrbitState(view: view, yaw: pose.yaw, pitch: pose.pitch)
    }

    func applyingDrag(translation: CGSize) -> OrbitalViewportOrbitState {
        OrbitalViewportOrbitState(
            view: view,
            yaw: yaw - Double(translation.width) * 0.006,
            pitch: min(Self.maxPitch, max(-Self.maxPitch, pitch - Double(translation.height) * 0.006)),
            distance: distance
        )
    }

    func spinning(deltaMS: Double) -> OrbitalViewportOrbitState {
        OrbitalViewportOrbitState(
            view: view,
            yaw: yaw - deltaMS * Self.spinRadiansPerMS,
            pitch: pitch,
            distance: distance
        )
    }

    var cameraBasis: OrbitalViewportCameraBasis {
        let baseDirection = view.baseViewDirection.normalized(fallback: OVVector3(x: 0, y: 0, z: 1))
        let baseUp = view.baseUp.normalized(fallback: OVVector3(x: 0, y: 1, z: 0))
        let yawedDirection = baseDirection.rotated(around: baseUp, angle: yaw)
            .normalized(fallback: baseDirection)
        let yawedRight = OVVector3.cross(baseUp, yawedDirection)
            .normalized(fallback: OVVector3(x: 1, y: 0, z: 0))
        let pitchedDirection = yawedDirection.rotated(around: yawedRight, angle: pitch)
            .normalized(fallback: yawedDirection)
        let pitchedUp = baseUp.rotated(around: yawedRight, angle: pitch)
            .normalized(fallback: baseUp)
        let right = OVVector3.cross(pitchedUp, pitchedDirection)
            .normalized(fallback: yawedRight)
        return OrbitalViewportCameraBasis(
            viewDirection: pitchedDirection,
            right: right,
            up: pitchedUp,
            distance: distance
        )
    }

    var cameraPosition: OVVector3 {
        cameraBasis.position
    }
}

struct OrbitalViewportCameraBasis: Equatable {
    let viewDirection: OVVector3
    let right: OVVector3
    let up: OVVector3
    let distance: Double

    var position: OVVector3 {
        viewDirection * distance
    }

    func transform(_ vector: OVVector3) -> OVVector3 {
        OVVector3(
            x: vector.dot(right),
            y: vector.dot(up),
            z: vector.dot(viewDirection)
        )
    }
}

struct OrbitalViewportRenderConfiguration: Equatable {
    let size: CGSize
    let timeMS: Double
    let yaw: Double
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let zoom: Double
    let renderStyle: OrbitalViewportRenderStyle
    let geodesicSaturation: Double
    let speakerShape: OrbitalViewportSpeakerShape
    let speakerSize: Double
    let fogDensity: Double
    let meterSource: OrbitalViewportMeterSource
    let cubeVUSettings: OrbitalViewportCubeVUSettings
    let activeViewportFramesPerSecond: Int
    let showSpeakerNumbers: Bool
    let showHiddenLines: Bool
    let selectedChannel: Int?
    let spin: Bool
    let spinStartYaw: Double
    let spinStartTimeMS: Double

    init(
        size: CGSize,
        timeMS: Double,
        yaw: Double,
        pitch: Double,
        cameraView: OrbitalViewportCameraView,
        zoom: Double,
        renderStyle: OrbitalViewportRenderStyle,
        geodesicSaturation: Double = 1,
        speakerShape: OrbitalViewportSpeakerShape,
        speakerSize: Double,
        fogDensity: Double,
        meterSource: OrbitalViewportMeterSource = .fake,
        cubeVUSettings: OrbitalViewportCubeVUSettings = .default,
        activeViewportFramesPerSecond: Int = OrbitalViewportMockup.viewportAnimationFramesPerSecond,
        showSpeakerNumbers: Bool,
        showHiddenLines: Bool,
        selectedChannel: Int?,
        spin: Bool = false,
        spinStartYaw: Double = 0,
        spinStartTimeMS: Double = 0
    ) {
        self.size = size
        self.timeMS = timeMS
        self.yaw = yaw
        self.pitch = pitch
        self.cameraView = cameraView
        self.zoom = zoom
        self.renderStyle = renderStyle
        self.geodesicSaturation = OrbitalViewportMath.clamp01(geodesicSaturation)
        self.speakerShape = speakerShape
        self.speakerSize = speakerSize
        self.fogDensity = fogDensity
        self.meterSource = meterSource
        self.cubeVUSettings = cubeVUSettings
        self.activeViewportFramesPerSecond = OrbitalViewportFrameRate.normalized(activeViewportFramesPerSecond)
        self.showSpeakerNumbers = showSpeakerNumbers
        self.showHiddenLines = showHiddenLines
        self.selectedChannel = selectedChannel
        self.spin = spin
        self.spinStartYaw = spinStartYaw
        self.spinStartTimeMS = spinStartTimeMS
    }

    var theme: OrbitalViewportTheme {
        OrbitalViewportTheme(style: renderStyle)
    }

    func geodesicColor(_ color: Color) -> Color {
        OrbitalViewportColorTools.withSaturation(color, geodesicSaturation)
    }

    var frontClipPlane: Double {
        -0.04
    }

    var sphereRadius: Double {
        min(size.width, size.height) * 0.34 * zoom
    }

    var orbitState: OrbitalViewportOrbitState {
        OrbitalViewportOrbitState(view: cameraView, yaw: yaw, pitch: pitch)
    }

    var fogConfiguration: OrbitalViewportFogConfiguration {
        OrbitalViewportFogConfiguration.make(density: fogDensity, cameraDistance: orbitState.distance)
    }

    func rotate(_ vector: OVVector3) -> OVVector3 {
        orbitState.cameraBasis.transform(vector)
    }

    func project(_ vector: OVVector3) -> CGPoint {
        CGPoint(
            x: size.width * 0.5 + vector.x * sphereRadius,
            y: size.height * 0.5 - vector.y * sphereRadius
        )
    }

    func hiddenDepthFade(_ depth: Double) -> Double {
        depth >= frontClipPlane ? 1 : 0.34
    }

    var hiddenLinesVisible: Bool {
        showHiddenLines
    }

    func isVisibleDepth(_ depth: Double) -> Bool {
        depth >= frontClipPlane || (hiddenLinesVisible && hiddenDepthFade(depth) > 0.02)
    }

    func foggedAlpha(depth: Double, baseAlpha: Double) -> Double {
        baseAlpha
    }

    func rearDepthAmount(_ depth: Double) -> Double {
        guard depth < frontClipPlane else {
            return 0
        }
        return OrbitalViewportMath.clamp01((frontClipPlane - depth) / 1.15)
    }

    func speakerAlpha(depth: Double, selected: Bool) -> Double {
        guard !selected else {
            return 1
        }
        guard depth < frontClipPlane else {
            return 0.94
        }

        let rear = rearDepthAmount(depth)
        let fogStrength = fogConfiguration.normalizedDensity
        let attenuation = max(0.2, 1 - rear * (0.38 + fogStrength * 0.42))
        return max(0.14, 0.42 * attenuation)
    }

    func speakerEmissionScale(depth: Double) -> Double {
        guard depth < frontClipPlane else {
            return 1
        }

        let rear = rearDepthAmount(depth)
        let fogStrength = fogConfiguration.normalizedDensity
        return max(0.12, 1 - rear * (0.58 + fogStrength * 0.34))
    }

    func shellEdgeVisible(startDepth: Double, endDepth: Double) -> Bool {
        if hiddenLinesVisible || startDepth >= frontClipPlane || endDepth >= frontClipPlane {
            return true
        }
        return fogConfiguration.isEnabled && shellDepthAlpha(startDepth: startDepth, endDepth: endDepth) > 0.04
    }

    func shellDepthAlpha(startDepth: Double, endDepth: Double) -> Double {
        let averageDepth = (startDepth + endDepth) * 0.5
        guard averageDepth < frontClipPlane else {
            return 1
        }

        let rear = rearDepthAmount(averageDepth)
        if hiddenLinesVisible {
            return max(0.18, 0.42 - rear * 0.12)
        }
        guard fogConfiguration.isEnabled else {
            return 0
        }
        return max(0.13, 0.32 - rear * (0.1 + fogConfiguration.normalizedDensity * 0.08))
    }

    func shellNodeAlpha(depth: Double) -> Double {
        guard depth < frontClipPlane else {
            return 0.42
        }
        return fogConfiguration.isEnabled || hiddenLinesVisible ? 0.16 : 0
    }

    func frameConfiguration(timeMS frameTimeMS: Double) -> OrbitalViewportRenderConfiguration {
        let frameYaw: Double
        if spin {
            frameYaw = spinStartYaw - ((frameTimeMS - spinStartTimeMS) * OrbitalViewportOrbitState.spinRadiansPerMS)
        } else {
            frameYaw = yaw
        }

        return OrbitalViewportRenderConfiguration(
            size: size,
            timeMS: frameTimeMS,
            yaw: frameYaw,
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
}

struct OrbitalViewportCameraUpdateKey: Equatable {
    let yaw: Double
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let zoom: Double

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.yaw = configuration.yaw
        self.pitch = configuration.pitch
        self.cameraView = configuration.cameraView
        self.zoom = configuration.zoom
    }
}

struct OrbitalViewportShellUpdateKey: Equatable {
    let yaw: Double
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let renderStyle: OrbitalViewportRenderStyle
    let geodesicSaturation: Double
    let showHiddenLines: Bool

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.yaw = configuration.yaw
        self.pitch = configuration.pitch
        self.cameraView = configuration.cameraView
        self.renderStyle = configuration.renderStyle
        self.geodesicSaturation = configuration.geodesicSaturation
        self.showHiddenLines = configuration.showHiddenLines
    }
}

struct OrbitalViewportSpeakerGeometryUpdateKey: Equatable {
    let speakerShape: OrbitalViewportSpeakerShape
    let speakerSize: Double
    let speakerHeight: Double

    init(
        speakerShape: OrbitalViewportSpeakerShape,
        speakerSize: Double,
        speakerHeight: Double
    ) {
        self.speakerShape = speakerShape
        self.speakerSize = speakerSize
        self.speakerHeight = speakerHeight
    }

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.init(
            speakerShape: configuration.speakerShape,
            speakerSize: configuration.speakerSize,
            speakerHeight: configuration.cubeVUSettings.speakerHeight
        )
    }
}

struct OrbitalViewportSpeakerVisibilityUpdateKey: Equatable {
    let yaw: Double
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let showHiddenLines: Bool
    let showSpeakerNumbers: Bool
    let selectedChannel: Int?

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.yaw = configuration.yaw
        self.pitch = configuration.pitch
        self.cameraView = configuration.cameraView
        self.showHiddenLines = configuration.showHiddenLines
        self.showSpeakerNumbers = configuration.showSpeakerNumbers
        self.selectedChannel = configuration.selectedChannel
    }
}

struct OrbitalViewportSpeakerMaterialUpdateKey: Equatable {
    let meterFrame: Int
    let activeFramesPerSecond: Int
    let renderStyle: OrbitalViewportRenderStyle
    let meterSourceMode: OrbitalViewportMeterSource.Mode
    let cubeVUSettings: OrbitalViewportCubeVUSettings
    let selectedChannel: Int?

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.activeFramesPerSecond = configuration.activeViewportFramesPerSecond
        self.meterFrame = Int(configuration.timeMS / (1000 / Double(configuration.activeViewportFramesPerSecond)))
        self.renderStyle = configuration.renderStyle
        self.meterSourceMode = configuration.meterSource.mode
        self.cubeVUSettings = configuration.cubeVUSettings
        self.selectedChannel = configuration.selectedChannel
    }
}

struct OrbitalViewportFogUpdateKey: Equatable {
    let fogDensity: Double
    let zoom: Double
    let cameraView: OrbitalViewportCameraView

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.fogDensity = configuration.fogDensity
        self.zoom = configuration.zoom
        self.cameraView = configuration.cameraView
    }
}

struct OrbitalViewportFogConfiguration: Equatable {
    static let disabledStartDistance = 1_000_000.0
    static let disabledEndDistance = 1_000_001.0

    let isEnabled: Bool
    let normalizedDensity: Double
    let startDistance: Double
    let endDistance: Double
    let densityExponent: Double

    static let disabled = OrbitalViewportFogConfiguration(
        isEnabled: false,
        normalizedDensity: 0,
        startDistance: disabledStartDistance,
        endDistance: disabledEndDistance,
        densityExponent: 1
    )

    static func make(density: Double, cameraDistance: Double) -> OrbitalViewportFogConfiguration {
        let normalized = OrbitalViewportMath.clamp01(density / 100)
        guard normalized > 0 else {
            return .disabled
        }

        let startDistance = max(0.1, cameraDistance - 0.35)
        let endDistance = cameraDistance + max(0.55, 2.25 - (normalized * 1.55))
        return OrbitalViewportFogConfiguration(
            isEnabled: true,
            normalizedDensity: normalized,
            startDistance: startDistance,
            endDistance: max(startDistance + 0.1, endDistance),
            densityExponent: 0.75 + normalized * 1.55
        )
    }
}

struct OrbitalViewportSnapshot: Equatable {
    let speakers: [OrbitalViewportProjectedSpeaker]
    let activeCount: Int
    let peakSpeaker: OrbitalViewportProjectedSpeaker

    init(configuration: OrbitalViewportRenderConfiguration) {
        let speakers = OrbitalViewportSpeaker.referenceSpeakers.map { speaker in
            OrbitalViewportProjectedSpeaker(source: speaker, configuration: configuration)
        }
        self.speakers = speakers
        self.activeCount = speakers.filter { $0.peak > 0.12 }.count
        self.peakSpeaker = speakers.max(by: { $0.peak < $1.peak }) ?? speakers[0]
    }
}

struct OrbitalViewportProjectedSpeaker: Identifiable, Equatable {
    let source: OrbitalViewportSpeaker
    let rms: Double
    let peak: Double
    let rotated: OVVector3
    let screen: CGPoint
    let scale: Double
    let visible: Bool

    var id: Int { channel }
    var channel: Int { source.channel }
    var label: String { source.label }
    var depth: Double { rotated.z }

    init(source: OrbitalViewportSpeaker, configuration: OrbitalViewportRenderConfiguration) {
        self.source = source
        let meter = configuration.meterSource.meter(channel: source.channel, timeMS: configuration.timeMS)
        self.rms = meter.rms
        self.peak = meter.peak
        let rotated = configuration.rotate(OVVector3(source))
        self.rotated = rotated
        self.screen = configuration.project(rotated)
        self.scale = configuration.speakerSize
        self.visible = configuration.isVisibleDepth(rotated.z)
    }
}

#if os(macOS)
struct OrbitalViewport3DSceneView: NSViewRepresentable {
    static let sceneFramesPerSecond = OrbitalViewportMockup.viewportAnimationFramesPerSecond
    static let rendersContinuously = false

    let activeFramesPerSecond: Int
    let configuration: OrbitalViewportRenderConfiguration
    let snapshot: OrbitalViewportSnapshot
    let onDragStarted: () -> Void
    let onDrag: (CGSize) -> Void
    let onDragEnded: () -> Void
    let onZoom: (Double) -> Void
    let onSelect: (Int?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> OrbitalViewportSceneNSView {
        let view = OrbitalViewportSceneNSView(frame: .zero)
        view.allowsCameraControl = false
        view.antialiasingMode = .multisampling4X
        view.backgroundColor = .clear
        view.rendersContinuously = Self.rendersContinuously
        view.isPlaying = false
        view.preferredFramesPerSecond = activeFramesPerSecond
        view.scene = context.coordinator.scene
        view.pointOfView = context.coordinator.cameraNode
        view.onDragStarted = onDragStarted
        view.onDrag = onDrag
        view.onDragEnded = onDragEnded
        view.onZoom = onZoom
        view.onSelect = onSelect
        context.coordinator.setActiveFramesPerSecond(activeFramesPerSecond)
        context.coordinator.attach(to: view)
        context.coordinator.update(
            configuration: configuration,
            snapshot: snapshot
        )
        return view
    }

    func updateNSView(_ nsView: OrbitalViewportSceneNSView, context: Context) {
        nsView.onDragStarted = onDragStarted
        nsView.onDrag = onDrag
        nsView.onDragEnded = onDragEnded
        nsView.onZoom = onZoom
        nsView.onSelect = onSelect
        if nsView.preferredFramesPerSecond != activeFramesPerSecond {
            nsView.preferredFramesPerSecond = activeFramesPerSecond
        }
        context.coordinator.setActiveFramesPerSecond(activeFramesPerSecond)
        context.coordinator.attach(to: nsView)
        context.coordinator.update(
            configuration: configuration,
            snapshot: snapshot
        )
    }

    final class Coordinator {
        let scene = SCNScene()
        let rootNode = SCNNode()
        let shellNode = SCNNode()
        let speakerRoot = SCNNode()
        let labelRoot = SCNNode()
        let cameraNode = SCNNode()

        private weak var view: OrbitalViewportSceneNSView?
        private var edgeNodes: [SCNNode] = []
        private var nodeMarkers: [SCNNode] = []
        private var speakerNodes: [Int: SCNNode] = [:]
        private var speakerOutlineNodes: [Int: [SCNNode]] = [:]
        private var labelNodes: [Int: SCNNode] = [:]
        private var animationTimer: Timer?
        private var latestConfiguration: OrbitalViewportRenderConfiguration?
        private var lastCameraKey: OrbitalViewportCameraUpdateKey?
        private var lastShellKey: OrbitalViewportShellUpdateKey?
        private var lastSpeakerGeometryKey: OrbitalViewportSpeakerGeometryUpdateKey?
        private var lastSpeakerVisibilityKey: OrbitalViewportSpeakerVisibilityUpdateKey?
        private var lastSpeakerMaterialKey: OrbitalViewportSpeakerMaterialUpdateKey?
        private var lastFogKey: OrbitalViewportFogUpdateKey?
        private var lastRenderedAnimationTimeMS: Double?
        private var activeFramesPerSecond = OrbitalViewport3DSceneView.sceneFramesPerSecond

        private(set) var shellBuildCount = 0
        private(set) var speakerRebuildCount = 0

        init() {
            scene.rootNode.addChildNode(rootNode)
            rootNode.addChildNode(shellNode)
            rootNode.addChildNode(speakerRoot)
            rootNode.addChildNode(labelRoot)
            configureCamera()
            configureLights()
            buildShell()
            rebuildSpeakers(
                shape: .prism,
                speakerSize: OrbitalViewportMath.speakerSize(fromSlider: 50),
                speakerHeight: OrbitalViewportCubeVUSettings.default.speakerHeight
            )
        }

        deinit {
            animationTimer?.invalidate()
        }

        func attach(to view: OrbitalViewportSceneNSView) {
            self.view = view
            startAnimationTimerIfNeeded()
        }

        func setActiveFramesPerSecond(_ framesPerSecond: Int) {
            let normalizedFramesPerSecond = OrbitalViewportFrameRate.normalized(framesPerSecond)
            guard activeFramesPerSecond != normalizedFramesPerSecond else {
                return
            }

            activeFramesPerSecond = normalizedFramesPerSecond
            lastRenderedAnimationTimeMS = nil
            restartAnimationTimer()
        }

        func update(
            configuration: OrbitalViewportRenderConfiguration,
            snapshot: OrbitalViewportSnapshot
        ) {
            _ = snapshot
            latestConfiguration = configuration

            let geometryKey = OrbitalViewportSpeakerGeometryUpdateKey(configuration: configuration)
            if lastSpeakerGeometryKey != geometryKey {
                rebuildSpeakers(
                    shape: configuration.speakerShape,
                    speakerSize: configuration.speakerSize,
                    speakerHeight: configuration.cubeVUSettings.speakerHeight
                )
            }

            renderScene(configuration: configuration)
        }

        private func startAnimationTimerIfNeeded() {
            guard animationTimer == nil else {
                return
            }

            let interval = 1 / Double(activeFramesPerSecond)
            let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
                self?.renderAnimationFrame()
            }
            RunLoop.main.add(timer, forMode: .common)
            animationTimer = timer
        }

        private func restartAnimationTimer() {
            animationTimer?.invalidate()
            animationTimer = nil
            if view != nil {
                startAnimationTimerIfNeeded()
            }
        }

        private func renderAnimationFrame() {
            guard let latestConfiguration else {
                return
            }
            let frameTimeMS = currentTimeMS()
            let framesPerSecond = latestConfiguration.spin
                ? activeFramesPerSecond
                : OrbitalViewportMockup.meterOnlyViewportFramesPerSecond
            let minimumFrameIntervalMS = 1000 / Double(framesPerSecond)
            if let lastRenderedAnimationTimeMS,
               frameTimeMS - lastRenderedAnimationTimeMS < minimumFrameIntervalMS {
                return
            }

            lastRenderedAnimationTimeMS = frameTimeMS
            renderScene(configuration: latestConfiguration.frameConfiguration(timeMS: frameTimeMS))
        }

        private func renderScene(configuration: OrbitalViewportRenderConfiguration) {
            let snapshot = OrbitalViewportSnapshot(configuration: configuration)
            let cameraKey = OrbitalViewportCameraUpdateKey(configuration: configuration)
            let shellKey = OrbitalViewportShellUpdateKey(configuration: configuration)
            let visibilityKey = OrbitalViewportSpeakerVisibilityUpdateKey(configuration: configuration)
            let materialKey = OrbitalViewportSpeakerMaterialUpdateKey(configuration: configuration)
            let fogKey = OrbitalViewportFogUpdateKey(configuration: configuration)

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0
            SCNTransaction.disableActions = true
            defer {
                SCNTransaction.commit()
            }

            if lastCameraKey != cameraKey {
                updateCamera(configuration: configuration)
                lastCameraKey = cameraKey
            }
            if lastShellKey != shellKey {
                updateShell(configuration: configuration)
                lastShellKey = shellKey
            }

            let shouldUpdateSpeakerVisibility = lastSpeakerVisibilityKey != visibilityKey
            let shouldUpdateSpeakerMaterial = lastSpeakerMaterialKey != materialKey
            if shouldUpdateSpeakerVisibility || shouldUpdateSpeakerMaterial {
                updateSpeakers(
                    configuration: configuration,
                    snapshot: snapshot,
                    updateVisibility: shouldUpdateSpeakerVisibility,
                    updateMaterial: shouldUpdateSpeakerMaterial
                )
                lastSpeakerVisibilityKey = visibilityKey
                lastSpeakerMaterialKey = materialKey
            }

            if lastFogKey != fogKey {
                updateFog(configuration: configuration)
                lastFogKey = fogKey
            }

            view?.needsDisplay = true
        }

        private func currentTimeMS() -> Double {
            Date.timeIntervalSinceReferenceDate * 1000
        }

        private func configureCamera() {
            let camera = SCNCamera()
            camera.usesOrthographicProjection = true
            camera.orthographicScale = 2.25
            camera.zNear = 0.01
            camera.zFar = 20
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(0, 0, 4)
            cameraNode.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(cameraNode)
        }

        private func configureLights() {
            let ambient = SCNNode()
            ambient.light = SCNLight()
            ambient.light?.type = .ambient
            ambient.light?.intensity = 360
            scene.rootNode.addChildNode(ambient)

            let key = SCNNode()
            key.light = SCNLight()
            key.light?.type = .directional
            key.light?.intensity = 720
            key.eulerAngles = SCNVector3(-0.65, 0.55, 0.15)
            scene.rootNode.addChildNode(key)

            let fill = SCNNode()
            fill.light = SCNLight()
            fill.light?.type = .omni
            fill.light?.intensity = 240
            fill.position = SCNVector3(-1.5, 1.2, 2.8)
            scene.rootNode.addChildNode(fill)
        }

        private func updateCamera(configuration: OrbitalViewportRenderConfiguration) {
            let basis = configuration.orbitState.cameraBasis
            cameraNode.camera?.orthographicScale = 2.25 / configuration.zoom
            cameraNode.position = basis.position.scn
            cameraNode.look(
                at: SCNVector3Zero,
                up: basis.up.scn,
                localFront: SCNVector3(0, 0, -1)
            )
        }

        private func buildShell() {
            shellBuildCount += 1
            shellNode.childNodes.forEach { $0.removeFromParentNode() }
            edgeNodes.removeAll()
            nodeMarkers.removeAll()

            for edge in OrbitalViewportGeodesic.structure.edges {
                let start = OrbitalViewportGeodesic.structure.nodes[edge.a]
                let end = OrbitalViewportGeodesic.structure.nodes[edge.b]
                let node = cylinderNode(
                    from: start,
                    to: end,
                    radius: edge.lengthGroup == 2
                        ? OrbitalViewportSceneMetrics.shellEquatorStrutRadius
                        : OrbitalViewportSceneMetrics.shellStrutRadius
                )
                node.name = "shell-edge-\(edge.a)-\(edge.b)"
                shellNode.addChildNode(node)
                edgeNodes.append(node)
            }

            for point in OrbitalViewportGeodesic.structure.nodes {
                let marker = SCNNode(geometry: SCNSphere(radius: OrbitalViewportSceneMetrics.shellNodeRadius))
                marker.position = point.scn
                marker.name = "shell-node"
                shellNode.addChildNode(marker)
                nodeMarkers.append(marker)
            }
        }

        private func rebuildSpeakers(
            shape: OrbitalViewportSpeakerShape,
            speakerSize: Double,
            speakerHeight: Double
        ) {
            speakerRebuildCount += 1
            speakerRoot.childNodes.forEach { $0.removeFromParentNode() }
            labelRoot.childNodes.forEach { $0.removeFromParentNode() }
            speakerNodes.removeAll()
            speakerOutlineNodes.removeAll()
            labelNodes.removeAll()
            lastSpeakerGeometryKey = OrbitalViewportSpeakerGeometryUpdateKey(
                speakerShape: shape,
                speakerSize: speakerSize,
                speakerHeight: speakerHeight
            )
            lastSpeakerVisibilityKey = nil
            lastSpeakerMaterialKey = nil

            for speaker in OrbitalViewportSpeaker.referenceSpeakers {
                let node = makeSpeakerNode(
                    speaker: speaker,
                    shape: shape,
                    speakerSize: speakerSize,
                    speakerHeight: speakerHeight
                )
                node.name = "speaker-\(speaker.channel)"
                speakerRoot.addChildNode(node)
                speakerNodes[speaker.channel] = node
                speakerOutlineNodes[speaker.channel] = node.childNodes.filter {
                    $0.name?.hasPrefix("speaker-outline-\(speaker.channel)-") == true
                }

                let label = makeLabelNode(channel: speaker.channel)
                label.name = "speaker-label-\(speaker.channel)"
                label.position = (OVVector3(speaker) * 1.18).scn
                labelRoot.addChildNode(label)
                labelNodes[speaker.channel] = label
            }
        }

        private func makeSpeakerNode(
            speaker: OrbitalViewportSpeaker,
            shape: OrbitalViewportSpeakerShape,
            speakerSize: Double,
            speakerHeight: Double
        ) -> SCNNode {
            let node: SCNNode
            switch shape {
            case .sphere:
                node = SCNNode(geometry: SCNSphere(radius: 0.035 * speakerSize))
                node.position = (OVVector3(speaker) * 1.02).scn
            case .prism, .cubeVU:
                let short = 0.032 * speakerSize * (
                    shape == .cubeVU ? OrbitalViewportCubeVUSceneKitMaterial.cubeVUReadableFaceScale : 1
                )
                let width = shape == .cubeVU ? short : short * 2
                let depth = short * min(2, max(1, speakerHeight))
                let geometry = SCNBox(
                    width: width,
                    height: short,
                    length: depth,
                    chamferRadius: shape == .cubeVU ? 0 : short * 0.05
                )
                node = SCNNode(geometry: geometry)
                if shape == .cubeVU {
                    makeCubeOutlineNodes(
                        channel: speaker.channel,
                        width: width,
                        height: short,
                        depth: depth
                    ).forEach { node.addChildNode($0) }
                }
                let basis = prismBasis(for: speaker)
                let position = OVVector3(speaker) + (basis.radialAxis * (depth * 0.5))
                node.simdTransform = matrix(
                    longAxis: basis.longAxis,
                    sideAxis: basis.sideAxis,
                    radialAxis: basis.radialAxis,
                    position: position
                )
            }

            let material = shape == .cubeVU
                ? OrbitalViewportCubeVUSceneKitMaterial.makeMaterial()
                : SCNMaterial()
            if shape != .cubeVU {
                material.lightingModel = .physicallyBased
            }
            node.geometry?.materials = shape == .cubeVU
                ? Array(repeating: material, count: 6)
                : [material]
            if shape != .cubeVU {
                node.geometry?.firstMaterial?.metalness.contents = 0.12
                node.geometry?.firstMaterial?.roughness.contents = 0.38
            }
            return node
        }

        private func makeCubeOutlineNodes(
            channel: Int,
            width: Double,
            height: Double,
            depth: Double
        ) -> [SCNNode] {
            let line = max(0.001, min(width, height, depth) * OrbitalViewportCubeVUSceneKitMaterial.cubeOutlineEdgeThicknessRatio)
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.diffuse.contents = NSColor.clear
            material.emission.contents = NSColor.clear
            material.transparency = 0
            material.isDoubleSided = true

            func edgeNode(
                index: Int,
                size: (width: Double, height: Double, depth: Double),
                position: SCNVector3
            ) -> SCNNode {
                let geometry = SCNBox(
                    width: size.width,
                    height: size.height,
                    length: size.depth,
                    chamferRadius: line * 0.22
                )
                geometry.materials = [material]
                let node = SCNNode(geometry: geometry)
                node.name = "speaker-outline-\(channel)-\(index)"
                node.position = position
                return node
            }

            var nodes: [SCNNode] = []
            var index = 0
            for y in [-height / 2, height / 2] {
                for z in [-depth / 2, depth / 2] {
                    nodes.append(edgeNode(
                        index: index,
                        size: (width + line, line, line),
                        position: SCNVector3(0, Float(y), Float(z))
                    ))
                    index += 1
                }
            }
            for x in [-width / 2, width / 2] {
                for z in [-depth / 2, depth / 2] {
                    nodes.append(edgeNode(
                        index: index,
                        size: (line, height + line, line),
                        position: SCNVector3(Float(x), 0, Float(z))
                    ))
                    index += 1
                }
            }
            for x in [-width / 2, width / 2] {
                for y in [-height / 2, height / 2] {
                    nodes.append(edgeNode(
                        index: index,
                        size: (line, line, depth + line),
                        position: SCNVector3(Float(x), Float(y), 0)
                    ))
                    index += 1
                }
            }
            return nodes
        }

        private func makeLabelNode(channel: Int) -> SCNNode {
            let text = SCNText(string: String(format: "%02d", channel), extrusionDepth: 0.0008)
            text.font = NSFont.systemFont(
                ofSize: OrbitalViewportSceneMetrics.speakerLabelFontPointSize,
                weight: .semibold
            )
            text.flatness = 0.18
            let material = SCNMaterial()
            material.isDoubleSided = true
            material.readsFromDepthBuffer = false
            material.writesToDepthBuffer = false
            text.materials = [material]
            let node = SCNNode(geometry: text)
            let bounds = text.boundingBox
            node.pivot = SCNMatrix4MakeTranslation(
                (bounds.min.x + bounds.max.x) * 0.5,
                (bounds.min.y + bounds.max.y) * 0.5,
                0
            )
            node.scale = SCNVector3(
                OrbitalViewportSceneMetrics.speakerLabelScale,
                OrbitalViewportSceneMetrics.speakerLabelScale,
                OrbitalViewportSceneMetrics.speakerLabelScale
            )
            node.renderingOrder = 1000
            node.constraints = [SCNBillboardConstraint()]
            return node
        }

        private func updateShell(configuration: OrbitalViewportRenderConfiguration) {
            let theme = configuration.theme
            let structureColor = configuration.geodesicColor(theme.structure)
            let equatorColor = configuration.geodesicColor(theme.equator)

            for (index, edgeNode) in edgeNodes.enumerated() {
                let edge = OrbitalViewportGeodesic.structure.edges[index]
                let start = configuration.rotate(OrbitalViewportGeodesic.structure.nodes[edge.a])
                let end = configuration.rotate(OrbitalViewportGeodesic.structure.nodes[edge.b])
                let visible = configuration.shellEdgeVisible(startDepth: start.z, endDepth: end.z)
                edgeNode.isHidden = !visible
                let depthAlpha = configuration.shellDepthAlpha(startDepth: start.z, endDepth: end.z)
                let baseAlpha = ([0.56, 0.74, 0.96][safe: edge.lengthGroup] ?? 0.72) * depthAlpha
                setMaterial(
                    edgeNode.geometry?.firstMaterial,
                    color: edge.lengthGroup == 2 ? equatorColor : structureColor,
                    alpha: baseAlpha
                )
            }

            for (index, node) in nodeMarkers.enumerated() {
                let rotated = configuration.rotate(OrbitalViewportGeodesic.structure.nodes[index])
                let alpha = configuration.shellNodeAlpha(depth: rotated.z)
                node.isHidden = alpha <= 0.02
                setMaterial(node.geometry?.firstMaterial, color: structureColor, alpha: alpha)
            }
        }

        private func updateSpeakers(
            configuration: OrbitalViewportRenderConfiguration,
            snapshot: OrbitalViewportSnapshot,
            updateVisibility: Bool,
            updateMaterial: Bool
        ) {
            for speaker in snapshot.speakers {
                guard let node = speakerNodes[speaker.channel] else {
                    continue
                }
                let selected = configuration.selectedChannel == speaker.channel
                let visible = configuration.isVisibleDepth(speaker.depth)

                if updateVisibility {
                    node.isHidden = !visible
                    let outlineVisible = visible &&
                        configuration.speakerShape == .cubeVU &&
                        configuration.cubeVUSettings.cubeOutlineStrength > 0.001
                    speakerOutlineNodes[speaker.channel]?.forEach { $0.isHidden = !outlineVisible }
                }

                if updateMaterial {
                    let alpha = configuration.speakerAlpha(depth: speaker.depth, selected: selected)
                    let emissionScale = configuration.speakerEmissionScale(depth: speaker.depth)
                    let scalars = SpeakerCubeVUScalars(
                        rawRms: Float(speaker.rms),
                        settings: configuration.cubeVUSettings.coreSettings,
                        paletteValue: Float(speaker.peak)
                    )
                    let display = Double(scalars.displayVuScalar)
                    let hot = Double(scalars.hotScalar)
                    let heat = Double(scalars.paletteHeat)
                    let color = configuration.theme.colorForPeak(heat)
                    let hotMix = OrbitalViewportMath.clamp01(
                        (hot - configuration.cubeVUSettings.hotThreshold) /
                        max(0.001, 1 - configuration.cubeVUSettings.hotThreshold)
                    )
                    let idleTint = configuration.cubeVUSettings.idleTint
                    let visibleFill = max(idleTint, display)
                    let emissionOpacity = (
                        configuration.cubeVUSettings.bloomMin +
                        (configuration.cubeVUSettings.bloomMax - configuration.cubeVUSettings.bloomMin) * visibleFill +
                        configuration.cubeVUSettings.hotFillStrength * hotMix * 0.38
                    ) * emissionScale
                    if configuration.speakerShape == .cubeVU {
                        let vuColor = configuration.theme.cubeVUColor(heat: heat)
                        let hotColor = configuration.theme.cubeVUHotColor
                        OrbitalViewportCubeVUSceneKitMaterial.update(
                            material: node.geometry?.firstMaterial,
                            settings: configuration.cubeVUSettings,
                            scalars: scalars,
                            clip: speaker.peak >= 0.995,
                            alpha: alpha,
                            vuColor: vuColor,
                            hotColor: hotColor
                        )
                        updateCubeOutline(
                            speakerOutlineNodes[speaker.channel],
                            theme: configuration.theme,
                            alpha: alpha,
                            strength: configuration.cubeVUSettings.cubeOutlineStrength,
                            selected: selected
                        )
                    } else {
                        setMaterial(
                            node.geometry?.firstMaterial,
                            color: color,
                            alpha: alpha * (0.72 + visibleFill * 0.28),
                            emission: color.opacity(OrbitalViewportMath.clamp01(emissionOpacity))
                        )
                    }
                }

                guard let label = labelNodes[speaker.channel] else {
                    continue
                }
                if updateVisibility {
                    label.isHidden = !configuration.showSpeakerNumbers || (!visible && !selected)
                }
                if updateMaterial {
                    let labelColor = selected ? configuration.theme.selectedLabel : configuration.theme.text
                    setMaterial(
                        label.geometry?.firstMaterial,
                        color: labelColor,
                        alpha: selected ? 1 : 0.94,
                        emission: labelColor.opacity(selected ? 0.35 : 0.18)
                    )
                }
            }
        }

        private func updateFog(configuration: OrbitalViewportRenderConfiguration) {
            let fog = configuration.fogConfiguration
            scene.fogColor = NSColor(configuration.theme.fog)
            scene.fogStartDistance = fog.startDistance
            scene.fogEndDistance = fog.endDistance
            scene.fogDensityExponent = fog.densityExponent
        }

        private func cylinderNode(from start: OVVector3, to end: OVVector3, radius: Double) -> SCNNode {
            let vector = end - start
            let height = vector.length
            let cylinder = SCNCylinder(radius: radius, height: height)
            cylinder.radialSegmentCount = 6
            let node = SCNNode(geometry: cylinder)
            node.position = ((start + end) * 0.5).scn
            node.simdOrientation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: vector.simdNormalized)
            return node
        }

        private func prismBasis(for speaker: OrbitalViewportSpeaker) -> (longAxis: OVVector3, radialAxis: OVVector3, sideAxis: OVVector3) {
            let normal = OVVector3(speaker).normalized(fallback: OVVector3(x: 0, y: 0, z: 1))
            let pole = OVVector3(x: 0, y: 1, z: 0)
            let dot = normal.dot(pole)
            let tangent = pole - (normal * dot)
            var longAxis = tangent.normalized(fallback: OVVector3(x: 1, y: 0, z: 0))
            if abs(longAxis.dot(normal)) > 0.98 {
                longAxis = OVVector3.cross(OVVector3(x: 1, y: 0, z: 0), normal).normalized(fallback: OVVector3(x: 1, y: 0, z: 0))
            }
            let sideAxis = OVVector3.cross(normal, longAxis).normalized(fallback: OVVector3(x: 1, y: 0, z: 0))
            return (longAxis, normal, sideAxis)
        }

        private func matrix(longAxis: OVVector3, sideAxis: OVVector3, radialAxis: OVVector3, position: OVVector3) -> simd_float4x4 {
            simd_float4x4(
                SIMD4<Float>(Float(longAxis.x), Float(longAxis.y), Float(longAxis.z), 0),
                SIMD4<Float>(Float(sideAxis.x), Float(sideAxis.y), Float(sideAxis.z), 0),
                SIMD4<Float>(Float(radialAxis.x), Float(radialAxis.y), Float(radialAxis.z), 0),
                SIMD4<Float>(Float(position.x), Float(position.y), Float(position.z), 1)
            )
        }

        private func setMaterial(
            _ material: SCNMaterial?,
            color: Color,
            alpha: Double,
            emission: Color? = nil
        ) {
            let nsColor = NSColor(color)
            material?.diffuse.contents = nsColor.withAlphaComponent(alpha)
            material?.emission.contents = NSColor(emission ?? .clear)
            material?.transparency = alpha
            material?.isDoubleSided = true
        }

        private func updateCubeOutline(
            _ nodes: [SCNNode]?,
            theme: OrbitalViewportTheme,
            alpha: Double,
            strength: Double,
            selected: Bool
        ) {
            let strength = OrbitalViewportMath.clamp01(strength)
            let alphaMultiplier = selected
                ? OrbitalViewportCubeVUSceneKitMaterial.cubeOutlineSelectedAlphaMultiplier
                : OrbitalViewportCubeVUSceneKitMaterial.cubeOutlineNormalAlphaMultiplier
            let outlineAlpha = alpha * strength * alphaMultiplier
            let color = selected ? theme.selectedLabel : theme.cubeOutline
            nodes?.forEach { node in
                node.isHidden = outlineAlpha <= 0.001
                setMaterial(
                    node.geometry?.firstMaterial,
                    color: color,
                    alpha: outlineAlpha,
                    emission: color.opacity(strength * OrbitalViewportCubeVUSceneKitMaterial.cubeOutlineEmissionMultiplier)
                )
            }
        }
    }
}

final class OrbitalViewportSceneNSView: SCNView {
    var onDragStarted: () -> Void = {}
    var onDrag: (CGSize) -> Void = { _ in }
    var onDragEnded: () -> Void = {}
    var onZoom: (Double) -> Void = { _ in }
    var onSelect: (Int?) -> Void = { _ in }

    private var mouseDownPoint: CGPoint?
    private var previousDragPoint: CGPoint?
    private var hasDragged = false

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        mouseDownPoint = point
        previousDragPoint = point
        hasDragged = false
        onDragStarted()
    }

    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        guard let previousDragPoint else {
            self.previousDragPoint = point
            return
        }
        guard let mouseDownPoint else {
            return
        }
        _ = previousDragPoint
        let delta = CGSize(width: point.x - mouseDownPoint.x, height: mouseDownPoint.y - point.y)
        hasDragged = true
        self.previousDragPoint = point
        onDrag(delta)
    }

    override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        defer {
            mouseDownPoint = nil
            previousDragPoint = nil
            hasDragged = false
            onDragEnded()
        }

        guard let mouseDownPoint else {
            return
        }
        let distance = hypot(point.x - mouseDownPoint.x, point.y - mouseDownPoint.y)
        if !hasDragged || distance < 4 {
            let hit = hitTest(point, options: [.searchMode: SCNHitTestSearchMode.closest.rawValue])
                .first { result in
                    result.node.name?.hasPrefix("speaker-") == true
                }
            if let name = hit?.node.name,
               let channel = Int(name.replacingOccurrences(of: "speaker-", with: "")) {
                onSelect(channel)
            } else {
                onSelect(nil)
            }
        }
    }

    override func scrollWheel(with event: NSEvent) {
        onZoom(OrbitalViewportMath.zoomDelta(forScrollDeltaY: event.scrollingDeltaY))
    }

    override func magnify(with event: NSEvent) {
        onZoom(event.magnification > 0 ? 1 : -1)
    }
}
#else
struct OrbitalViewport3DSceneView: View {
    let configuration: OrbitalViewportRenderConfiguration
    let snapshot: OrbitalViewportSnapshot
    let onDragStarted: () -> Void
    let onDrag: (CGSize) -> Void
    let onDragEnded: () -> Void
    let onZoom: (Double) -> Void
    let onSelect: (Int?) -> Void

    var body: some View {
        OrbitalViewportCanvas(configuration: configuration, snapshot: snapshot)
    }
}
#endif

struct OrbitalViewportCanvas: View {
    let configuration: OrbitalViewportRenderConfiguration
    let snapshot: OrbitalViewportSnapshot

    var body: some View {
        Canvas { context, size in
            var painter = OrbitalViewportPainter(
                context: context,
                configuration: configuration,
                snapshot: snapshot
            )
            painter.draw(size: size)
        }
    }
}

private struct OrbitalViewportPainter {
    var context: GraphicsContext
    let configuration: OrbitalViewportRenderConfiguration
    let snapshot: OrbitalViewportSnapshot

    private var theme: OrbitalViewportTheme {
        configuration.theme
    }

    mutating func draw(size: CGSize) {
        drawBackground(size: size)
        drawStructure()
        drawHiddenLinesBoundary()
        drawFogVeil(size: size)
        drawSpeakers()
    }

    mutating private func drawBackground(size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        context.fill(Path(rect), with: theme.canvasBackground)
        if let glow = theme.backgroundGlow {
            context.fill(
                Path(rect),
                with: .radialGradient(
                    Gradient(stops: [
                        Gradient.Stop(color: glow, location: 0),
                        Gradient.Stop(color: Color(red: 0.043, green: 0.047, blue: 0.051).opacity(0), location: 1)
                    ]),
                    center: CGPoint(x: size.width * 0.5, y: size.height * 0.42),
                    startRadius: 0,
                    endRadius: max(size.width, size.height) * 0.65
                )
            )
        }
    }

    mutating private func drawStructure() {
        let edgeViews = OrbitalViewportGeodesic.structure.edges.compactMap { edge -> OrbitalViewportEdgeView? in
            let start = configuration.rotate(OrbitalViewportGeodesic.structure.nodes[edge.a])
            let end = configuration.rotate(OrbitalViewportGeodesic.structure.nodes[edge.b])
            guard let clipped = clipSegmentToFront(start: start, end: end) else {
                return nil
            }
            let fade = min(configuration.hiddenDepthFade(clipped.start.z), configuration.hiddenDepthFade(clipped.end.z))
            guard fade > 0.02 else {
                return nil
            }
            return OrbitalViewportEdgeView(
                edge: edge,
                start: clipped.start,
                end: clipped.end,
                depth: (clipped.start.z + clipped.end.z) * 0.5,
                fade: fade
            )
        }
        .sorted { $0.depth < $1.depth }

        for edgeView in edgeViews {
            var path = Path()
            path.move(to: configuration.project(edgeView.start))
            path.addLine(to: configuration.project(edgeView.end))
            let alpha = ([0.58, 0.78, 0.96][safe: edgeView.edge.lengthGroup] ?? 0.72) * edgeView.fade
            let strokeColor = configuration.geodesicColor(edgeView.edge.lengthGroup == 2 ? theme.equator : theme.structure)
            context.stroke(
                path,
                with: .color(strokeColor.opacity(alpha)),
                style: StrokeStyle(lineWidth: edgeView.edge.lengthGroup == 2 ? 1.15 : 0.9, lineCap: .round)
            )
        }

        drawGeodesicNodes()
    }

    mutating private func drawGeodesicNodes() {
        for node in OrbitalViewportGeodesic.structure.nodes {
            let rotated = configuration.rotate(node)
            guard configuration.isVisibleDepth(rotated.z) else {
                continue
            }
            let point = configuration.project(rotated)
            let alpha = 0.42 * configuration.hiddenDepthFade(rotated.z)
            let rect = CGRect(x: point.x - 1.45, y: point.y - 1.45, width: 2.9, height: 2.9)
            context.fill(Path(ellipseIn: rect), with: .color(configuration.geodesicColor(theme.structure).opacity(alpha)))
        }
    }

    mutating private func drawHiddenLinesBoundary() {
        guard !configuration.hiddenLinesVisible else {
            return
        }
        let center = CGPoint(x: configuration.size.width * 0.5, y: configuration.size.height * 0.5)
        let radius = configuration.sphereRadius
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.stroke(Path(ellipseIn: rect), with: .color(configuration.geodesicColor(theme.structure)), lineWidth: 1)
    }

    mutating private func drawFogVeil(size: CGSize) {
        let fog = configuration.fogConfiguration
        guard fog.isEnabled else {
            return
        }
        let alpha = min(0.34, fog.normalizedDensity * 0.34)
        var overlay = context
        overlay.opacity = alpha
        overlay.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(stops: [
                    Gradient.Stop(color: theme.fog, location: 0),
                    Gradient.Stop(color: configuration.renderStyle == .bw ? Color.white.opacity(0) : Color.black.opacity(alpha * 0.22), location: 0.48),
                    Gradient.Stop(color: theme.fog, location: 1)
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }

    mutating private func drawSpeakers() {
        let speakers = snapshot.speakers.sorted { $0.depth < $1.depth }
        for speaker in speakers {
            let far = speaker.depth < 0
            let baseAlpha = far ? 0.42 : 0.94
            let alpha = configuration.foggedAlpha(depth: speaker.depth, baseAlpha: baseAlpha)
            let selected = configuration.selectedChannel == speaker.channel
            let color = theme.colorForPeak(speaker.peak)

            switch configuration.speakerShape {
            case .sphere:
                guard configuration.isVisibleDepth(speaker.depth) else {
                    continue
                }
                drawSpeakerSphere(speaker, color: color, alpha: alpha, selected: selected)
            case .prism, .cubeVU:
                drawSpeakerPrism(speaker, color: color, baseAlpha: alpha, selected: selected)
            }

            if configuration.showSpeakerNumbers && (selected || !far) {
                drawLabel(for: speaker, selected: selected)
            }
        }
    }

    mutating private func drawSpeakerSphere(
        _ speaker: OrbitalViewportProjectedSpeaker,
        color: Color,
        alpha: Double,
        selected: Bool
    ) {
        let radius = 8.2 * speaker.scale
        let rect = CGRect(
            x: speaker.screen.x - radius,
            y: speaker.screen.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        let path = Path(ellipseIn: rect)
        var body = context
        body.opacity = alpha
        body.fill(
            path,
            with: .radialGradient(
                Gradient(stops: [
                    Gradient.Stop(color: configuration.renderStyle == .bw ? Color.white.opacity(0.88) : Color(red: 0.945, green: 1, blue: 0.98).opacity(0.58), location: 0),
                    Gradient.Stop(color: color.opacity(configuration.renderStyle == .bw ? 0.18 : 0.24), location: 0.34),
                    Gradient.Stop(color: configuration.renderStyle == .bw ? Color(red: 0.31, green: 0.31, blue: 0.31).opacity(0.4) : Color(red: 0.282, green: 0.463, blue: 0.435).opacity(0.34), location: 0.72),
                    Gradient.Stop(color: configuration.renderStyle == .bw ? Color(hex: "#111111").opacity(0.76) : Color(red: 0.039, green: 0.071, blue: 0.078).opacity(0.72), location: 1)
                ]),
                center: CGPoint(x: speaker.screen.x, y: speaker.screen.y),
                startRadius: radius * 0.08,
                endRadius: radius
            )
        )
        body.fill(
            path,
            with: .radialGradient(
                Gradient(stops: [
                    Gradient.Stop(color: color.opacity(0.28 + speaker.peak * 0.58), location: 0),
                    Gradient.Stop(color: color.opacity(0.16 + speaker.rms * 0.34), location: 0.44),
                    Gradient.Stop(color: color.opacity(0), location: 1)
                ]),
                center: speaker.screen,
                startRadius: 0,
                endRadius: radius * 0.9
            )
        )
        body.fill(
            path,
            with: .radialGradient(
                Gradient(stops: [
                    Gradient.Stop(color: Color.white.opacity(selected ? 0.56 : 0.34), location: 0),
                    Gradient.Stop(color: Color.white.opacity(0), location: 1)
                ]),
                center: CGPoint(x: speaker.screen.x - radius * 0.34, y: speaker.screen.y - radius * 0.4),
                startRadius: 0,
                endRadius: radius * 0.46
            )
        )
    }

    mutating private func drawSpeakerPrism(
        _ speaker: OrbitalViewportProjectedSpeaker,
        color: Color,
        baseAlpha: Double,
        selected: Bool
    ) {
        let faces = prismFaces(for: speaker)
        guard !faces.isEmpty else {
            return
        }

        for face in faces {
            let points = face.points.map(\.screen)
            let path = polygonPath(points)
            let alpha = baseAlpha * face.alpha
            var fillContext = context
            fillContext.opacity = alpha
            let colorAlpha = (configuration.renderStyle == .bw ? 0.08 : 0.14) + speaker.rms * 0.12
            fillContext.fill(
                path,
                with: .linearGradient(
                    Gradient(stops: [
                        Gradient.Stop(color: configuration.renderStyle == .bw ? Color.white.opacity(0.82) : color.opacity(colorAlpha * face.shade), location: 0),
                        Gradient.Stop(color: color.opacity((0.18 + speaker.peak * 0.24) * face.shade), location: 0.58),
                        Gradient.Stop(color: configuration.renderStyle == .bw ? Color(hex: "#111111").opacity(0.2) : Color(red: 0.922, green: 1, blue: 0.973).opacity(0.1), location: 1)
                    ]),
                    startPoint: points[0],
                    endPoint: points[points.count / 2]
                )
            )

            let strokeColor = selected ? theme.selectedLabel : configuration.renderStyle == .bw ? Color(hex: "#111111").opacity(0.58) : color.opacity(0.36 + speaker.peak * 0.22)
            context.stroke(
                path,
                with: .color(strokeColor.opacity(max(0.04, alpha))),
                style: StrokeStyle(lineWidth: selected ? 1.7 : 1)
            )
        }
    }

    mutating private func drawLabel(for speaker: OrbitalViewportProjectedSpeaker, selected: Bool) {
        let offset = labelOffset(for: speaker)
        let color = configuration.renderStyle == .bw ? Color(hex: "#111111") : (selected ? theme.selectedLabel : theme.label)
        context.draw(
            Text(String(format: "%02d", speaker.channel))
                .font(.system(size: 11))
                .foregroundColor(color),
            at: CGPoint(x: speaker.screen.x + offset.x, y: speaker.screen.y + offset.y),
            anchor: .center
        )
    }

    private func clipSegmentToFront(start: OVVector3, end: OVVector3) -> (start: OVVector3, end: OVVector3)? {
        if configuration.hiddenLinesVisible {
            return (start, end)
        }

        let startInside = start.z >= configuration.frontClipPlane
        let endInside = end.z >= configuration.frontClipPlane
        if !startInside && !endInside {
            return nil
        }
        if startInside && endInside {
            return (start, end)
        }

        let t = (configuration.frontClipPlane - start.z) / (end.z - start.z)
        let clipped = OVVector3.lerp(start, end, t)
        return startInside ? (start, clipped) : (clipped, end)
    }

    private func prismBasis(for speaker: OrbitalViewportProjectedSpeaker) -> (longAxis: OVVector3, radialAxis: OVVector3, sideAxis: OVVector3) {
        let normal = OVVector3(speaker.source).normalized(fallback: OVVector3(x: 0, y: 0, z: 1))
        let pole = OVVector3(x: 0, y: 1, z: 0)
        let dot = normal.dot(pole)
        let tangent = pole - (normal * dot)
        var longAxis = tangent.normalized(fallback: OVVector3(x: 1, y: 0, z: 0))
        if abs(longAxis.dot(normal)) > 0.98 {
            longAxis = OVVector3.cross(OVVector3(x: 1, y: 0, z: 0), normal).normalized(fallback: OVVector3(x: 1, y: 0, z: 0))
        }
        let sideAxis = OVVector3.cross(normal, longAxis).normalized(fallback: OVVector3(x: 1, y: 0, z: 0))
        return (longAxis, normal, sideAxis)
    }

    private func prismFaces(for speaker: OrbitalViewportProjectedSpeaker) -> [OrbitalViewportPrismFace] {
        let basis = prismBasis(for: speaker)
        let short = (10 * configuration.speakerSize) / max(1, configuration.sphereRadius)
        let long = configuration.speakerShape == .cubeVU ? short : short * 2
        let depth = short * min(2, max(1, configuration.cubeVUSettings.speakerHeight))
        let base = basis.radialAxis
        func vertex(_ longSign: Double, _ sideSign: Double, _ radialAmount: Double) -> OrbitalViewportPrismPoint {
            let source = base
                + (basis.longAxis * (longSign * long * 0.5))
                + (basis.sideAxis * (sideSign * short * 0.5))
                + (basis.radialAxis * radialAmount)
            let rotated = configuration.rotate(source)
            return OrbitalViewportPrismPoint(rotated: rotated, screen: configuration.project(rotated), clipped: false)
        }

        let vertices = [
            vertex(-1, -1, 0),
            vertex(1, -1, 0),
            vertex(1, 1, 0),
            vertex(-1, 1, 0),
            vertex(-1, -1, depth),
            vertex(1, -1, depth),
            vertex(1, 1, depth),
            vertex(-1, 1, depth)
        ]
        let faceSpecs: [(indices: [Int], shade: Double)] = [
            ([0, 1, 2, 3], 0.58),
            ([4, 5, 6, 7], 1),
            ([0, 4, 7, 3], 0.74),
            ([1, 5, 6, 2], 0.7),
            ([3, 2, 6, 7], 0.88),
            ([0, 1, 5, 4], 0.64)
        ]

        return faceSpecs.compactMap { spec -> OrbitalViewportPrismFace? in
            let original = spec.indices.map { vertices[$0] }
            let clipped = clipPolygonToFront(original)
            guard clipped.count >= 3 else {
                return nil
            }
            let wasClipped = clipped.count != original.count || clipped.contains { $0.clipped }
            let alpha = faceFade(points: clipped, wasClipped: wasClipped)
            guard alpha > 0.025 else {
                return nil
            }
            return OrbitalViewportPrismFace(
                points: clipped,
                shade: spec.shade,
                alpha: alpha,
                depth: clipped.reduce(0) { $0 + $1.rotated.z } / Double(clipped.count)
            )
        }
        .sorted { $0.depth < $1.depth }
    }

    private func clipPolygonToFront(_ points: [OrbitalViewportPrismPoint]) -> [OrbitalViewportPrismPoint] {
        if configuration.hiddenLinesVisible {
            return points
        }

        var clipped: [OrbitalViewportPrismPoint] = []
        for index in points.indices {
            let current = points[index]
            let previous = points[(index + points.count - 1) % points.count]
            let currentInside = current.rotated.z >= configuration.frontClipPlane
            let previousInside = previous.rotated.z >= configuration.frontClipPlane

            if currentInside != previousInside {
                let t = (configuration.frontClipPlane - previous.rotated.z) / (current.rotated.z - previous.rotated.z)
                let rotated = OVVector3.lerp(previous.rotated, current.rotated, t)
                clipped.append(
                    OrbitalViewportPrismPoint(
                        rotated: rotated,
                        screen: configuration.project(rotated),
                        clipped: true
                    )
                )
            }

            if currentInside {
                clipped.append(current)
            }
        }
        return clipped
    }

    private func faceFade(points: [OrbitalViewportPrismPoint], wasClipped: Bool) -> Double {
        if configuration.hiddenLinesVisible {
            return points.reduce(0) { $0 + configuration.hiddenDepthFade($1.rotated.z) } / Double(points.count)
        }
        let band = 0.18
        let maxDepth = points.map(\.rotated.z).max() ?? 0
        let fade = OrbitalViewportMath.clamp01((maxDepth - configuration.frontClipPlane) / band)
        return max(wasClipped ? 0.5 : 0.28, fade)
    }

    private func labelOffset(for speaker: OrbitalViewportProjectedSpeaker) -> CGPoint {
        let center = CGPoint(x: configuration.size.width * 0.5, y: configuration.size.height * 0.5)
        let dx = speaker.screen.x - center.x
        let dy = speaker.screen.y - center.y
        let length = hypot(dx, dy)
        let direction = length > 0.001 ? CGPoint(x: dx / length, y: dy / length) : CGPoint(x: 1, y: -1)
        let distance = (configuration.speakerShape == .sphere ? 17 : 24) + configuration.speakerSize * 4
        return CGPoint(x: direction.x * distance, y: direction.y * distance)
    }

    private func polygonPath(_ points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else {
            return path
        }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

struct OrbitalViewportLabTheme {
    static let bg = Color(red: 7 / 255, green: 16 / 255, blue: 20 / 255)
    static let bgBottom = Color(red: 2 / 255, green: 7 / 255, blue: 10 / 255)
    static let panel = Color(red: 13 / 255, green: 24 / 255, blue: 29 / 255).opacity(0.88)
    static let panelSoft = Color.white.opacity(0.045)
    static let toolbar = Color(red: 5 / 255, green: 12 / 255, blue: 15 / 255).opacity(0.68)
    static let line = Color(red: 217 / 255, green: 251 / 255, blue: 255 / 255).opacity(0.14)
    static let text = Color(red: 239 / 255, green: 252 / 255, blue: 255 / 255)
    static let textSoft = Color(red: 159 / 255, green: 185 / 255, blue: 189 / 255)
    static let cyan = Color(red: 94 / 255, green: 234 / 255, blue: 212 / 255)
    static let blue = Color(red: 96 / 255, green: 165 / 255, blue: 250 / 255)
    static let green = Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)
    static let amber = Color(red: 250 / 255, green: 204 / 255, blue: 21 / 255)
    static let red = Color(red: 251 / 255, green: 113 / 255, blue: 133 / 255)

    static let panelRadius: CGFloat = 8
    static let controlRadius: CGFloat = 7
    static let controlHeight: CGFloat = 34
    static let controlFontSize: CGFloat = 12
    static let switchColumnWidth: CGFloat = 54
    static let toggleRowHeight: CGFloat = 30
}

struct OrbitalViewportSceneMetrics {
    static let shellStrutScale = 1.5
    static let shellStrutRadius = 0.0024 * shellStrutScale
    static let shellEquatorStrutRadius = 0.0032 * shellStrutScale
    static let shellNodeRadius = 0.005 * shellStrutScale
    static let speakerLabelFontPointSize = OrbitalViewportLabTheme.controlFontSize
    static let speakerLabelScale: Float = 0.0032
}

struct OrbitalViewportTheme: Equatable {
    let style: OrbitalViewportRenderStyle

    private var palette: OrbitalViewportPalette {
        style.palette
    }

    var pageBackground: AnyShapeStyle {
        AnyShapeStyle(LinearGradient(colors: [palette.backgroundTop, palette.backgroundBottom], startPoint: .top, endPoint: .bottom))
    }

    var canvasBackground: GraphicsContext.Shading {
        .linearGradient(Gradient(colors: [palette.backgroundTop, palette.backgroundBottom]), startPoint: .zero, endPoint: CGPoint(x: 0, y: 900))
    }

    var railBackground: Color {
        palette.panel
    }

    var toolbarBackground: Color {
        palette.toolbar
    }

    var panelBackground: Color {
        palette.panel
    }

    var panelSecondaryBackground: Color {
        palette.panelSoft
    }

    var statusBackground: Color {
        palette.toolbar
    }

    var chipBackground: Color {
        palette.panelSoft
    }

    var text: Color {
        palette.text
    }

    var muted: Color {
        palette.textSoft
    }

    var line: Color {
        palette.line
    }

    var rowLine: Color {
        palette.line.opacity(0.72)
    }

    var buttonBackground: Color {
        palette.panelSoft
    }

    var buttonActiveBackground: Color {
        palette.accent.opacity(0.14)
    }

    var buttonActiveBorder: Color {
        palette.accent.opacity(0.55)
    }

    var activeButtonText: Color {
        text
    }

    var accent: Color {
        palette.accent
    }

    var accentStrong: Color {
        palette.accent
    }

    var accentSecondary: Color {
        palette.accentSecondary
    }

    var vuHot: Color {
        palette.danger
    }

    var metricBackground: Color {
        palette.panelSoft
    }

    var metricBorder: Color {
        line
    }

    var barTrack: Color {
        palette.compressedRainbowWell ?? palette.line
    }

    var meterBar: AnyShapeStyle {
        AnyShapeStyle(LinearGradient(stops: palette.vuGradientStops, startPoint: .leading, endPoint: .trailing))
    }

    var structure: Color {
        palette.line.opacity(style == .bw ? 1.8 : 1.15)
    }

    var equator: Color {
        palette.accent.opacity(style == .bw ? 0.42 : 0.34)
    }

    var label: Color {
        palette.textSoft.opacity(0.78)
    }

    var selectedLabel: Color {
        palette.text
    }

    var fog: Color {
        palette.backgroundBottom.opacity(style == .bw ? 0.7 : 0.66)
    }

    var backgroundGlow: Color? {
        accent.opacity(style == .bw ? 0.05 : 0.1)
    }

    var dot: Color {
        accent
    }

    var cubeOutline: Color {
        palette.text
    }

    func colorForPeak(_ peak: Double) -> Color {
        palette.vuColor(for: peak)
    }

    func cubeVUColor(heat: Double) -> Color {
        palette.vuColor(for: heat)
    }

    var cubeVUHotColor: Color {
        palette.danger
    }
}

private struct OrbitalViewportGeodesic {
    static let structure = build()

    struct Structure {
        let nodes: [OVVector3]
        let edges: [Edge]
    }

    struct Edge {
        let a: Int
        let b: Int
        let lengthGroup: Int
    }

    private static let icosahedronFaces = [
        [0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11],
        [1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
        [3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9],
        [4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1]
    ]

    private static func build() -> Structure {
        let frequency = 3
        let baseVertices = createIcosahedronVertices()
        let source = baseVertices[5]
        let base = baseVertices.map {
            rotateVectorBetween(vector: $0, from: source, to: OVVector3(x: 0, y: 1, z: 0))
        }
        var nodes: [OVVector3] = []
        var nodeIds: [String: Int] = [:]
        var edgeIds: [String: (Int, Int)] = [:]

        func nodeKey(_ point: OVVector3) -> String {
            "\(String(format: "%.6f", point.x)),\(String(format: "%.6f", point.y)),\(String(format: "%.6f", point.z))"
        }

        func nodeID(_ point: OVVector3) -> Int {
            let normalized = point.normalized()
            let key = nodeKey(normalized)
            if let existing = nodeIds[key] {
                return existing
            }
            let id = nodes.count
            nodes.append(normalized)
            nodeIds[key] = id
            return id
        }

        func addEdge(_ a: Int, _ b: Int) {
            guard a != b else {
                return
            }
            let low = min(a, b)
            let high = max(a, b)
            edgeIds["\(low):\(high)"] = (low, high)
        }

        for face in icosahedronFaces {
            let a = base[face[0]]
            let b = base[face[1]]
            let c = base[face[2]]
            var localNodes: [String: Int] = [:]

            func localNodeID(_ i: Int, _ j: Int) -> Int {
                let key = "\(i):\(j)"
                if let existing = localNodes[key] {
                    return existing
                }
                let k = frequency - i - j
                let point = (a * (Double(k) / Double(frequency)))
                    + (b * (Double(i) / Double(frequency)))
                    + (c * (Double(j) / Double(frequency)))
                let id = nodeID(point)
                localNodes[key] = id
                return id
            }

            for i in 0...frequency {
                for j in 0...(frequency - i) {
                    let current = localNodeID(i, j)
                    for delta in [(1, 0), (0, 1), (-1, 1)] {
                        let nextI = i + delta.0
                        let nextJ = j + delta.1
                        if nextI >= 0, nextJ >= 0, nextI + nextJ <= frequency {
                            addEdge(current, localNodeID(nextI, nextJ))
                        }
                    }
                }
            }
        }

        let edgeLengths = edgeIds.values.map { pair in
            (pair, (nodes[pair.0] - nodes[pair.1]).length)
        }
        let lengthKeys = Array(Set(edgeLengths.map { String(format: "%.5f", $0.1) })).sorted { Double($0)! < Double($1)! }
        let edges = edgeLengths.map { pair, length in
            Edge(a: pair.0, b: pair.1, lengthGroup: lengthKeys.firstIndex(of: String(format: "%.5f", length)) ?? 0)
        }

        return Structure(nodes: nodes, edges: edges)
    }

    private static func createIcosahedronVertices() -> [OVVector3] {
        let phi = (1 + sqrt(5)) / 2
        return [
            OVVector3(x: -1, y: phi, z: 0),
            OVVector3(x: 1, y: phi, z: 0),
            OVVector3(x: -1, y: -phi, z: 0),
            OVVector3(x: 1, y: -phi, z: 0),
            OVVector3(x: 0, y: -1, z: phi),
            OVVector3(x: 0, y: 1, z: phi),
            OVVector3(x: 0, y: -1, z: -phi),
            OVVector3(x: 0, y: 1, z: -phi),
            OVVector3(x: phi, y: 0, z: -1),
            OVVector3(x: phi, y: 0, z: 1),
            OVVector3(x: -phi, y: 0, z: -1),
            OVVector3(x: -phi, y: 0, z: 1)
        ]
        .map { $0.normalized() }
    }

    private static func rotateVectorBetween(vector: OVVector3, from: OVVector3, to: OVVector3) -> OVVector3 {
        let source = from.normalized()
        let target = to.normalized()
        let axis = OVVector3.cross(source, target)
        let sinValue = axis.length
        let cosValue = source.dot(target)

        if sinValue < 0.00001 {
            if cosValue > 0 {
                return vector
            }
            return OVVector3(x: vector.x, y: -vector.y, z: -vector.z)
        }

        let unitAxis = axis * (1 / sinValue)
        return (vector * cosValue)
            + (OVVector3.cross(unitAxis, vector) * sinValue)
            + (unitAxis * (unitAxis.dot(vector) * (1 - cosValue)))
    }
}

private struct OrbitalViewportEdgeView {
    let edge: OrbitalViewportGeodesic.Edge
    let start: OVVector3
    let end: OVVector3
    let depth: Double
    let fade: Double
}

private struct OrbitalViewportPrismPoint {
    let rotated: OVVector3
    let screen: CGPoint
    let clipped: Bool
}

private struct OrbitalViewportPrismFace {
    let points: [OrbitalViewportPrismPoint]
    let shade: Double
    let alpha: Double
    let depth: Double
}

enum OrbitalViewportColorTools {
    static func withSaturation(_ color: Color, _ saturation: Double) -> Color {
        let clamped = OrbitalViewportMath.clamp01(saturation)
        guard clamped < 0.999 else {
            return color
        }

        #if os(macOS)
        let nsColor = NSColor(color)
        guard let rgb = nsColor.usingColorSpace(.deviceRGB) ?? nsColor.usingColorSpace(.sRGB) else {
            return color
        }
        let red = Double(rgb.redComponent)
        let green = Double(rgb.greenComponent)
        let blue = Double(rgb.blueComponent)
        let luminance = red * 0.2126 + green * 0.7152 + blue * 0.0722
        return Color(
            .sRGB,
            red: luminance + (red - luminance) * clamped,
            green: luminance + (green - luminance) * clamped,
            blue: luminance + (blue - luminance) * clamped,
            opacity: Double(rgb.alphaComponent)
        )
        #else
        return color
        #endif
    }
}

enum OrbitalViewportMath {
    static let speakerSizeCenter = 1.95
    private static let fogMidpointDensity = 30.0
    private static let fogDensityExponent = log(fogMidpointDensity / 100) / log(0.5)

    static func speakerSize(fromSlider value: Double) -> Double {
        let offset = (value - 50) / 50
        return speakerSizeCenter * pow(2, offset)
    }

    static func fogDensity(fromSlider value: Double) -> Double {
        let normalized = max(0, min(1, value / 100))
        return round(100 * pow(normalized, fogDensityExponent))
    }

    static func fakeMeter(channel: Int, timeMS: Double) -> (rms: Double, peak: Double) {
        let a = sin(timeMS * 0.0019 + Double(channel) * 0.73) * 0.5 + 0.5
        let b = sin(timeMS * 0.0031 + Double(channel) * 1.31) * 0.5 + 0.5
        let pulse = max(0, sin(timeMS * 0.006 + Double(channel)) - 0.78) * 3.8
        let rms = min(1, a * 0.44 + b * 0.16 + pulse * 0.16)
        let peak = min(1, rms + b * 0.28)
        return (rms, peak)
    }

    static func clamp01(_ value: Double) -> Double {
        max(0, min(1, value))
    }

    static func zoomDelta(forScrollDeltaY value: Double) -> Double {
        value > 0 ? 1 : -1
    }
}

struct OVVector3: Equatable {
    let x: Double
    let y: Double
    let z: Double

    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    init(_ speaker: OrbitalViewportSpeaker) {
        self.init(x: speaker.x, y: speaker.y, z: speaker.z)
    }

    var scn: SCNVector3 {
        SCNVector3(x, y, z)
    }

    var simdNormalized: SIMD3<Float> {
        let vector = SIMD3<Float>(Float(x), Float(y), Float(z))
        let length = simd_length(vector)
        if length < 0.0001 {
            return SIMD3<Float>(0, 1, 0)
        }
        return vector / length
    }

    var length: Double {
        sqrt(x * x + y * y + z * z)
    }

    func dot(_ other: OVVector3) -> Double {
        x * other.x + y * other.y + z * other.z
    }

    func normalized(fallback: OVVector3 = OVVector3(x: 1, y: 0, z: 0)) -> OVVector3 {
        let length = length
        if length < 0.0001 {
            return fallback
        }
        return self * (1 / length)
    }

    func rotated(around axis: OVVector3, angle: Double) -> OVVector3 {
        let unitAxis = axis.normalized()
        let cosValue = cos(angle)
        let sinValue = sin(angle)
        return (self * cosValue)
            + (OVVector3.cross(unitAxis, self) * sinValue)
            + (unitAxis * (unitAxis.dot(self) * (1 - cosValue)))
    }

    static func + (lhs: OVVector3, rhs: OVVector3) -> OVVector3 {
        OVVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    static func - (lhs: OVVector3, rhs: OVVector3) -> OVVector3 {
        OVVector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }

    static func * (lhs: OVVector3, rhs: Double) -> OVVector3 {
        OVVector3(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }

    static func cross(_ a: OVVector3, _ b: OVVector3) -> OVVector3 {
        OVVector3(
            x: a.y * b.z - a.z * b.y,
            y: a.z * b.x - a.x * b.z,
            z: a.x * b.y - a.y * b.x
        )
    }

    static func lerp(_ a: OVVector3, _ b: OVVector3, _ t: Double) -> OVVector3 {
        OVVector3(
            x: a.x + (b.x - a.x) * t,
            y: a.y + (b.y - a.y) * t,
            z: a.z + (b.z - a.z) * t
        )
    }
}

private extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xff) / 255
        let green = Double((value >> 8) & 0xff) / 255
        let blue = Double(value & 0xff) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private extension Double {
    var percentText: String {
        "\((OrbitalViewportMath.clamp01(self) * 100).formatted(.number.precision(.fractionLength(0))))%"
    }
}
