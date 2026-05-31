import Foundation
import OrbitalViewCore
import OrbitalViewSpatGRIS
import OrbitalViewTelemetry
import AVFoundation
import Combine
import Network
#if os(macOS)
import AppKit
import CoreText
import SceneKit
import simd
import UniformTypeIdentifiers
#endif
import SwiftUI

public struct OrbitalViewportMockup: View {
    public static let correctReviewAppName = "Orbital View 1.0 Native SceneKit Review App With Preserved Control Rail, Right Tuning Panel, Motion FPS Toggle, Full-Window PNG Export, and Cube VU Speaker Surface"
    public static let sourceMockupPath = "mockups/orbital-view-viewport/index.html"
    public static let desktopSize = CGSize(width: 1512, height: 850)
    public static let nativeDefaultWindowSize = CGSize(width: 1180, height: 760)
    public static let nativeMinimumWindowSize = CGSize(width: 980, height: 680)
    public static let leftRailWidth: CGFloat = 268
    public static let leftRailWindowEdgeInset: CGFloat = 18
    public static let inspectorWidth: CGFloat = 300
    public static let footerHeight: CGFloat = 46
    public static let controlSkinSource = "orbisonic-design-language"
    static let usesRootAnimationTimeline = false
    static let tuningTrayHitTargetPattern = "full-width-header-button"
    static let viewportAnimationFramesPerSecond = OrbitalViewportFrameRate.oneTwenty.framesPerSecond
    static let meterOnlyViewportFramesPerSecond = 30
    static let inspectorRefreshFramesPerSecond = 10
    public static let speakerCount = OrbitalViewportSpeaker.referenceSpeakers.count
    static let leftRailTitleText = "Orbital View"
    static let leftRailTitleFontSource = "Wavefield Receiver PlayerPanelView title"
    static let leftRailTitleFontPointSize: CGFloat = 16
    static let leftRailTitleFontWeight = "black"
    static let leftRailDesktopHeightPolicy = "full-height-desktop-rail"
    static let leftRailSectionTitles = [
        "Camera",
        "View Detail"
    ]
    static let leftRailCameraPanelPlacement = "top-aligned-under-title"
    static let sourceSelectorControlTitles = OrbitalViewportSourceMode.allCases.map(\.title)
    static let telemetryTrayControlTitles = OrbitalViewportSourceMode.telemetry.trayControlTitles
    static let localSongTrayControlTitles = OrbitalViewportSourceMode.localSong.trayControlTitles
    static let impulseTestTrayControlTitles = OrbitalViewportSourceMode.impulseTest.trayControlTitles
    static let inputSectionHeaderTitle = "Sound Metering Input"
    static let inputTrayTitle = "Input"
    static let inputTrayControlTitles = [
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
    static let themeControlPattern = "full-width-orbisonic-theme-buttons"
    static let themePaletteSource = "orbisonic-palette-brief"
    static let sameAsMainThemeTitle = "Same as Main Theme"
    static let colorPaletteControlTitles = [
        "Color Palette",
        "App Skin",
        "Speaker Pixels",
        "Source Pixels",
        "Sphere Palette",
        "Ground Palette",
        "Cube VU Ramp"
    ]
    static let globalDiceButtonStyle = "icon-only-centered-dice"
    static let viewDetailControlTitles = [
        "Speaker Size",
        "Fog Density",
        "Speaker Labels",
        "Hidden Lines",
        "Ground Plane"
    ]
    static let geodesicAppearanceControlTitles = [
        "Sphere Palette",
        "Sphere Saturation"
    ]
    static let sphereGeometryControlTitles = [
        "Ribbed Speaker Sphere",
        "Rib Thickness",
        "Vertical Ribs",
        "Horizontal Rings"
    ]
    static let groundAppearanceControlTitles = [
        "Ground Palette",
        "Grid Visibility",
        "Grid Spacing",
        "Grid Thickness",
        "Grid Size"
    ]
    static let audioRenderTypeTitles = OrbitalViewportAudioRenderMode.allCases.map(\.title)
    static let bloomStyleControlTitles = ["Randomize Bloom Style"] + OrbitalViewportCubeVUPreset.allCases.map(\.title)
    static let removedPresetControlTitles = [
        "Reset Cube VU",
        "Export Settings JSON"
    ]
    static let viewThemeDirectoryName = OrbitalViewportViewThemeStore.directoryName
    static let viewThemeTrayControlTitles = [
        "Save Theme",
        "Refresh Themes",
        "Load",
        "Set Default"
    ]
    static let speakerSourceLayoutSectionTitle = "Speaker and Source Layout"
    static let speakerLayoutTrayTitle = "Sonic Sphere Speakers"
    static let sourceLayoutTrayTitle = "Source Speakers"
    static let speakerLayoutKickerText = "Speaker layout in SPAT XML format."
    static let sourceLayoutKickerText = "Source speaker layout in SPAT XML format."
    static let speakerLayoutDirectoryName = OrbitalViewportSpatGRISLayoutStore.Kind.speakers.directoryName
    static let sourceLayoutDirectoryName = OrbitalViewportSpatGRISLayoutStore.Kind.sources.directoryName
    static let speakerLayoutTrayControlTitles = [
        "Import...",
        "Save",
        "Refresh",
        "Load",
        "Set Default"
    ]
    static let sourceLayoutTrayControlTitles = [
        "Import Setup...",
        "Import Project...",
        "Save",
        "Refresh",
        "Listen OSC",
        "Load",
        "Set Default"
    ]
    static let spatGRISOSCAddress = SpatGRISOSC.address
    static let spatGRISDefaultOSCPort = SpatGRISOSC.defaultInputPort
    static let spatGRISOSCPortRange = "1024...65535"
    static let speakerLabelFontControlTitles = OrbitalViewportSpeakerLabelFont.allCases.map(\.title)
    static let speakerLabelFontGroupTitles = OrbitalViewportSpeakerLabelFontGroup.allCases.map(\.title)
    static let speakerLabelFontSizeControlTitle = "Font Size"
    static let rollTheDiceTitle = "Roll the dice on looks"
    static let diceRandomizerAccessibilityLabels = [
        rollTheDiceTitle,
        "Randomize Cube Surface",
        "Randomize Bloom Style",
        "Randomize Meter Response"
    ]
    static let rightPanelSectionTitles = [
        "Sound Metering Input",
        "Speaker and Source Layout",
        "Roll the dice on looks",
        "Theme",
        "Speaker Appearance",
        "Sphere Appearance",
        "Ground Appearance",
        "Meter Behavior",
        "Diagnostics"
    ]
    static let futureWorkTrayTitles: [String] = []
    static let futureWorkLabel = "Future work"
    static let tuningTrayTitles = [
        "Input",
        "Sonic Sphere Speakers",
        "Source Speakers",
        "Roll the dice on looks",
        "Color Palette",
        "Saved Themes",
        "Speaker Shape",
        "Label Font",
        "Cube Surface",
        "Bloom Style",
        "Sphere Geometry",
        "Sphere Palette",
        "Ground Appearance",
        "Meter Response",
        "Performance",
        "Diagnostics"
    ]
    static let defaultExpandedRightPanelTrayTitles: [String] = []
    static func defaultRightPanelTrayExpanded(_ title: String) -> Bool {
        defaultExpandedRightPanelTrayTitles.contains(title)
    }
    static let globalDiceRandomizedControlTitles = [
        "Camera",
        "Zoom",
        "Spin",
        "Speaker Size",
        "Fog Density",
        "Speaker Labels",
        "Hidden Lines",
        "Color Palette",
        "Ribbed Speaker Sphere",
        "Rib Thickness",
        "Vertical Ribs",
        "Horizontal Rings",
        "Sphere Palette",
        "Sphere Saturation",
        "Ground Plane",
        "Ground Palette",
        "Grid Visibility",
        "Grid Spacing",
        "Grid Thickness",
        "Speaker Shape",
        "Label Font",
        "Cube Surface",
        "Bloom Style",
        "Meter Response",
        "Performance"
    ]
    static let globalDicePreservedInputStateTitles = [
        "Source Mode",
        "Telemetry Advertiser",
        "Local Song File",
        "Local Song Playback",
        "Local Song Render Type",
        "Impulse Pattern"
    ]
    static let surfaceBloomControlTitles = [
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
    static let meterResponseControlTitles = [
        "Randomize Meter Response",
        "Input Calibration",
        "Level Compression",
        "Display Ceiling",
        "Hot Response",
        "Hot Threshold",
        "Hot Fill Strength",
        "Palette Drive"
    ]
    static let inactiveObjectTrayTitles = [
        "Object Overlay",
        "Trails",
        "Glow Trails",
        "Bounds"
    ]
    static let objectTuningTraysVisible = false
    static let audioSourcePosition = "right-panel-single-input-tray-above-theme"
    static let audioTransportButtonLayout = "inside-expanded-input-tray-local-song-mode"
    static let meterSourceControlLocation = "inside-right-panel-input-tray"
    static let motionFPSControlLocation = "right-performance-tray"
    static let fpsMeterLocation = "viewport-bottom-right"
    static let fpsMeterTargetFramesPerSecond = OrbitalViewportFrameRate.oneTwenty.framesPerSecond
    static let fpsMeterUnderTargetFramesPerSecond = OrbitalViewportFrameRate.oneTwenty.framesPerSecond / 2
    static let fpsMeterLogSamplesPerSecond = 5
    public static let headedBenchmarkLaunchArgument = "--headed-benchmark"
    public static let headedBenchmarkEnvironmentKey = "ORBITAL_VIEW_HEADED_BENCHMARK"
    static let removedRightPanelCards = [
        "Scene",
        "No speaker selected",
        "30-channel VU list"
    ]
    static let rightPanelPurpose = "tuning-debug-panel"
    static let defaultSettingsSourceFileName = "Orbital View Settings 2026-05-21-171537.json"
    static let defaultRenderStyle: OrbitalViewportRenderStyle = .purple
    static let defaultSourceSpeakerRenderStyle: OrbitalViewportRenderStyle = defaultRenderStyle
    static let defaultGeodesicRenderStyle: OrbitalViewportRenderStyle = .purple
    static let defaultGeodesicSaturation = 0.0
    static let defaultShowRibbedSpeakerSphere = false
    static let defaultRibbedSphereThickness = 1.0
    static let defaultRibbedSphereVerticalRibs = 16
    static let defaultRibbedSphereHorizontalRings = 8
    static let defaultSpeakerShape: OrbitalViewportSpeakerShape = .cubeVU
    static let defaultViewportFrameRate: OrbitalViewportFrameRate = .oneTwenty
    static let defaultSourceMode: OrbitalViewportSourceMode = .telemetry
    static let defaultTelemetryAdvertisers: [OrbitalViewportTelemetryAdvertiser] = []
    static let defaultCubeVUPreset: OrbitalViewportCubeVUPreset = .hotCoreBloom
    static let defaultVUDriveMode: OrbitalViewportVUDriveMode = .impulseRipple
    static let defaultCubeVUSettings: OrbitalViewportCubeVUSettings = {
        var settings = OrbitalViewportCubeVUPreset.hotCoreBloom.settings
        settings.cubeOutlineStrength = 0.64
        settings.pixelFill = 0.86
        settings.surfaceCheckerOpacity = 0
        return settings
    }()

    @State private var yaw = OrbitalViewportCameraView.isometric.preset.yaw
    @State private var pitch = OrbitalViewportCameraView.isometric.preset.pitch
    @State private var zoom = 1.0
    @State private var cameraView: OrbitalViewportCameraView = .isometric
    @State private var renderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultRenderStyle
    @State private var sourceSpeakerRenderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultSourceSpeakerRenderStyle
    @State private var geodesicRenderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultGeodesicRenderStyle
    @State private var geodesicPaletteFollowsMainTheme = true
    @State private var geodesicSaturation = OrbitalViewportMockup.defaultGeodesicSaturation
    @State private var showRibbedSpeakerSphere = OrbitalViewportMockup.defaultShowRibbedSpeakerSphere
    @State private var ribbedSphereThickness = OrbitalViewportMockup.defaultRibbedSphereThickness
    @State private var ribbedSphereVerticalRibs = OrbitalViewportMockup.defaultRibbedSphereVerticalRibs
    @State private var ribbedSphereHorizontalRings = OrbitalViewportMockup.defaultRibbedSphereHorizontalRings
    @State private var speakerShape: OrbitalViewportSpeakerShape = OrbitalViewportMockup.defaultSpeakerShape
    @State private var speakerSizeSlider = 50.0
    @State private var fogDensitySlider = 50.0
    @State private var viewportFrameRate: OrbitalViewportFrameRate = OrbitalViewportMockup.defaultViewportFrameRate
    @State private var spin = false
    @State private var showSpeakerNumbers = false
    @State private var showHiddenLines = false
    @State private var showGridPlane = false
    @State private var gridPlaneVisibilitySlider = OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider
    @State private var gridPlaneSpacing = OrbitalViewportGridPlaneGeometry.defaultSpacing
    @State private var gridPlaneRenderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultGeodesicRenderStyle
    @State private var gridPlanePaletteFollowsMainTheme = true
    @State private var gridPlaneThickness = OrbitalViewportGridPlaneGeometry.defaultThickness
    @State private var selectedChannel: Int?
    @State private var dragStartYaw: Double?
    @State private var dragStartPitch: Double?
    @State private var spinStartYaw = OrbitalViewportCameraView.isometric.preset.yaw
    @State private var spinStartTimeMS = Date.timeIntervalSinceReferenceDate * 1000
    @State private var isDragging = false
    @State private var cameraAdjusted = false
    @State private var exportInProgress = false
    @State private var exportStatus: OrbitalViewportExportStatus?
    @State private var magnificationStartZoom: Double?
    @StateObject private var localAudio = OrbitalViewportLocalAudioController()
    @StateObject private var spatGRISOscListener = OrbitalViewportSpatGRISOSCListener()
    @StateObject private var telemetry = OrbitalViewTelemetryConsumerViewModel()
    @State private var sourceMode: OrbitalViewportSourceMode = OrbitalViewportMockup.defaultSourceMode
    @State private var inputTrayExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded(OrbitalViewportMockup.inputTrayTitle)
    @State private var selectedTelemetryAdvertiserID: String?
    @State private var localAudioRenderMode: OrbitalViewportAudioRenderMode = .allMono
    @State private var cubeVUSettings = OrbitalViewportMockup.defaultCubeVUSettings
    @State private var cubeVUPreset: OrbitalViewportCubeVUPreset = OrbitalViewportMockup.defaultCubeVUPreset
    @State private var vuDriveMode: OrbitalViewportVUDriveMode = OrbitalViewportMockup.defaultVUDriveMode
    @State private var speakerLabelFont: OrbitalViewportSpeakerLabelFont = .systemDefault
    @State private var speakerLabelFontSizeSlider = OrbitalViewportMath.speakerLabelFontSizeSliderCenter
    @State private var objectTuning = OrbitalViewportObjectTuning.default
    @State private var colorPaletteExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Color Palette")
    @State private var viewThemeExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Saved Themes")
    @State private var speakerLayoutExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded(OrbitalViewportMockup.speakerLayoutTrayTitle)
    @State private var sourceLayoutExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded(OrbitalViewportMockup.sourceLayoutTrayTitle)
    @State private var speakerGeometryExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Speaker Shape")
    @State private var sphereGeometryExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Sphere Geometry")
    @State private var geodesicAppearanceExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Sphere Palette")
    @State private var groundAppearanceExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Ground Appearance")
    @State private var speakerLabelsExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Label Font")
    @State private var meterCalibrationExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Meter Response")
    @State private var surfaceBloomExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Cube Surface")
    @State private var objectOverlayExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Object Overlay")
    @State private var trailsExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Trails")
    @State private var glowTrailsExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Glow Trails")
    @State private var boundsExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Bounds")
    @State private var performanceExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Performance")
    @State private var presetsExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Bloom Style")
    @State private var diagnosticsExpanded = OrbitalViewportMockup.defaultRightPanelTrayExpanded("Diagnostics")
    @State private var lastFrameRateStatus = OrbitalViewportFrameRateSample.pending.status
    @State private var diagnosticLogEntries = OrbitalViewportDiagnosticLog.initialEntries()
    @State private var viewThemeEntries: [OrbitalViewportSavedTheme] = []
    @State private var defaultViewTheme: OrbitalViewportDefaultThemeMetadata?
    @State private var speakerLayoutEntries: [OrbitalViewportSavedSpatGRISLayout] = []
    @State private var sourceLayoutEntries: [OrbitalViewportSavedSpatGRISLayout] = []
    @State private var defaultSpeakerLayout: OrbitalViewportDefaultSpatGRISLayoutMetadata?
    @State private var defaultSourceLayout: OrbitalViewportDefaultSpatGRISLayoutMetadata?
    @State private var activeSpeakerSetup: SpatGRISSpeakerSetup?
    @State private var activeSpeakerLayoutName = "Reference 30"
    @State private var activeSourceSetup: SpatGRISSpeakerSetup?
    @State private var activeSourceLayoutName = "No Source Setup"
    @State private var activeProject: SpatGRISProject?
    @State private var sourceMarkers: [Int: OrbitalViewportSourceMarker] = [:]
    @State private var spatGRISOSCPortText = String(SpatGRISOSC.defaultInputPort)
    @State private var didLoadInitialViewThemes = false

    public init(startWithSpin: Bool = false) {
        let initialOrbit = OrbitalViewportOrbitState.preset(.isometric)
        _yaw = State(initialValue: initialOrbit.yaw)
        _pitch = State(initialValue: initialOrbit.pitch)
        _spin = State(initialValue: startWithSpin)
        _spinStartYaw = State(initialValue: initialOrbit.yaw)
        _spinStartTimeMS = State(initialValue: Date.timeIntervalSinceReferenceDate * 1000)
    }

    public static func shouldStartHeadedBenchmarkSpin(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        arguments: [String] = CommandLine.arguments
    ) -> Bool {
        environment[headedBenchmarkEnvironmentKey] == "1" ||
            arguments.contains(headedBenchmarkLaunchArgument)
    }

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
        .onReceive(spatGRISOscListener.$latestMessage.compactMap { $0 }) { message in
            applySpatGRISOSCMessage(message)
        }
        .onReceive(spatGRISOscListener.$latestDiagnostic.compactMap { $0 }) { diagnostic in
            exportStatus = OrbitalViewportExportStatus(message: diagnostic.userMessage, isError: diagnostic.isError)
            recordDiagnostic(diagnostic.detail)
        }
        .onAppear {
            telemetry.start()
            guard !didLoadInitialViewThemes else {
                return
            }
            didLoadInitialViewThemes = true
            #if DEBUG
            let shouldApplyDefaultTheme = !OrbitalRenderTrace.isEnvironmentFlagEnabled("ORB_DISABLE_SAVED_THEME")
            #else
            let shouldApplyDefaultTheme = true
            #endif
            refreshViewThemes(applyDefault: shouldApplyDefaultTheme)
            refreshSpeakerLayouts(applyDefault: true)
            refreshSourceLayouts(applyDefault: true)
        }
        .onDisappear {
            telemetry.stop()
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

    private var speakerLabelSizeScale: Double {
        OrbitalViewportMath.speakerLabelSizeScale(fromSlider: speakerLabelFontSizeSlider)
    }

    private var gridPlaneVisibility: Double {
        OrbitalViewportGridPlaneGeometry.visibility(fromSlider: gridPlaneVisibilitySlider)
    }

    private var resolvedGeodesicRenderStyle: OrbitalViewportRenderStyle {
        geodesicPaletteFollowsMainTheme ? renderStyle : geodesicRenderStyle
    }

    private var resolvedGridPlaneRenderStyle: OrbitalViewportRenderStyle {
        gridPlanePaletteFollowsMainTheme ? renderStyle : gridPlaneRenderStyle
    }

    private var resolvedSpherePaletteTitle: String {
        localPaletteTitle(
            followsMainTheme: geodesicPaletteFollowsMainTheme,
            resolvedStyle: resolvedGeodesicRenderStyle
        )
    }

    private var resolvedGroundPaletteTitle: String {
        localPaletteTitle(
            followsMainTheme: gridPlanePaletteFollowsMainTheme,
            resolvedStyle: resolvedGridPlaneRenderStyle
        )
    }

    private var geodesicSaturationBinding: Binding<Double> {
        Binding(
            get: { geodesicSaturation },
            set: { setGeodesicSaturation($0, source: "sphere_saturation_slider") }
        )
    }

    private var activeViewportSpeakers: [OrbitalViewportSpeaker] {
        guard let activeSpeakerSetup else {
            return OrbitalViewportSpeaker.referenceSpeakers
        }
        return activeSpeakerSetup.sortedSpeakers.map(OrbitalViewportSpeaker.init(spatGRISSpeaker:))
    }

    private var activeViewportSources: [OrbitalViewportSourceMarker] {
        sourceMarkers.values.sorted { lhs, rhs in lhs.sourceID < rhs.sourceID }
    }

    private var activeSceneBounds: OrbitalViewportSceneBounds3D {
        OrbitalViewportSceneBounds3D.enclosing(
            speakers: activeViewportSpeakers,
            sources: activeViewportSources
        )
    }

    private func configuration(size: CGSize, timeMS: Double) -> OrbitalViewportRenderConfiguration {
        let effectiveYaw = displayedYaw(timeMS: timeMS)
        let sceneBounds = activeSceneBounds
        #if DEBUG
        let forceRibbedVisible = OrbitalRenderTrace.isEnvironmentFlagEnabled("ORB_FORCE_RIBBED_SPHERE_VISIBLE")
        let disableRandomAnimation = OrbitalRenderTrace.isEnvironmentFlagEnabled("ORB_DISABLE_RANDOM_ANIMATION")
        #else
        let forceRibbedVisible = false
        let disableRandomAnimation = false
        #endif
        let configuration = OrbitalViewportRenderConfiguration(
            size: size,
            timeMS: timeMS,
            yaw: effectiveYaw,
            pitch: pitch,
            cameraView: cameraView,
            zoom: zoom,
            renderStyle: renderStyle,
            sourceSpeakerRenderStyle: sourceSpeakerRenderStyle,
            geodesicRenderStyle: resolvedGeodesicRenderStyle,
            geodesicSaturation: geodesicSaturation,
            showRibbedSpeakerSphere: forceRibbedVisible || showRibbedSpeakerSphere,
            ribbedSphereThickness: ribbedSphereThickness,
            ribbedSphereVerticalRibs: ribbedSphereVerticalRibs,
            ribbedSphereHorizontalRings: ribbedSphereHorizontalRings,
            speakerShape: speakerShape,
            speakerSize: speakerSize,
            fogDensity: fogDensity,
            meterSource: activeMeterSource,
            cubeVUSettings: cubeVUSettings,
            activeViewportFramesPerSecond: viewportFrameRate.framesPerSecond,
            meterOnlyViewportFramesPerSecond: Self.meterOnlyViewportFramesPerSecond,
            inspectorRefreshFramesPerSecond: Self.inspectorRefreshFramesPerSecond,
            speakerLabelFont: speakerLabelFont,
            speakerLabelSizeScale: speakerLabelSizeScale,
            showSpeakerNumbers: showSpeakerNumbers,
            showHiddenLines: showHiddenLines,
            showGridPlane: showGridPlane,
            gridPlaneVisibility: gridPlaneVisibility,
            gridPlaneSpacing: gridPlaneSpacing,
            gridPlaneRenderStyle: resolvedGridPlaneRenderStyle,
            gridPlaneThickness: gridPlaneThickness,
            selectedChannel: selectedChannel,
            speakers: activeViewportSpeakers,
            sources: activeViewportSources,
            sceneCenter: sceneBounds.center,
            sceneHalfExtent: sceneBounds.halfExtent,
            spin: spin && !isDragging && !disableRandomAnimation,
            spinStartYaw: spinStartYaw,
            spinStartTimeMS: spinStartTimeMS
        )
        #if DEBUG
        OrbitalRenderTrace.log("configuration_built", configuration: configuration)
        #endif
        return configuration
    }

    private var activeMeterSource: OrbitalViewportMeterSource {
        switch sourceMode {
        case .telemetry:
            if let meterSnapshot = telemetry.snapshot.meterSnapshot {
                return .telemetry(meterSnapshot)
            }
            return .telemetryNoProvider
        case .localSong:
            return localAudio.meterSource(renderMode: localAudioRenderMode)
        case .impulseTest:
            return .impulse(vuDriveMode.impulseKind ?? .ripple)
        }
    }

    private var selectedTelemetryAdvertiser: OrbitalViewportTelemetryAdvertiser? {
        OrbitalViewportTelemetryAdvertiserSelection.selectedAdvertiser(
            in: telemetryAdvertisers,
            selectedID: selectedTelemetryAdvertiserID ?? telemetry.snapshot.selectedProviderID
        )
    }

    private var telemetryAdvertisers: [OrbitalViewportTelemetryAdvertiser] {
        telemetry.snapshot.providers.map(OrbitalViewportTelemetryAdvertiser.init(summary:))
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

        return HStack(alignment: .top, spacing: 0) {
            controlRail(fullHeight: true)
                .frame(width: Self.leftRailWidth)
                .frame(maxHeight: .infinity, alignment: .topLeading)

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
                controlRail(fullHeight: false)
                    .frame(minHeight: 460)
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

    private func controlRail(fullHeight: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(Self.leftRailTitleText)
                    .font(.system(size: Self.leftRailTitleFontPointSize, weight: .black))
                    .foregroundStyle(theme.text)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)

            leftRailControlPanel
        }
        .padding(12)
        .padding(.leading, Self.leftRailWindowEdgeInset)
        .padding(.trailing, Self.leftRailWindowEdgeInset)
        .frame(maxWidth: .infinity, maxHeight: fullHeight ? .infinity : nil, alignment: .topLeading)
        .background(theme.railBackground)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(theme.line)
                .frame(width: 1)
        }
    }

    private var leftRailControlPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            cameraSection
            viewDetailSection
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.toolbarBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.panelRadius, style: .continuous)
                .stroke(theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.panelRadius, style: .continuous))
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

    private var inputSection: some View {
        tuningTray(Self.inputTrayTitle, isExpanded: $inputTrayExpanded) {
            controlButtonGroup(
                OrbitalViewportSourceMode.allCases,
                selection: sourceMode,
                title: \.title
            ) { mode in
                if sourceMode != mode {
                    setSourceMode(mode)
                }
            }

            switch sourceMode {
            case .telemetry:
                telemetrySourceControls
            case .localSong:
                localSongSourceControls
            case .impulseTest:
                impulseTestSourceControls
            }

            inputDivider()
            inputMeterSourceControls
        }
    }

    private var telemetrySourceControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            if telemetryAdvertisers.count > 1 {
                sectionLabel("Advertisers")
                ForEach(telemetryAdvertisers) { advertiser in
                    controlButton(advertiser.provider, active: selectedTelemetryAdvertiser?.id == advertiser.id) {
                        selectedTelemetryAdvertiserID = advertiser.id
                        telemetry.selectProvider(id: advertiser.id)
                        recordDiagnostic("Telemetry advertiser set to \(advertiser.provider)")
                    }
                }
            }

            let advertiser = selectedTelemetryAdvertiser
            tuningValueRow("Provider", value: advertiser?.provider ?? "No Provider")
            tuningValueRow("Status", value: advertiser?.status ?? "Waiting")
            tuningValueRow("Track", value: advertiser?.track ?? "No Metadata")
        }
    }

    private var localSongSourceControls: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            Text(localAudio.fileDisplayName ?? "No local song selected")
                .font(.system(size: 11))
                .foregroundStyle(theme.muted)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            sectionLabel("Render Type")
            controlButtonGroup(
                OrbitalViewportAudioRenderMode.allCases,
                selection: localAudioRenderMode,
                title: \.title
            ) { mode in
                if localAudioRenderMode != mode {
                    localAudioRenderMode = mode
                    recordDiagnostic("Audio render type set to \(mode.title)")
                }
            }
        }
    }

    private var impulseTestSourceControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Pattern")
            controlButtonGroup(
                OrbitalViewportVUDriveMode.impulseCases,
                selection: normalizedImpulseMode,
                title: \.impulseTitle
            ) { mode in
                setVUDriveMode(mode)
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
            toggleRow("Speaker Labels", isOn: $showSpeakerNumbers)
            toggleRow("Hidden Lines", isOn: $showHiddenLines)
            toggleRow("Ground Plane", isOn: $showGridPlane)
        }
    }

    private var colorPaletteTray: some View {
        tuningTray("Color Palette", isExpanded: $colorPaletteExpanded) {
            VStack(spacing: 6) {
                ForEach(OrbitalViewportRenderStyle.allCases) { style in
                    paletteButton(style, selection: renderStyle) {
                        if renderStyle != style {
                            setGlobalColorPalette(style, source: "color_palette_picker")
                            recordDiagnostic("Color palette set to \(style.title)")
                        }
                    }
                }
            }
            tuningValueRow("Color Palette", value: renderStyle.title)
            tuningValueRow("App Skin", value: renderStyle.title)
            tuningValueRow("Speaker Pixels", value: renderStyle.title)
            tuningValueRow("Source Pixels", value: sourceSpeakerRenderStyle.title)
            tuningValueRow("Sphere Palette", value: resolvedSpherePaletteTitle)
            tuningValueRow("Ground Palette", value: resolvedGroundPaletteTitle)
            tuningValueRow("Cube VU Ramp", value: renderStyle.title)
        }
    }

    private var geodesicAppearanceTray: some View {
        tuningTray("Sphere Palette", isExpanded: $geodesicAppearanceExpanded) {
            VStack(spacing: 6) {
                sameAsMainThemePaletteButton(active: geodesicPaletteFollowsMainTheme) {
                    setGeodesicPaletteFollowsMainTheme(source: "sphere_palette_picker")
                    ensureVisibleGeodesicSaturation(source: "sphere_palette_picker")
                    recordDiagnostic("Sphere palette set to \(Self.sameAsMainThemeTitle)")
                }
                ForEach(OrbitalViewportRenderStyle.allCases) { style in
                    paletteButton(
                        style,
                        selection: resolvedGeodesicRenderStyle,
                        active: !geodesicPaletteFollowsMainTheme && resolvedGeodesicRenderStyle == style
                    ) {
                        if geodesicPaletteFollowsMainTheme || geodesicRenderStyle != style {
                            setGeodesicRenderStyle(style, source: "sphere_palette_picker")
                            ensureVisibleGeodesicSaturation(source: "sphere_palette_picker")
                            #if DEBUG
                            OrbitalRenderTrace.log(
                                "ui_palette_click_\(style.rawValue)",
                                configuration: configuration(size: .zero, timeMS: currentTimeMS())
                            )
                            #endif
                            recordDiagnostic("Sphere palette set to \(style.title)")
                        }
                    }
                }
            }
            tuningSliderRow(
                "Sphere Saturation",
                value: geodesicSaturationBinding,
                range: 0...1,
                step: 0.01,
                valueText: "\((geodesicSaturation * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningValueRow("Sphere Palette", value: resolvedSpherePaletteTitle)
        }
    }

    private func setGlobalColorPalette(_ style: OrbitalViewportRenderStyle, source: String) {
        let oldValue = renderStyle
        renderStyle = style
        let oldSourceValue = sourceSpeakerRenderStyle
        sourceSpeakerRenderStyle = style
        #if DEBUG
        OrbitalRenderTrace.logWrite(
            "renderStyle source=\(source)",
            old: oldValue,
            new: style
        )
        OrbitalRenderTrace.logWrite(
            "sourceSpeakerRenderStyle source=\(source)",
            old: oldSourceValue,
            new: style
        )
        #endif

        setGeodesicPaletteFollowsMainTheme(source: "\(source)_sphere")
        setGridPlanePaletteFollowsMainTheme(source: "\(source)_ground")
        ensureVisibleGeodesicSaturation(source: "\(source)_sphere")
    }

    private func setGeodesicPaletteFollowsMainTheme(source: String) {
        let oldFollow = geodesicPaletteFollowsMainTheme
        geodesicPaletteFollowsMainTheme = true
        #if DEBUG
        OrbitalRenderTrace.logWrite(
            "geodesicPaletteFollowsMainTheme source=\(source)",
            old: oldFollow,
            new: geodesicPaletteFollowsMainTheme
        )
        #endif
    }

    private func setGeodesicRenderStyle(
        _ style: OrbitalViewportRenderStyle,
        source: String
    ) {
        let oldValue = geodesicRenderStyle
        let oldFollow = geodesicPaletteFollowsMainTheme
        geodesicPaletteFollowsMainTheme = false
        geodesicRenderStyle = style
        #if DEBUG
        OrbitalRenderTrace.logWrite(
            "geodesicPaletteFollowsMainTheme source=\(source)",
            old: oldFollow,
            new: geodesicPaletteFollowsMainTheme
        )
        OrbitalRenderTrace.logWrite(
            "geodesicRenderStyle source=\(source)",
            old: oldValue,
            new: style
        )
        #endif
    }

    private func setGeodesicSaturation(
        _ saturation: Double,
        source: String
    ) {
        let normalizedSaturation = OrbitalViewportMath.clamp01(saturation)
        let oldValue = geodesicSaturation
        geodesicSaturation = normalizedSaturation
        #if DEBUG
        OrbitalRenderTrace.logWrite(
            "geodesicSaturation source=\(source)",
            old: oldValue,
            new: normalizedSaturation
        )
        #endif
    }

    private func ensureVisibleGeodesicSaturation(source: String) {
        let visibleSaturation = OrbitalViewportGeodesicAppearanceInteraction.saturationAfterPaletteSelection(
            current: geodesicSaturation
        )
        guard abs(visibleSaturation - geodesicSaturation) > 0.000_001 else {
            return
        }

        setGeodesicSaturation(visibleSaturation, source: "\(source)_auto_visible_saturation")
    }

    private func setGridPlanePaletteFollowsMainTheme(source: String) {
        let oldFollow = gridPlanePaletteFollowsMainTheme
        gridPlanePaletteFollowsMainTheme = true
        #if DEBUG
        OrbitalRenderTrace.logWrite(
            "gridPlanePaletteFollowsMainTheme source=\(source)",
            old: oldFollow,
            new: gridPlanePaletteFollowsMainTheme
        )
        #endif
    }

    private func setGridPlaneRenderStyle(
        _ style: OrbitalViewportRenderStyle,
        source: String
    ) {
        let oldFollow = gridPlanePaletteFollowsMainTheme
        let oldValue = gridPlaneRenderStyle
        gridPlanePaletteFollowsMainTheme = false
        gridPlaneRenderStyle = style
        #if DEBUG
        OrbitalRenderTrace.logWrite(
            "gridPlanePaletteFollowsMainTheme source=\(source)",
            old: oldFollow,
            new: gridPlanePaletteFollowsMainTheme
        )
        OrbitalRenderTrace.logWrite(
            "gridPlaneRenderStyle source=\(source)",
            old: oldValue,
            new: style
        )
        #endif
    }

    private var groundAppearanceTray: some View {
        tuningTray("Ground Appearance", isExpanded: $groundAppearanceExpanded) {
            VStack(spacing: 6) {
                sameAsMainThemePaletteButton(active: gridPlanePaletteFollowsMainTheme) {
                    setGridPlanePaletteFollowsMainTheme(source: "ground_palette_picker")
                    recordDiagnostic("Ground palette set to \(Self.sameAsMainThemeTitle)")
                }
                ForEach(OrbitalViewportRenderStyle.allCases) { style in
                    paletteButton(
                        style,
                        selection: resolvedGridPlaneRenderStyle,
                        active: !gridPlanePaletteFollowsMainTheme && resolvedGridPlaneRenderStyle == style
                    ) {
                        if gridPlanePaletteFollowsMainTheme || gridPlaneRenderStyle != style {
                            setGridPlaneRenderStyle(style, source: "ground_palette_picker")
                            recordDiagnostic("Ground palette set to \(style.title)")
                        }
                    }
                }
            }
            tuningSliderRow(
                "Grid Visibility",
                value: $gridPlaneVisibilitySlider,
                range: 0...100,
                step: 1,
                valueText: "\((gridPlaneVisibility * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningSliderRow(
                "Grid Spacing",
                value: $gridPlaneSpacing,
                range: OrbitalViewportGridPlaneGeometry.spacingRange,
                step: 0.05,
                valueText: gridPlaneSpacing.formatted(.number.precision(.fractionLength(2)))
            )
            tuningSliderRow(
                "Grid Thickness",
                value: $gridPlaneThickness,
                range: OrbitalViewportGridPlaneGeometry.thicknessRange,
                step: 0.05,
                valueText: "\((gridPlaneThickness * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningValueRow("Ground Palette", value: resolvedGroundPaletteTitle)
            tuningValueRow("Grid Size", value: "10 x 10")
        }
    }

    private var inputMeterSourceControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Meter Source")
            tuningValueRow("Selected Source", value: sourceMode.title)
            switch sourceMode {
            case .telemetry:
                let advertiser = selectedTelemetryAdvertiser
                tuningValueRow("Provider", value: advertiser?.provider ?? "No Provider")
                tuningValueRow("Telemetry Status", value: telemetry.snapshot.status)
                tuningValueRow("Displayed Meter", value: telemetry.snapshot.displayedMeter)
            case .localSong:
                tuningValueRow("Active Meter", value: "Local Song")
                tuningValueRow("Music Render", value: localAudioRenderMode.title)
                tuningValueRow("Music Source", value: localAudio.hasLoadedAudio ? "local file" : "no file")
            case .impulseTest:
                tuningValueRow("Active Meter", value: "Impulse Test")
                tuningValueRow("Impulse Pattern", value: normalizedImpulseMode.impulseTitle)
                tuningValueRow("Music Render", value: "not used")
            }
        }
    }

    private var viewThemeTray: some View {
        tuningTray("Saved Themes", isExpanded: $viewThemeExpanded) {
            HStack(spacing: 8) {
                controlButton("Save Theme", active: false) {
                    saveViewTheme()
                }
                controlButton("Refresh Themes", active: false) {
                    refreshViewThemes(applyDefault: false)
                }
            }

            if viewThemeEntries.isEmpty {
                Text("No saved themes")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.muted)
                    .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewThemeEntries) { entry in
                        viewThemeRow(entry)
                    }
                }
            }
        }
    }

    private var speakerLayoutTray: some View {
        tuningTray(Self.speakerLayoutTrayTitle, isExpanded: $speakerLayoutExpanded) {
            trayKicker(Self.speakerLayoutKickerText)

            HStack(spacing: 8) {
                controlButton("Import...", active: false) {
                    importSpeakerLayout()
                }
                controlButton("Save", active: false) {
                    saveSpeakerLayout()
                }
                controlButton("Refresh", active: false) {
                    refreshSpeakerLayouts(applyDefault: false)
                }
            }

            tuningValueRow("Current", value: activeSpeakerLayoutName)
            tuningValueRow("Mode", value: activeSpeakerSetup?.spatMode.rawValue ?? "Reference")
            tuningValueRow("Speakers", value: "\(activeViewportSpeakers.count)")

            savedSpatGRISLayoutList(
                entries: speakerLayoutEntries,
                kind: .speakers
            )
        }
    }

    private var sourceLayoutTray: some View {
        tuningTray(Self.sourceLayoutTrayTitle, isExpanded: $sourceLayoutExpanded) {
            trayKicker(Self.sourceLayoutKickerText)

            HStack(spacing: 8) {
                controlButton("Import Setup...", active: false) {
                    importSourceLayout()
                }
                controlButton("Import Project...", active: false) {
                    importSourceProject()
                }
            }

            HStack(spacing: 8) {
                controlButton("Save", active: false, disabled: activeViewportSources.isEmpty) {
                    saveSourceLayout()
                }
                controlButton("Refresh", active: false) {
                    refreshSourceLayouts(applyDefault: false)
                }
            }

            HStack(spacing: 8) {
                TextField("", text: $spatGRISOSCPortText)
                    .textFieldStyle(.plain)
                    .font(.system(size: OrbitalViewportLabTheme.controlFontSize, weight: .semibold))
                    .foregroundStyle(theme.text)
                    .multilineTextAlignment(.center)
                    .frame(width: 68)
                    .frame(minHeight: OrbitalViewportLabTheme.controlHeight)
                    .background(theme.buttonBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                            .stroke(theme.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
                    .accessibilityLabel("OSC Port")
                controlButton("Listen OSC", active: spatGRISOscListener.isListening) {
                    toggleSpatGRISOSCListening()
                }
            }

            tuningValueRow("Source Setup", value: activeSourceLayoutName)
            tuningValueRow("Project", value: activeProject.map { "\($0.sources.count) sources" } ?? "No Project")
            tuningValueRow("OSC", value: spatGRISOscListener.statusText)

            savedSpatGRISLayoutList(
                entries: sourceLayoutEntries,
                kind: .sources
            )
        }
    }

    private func savedSpatGRISLayoutList(
        entries: [OrbitalViewportSavedSpatGRISLayout],
        kind: OrbitalViewportSpatGRISLayoutStore.Kind
    ) -> some View {
        Group {
            if entries.isEmpty {
                Text(kind.emptyListTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.muted)
                    .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    ForEach(entries) { entry in
                        spatGRISLayoutRow(entry, kind: kind)
                    }
                }
            }
        }
    }

    private var speakerGeometryTray: some View {
        tuningTray("Speaker Shape", isExpanded: $speakerGeometryExpanded) {
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
        }
    }

    private var sphereGeometryTray: some View {
        tuningTray("Sphere Geometry", isExpanded: $sphereGeometryExpanded) {
            toggleRow("Ribbed Speaker Sphere", isOn: $showRibbedSpeakerSphere)
            tuningSliderRow(
                "Rib Thickness",
                value: $ribbedSphereThickness,
                range: OrbitalViewportRibbedSpeakerSphereGeometry.thicknessRange,
                step: 0.05,
                valueText: "\((ribbedSphereThickness * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningStepperRow(
                "Vertical Ribs",
                value: $ribbedSphereVerticalRibs,
                range: OrbitalViewportRibbedSpeakerSphereGeometry.verticalRibRange
            )
            tuningStepperRow(
                "Horizontal Rings",
                value: $ribbedSphereHorizontalRings,
                range: OrbitalViewportRibbedSpeakerSphereGeometry.horizontalRingRange
            )
        }
    }

    private var speakerLabelsTray: some View {
        tuningTray("Label Font", isExpanded: $speakerLabelsExpanded) {
            VStack(spacing: 8) {
                tuningSliderRow(
                    Self.speakerLabelFontSizeControlTitle,
                    value: $speakerLabelFontSizeSlider,
                    range: 0...100,
                    step: 1,
                    valueText: "\((speakerLabelSizeScale * 100).formatted(.number.precision(.fractionLength(0))))%"
                )
                ForEach(OrbitalViewportSpeakerLabelFontGroup.allCases) { group in
                    VStack(spacing: 6) {
                        sectionLabel(group.title)
                        ForEach(OrbitalViewportSpeakerLabelFont.fonts(in: group)) { font in
                            speakerLabelFontButton(font)
                        }
                    }
                }
            }
            tuningValueRow("Active Font", value: speakerLabelFont.title)
            tuningValueRow("Font Size", value: "\((speakerLabelSizeScale * 100).formatted(.number.precision(.fractionLength(0))))%")
        }
    }

    private var meterCalibrationTray: some View {
        tuningTray("Meter Response", isExpanded: $meterCalibrationExpanded) {
            HStack {
                Spacer()
                diceButton(accessibilityLabel: "Randomize Meter Response") {
                    randomizeMeterResponse()
                }
            }
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
        tuningTray("Cube Surface", isExpanded: $surfaceBloomExpanded) {
            HStack {
                Spacer()
                diceButton(accessibilityLabel: "Randomize Cube Surface") {
                    randomizeCubeSurface()
                }
            }
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
        tuningTray("Performance", isExpanded: $performanceExpanded) {
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
        tuningTray("Bloom Style", isExpanded: $presetsExpanded) {
            HStack {
                Spacer()
                diceButton(accessibilityLabel: "Randomize Bloom Style") {
                    randomizeBloomStyle()
                }
            }
            VStack(spacing: 6) {
                ForEach(OrbitalViewportCubeVUPreset.allCases) { preset in
                    controlButton(preset.title, active: cubeVUPreset == preset) {
                        applyCubeVUPreset(preset)
                    }
                }
            }
        }
    }

    private var diagnosticsTray: some View {
        tuningTray("Diagnostics", isExpanded: $diagnosticsExpanded) {
            let diagnostics = currentMeterDiagnostics()
            tuningValueRow("Correct Surface", value: "SceneKit ribbed sphere")
            tuningValueRow("Ribbed Sphere", value: showRibbedSpeakerSphere ? "Shown" : "Hidden")
            tuningValueRow("Ribbed Geometry", value: "\(ribbedSphereVerticalRibs) ribs / \(ribbedSphereHorizontalRings) rings")
            tuningValueRow("Static Speaker Rebuilds", value: "shape/size only")
            tuningValueRow("Meter Source", value: sourceMode.title)
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

    private var rollTheDicePanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                rollTheDice()
            } label: {
                Image(systemName: "dice.fill")
                    .font(.system(size: 15, weight: .heavy))
                    .frame(maxWidth: .infinity, minHeight: OrbitalViewportLabTheme.controlHeight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.accent)
            .background(theme.buttonBackground)
            .overlay(
                RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
            .accessibilityLabel(Self.rollTheDiceTitle)
            .help(Self.rollTheDiceTitle)
        }
        .padding(9)
        .background(theme.panelSecondaryBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
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

    private var sourceModeBinding: Binding<OrbitalViewportSourceMode> {
        Binding(
            get: { sourceMode },
            set: { setSourceMode($0) }
        )
    }

    private var normalizedImpulseMode: OrbitalViewportVUDriveMode {
        vuDriveMode.impulseKind == nil ? Self.defaultVUDriveMode : vuDriveMode
    }

    private func setSourceMode(_ mode: OrbitalViewportSourceMode) {
        guard sourceMode != mode else { return }
        sourceMode = mode
        if mode == .impulseTest, vuDriveMode.impulseKind == nil {
            vuDriveMode = Self.defaultVUDriveMode
        }
        recordDiagnostic("Source set to \(mode.title)")
    }

    private func setVUDriveMode(_ mode: OrbitalViewportVUDriveMode) {
        vuDriveMode = mode
        recordDiagnostic("Impulse test set to \(mode.impulseTitle)")
    }

    private func applyCubeVUPreset(_ preset: OrbitalViewportCubeVUPreset) {
        cubeVUPreset = preset
        cubeVUSettings = preset.settings
        recordDiagnostic("Cube VU preset set to \(preset.title)")
    }

    private func randomizeCubeSurface() {
        var generator = SystemRandomNumberGenerator()
        cubeVUSettings = OrbitalViewportDiceRandomizer.randomizedCubeSurfaceSettings(
            from: cubeVUSettings,
            using: &generator
        )
        recordDiagnostic("Cube Surface randomized")
    }

    private func randomizeBloomStyle() {
        var generator = SystemRandomNumberGenerator()
        let preset = OrbitalViewportDiceRandomizer.randomBloomPreset(
            current: cubeVUPreset,
            using: &generator
        )
        applyCubeVUPreset(preset)
        recordDiagnostic("Bloom Style randomized")
    }

    private func randomizeMeterResponse() {
        var generator = SystemRandomNumberGenerator()
        cubeVUSettings = OrbitalViewportDiceRandomizer.randomizedMeterResponseSettings(
            from: cubeVUSettings,
            using: &generator
        )
        recordDiagnostic("Meter Response randomized")
    }

    private func rollTheDice() {
        var generator = SystemRandomNumberGenerator()
        let roll = OrbitalViewportDiceRandomizer.globalViewRoll(
            currentBloomPreset: cubeVUPreset,
            currentShowRibbedSpeakerSphere: showRibbedSpeakerSphere,
            currentRibbedSphereThickness: ribbedSphereThickness,
            currentRibbedSphereVerticalRibs: ribbedSphereVerticalRibs,
            currentRibbedSphereHorizontalRings: ribbedSphereHorizontalRings,
            currentGeodesicRenderStyle: geodesicRenderStyle,
            currentGeodesicSaturation: geodesicSaturation,
            using: &generator
        )
        applyGlobalDiceRoll(roll)
        recordDiagnostic("Rolled the Dice")
    }

    private func applyGlobalDiceRoll(_ roll: OrbitalViewportGlobalDiceRoll) {
        commitDisplayedYaw()
        cameraView = roll.cameraView
        yaw = roll.yaw
        pitch = roll.pitch
        zoom = roll.zoom
        spin = roll.spin
        cameraAdjusted = true
        isDragging = false
        dragStartYaw = nil
        dragStartPitch = nil
        anchorSpin(to: roll.yaw)

        speakerSizeSlider = roll.speakerSizeSlider
        fogDensitySlider = roll.fogDensitySlider
        showSpeakerNumbers = roll.showSpeakerNumbers
        showHiddenLines = roll.showHiddenLines

        setGlobalColorPalette(roll.renderStyle, source: "global_dice")
        showRibbedSpeakerSphere = roll.showRibbedSpeakerSphere
        ribbedSphereThickness = roll.ribbedSphereThickness
        ribbedSphereVerticalRibs = roll.ribbedSphereVerticalRibs
        ribbedSphereHorizontalRings = roll.ribbedSphereHorizontalRings
        if roll.geodesicPaletteFollowsMainTheme {
            setGeodesicPaletteFollowsMainTheme(source: "global_dice_sphere")
        } else {
            setGeodesicRenderStyle(roll.geodesicRenderStyle, source: "global_dice_sphere")
        }
        setGeodesicSaturation(roll.geodesicSaturation, source: "global_dice_sphere")
        if roll.gridPlanePaletteFollowsMainTheme {
            setGridPlanePaletteFollowsMainTheme(source: "global_dice_ground")
        } else {
            setGridPlaneRenderStyle(roll.gridPlaneRenderStyle, source: "global_dice_ground")
        }
        showGridPlane = roll.showGridPlane
        gridPlaneVisibilitySlider = roll.gridPlaneVisibilitySlider
        gridPlaneSpacing = roll.gridPlaneSpacing
        gridPlaneThickness = roll.gridPlaneThickness

        speakerShape = roll.speakerShape
        speakerLabelFont = roll.speakerLabelFont
        speakerLabelFontSizeSlider = roll.speakerLabelFontSizeSlider
        cubeVUPreset = roll.cubePreset
        cubeVUSettings = roll.cubeSettings
        viewportFrameRate = roll.viewportFrameRate
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

    private func rightPanelSectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .heavy))
            .textCase(.uppercase)
            .foregroundStyle(theme.accent.opacity(0.82))
            .tracking(0.8)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func inputDivider() -> some View {
        Rectangle()
            .fill(theme.line.opacity(0.86))
            .frame(height: 1)
            .padding(.vertical, 2)
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

    private func localPaletteTitle(
        followsMainTheme: Bool,
        resolvedStyle: OrbitalViewportRenderStyle
    ) -> String {
        followsMainTheme
            ? "\(Self.sameAsMainThemeTitle) (\(resolvedStyle.title))"
            : resolvedStyle.title
    }

    private func sameAsMainThemePaletteButton(
        active: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let optionTheme = OrbitalViewportTheme(style: renderStyle)
        return Button(action: action) {
            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    themeSwatch(optionTheme.accent)
                    themeSwatch(optionTheme.accentSecondary)
                    themeSwatch(optionTheme.vuHot)
                }
                .frame(width: 42, alignment: .leading)

                VStack(alignment: .leading, spacing: 1) {
                    Text(Self.sameAsMainThemeTitle)
                        .font(.system(size: 11, weight: .heavy))
                        .lineLimit(1)
                    Text(renderStyle.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(active ? optionTheme.text.opacity(0.74) : theme.muted)
                }

                Spacer(minLength: 6)

                if active {
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
        .foregroundStyle(active ? optionTheme.text : theme.muted)
        .background(active ? optionTheme.buttonActiveBackground : theme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(active ? optionTheme.buttonActiveBorder : theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
    }

    private func paletteButton(
        _ style: OrbitalViewportRenderStyle,
        selection: OrbitalViewportRenderStyle,
        active activeOverride: Bool? = nil,
        action: @escaping () -> Void
    ) -> some View {
        let isActive = activeOverride ?? (selection == style)
        let optionTheme = OrbitalViewportTheme(style: style)
        return Button(action: action) {
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

    private func diceButton(accessibilityLabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "dice.fill")
                .font(.system(size: 13, weight: .heavy))
                .frame(width: 34, height: 30)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.accent)
        .background(theme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
        .accessibilityLabel(accessibilityLabel)
        .help(accessibilityLabel)
    }

    private func iconControlButton(
        _ title: String,
        systemName: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: systemName)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(theme.accent)
                    .frame(width: 16)
                Text(title)
                    .font(.system(size: OrbitalViewportLabTheme.controlFontSize, weight: .heavy))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: OrbitalViewportLabTheme.controlHeight, alignment: .leading)
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.text)
        .background(theme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
        .accessibilityLabel(accessibilityLabel)
        .help(accessibilityLabel)
    }

    private func speakerLabelFontButton(_ font: OrbitalViewportSpeakerLabelFont) -> some View {
        let isActive = speakerLabelFont == font
        let availabilityNote = font.availabilityNote
        return Button {
            if speakerLabelFont != font {
                speakerLabelFont = font
                recordDiagnostic("Speaker label font set to \(font.title)")
            }
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(font.title)
                        .font(.system(size: 11, weight: .heavy))
                        .lineLimit(1)
                    Text(font.sourceNote)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(isActive ? theme.text.opacity(0.72) : theme.muted)
                        .lineLimit(1)
                    Text(availabilityNote)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(isActive ? theme.accent.opacity(0.78) : theme.muted.opacity(0.86))
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                if isActive {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(theme.accent)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isActive ? theme.text : theme.muted)
        .background(isActive ? theme.buttonActiveBackground : theme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(isActive ? theme.buttonActiveBorder : theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
    }

    private func viewThemeRow(_ entry: OrbitalViewportSavedTheme) -> some View {
        let isDefault = isDefaultViewTheme(entry)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.displayName)
                        .font(.system(size: 11, weight: .heavy))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text(entry.isValid ? (isDefault ? "Default" : "Saved") : "Invalid JSON")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(isDefault ? theme.accent.opacity(0.82) : theme.muted)
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                if isDefault {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(theme.accent)
                }
            }

            HStack(spacing: 8) {
                controlButton("Load", active: false, disabled: !entry.isValid) {
                    loadViewTheme(entry)
                }
                controlButton("Set Default", active: isDefault, disabled: !entry.isValid) {
                    setDefaultViewTheme(entry)
                }
            }
        }
        .padding(9)
        .background(isDefault ? theme.buttonActiveBackground : theme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(isDefault ? theme.buttonActiveBorder : theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
    }

    private func spatGRISLayoutRow(
        _ entry: OrbitalViewportSavedSpatGRISLayout,
        kind: OrbitalViewportSpatGRISLayoutStore.Kind
    ) -> some View {
        let isDefault = isDefaultSpatGRISLayout(entry, kind: kind)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.displayName)
                        .font(.system(size: 11, weight: .heavy))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text(entry.isValid ? (isDefault ? "Default" : "Saved") : "Invalid XML")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(isDefault ? theme.accent.opacity(0.82) : theme.muted)
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                if isDefault {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(theme.accent)
                }
            }

            HStack(spacing: 8) {
                controlButton("Load", active: false, disabled: !entry.isValid) {
                    loadSpatGRISLayout(entry, kind: kind)
                }
                controlButton("Set Default", active: isDefault, disabled: !entry.isValid) {
                    setDefaultSpatGRISLayout(entry, kind: kind)
                }
            }
        }
        .padding(9)
        .background(isDefault ? theme.buttonActiveBackground : theme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous)
                .stroke(isDefault ? theme.buttonActiveBorder : theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: OrbitalViewportLabTheme.controlRadius, style: .continuous))
    }

    private func trayKicker(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(theme.muted)
            .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
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

    private func futureWorkRow(_ text: String = Self.futureWorkLabel) -> some View {
        trayKicker(text)
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
                let next = OrbitalViewportOrbitState(
                    view: cameraView,
                    yaw: startYaw,
                    pitch: startPitch
                ).applyingDrag(translation: delta)
                yaw = next.yaw
                pitch = next.pitch
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
            },
            onFrameRateSample: handleFrameRateSample
        )
        .accessibilityLabel("Orbital 3D Sonic Sphere viewport")
        .simultaneousGesture(magnificationGesture())
    }

    private func handleFrameRateSample(_ sample: OrbitalViewportFrameRateSample) {
        let previousStatus = lastFrameRateStatus
        guard sample.status != previousStatus else {
            return
        }

        lastFrameRateStatus = sample.status
        if sample.shouldLog {
            recordDiagnostic(sample.diagnosticMessage)
        }
    }

    private var tuningPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                rightPanelSectionHeader(Self.inputSectionHeaderTitle)
                inputSection

                rightPanelSectionHeader(Self.speakerSourceLayoutSectionTitle)
                speakerLayoutTray
                sourceLayoutTray

                rightPanelSectionHeader(Self.rollTheDiceTitle)
                rollTheDicePanel

                rightPanelSectionHeader("Theme")
                colorPaletteTray
                viewThemeTray

                rightPanelSectionHeader("Speaker Appearance")
                speakerGeometryTray
                speakerLabelsTray
                surfaceBloomTray
                presetsTray

                rightPanelSectionHeader("Sphere Appearance")
                sphereGeometryTray
                geodesicAppearanceTray

                rightPanelSectionHeader("Ground Appearance")
                groundAppearanceTray

                rightPanelSectionHeader("Meter Behavior")
                meterCalibrationTray
                performanceTray

                rightPanelSectionHeader("Diagnostics")
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
                Text(sourceFooterLabel)
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

    private var sourceFooterLabel: String {
        switch sourceMode {
        case .telemetry:
            return "Telemetry / \(selectedTelemetryAdvertiser?.provider ?? "No Provider")"
        case .localSong:
            return localAudio.footerLabel(renderMode: localAudioRenderMode)
        case .impulseTest:
            return "Impulse Test / \(normalizedImpulseMode.impulseTitle)"
        }
    }

    private func displayedYaw(at date: Date) -> Double {
        displayedYaw(timeMS: date.timeIntervalSinceReferenceDate * 1000)
    }

    private func displayedYaw(timeMS: Double) -> Double {
        #if DEBUG
        guard !OrbitalRenderTrace.isEnvironmentFlagEnabled("ORB_DISABLE_RANDOM_ANIMATION") else {
            return yaw
        }
        #endif
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
                    let next = OrbitalViewportOrbitState(
                        view: cameraView,
                        yaw: dragStartYaw ?? yaw,
                        pitch: dragStartPitch ?? pitch
                    ).applyingDrag(
                        translation: CGSize(width: dx, height: dy)
                    )
                    yaw = next.yaw
                    pitch = next.pitch
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
            let payload = currentSettingsPayload()
            let result: Result<URL, Error>
            do {
                result = .success(try OrbitalViewportSettingsJSONExporter.writeSettings(payload: payload))
            } catch {
                result = .failure(error)
            }
            handleSettingsExportResult(result)
        }
    }

    private func currentSettingsPayload(themeID: String? = nil) -> OrbitalViewportSettingsExportPayload {
        OrbitalViewportSettingsExportPayload(
            themeID: themeID,
            renderStyle: renderStyle,
            sourceSpeakerRenderStyle: renderStyle,
            geodesicRenderStyle: resolvedGeodesicRenderStyle,
            geodesicPaletteFollowsMainTheme: geodesicPaletteFollowsMainTheme,
            geodesicSaturation: geodesicSaturation,
            showRibbedSpeakerSphere: showRibbedSpeakerSphere,
            ribbedSphereThickness: ribbedSphereThickness,
            ribbedSphereVerticalRibs: ribbedSphereVerticalRibs,
            ribbedSphereHorizontalRings: ribbedSphereHorizontalRings,
            speakerShape: speakerShape,
            speakerLabelFont: speakerLabelFont,
            speakerLabelFontSizeSlider: speakerLabelFontSizeSlider,
            speakerLabelFontSizeScale: speakerLabelSizeScale,
            leftPanel: OrbitalViewportLeftPanelSettings(
                audioSource: OrbitalViewportAudioSourceExportSettings(
                    mode: localAudio.hasLoadedAudio ? .localAudioFile : .fakeMeterStream,
                    hasLoadedAudio: localAudio.hasLoadedAudio,
                    fileName: localAudio.fileDisplayName,
                    filePath: localAudio.filePath,
                    isPlaying: localAudio.isPlaying,
                    statusText: localAudio.statusText,
                    renderMode: localAudioRenderMode
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
                    showHiddenLines: showHiddenLines,
                    showGridPlane: showGridPlane,
                    gridPlaneVisibilitySlider: gridPlaneVisibilitySlider
                ),
                selectedChannel: selectedChannel
            ),
            groundAppearance: OrbitalViewportGroundAppearanceExportSettings(
                showGridPlane: showGridPlane,
                gridPlaneVisibilitySlider: gridPlaneVisibilitySlider,
                gridPlaneSpacing: gridPlaneSpacing,
                gridPlaneRenderStyle: resolvedGridPlaneRenderStyle,
                gridPlanePaletteFollowsMainTheme: gridPlanePaletteFollowsMainTheme,
                gridPlaneThickness: gridPlaneThickness
            ),
            sourceMode: sourceMode,
            driveMode: vuDriveMode,
            cubePreset: cubeVUPreset,
            cubeSettings: cubeVUSettings,
            activeViewportFramesPerSecond: viewportFrameRate.framesPerSecond,
            meterOnlyViewportFramesPerSecond: Self.meterOnlyViewportFramesPerSecond,
            inspectorRefreshFramesPerSecond: Self.inspectorRefreshFramesPerSecond,
            drawsOnDemand: !OrbitalViewport3DSceneView.rendersContinuously
        )
    }

    private func saveViewTheme() {
        do {
            let savedTheme = try OrbitalViewportViewThemeStore.writeTheme(
                payload: currentSettingsPayload(themeID: UUID().uuidString)
            )
            try reloadViewThemeEntries()
            exportStatus = OrbitalViewportExportStatus(message: "Saved theme \(savedTheme.displayName)", isError: false)
            recordDiagnostic("View theme saved as \(savedTheme.displayName)")
        } catch {
            exportStatus = OrbitalViewportExportStatus(
                message: "Theme save failed: \(error.localizedDescription)",
                isError: true
            )
            recordDiagnostic("View theme save failed: \(error.localizedDescription)")
        }
    }

    private func refreshViewThemes(applyDefault: Bool) {
        do {
            try reloadViewThemeEntries()
            if applyDefault,
               let defaultTheme = OrbitalViewportViewThemeStore.defaultTheme(
                in: viewThemeEntries,
                metadata: defaultViewTheme
               ),
               let payload = defaultTheme.payload {
                applyViewTheme(
                    payload,
                    preferDefaultSourceWhenMissing: true,
                    source: "default_theme_restore"
                )
                recordDiagnostic("Default view theme loaded: \(defaultTheme.displayName)")
            }
        } catch {
            exportStatus = OrbitalViewportExportStatus(
                message: "Theme refresh failed: \(error.localizedDescription)",
                isError: true
            )
            recordDiagnostic("View theme refresh failed: \(error.localizedDescription)")
        }
    }

    private func reloadViewThemeEntries() throws {
        let directoryURL = try OrbitalViewportViewThemeStore.themeDirectoryURL()
        viewThemeEntries = try OrbitalViewportViewThemeStore.savedThemes(in: directoryURL)
        defaultViewTheme = try? OrbitalViewportViewThemeStore.readDefaultTheme(in: directoryURL)
    }

    private func loadViewTheme(_ entry: OrbitalViewportSavedTheme) {
        guard let payload = entry.payload else {
            exportStatus = OrbitalViewportExportStatus(message: "Theme JSON is invalid", isError: true)
            recordDiagnostic("View theme load failed: invalid JSON in \(entry.fileName)")
            return
        }

        applyViewTheme(payload, source: "saved_theme_load")
        exportStatus = OrbitalViewportExportStatus(message: "Loaded theme \(entry.displayName)", isError: false)
        recordDiagnostic("View theme loaded: \(entry.displayName)")
    }

    private func setDefaultViewTheme(_ entry: OrbitalViewportSavedTheme) {
        guard entry.payload != nil else {
            exportStatus = OrbitalViewportExportStatus(message: "Theme JSON is invalid", isError: true)
            recordDiagnostic("Default view theme failed: invalid JSON in \(entry.fileName)")
            return
        }

        do {
            let metadata = try OrbitalViewportViewThemeStore.writeDefaultTheme(entry)
            defaultViewTheme = metadata
            exportStatus = OrbitalViewportExportStatus(message: "Default theme \(entry.displayName)", isError: false)
            recordDiagnostic("Default view theme set to \(entry.displayName)")
        } catch {
            exportStatus = OrbitalViewportExportStatus(
                message: "Default theme failed: \(error.localizedDescription)",
                isError: true
            )
            recordDiagnostic("Default view theme failed: \(error.localizedDescription)")
        }
    }

    private func applyViewTheme(
        _ payload: OrbitalViewportSettingsExportPayload,
        preferDefaultSourceWhenMissing: Bool = false,
        source: String = "saved_theme_restore"
    ) {
        setGlobalColorPalette(payload.renderStyle, source: source)
        if payload.geodesicPaletteFollowsMainTheme {
            setGeodesicPaletteFollowsMainTheme(source: "\(source)_sphere")
        } else {
            setGeodesicRenderStyle(payload.geodesicRenderStyle, source: "\(source)_sphere")
        }
        setGeodesicSaturation(payload.geodesicSaturation, source: "\(source)_sphere")
        showRibbedSpeakerSphere = payload.showRibbedSpeakerSphere
        ribbedSphereThickness = payload.ribbedSphereThickness
        ribbedSphereVerticalRibs = payload.ribbedSphereVerticalRibs
        ribbedSphereHorizontalRings = payload.ribbedSphereHorizontalRings
        speakerShape = payload.speakerShape
        speakerLabelFont = payload.speakerLabelFont
        speakerLabelFontSizeSlider = min(100, max(0, payload.speakerLabelFontSizeSlider))
        sourceMode = payload.sourceModeForThemeLoad(
            defaultMode: Self.defaultSourceMode,
            preferDefaultWhenMissing: preferDefaultSourceWhenMissing
        )
        localAudioRenderMode = payload.leftPanel.audioSource.renderMode ?? .allMono
        let loadedOrbit = payload.leftPanel.camera.resolvedOrbitState
        cameraView = loadedOrbit.view
        yaw = loadedOrbit.yaw
        pitch = loadedOrbit.pitch
        zoom = min(1.75, max(0.62, payload.leftPanel.camera.zoom))
        spin = payload.leftPanel.camera.spin
        cameraAdjusted = payload.leftPanel.camera.cameraAdjusted
        anchorSpin(to: yaw)
        speakerSizeSlider = min(100, max(0, payload.leftPanel.viewDetail.speakerSizeSlider))
        fogDensitySlider = min(100, max(0, payload.leftPanel.viewDetail.fogDensitySlider))
        showSpeakerNumbers = payload.leftPanel.viewDetail.showSpeakerNumbers
        showHiddenLines = payload.leftPanel.viewDetail.showHiddenLines
        showGridPlane = payload.groundAppearance.showGridPlane
        gridPlaneVisibilitySlider = payload.groundAppearance.gridPlaneVisibilitySlider
        gridPlaneSpacing = payload.groundAppearance.gridPlaneSpacing
        if payload.groundAppearance.gridPlanePaletteFollowsMainTheme {
            setGridPlanePaletteFollowsMainTheme(source: "\(source)_ground")
        } else {
            setGridPlaneRenderStyle(payload.groundAppearance.gridPlaneRenderStyle, source: "\(source)_ground")
        }
        gridPlaneThickness = payload.groundAppearance.gridPlaneThickness
        vuDriveMode = payload.driveMode.impulseKind == nil ? Self.defaultVUDriveMode : payload.driveMode
        cubeVUPreset = payload.cubePreset
        cubeVUSettings = payload.cubeSettings
        cubeVUSettings.speakerHeight = 1
        viewportFrameRate = OrbitalViewportFrameRate.option(for: payload.activeViewportFramesPerSecond)
    }

    private func isDefaultViewTheme(_ entry: OrbitalViewportSavedTheme) -> Bool {
        OrbitalViewportViewThemeStore.isDefaultTheme(entry, metadata: defaultViewTheme)
    }

    private func importSpeakerLayout() {
        openSpatGRISXMLPanel(title: "Import Speaker Layout") { url in
            do {
                let savedLayout = try OrbitalViewportSpatGRISLayoutStore.importLayout(
                    from: url,
                    kind: .speakers
                )
                try reloadSpeakerLayoutEntries()
                guard let setup = savedLayout.setup else {
                    throw SpatGRISLayoutError.malformedXML("imported setup was not saved")
                }
                applySpeakerSetup(setup, displayName: savedLayout.displayName)
                exportStatus = OrbitalViewportExportStatus(message: "Loaded speakers \(savedLayout.displayName)", isError: false)
                recordSpatGRISDiagnostics(setup, context: "Speaker layout import")
            } catch {
                exportStatus = OrbitalViewportExportStatus(message: "Speaker import failed", isError: true)
                recordDiagnostic("Speaker layout import failed: \(error.localizedDescription)")
            }
        }
    }

    private func saveSpeakerLayout() {
        do {
            let setup = try activeSpeakerSetup ?? OrbitalViewportSpatGRISLayoutStore.referenceSpeakerSetup()
            let savedLayout = try OrbitalViewportSpatGRISLayoutStore.writeLayout(
                setup: setup,
                kind: .speakers
            )
            try reloadSpeakerLayoutEntries()
            exportStatus = OrbitalViewportExportStatus(message: "Saved speakers \(savedLayout.displayName)", isError: false)
            recordDiagnostic("Speaker layout saved as \(savedLayout.displayName)")
        } catch {
            exportStatus = OrbitalViewportExportStatus(message: "Speaker save failed", isError: true)
            recordDiagnostic("Speaker layout save failed: \(error.localizedDescription)")
        }
    }

    private func refreshSpeakerLayouts(applyDefault: Bool) {
        do {
            try reloadSpeakerLayoutEntries()
            if applyDefault,
               let defaultLayout = OrbitalViewportSpatGRISLayoutStore.defaultLayout(
                in: speakerLayoutEntries,
                metadata: defaultSpeakerLayout
               ),
               let setup = defaultLayout.setup {
                applySpeakerSetup(setup, displayName: defaultLayout.displayName)
                recordDiagnostic("Default speaker layout loaded: \(defaultLayout.displayName)")
            }
        } catch {
            exportStatus = OrbitalViewportExportStatus(message: "Speaker refresh failed", isError: true)
            recordDiagnostic("Speaker layout refresh failed: \(error.localizedDescription)")
        }
    }

    private func reloadSpeakerLayoutEntries() throws {
        let directoryURL = try OrbitalViewportSpatGRISLayoutStore.layoutDirectoryURL(kind: .speakers)
        speakerLayoutEntries = try OrbitalViewportSpatGRISLayoutStore.savedLayouts(in: directoryURL)
        defaultSpeakerLayout = try? OrbitalViewportSpatGRISLayoutStore.readDefaultLayout(
            kind: .speakers,
            in: directoryURL
        )
    }

    private func importSourceLayout() {
        openSpatGRISXMLPanel(title: "Import Source Setup") { url in
            do {
                let savedLayout = try OrbitalViewportSpatGRISLayoutStore.importLayout(
                    from: url,
                    kind: .sources
                )
                try reloadSourceLayoutEntries()
                guard let setup = savedLayout.setup else {
                    throw SpatGRISLayoutError.malformedXML("imported setup was not saved")
                }
                applySourceSetup(setup, displayName: savedLayout.displayName)
                exportStatus = OrbitalViewportExportStatus(message: "Loaded source \(savedLayout.displayName)", isError: false)
                recordSpatGRISDiagnostics(setup, context: "Source setup import")
            } catch {
                exportStatus = OrbitalViewportExportStatus(message: "Source import failed", isError: true)
                recordDiagnostic("Source setup import failed: \(error.localizedDescription)")
            }
        }
    }

    private func importSourceProject() {
        openSpatGRISXMLPanel(title: "Import Source Project") { url in
            do {
                let project = try SpatGRISXML.parseProjectData(from: url)
                activeProject = project
                sourceMarkers = sourceMarkers.mapValues { marker in
                    marker.applying(project: project)
                }
                exportStatus = OrbitalViewportExportStatus(message: "Loaded project \(project.sources.count) sources", isError: false)
                recordDiagnostic("SpatGRIS project loaded from \(url.lastPathComponent) with \(project.sources.count) source rows")
            } catch {
                exportStatus = OrbitalViewportExportStatus(message: "Project import failed", isError: true)
                recordDiagnostic("SpatGRIS project import failed: \(error.localizedDescription)")
            }
        }
    }

    private func saveSourceLayout() {
        do {
            let setup = try OrbitalViewportSpatGRISLayoutStore.sourceSetup(from: activeViewportSources)
            let savedLayout = try OrbitalViewportSpatGRISLayoutStore.writeLayout(
                setup: setup,
                kind: .sources
            )
            try reloadSourceLayoutEntries()
            exportStatus = OrbitalViewportExportStatus(message: "Saved source \(savedLayout.displayName)", isError: false)
            recordDiagnostic("Source layout saved as \(savedLayout.displayName)")
        } catch {
            exportStatus = OrbitalViewportExportStatus(message: "Source save failed", isError: true)
            recordDiagnostic("Source layout save failed: \(error.localizedDescription)")
        }
    }

    private func refreshSourceLayouts(applyDefault: Bool) {
        do {
            try reloadSourceLayoutEntries()
            if applyDefault,
               let defaultLayout = OrbitalViewportSpatGRISLayoutStore.defaultLayout(
                in: sourceLayoutEntries,
                metadata: defaultSourceLayout
               ),
               let setup = defaultLayout.setup {
                applySourceSetup(setup, displayName: defaultLayout.displayName)
                recordDiagnostic("Default source layout loaded: \(defaultLayout.displayName)")
            }
        } catch {
            exportStatus = OrbitalViewportExportStatus(message: "Source refresh failed", isError: true)
            recordDiagnostic("Source layout refresh failed: \(error.localizedDescription)")
        }
    }

    private func reloadSourceLayoutEntries() throws {
        let directoryURL = try OrbitalViewportSpatGRISLayoutStore.layoutDirectoryURL(kind: .sources)
        sourceLayoutEntries = try OrbitalViewportSpatGRISLayoutStore.savedLayouts(in: directoryURL)
        defaultSourceLayout = try? OrbitalViewportSpatGRISLayoutStore.readDefaultLayout(
            kind: .sources,
            in: directoryURL
        )
    }

    private func loadSpatGRISLayout(
        _ entry: OrbitalViewportSavedSpatGRISLayout,
        kind: OrbitalViewportSpatGRISLayoutStore.Kind
    ) {
        guard let setup = entry.setup else {
            exportStatus = OrbitalViewportExportStatus(message: "Layout XML is invalid", isError: true)
            recordDiagnostic("\(kind.displayName) layout load failed: invalid XML in \(entry.fileName)")
            return
        }

        switch kind {
        case .speakers:
            applySpeakerSetup(setup, displayName: entry.displayName)
            exportStatus = OrbitalViewportExportStatus(message: "Loaded speakers \(entry.displayName)", isError: false)
        case .sources:
            applySourceSetup(setup, displayName: entry.displayName)
            exportStatus = OrbitalViewportExportStatus(message: "Loaded source \(entry.displayName)", isError: false)
        }
        recordDiagnostic("\(kind.displayName) layout loaded: \(entry.displayName)")
        recordSpatGRISDiagnostics(setup, context: "\(kind.displayName) layout load")
    }

    private func setDefaultSpatGRISLayout(
        _ entry: OrbitalViewportSavedSpatGRISLayout,
        kind: OrbitalViewportSpatGRISLayoutStore.Kind
    ) {
        guard entry.setup != nil else {
            exportStatus = OrbitalViewportExportStatus(message: "Layout XML is invalid", isError: true)
            recordDiagnostic("Default \(kind.displayName.lowercased()) layout failed: invalid XML in \(entry.fileName)")
            return
        }

        do {
            let metadata = try OrbitalViewportSpatGRISLayoutStore.writeDefaultLayout(entry, kind: kind)
            switch kind {
            case .speakers:
                defaultSpeakerLayout = metadata
            case .sources:
                defaultSourceLayout = metadata
            }
            exportStatus = OrbitalViewportExportStatus(message: "Default \(kind.displayName.lowercased()) \(entry.displayName)", isError: false)
            recordDiagnostic("Default \(kind.displayName.lowercased()) layout set to \(entry.displayName)")
        } catch {
            exportStatus = OrbitalViewportExportStatus(message: "Default layout failed", isError: true)
            recordDiagnostic("Default \(kind.displayName.lowercased()) layout failed: \(error.localizedDescription)")
        }
    }

    private func isDefaultSpatGRISLayout(
        _ entry: OrbitalViewportSavedSpatGRISLayout,
        kind: OrbitalViewportSpatGRISLayoutStore.Kind
    ) -> Bool {
        let metadata: OrbitalViewportDefaultSpatGRISLayoutMetadata?
        switch kind {
        case .speakers:
            metadata = defaultSpeakerLayout
        case .sources:
            metadata = defaultSourceLayout
        }
        return OrbitalViewportSpatGRISLayoutStore.isDefaultLayout(entry, metadata: metadata)
    }

    private func applySpeakerSetup(_ setup: SpatGRISSpeakerSetup, displayName: String) {
        activeSpeakerSetup = setup
        activeSpeakerLayoutName = displayName
        let validChannels = Set(setup.speakers.map(\.patchID))
        if let selectedChannel, !validChannels.contains(selectedChannel) {
            self.selectedChannel = nil
        }
    }

    private func applySourceSetup(_ setup: SpatGRISSpeakerSetup, displayName: String) {
        activeSourceSetup = setup
        activeSourceLayoutName = displayName
        sourceMarkers = Dictionary(uniqueKeysWithValues: setup.sortedSpeakers.map { speaker in
            let marker = OrbitalViewportSourceMarker(spatGRISSpeaker: speaker).applying(project: activeProject)
            return (marker.sourceID, marker)
        })
    }

    private func applySpatGRISOSCMessage(_ message: SpatGRISSourcePositionMessage) {
        if let position = message.position {
            var marker = sourceMarkers[message.sourceID] ?? OrbitalViewportSourceMarker(
                sourceID: message.sourceID,
                label: "Source \(String(format: "%02d", message.sourceID))",
                position: position
            ).applying(project: activeProject)
            marker = marker.repositioned(to: position)
            sourceMarkers[message.sourceID] = marker
            activeSourceLayoutName = activeSourceSetup == nil ? "OSC Sources" : activeSourceLayoutName
        } else {
            sourceMarkers.removeValue(forKey: message.sourceID)
        }
        recordDiagnostic("SpatGRIS OSC source \(message.sourceID) \(message.kind.rawValue) received")
    }

    private func toggleSpatGRISOSCListening() {
        if spatGRISOscListener.isListening {
            spatGRISOscListener.stop()
            return
        }

        guard let port = Int(spatGRISOSCPortText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            exportStatus = OrbitalViewportExportStatus(message: "Invalid OSC port", isError: true)
            recordDiagnostic("SpatGRIS OSC listen failed: non-numeric port")
            return
        }

        do {
            try SpatGRISOSC.validatePort(port)
            try spatGRISOscListener.start(port: port)
        } catch {
            exportStatus = OrbitalViewportExportStatus(message: "Invalid OSC port", isError: true)
            recordDiagnostic("SpatGRIS OSC listen failed: \(error.localizedDescription)")
        }
    }

    private func recordSpatGRISDiagnostics(_ setup: SpatGRISSpeakerSetup, context: String) {
        setup.diagnostics.forEach { diagnostic in
            recordDiagnostic("\(context): \(diagnostic.severity.rawValue) \(diagnostic.message)")
        }
    }

    private func openSpatGRISXMLPanel(title: String, completion: @escaping (URL) -> Void) {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.title = title
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.xml]
        if panel.runModal() == .OK,
           let url = panel.url {
            completion(url)
        }
        #else
        _ = title
        _ = completion
        exportStatus = OrbitalViewportExportStatus(message: "Import unavailable", isError: true)
        recordDiagnostic("SpatGRIS XML import unavailable on this platform")
        #endif
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

enum OrbitalViewportFrameRateStatus: String, Equatable {
    case target
    case belowTarget = "below target"
    case underTarget = "under target"

    static func status(for framesPerSecond: Double) -> OrbitalViewportFrameRateStatus {
        status(
            for: framesPerSecond,
            targetFramesPerSecond: OrbitalViewportMockup.fpsMeterTargetFramesPerSecond
        )
    }

    static func status(
        for framesPerSecond: Double,
        targetFramesPerSecond: Int
    ) -> OrbitalViewportFrameRateStatus {
        let target = Double(max(1, targetFramesPerSecond))
        if framesPerSecond < target * 0.5 {
            return .underTarget
        }
        if framesPerSecond < target * 0.9 {
            return .belowTarget
        }
        return .target
    }
}

struct OrbitalViewportFrameRateSample: Equatable {
    let timestampMS: Double
    let framesPerSecond: Double?
    let targetFramesPerSecond: Int
    let status: OrbitalViewportFrameRateStatus
    let shouldLog: Bool

    static let pending = OrbitalViewportFrameRateSample(
        timestampMS: 0,
        framesPerSecond: nil,
        targetFramesPerSecond: OrbitalViewportMockup.fpsMeterTargetFramesPerSecond,
        status: .belowTarget,
        shouldLog: false
    )

    var isPending: Bool {
        framesPerSecond == nil
    }

    var displayFramesPerSecondText: String {
        guard let framesPerSecond else {
            return "--"
        }
        return String(format: "%.1f", framesPerSecond)
    }

    var displayStatusText: String {
        isPending ? "warming up" : status.rawValue
    }

    var diagnosticMessage: String {
        "FPS \(displayFramesPerSecondText) target=\(targetFramesPerSecond) status=\(status.rawValue)"
    }

    var accessibilityValue: String {
        "FPS \(displayFramesPerSecondText), target \(targetFramesPerSecond), status \(displayStatusText)"
    }
}

struct OrbitalViewportFrameRateMonitor {
    private static let sampleWindowMS = 1_000.0
    private static let emitIntervalMS = 1_000.0 / Double(OrbitalViewportMockup.fpsMeterLogSamplesPerSecond)

    private let targetFramesPerSecond: Int
    private var frameTimesMS: [Double] = []
    private var lastEmitTimeMS: Double?
    private var lastStatus: OrbitalViewportFrameRateStatus?

    init(targetFramesPerSecond: Int = OrbitalViewportMockup.fpsMeterTargetFramesPerSecond) {
        self.targetFramesPerSecond = max(1, targetFramesPerSecond)
    }

    mutating func recordFrame(at timeMS: Double) -> OrbitalViewportFrameRateSample? {
        frameTimesMS.append(timeMS)
        let cutoffMS = timeMS - Self.sampleWindowMS
        frameTimesMS.removeAll { $0 < cutoffMS }

        guard frameTimesMS.count >= 2,
              let firstFrameTimeMS = frameTimesMS.first else {
            return nil
        }

        let elapsedMS = max(1, timeMS - firstFrameTimeMS)
        let rawFramesPerSecond = Double(frameTimesMS.count - 1) * 1_000 / elapsedMS
        let framesPerSecond = (rawFramesPerSecond * 10).rounded() / 10
        let status = OrbitalViewportFrameRateStatus.status(
            for: framesPerSecond,
            targetFramesPerSecond: targetFramesPerSecond
        )
        let statusChanged = lastStatus.map { $0 != status } ?? true
        let outsideThrottleWindow = lastEmitTimeMS.map { timeMS - $0 >= Self.emitIntervalMS - 0.000_001 } ?? true

        guard statusChanged || outsideThrottleWindow else {
            return nil
        }

        lastEmitTimeMS = timeMS
        lastStatus = status
        return OrbitalViewportFrameRateSample(
            timestampMS: timeMS,
            framesPerSecond: framesPerSecond,
            targetFramesPerSecond: targetFramesPerSecond,
            status: status,
            shouldLog: true
        )
    }

    mutating func reset() {
        frameTimesMS.removeAll(keepingCapacity: true)
        lastEmitTimeMS = nil
        lastStatus = nil
    }
}

struct OrbitalViewportRenderInstrumentationSnapshot: Equatable {
    var renderAnimationFrameAttemptCount = 0
    var renderAnimationFrameDrawCount = 0
    var renderAnimationFrameSkippedForCadenceCount = 0
    var renderSceneCount = 0
    var cameraUpdateCount = 0
    var gridPlaneUpdateCount = 0
    var ribbedSphereTopologyBuildCount = 0
    var ribbedSphereSegmentNodeBuildCount = 0
    var ribbedSphereSegmentVisitCount = 0
    var ribbedSphereMaterialWriteCount = 0
    var ribbedSphereHiddenStateWriteCount = 0
    var ribbedSphereMaterialUpdateCount = 0
    var speakerVisibilityUpdateCount = 0
    var speakerMaterialUpdateCount = 0
    var speakerMaterialSpeakerVisitCount = 0
    var speakerLabelMaterialUpdateCount = 0
    var sourcePoseOrVisibilityUpdateCount = 0
    var sourceMaterialUpdateCount = 0
    var fogUpdateCount = 0
    var cubeVUMaterialUpdateCount = 0
    var cubeVUFaceTextureCacheHitCount = 0
    var cubeVUFaceTextureCacheMissCount = 0
    var cubeVUFaceTextureGenerationCount = 0
    var cubeVUFaceTextureEvictionCount = 0
    var cubeVUUniformWriteCount = 0
    var cubeVUTextureAssignmentCount = 0
    var cubeOutlineMaterialUpdateCount = 0
    var needsDisplayCount = 0
    var needsDisplaySkippedCount = 0
    var renderSceneNoOpCount = 0
    var sceneMaterialWriteCount = 0
    var sceneMaterialSkipCount = 0
    var speakerMaterialUnchangedFrameSkipCount = 0
    var sourceMaterialUnchangedFrameSkipCount = 0
    var frameRateSampleCount = 0
}

struct OrbitalViewportAudioDiagnosticEvent: Equatable {
    let id = UUID()
    let message: String
}

struct OrbitalViewportSpatGRISOSCDiagnostic: Equatable {
    let userMessage: String
    let detail: String
    let isError: Bool
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

enum OrbitalViewportSourceMode: String, CaseIterable, Identifiable, Codable, Equatable {
    case telemetry
    case localSong
    case impulseTest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .telemetry:
            return "Telemetry"
        case .localSong:
            return "Local Song"
        case .impulseTest:
            return "Impulse Test"
        }
    }

    var trayControlTitles: [String] {
        switch self {
        case .telemetry:
            return ["Provider", "Status", "Track"]
        case .localSong:
            return ["Choose File", "Play", "Pause", "Render Type"]
        case .impulseTest:
            return OrbitalViewportVUDriveMode.impulseCases.map(\.impulseTitle)
        }
    }

    static func legacyMode(for driveMode: OrbitalViewportVUDriveMode) -> OrbitalViewportSourceMode {
        driveMode.impulseKind == nil ? .localSong : .impulseTest
    }
}

struct OrbitalViewportTelemetryAdvertiser: Identifiable, Equatable {
    let id: String
    let provider: String
    let status: String
    let track: String

    init(id: String, provider: String, status: String, track: String) {
        self.id = id
        self.provider = provider
        self.status = status
        self.track = track
    }

    init(summary: OrbitalViewTelemetryProviderSummary) {
        self.init(
            id: summary.id,
            provider: summary.provider,
            status: summary.status,
            track: summary.track
        )
    }
}

enum OrbitalViewportTelemetryAdvertiserSelection {
    static func selectedAdvertiser(
        in advertisers: [OrbitalViewportTelemetryAdvertiser],
        selectedID: String?
    ) -> OrbitalViewportTelemetryAdvertiser? {
        guard !advertisers.isEmpty else {
            return nil
        }

        if let selectedID,
           let selected = advertisers.first(where: { $0.id == selectedID }) {
            return selected
        }

        return advertisers[0]
    }

    static func advertiserButtonTitles(for advertisers: [OrbitalViewportTelemetryAdvertiser]) -> [String] {
        advertisers.count > 1 ? advertisers.map(\.provider) : []
    }
}

enum OrbitalViewportSilentMeterReason: Equatable {
    case telemetryNoProvider
    case localSongNoFile
}

struct OrbitalViewportMeterSource: Equatable {
    enum Mode: Equatable {
        case silent(OrbitalViewportSilentMeterReason)
        case telemetry(OrbitalViewTelemetryMeterSnapshot)
        case localAudio(UUID, OrbitalViewportAudioRenderMode)
        case impulse(OrbitalViewportImpulseKind)
    }

    let mode: Mode
    private let localAudio: OrbitalViewportLocalAudioController?

    static let telemetryNoProvider = OrbitalViewportMeterSource(mode: .silent(.telemetryNoProvider), localAudio: nil)
    static let localSongNoFile = OrbitalViewportMeterSource(mode: .silent(.localSongNoFile), localAudio: nil)
    static let sphereImpulseTest = OrbitalViewportMeterSource(mode: .impulse(.ripple), localAudio: nil)

    static func impulse(_ kind: OrbitalViewportImpulseKind) -> OrbitalViewportMeterSource {
        OrbitalViewportMeterSource(mode: .impulse(kind), localAudio: nil)
    }

    static func telemetry(_ snapshot: OrbitalViewTelemetryMeterSnapshot) -> OrbitalViewportMeterSource {
        OrbitalViewportMeterSource(mode: .telemetry(snapshot), localAudio: nil)
    }

    static func localAudio(
        _ controller: OrbitalViewportLocalAudioController,
        renderMode: OrbitalViewportAudioRenderMode
    ) -> OrbitalViewportMeterSource {
        OrbitalViewportMeterSource(mode: .localAudio(controller.sourceID, renderMode), localAudio: controller)
    }

    static func == (lhs: OrbitalViewportMeterSource, rhs: OrbitalViewportMeterSource) -> Bool {
        lhs.mode == rhs.mode
    }

    func meter(channel: Int, timeMS: Double) -> OrbitalViewportMeterSample {
        switch mode {
        case .silent:
            return .silent
        case .telemetry(let snapshot):
            guard let level = snapshot.level(channel: channel) else {
                return .silent
            }
            return OrbitalViewportMeterSample(rms: level.rms, peak: level.peak)
        case .localAudio(_, let renderMode):
            let sample = localAudio?.currentMeterSample() ?? .silent
            guard let impulseKind = renderMode.impulseKind else {
                return sample
            }
            return OrbitalViewportImpulsePattern.meter(
                kind: impulseKind,
                channel: channel,
                timeMS: timeMS,
                excitation: sample
            )
        case .impulse(let kind):
            return OrbitalViewportImpulsePattern.meter(kind: kind, channel: channel, timeMS: timeMS)
        }
    }
}

enum OrbitalViewportImpulsePattern {
    static let patternName = "sphere-ripple-impulse"
    static let orbitingCometCount = 2

    static func meter(channel: Int, timeMS: Double) -> OrbitalViewportMeterSample {
        meter(kind: .ripple, channel: channel, timeMS: timeMS)
    }

    static func meter(
        kind: OrbitalViewportImpulseKind,
        channel: Int,
        timeMS: Double,
        excitation: OrbitalViewportMeterSample? = nil
    ) -> OrbitalViewportMeterSample {
        let speaker = OrbitalViewportSpeaker.referenceSpeakers[safe: channel - 1]
        let position = speaker.map { OVVector3($0).normalized() } ?? OVVector3(x: 0, y: 0, z: 1)
        let seconds = timeMS / 1000
        let rawPattern: Double
        let rawPeak: Double

        switch kind {
        case .ripple:
            let ripple = rippleValue(position: position, seconds: seconds)
            rawPattern = ripple.rms
            rawPeak = ripple.peak
        case .waves:
            let waves = wavesValue(position: position, seconds: seconds)
            rawPattern = waves.rms
            rawPeak = waves.peak
        case .orbitingComets:
            let comets = orbitingCometsValue(position: position, seconds: seconds)
            rawPattern = comets.rms
            rawPeak = comets.peak
        }

        let drive = excitation.map {
            OrbitalViewportMath.clamp01(0.16 + $0.rms * 1.28 + $0.peak * 0.24)
        } ?? 1
        let floor = excitation == nil ? 0.03 : 0.008 + (excitation?.rms ?? 0) * 0.045
        let rms = OrbitalViewportMath.clamp01(floor + rawPattern * drive)
        let peak = OrbitalViewportMath.clamp01(rms + rawPeak * drive * 0.22 + (excitation?.peak ?? 0) * 0.08)
        return OrbitalViewportMeterSample(rms: rms, peak: peak)
    }

    private static func rippleValue(position: OVVector3, seconds: Double) -> (rms: Double, peak: Double) {
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
        let sweep = pow(max(0, 0.5 + 0.5 * sin(seconds * 2.3 + position.z * 3.7 + position.x * 1.4)), 3) * 0.14
        let meridian = pow(max(0, 0.5 + 0.5 * cos(seconds * 2.1 + atan2(position.y, position.x) * 2.0)), 4) * 0.18
        let coreFlash = gaussian(angularDistance(position, primaryOrigin), width: 0.22) * 0.34
        let rms = OrbitalViewportMath.clamp01(primary * 1.05 + secondary * 0.62 + sweep + meridian + coreFlash)
        return (rms, max(primary, secondary))
    }

    private static func wavesValue(position: OVVector3, seconds: Double) -> (rms: Double, peak: Double) {
        let azimuth = atan2(position.y, position.x)
        let latitude = asin(max(-1, min(1, position.z)))
        let bandA = pow(max(0, 0.5 + 0.5 * sin(seconds * 2.15 + latitude * 7.2)), 2.7)
        let bandB = pow(max(0, 0.5 + 0.5 * sin(seconds * 1.68 - azimuth * 3.0)), 3.2) * 0.62
        let cross = pow(max(0, 0.5 + 0.5 * cos(seconds * 2.7 + position.x * 4.4 - position.y * 3.6)), 4) * 0.34
        let rms = OrbitalViewportMath.clamp01(bandA * 0.72 + bandB + cross)
        return (rms, max(bandA, max(bandB, cross)))
    }

    private static func orbitingCometsValue(position: OVVector3, seconds: Double) -> (rms: Double, peak: Double) {
        let cometA = cometTrailValue(position: position, seconds: seconds, phase: 0, speed: 0.58)
        let cometB = cometTrailValue(position: position, seconds: seconds, phase: 2.85, speed: -0.52)
        let tailHeat = max(cometA.tailPeak, cometB.tailPeak)
        let shimmer = pow(max(0, 0.5 + 0.5 * sin(seconds * 3.7 + position.z * 4.2)), 6) * 0.05
        let rms = OrbitalViewportMath.clamp01(cometA.rms + cometB.rms + shimmer)
        let peak = OrbitalViewportMath.clamp01(max(cometA.peak, cometB.peak) + tailHeat * 0.18)
        return (rms, peak)
    }

    private static func cometTrailValue(
        position: OVVector3,
        seconds: Double,
        phase: Double,
        speed: Double
    ) -> (rms: Double, peak: Double, tailPeak: Double) {
        let cometTime = seconds * speed
        let headOrigin = movingOrigin(seconds: cometTime, phase: phase)
        let head = gaussian(angularDistance(position, headOrigin), width: 0.32)
        let tail1 = gaussian(
            angularDistance(position, movingOrigin(seconds: cometTime - 0.48, phase: phase)),
            width: 0.42
        ) * 0.72
        let tail2 = gaussian(
            angularDistance(position, movingOrigin(seconds: cometTime - 0.92, phase: phase)),
            width: 0.54
        ) * 0.5
        let tail3 = gaussian(
            angularDistance(position, movingOrigin(seconds: cometTime - 1.36, phase: phase)),
            width: 0.64
        ) * 0.32
        let tailPeak = max(tail1, max(tail2, tail3))
        let rms = OrbitalViewportMath.clamp01(head * 0.95 + tail1 + tail2 + tail3)
        let peak = OrbitalViewportMath.clamp01(head + tail1 * 0.48 + tail2 * 0.3 + tail3 * 0.18)
        return (rms, peak, tailPeak)
    }

    private static func movingOrigin(seconds: Double, phase: Double) -> OVVector3 {
        let latitude = sin(seconds * 0.41 + phase) * 0.72
        let longitude = seconds * 0.77 + sin(seconds * 0.19 + phase) * 0.65 + phase
        let horizontal = sqrt(max(0.0001, 1 - latitude * latitude))
        return OVVector3(
            x: cos(longitude) * horizontal,
            y: sin(longitude) * horizontal,
            z: latitude
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

final class OrbitalViewportSpatGRISOSCListener: ObservableObject {
    @Published private(set) var isListening = false
    @Published private(set) var statusText = "Off"
    @Published var latestMessage: SpatGRISSourcePositionMessage?
    @Published var latestDiagnostic: OrbitalViewportSpatGRISOSCDiagnostic?

    private var listener: NWListener?
    private let queue = DispatchQueue(label: "OrbitalViewport.SpatGRISOSC")

    func start(port: Int) throws {
        try SpatGRISOSC.validatePort(port)
        stop()

        guard let nwPort = NWEndpoint.Port(rawValue: UInt16(port)) else {
            throw SpatGRISLayoutError.invalidPort(port)
        }

        let listener = try NWListener(using: .udp, on: nwPort)
        listener.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.handle(state: state, port: port)
            }
        }
        listener.newConnectionHandler = { [weak self] connection in
            self?.receive(from: connection)
        }
        listener.start(queue: queue)
        self.listener = listener
    }

    func stop() {
        listener?.cancel()
        listener = nil
        DispatchQueue.main.async {
            self.isListening = false
            self.statusText = "Off"
            self.latestDiagnostic = OrbitalViewportSpatGRISOSCDiagnostic(
                userMessage: "OSC stopped",
                detail: "SpatGRIS OSC listener stopped",
                isError: false
            )
        }
    }

    private func handle(state: NWListener.State, port: Int) {
        switch state {
        case .ready:
            isListening = true
            statusText = "Listening \(port)"
            latestDiagnostic = OrbitalViewportSpatGRISOSCDiagnostic(
                userMessage: "OSC listening",
                detail: "SpatGRIS OSC listener ready on port \(port)",
                isError: false
            )
        case .failed(let error):
            isListening = false
            statusText = "Error"
            latestDiagnostic = OrbitalViewportSpatGRISOSCDiagnostic(
                userMessage: "OSC error",
                detail: "SpatGRIS OSC listener failed: \(error.localizedDescription)",
                isError: true
            )
            listener?.cancel()
            listener = nil
        case .cancelled:
            isListening = false
            statusText = "Off"
        default:
            break
        }
    }

    private func receive(from connection: NWConnection) {
        connection.stateUpdateHandler = { _ in }
        connection.start(queue: queue)
        receiveNext(from: connection)
    }

    private func receiveNext(from connection: NWConnection) {
        connection.receiveMessage { [weak self] data, _, _, error in
            guard let self else {
                return
            }
            if let data, !data.isEmpty {
                self.handlePacket(data)
            }
            if let error {
                DispatchQueue.main.async {
                    self.latestDiagnostic = OrbitalViewportSpatGRISOSCDiagnostic(
                        userMessage: "OSC packet error",
                        detail: "SpatGRIS OSC receive failed: \(error.localizedDescription)",
                        isError: true
                    )
                }
                return
            }
            self.receiveNext(from: connection)
        }
    }

    private func handlePacket(_ data: Data) {
        do {
            let messages: [SpatGRISSourcePositionMessage]
            if let line = String(data: data, encoding: .utf8),
               let textMessage = try SpatGRISOSCParser.parseTextLine(line) {
                messages = [textMessage]
            } else {
                messages = try SpatGRISOSCParser.parsePacket(data)
            }
            for message in messages {
                DispatchQueue.main.async {
                    self.latestMessage = message
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.latestDiagnostic = OrbitalViewportSpatGRISOSCDiagnostic(
                    userMessage: "OSC parse error",
                    detail: "SpatGRIS OSC parse failed: \(error.localizedDescription)",
                    isError: true
                )
            }
        }
    }
}

final class OrbitalViewportLocalAudioController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var fileDisplayName: String?
    @Published private(set) var filePath: String?
    @Published private(set) var isPlaying = false
    @Published private(set) var statusText = "No local song selected"
    @Published private(set) var latestDiagnosticEvent: OrbitalViewportAudioDiagnosticEvent?

    private var player: AVAudioPlayer?
    private(set) var sourceID = UUID()

    var hasLoadedAudio: Bool {
        player != nil
    }

    func meterSource(renderMode: OrbitalViewportAudioRenderMode) -> OrbitalViewportMeterSource {
        guard player != nil else {
            return .localSongNoFile
        }
        return .localAudio(self, renderMode: renderMode)
    }

    func footerLabel(renderMode: OrbitalViewportAudioRenderMode) -> String {
        guard let fileDisplayName else {
            return "Local Song / No File"
        }
        let source = isPlaying ? "Local Song: \(fileDisplayName)" : "Local Song paused"
        return renderMode == .allMono ? source : "\(source) / \(renderMode.title)"
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
        return "Orbital View \(formatter.string(from: date)) \(style.title).png"
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
    var themeID: String?
    let schemaVersion: Int
    let appName: String
    let exportedAt: String
    let renderStyle: OrbitalViewportRenderStyle
    let sourceSpeakerRenderStyle: OrbitalViewportRenderStyle
    let geodesicRenderStyle: OrbitalViewportRenderStyle
    let geodesicPaletteFollowsMainTheme: Bool
    let geodesicSaturation: Double
    let showRibbedSpeakerSphere: Bool
    let ribbedSphereThickness: Double
    let ribbedSphereVerticalRibs: Int
    let ribbedSphereHorizontalRings: Int
    let speakerShape: OrbitalViewportSpeakerShape
    let speakerLabelFont: OrbitalViewportSpeakerLabelFont
    let speakerLabelFontSizeSlider: Double
    let speakerLabelFontSizeScale: Double
    let leftPanel: OrbitalViewportLeftPanelSettings
    let groundAppearance: OrbitalViewportGroundAppearanceExportSettings
    let sourceMode: OrbitalViewportSourceMode
    let sourceModeWasExplicit: Bool
    let driveMode: OrbitalViewportVUDriveMode
    let cubePreset: OrbitalViewportCubeVUPreset
    let cubeSettings: OrbitalViewportCubeVUSettings
    let activeViewportFramesPerSecond: Int
    let meterOnlyViewportFramesPerSecond: Int
    let inspectorRefreshFramesPerSecond: Int
    let drawsOnDemand: Bool

    init(
        themeID: String? = nil,
        renderStyle: OrbitalViewportRenderStyle,
        sourceSpeakerRenderStyle: OrbitalViewportRenderStyle? = nil,
        geodesicRenderStyle: OrbitalViewportRenderStyle? = nil,
        geodesicPaletteFollowsMainTheme: Bool? = nil,
        geodesicSaturation: Double = 1,
        showRibbedSpeakerSphere: Bool = OrbitalViewportMockup.defaultShowRibbedSpeakerSphere,
        ribbedSphereThickness: Double = OrbitalViewportMockup.defaultRibbedSphereThickness,
        ribbedSphereVerticalRibs: Int = OrbitalViewportMockup.defaultRibbedSphereVerticalRibs,
        ribbedSphereHorizontalRings: Int = OrbitalViewportMockup.defaultRibbedSphereHorizontalRings,
        speakerShape: OrbitalViewportSpeakerShape,
        speakerLabelFont: OrbitalViewportSpeakerLabelFont = .systemDefault,
        speakerLabelFontSizeSlider: Double = OrbitalViewportMath.speakerLabelFontSizeSliderCenter,
        speakerLabelFontSizeScale: Double = 1,
        leftPanel: OrbitalViewportLeftPanelSettings = .default,
        groundAppearance: OrbitalViewportGroundAppearanceExportSettings = .default,
        sourceMode: OrbitalViewportSourceMode = OrbitalViewportMockup.defaultSourceMode,
        driveMode: OrbitalViewportVUDriveMode,
        cubePreset: OrbitalViewportCubeVUPreset,
        cubeSettings: OrbitalViewportCubeVUSettings,
        activeViewportFramesPerSecond: Int,
        meterOnlyViewportFramesPerSecond: Int,
        inspectorRefreshFramesPerSecond: Int,
        drawsOnDemand: Bool,
        exportedAt date: Date = Date()
    ) {
        self.themeID = themeID
        self.schemaVersion = 9
        self.appName = OrbitalViewportMockup.correctReviewAppName
        self.exportedAt = OrbitalViewportSettingsJSONExporter.timestampString(date: date)
        self.renderStyle = renderStyle
        self.sourceSpeakerRenderStyle = sourceSpeakerRenderStyle ?? renderStyle
        let resolvedGeodesicRenderStyle = geodesicRenderStyle ?? renderStyle
        self.geodesicRenderStyle = resolvedGeodesicRenderStyle
        self.geodesicPaletteFollowsMainTheme = geodesicPaletteFollowsMainTheme ??
            (resolvedGeodesicRenderStyle == renderStyle)
        self.geodesicSaturation = OrbitalViewportMath.clamp01(geodesicSaturation)
        self.showRibbedSpeakerSphere = showRibbedSpeakerSphere
        self.ribbedSphereThickness = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedThickness(ribbedSphereThickness)
        self.ribbedSphereVerticalRibs = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedVerticalRibs(ribbedSphereVerticalRibs)
        self.ribbedSphereHorizontalRings = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedHorizontalRings(ribbedSphereHorizontalRings)
        self.speakerShape = speakerShape
        self.speakerLabelFont = speakerLabelFont
        self.speakerLabelFontSizeSlider = min(100, max(0, speakerLabelFontSizeSlider))
        self.speakerLabelFontSizeScale = max(0.1, speakerLabelFontSizeScale)
        self.leftPanel = leftPanel
        self.groundAppearance = groundAppearance
        self.sourceMode = sourceMode
        self.sourceModeWasExplicit = true
        self.driveMode = driveMode
        self.cubePreset = cubePreset
        self.cubeSettings = cubeSettings
        self.activeViewportFramesPerSecond = activeViewportFramesPerSecond
        self.meterOnlyViewportFramesPerSecond = meterOnlyViewportFramesPerSecond
        self.inspectorRefreshFramesPerSecond = inspectorRefreshFramesPerSecond
        self.drawsOnDemand = drawsOnDemand
    }

    enum CodingKeys: String, CodingKey {
        case themeID
        case schemaVersion
        case appName
        case exportedAt
        case renderStyle
        case sourceSpeakerRenderStyle
        case geodesicRenderStyle
        case geodesicPaletteFollowsMainTheme
        case geodesicSaturation
        case showRibbedSpeakerSphere
        case ribbedSphereThickness
        case ribbedSphereVerticalRibs
        case ribbedSphereHorizontalRings
        case showSpeakerCenterStruts
        case speakerShape
        case speakerLabelFont
        case speakerLabelFontSizeSlider
        case speakerLabelFontSizeScale
        case leftPanel
        case groundAppearance
        case sourceMode
        case driveMode
        case cubePreset
        case cubeSettings
        case activeViewportFramesPerSecond
        case meterOnlyViewportFramesPerSecond
        case inspectorRefreshFramesPerSecond
        case drawsOnDemand
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(themeID, forKey: .themeID)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(appName, forKey: .appName)
        try container.encode(exportedAt, forKey: .exportedAt)
        try container.encode(renderStyle, forKey: .renderStyle)
        try container.encode(sourceSpeakerRenderStyle, forKey: .sourceSpeakerRenderStyle)
        try container.encode(geodesicRenderStyle, forKey: .geodesicRenderStyle)
        try container.encode(geodesicPaletteFollowsMainTheme, forKey: .geodesicPaletteFollowsMainTheme)
        try container.encode(geodesicSaturation, forKey: .geodesicSaturation)
        try container.encode(showRibbedSpeakerSphere, forKey: .showRibbedSpeakerSphere)
        try container.encode(ribbedSphereThickness, forKey: .ribbedSphereThickness)
        try container.encode(ribbedSphereVerticalRibs, forKey: .ribbedSphereVerticalRibs)
        try container.encode(ribbedSphereHorizontalRings, forKey: .ribbedSphereHorizontalRings)
        try container.encode(speakerShape, forKey: .speakerShape)
        try container.encode(speakerLabelFont, forKey: .speakerLabelFont)
        try container.encode(speakerLabelFontSizeSlider, forKey: .speakerLabelFontSizeSlider)
        try container.encode(speakerLabelFontSizeScale, forKey: .speakerLabelFontSizeScale)
        try container.encode(leftPanel, forKey: .leftPanel)
        try container.encode(groundAppearance, forKey: .groundAppearance)
        try container.encode(sourceMode, forKey: .sourceMode)
        try container.encode(driveMode, forKey: .driveMode)
        try container.encode(cubePreset, forKey: .cubePreset)
        try container.encode(cubeSettings, forKey: .cubeSettings)
        try container.encode(activeViewportFramesPerSecond, forKey: .activeViewportFramesPerSecond)
        try container.encode(meterOnlyViewportFramesPerSecond, forKey: .meterOnlyViewportFramesPerSecond)
        try container.encode(inspectorRefreshFramesPerSecond, forKey: .inspectorRefreshFramesPerSecond)
        try container.encode(drawsOnDemand, forKey: .drawsOnDemand)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        themeID = try container.decodeIfPresent(String.self, forKey: .themeID)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        appName = try container.decode(String.self, forKey: .appName)
        exportedAt = try container.decode(String.self, forKey: .exportedAt)
        renderStyle = try container.decode(OrbitalViewportRenderStyle.self, forKey: .renderStyle)
        sourceSpeakerRenderStyle = try container.decodeIfPresent(
            OrbitalViewportRenderStyle.self,
            forKey: .sourceSpeakerRenderStyle
        ) ?? renderStyle
        geodesicRenderStyle = try container.decodeIfPresent(
            OrbitalViewportRenderStyle.self,
            forKey: .geodesicRenderStyle
        ) ?? renderStyle
        geodesicPaletteFollowsMainTheme = try container.decodeIfPresent(
            Bool.self,
            forKey: .geodesicPaletteFollowsMainTheme
        ) ?? (geodesicRenderStyle == renderStyle)
        geodesicSaturation = OrbitalViewportMath.clamp01(
            try container.decodeIfPresent(Double.self, forKey: .geodesicSaturation) ?? 1
        )
        showRibbedSpeakerSphere = try container.decodeIfPresent(
            Bool.self,
            forKey: .showRibbedSpeakerSphere
        ) ?? (
            try container.decodeIfPresent(Bool.self, forKey: .showSpeakerCenterStruts)
                ?? OrbitalViewportMockup.defaultShowRibbedSpeakerSphere
        )
        ribbedSphereThickness = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedThickness(
            try container.decodeIfPresent(Double.self, forKey: .ribbedSphereThickness)
                ?? OrbitalViewportMockup.defaultRibbedSphereThickness
        )
        ribbedSphereVerticalRibs = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedVerticalRibs(
            try container.decodeIfPresent(Int.self, forKey: .ribbedSphereVerticalRibs)
                ?? OrbitalViewportMockup.defaultRibbedSphereVerticalRibs
        )
        ribbedSphereHorizontalRings = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedHorizontalRings(
            try container.decodeIfPresent(Int.self, forKey: .ribbedSphereHorizontalRings)
                ?? OrbitalViewportMockup.defaultRibbedSphereHorizontalRings
        )
        speakerShape = try container.decode(OrbitalViewportSpeakerShape.self, forKey: .speakerShape)
        speakerLabelFont = try container.decodeIfPresent(
            OrbitalViewportSpeakerLabelFont.self,
            forKey: .speakerLabelFont
        ) ?? .systemDefault
        speakerLabelFontSizeSlider = min(
            100,
            max(
                0,
                try container.decodeIfPresent(
                    Double.self,
                    forKey: .speakerLabelFontSizeSlider
                ) ?? OrbitalViewportMath.speakerLabelFontSizeSliderCenter
            )
        )
        speakerLabelFontSizeScale = max(
            0.1,
            try container.decodeIfPresent(
                Double.self,
                forKey: .speakerLabelFontSizeScale
            ) ?? OrbitalViewportMath.speakerLabelSizeScale(fromSlider: speakerLabelFontSizeSlider)
        )
        leftPanel = try container.decodeIfPresent(
            OrbitalViewportLeftPanelSettings.self,
            forKey: .leftPanel
        ) ?? .default
        let decodedGroundAppearance = try container.decodeIfPresent(
            OrbitalViewportGroundAppearanceExportSettings.self,
            forKey: .groundAppearance
        ) ?? OrbitalViewportGroundAppearanceExportSettings(
            showGridPlane: leftPanel.viewDetail.showGridPlane,
            gridPlaneVisibilitySlider: leftPanel.viewDetail.gridPlaneVisibilitySlider,
            gridPlaneSpacing: OrbitalViewportGridPlaneGeometry.defaultSpacing,
            gridPlaneRenderStyle: geodesicRenderStyle,
            gridPlanePaletteFollowsMainTheme: geodesicRenderStyle == renderStyle,
            gridPlaneThickness: OrbitalViewportGridPlaneGeometry.defaultThickness
        )
        let inferredGroundPaletteFollowsMainTheme = decodedGroundAppearance.gridPlanePaletteFollowsMainThemeWasExplicit
            ? decodedGroundAppearance.gridPlanePaletteFollowsMainTheme
            : decodedGroundAppearance.gridPlaneRenderStyle == renderStyle
        groundAppearance = OrbitalViewportGroundAppearanceExportSettings(
            showGridPlane: decodedGroundAppearance.showGridPlane,
            gridPlaneVisibilitySlider: decodedGroundAppearance.gridPlaneVisibilitySlider,
            gridPlaneSpacing: decodedGroundAppearance.gridPlaneSpacing,
            gridPlaneRenderStyle: decodedGroundAppearance.gridPlaneRenderStyle,
            gridPlanePaletteFollowsMainTheme: inferredGroundPaletteFollowsMainTheme,
            gridPlaneThickness: decodedGroundAppearance.gridPlaneThickness
        )
        let decodedSourceMode = try container.decodeIfPresent(
            OrbitalViewportSourceMode.self,
            forKey: .sourceMode
        )
        driveMode = try container.decode(OrbitalViewportVUDriveMode.self, forKey: .driveMode)
        sourceModeWasExplicit = decodedSourceMode != nil
        sourceMode = decodedSourceMode ?? OrbitalViewportSourceMode.legacyMode(for: driveMode)
        cubePreset = try container.decode(OrbitalViewportCubeVUPreset.self, forKey: .cubePreset)
        cubeSettings = try container.decode(OrbitalViewportCubeVUSettings.self, forKey: .cubeSettings)
        activeViewportFramesPerSecond = try container.decode(Int.self, forKey: .activeViewportFramesPerSecond)
        meterOnlyViewportFramesPerSecond = try container.decode(
            Int.self,
            forKey: .meterOnlyViewportFramesPerSecond
        )
        inspectorRefreshFramesPerSecond = try container.decode(
            Int.self,
            forKey: .inspectorRefreshFramesPerSecond
        )
        drawsOnDemand = try container.decode(Bool.self, forKey: .drawsOnDemand)
    }

    func sourceModeForThemeLoad(
        defaultMode: OrbitalViewportSourceMode,
        preferDefaultWhenMissing: Bool
    ) -> OrbitalViewportSourceMode {
        guard preferDefaultWhenMissing, !sourceModeWasExplicit else {
            return sourceMode
        }
        return defaultMode
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
        statusText: "Fake meter stream",
        renderMode: .allMono
    )

    let mode: OrbitalViewportAudioSourceMode
    let hasLoadedAudio: Bool
    let fileName: String?
    let filePath: String?
    let isPlaying: Bool
    let statusText: String
    let renderMode: OrbitalViewportAudioRenderMode?

    init(
        mode: OrbitalViewportAudioSourceMode,
        hasLoadedAudio: Bool,
        fileName: String?,
        filePath: String?,
        isPlaying: Bool,
        statusText: String,
        renderMode: OrbitalViewportAudioRenderMode? = .allMono
    ) {
        self.mode = mode
        self.hasLoadedAudio = hasLoadedAudio
        self.fileName = fileName
        self.filePath = filePath
        self.isPlaying = isPlaying
        self.statusText = statusText
        self.renderMode = renderMode
    }
}

struct OrbitalViewportCameraExportSettings: Codable, Equatable {
    static let `default` = OrbitalViewportCameraExportSettings(
        cameraView: .isometric,
        yaw: OrbitalViewportCameraView.isometric.preset.yaw,
        pitch: OrbitalViewportCameraView.isometric.preset.pitch,
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

    var resolvedOrbitState: OrbitalViewportOrbitState {
        if cameraAdjusted {
            return OrbitalViewportOrbitState(
                view: cameraView,
                yaw: yaw,
                pitch: OrbitalViewportOrbitState.clampedPitch(pitch)
            )
        }
        return OrbitalViewportOrbitState.preset(cameraView)
    }
}

struct OrbitalViewportViewDetailExportSettings: Codable, Equatable {
    static let `default` = OrbitalViewportViewDetailExportSettings(
        speakerSizeSlider: 50,
        speakerSize: OrbitalViewportMath.speakerSize(fromSlider: 50),
        fogDensitySlider: 50,
        fogDensity: OrbitalViewportMath.fogDensity(fromSlider: 50),
        showSpeakerNumbers: false,
        showHiddenLines: false,
        showGridPlane: false,
        gridPlaneVisibilitySlider: OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider
    )

    let speakerSizeSlider: Double
    let speakerSize: Double
    let fogDensitySlider: Double
    let fogDensity: Double
    let showSpeakerNumbers: Bool
    let showHiddenLines: Bool
    let showGridPlane: Bool
    let gridPlaneVisibilitySlider: Double

    init(
        speakerSizeSlider: Double,
        speakerSize: Double,
        fogDensitySlider: Double,
        fogDensity: Double,
        showSpeakerNumbers: Bool,
        showHiddenLines: Bool,
        showGridPlane: Bool = false,
        gridPlaneVisibilitySlider: Double = OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider
    ) {
        self.speakerSizeSlider = speakerSizeSlider
        self.speakerSize = speakerSize
        self.fogDensitySlider = fogDensitySlider
        self.fogDensity = fogDensity
        self.showSpeakerNumbers = showSpeakerNumbers
        self.showHiddenLines = showHiddenLines
        self.showGridPlane = showGridPlane
        self.gridPlaneVisibilitySlider = min(100, max(0, gridPlaneVisibilitySlider))
    }

    enum CodingKeys: String, CodingKey {
        case speakerSizeSlider
        case speakerSize
        case fogDensitySlider
        case fogDensity
        case showSpeakerNumbers
        case showHiddenLines
        case showGridPlane
        case gridPlaneVisibilitySlider
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            speakerSizeSlider: try container.decode(Double.self, forKey: .speakerSizeSlider),
            speakerSize: try container.decode(Double.self, forKey: .speakerSize),
            fogDensitySlider: try container.decode(Double.self, forKey: .fogDensitySlider),
            fogDensity: try container.decode(Double.self, forKey: .fogDensity),
            showSpeakerNumbers: try container.decode(Bool.self, forKey: .showSpeakerNumbers),
            showHiddenLines: try container.decode(Bool.self, forKey: .showHiddenLines),
            showGridPlane: try container.decodeIfPresent(Bool.self, forKey: .showGridPlane) ?? false,
            gridPlaneVisibilitySlider: try container.decodeIfPresent(
                Double.self,
                forKey: .gridPlaneVisibilitySlider
            ) ?? OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider
        )
    }
}

struct OrbitalViewportGroundAppearanceExportSettings: Codable, Equatable {
    static let `default` = OrbitalViewportGroundAppearanceExportSettings(
        showGridPlane: false,
        gridPlaneVisibilitySlider: OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider,
        gridPlaneSpacing: OrbitalViewportGridPlaneGeometry.defaultSpacing,
        gridPlaneRenderStyle: OrbitalViewportMockup.defaultGeodesicRenderStyle,
        gridPlanePaletteFollowsMainTheme: true,
        gridPlaneThickness: OrbitalViewportGridPlaneGeometry.defaultThickness
    )

    let showGridPlane: Bool
    let gridPlaneVisibilitySlider: Double
    let gridPlaneSpacing: Double
    let gridPlaneRenderStyle: OrbitalViewportRenderStyle
    let gridPlanePaletteFollowsMainTheme: Bool
    let gridPlanePaletteFollowsMainThemeWasExplicit: Bool
    let gridPlaneThickness: Double

    init(
        showGridPlane: Bool = false,
        gridPlaneVisibilitySlider: Double = OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider,
        gridPlaneSpacing: Double = OrbitalViewportGridPlaneGeometry.defaultSpacing,
        gridPlaneRenderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultGeodesicRenderStyle,
        gridPlanePaletteFollowsMainTheme: Bool? = nil,
        gridPlaneThickness: Double = OrbitalViewportGridPlaneGeometry.defaultThickness
    ) {
        self.showGridPlane = showGridPlane
        self.gridPlaneVisibilitySlider = min(100, max(0, gridPlaneVisibilitySlider))
        self.gridPlaneSpacing = OrbitalViewportGridPlaneGeometry.normalizedSpacing(gridPlaneSpacing)
        self.gridPlaneRenderStyle = gridPlaneRenderStyle
        self.gridPlanePaletteFollowsMainTheme = gridPlanePaletteFollowsMainTheme ?? false
        self.gridPlanePaletteFollowsMainThemeWasExplicit = gridPlanePaletteFollowsMainTheme != nil
        self.gridPlaneThickness = OrbitalViewportGridPlaneGeometry.normalizedThickness(gridPlaneThickness)
    }

    enum CodingKeys: String, CodingKey {
        case showGridPlane
        case gridPlaneVisibilitySlider
        case gridPlaneSpacing
        case gridPlaneRenderStyle
        case gridPlanePaletteFollowsMainTheme
        case gridPlaneThickness
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(showGridPlane, forKey: .showGridPlane)
        try container.encode(gridPlaneVisibilitySlider, forKey: .gridPlaneVisibilitySlider)
        try container.encode(gridPlaneSpacing, forKey: .gridPlaneSpacing)
        try container.encode(gridPlaneRenderStyle, forKey: .gridPlaneRenderStyle)
        try container.encode(gridPlanePaletteFollowsMainTheme, forKey: .gridPlanePaletteFollowsMainTheme)
        try container.encode(gridPlaneThickness, forKey: .gridPlaneThickness)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            showGridPlane: try container.decodeIfPresent(Bool.self, forKey: .showGridPlane) ?? false,
            gridPlaneVisibilitySlider: try container.decodeIfPresent(
                Double.self,
                forKey: .gridPlaneVisibilitySlider
            ) ?? OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider,
            gridPlaneSpacing: try container.decodeIfPresent(
                Double.self,
                forKey: .gridPlaneSpacing
            ) ?? OrbitalViewportGridPlaneGeometry.defaultSpacing,
            gridPlaneRenderStyle: try container.decodeIfPresent(
                OrbitalViewportRenderStyle.self,
                forKey: .gridPlaneRenderStyle
            ) ?? OrbitalViewportMockup.defaultGeodesicRenderStyle,
            gridPlanePaletteFollowsMainTheme: try container.decodeIfPresent(
                Bool.self,
                forKey: .gridPlanePaletteFollowsMainTheme
            ),
            gridPlaneThickness: try container.decodeIfPresent(
                Double.self,
                forKey: .gridPlaneThickness
            ) ?? OrbitalViewportGridPlaneGeometry.defaultThickness
        )
    }
}

enum OrbitalViewportSettingsJSONExporter {
    static let filePrefix = "Orbital View Settings"

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

struct OrbitalViewportSavedTheme: Identifiable, Equatable {
    let id: String
    let url: URL
    let displayName: String
    let fileName: String
    let themeID: String?
    let payload: OrbitalViewportSettingsExportPayload?

    var isValid: Bool {
        payload != nil
    }

    init(url: URL, payload: OrbitalViewportSettingsExportPayload?) {
        self.id = url.path
        self.url = url
        self.displayName = url.deletingPathExtension().lastPathComponent
        self.fileName = url.lastPathComponent
        self.themeID = payload?.themeID
        self.payload = payload
    }
}

struct OrbitalViewportDefaultThemeMetadata: Codable, Equatable {
    let themeID: String?
    let fileName: String?
}

enum OrbitalViewportViewThemeStoreError: LocalizedError, Equatable {
    case noAvailableThemeNames

    var errorDescription: String? {
        switch self {
        case .noAvailableThemeNames:
            return "No available two-word theme names"
        }
    }
}

enum OrbitalViewportViewThemeStore {
    static let directoryName = "View Themes"
    static let defaultThemeFileName = ".view-theme-default.json"

    private static let firstWords = [
        "Neon",
        "Velvet",
        "Chrome",
        "Midnight",
        "Solar",
        "Lunar",
        "Phantom",
        "Electric",
        "Crystal",
        "Vivid",
        "Radiant",
        "Turbo",
        "Nova",
        "Static",
        "Prism",
        "Quantum"
    ]

    private static let secondWords = [
        "Circuit",
        "Horizon",
        "Beacon",
        "Pulse",
        "Halo",
        "Matrix",
        "Signal",
        "Bloom",
        "Console",
        "Grid",
        "Orbit",
        "Mirage",
        "Vector",
        "Comet",
        "Flux",
        "Satellite"
    ]

    static func defaultResourcesURL(fileManager: FileManager = .default) -> URL {
        if let resourceURL = Bundle.main.resourceURL {
            return resourceURL
        }

        let bundleURL = Bundle.main.bundleURL
        if bundleURL.pathExtension == "app" {
            return bundleURL.appendingPathComponent("Contents/Resources", isDirectory: true)
        }

        return URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
    }

    static func themeDirectoryURL(
        resourcesURL: URL? = nil,
        fileManager: FileManager = .default
    ) throws -> URL {
        let baseURL = resourcesURL ?? defaultResourcesURL(fileManager: fileManager)
        let directoryURL = baseURL.appendingPathComponent(directoryName, isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL
    }

    static func randomThemeStem() -> String {
        let first = firstWords.randomElement() ?? "Neon"
        let second = secondWords.randomElement() ?? "Circuit"
        return "\(first) \(second)"
    }

    static func uniqueThemeFileURL(
        in directoryURL: URL,
        fileManager: FileManager = .default,
        nameProvider: () -> String = randomThemeStem
    ) throws -> URL {
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        for _ in 0..<128 {
            let stem = sanitizedStem(nameProvider())
            let url = directoryURL.appendingPathComponent("\(stem).json", isDirectory: false)
            if !fileManager.fileExists(atPath: url.path) {
                return url
            }
        }

        for firstWord in firstWords {
            for secondWord in secondWords {
                let stem = "\(firstWord) \(secondWord)"
                let url = directoryURL.appendingPathComponent("\(stem).json", isDirectory: false)
                if !fileManager.fileExists(atPath: url.path) {
                    return url
                }
            }
        }

        throw OrbitalViewportViewThemeStoreError.noAvailableThemeNames
    }

    static func writeTheme(
        payload: OrbitalViewportSettingsExportPayload,
        resourcesURL: URL? = nil,
        fileManager: FileManager = .default,
        nameProvider: () -> String = randomThemeStem
    ) throws -> OrbitalViewportSavedTheme {
        let directoryURL = try themeDirectoryURL(resourcesURL: resourcesURL, fileManager: fileManager)
        let url = try uniqueThemeFileURL(in: directoryURL, fileManager: fileManager, nameProvider: nameProvider)
        var themePayload = payload
        if themePayload.themeID == nil {
            themePayload.themeID = UUID().uuidString
        }
        try OrbitalViewportSettingsJSONExporter.jsonData(payload: themePayload).write(to: url, options: .atomic)
        return OrbitalViewportSavedTheme(url: url, payload: themePayload)
    }

    static func savedThemes(
        in directoryURL: URL,
        fileManager: FileManager = .default
    ) throws -> [OrbitalViewportSavedTheme] {
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let urls = try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        let themeURLs = urls
            .filter { $0.pathExtension.lowercased() == "json" && $0.lastPathComponent != defaultThemeFileName }
            .sorted { lhs, rhs in
                let lhsDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                let rhsDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                if lhsDate == rhsDate {
                    return lhs.lastPathComponent.localizedCaseInsensitiveCompare(rhs.lastPathComponent) == .orderedAscending
                }
                return lhsDate > rhsDate
            }

        return themeURLs.map { url in
            let payload = (try? Data(contentsOf: url))
                .flatMap { try? JSONDecoder().decode(OrbitalViewportSettingsExportPayload.self, from: $0) }
            return OrbitalViewportSavedTheme(url: url, payload: payload)
        }
    }

    static func writeDefaultTheme(
        _ theme: OrbitalViewportSavedTheme,
        fileManager: FileManager = .default
    ) throws -> OrbitalViewportDefaultThemeMetadata {
        let directoryURL = theme.url.deletingLastPathComponent()
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let metadata = OrbitalViewportDefaultThemeMetadata(
            themeID: theme.themeID,
            fileName: theme.fileName
        )
        let data = try JSONEncoder().encode(metadata)
        try data.write(to: defaultThemeURL(in: directoryURL), options: .atomic)
        return metadata
    }

    static func readDefaultTheme(in directoryURL: URL) throws -> OrbitalViewportDefaultThemeMetadata {
        let data = try Data(contentsOf: defaultThemeURL(in: directoryURL))
        return try JSONDecoder().decode(OrbitalViewportDefaultThemeMetadata.self, from: data)
    }

    static func defaultTheme(
        in themes: [OrbitalViewportSavedTheme],
        metadata: OrbitalViewportDefaultThemeMetadata?
    ) -> OrbitalViewportSavedTheme? {
        guard let metadata else {
            return nil
        }
        if let themeID = metadata.themeID,
           let match = themes.first(where: { $0.themeID == themeID && $0.isValid }) {
            return match
        }
        if let fileName = metadata.fileName,
           let match = themes.first(where: { $0.fileName == fileName && $0.isValid }) {
            return match
        }
        return nil
    }

    static func isDefaultTheme(
        _ theme: OrbitalViewportSavedTheme,
        metadata: OrbitalViewportDefaultThemeMetadata?
    ) -> Bool {
        guard let metadata else {
            return false
        }
        if let themeID = metadata.themeID,
           let entryThemeID = theme.themeID {
            return themeID == entryThemeID
        }
        return metadata.fileName == theme.fileName
    }

    static func defaultThemeURL(in directoryURL: URL) -> URL {
        directoryURL.appendingPathComponent(defaultThemeFileName, isDirectory: false)
    }

    private static func sanitizedStem(_ rawStem: String) -> String {
        let illegal = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        let replaced = rawStem.unicodeScalars.map { scalar -> String in
            illegal.contains(scalar) ? " " : String(scalar)
        }.joined()
        let collapsed = replaced
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        return collapsed.isEmpty ? randomThemeStem() : collapsed
    }
}

enum OrbitalViewportSavedResourceHelper {
    static func defaultResourcesURL(fileManager: FileManager = .default) -> URL {
        OrbitalViewportViewThemeStore.defaultResourcesURL(fileManager: fileManager)
    }

    static func resourceDirectoryURL(
        directoryName: String,
        resourcesURL: URL? = nil,
        fileManager: FileManager = .default
    ) throws -> URL {
        let baseURL = resourcesURL ?? defaultResourcesURL(fileManager: fileManager)
        let directoryURL = baseURL.appendingPathComponent(directoryName, isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL
    }

    static func sortedResourceURLs(
        in directoryURL: URL,
        extensions: Set<String>,
        excluding fileNames: Set<String> = [],
        fileManager: FileManager = .default
    ) throws -> [URL] {
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        .filter { extensions.contains($0.pathExtension.lowercased()) && !fileNames.contains($0.lastPathComponent) }
        .sorted { lhs, rhs in
            let lhsDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let rhsDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            if lhsDate == rhsDate {
                return lhs.lastPathComponent.localizedCaseInsensitiveCompare(rhs.lastPathComponent) == .orderedAscending
            }
            return lhsDate > rhsDate
        }
    }

    static func sanitizedStem(_ rawStem: String, fallback: String) -> String {
        let illegal = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        let replaced = rawStem.unicodeScalars.map { scalar -> String in
            illegal.contains(scalar) ? " " : String(scalar)
        }.joined()
        let collapsed = replaced
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        return collapsed.isEmpty ? fallback : collapsed
    }

    static func uniqueFileURL(
        in directoryURL: URL,
        fileExtension: String,
        fileManager: FileManager = .default,
        fallbackStems: [String] = [],
        nameProvider: () -> String
    ) throws -> URL {
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        for _ in 0..<128 {
            let stem = sanitizedStem(nameProvider(), fallback: fallbackStems.first ?? "Layout")
            let url = directoryURL.appendingPathComponent("\(stem).\(fileExtension)", isDirectory: false)
            if !fileManager.fileExists(atPath: url.path) {
                return url
            }
        }

        for stem in fallbackStems {
            let sanitized = sanitizedStem(stem, fallback: "Layout")
            let url = directoryURL.appendingPathComponent("\(sanitized).\(fileExtension)", isDirectory: false)
            if !fileManager.fileExists(atPath: url.path) {
                return url
            }
        }

        throw OrbitalViewportViewThemeStoreError.noAvailableThemeNames
    }
}

struct OrbitalViewportSavedSpatGRISLayout: Identifiable, Equatable {
    let id: String
    let url: URL
    let displayName: String
    let fileName: String
    let layoutID: String?
    let setup: SpatGRISSpeakerSetup?

    var isValid: Bool {
        setup != nil
    }

    init(url: URL, setup: SpatGRISSpeakerSetup?) {
        self.id = url.path
        self.url = url
        self.displayName = url.deletingPathExtension().lastPathComponent
        self.fileName = url.lastPathComponent
        self.layoutID = setup?.uuid
        self.setup = setup
    }
}

struct OrbitalViewportDefaultSpatGRISLayoutMetadata: Codable, Equatable {
    let layoutID: String?
    let fileName: String?
}

enum OrbitalViewportSpatGRISLayoutStore {
    enum Kind: Equatable {
        case speakers
        case sources

        var directoryName: String {
            switch self {
            case .speakers:
                return "Speaker Layouts"
            case .sources:
                return "Source Layouts"
            }
        }

        var defaultFileName: String {
            switch self {
            case .speakers:
                return ".speaker-layout-default.json"
            case .sources:
                return ".source-layout-default.json"
            }
        }

        var displayName: String {
            switch self {
            case .speakers:
                return "Speaker"
            case .sources:
                return "Source"
            }
        }

        var emptyListTitle: String {
            switch self {
            case .speakers:
                return "No saved speakers"
            case .sources:
                return "No saved sources"
            }
        }

        var fallbackStems: [String] {
            switch self {
            case .speakers:
                return ["SpatGRIS Speakers", "Receiver Layout", "Speaker Setup"]
            case .sources:
                return ["SpatGRIS Sources", "Source Layout", "Source Setup"]
            }
        }
    }

    static func layoutDirectoryURL(
        kind: Kind,
        resourcesURL: URL? = nil,
        fileManager: FileManager = .default
    ) throws -> URL {
        try OrbitalViewportSavedResourceHelper.resourceDirectoryURL(
            directoryName: kind.directoryName,
            resourcesURL: resourcesURL,
            fileManager: fileManager
        )
    }

    static func uniqueLayoutFileURL(
        kind: Kind,
        in directoryURL: URL,
        fileManager: FileManager = .default,
        nameProvider: () -> String
    ) throws -> URL {
        try OrbitalViewportSavedResourceHelper.uniqueFileURL(
            in: directoryURL,
            fileExtension: "xml",
            fileManager: fileManager,
            fallbackStems: kind.fallbackStems,
            nameProvider: nameProvider
        )
    }

    static func writeLayout(
        setup: SpatGRISSpeakerSetup,
        kind: Kind,
        resourcesURL: URL? = nil,
        fileManager: FileManager = .default,
        nameProvider: (() -> String)? = nil
    ) throws -> OrbitalViewportSavedSpatGRISLayout {
        let directoryURL = try layoutDirectoryURL(kind: kind, resourcesURL: resourcesURL, fileManager: fileManager)
        let url = try uniqueLayoutFileURL(
            kind: kind,
            in: directoryURL,
            fileManager: fileManager,
            nameProvider: nameProvider ?? { "\(kind.displayName) \(OrbitalViewportViewThemeStore.randomThemeStem())" }
        )
        guard let data = SpatGRISXML.exportSpeakerSetup(setup).data(using: .utf8) else {
            throw SpatGRISLayoutError.malformedXML("export encoding failed")
        }
        try data.write(to: url, options: .atomic)
        return OrbitalViewportSavedSpatGRISLayout(url: url, setup: setup)
    }

    static func importLayout(
        from sourceURL: URL,
        kind: Kind,
        resourcesURL: URL? = nil,
        fileManager: FileManager = .default
    ) throws -> OrbitalViewportSavedSpatGRISLayout {
        let setup = try SpatGRISXML.parseSpeakerSetup(from: sourceURL)
        return try writeLayout(
            setup: setup,
            kind: kind,
            resourcesURL: resourcesURL,
            fileManager: fileManager,
            nameProvider: { sourceURL.deletingPathExtension().lastPathComponent }
        )
    }

    static func savedLayouts(
        in directoryURL: URL,
        fileManager: FileManager = .default
    ) throws -> [OrbitalViewportSavedSpatGRISLayout] {
        try OrbitalViewportSavedResourceHelper.sortedResourceURLs(
            in: directoryURL,
            extensions: ["xml"],
            fileManager: fileManager
        ).map { url in
            let setup = (try? Data(contentsOf: url)).flatMap { try? SpatGRISXML.parseSpeakerSetup(data: $0) }
            return OrbitalViewportSavedSpatGRISLayout(url: url, setup: setup)
        }
    }

    static func writeDefaultLayout(
        _ layout: OrbitalViewportSavedSpatGRISLayout,
        kind: Kind,
        fileManager: FileManager = .default
    ) throws -> OrbitalViewportDefaultSpatGRISLayoutMetadata {
        let directoryURL = layout.url.deletingLastPathComponent()
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let metadata = OrbitalViewportDefaultSpatGRISLayoutMetadata(
            layoutID: layout.layoutID,
            fileName: layout.fileName
        )
        let data = try JSONEncoder().encode(metadata)
        try data.write(to: defaultLayoutURL(kind: kind, in: directoryURL), options: .atomic)
        return metadata
    }

    static func readDefaultLayout(
        kind: Kind,
        in directoryURL: URL
    ) throws -> OrbitalViewportDefaultSpatGRISLayoutMetadata {
        let data = try Data(contentsOf: defaultLayoutURL(kind: kind, in: directoryURL))
        return try JSONDecoder().decode(OrbitalViewportDefaultSpatGRISLayoutMetadata.self, from: data)
    }

    static func defaultLayout(
        in layouts: [OrbitalViewportSavedSpatGRISLayout],
        metadata: OrbitalViewportDefaultSpatGRISLayoutMetadata?
    ) -> OrbitalViewportSavedSpatGRISLayout? {
        guard let metadata else {
            return nil
        }
        if let layoutID = metadata.layoutID,
           let match = layouts.first(where: { $0.layoutID == layoutID && $0.isValid }) {
            return match
        }
        if let fileName = metadata.fileName,
           let match = layouts.first(where: { $0.fileName == fileName && $0.isValid }) {
            return match
        }
        return nil
    }

    static func isDefaultLayout(
        _ layout: OrbitalViewportSavedSpatGRISLayout,
        metadata: OrbitalViewportDefaultSpatGRISLayoutMetadata?
    ) -> Bool {
        guard let metadata else {
            return false
        }
        if let layoutID = metadata.layoutID,
           let entryLayoutID = layout.layoutID {
            return layoutID == entryLayoutID
        }
        return metadata.fileName == layout.fileName
    }

    static func defaultLayoutURL(kind: Kind, in directoryURL: URL) -> URL {
        directoryURL.appendingPathComponent(kind.defaultFileName, isDirectory: false)
    }

    static func referenceSpeakerSetup() throws -> SpatGRISSpeakerSetup {
        try SpatGRISSpeakerSetup(
            spatMode: .dome,
            speakers: OrbitalViewportSpeaker.referenceSpeakers.map { speaker in
                try SpatGRISSpeaker(
                    patchID: speaker.channel,
                    position: try OrbitalViewVector3(x: speaker.x, y: speaker.y, z: speaker.z)
                )
            }
        )
    }

    static func sourceSetup(from sources: [OrbitalViewportSourceMarker]) throws -> SpatGRISSpeakerSetup {
        try SpatGRISSpeakerSetup(
            spatMode: .cube,
            speakers: sources.map { source in
                try SpatGRISSpeaker(
                    patchID: source.sourceID,
                    state: source.state,
                    directOutOnly: source.isDirectOut,
                    position: source.position.coreVector
                )
            }
        )
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
        switch self {
        case .plan:
            return (0, Double.pi / 2)
        case .elevation:
            return (0, 0)
        case .isometric:
            return (Double.pi / 4, asin(1 / sqrt(3)))
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

#if os(macOS)
private struct OrbitalViewportResolvedColor {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    init(_ color: Color) {
        let nsColor = NSColor(color)
        let resolved = nsColor.usingColorSpace(.deviceRGB) ?? nsColor
        self.red = resolved.redComponent
        self.green = resolved.greenComponent
        self.blue = resolved.blueComponent
        self.alpha = resolved.alphaComponent
    }

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    var nsColor: NSColor {
        NSColor(deviceRed: red, green: green, blue: blue, alpha: alpha)
    }

    func interpolated(to other: OrbitalViewportResolvedColor, amount: Double) -> OrbitalViewportResolvedColor {
        let t = CGFloat(OrbitalViewportMath.clamp01(amount))
        return OrbitalViewportResolvedColor(
            red: red + (other.red - red) * t,
            green: green + (other.green - green) * t,
            blue: blue + (other.blue - blue) * t,
            alpha: alpha + (other.alpha - alpha) * t
        )
    }
}

private struct OrbitalViewportResolvedVURampStop {
    let position: Double
    let color: OrbitalViewportResolvedColor
}

private struct OrbitalViewportResolvedVUPalette {
    let danger: OrbitalViewportResolvedColor
    let ramp: [OrbitalViewportResolvedVURampStop]

    init(palette: OrbitalViewportPalette) {
        self.danger = OrbitalViewportResolvedColor(palette.danger)
        self.ramp = palette.vuRamp
            .sorted { $0.position < $1.position }
            .map {
                OrbitalViewportResolvedVURampStop(
                    position: $0.position,
                    color: OrbitalViewportResolvedColor($0.color)
                )
            }
    }

    func vuColor(for level: Double) -> NSColor {
        let normalized = OrbitalViewportMath.clamp01(level)
        guard let first = ramp.first else {
            return danger.nsColor
        }

        var lower = first
        var upper = first
        for stop in ramp {
            if stop.position <= normalized {
                lower = stop
            }
            if stop.position >= normalized {
                upper = stop
                break
            }
        }

        let span = max(upper.position - lower.position, 0.000_001)
        return lower.color
            .interpolated(to: upper.color, amount: (normalized - lower.position) / span)
            .nsColor
    }
}
#endif

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

enum OrbitalViewportSpeakerLabelFontGroup: String, CaseIterable, Identifiable, Equatable {
    case normie
    case nerd
    case nostromo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .normie:
            return "Normie"
        case .nerd:
            return "Nerd"
        case .nostromo:
            return "Nostromo"
        }
    }
}

enum OrbitalViewportSpeakerLabelFont: String, CaseIterable, Identifiable, Equatable, Codable {
    case systemDefault
    case helveticaBlack
    case futura
    case pressStart2P
    case minecraft
    case chintzyCPU
    case archivoBlack
    case jost
    case michroma
    case sevastopolInterface

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .systemDefault
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    static func fonts(in group: OrbitalViewportSpeakerLabelFontGroup) -> [OrbitalViewportSpeakerLabelFont] {
        allCases.filter { $0.group == group }
    }

    var group: OrbitalViewportSpeakerLabelFontGroup {
        switch self {
        case .systemDefault, .helveticaBlack, .futura:
            return .normie
        case .pressStart2P, .minecraft, .chintzyCPU:
            return .nerd
        case .archivoBlack, .jost, .michroma, .sevastopolInterface:
            return .nostromo
        }
    }

    var title: String {
        switch self {
        case .systemDefault:
            return "System Default"
        case .pressStart2P:
            return "Press Start 2P"
        case .minecraft:
            return "Minecraft"
        case .chintzyCPU:
            return "Chintzy CPU BRK"
        case .archivoBlack:
            return "Archivo Black"
        case .jost:
            return "Jost"
        case .michroma:
            return "Michroma"
        case .sevastopolInterface:
            return "Sevastopol Interface"
        case .helveticaBlack:
            return "Helvetica Black"
        case .futura:
            return "Futura"
        }
    }

    var sourceNote: String {
        switch self {
        case .systemDefault:
            return "Current native label font"
        case .pressStart2P:
            return "Google Fonts / SIL OFL"
        case .minecraft:
            return "Craftron Gaming / DaFont 100% Free"
        case .chintzyCPU:
            return "AEnigma / DaFont 100% Free"
        case .archivoBlack:
            return "Helvetica Black-ish / Google OFL"
        case .jost:
            return "Futura-ish / Google OFL"
        case .michroma:
            return "Microgramma-ish / Google OFL"
        case .sevastopolInterface:
            return "Alien: Isolation-inspired / DaFont 100% Free"
        case .helveticaBlack:
            return "Alien title-like / commercial local font"
        case .futura:
            return "Alien title candidate / commercial local font"
        }
    }

    var resourceFileNames: [String] {
        switch self {
        case .systemDefault, .helveticaBlack, .futura:
            return []
        case .pressStart2P:
            return ["PressStart2P-Regular.ttf"]
        case .minecraft:
            return ["Minecraft.ttf"]
        case .chintzyCPU:
            return ["chintzy.ttf", "chintzys.ttf"]
        case .archivoBlack:
            return ["ArchivoBlack-Regular.ttf"]
        case .jost:
            return ["Jost-Regular.ttf"]
        case .michroma:
            return ["Michroma-Regular.ttf"]
        case .sevastopolInterface:
            return ["Sevastopol-Interface.ttf"]
        }
    }

    var postScriptNameCandidates: [String] {
        switch self {
        case .systemDefault:
            return []
        case .pressStart2P:
            return ["PressStart2P-Regular", "Press Start 2P Regular"]
        case .minecraft:
            return ["Minecraft"]
        case .chintzyCPU:
            return ["ChintzyCPUBRK", "Chintzy CPU BRK"]
        case .archivoBlack:
            return ["ArchivoBlack-Regular", "Archivo Black Regular"]
        case .jost:
            return ["Jost-Regular", "JostRoman-Regular", "Jost"]
        case .michroma:
            return ["Michroma-Regular", "Michroma"]
        case .sevastopolInterface:
            return ["Sevastopol-Interface", "Sevastopol Interface Regular", "SevastopolInterface-Regular"]
        case .helveticaBlack:
            return ["Helvetica-Black", "HelveticaPro-Black", "HelveticaNeue-Black"]
        case .futura:
            return ["Futura-Medium", "FuturaPT-Book", "FuturaBT-Book", "Futura"]
        }
    }

    func speakerLabelText(channel: Int) -> String {
        let label = String(format: "%02d", channel)
        switch self {
        case .minecraft:
            return label.replacingOccurrences(of: "0", with: "O")
        case .systemDefault, .pressStart2P, .chintzyCPU, .archivoBlack, .jost, .michroma, .sevastopolInterface, .helveticaBlack, .futura:
            return label
        }
    }

    var sceneKitTextFlatness: CGFloat {
        switch self {
        case .jost:
            return 0.025
        case .systemDefault, .pressStart2P, .minecraft, .chintzyCPU, .archivoBlack, .michroma, .sevastopolInterface, .helveticaBlack, .futura:
            return 0.18
        }
    }

    var usesTextureBackedSceneKitLabel: Bool {
        switch self {
        case .jost:
            return true
        case .systemDefault, .pressStart2P, .minecraft, .chintzyCPU, .archivoBlack, .michroma, .sevastopolInterface, .helveticaBlack, .futura:
            return false
        }
    }

    #if os(macOS)
    func nsFont(pointSize: CGFloat) -> NSFont {
        switch self {
        case .systemDefault:
            return NSFont.systemFont(ofSize: pointSize, weight: .semibold)
        case .pressStart2P, .minecraft, .chintzyCPU, .archivoBlack, .jost, .michroma, .sevastopolInterface, .helveticaBlack, .futura:
            return resolvedCustomFont(pointSize: pointSize) ?? NSFont.systemFont(ofSize: pointSize, weight: .semibold)
        }
    }

    var availabilityNote: String {
        switch self {
        case .systemDefault:
            return "Built in"
        case .pressStart2P, .minecraft, .chintzyCPU, .archivoBlack, .jost, .michroma, .sevastopolInterface:
            return "Bundled offline"
        case .helveticaBlack, .futura:
            return isInstalled ? "Installed" : "Not installed - uses System Default"
        }
    }

    private var isInstalled: Bool {
        resolvedCustomFont(pointSize: 12) != nil
    }

    private func resolvedCustomFont(pointSize: CGFloat) -> NSFont? {
        OrbitalViewportFontRegistry.registerFontsIfNeeded()
        for name in postScriptNameCandidates {
            if let font = NSFont(name: name, size: pointSize) {
                return font
            }
        }
        return nil
    }
    #endif
}

#if os(macOS)
enum OrbitalViewportFontRegistry {
    private static var registered = false
    private static let resourceFileNames = OrbitalViewportSpeakerLabelFont.allCases.flatMap(\.resourceFileNames)

    static func registerFontsIfNeeded() {
        guard !registered else {
            return
        }
        registered = true

        for fileName in resourceFileNames {
            guard let url = resourceURL(fileName: fileName) else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func resourceURL(fileName: String) -> URL? {
        for baseURL in appBundleResourceBaseURLs() {
            if let url = resourceURL(fileName: fileName, baseURL: baseURL) {
                return url
            }
        }

        for baseURL in moduleResourceBaseURLs() {
            if let url = resourceURL(fileName: fileName, baseURL: baseURL) {
                return url
            }
        }

        return nil
    }

    static func resourceURL(fileName: String, baseURL: URL) -> URL? {
        let fileName = URL(fileURLWithPath: fileName).lastPathComponent
        let candidates = [
            baseURL.appendingPathComponent("Fonts", isDirectory: true).appendingPathComponent(fileName),
            baseURL.appendingPathComponent(fileName)
        ]
        return candidates.first { FileManager.default.fileExists(atPath: $0.path) }
    }

    private static func appBundleResourceBaseURLs() -> [URL] {
        guard let resourceURL = Bundle.main.resourceURL else {
            return []
        }
        return [
            resourceURL.appendingPathComponent("OrbitalView_OrbitalViewReview.bundle", isDirectory: true),
            resourceURL.appendingPathComponent("OrbitalViewKit_OrbitalViewReview.bundle", isDirectory: true),
            resourceURL
        ]
    }

    private static func moduleResourceBaseURLs() -> [URL] {
        [
            Bundle.module.resourceURL,
            Bundle.module.bundleURL
        ].compactMap { $0 }
    }
}
#endif

enum OrbitalViewportImpulseKind: String, CaseIterable, Identifiable, Equatable, Codable {
    case ripple
    case waves
    case orbitingComets

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ripple:
            return "Ripple"
        case .waves:
            return "Waves"
        case .orbitingComets:
            return "Orbiting Comets"
        }
    }
}

enum OrbitalViewportAudioRenderMode: String, CaseIterable, Identifiable, Equatable, Codable {
    case allMono
    case exciteRipple
    case exciteWaves
    case exciteOrbitingComets

    var id: String { rawValue }

    var title: String {
        switch self {
        case .allMono:
            return "All Mono"
        case .exciteRipple:
            return "Excite Ripple"
        case .exciteWaves:
            return "Excite Waves"
        case .exciteOrbitingComets:
            return "Excite Comets"
        }
    }

    var impulseKind: OrbitalViewportImpulseKind? {
        switch self {
        case .allMono:
            return nil
        case .exciteRipple:
            return .ripple
        case .exciteWaves:
            return .waves
        case .exciteOrbitingComets:
            return .orbitingComets
        }
    }
}

enum OrbitalViewportVUDriveMode: String, CaseIterable, Identifiable, Equatable, Codable {
    case music
    case impulseRipple = "impulseTest"
    case impulseWaves
    case impulseOrbitingComets

    static let impulseCases: [OrbitalViewportVUDriveMode] = [
        .impulseRipple,
        .impulseWaves,
        .impulseOrbitingComets
    ]

    var id: String { rawValue }

    var title: String {
        switch self {
        case .music:
            return "Music"
        case .impulseRipple:
            return "Impulse Test Ripple"
        case .impulseWaves:
            return "Impulse Test Waves"
        case .impulseOrbitingComets:
            return "Impulse Test Orbiting Comets"
        }
    }

    var statusTitle: String {
        switch self {
        case .music:
            return "Music source"
        case .impulseRipple:
            return "Impulse ripple"
        case .impulseWaves:
            return "Impulse waves"
        case .impulseOrbitingComets:
            return "Impulse orbiting comets"
        }
    }

    var impulseTitle: String {
        switch self {
        case .music:
            return "Ripple"
        case .impulseRipple:
            return "Ripple"
        case .impulseWaves:
            return "Waves"
        case .impulseOrbitingComets:
            return "Orbiting Comets"
        }
    }

    var impulseKind: OrbitalViewportImpulseKind? {
        switch self {
        case .music:
            return nil
        case .impulseRipple:
            return .ripple
        case .impulseWaves:
            return .waves
        case .impulseOrbitingComets:
            return .orbitingComets
        }
    }

    var isImpulse: Bool {
        self != .music
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
            speakerZScale: 1,
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

struct OrbitalViewportGlobalDiceRoll: Equatable {
    let cameraView: OrbitalViewportCameraView
    let yaw: Double
    let pitch: Double
    let zoom: Double
    let spin: Bool
    let speakerSizeSlider: Double
    let fogDensitySlider: Double
    let showSpeakerNumbers: Bool
    let showHiddenLines: Bool
    let renderStyle: OrbitalViewportRenderStyle
    let sourceSpeakerRenderStyle: OrbitalViewportRenderStyle
    let showRibbedSpeakerSphere: Bool
    let ribbedSphereThickness: Double
    let ribbedSphereVerticalRibs: Int
    let ribbedSphereHorizontalRings: Int
    let geodesicRenderStyle: OrbitalViewportRenderStyle
    let geodesicPaletteFollowsMainTheme: Bool
    let geodesicSaturation: Double
    let gridPlaneRenderStyle: OrbitalViewportRenderStyle
    let gridPlanePaletteFollowsMainTheme: Bool
    let showGridPlane: Bool
    let gridPlaneVisibilitySlider: Double
    let gridPlaneSpacing: Double
    let gridPlaneThickness: Double
    let speakerShape: OrbitalViewportSpeakerShape
    let speakerLabelFont: OrbitalViewportSpeakerLabelFont
    let speakerLabelFontSizeSlider: Double
    let cubePreset: OrbitalViewportCubeVUPreset
    let cubeSettings: OrbitalViewportCubeVUSettings
    let viewportFrameRate: OrbitalViewportFrameRate
}

enum OrbitalViewportDiceRandomizer {
    static func globalViewRoll<R: RandomNumberGenerator>(
        currentBloomPreset: OrbitalViewportCubeVUPreset,
        currentShowRibbedSpeakerSphere: Bool = OrbitalViewportMockup.defaultShowRibbedSpeakerSphere,
        currentRibbedSphereThickness: Double = OrbitalViewportMockup.defaultRibbedSphereThickness,
        currentRibbedSphereVerticalRibs: Int = OrbitalViewportMockup.defaultRibbedSphereVerticalRibs,
        currentRibbedSphereHorizontalRings: Int = OrbitalViewportMockup.defaultRibbedSphereHorizontalRings,
        currentGeodesicRenderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultGeodesicRenderStyle,
        currentGeodesicSaturation: Double = OrbitalViewportMockup.defaultGeodesicSaturation,
        using generator: inout R
    ) -> OrbitalViewportGlobalDiceRoll {
        let cubePreset = randomBloomPreset(current: currentBloomPreset, using: &generator)
        var cubeSettings = randomizedCubeSurfaceSettings(from: cubePreset.settings, using: &generator)
        cubeSettings = randomizedMeterResponseSettings(from: cubeSettings, using: &generator)
        cubeSettings.cubeOutlineStrength = Double.random(in: 0...1, using: &generator)
        cubeSettings.speakerHeight = 1
        let renderStyle = OrbitalViewportRenderStyle.allCases.randomElement(using: &generator) ?? OrbitalViewportMockup.defaultRenderStyle
        let geodesicPaletteFollowsMainTheme = Bool.random(using: &generator)
        let geodesicRenderStyle = geodesicPaletteFollowsMainTheme
            ? renderStyle
            : randomRenderStyle(
                excluding: currentGeodesicRenderStyle,
                using: &generator
            )
        let geodesicSaturation = randomSaturation(
            excluding: currentGeodesicSaturation,
            using: &generator
        )
        let gridPlanePaletteFollowsMainTheme = Bool.random(using: &generator)
        let gridPlaneRenderStyle = gridPlanePaletteFollowsMainTheme
            ? renderStyle
            : (
                OrbitalViewportRenderStyle.allCases.randomElement(using: &generator)
                    ?? OrbitalViewportMockup.defaultGeodesicRenderStyle
            )
        let ribbedSphereThickness = randomThickness(
            excluding: currentRibbedSphereThickness,
            using: &generator
        )
        let ribbedSphereVerticalRibs = randomInteger(
            in: OrbitalViewportRibbedSpeakerSphereGeometry.verticalRibRange,
            excluding: currentRibbedSphereVerticalRibs,
            using: &generator
        )
        let ribbedSphereHorizontalRings = randomInteger(
            in: OrbitalViewportRibbedSpeakerSphereGeometry.horizontalRingRange,
            excluding: currentRibbedSphereHorizontalRings,
            using: &generator
        )

        return OrbitalViewportGlobalDiceRoll(
            cameraView: OrbitalViewportCameraView.allCases.randomElement(using: &generator) ?? .isometric,
            yaw: Double.random(in: -Double.pi...Double.pi, using: &generator),
            pitch: Double.random(in: -OrbitalViewportOrbitState.maxPitch...OrbitalViewportOrbitState.maxPitch, using: &generator),
            zoom: Double.random(in: 0.62...1.75, using: &generator),
            spin: Bool.random(using: &generator),
            speakerSizeSlider: Double.random(in: 0...100, using: &generator),
            fogDensitySlider: Double.random(in: 0...100, using: &generator),
            showSpeakerNumbers: Bool.random(using: &generator),
            showHiddenLines: Bool.random(using: &generator),
            renderStyle: renderStyle,
            sourceSpeakerRenderStyle: renderStyle,
            showRibbedSpeakerSphere: true,
            ribbedSphereThickness: ribbedSphereThickness,
            ribbedSphereVerticalRibs: ribbedSphereVerticalRibs,
            ribbedSphereHorizontalRings: ribbedSphereHorizontalRings,
            geodesicRenderStyle: geodesicRenderStyle,
            geodesicPaletteFollowsMainTheme: geodesicPaletteFollowsMainTheme,
            geodesicSaturation: geodesicSaturation,
            gridPlaneRenderStyle: gridPlaneRenderStyle,
            gridPlanePaletteFollowsMainTheme: gridPlanePaletteFollowsMainTheme,
            showGridPlane: Bool.random(using: &generator),
            gridPlaneVisibilitySlider: Double.random(in: 0...100, using: &generator),
            gridPlaneSpacing: Double.random(in: OrbitalViewportGridPlaneGeometry.spacingRange, using: &generator),
            gridPlaneThickness: Double.random(in: OrbitalViewportGridPlaneGeometry.thicknessRange, using: &generator),
            speakerShape: OrbitalViewportSpeakerShape.allCases.randomElement(using: &generator) ?? OrbitalViewportMockup.defaultSpeakerShape,
            speakerLabelFont: OrbitalViewportSpeakerLabelFont.allCases.randomElement(using: &generator) ?? .systemDefault,
            speakerLabelFontSizeSlider: Double.random(in: 0...100, using: &generator),
            cubePreset: cubePreset,
            cubeSettings: cubeSettings,
            viewportFrameRate: OrbitalViewportFrameRate.allCases.randomElement(using: &generator) ?? OrbitalViewportMockup.defaultViewportFrameRate
        )
    }

    private static func randomRenderStyle<R: RandomNumberGenerator>(
        excluding current: OrbitalViewportRenderStyle,
        using generator: inout R
    ) -> OrbitalViewportRenderStyle {
        let candidates = OrbitalViewportRenderStyle.allCases.filter { $0 != current }
        return candidates.randomElement(using: &generator)
            ?? OrbitalViewportMockup.defaultGeodesicRenderStyle
    }

    private static func randomSaturation<R: RandomNumberGenerator>(
        excluding current: Double,
        using generator: inout R
    ) -> Double {
        let clampedCurrent = OrbitalViewportMath.clamp01(current)
        let candidate = Double.random(in: 0...1, using: &generator)
        if abs(candidate - clampedCurrent) >= 0.08 {
            return candidate
        }
        return (clampedCurrent + 0.43).truncatingRemainder(dividingBy: 1)
    }

    private static func randomThickness<R: RandomNumberGenerator>(
        excluding current: Double,
        using generator: inout R
    ) -> Double {
        let range = OrbitalViewportRibbedSpeakerSphereGeometry.thicknessRange
        let clampedCurrent = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedThickness(current)
        let candidate = Double.random(in: range, using: &generator)
        if abs(candidate - clampedCurrent) >= 0.08 {
            return candidate
        }
        let shifted = clampedCurrent + 0.65
        if shifted <= range.upperBound {
            return shifted
        }
        return max(range.lowerBound, shifted - (range.upperBound - range.lowerBound))
    }

    private static func randomInteger<R: RandomNumberGenerator>(
        in range: ClosedRange<Int>,
        excluding current: Int,
        using generator: inout R
    ) -> Int {
        let candidate = Int.random(in: range, using: &generator)
        guard candidate == current, range.lowerBound < range.upperBound else {
            return candidate
        }
        return candidate == range.upperBound ? range.lowerBound : candidate + 1
    }

    static func randomizedCubeSurfaceSettings<R: RandomNumberGenerator>(
        from settings: OrbitalViewportCubeVUSettings,
        using generator: inout R
    ) -> OrbitalViewportCubeVUSettings {
        var randomized = settings
        let bloomMin = Double.random(in: 0...0.26, using: &generator)
        randomized.bloomMin = bloomMin
        randomized.bloomMax = Double.random(in: min(1, bloomMin + 0.28)...1, using: &generator)
        randomized.bloomEdge = Double.random(in: 0.025...0.38, using: &generator)
        randomized.rimHaloEdge = Double.random(in: 0...1, using: &generator)
        randomized.responseCurve = Double.random(in: 0.35...2.2, using: &generator)
        randomized.facePixels = Int.random(in: 6...14, using: &generator)
        randomized.pixelFill = Double.random(in: 0.55...1, using: &generator)
        randomized.idleTint = Double.random(in: 0...0.35, using: &generator)
        randomized.surfaceCheckerOpacity = Double.random(in: 0...0.75, using: &generator)
        randomized.checkerContrast = Double.random(in: 0...0.28, using: &generator)
        randomized.speakerHeight = 1
        return randomized
    }

    static func randomizedMeterResponseSettings<R: RandomNumberGenerator>(
        from settings: OrbitalViewportCubeVUSettings,
        using generator: inout R
    ) -> OrbitalViewportCubeVUSettings {
        var randomized = settings
        randomized.inputCalibration = Double.random(in: 0.5...1.65, using: &generator)
        randomized.levelCompression = Double.random(in: 1...2.7, using: &generator)
        randomized.displayCeiling = Double.random(in: 0.72...1, using: &generator)
        randomized.hotResponse = Double.random(in: 1.1...3, using: &generator)
        randomized.hotThreshold = Double.random(in: 0.42...0.84, using: &generator)
        randomized.hotFillStrength = Double.random(in: 0.45...1, using: &generator)
        randomized.paletteDrive = Double.random(in: 1...3.4, using: &generator)
        randomized.speakerHeight = 1
        return randomized
    }

    static func randomBloomPreset<R: RandomNumberGenerator>(
        current: OrbitalViewportCubeVUPreset,
        using generator: inout R
    ) -> OrbitalViewportCubeVUPreset {
        let options = OrbitalViewportCubeVUPreset.allCases.filter { $0 != current }
        return options.randomElement(using: &generator) ?? current
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

    private struct MaterialUniformState: Equatable {
        var emissionIntensity: CGFloat
        var transparency: CGFloat
        var displayVuScalar: Double
        var hotScalar: Double
        var clipState: Double
        var bloomMin: Double
        var bloomMax: Double
        var bloomEdge: Double
        var rimHaloEdge: Double
        var responseCurve: Double
        var idleTint: Double
        var checkerContrast: Double
        var hotFillStrength: Double
        var hotThreshold: Double
        var facePixels: Double
        var alphaValue: Double

        init(
            settings: OrbitalViewportCubeVUSettings,
            scalars: SpeakerCubeVUScalars,
            clip: Bool,
            alpha: Double
        ) {
            self.emissionIntensity = CGFloat(
                OrbitalViewportMath.clamp01(
                    0.24 +
                    Double(scalars.displayVuScalar) * 0.46 +
                    Double(scalars.hotScalar) * 0.24 +
                    (clip ? 0.36 : 0)
                )
            )
            self.transparency = CGFloat(alpha)
            self.displayVuScalar = Double(scalars.displayVuScalar)
            self.hotScalar = Double(scalars.hotScalar)
            self.clipState = clip ? 1 : 0
            self.bloomMin = settings.bloomMin
            self.bloomMax = settings.bloomMax
            self.bloomEdge = settings.bloomEdge
            self.rimHaloEdge = settings.rimHaloEdge
            self.responseCurve = settings.responseCurve
            self.idleTint = settings.idleTint
            self.checkerContrast = settings.checkerContrast
            self.hotFillStrength = settings.hotFillStrength
            self.hotThreshold = settings.hotThreshold
            self.facePixels = Double(settings.facePixels)
            self.alphaValue = alpha
        }
    }

    private static var faceTextureCache: [FaceTextureKey: NSImage] = [:]
    private static var faceTextureOrder: [FaceTextureKey] = []
    private static var materialUniformStates: [ObjectIdentifier: MaterialUniformState] = [:]
    private static var diagnostics = DiagnosticsSnapshot()

    struct DiagnosticsSnapshot: Equatable {
        var materialUpdateCount = 0
        var faceTextureCacheHitCount = 0
        var faceTextureCacheMissCount = 0
        var faceTextureGenerationCount = 0
        var faceTextureEvictionCount = 0
        var uniformWriteCount = 0
        var textureAssignmentCount = 0
    }

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
        if usesSceneKitShaderModifier {
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
        }
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
        update(
            material: material,
            settings: settings,
            scalars: scalars,
            clip: clip,
            alpha: alpha,
            vuColor: resolvedColor(vuColor),
            hotColor: resolvedColor(hotColor)
        )
    }

    static func update(
        material: SCNMaterial?,
        settings: OrbitalViewportCubeVUSettings,
        scalars: SpeakerCubeVUScalars,
        clip: Bool,
        alpha: Double,
        vuColor: NSColor,
        hotColor: NSColor
    ) {
        guard let material else {
            return
        }
        diagnostics.materialUpdateCount += 1
        let vuNSColor = resolvedColor(vuColor)
        let hotNSColor = resolvedColor(hotColor)
        let texture = faceTexture(
            settings: settings,
            scalars: scalars,
            clip: clip,
            vuColor: vuNSColor,
            hotColor: hotNSColor
        )
        assignTexture(texture, to: material.diffuse)
        assignTexture(texture, to: material.emission)
        let uniformState = MaterialUniformState(
            settings: settings,
            scalars: scalars,
            clip: clip,
            alpha: alpha
        )
        let materialID = ObjectIdentifier(material)
        let previousUniformState = materialUniformStates[materialID]
        setCGFloat(
            uniformState.emissionIntensity,
            previous: previousUniformState?.emissionIntensity,
            to: material.emission,
            keyPath: \.intensity
        )
        setCGFloat(
            uniformState.transparency,
            previous: previousUniformState?.transparency,
            to: material,
            keyPath: \.transparency
        )
        if usesSceneKitShaderModifier {
            setNumericValue(
                uniformState.displayVuScalar,
                previous: previousUniformState?.displayVuScalar,
                forKey: "displayVuScalar",
                on: material
            )
            setNumericValue(uniformState.hotScalar, previous: previousUniformState?.hotScalar, forKey: "hotScalar", on: material)
            setNumericValue(uniformState.clipState, previous: previousUniformState?.clipState, forKey: "clipState", on: material)
            setNumericValue(uniformState.bloomMin, previous: previousUniformState?.bloomMin, forKey: "bloomMin", on: material)
            setNumericValue(uniformState.bloomMax, previous: previousUniformState?.bloomMax, forKey: "bloomMax", on: material)
            setNumericValue(uniformState.bloomEdge, previous: previousUniformState?.bloomEdge, forKey: "bloomEdge", on: material)
            setNumericValue(uniformState.rimHaloEdge, previous: previousUniformState?.rimHaloEdge, forKey: "rimHaloEdge", on: material)
            setNumericValue(uniformState.responseCurve, previous: previousUniformState?.responseCurve, forKey: "responseCurve", on: material)
            setNumericValue(uniformState.idleTint, previous: previousUniformState?.idleTint, forKey: "idleTint", on: material)
            setNumericValue(uniformState.checkerContrast, previous: previousUniformState?.checkerContrast, forKey: "checkerContrast", on: material)
            setNumericValue(uniformState.hotFillStrength, previous: previousUniformState?.hotFillStrength, forKey: "hotFillStrength", on: material)
            setNumericValue(uniformState.hotThreshold, previous: previousUniformState?.hotThreshold, forKey: "hotThreshold", on: material)
            setNumericValue(uniformState.facePixels, previous: previousUniformState?.facePixels, forKey: "facePixels", on: material)
            setNumericValue(uniformState.alphaValue, previous: previousUniformState?.alphaValue, forKey: "alphaValue", on: material)
        }
        materialUniformStates[materialID] = uniformState
    }

    private static func assignTexture(_ texture: NSImage, to property: SCNMaterialProperty) {
        if let current = property.contents as? NSImage,
           current === texture {
            return
        }
        property.contents = texture
        diagnostics.textureAssignmentCount += 1
    }

    private static func setNumericValue(
        _ value: Double,
        previous: Double?,
        forKey key: String,
        on material: SCNMaterial
    ) {
        if let previous,
           abs(previous - value) < 0.000_001 {
            return
        }
        material.setValue(NSNumber(value: value), forKey: key)
        diagnostics.uniformWriteCount += 1
    }

    private static func setCGFloat<Root: AnyObject>(
        _ value: CGFloat,
        previous: CGFloat?,
        to object: Root,
        keyPath: ReferenceWritableKeyPath<Root, CGFloat>
    ) {
        if let previous,
           abs(previous - value) < 0.000_001 {
            return
        }
        object[keyPath: keyPath] = value
        diagnostics.uniformWriteCount += 1
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
            diagnostics.faceTextureCacheHitCount += 1
            return cached
        }
        diagnostics.faceTextureCacheMissCount += 1

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
            diagnostics.faceTextureEvictionCount += 1
        }
        return image
    }

    static func cachedFaceTextureCountForTests() -> Int {
        faceTextureCache.count
    }

    static func resetFaceTextureCacheForTests() {
        faceTextureCache.removeAll()
        faceTextureOrder.removeAll()
        materialUniformStates.removeAll()
        resetDiagnosticsForTests()
    }

    static func diagnosticsSnapshotForTests() -> DiagnosticsSnapshot {
        diagnostics
    }

    static func resetDiagnosticsForTests() {
        diagnostics = DiagnosticsSnapshot()
    }

    private static func makeFaceTextureImage(
        key: FaceTextureKey,
        settings: OrbitalViewportCubeVUSettings,
        scalars: SpeakerCubeVUScalars,
        clip: Bool,
        vuColor: NSColor,
        hotColor: NSColor
    ) -> NSImage {
        diagnostics.faceTextureGenerationCount += 1
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
    case oneTwenty = 120

    var id: Int { rawValue }

    var framesPerSecond: Int { rawValue }

    var title: String {
        "\(rawValue) FPS"
    }

    static func option(for framesPerSecond: Int) -> OrbitalViewportFrameRate {
        allCases.first(where: { $0.framesPerSecond == framesPerSecond }) ?? .oneTwenty
    }

    static func normalized(_ framesPerSecond: Int) -> Int {
        option(for: framesPerSecond).framesPerSecond
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
        OrbitalViewportSpeaker(channel: 21, label: "Fey 21", x: -0.479772219839528, y: -0.662085663378549, z: 0.575726663807434),
        OrbitalViewportSpeaker(channel: 22, label: "Fey 22", x: -0.776114000116266, y: 0.242535625036333, z: 0.582085500087199),
        OrbitalViewportSpeaker(channel: 23, label: "Fey 23", x: 0, y: 0.8, z: 0.6),
        OrbitalViewportSpeaker(channel: 24, label: "Fey 24", x: 0.774258005430618, y: 0.251633851764951, z: 0.580693504072963),
        OrbitalViewportSpeaker(channel: 25, label: "Fey 25", x: 0.479772219839528, y: -0.662085663378549, z: 0.575726663807434),
        OrbitalViewportSpeaker(channel: 26, label: "Fey 26", x: 0, y: -0.554700196225229, z: 0.832050294337844),
        OrbitalViewportSpeaker(channel: 27, label: "Fey 27", x: -0.545454545454545, y: -0.181818181818182, z: 0.818181818181818),
        OrbitalViewportSpeaker(channel: 28, label: "Fey 28", x: -0.403422633196499, y: 0.556723233811169, z: 0.726160739753698),
        OrbitalViewportSpeaker(channel: 29, label: "Fey 29", x: 0.403422633196499, y: 0.556723233811169, z: 0.726160739753698),
        OrbitalViewportSpeaker(channel: 30, label: "Fey 30", x: 0.545454545454545, y: -0.181818181818182, z: 0.818181818181818)
    ]
}

extension OrbitalViewportSpeaker {
    init(spatGRISSpeaker speaker: SpatGRISSpeaker) {
        self.init(
            channel: speaker.patchID,
            label: "SpatGRIS \(String(format: "%02d", speaker.patchID))",
            x: speaker.position.x,
            y: speaker.position.y,
            z: speaker.position.z
        )
    }
}

struct OrbitalViewportSourceMarker: Identifiable, Equatable, Sendable {
    let sourceID: Int
    let label: String
    let position: OVVector3
    let state: SpatGRISSliceState
    let argbColor: UInt32?
    let directOutPatchID: Int?
    let hybridSpatMode: SpatGRISSpatMode?
    let isDirectOut: Bool

    var id: Int { sourceID }

    init(
        sourceID: Int,
        label: String,
        position: OrbitalViewVector3,
        state: SpatGRISSliceState = .normal,
        argbColor: UInt32? = nil,
        directOutPatchID: Int? = nil,
        hybridSpatMode: SpatGRISSpatMode? = nil,
        isDirectOut: Bool = false
    ) {
        self.sourceID = sourceID
        self.label = label
        self.position = OVVector3(position)
        self.state = state
        self.argbColor = argbColor
        self.directOutPatchID = directOutPatchID
        self.hybridSpatMode = hybridSpatMode
        self.isDirectOut = isDirectOut
    }

    init(spatGRISSpeaker speaker: SpatGRISSpeaker) {
        self.init(
            sourceID: speaker.patchID,
            label: "Source \(String(format: "%02d", speaker.patchID))",
            position: speaker.position,
            state: speaker.state,
            isDirectOut: speaker.directOutOnly
        )
    }

    func applying(project: SpatGRISProject?) -> OrbitalViewportSourceMarker {
        guard let projectSource = project?.sources.first(where: { $0.sourceID == sourceID }) else {
            return self
        }
        return OrbitalViewportSourceMarker(
            sourceID: sourceID,
            label: label,
            position: position.coreVector,
            state: projectSource.state,
            argbColor: projectSource.argbColor,
            directOutPatchID: projectSource.directOutPatchID,
            hybridSpatMode: projectSource.hybridSpatMode,
            isDirectOut: isDirectOut || projectSource.directOutPatchID != nil
        )
    }

    func repositioned(to position: OrbitalViewVector3) -> OrbitalViewportSourceMarker {
        OrbitalViewportSourceMarker(
            sourceID: sourceID,
            label: label,
            position: position,
            state: state,
            argbColor: argbColor,
            directOutPatchID: directOutPatchID,
            hybridSpatMode: hybridSpatMode,
            isDirectOut: isDirectOut
        )
    }

    func color(theme: OrbitalViewportTheme) -> Color {
        if state == .muted {
            return theme.muted
        }
        return isDirectOut ? theme.vuHot : theme.accentSecondary
    }

    #if os(macOS)
    func nsColor(theme: OrbitalViewportTheme) -> NSColor {
        if state == .muted {
            return theme.mutedNSColor
        }
        return isDirectOut ? theme.vuHotNSColor : theme.accentSecondaryNSColor
    }
    #endif
}

struct OrbitalViewportSceneBounds3D: Equatable, Sendable {
    let center: OVVector3
    let halfExtent: Double

    static func enclosing(
        speakers: [OrbitalViewportSpeaker],
        sources: [OrbitalViewportSourceMarker]
    ) -> OrbitalViewportSceneBounds3D {
        let points = speakers.map(OVVector3.init) + sources.map(OVVector3.init)
        guard !points.isEmpty else {
            return OrbitalViewportSceneBounds3D(center: .zero, halfExtent: 1)
        }

        let minX = points.map(\.x).min() ?? -1
        let maxX = points.map(\.x).max() ?? 1
        let minY = points.map(\.y).min() ?? -1
        let maxY = points.map(\.y).max() ?? 1
        let minZ = points.map(\.z).min() ?? -1
        let maxZ = points.map(\.z).max() ?? 1
        let center = OVVector3(
            x: (minX + maxX) * 0.5,
            y: (minY + maxY) * 0.5,
            z: (minZ + maxZ) * 0.5
        )
        let halfExtent = max(1, (maxX - minX) * 0.5, (maxY - minY) * 0.5, (maxZ - minZ) * 0.5)
        return OrbitalViewportSceneBounds3D(center: center, halfExtent: min(64, halfExtent))
    }
}

struct OrbitalViewportOrbitState: Equatable {
    static let spinRadiansPerMS = 0.000075
    static let defaultDistance = 4.15
    static let maxPitch = Double.pi / 2

    var view: OrbitalViewportCameraView = .isometric
    var yaw: Double
    var pitch: Double
    var distance: Double = Self.defaultDistance

    static func clampedPitch(_ pitch: Double) -> Double {
        min(maxPitch, max(-maxPitch, pitch))
    }

    static func preset(_ view: OrbitalViewportCameraView) -> OrbitalViewportOrbitState {
        let pose = view.preset
        return OrbitalViewportOrbitState(view: view, yaw: pose.yaw, pitch: pose.pitch)
    }

    func applyingDrag(translation: CGSize) -> OrbitalViewportOrbitState {
        OrbitalViewportOrbitState(
            view: view,
            yaw: yaw - Double(translation.width) * 0.006,
            pitch: Self.clampedPitch(pitch + Double(translation.height) * 0.006),
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
        let clampedPitch = Self.clampedPitch(pitch)
        let horizontal = cos(clampedPitch)
        let viewDirection = OVVector3(
            x: sin(yaw) * horizontal,
            y: cos(yaw) * horizontal,
            z: sin(clampedPitch)
        ).normalized(fallback: OVVector3(x: 0, y: 1, z: 0))
        let right = OVVector3(
            x: cos(yaw),
            y: -sin(yaw),
            z: 0
        ).normalized(fallback: OVVector3(x: 1, y: 0, z: 0))
        let up = OVVector3.cross(right, viewDirection)
            .normalized(fallback: OVVector3(x: 0, y: -1, z: 0))
        return OrbitalViewportCameraBasis(
            viewDirection: viewDirection,
            right: right,
            up: up,
            distance: distance
        )
    }

    var cameraPosition: OVVector3 {
        cameraBasis.position
    }
}

enum OrbitalViewportGeodesicAppearanceInteraction {
    static let automaticVisibleSaturationThreshold = 0.05
    static let automaticVisibleSaturation = 1.0

    static func saturationAfterPaletteSelection(current saturation: Double) -> Double {
        let normalized = OrbitalViewportMath.clamp01(saturation)
        guard normalized <= automaticVisibleSaturationThreshold else {
            return normalized
        }

        return automaticVisibleSaturation
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

struct OrbitalViewportFrameCadence: Equatable {
    let activeFramesPerSecond: Int
    let meterDisplayFramesPerSecond: Int
    let inspectorFramesPerSecond: Int

    init(
        activeFramesPerSecond: Int,
        meterDisplayFramesPerSecond: Int,
        inspectorFramesPerSecond: Int
    ) {
        self.activeFramesPerSecond = OrbitalViewportFrameRate.normalized(activeFramesPerSecond)
        self.meterDisplayFramesPerSecond = max(1, min(30, meterDisplayFramesPerSecond))
        self.inspectorFramesPerSecond = max(1, min(30, inspectorFramesPerSecond))
    }

    func activeFrameIndex(timeMS: Double) -> Int {
        frameIndex(timeMS: timeMS, framesPerSecond: activeFramesPerSecond)
    }

    func meterDisplayFrameIndex(timeMS: Double) -> Int {
        frameIndex(timeMS: timeMS, framesPerSecond: meterDisplayFramesPerSecond)
    }

    func inspectorFrameIndex(timeMS: Double) -> Int {
        frameIndex(timeMS: timeMS, framesPerSecond: inspectorFramesPerSecond)
    }

    private func frameIndex(timeMS: Double, framesPerSecond: Int) -> Int {
        Int(floor((timeMS * Double(max(1, framesPerSecond)) / 1_000.0) + 0.000_001))
    }
}

enum OrbitalViewportRenderScheduler {
    static func targetFramesPerSecond(
        activeFramesPerSecond: Int,
        meterOnlyFramesPerSecond: Int,
        isActiveMotion: Bool
    ) -> Int {
        isActiveMotion
            ? OrbitalViewportFrameRate.normalized(activeFramesPerSecond)
            : max(1, min(30, meterOnlyFramesPerSecond))
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
    let sourceSpeakerRenderStyle: OrbitalViewportRenderStyle
    let geodesicRenderStyle: OrbitalViewportRenderStyle
    let geodesicSaturation: Double
    let showRibbedSpeakerSphere: Bool
    let ribbedSphereThickness: Double
    let ribbedSphereVerticalRibs: Int
    let ribbedSphereHorizontalRings: Int
    let speakerShape: OrbitalViewportSpeakerShape
    let speakerSize: Double
    let fogDensity: Double
    let meterSource: OrbitalViewportMeterSource
    let cubeVUSettings: OrbitalViewportCubeVUSettings
    let activeViewportFramesPerSecond: Int
    let meterOnlyViewportFramesPerSecond: Int
    let inspectorRefreshFramesPerSecond: Int
    let speakerLabelFont: OrbitalViewportSpeakerLabelFont
    let speakerLabelSizeScale: Double
    let showSpeakerNumbers: Bool
    let showHiddenLines: Bool
    let showGridPlane: Bool
    let gridPlaneVisibility: Double
    let gridPlaneSpacing: Double
    let gridPlaneRenderStyle: OrbitalViewportRenderStyle
    let gridPlaneThickness: Double
    let selectedChannel: Int?
    let speakers: [OrbitalViewportSpeaker]
    let sources: [OrbitalViewportSourceMarker]
    let sceneCenter: OVVector3
    let sceneHalfExtent: Double
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
        sourceSpeakerRenderStyle: OrbitalViewportRenderStyle? = nil,
        geodesicRenderStyle: OrbitalViewportRenderStyle? = nil,
        geodesicSaturation: Double = 1,
        showRibbedSpeakerSphere: Bool = false,
        ribbedSphereThickness: Double = OrbitalViewportMockup.defaultRibbedSphereThickness,
        ribbedSphereVerticalRibs: Int = OrbitalViewportMockup.defaultRibbedSphereVerticalRibs,
        ribbedSphereHorizontalRings: Int = OrbitalViewportMockup.defaultRibbedSphereHorizontalRings,
        speakerShape: OrbitalViewportSpeakerShape,
        speakerSize: Double,
        fogDensity: Double,
        meterSource: OrbitalViewportMeterSource = .telemetryNoProvider,
        cubeVUSettings: OrbitalViewportCubeVUSettings = .default,
        activeViewportFramesPerSecond: Int = OrbitalViewportMockup.viewportAnimationFramesPerSecond,
        meterOnlyViewportFramesPerSecond: Int = OrbitalViewportMockup.meterOnlyViewportFramesPerSecond,
        inspectorRefreshFramesPerSecond: Int = OrbitalViewportMockup.inspectorRefreshFramesPerSecond,
        speakerLabelFont: OrbitalViewportSpeakerLabelFont = .systemDefault,
        speakerLabelSizeScale: Double = 1,
        showSpeakerNumbers: Bool,
        showHiddenLines: Bool,
        showGridPlane: Bool = false,
        gridPlaneVisibility: Double = OrbitalViewportGridPlaneGeometry.defaultVisibility,
        gridPlaneSpacing: Double = OrbitalViewportGridPlaneGeometry.defaultSpacing,
        gridPlaneRenderStyle: OrbitalViewportRenderStyle? = nil,
        gridPlaneThickness: Double = OrbitalViewportGridPlaneGeometry.defaultThickness,
        selectedChannel: Int?,
        speakers: [OrbitalViewportSpeaker] = OrbitalViewportSpeaker.referenceSpeakers,
        sources: [OrbitalViewportSourceMarker] = [],
        sceneCenter: OVVector3 = .zero,
        sceneHalfExtent: Double = 1,
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
        self.sourceSpeakerRenderStyle = sourceSpeakerRenderStyle ?? renderStyle
        self.geodesicRenderStyle = geodesicRenderStyle ?? renderStyle
        self.geodesicSaturation = OrbitalViewportMath.clamp01(geodesicSaturation)
        self.showRibbedSpeakerSphere = showRibbedSpeakerSphere
        self.ribbedSphereThickness = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedThickness(ribbedSphereThickness)
        self.ribbedSphereVerticalRibs = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedVerticalRibs(ribbedSphereVerticalRibs)
        self.ribbedSphereHorizontalRings = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedHorizontalRings(ribbedSphereHorizontalRings)
        self.speakerShape = speakerShape
        self.speakerSize = speakerSize
        self.fogDensity = fogDensity
        self.meterSource = meterSource
        self.cubeVUSettings = cubeVUSettings
        self.activeViewportFramesPerSecond = OrbitalViewportFrameRate.normalized(activeViewportFramesPerSecond)
        self.meterOnlyViewportFramesPerSecond = max(1, min(30, meterOnlyViewportFramesPerSecond))
        self.inspectorRefreshFramesPerSecond = max(1, min(30, inspectorRefreshFramesPerSecond))
        self.speakerLabelFont = speakerLabelFont
        self.speakerLabelSizeScale = max(0.1, speakerLabelSizeScale)
        self.showSpeakerNumbers = showSpeakerNumbers
        self.showHiddenLines = showHiddenLines
        self.showGridPlane = showGridPlane
        self.gridPlaneVisibility = OrbitalViewportMath.clamp01(gridPlaneVisibility)
        self.gridPlaneSpacing = OrbitalViewportGridPlaneGeometry.normalizedSpacing(gridPlaneSpacing)
        self.gridPlaneRenderStyle = gridPlaneRenderStyle ?? OrbitalViewportMockup.defaultGeodesicRenderStyle
        self.gridPlaneThickness = OrbitalViewportGridPlaneGeometry.normalizedThickness(gridPlaneThickness)
        self.selectedChannel = selectedChannel
        self.speakers = speakers.isEmpty ? OrbitalViewportSpeaker.referenceSpeakers : speakers
        self.sources = sources
        self.sceneCenter = sceneCenter
        self.sceneHalfExtent = max(0.1, min(64, sceneHalfExtent))
        self.spin = spin
        self.spinStartYaw = spinStartYaw
        self.spinStartTimeMS = spinStartTimeMS
    }

    var theme: OrbitalViewportTheme {
        OrbitalViewportTheme(style: renderStyle)
    }

    var sourceSpeakerTheme: OrbitalViewportTheme {
        OrbitalViewportTheme(style: sourceSpeakerRenderStyle)
    }

    var geodesicTheme: OrbitalViewportTheme {
        OrbitalViewportTheme(style: geodesicRenderStyle)
    }

    var gridPlaneTheme: OrbitalViewportTheme {
        OrbitalViewportTheme(style: gridPlaneRenderStyle)
    }

    var frameCadence: OrbitalViewportFrameCadence {
        OrbitalViewportFrameCadence(
            activeFramesPerSecond: activeViewportFramesPerSecond,
            meterDisplayFramesPerSecond: meterOnlyViewportFramesPerSecond,
            inspectorFramesPerSecond: inspectorRefreshFramesPerSecond
        )
    }

    func geodesicColor(_ color: Color) -> Color {
        OrbitalViewportColorTools.withSaturation(color, geodesicSaturation)
    }

    var frontClipPlane: Double {
        -0.04 * sceneScale
    }

    var sphereRadius: Double {
        min(size.width, size.height) * 0.34 * zoom
    }

    var sceneScale: Double {
        max(0.1, sceneHalfExtent)
    }

    var orbitState: OrbitalViewportOrbitState {
        OrbitalViewportOrbitState(view: cameraView, yaw: yaw, pitch: pitch)
    }

    var fogConfiguration: OrbitalViewportFogConfiguration {
        OrbitalViewportFogConfiguration.make(density: fogDensity, cameraDistance: orbitState.distance)
    }

    func depthFogAmount(_ depth: Double) -> Double {
        let fogStrength = fogConfiguration.normalizedDensity
        guard fogStrength > 0 else {
            return 0
        }

        let nearToFar = OrbitalViewportMath.clamp01((sceneScale - depth) / (sceneScale * 2))
        let depthCurve = pow(nearToFar, 1.18)
        let densityCurve = pow(fogStrength, 0.72)
        return OrbitalViewportMath.clamp01(depthCurve * densityCurve)
    }

    func rotate(_ vector: OVVector3) -> OVVector3 {
        orbitState.cameraBasis.transform(vector - sceneCenter)
    }

    func project(_ vector: OVVector3) -> CGPoint {
        CGPoint(
            x: size.width * 0.5 + (vector.x / sceneScale) * sphereRadius,
            y: size.height * 0.5 - (vector.y / sceneScale) * sphereRadius
        )
    }

    func hiddenDepthFade(_ depth: Double) -> Double {
        guard depth < frontClipPlane else {
            return 1
        }

        let rear = rearDepthAmount(depth)
        let fogStrength = fogConfiguration.normalizedDensity
        let baseFade = 0.38 - rear * 0.12
        let fogLoss = fogStrength * (0.12 + rear * 0.22)
        return max(0.04, baseFade - fogLoss)
    }

    func sphereGeometryFogAlpha(depth: Double) -> Double {
        let fogAmount = depthFogAmount(depth)
        guard fogAmount > 0 else {
            return 1
        }

        let base = max(0.22, 1 - fogAmount * 0.86)
        guard depth < frontClipPlane else {
            return base
        }

        let rear = rearDepthAmount(depth)
        return max(0.04, base * max(0.18, 1 - rear * 0.58))
    }

    var ribbedSphereSceneMaterialFogDepth: Double {
        frontClipPlane - (sceneScale * 0.58)
    }

    var ribbedSphereSceneMaterialAlpha: Double {
        sphereGeometryFogAlpha(depth: ribbedSphereSceneMaterialFogDepth)
    }

    func ribbedSphereCutawayPlaneOffset(radius: Double) -> Double {
        guard fogConfiguration.isEnabled else {
            return 0
        }

        return radius * 0.22 * pow(fogConfiguration.normalizedDensity, 0.82)
    }

    var hiddenLinesVisible: Bool {
        showHiddenLines
    }

    func isVisibleDepth(_ depth: Double) -> Bool {
        depth >= frontClipPlane || (hiddenLinesVisible && hiddenDepthFade(depth) > 0.02)
    }

    func speakerLabelVisible(depth: Double, selected: Bool) -> Bool {
        showSpeakerNumbers && (selected || isVisibleDepth(depth))
    }

    func speakerLabelAlpha(depth: Double, selected: Bool) -> Double {
        guard !selected else {
            return 1
        }
        return max(0.18, 0.94 * (1 - depthFogAmount(depth) * 0.72))
    }

    func foggedAlpha(depth: Double, baseAlpha: Double) -> Double {
        let fogAmount = depthFogAmount(depth)
        guard fogAmount > 0 else {
            return baseAlpha
        }

        let floor = depth < frontClipPlane ? baseAlpha * 0.12 : baseAlpha * 0.42
        return max(floor, baseAlpha * (1 - fogAmount * 0.78))
    }

    func rearDepthAmount(_ depth: Double) -> Double {
        guard depth < frontClipPlane else {
            return 0
        }
        return OrbitalViewportMath.clamp01((frontClipPlane - depth) / (1.15 * sceneScale))
    }

    func speakerAlpha(depth: Double, selected: Bool) -> Double {
        guard !selected else {
            return 1
        }
        if depth >= frontClipPlane {
            return max(0.34, foggedAlpha(depth: depth, baseAlpha: 0.94))
        }

        let fogAmount = depthFogAmount(depth)
        let rear = rearDepthAmount(depth)
        let rearAttenuation = max(0.24, 1 - rear * (0.16 + fogAmount * 0.22))
        return max(0.055, foggedAlpha(depth: depth, baseAlpha: 0.42) * rearAttenuation)
    }

    func speakerEmissionScale(depth: Double) -> Double {
        let rear = rearDepthAmount(depth)
        let fogAmount = depthFogAmount(depth)
        let fogAttenuation = pow(max(0, 1 - fogAmount), 1.45)
        let rearAttenuation = max(0.34, 1 - rear * 0.48)
        return max(0.06, fogAttenuation * rearAttenuation)
    }

    func ribbedSphereSegmentVisible(startDepth: Double, endDepth: Double) -> Bool {
        if hiddenLinesVisible || startDepth >= frontClipPlane || endDepth >= frontClipPlane {
            return true
        }
        return fogConfiguration.isEnabled && ribbedSphereDepthAlpha(startDepth: startDepth, endDepth: endDepth) > 0.04
    }

    func ribbedSphereDepthAlpha(startDepth: Double, endDepth: Double) -> Double {
        let averageDepth = (startDepth + endDepth) * 0.5
        let fogAlpha = sphereGeometryFogAlpha(depth: averageDepth)
        guard averageDepth < frontClipPlane else {
            return fogAlpha
        }

        let hiddenAlpha = min(hiddenDepthFade(averageDepth), fogAlpha)
        if hiddenLinesVisible {
            return hiddenAlpha
        }
        guard fogConfiguration.isEnabled else {
            return 0
        }
        return max(0.025, hiddenAlpha * 0.72)
    }

    func foggedColor(_ color: Color, depth: Double) -> Color {
        OrbitalViewportColorTools.blend(color, with: theme.fog, amount: depthFogAmount(depth) * 0.68)
    }

    #if os(macOS)
    func foggedNSColor(_ color: NSColor, depth: Double) -> NSColor {
        OrbitalViewportColorTools.blend(color, with: NSColor(theme.fog), amount: depthFogAmount(depth) * 0.68)
    }

    func foggedGeodesicNSColor(_ color: NSColor, depth: Double) -> NSColor {
        let fogColor = NSColor(geodesicColor(geodesicTheme.fog))
        return OrbitalViewportColorTools.blend(color, with: fogColor, amount: depthFogAmount(depth) * 0.68)
    }
    #endif

    func foggedGeodesicColor(_ color: Color, depth: Double) -> Color {
        OrbitalViewportColorTools.blend(color, with: geodesicColor(geodesicTheme.fog), amount: depthFogAmount(depth) * 0.68)
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
            gridPlaneThickness: gridPlaneThickness,
            selectedChannel: selectedChannel,
            speakers: speakers,
            sources: sources,
            sceneCenter: sceneCenter,
            sceneHalfExtent: sceneHalfExtent,
            spin: spin,
            spinStartYaw: spinStartYaw,
            spinStartTimeMS: spinStartTimeMS
        )
    }
}

#if DEBUG
enum OrbitalRenderTrace {
    static let buildStamp = "ribbed-color-probe-2026-05-31-a"

    static var isEnabled: Bool {
        isEnvironmentFlagEnabled("ORB_DEBUG_RENDER_TRACE")
    }

    static func isEnvironmentFlagEnabled(
        _ key: String,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> Bool {
        environment[key] == "1"
    }

    static func log(
        _ stage: String,
        configuration: OrbitalViewportRenderConfiguration,
        extra: String = "",
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        guard isEnabled else {
            return
        }

        print(
            "[RIBBED_TRACE] stage=\(stage) style=\(configuration.geodesicRenderStyle.rawValue) saturation=\(configuration.geodesicSaturation) extra=\(extra) at=\(file):\(line)"
        )
    }

    static func logWrite<Value>(
        _ name: String,
        old: Value,
        new: Value,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        guard isEnabled else {
            return
        }

        print(
            """
            [RIBBED_WRITE] \(name) old=\(old) new=\(new) at=\(file):\(line)
            \(Thread.callStackSymbols.prefix(14).joined(separator: "\n"))
            """
        )
    }
}

struct OrbitalViewportRibbedDebugState: Equatable {
    let buildStamp: String
    let lastApplySequence: Int
    let lastWriter: String
    let materialNames: String

    static let empty = OrbitalViewportRibbedDebugState(
        buildStamp: OrbitalRenderTrace.buildStamp,
        lastApplySequence: 0,
        lastWriter: "none",
        materialNames: "none"
    )
}
#endif

struct OrbitalViewportCameraUpdateKey: Equatable {
    let yaw: Double
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let zoom: Double
    let sceneCenter: OVVector3
    let sceneHalfExtent: Double

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.yaw = configuration.yaw
        self.pitch = configuration.pitch
        self.cameraView = configuration.cameraView
        self.zoom = configuration.zoom
        self.sceneCenter = configuration.sceneCenter
        self.sceneHalfExtent = configuration.sceneHalfExtent
    }
}

struct OrbitalViewportRibbedSpeakerSphereTopologyKey: Equatable {
    let speakers: [OrbitalViewportSpeaker]
    let ribbedSphereThickness: Double
    let ribbedSphereVerticalRibs: Int
    let ribbedSphereHorizontalRings: Int
    let sceneScale: Double

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.speakers = configuration.speakers
        self.ribbedSphereThickness = configuration.ribbedSphereThickness
        self.ribbedSphereVerticalRibs = configuration.ribbedSphereVerticalRibs
        self.ribbedSphereHorizontalRings = configuration.ribbedSphereHorizontalRings
        self.sceneScale = configuration.sceneScale
    }
}

struct OrbitalViewportRibbedSpeakerSphereUpdateKey: Equatable {
    let showRibbedSpeakerSphere: Bool
    let geodesicRenderStyle: OrbitalViewportRenderStyle
    let geodesicSaturation: Double
    let showHiddenLines: Bool

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.showRibbedSpeakerSphere = configuration.showRibbedSpeakerSphere
        self.geodesicRenderStyle = configuration.geodesicRenderStyle
        self.geodesicSaturation = configuration.geodesicSaturation
        self.showHiddenLines = configuration.showHiddenLines
    }
}

struct OrbitalViewportSpeakerGeometryUpdateKey: Equatable {
    let speakerShape: OrbitalViewportSpeakerShape
    let speakerSize: Double
    let speakers: [OrbitalViewportSpeaker]

    init(
        speakerShape: OrbitalViewportSpeakerShape,
        speakerSize: Double,
        speakers: [OrbitalViewportSpeaker]
    ) {
        self.speakerShape = speakerShape
        self.speakerSize = speakerSize
        self.speakers = speakers
    }

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.init(
            speakerShape: configuration.speakerShape,
            speakerSize: configuration.speakerSize,
            speakers: configuration.speakers
        )
    }
}

struct OrbitalViewportSpeakerLabelGeometryUpdateKey: Equatable {
    let speakerLabelFont: OrbitalViewportSpeakerLabelFont
    let speakerLabelSizeScale: Double

    init(speakerLabelFont: OrbitalViewportSpeakerLabelFont, speakerLabelSizeScale: Double) {
        self.speakerLabelFont = speakerLabelFont
        self.speakerLabelSizeScale = speakerLabelSizeScale
    }

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.init(
            speakerLabelFont: configuration.speakerLabelFont,
            speakerLabelSizeScale: configuration.speakerLabelSizeScale
        )
    }
}

struct OrbitalViewportCubeOutlineMaterialUpdateKey: Equatable {
    let renderStyle: OrbitalViewportRenderStyle
    let alpha: Double
    let strength: Double
    let selected: Bool
    let isHidden: Bool
}

struct OrbitalViewportSpeakerLabelMaterialUpdateKey: Equatable {
    let renderStyle: OrbitalViewportRenderStyle
    let selected: Bool
    let textureBacked: Bool
    let alpha: Double
}

private enum OrbitalViewportVisualSignatureBucket {
    static func normalized(_ value: Double, scale: Double = 10_000) -> Int {
        guard value.isFinite else {
            return 0
        }
        return Int((OrbitalViewportMath.clamp01(value) * scale).rounded())
    }
}

struct OrbitalViewportSpeakerMaterialVisualSignature: Equatable {
    let channel: Int
    let selected: Bool
    let visible: Bool
    let fogAmount: Int
    let rms: Int
    let peak: Int
    let display: Int
    let hot: Int
    let heat: Int
    let alpha: Int
    let labelAlpha: Int
    let emissionOpacity: Int

    init(
        speaker: OrbitalViewportProjectedSpeaker,
        configuration: OrbitalViewportRenderConfiguration
    ) {
        let selected = configuration.selectedChannel == speaker.channel
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
        let fogAmount = configuration.depthFogAmount(speaker.depth)
        let labelAlpha = configuration.speakerLabelAlpha(depth: speaker.depth, selected: selected)
        let hotMix = OrbitalViewportMath.clamp01(
            (hot - configuration.cubeVUSettings.hotThreshold) /
            max(0.001, 1 - configuration.cubeVUSettings.hotThreshold)
        )
        let visibleFill = max(configuration.cubeVUSettings.idleTint, display)
        let emissionOpacity = (
            configuration.cubeVUSettings.bloomMin +
            (configuration.cubeVUSettings.bloomMax - configuration.cubeVUSettings.bloomMin) * visibleFill +
            configuration.cubeVUSettings.hotFillStrength * hotMix * 0.38
        ) * emissionScale

        self.channel = speaker.channel
        self.selected = selected
        self.visible = configuration.isVisibleDepth(speaker.depth)
        self.fogAmount = OrbitalViewportVisualSignatureBucket.normalized(fogAmount)
        self.rms = OrbitalViewportVisualSignatureBucket.normalized(speaker.rms)
        self.peak = OrbitalViewportVisualSignatureBucket.normalized(speaker.peak)
        self.display = OrbitalViewportVisualSignatureBucket.normalized(display)
        self.hot = OrbitalViewportVisualSignatureBucket.normalized(hot)
        self.heat = OrbitalViewportVisualSignatureBucket.normalized(heat)
        self.alpha = OrbitalViewportVisualSignatureBucket.normalized(alpha)
        self.labelAlpha = OrbitalViewportVisualSignatureBucket.normalized(labelAlpha)
        self.emissionOpacity = OrbitalViewportVisualSignatureBucket.normalized(emissionOpacity)
    }
}

struct OrbitalViewportSpeakerMaterialVisualSignatureKey: Equatable {
    let renderStyle: OrbitalViewportRenderStyle
    let meterSourceMode: OrbitalViewportMeterSource.Mode
    let cubeVUSettings: OrbitalViewportCubeVUSettings
    let selectedChannel: Int?
    let speakerShape: OrbitalViewportSpeakerShape
    let speakerLabelFont: OrbitalViewportSpeakerLabelFont
    let signatures: [OrbitalViewportSpeakerMaterialVisualSignature]

    init(
        configuration: OrbitalViewportRenderConfiguration,
        snapshot: OrbitalViewportSnapshot
    ) {
        self.renderStyle = configuration.renderStyle
        self.meterSourceMode = configuration.meterSource.mode
        var materialSettings = configuration.cubeVUSettings
        materialSettings.speakerHeight = 1
        self.cubeVUSettings = materialSettings
        self.selectedChannel = configuration.selectedChannel
        self.speakerShape = configuration.speakerShape
        self.speakerLabelFont = configuration.speakerLabelFont
        self.signatures = snapshot.speakers.map {
            OrbitalViewportSpeakerMaterialVisualSignature(speaker: $0, configuration: configuration)
        }
    }
}

struct OrbitalViewportSourceMaterialVisualSignature: Equatable {
    let sourceID: Int
    let state: SpatGRISSliceState
    let isDirectOut: Bool
    let fogAmount: Int
    let rms: Int
    let peak: Int
    let alpha: Int
    let bloom: Int

    init(
        source: OrbitalViewportProjectedSource,
        configuration: OrbitalViewportRenderConfiguration
    ) {
        self.sourceID = source.sourceID
        self.state = source.source.state
        self.isDirectOut = source.source.isDirectOut
        self.fogAmount = OrbitalViewportVisualSignatureBucket.normalized(
            configuration.depthFogAmount(source.depth)
        )
        self.rms = OrbitalViewportVisualSignatureBucket.normalized(source.rms)
        self.peak = OrbitalViewportVisualSignatureBucket.normalized(source.peak)
        self.alpha = OrbitalViewportVisualSignatureBucket.normalized(
            configuration.speakerAlpha(depth: source.depth, selected: false)
        )
        self.bloom = OrbitalViewportVisualSignatureBucket.normalized(
            (0.24 + (source.peak * 0.55)) *
            configuration.speakerEmissionScale(depth: source.depth)
        )
    }
}

struct OrbitalViewportSourceMaterialVisualSignatureKey: Equatable {
    let sourceSpeakerRenderStyle: OrbitalViewportRenderStyle
    let meterSourceMode: OrbitalViewportMeterSource.Mode
    let signatures: [OrbitalViewportSourceMaterialVisualSignature]

    init(
        configuration: OrbitalViewportRenderConfiguration,
        snapshot: OrbitalViewportSnapshot
    ) {
        self.sourceSpeakerRenderStyle = configuration.sourceSpeakerRenderStyle
        self.meterSourceMode = configuration.meterSource.mode
        self.signatures = snapshot.sources.map {
            OrbitalViewportSourceMaterialVisualSignature(source: $0, configuration: configuration)
        }
    }
}

struct OrbitalViewportSpeakerVisibilityUpdateKey: Equatable {
    let yaw: Double
    let activeMotionVisibilityFrame: Int?
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let showHiddenLines: Bool
    let showSpeakerNumbers: Bool
    let selectedChannel: Int?
    let speakers: [OrbitalViewportSpeaker]

    init(configuration: OrbitalViewportRenderConfiguration) {
        if configuration.spin {
            self.yaw = 0
            self.activeMotionVisibilityFrame = configuration.frameCadence.meterDisplayFrameIndex(timeMS: configuration.timeMS)
        } else {
            self.yaw = configuration.yaw
            self.activeMotionVisibilityFrame = nil
        }
        self.pitch = configuration.pitch
        self.cameraView = configuration.cameraView
        self.showHiddenLines = configuration.showHiddenLines
        self.showSpeakerNumbers = configuration.showSpeakerNumbers
        self.selectedChannel = configuration.selectedChannel
        self.speakers = configuration.speakers
    }
}

struct OrbitalViewportGridPlaneUpdateKey: Equatable {
    let showGridPlane: Bool
    let gridPlaneVisibility: Double
    let gridPlaneSpacing: Double
    let gridPlaneRenderStyle: OrbitalViewportRenderStyle
    let gridPlaneThickness: Double

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.showGridPlane = configuration.showGridPlane
        self.gridPlaneVisibility = configuration.gridPlaneVisibility
        self.gridPlaneSpacing = configuration.gridPlaneSpacing
        self.gridPlaneRenderStyle = configuration.gridPlaneRenderStyle
        self.gridPlaneThickness = configuration.gridPlaneThickness
    }
}

struct OrbitalViewportSpeakerMaterialUpdateKey: Equatable {
    let meterDisplayFrame: Int
    let meterDisplayFramesPerSecond: Int
    let renderStyle: OrbitalViewportRenderStyle
    let meterSourceMode: OrbitalViewportMeterSource.Mode
    let cubeVUSettings: OrbitalViewportCubeVUSettings
    let selectedChannel: Int?
    let fogDensity: Double

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.meterDisplayFramesPerSecond = configuration.meterOnlyViewportFramesPerSecond
        self.meterDisplayFrame = configuration.frameCadence.meterDisplayFrameIndex(timeMS: configuration.timeMS)
        self.renderStyle = configuration.renderStyle
        self.meterSourceMode = configuration.meterSource.mode
        var materialSettings = configuration.cubeVUSettings
        materialSettings.speakerHeight = 1
        self.cubeVUSettings = materialSettings
        self.selectedChannel = configuration.selectedChannel
        self.fogDensity = configuration.fogDensity
    }
}

struct OrbitalViewportSourcePoseUpdateKey: Equatable {
    let yaw: Double
    let activeMotionPoseFrame: Int?
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let showHiddenLines: Bool
    let sources: [OrbitalViewportSourceMarker]
    let sceneCenter: OVVector3
    let sceneHalfExtent: Double

    init(configuration: OrbitalViewportRenderConfiguration) {
        if configuration.spin {
            self.yaw = 0
            self.activeMotionPoseFrame = configuration.frameCadence.meterDisplayFrameIndex(timeMS: configuration.timeMS)
        } else {
            self.yaw = configuration.yaw
            self.activeMotionPoseFrame = nil
        }
        self.pitch = configuration.pitch
        self.cameraView = configuration.cameraView
        self.showHiddenLines = configuration.showHiddenLines
        self.sources = configuration.sources
        self.sceneCenter = configuration.sceneCenter
        self.sceneHalfExtent = configuration.sceneHalfExtent
    }
}

struct OrbitalViewportSourceMaterialUpdateKey: Equatable {
    let sourceSpeakerRenderStyle: OrbitalViewportRenderStyle
    let meterSourceMode: OrbitalViewportMeterSource.Mode
    let meterDisplayFrame: Int
    let meterDisplayFramesPerSecond: Int
    let fogDensity: Double
    let sources: [OrbitalViewportSourceMarker]

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.sourceSpeakerRenderStyle = configuration.sourceSpeakerRenderStyle
        self.meterSourceMode = configuration.meterSource.mode
        self.meterDisplayFrame = configuration.frameCadence.meterDisplayFrameIndex(timeMS: configuration.timeMS)
        self.meterDisplayFramesPerSecond = configuration.meterOnlyViewportFramesPerSecond
        self.fogDensity = configuration.fogDensity
        self.sources = configuration.sources
    }
}

struct OrbitalViewportGridPlaneGeometry {
    static let canonicalZ = -1.2
    static let halfExtent = 5.0
    static let defaultSpacing = 0.5
    static let spacingRange: ClosedRange<Double> = 0.25...1.0
    static let defaultVisibilitySlider = 70.0
    static let defaultVisibility = visibility(fromSlider: defaultVisibilitySlider)
    static let defaultThickness = 1.0
    static let thicknessRange: ClosedRange<Double> = 0.5...2.5
    static let minorLineRadius = 0.00115
    static let majorLineRadius = 0.00185
    static let minorLineAlpha = 0.45
    static let majorLineAlpha = 0.8
    static let lineSegments = lineSegments(spacing: defaultSpacing)

    struct LineSegment: Equatable {
        let start: OVVector3
        let end: OVVector3
        let isMajor: Bool
    }

    static func visibility(fromSlider value: Double) -> Double {
        OrbitalViewportMath.clamp01(value / 100)
    }

    static func alpha(for line: LineSegment, visibility: Double) -> Double {
        (line.isMajor ? majorLineAlpha : minorLineAlpha) * OrbitalViewportMath.clamp01(visibility)
    }

    static func normalizedSpacing(_ value: Double) -> Double {
        min(spacingRange.upperBound, max(spacingRange.lowerBound, value))
    }

    static func normalizedThickness(_ value: Double) -> Double {
        min(thicknessRange.upperBound, max(thicknessRange.lowerBound, value))
    }

    static func radius(for line: LineSegment, thickness: Double) -> Double {
        (line.isMajor ? majorLineRadius : minorLineRadius) * normalizedThickness(thickness)
    }

    static func lineSegments(spacing rawSpacing: Double) -> [LineSegment] {
        let spacing = normalizedSpacing(rawSpacing)
        let steps = Int(round((halfExtent * 2) / spacing))
        let startIndex = -steps / 2
        let endIndex = steps / 2
        var lines: [LineSegment] = []
        lines.reserveCapacity((endIndex - startIndex + 1) * 2)

        for index in startIndex...endIndex {
            let value = Double(index) * spacing
            let isMajor = abs(value) < 0.000_001
            lines.append(
                LineSegment(
                    start: OVVector3(x: value, y: -halfExtent, z: canonicalZ),
                    end: OVVector3(x: value, y: halfExtent, z: canonicalZ),
                    isMajor: isMajor
                )
            )
            lines.append(
                LineSegment(
                    start: OVVector3(x: -halfExtent, y: value, z: canonicalZ),
                    end: OVVector3(x: halfExtent, y: value, z: canonicalZ),
                    isMajor: isMajor
                )
            )
        }

        return lines
    }
}

struct OrbitalViewportRibbedSpeakerSphereGeometry {
    static let thicknessRange = 0.70...2.5
    static let verticalRibRange = 3...64
    static let horizontalRingRange = 0...32
    static let baseStrutRadius = 0.0019
    static let frontLineAlpha = 0.66
    static let rearLineAlpha = 0.28

    private static let twoPi = Double.pi * 2
    private static let epsilon = 0.000_001

    enum SegmentKind: Int, Equatable {
        case verticalRib
        case horizontalRing
    }

    struct Fit: Equatable {
        let center: OVVector3
        let radius: Double
    }

    struct Segment: Equatable {
        let kind: SegmentKind
        let index: Int
        let start: OVVector3
        let end: OVVector3
    }

    struct Curve: Equatable {
        let kind: SegmentKind
        let index: Int
        let points: [OVVector3]
        let isClosed: Bool

        var segmentCount: Int {
            isClosed ? points.count : max(0, points.count - 1)
        }
    }

    struct SegmentCounts: Equatable {
        let vertical: Int
        let horizontal: Int

        var total: Int {
            vertical + horizontal
        }
    }

    static func normalizedThickness(_ value: Double) -> Double {
        min(thicknessRange.upperBound, max(thicknessRange.lowerBound, value))
    }

    static func normalizedVerticalRibs(_ value: Int) -> Int {
        min(verticalRibRange.upperBound, max(verticalRibRange.lowerBound, value))
    }

    static func normalizedHorizontalRings(_ value: Int) -> Int {
        min(horizontalRingRange.upperBound, max(horizontalRingRange.lowerBound, value))
    }

    static func fit(
        for speakers: [OrbitalViewportSpeaker],
        fallbackRadius: Double = 1
    ) -> Fit {
        let positions = uniqueSpeakers(speakers).map(OVVector3.init)
        guard !positions.isEmpty else {
            return Fit(center: .zero, radius: max(0.1, fallbackRadius))
        }

        let center = positions.reduce(.zero, +) * (1 / Double(positions.count))
        let distances = positions
            .map { ($0 - center).length }
            .filter { $0 > epsilon }
            .sorted()
        guard !distances.isEmpty else {
            return Fit(center: center, radius: max(0.1, fallbackRadius))
        }

        let middle = distances.count / 2
        let radius = distances.count.isMultiple(of: 2)
            ? (distances[middle - 1] + distances[middle]) * 0.5
            : distances[middle]
        return Fit(center: center, radius: max(0.1, radius))
    }

    static func verticalRibLongitudes(
        for speakers: [OrbitalViewportSpeaker],
        count: Int
    ) -> [Double] {
        _ = speakers
        let normalizedCount = normalizedVerticalRibs(count)
        return (0..<normalizedCount).map { index in
            (Double(index) / Double(normalizedCount)) * twoPi
        }
    }

    static func horizontalRingLatitudes(
        for speakers: [OrbitalViewportSpeaker],
        count: Int
    ) -> [Double] {
        _ = speakers
        let normalizedCount = normalizedHorizontalRings(count)
        guard normalizedCount > 0 else {
            return []
        }
        let lower = -Double.pi * 0.5
        let span = Double.pi
        return (0..<normalizedCount).map { index in
            lower + (Double(index + 1) / Double(normalizedCount + 1)) * span
        }
    }

    static func segmentCounts(
        verticalRibs: Int,
        horizontalRings: Int
    ) -> SegmentCounts {
        let ribCount = normalizedVerticalRibs(verticalRibs)
        let ringCount = normalizedHorizontalRings(horizontalRings)
        let meridianSteps = max(24, min(80, 24 + ringCount * 3))
        let ringSteps = max(24, min(96, ribCount * 3))
        return SegmentCounts(
            vertical: ribCount * meridianSteps,
            horizontal: ringCount * ringSteps
        )
    }

    static func segments(
        for speakers: [OrbitalViewportSpeaker],
        verticalRibs: Int,
        horizontalRings: Int,
        fallbackRadius: Double = 1
    ) -> [Segment] {
        let curves = curves(
            for: speakers,
            verticalRibs: verticalRibs,
            horizontalRings: horizontalRings,
            fallbackRadius: fallbackRadius
        )
        let capacity = curves.reduce(0) { $0 + $1.segmentCount }
        var output: [Segment] = []
        output.reserveCapacity(capacity)

        for curve in curves {
            guard curve.points.count >= 2 else {
                continue
            }
            for index in 0..<(curve.points.count - 1) {
                output.append(
                    Segment(
                        kind: curve.kind,
                        index: curve.index,
                        start: curve.points[index],
                        end: curve.points[index + 1]
                    )
                )
            }
            if curve.isClosed, let first = curve.points.first, let last = curve.points.last {
                output.append(
                    Segment(
                        kind: curve.kind,
                        index: curve.index,
                        start: last,
                        end: first
                    )
                )
            }
        }

        return output
    }

    static func curves(
        for speakers: [OrbitalViewportSpeaker],
        verticalRibs: Int,
        horizontalRings: Int,
        fallbackRadius: Double = 1
    ) -> [Curve] {
        let fit = fit(for: speakers, fallbackRadius: fallbackRadius)
        let ribCount = normalizedVerticalRibs(verticalRibs)
        let ringCount = normalizedHorizontalRings(horizontalRings)
        let longitudes = verticalRibLongitudes(for: speakers, count: ribCount)
        let latitudes = horizontalRingLatitudes(for: speakers, count: ringCount)
        let counts = segmentCounts(verticalRibs: verticalRibs, horizontalRings: horizontalRings)
        let meridianSteps = counts.vertical / ribCount
        let ringSteps = ringCount > 0 ? counts.horizontal / ringCount : 0
        var output: [Curve] = []
        output.reserveCapacity(ribCount + ringCount)

        for (ribIndex, longitude) in longitudes.enumerated() {
            let points = (0...meridianSteps).map { step in
                let latitude = (-Double.pi * 0.5) + (Double(step) / Double(meridianSteps)) * Double.pi
                return point(center: fit.center, radius: fit.radius, longitude: longitude, latitude: latitude)
            }
            output.append(Curve(kind: .verticalRib, index: ribIndex, points: points, isClosed: false))
        }

        for (ringIndex, latitude) in latitudes.enumerated() {
            let points = (0..<ringSteps).map { step in
                let longitude = (Double(step) / Double(ringSteps)) * twoPi
                return point(center: fit.center, radius: fit.radius, longitude: longitude, latitude: latitude)
            }
            output.append(Curve(kind: .horizontalRing, index: ringIndex, points: points, isClosed: true))
        }

        return output
    }

    private static func uniqueSpeakers(_ speakers: [OrbitalViewportSpeaker]) -> [OrbitalViewportSpeaker] {
        let sortedSpeakers = speakers.sorted {
            $0.channel == $1.channel ? $0.label < $1.label : $0.channel < $1.channel
        }
        var seenChannels = Set<Int>()
        return sortedSpeakers.filter { speaker in
            seenChannels.insert(speaker.channel).inserted
        }
    }

    private static func point(
        center: OVVector3,
        radius: Double,
        longitude: Double,
        latitude: Double
    ) -> OVVector3 {
        let cosLatitude = cos(latitude)
        return center + OVVector3(
            x: radius * cosLatitude * cos(longitude),
            y: radius * cosLatitude * sin(longitude),
            z: radius * sin(latitude)
        )
    }

}

struct OrbitalViewportFogUpdateKey: Equatable {
    let fogDensity: Double
    let zoom: Double
    let cameraView: OrbitalViewportCameraView
    let renderStyle: OrbitalViewportRenderStyle

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.fogDensity = configuration.fogDensity
        self.zoom = configuration.zoom
        self.cameraView = configuration.cameraView
        self.renderStyle = configuration.renderStyle
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

        let startDistance = max(0.1, cameraDistance - (0.46 + normalized * 1.08))
        let endDistance = cameraDistance + max(0.22, 2.35 - (normalized * 2.12))
        return OrbitalViewportFogConfiguration(
            isEnabled: true,
            normalizedDensity: normalized,
            startDistance: startDistance,
            endDistance: max(startDistance + 0.1, endDistance),
            densityExponent: 0.72 + normalized * 2.45
        )
    }
}

struct OrbitalViewportSnapshot: Equatable {
    let speakers: [OrbitalViewportProjectedSpeaker]
    let sources: [OrbitalViewportProjectedSource]
    let activeCount: Int
    let peakSpeaker: OrbitalViewportProjectedSpeaker

    init(configuration: OrbitalViewportRenderConfiguration) {
        let speakers = configuration.speakers.map { speaker in
            OrbitalViewportProjectedSpeaker(source: speaker, configuration: configuration)
        }
        let sources = configuration.sources.map { source in
            OrbitalViewportProjectedSource(source: source, configuration: configuration)
        }
        self.speakers = speakers
        self.sources = sources
        self.activeCount = speakers.filter { $0.peak > 0.12 }.count
        self.peakSpeaker = speakers.max(by: { $0.peak < $1.peak }) ?? OrbitalViewportProjectedSpeaker(
            source: OrbitalViewportSpeaker.referenceSpeakers[0],
            configuration: configuration
        )
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

struct OrbitalViewportProjectedSource: Identifiable, Equatable {
    let source: OrbitalViewportSourceMarker
    let rms: Double
    let peak: Double
    let rotated: OVVector3
    let screen: CGPoint
    let visible: Bool

    var id: Int { sourceID }
    var sourceID: Int { source.sourceID }
    var label: String { source.label }
    var depth: Double { rotated.z }

    init(source: OrbitalViewportSourceMarker, configuration: OrbitalViewportRenderConfiguration) {
        self.source = source
        let meter = configuration.meterSource.meter(channel: source.sourceID, timeMS: configuration.timeMS)
        self.rms = meter.rms
        self.peak = meter.peak
        let rotated = configuration.rotate(OVVector3(source))
        self.rotated = rotated
        self.screen = configuration.project(rotated)
        self.visible = configuration.isVisibleDepth(rotated.z)
    }
}

#if os(macOS)
private struct OrbitalViewportSceneColorState: Equatable {
    let red: Int
    let green: Int
    let blue: Int
    let alpha: Int

    init(_ color: NSColor) {
        let resolved = color.usingColorSpace(.deviceRGB) ?? color
        self.red = Self.bucket(resolved.redComponent)
        self.green = Self.bucket(resolved.greenComponent)
        self.blue = Self.bucket(resolved.blueComponent)
        self.alpha = Self.bucket(resolved.alphaComponent)
    }

    private static func bucket(_ value: CGFloat) -> Int {
        guard value.isFinite else {
            return 0
        }
        return Int((max(0, min(1, Double(value))) * 100_000).rounded())
    }
}

private struct OrbitalViewportSceneMaterialState: Equatable {
    let name: String?
    let diffuse: OrbitalViewportSceneColorState?
    let emission: OrbitalViewportSceneColorState?
    let multiply: OrbitalViewportSceneColorState?
    let transparency: Int
    let isDoubleSided: Bool

    init(
        name: String? = nil,
        diffuse: NSColor? = nil,
        emission: NSColor? = nil,
        multiply: NSColor? = nil,
        transparency: Double,
        isDoubleSided: Bool
    ) {
        self.name = name
        self.diffuse = diffuse.map(OrbitalViewportSceneColorState.init)
        self.emission = emission.map(OrbitalViewportSceneColorState.init)
        self.multiply = multiply.map(OrbitalViewportSceneColorState.init)
        self.transparency = Int((OrbitalViewportMath.clamp01(transparency) * 100_000).rounded())
        self.isDoubleSided = isDoubleSided
    }
}

private struct OrbitalViewportRibbedSphereCutawayUniforms: Equatable {
    let clipNormal: SIMD3<Float>
    let sceneCenter: SIMD3<Float>
    let frontClipPlane: Float

    init(clipNormal: SIMD3<Float>, sceneCenter: SIMD3<Float>, frontClipPlane: Float) {
        self.clipNormal = clipNormal
        self.sceneCenter = sceneCenter
        self.frontClipPlane = frontClipPlane
    }

    init(configuration: OrbitalViewportRenderConfiguration) {
        let fit = OrbitalViewportRibbedSpeakerSphereGeometry.fit(
            for: configuration.speakers,
            fallbackRadius: configuration.sceneScale
        )
        self.init(configuration: configuration, fit: fit)
    }

    init(
        configuration: OrbitalViewportRenderConfiguration,
        fit: OrbitalViewportRibbedSpeakerSphereGeometry.Fit
    ) {
        self.clipNormal = simd_normalize(configuration.orbitState.cameraBasis.viewDirection.simdSCN)
        self.sceneCenter = fit.center.simdSCN
        self.frontClipPlane = Float(configuration.ribbedSphereCutawayPlaneOffset(radius: fit.radius))
    }

    func depth(for point: OVVector3) -> Double {
        let scenePoint = point.simdSCN
        let depth = simd_dot(scenePoint - sceneCenter, clipNormal)
        return Double(depth)
    }

    func isVisible(point: OVVector3, showHiddenLines: Bool) -> Bool {
        showHiddenLines || depth(for: point) >= Double(frontClipPlane)
    }
}

private struct OrbitalViewportRibbedSphereCutawayPlaneState: Equatable {
    let isHidden: Bool
    let clipNormalX: Int
    let clipNormalY: Int
    let clipNormalZ: Int
    let sceneCenterX: Int
    let sceneCenterY: Int
    let sceneCenterZ: Int
    let frontClipPlane: Int
    let planeSize: Int

    init(
        isHidden: Bool,
        uniforms: OrbitalViewportRibbedSphereCutawayUniforms,
        planeSize: Double
    ) {
        self.isHidden = isHidden
        self.clipNormalX = Self.bucket(Double(uniforms.clipNormal.x))
        self.clipNormalY = Self.bucket(Double(uniforms.clipNormal.y))
        self.clipNormalZ = Self.bucket(Double(uniforms.clipNormal.z))
        self.sceneCenterX = Self.bucket(Double(uniforms.sceneCenter.x))
        self.sceneCenterY = Self.bucket(Double(uniforms.sceneCenter.y))
        self.sceneCenterZ = Self.bucket(Double(uniforms.sceneCenter.z))
        self.frontClipPlane = Self.bucket(Double(uniforms.frontClipPlane))
        self.planeSize = Self.bucket(planeSize)
    }

    private static func bucket(_ value: Double) -> Int {
        guard value.isFinite else {
            return 0
        }
        return Int((value * 100_000).rounded())
    }
}

struct OrbitalViewport3DSceneView: NSViewRepresentable {
    static let sceneFramesPerSecond = OrbitalViewportMockup.viewportAnimationFramesPerSecond
    static let rendersContinuously = false
    static let antialiasingMode: SCNAntialiasingMode = .none
    static let usesContinuousRenderDuringActiveMotion = true

    let activeFramesPerSecond: Int
    let configuration: OrbitalViewportRenderConfiguration
    let snapshot: OrbitalViewportSnapshot
    let onDragStarted: () -> Void
    let onDrag: (CGSize) -> Void
    let onDragEnded: () -> Void
    let onZoom: (Double) -> Void
    let onSelect: (Int?) -> Void
    let onFrameRateSample: (OrbitalViewportFrameRateSample) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> OrbitalViewportSceneNSView {
        #if DEBUG
        OrbitalRenderTrace.log("representable_makeNSView_enter", configuration: configuration)
        #endif
        let view = OrbitalViewportSceneNSView(frame: .zero)
        view.allowsCameraControl = false
        view.antialiasingMode = Self.antialiasingMode
        view.backgroundColor = .clear
        view.rendersContinuously = Self.rendersContinuously
        view.isPlaying = false
        view.preferredFramesPerSecond = activeFramesPerSecond
        view.delegate = context.coordinator
        view.scene = context.coordinator.scene
        view.pointOfView = context.coordinator.cameraNode
        view.onDragStarted = onDragStarted
        view.onDrag = onDrag
        view.onDragEnded = onDragEnded
        view.onZoom = onZoom
        view.onSelect = onSelect
        view.configureFrameRateMeter(theme: configuration.theme, sample: .pending)
        context.coordinator.onFrameRateSample = onFrameRateSample
        context.coordinator.setActiveFramesPerSecond(activeFramesPerSecond)
        context.coordinator.attach(to: view)
        context.coordinator.update(
            configuration: configuration,
            snapshot: snapshot
        )
        #if DEBUG
        view.updateRibbedDebugOverlay(
            configuration: configuration,
            state: context.coordinator.ribbedDebugState
        )
        #endif
        updateContinuousRenderMode(view, configuration: configuration)
        return view
    }

    func updateNSView(_ nsView: OrbitalViewportSceneNSView, context: Context) {
        #if DEBUG
        OrbitalRenderTrace.log("representable_updateNSView_enter", configuration: configuration)
        #endif
        nsView.onDragStarted = onDragStarted
        nsView.onDrag = onDrag
        nsView.onDragEnded = onDragEnded
        nsView.onZoom = onZoom
        nsView.onSelect = onSelect
        nsView.configureFrameRateMeter(theme: configuration.theme)
        context.coordinator.onFrameRateSample = onFrameRateSample
        if nsView.preferredFramesPerSecond != activeFramesPerSecond {
            nsView.preferredFramesPerSecond = activeFramesPerSecond
        }
        context.coordinator.setActiveFramesPerSecond(activeFramesPerSecond)
        context.coordinator.attach(to: nsView)
        context.coordinator.update(
            configuration: configuration,
            snapshot: snapshot
        )
        #if DEBUG
        nsView.updateRibbedDebugOverlay(
            configuration: configuration,
            state: context.coordinator.ribbedDebugState
        )
        #endif
        updateContinuousRenderMode(nsView, configuration: configuration)
    }

    private func updateContinuousRenderMode(
        _ view: OrbitalViewportSceneNSView,
        configuration: OrbitalViewportRenderConfiguration
    ) {
        #if DEBUG
        let debugForcesContinuousRender =
            OrbitalRenderTrace.isEnvironmentFlagEnabled("ORB_DEBUG_FORCE_CONTINUOUS_RENDER") ||
            OrbitalRenderTrace.isEnvironmentFlagEnabled("ORB_DEBUG_FORCE_RIBBED_GREEN")
        #else
        let debugForcesContinuousRender = false
        #endif
        let shouldRenderContinuously = debugForcesContinuousRender ||
            (Self.usesContinuousRenderDuringActiveMotion && configuration.spin)
        guard view.rendersContinuously != shouldRenderContinuously ||
            view.isPlaying != shouldRenderContinuously else {
            return
        }

        view.rendersContinuously = shouldRenderContinuously
        view.isPlaying = shouldRenderContinuously
    }

    final class Coordinator: NSObject, SCNSceneRendererDelegate {
        let scene = SCNScene()
        let rootNode = SCNNode()
        let gridPlaneNode = SCNNode()
        let ribbedSphereCutawayPlaneNode = SCNNode()
        let ribbedSphereNode = SCNNode()
        let speakerRoot = SCNNode()
        let sourceRoot = SCNNode()
        let labelRoot = SCNNode()
        let cameraNode = SCNNode()

        private weak var view: OrbitalViewportSceneNSView?
        private var gridPlaneLineNodes: [SCNNode] = []
        private var ribbedSphereVerticalNode: SCNNode?
        private var ribbedSphereHorizontalNode: SCNNode?
        private var ribbedSphereSegmentCount = 0
        private var speakerNodes: [Int: SCNNode] = [:]
        private var speakerOutlineNodes: [Int: [SCNNode]] = [:]
        private var speakerOutlineMaterialKeys: [Int: OrbitalViewportCubeOutlineMaterialUpdateKey] = [:]
        private var sourceNodes: [Int: SCNNode] = [:]
        private var labelNodes: [Int: SCNNode] = [:]
        private var speakerLabelMaterialKeys: [Int: OrbitalViewportSpeakerLabelMaterialUpdateKey] = [:]
        private let sceneMutationLock = NSRecursiveLock()
        private var animationTimer: Timer?
        private var latestConfiguration: OrbitalViewportRenderConfiguration?
        private var lastCameraKey: OrbitalViewportCameraUpdateKey?
        private var lastGridPlaneKey: OrbitalViewportGridPlaneUpdateKey?
        private var lastRibbedSphereTopologyKey: OrbitalViewportRibbedSpeakerSphereTopologyKey?
        private var lastRibbedSphereUpdateKey: OrbitalViewportRibbedSpeakerSphereUpdateKey?
        private var lastSpeakerGeometryKey: OrbitalViewportSpeakerGeometryUpdateKey?
        private var lastSpeakerLabelGeometryKey: OrbitalViewportSpeakerLabelGeometryUpdateKey?
        private var lastSpeakerVisibilityKey: OrbitalViewportSpeakerVisibilityUpdateKey?
        private var lastSpeakerMaterialKey: OrbitalViewportSpeakerMaterialUpdateKey?
        private var lastSpeakerMaterialVisualSignatureKey: OrbitalViewportSpeakerMaterialVisualSignatureKey?
        private var lastSourcePoseUpdateKey: OrbitalViewportSourcePoseUpdateKey?
        private var lastSourceMaterialUpdateKey: OrbitalViewportSourceMaterialUpdateKey?
        private var lastSourceMaterialVisualSignatureKey: OrbitalViewportSourceMaterialVisualSignatureKey?
        private var lastFogKey: OrbitalViewportFogUpdateKey?
        private var sceneMaterialStates: [ObjectIdentifier: OrbitalViewportSceneMaterialState] = [:]
        private var lastRibbedSphereCutawayPlaneState: OrbitalViewportRibbedSphereCutawayPlaneState?
        private var lastRibbedSphereCutawayUniforms: OrbitalViewportRibbedSphereCutawayUniforms?
        private var lastRibbedSphereCutawayShowHiddenLines: Bool?
        private var ribbedSphereFit = OrbitalViewportRibbedSpeakerSphereGeometry.Fit(center: .zero, radius: 1)
        private var lastRenderedAnimationTimeMS: Double?
        private var gridPlaneSpacing = OrbitalViewportGridPlaneGeometry.defaultSpacing
        private var gridPlaneThickness = OrbitalViewportGridPlaneGeometry.defaultThickness
        private var activeFramesPerSecond = OrbitalViewport3DSceneView.sceneFramesPerSecond
        private var frameRateMonitor = OrbitalViewportFrameRateMonitor(
            targetFramesPerSecond: OrbitalViewport3DSceneView.sceneFramesPerSecond
        )
        private var instrumentation = OrbitalViewportRenderInstrumentationSnapshot()
        private let gridPlaneRenderingOrder = -1001
        private let ribbedSphereCutawayPlaneRenderingOrder = -1000
        #if DEBUG
        private var ribbedDebugApplySequence = 0
        private var ribbedDebugLastWriter = "none"
        private var ribbedDebugMaterialNames = "none"
        #endif
        var onFrameRateSample: (OrbitalViewportFrameRateSample) -> Void = { _ in }

        private(set) var gridPlaneBuildCount = 0
        private(set) var ribbedSphereBuildCount = 0
        private(set) var speakerRebuildCount = 0
        private(set) var sourceUpdateCount = 0
        private(set) var labelRebuildCount = 0

        var ribbedSphereSceneNodeCountForTests: Int {
            ribbedSphereNode.childNodes.count
        }

        var ribbedSphereSegmentCountForTests: Int {
            ribbedSphereSegmentCount
        }

        #if DEBUG
        var ribbedDebugState: OrbitalViewportRibbedDebugState {
            OrbitalViewportRibbedDebugState(
                buildStamp: OrbitalRenderTrace.buildStamp,
                lastApplySequence: ribbedDebugApplySequence,
                lastWriter: ribbedDebugLastWriter,
                materialNames: ribbedDebugMaterialNames
            )
        }
        #endif

        func speakerNodeHiddenForTests(channel: Int) -> Bool? {
            speakerNodes[channel]?.isHidden
        }

        func speakerLabelNodeHiddenForTests(channel: Int) -> Bool? {
            labelNodes[channel]?.isHidden
        }

        var ribbedSphereCutawayPlaneHiddenForTests: Bool {
            ribbedSphereCutawayPlaneNode.isHidden
        }

        var firstRibbedSphereCutawayShaderForTests: String? {
            ribbedSphereVerticalNode?.geometry?.firstMaterial?.shaderModifiers?[.surface]
        }

        var firstRibbedSphereCutawayGeometryShaderForTests: String? {
            ribbedSphereVerticalNode?.geometry?.firstMaterial?.shaderModifiers?[.geometry]
        }

        var firstRibbedSphereCutawayHiddenLinesVisibleForTests: Bool? {
            lastRibbedSphereCutawayShowHiddenLines
        }

        var firstRibbedSphereCutawayFrontClipPlaneForTests: Double? {
            lastRibbedSphereCutawayUniforms.map { Double($0.frontClipPlane) }
        }

        func firstRibbedSphereCutawayDepthForTests(point: OVVector3) -> Double? {
            guard let uniforms = lastRibbedSphereCutawayUniforms else {
                return nil
            }
            return uniforms.depth(for: point)
        }

        func firstRibbedSphereCutawayVisibleForTests(point: OVVector3) -> Bool? {
            guard let uniforms = lastRibbedSphereCutawayUniforms,
                let showHiddenLines = firstRibbedSphereCutawayHiddenLinesVisibleForTests else {
                return nil
            }
            return uniforms.isVisible(point: point, showHiddenLines: showHiddenLines)
        }

        @discardableResult
        func renderActiveFrameForTests(configuration: OrbitalViewportRenderConfiguration, timeMS: Double) -> Bool {
            guard sceneMutationLock.try() else {
                return false
            }
            defer { sceneMutationLock.unlock() }
            guard configuration.spin else {
                return false
            }

            updateCameraForActiveRendererFrame(
                configuration: configuration.frameConfiguration(timeMS: timeMS),
                timeMS: timeMS
            )
            return true
        }

        func withSceneMutationLockHeldByBackgroundThreadForTests(_ body: () -> Void) {
            let didLock = DispatchSemaphore(value: 0)
            let shouldUnlock = DispatchSemaphore(value: 0)
            let didUnlock = DispatchSemaphore(value: 0)
            let lock = sceneMutationLock

            DispatchQueue.global(qos: .userInitiated).async {
                lock.lock()
                didLock.signal()
                shouldUnlock.wait()
                lock.unlock()
                didUnlock.signal()
            }

            didLock.wait()
            defer {
                shouldUnlock.signal()
                didUnlock.wait()
            }
            body()
        }

        var instrumentationSnapshotForTests: OrbitalViewportRenderInstrumentationSnapshot {
            var snapshot = instrumentation
            let cubeVUSnapshot = OrbitalViewportCubeVUSceneKitMaterial.diagnosticsSnapshotForTests()
            snapshot.cubeVUMaterialUpdateCount = cubeVUSnapshot.materialUpdateCount
            snapshot.cubeVUFaceTextureCacheHitCount = cubeVUSnapshot.faceTextureCacheHitCount
            snapshot.cubeVUFaceTextureCacheMissCount = cubeVUSnapshot.faceTextureCacheMissCount
            snapshot.cubeVUFaceTextureGenerationCount = cubeVUSnapshot.faceTextureGenerationCount
            snapshot.cubeVUFaceTextureEvictionCount = cubeVUSnapshot.faceTextureEvictionCount
            snapshot.cubeVUUniformWriteCount = cubeVUSnapshot.uniformWriteCount
            snapshot.cubeVUTextureAssignmentCount = cubeVUSnapshot.textureAssignmentCount
            return snapshot
        }

        func resetInstrumentationForTests() {
            instrumentation = OrbitalViewportRenderInstrumentationSnapshot()
            OrbitalViewportCubeVUSceneKitMaterial.resetDiagnosticsForTests()
        }

        override init() {
            super.init()
            scene.rootNode.addChildNode(rootNode)
            rootNode.addChildNode(gridPlaneNode)
            rootNode.addChildNode(ribbedSphereCutawayPlaneNode)
            rootNode.addChildNode(ribbedSphereNode)
            rootNode.addChildNode(speakerRoot)
            rootNode.addChildNode(sourceRoot)
            rootNode.addChildNode(labelRoot)
            configureCamera()
            configureLights()
            configureRibbedSphereCutawayPlane()
            buildGridPlane()
            buildRibbedSpeakerSphere(
                speakers: OrbitalViewportSpeaker.referenceSpeakers,
                verticalRibs: OrbitalViewportMockup.defaultRibbedSphereVerticalRibs,
                horizontalRings: OrbitalViewportMockup.defaultRibbedSphereHorizontalRings,
                thickness: OrbitalViewportMockup.defaultRibbedSphereThickness,
                fallbackRadius: 1
            )
            rebuildSpeakers(
                speakers: OrbitalViewportSpeaker.referenceSpeakers,
                shape: .prism,
                speakerSize: OrbitalViewportMath.speakerSize(fromSlider: 50),
                speakerLabelFont: .systemDefault,
                speakerLabelSizeScale: 1
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
            sceneMutationLock.lock()
            defer { sceneMutationLock.unlock() }
            let normalizedFramesPerSecond = OrbitalViewportFrameRate.normalized(framesPerSecond)
            guard activeFramesPerSecond != normalizedFramesPerSecond else {
                return
            }

            activeFramesPerSecond = normalizedFramesPerSecond
            lastRenderedAnimationTimeMS = nil
            frameRateMonitor = OrbitalViewportFrameRateMonitor(targetFramesPerSecond: normalizedFramesPerSecond)
            restartAnimationTimer()
        }

        func update(
            configuration: OrbitalViewportRenderConfiguration,
            snapshot: OrbitalViewportSnapshot
        ) {
            sceneMutationLock.lock()
            defer { sceneMutationLock.unlock() }
            #if DEBUG
            OrbitalRenderTrace.log("coordinator_update_enter", configuration: configuration)
            #endif
            _ = snapshot
            latestConfiguration = configuration

            let geometryKey = OrbitalViewportSpeakerGeometryUpdateKey(configuration: configuration)
            if lastSpeakerGeometryKey != geometryKey {
                rebuildSpeakers(
                    speakers: configuration.speakers,
                    shape: configuration.speakerShape,
                    speakerSize: configuration.speakerSize,
                    speakerLabelFont: configuration.speakerLabelFont,
                    speakerLabelSizeScale: configuration.speakerLabelSizeScale
                )
            } else {
                let labelGeometryKey = OrbitalViewportSpeakerLabelGeometryUpdateKey(configuration: configuration)
                if lastSpeakerLabelGeometryKey != labelGeometryKey {
                    rebuildSpeakerLabels(
                        speakers: configuration.speakers,
                        font: configuration.speakerLabelFont,
                        sizeScale: configuration.speakerLabelSizeScale
                    )
                }
            }

            renderScene(configuration: configuration)
        }

        func renderHeadlessFrameForBenchmark(configuration: OrbitalViewportRenderConfiguration) {
            sceneMutationLock.lock()
            defer { sceneMutationLock.unlock() }
            latestConfiguration = configuration
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
            sceneMutationLock.lock()
            defer { sceneMutationLock.unlock() }
            instrumentation.renderAnimationFrameAttemptCount += 1
            guard let latestConfiguration else {
                return
            }
            let frameTimeMS = currentTimeMS()
            let framesPerSecond = timerFramesPerSecond(configuration: latestConfiguration)
            let minimumFrameIntervalMS = 1000 / Double(framesPerSecond)
            if let lastRenderedAnimationTimeMS,
               frameTimeMS - lastRenderedAnimationTimeMS < minimumFrameIntervalMS {
                instrumentation.renderAnimationFrameSkippedForCadenceCount += 1
                return
            }

            lastRenderedAnimationTimeMS = frameTimeMS
            instrumentation.renderAnimationFrameDrawCount += 1
            let frameConfiguration = latestConfiguration.frameConfiguration(timeMS: frameTimeMS)
            #if DEBUG
            OrbitalRenderTrace.log(
                "frame_material_writer",
                configuration: frameConfiguration,
                extra: "timer_renderAnimationFrame"
            )
            #endif
            renderScene(configuration: frameConfiguration)
        }

        private func timerFramesPerSecond(configuration: OrbitalViewportRenderConfiguration) -> Int {
            if configuration.spin {
                return max(1, min(30, configuration.meterOnlyViewportFramesPerSecond))
            }

            return OrbitalViewportRenderScheduler.targetFramesPerSecond(
                activeFramesPerSecond: activeFramesPerSecond,
                meterOnlyFramesPerSecond: configuration.meterOnlyViewportFramesPerSecond,
                isActiveMotion: false
            )
        }

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            _ = time
            guard sceneMutationLock.try() else {
                return
            }
            defer { sceneMutationLock.unlock() }
            guard let latestConfiguration,
                  latestConfiguration.spin else {
                return
            }

            let frameTimeMS = currentTimeMS()
            let frameConfiguration = latestConfiguration.frameConfiguration(timeMS: frameTimeMS)
            updateCameraForActiveRendererFrame(configuration: frameConfiguration, timeMS: frameTimeMS)
        }

        private func renderScene(configuration: OrbitalViewportRenderConfiguration) {
            instrumentation.renderSceneCount += 1
            let snapshot = OrbitalViewportSnapshot(configuration: configuration)
            let cameraKey = OrbitalViewportCameraUpdateKey(configuration: configuration)
            let gridPlaneKey = OrbitalViewportGridPlaneUpdateKey(configuration: configuration)
            let ribbedSphereTopologyKey = OrbitalViewportRibbedSpeakerSphereTopologyKey(configuration: configuration)
            let ribbedSphereUpdateKey = OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: configuration)
            let visibilityKey = OrbitalViewportSpeakerVisibilityUpdateKey(configuration: configuration)
            let materialKey = OrbitalViewportSpeakerMaterialUpdateKey(configuration: configuration)
            let materialVisualSignatureKey = OrbitalViewportSpeakerMaterialVisualSignatureKey(
                configuration: configuration,
                snapshot: snapshot
            )
            let sourcePoseKey = OrbitalViewportSourcePoseUpdateKey(configuration: configuration)
            let sourceMaterialKey = OrbitalViewportSourceMaterialUpdateKey(configuration: configuration)
            let sourceMaterialVisualSignatureKey = OrbitalViewportSourceMaterialVisualSignatureKey(
                configuration: configuration,
                snapshot: snapshot
            )
            let fogKey = OrbitalViewportFogUpdateKey(configuration: configuration)
            #if DEBUG
            OrbitalRenderTrace.log(
                "ribbed_update_key_compare",
                configuration: configuration,
                extra: "old=\(String(describing: lastRibbedSphereUpdateKey)) new=\(ribbedSphereUpdateKey) changed=\(lastRibbedSphereUpdateKey != ribbedSphereUpdateKey)"
            )
            #endif

            var didBeginTransaction = false
            var didMutateScene = false
            func beginSceneTransactionIfNeeded() {
                guard !didBeginTransaction else {
                    return
                }

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0
                SCNTransaction.disableActions = true
                didBeginTransaction = true
            }

            func performSceneMutation(_ body: () -> Bool) {
                beginSceneTransactionIfNeeded()
                didMutateScene = body() || didMutateScene
            }

            defer {
                if didBeginTransaction {
                    SCNTransaction.commit()
                }
            }

            if lastCameraKey != cameraKey {
                performSceneMutation {
                    updateCamera(configuration: configuration)
                    if configuration.showRibbedSpeakerSphere {
                        _ = updateRibbedSphereCutawayPlane(configuration: configuration)
                    }
                    return true
                }
                lastCameraKey = cameraKey
            }
            if lastGridPlaneKey != gridPlaneKey {
                performSceneMutation {
                    updateGridPlane(configuration: configuration)
                }
                lastGridPlaneKey = gridPlaneKey
            }
            if lastRibbedSphereTopologyKey != ribbedSphereTopologyKey {
                performSceneMutation {
                    buildRibbedSpeakerSphere(
                        speakers: configuration.speakers,
                        verticalRibs: configuration.ribbedSphereVerticalRibs,
                        horizontalRings: configuration.ribbedSphereHorizontalRings,
                        thickness: configuration.ribbedSphereThickness,
                        fallbackRadius: configuration.sceneScale
                    )
                    return true
                }
                lastRibbedSphereTopologyKey = ribbedSphereTopologyKey
                lastRibbedSphereUpdateKey = nil
            }
            if lastRibbedSphereUpdateKey != ribbedSphereUpdateKey {
                performSceneMutation {
                    updateRibbedSpeakerSphere(configuration: configuration)
                }
                lastRibbedSphereUpdateKey = ribbedSphereUpdateKey
            }

            let shouldUpdateSpeakerVisibility = lastSpeakerVisibilityKey != visibilityKey
            let speakerMaterialCadenceChanged = lastSpeakerMaterialKey != materialKey
            let speakerMaterialVisualChanged = lastSpeakerMaterialVisualSignatureKey != materialVisualSignatureKey
            let shouldUpdateSpeakerMaterial = speakerMaterialCadenceChanged && speakerMaterialVisualChanged
            if speakerMaterialCadenceChanged && !speakerMaterialVisualChanged {
                instrumentation.speakerMaterialUnchangedFrameSkipCount += 1
                lastSpeakerMaterialKey = materialKey
            }
            if shouldUpdateSpeakerVisibility || shouldUpdateSpeakerMaterial {
                performSceneMutation {
                    updateSpeakers(
                        configuration: configuration,
                        snapshot: snapshot,
                        updateVisibility: shouldUpdateSpeakerVisibility,
                        updateMaterial: shouldUpdateSpeakerMaterial
                    )
                }
                lastSpeakerVisibilityKey = visibilityKey
                if shouldUpdateSpeakerMaterial {
                    lastSpeakerMaterialKey = materialKey
                    lastSpeakerMaterialVisualSignatureKey = materialVisualSignatureKey
                }
            }

            if lastSourcePoseUpdateKey != sourcePoseKey {
                performSceneMutation {
                    updateSourcePoseAndVisibility(configuration: configuration, snapshot: snapshot)
                }
                lastSourcePoseUpdateKey = sourcePoseKey
            }

            let sourceMaterialCadenceChanged = lastSourceMaterialUpdateKey != sourceMaterialKey
            let sourceMaterialVisualChanged = lastSourceMaterialVisualSignatureKey != sourceMaterialVisualSignatureKey
            let shouldUpdateSourceMaterial = sourceMaterialCadenceChanged && sourceMaterialVisualChanged
            if sourceMaterialCadenceChanged && !sourceMaterialVisualChanged {
                instrumentation.sourceMaterialUnchangedFrameSkipCount += 1
                lastSourceMaterialUpdateKey = sourceMaterialKey
            }
            if shouldUpdateSourceMaterial {
                performSceneMutation {
                    updateSourceMaterial(configuration: configuration, snapshot: snapshot)
                }
                lastSourceMaterialUpdateKey = sourceMaterialKey
                lastSourceMaterialVisualSignatureKey = sourceMaterialVisualSignatureKey
            }

            if lastFogKey != fogKey {
                performSceneMutation {
                    updateFog(configuration: configuration)
                    if configuration.showRibbedSpeakerSphere {
                        _ = updateRibbedSphereCutawayPlane(configuration: configuration)
                    }
                    return true
                }
                lastFogKey = fogKey
            }

            if didMutateScene {
                instrumentation.needsDisplayCount += 1
                view?.needsDisplay = true
            } else {
                instrumentation.needsDisplaySkippedCount += 1
                instrumentation.renderSceneNoOpCount += 1
            }

            if didMutateScene,
               !configuration.spin,
               view != nil,
               let sample = frameRateMonitor.recordFrame(at: currentTimeMS()) {
                instrumentation.frameRateSampleCount += 1
                view?.updateFrameRateMeter(sample: sample)
                onFrameRateSample(sample)
            }
        }

        private func updateCameraForActiveRendererFrame(
            configuration: OrbitalViewportRenderConfiguration,
            timeMS: Double
        ) {
            let cameraKey = OrbitalViewportCameraUpdateKey(configuration: configuration)
            if lastCameraKey != cameraKey {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0
                SCNTransaction.disableActions = true
                updateCamera(configuration: configuration)
                if configuration.showRibbedSpeakerSphere {
                    _ = updateRibbedSphereCutawayPlane(configuration: configuration)
                }
                SCNTransaction.commit()
                lastCameraKey = cameraKey
            }

            guard view != nil,
                  let sample = frameRateMonitor.recordFrame(at: timeMS) else {
                return
            }

            instrumentation.frameRateSampleCount += 1
            DispatchQueue.main.async { [weak self] in
                self?.view?.updateFrameRateMeter(sample: sample)
                self?.onFrameRateSample(sample)
            }
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

        private func buildGridPlane(
            spacing: Double = OrbitalViewportGridPlaneGeometry.defaultSpacing,
            thickness: Double = OrbitalViewportGridPlaneGeometry.defaultThickness
        ) {
            gridPlaneBuildCount += 1
            instrumentation.gridPlaneUpdateCount += 1
            gridPlaneNode.childNodes.forEach {
                forgetMaterialStates(in: $0)
                $0.removeFromParentNode()
            }
            gridPlaneLineNodes.removeAll()
            gridPlaneSpacing = OrbitalViewportGridPlaneGeometry.normalizedSpacing(spacing)
            gridPlaneThickness = OrbitalViewportGridPlaneGeometry.normalizedThickness(thickness)
            gridPlaneNode.name = "grid-plane"
            gridPlaneNode.isHidden = true

            for line in OrbitalViewportGridPlaneGeometry.lineSegments(spacing: gridPlaneSpacing) {
                let node = cylinderNode(
                    from: line.start,
                    to: line.end,
                    radius: OrbitalViewportGridPlaneGeometry.radius(
                        for: line,
                        thickness: gridPlaneThickness
                    )
                )
                node.name = line.isMajor ? "grid-plane-major-line" : "grid-plane-line"
                node.renderingOrder = gridPlaneRenderingOrder
                let material = SCNMaterial()
                material.lightingModel = .constant
                material.isDoubleSided = true
                node.geometry?.materials = [material]
                gridPlaneNode.addChildNode(node)
                gridPlaneLineNodes.append(node)
            }
        }

        private func updateGridPlane(configuration: OrbitalViewportRenderConfiguration) -> Bool {
            instrumentation.gridPlaneUpdateCount += 1
            var didMutate = false
            let isHidden = !configuration.showGridPlane
            if gridPlaneNode.isHidden != isHidden {
                gridPlaneNode.isHidden = isHidden
                didMutate = true
            }
            guard configuration.showGridPlane else {
                return didMutate
            }

            let lineSegments = OrbitalViewportGridPlaneGeometry.lineSegments(spacing: configuration.gridPlaneSpacing)
            if gridPlaneLineNodes.count != lineSegments.count ||
                abs(gridPlaneSpacing - configuration.gridPlaneSpacing) > 0.000_001 ||
                abs(gridPlaneThickness - configuration.gridPlaneThickness) > 0.000_001 {
                buildGridPlane(
                    spacing: configuration.gridPlaneSpacing,
                    thickness: configuration.gridPlaneThickness
                )
                gridPlaneNode.isHidden = false
                didMutate = true
            }

            let theme = configuration.gridPlaneTheme
            let structureColor = theme.structure
            let axisColor = theme.equator

            for (index, lineNode) in gridPlaneLineNodes.enumerated() {
                let line = lineSegments[index]
                didMutate = setMaterial(
                    lineNode.geometry?.firstMaterial,
                    color: line.isMajor ? axisColor : structureColor,
                    alpha: OrbitalViewportGridPlaneGeometry.alpha(
                        for: line,
                        visibility: configuration.gridPlaneVisibility
                    )
                ) || didMutate
            }

            return didMutate
        }

        private func updateCamera(configuration: OrbitalViewportRenderConfiguration) {
            instrumentation.cameraUpdateCount += 1
            let basis = configuration.orbitState.cameraBasis
            let cameraDistance = basis.viewDirection * (basis.distance * configuration.sceneScale)
            cameraNode.camera?.orthographicScale = (2.25 * configuration.sceneScale) / configuration.zoom
            cameraNode.camera?.zFar = max(20, 24 * configuration.sceneScale)
            cameraNode.position = (configuration.sceneCenter + cameraDistance).scn
            cameraNode.look(
                at: configuration.sceneCenter.scn,
                up: basis.up.scn,
                localFront: SCNVector3(0, 0, -1)
            )
        }

        private func buildRibbedSpeakerSphere(
            speakers: [OrbitalViewportSpeaker],
            verticalRibs: Int,
            horizontalRings: Int,
            thickness: Double,
            fallbackRadius: Double
        ) {
            ribbedSphereBuildCount += 1
            instrumentation.ribbedSphereTopologyBuildCount += 1
            ribbedSphereNode.childNodes.forEach {
                forgetMaterialStates(in: $0)
                $0.removeFromParentNode()
            }
            ribbedSphereVerticalNode = nil
            ribbedSphereHorizontalNode = nil
            ribbedSphereSegmentCount = 0
            ribbedSphereNode.name = "ribbed-speaker-sphere"
            ribbedSphereNode.isHidden = true

            let radius = OrbitalViewportRibbedSpeakerSphereGeometry.baseStrutRadius *
                OrbitalViewportRibbedSpeakerSphereGeometry.normalizedThickness(thickness)
            ribbedSphereFit = OrbitalViewportRibbedSpeakerSphereGeometry.fit(
                for: speakers,
                fallbackRadius: fallbackRadius
            )
            let curves = OrbitalViewportRibbedSpeakerSphereGeometry.curves(
                for: speakers,
                verticalRibs: verticalRibs,
                horizontalRings: horizontalRings,
                fallbackRadius: fallbackRadius
            )
            ribbedSphereSegmentCount = curves.reduce(0) { $0 + $1.segmentCount }

            let verticalCurves = curves.filter { $0.kind == .verticalRib }
            if let verticalNode = makeRibbedSpeakerSphereBatchNode(
                curves: verticalCurves,
                radius: radius,
                name: "ribbed-speaker-sphere-vertical-ribs"
            ) {
                ribbedSphereNode.addChildNode(verticalNode)
                ribbedSphereVerticalNode = verticalNode
            }

            let horizontalCurves = curves.filter { $0.kind == .horizontalRing }
            if let horizontalNode = makeRibbedSpeakerSphereBatchNode(
                curves: horizontalCurves,
                radius: radius,
                name: "ribbed-speaker-sphere-horizontal-rings"
            ) {
                ribbedSphereNode.addChildNode(horizontalNode)
                ribbedSphereHorizontalNode = horizontalNode
            }
            instrumentation.ribbedSphereSegmentNodeBuildCount += ribbedSphereNode.childNodes.count
        }

        private func rebuildSpeakers(
            speakers: [OrbitalViewportSpeaker],
            shape: OrbitalViewportSpeakerShape,
            speakerSize: Double,
            speakerLabelFont: OrbitalViewportSpeakerLabelFont,
            speakerLabelSizeScale: Double
        ) {
            speakerRebuildCount += 1
            speakerRoot.childNodes.forEach {
                forgetMaterialStates(in: $0)
                $0.removeFromParentNode()
            }
            speakerNodes.removeAll()
            speakerOutlineNodes.removeAll()
            speakerOutlineMaterialKeys.removeAll()
            lastSpeakerGeometryKey = OrbitalViewportSpeakerGeometryUpdateKey(
                speakerShape: shape,
                speakerSize: speakerSize,
                speakers: speakers
            )

            for speaker in speakers {
                let node = makeSpeakerNode(
                    speaker: speaker,
                    shape: shape,
                    speakerSize: speakerSize
                )
                node.name = "speaker-\(speaker.channel)"
                speakerRoot.addChildNode(node)
                speakerNodes[speaker.channel] = node
                speakerOutlineNodes[speaker.channel] = node.childNodes.filter {
                    $0.name?.hasPrefix("speaker-outline-\(speaker.channel)-") == true
                }
            }

            rebuildSpeakerLabels(speakers: speakers, font: speakerLabelFont, sizeScale: speakerLabelSizeScale)
        }

        private func rebuildSpeakerLabels(
            speakers: [OrbitalViewportSpeaker],
            font: OrbitalViewportSpeakerLabelFont,
            sizeScale: Double
        ) {
            labelRebuildCount += 1
            labelRoot.childNodes.forEach {
                forgetMaterialStates(in: $0)
                $0.removeFromParentNode()
            }
            labelNodes.removeAll()
            speakerLabelMaterialKeys.removeAll()
            lastSpeakerLabelGeometryKey = OrbitalViewportSpeakerLabelGeometryUpdateKey(
                speakerLabelFont: font,
                speakerLabelSizeScale: sizeScale
            )
            lastSpeakerVisibilityKey = nil
            lastSpeakerMaterialKey = nil
            lastSpeakerMaterialVisualSignatureKey = nil

            for speaker in speakers {
                let label = makeLabelNode(channel: speaker.channel, font: font, sizeScale: sizeScale)
                label.name = "speaker-label-\(speaker.channel)"
                label.position = (OVVector3(speaker) * 1.18).scn
                labelRoot.addChildNode(label)
                labelNodes[speaker.channel] = label
            }
        }

        private func makeSpeakerNode(
            speaker: OrbitalViewportSpeaker,
            shape: OrbitalViewportSpeakerShape,
            speakerSize: Double
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
                let depth = short
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

        private func makeLabelNode(
            channel: Int,
            font: OrbitalViewportSpeakerLabelFont,
            sizeScale: Double
        ) -> SCNNode {
            if font.usesTextureBackedSceneKitLabel {
                return makeTextureBackedLabelNode(channel: channel, font: font, sizeScale: sizeScale)
            }

            let text = SCNText(string: font.speakerLabelText(channel: channel), extrusionDepth: 0.0008)
            text.font = font.nsFont(
                pointSize: OrbitalViewportSceneMetrics.speakerLabelFontPointSize * CGFloat(sizeScale)
            )
            text.flatness = font.sceneKitTextFlatness
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

        private func makeTextureBackedLabelNode(
            channel: Int,
            font: OrbitalViewportSpeakerLabelFont,
            sizeScale: Double
        ) -> SCNNode {
            let image = makeLabelTexture(
                text: font.speakerLabelText(channel: channel),
                font: font.nsFont(
                    pointSize: OrbitalViewportSceneMetrics.speakerLabelTextureFontPointSize * CGFloat(sizeScale)
                )
            )
            let plane = SCNPlane(
                width: OrbitalViewportSceneMetrics.speakerLabelTextureWidth * CGFloat(sizeScale),
                height: OrbitalViewportSceneMetrics.speakerLabelTextureHeight * CGFloat(sizeScale)
            )
            let material = SCNMaterial()
            material.isDoubleSided = true
            material.lightingModel = .constant
            material.readsFromDepthBuffer = false
            material.writesToDepthBuffer = false
            material.diffuse.contents = image
            material.multiply.contents = NSColor.white
            material.transparency = 0.94
            material.blendMode = .alpha
            plane.materials = [material]

            let node = SCNNode(geometry: plane)
            node.renderingOrder = 1000
            node.constraints = [SCNBillboardConstraint()]
            return node
        }

        private func makeLabelTexture(text: String, font: NSFont) -> NSImage {
            let size = NSSize(width: 160, height: 80)
            let image = NSImage(size: size)
            image.lockFocus()
            NSColor.clear.setFill()
            NSRect(origin: .zero, size: size).fill()

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.white,
                .paragraphStyle: paragraph
            ]
            let string = NSAttributedString(string: text, attributes: attributes)
            let textSize = string.size()
            let rect = NSRect(
                x: 0,
                y: max(0, (size.height - textSize.height) * 0.5),
                width: size.width,
                height: textSize.height
            )
            string.draw(in: rect)
            image.unlockFocus()
            return image
        }

        private func forgetMaterialStates(in node: SCNNode) {
            node.geometry?.materials.forEach {
                let materialID = ObjectIdentifier($0)
                sceneMaterialStates.removeValue(forKey: materialID)
            }
            node.childNodes.forEach { forgetMaterialStates(in: $0) }
        }

        private func updateRibbedSpeakerSphere(configuration: OrbitalViewportRenderConfiguration) -> Bool {
            let isHidden = !configuration.showRibbedSpeakerSphere
            var didMutate = false
            if ribbedSphereNode.isHidden != isHidden {
                instrumentation.ribbedSphereHiddenStateWriteCount += 1
                ribbedSphereNode.isHidden = isHidden
                didMutate = true
            }
            didMutate = updateRibbedSphereCutawayPlane(configuration: configuration) || didMutate
            guard configuration.showRibbedSpeakerSphere else {
                return didMutate
            }
            #if DEBUG
            if OrbitalRenderTrace.isEnvironmentFlagEnabled("ORB_DEBUG_FORCE_RIBBED_GREEN") {
                let didForceGreen = forceDebugRibbedSphereGreen(ribbedSphereNode, reason: "live_path_probe")
                view?.rendersContinuously = true
                view?.isPlaying = true
                view?.needsDisplay = true
                return didForceGreen || didMutate
            }
            #endif
            instrumentation.ribbedSphereMaterialUpdateCount += 1

            let theme = configuration.geodesicTheme
            let verticalRibColor = sceneColor(configuration.geodesicColor(theme.accent))
            let horizontalRingColor = sceneColor(configuration.geodesicColor(theme.accent))
            let visibilityAlpha = configuration.showHiddenLines
                ? 0.92
                : OrbitalViewportRibbedSpeakerSphereGeometry.frontLineAlpha
            didMutate = updateRibbedSpeakerSphereBatchMaterial(
                ribbedSphereVerticalNode,
                lane: "vertical",
                configuration: configuration,
                color: verticalRibColor,
                alpha: 0.74 * visibilityAlpha
            ) || didMutate
            didMutate = updateRibbedSpeakerSphereBatchMaterial(
                ribbedSphereHorizontalNode,
                lane: "horizontal",
                configuration: configuration,
                color: horizontalRingColor,
                alpha: 0.64 * visibilityAlpha
            ) || didMutate
            #if DEBUG
            recordRibbedMaterialApply(
                configuration: configuration,
                verticalColor: verticalRibColor,
                horizontalColor: horizontalRingColor
            )
            #endif
            return didMutate
        }

        #if DEBUG
        @discardableResult
        private func forceDebugRibbedSphereGreen(_ root: SCNNode, reason: String) -> Bool {
            var didMutate = false
            root.enumerateChildNodes { node, _ in
                guard let geometry = node.geometry else {
                    return
                }

                node.name = [node.name, "DEBUG_FORCE_RIBBED_GREEN", reason]
                    .compactMap { $0 }
                    .joined(separator: ".")

                for material in geometry.materials {
                    let materialID = ObjectIdentifier(material)
                    sceneMaterialStates.removeValue(forKey: materialID)
                    material.name = "DEBUG_FORCE_GREEN_\(reason)"
                    material.diffuse.contents = NSColor.systemGreen
                    material.emission.contents = NSColor.systemGreen
                    material.ambient.contents = NSColor.systemGreen
                    material.multiply.contents = NSColor.white
                    material.transparent.contents = NSColor.white
                    material.shaderModifiers = nil
                    didMutate = true
                }
            }

            if didMutate {
                ribbedDebugApplySequence += 1
                ribbedDebugLastWriter = "debug_force_green_\(reason)"
                ribbedDebugMaterialNames = ribbedSphereMaterialNames()
                if let latestConfiguration {
                    OrbitalRenderTrace.log(
                        "ribbed_force_green_apply",
                        configuration: latestConfiguration,
                        extra: "materials=\(ribbedDebugMaterialNames)"
                    )
                }
            }
            return didMutate
        }

        private func recordRibbedMaterialApply(
            configuration: OrbitalViewportRenderConfiguration,
            verticalColor: NSColor,
            horizontalColor: NSColor
        ) {
            ribbedDebugApplySequence += 1
            ribbedDebugLastWriter = "ribbed_material_apply"
            ribbedDebugMaterialNames = ribbedSphereMaterialNames()
            let materialIDs = ribbedSphereMaterials()
                .map { String(describing: ObjectIdentifier($0)) }
                .joined(separator: ",")
            OrbitalRenderTrace.log(
                "ribbed_material_apply",
                configuration: configuration,
                extra: "vertical=\(debugColorDescription(verticalColor)) horizontal=\(debugColorDescription(horizontalColor)) materialIDs=\(materialIDs) names=\(ribbedDebugMaterialNames)"
            )
        }

        private func ribbedSphereMaterials() -> [SCNMaterial] {
            [ribbedSphereVerticalNode, ribbedSphereHorizontalNode]
                .compactMap { $0?.geometry?.firstMaterial }
        }

        private func ribbedSphereMaterialNames() -> String {
            ribbedSphereMaterials()
                .map { $0.name ?? "nil" }
                .joined(separator: ",")
        }

        private func debugColorDescription(_ color: NSColor) -> String {
            let resolved = color.usingColorSpace(.deviceRGB) ?? color
            return String(
                format: "r=%.3f g=%.3f b=%.3f a=%.3f",
                resolved.redComponent,
                resolved.greenComponent,
                resolved.blueComponent,
                resolved.alphaComponent
            )
        }
        #endif

        private func configureRibbedSphereCutawayPlane() {
            let plane = SCNPlane(width: 2, height: 2)
            let material = SCNMaterial()
            material.isDoubleSided = true
            material.lightingModel = .constant
            material.diffuse.contents = NSColor.white
            material.readsFromDepthBuffer = false
            material.writesToDepthBuffer = true
            material.colorBufferWriteMask = []
            plane.materials = [material]

            ribbedSphereCutawayPlaneNode.name = "ribbed-speaker-sphere-cutaway-plane"
            ribbedSphereCutawayPlaneNode.geometry = plane
            ribbedSphereCutawayPlaneNode.isHidden = true
            ribbedSphereCutawayPlaneNode.renderingOrder = ribbedSphereCutawayPlaneRenderingOrder
        }

        private func updateRibbedSphereCutawayPlane(
            configuration: OrbitalViewportRenderConfiguration
        ) -> Bool {
            let fit = ribbedSphereFit
            let uniforms = OrbitalViewportRibbedSphereCutawayUniforms(
                configuration: configuration,
                fit: fit
            )
            let planeSize = max(
                0.1,
                fit.radius * 2.4 +
                    OrbitalViewportRibbedSpeakerSphereGeometry.baseStrutRadius *
                    OrbitalViewportRibbedSpeakerSphereGeometry.normalizedThickness(configuration.ribbedSphereThickness) *
                    8
            )
            let isHidden = !configuration.showRibbedSpeakerSphere || configuration.showHiddenLines
            let state = OrbitalViewportRibbedSphereCutawayPlaneState(
                isHidden: isHidden,
                uniforms: uniforms,
                planeSize: planeSize
            )
            lastRibbedSphereCutawayUniforms = uniforms
            lastRibbedSphereCutawayShowHiddenLines = configuration.showHiddenLines
            guard lastRibbedSphereCutawayPlaneState != state else {
                return false
            }

            if let plane = ribbedSphereCutawayPlaneNode.geometry as? SCNPlane {
                let cgPlaneSize = CGFloat(planeSize)
                plane.width = cgPlaneSize
                plane.height = cgPlaneSize
            }
            ribbedSphereCutawayPlaneNode.isHidden = isHidden
            ribbedSphereCutawayPlaneNode.simdPosition = uniforms.sceneCenter +
                uniforms.clipNormal * uniforms.frontClipPlane
            ribbedSphereCutawayPlaneNode.simdOrientation = simd_quatf(
                from: SIMD3<Float>(0, 0, 1),
                to: uniforms.clipNormal
            )
            lastRibbedSphereCutawayPlaneState = state
            return true
        }

        private func updateSpeakers(
            configuration: OrbitalViewportRenderConfiguration,
            snapshot: OrbitalViewportSnapshot,
            updateVisibility: Bool,
            updateMaterial: Bool
        ) -> Bool {
            var didMutate = false
            if updateVisibility {
                instrumentation.speakerVisibilityUpdateCount += 1
            }
            if updateMaterial {
                instrumentation.speakerMaterialUpdateCount += 1
            }
            for speaker in snapshot.speakers {
                guard let node = speakerNodes[speaker.channel] else {
                    continue
                }
                let selected = configuration.selectedChannel == speaker.channel
                let visible = configuration.isVisibleDepth(speaker.depth)

                if updateVisibility {
                    let nodeHidden = !visible
                    if node.isHidden != nodeHidden {
                        node.isHidden = nodeHidden
                        didMutate = true
                    }
                    let outlineVisible = visible &&
                        configuration.speakerShape == .cubeVU &&
                        configuration.cubeVUSettings.cubeOutlineStrength > 0.001
                    speakerOutlineNodes[speaker.channel]?.forEach {
                        if $0.isHidden != !outlineVisible {
                            $0.isHidden = !outlineVisible
                            didMutate = true
                        }
                    }
                }

                if updateMaterial {
                    instrumentation.speakerMaterialSpeakerVisitCount += 1
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
                        let vuColor = configuration.foggedNSColor(
                            configuration.theme.cubeVUNSColor(heat: heat),
                            depth: speaker.depth
                        )
                        let hotColor = selected
                            ? configuration.theme.cubeVUHotNSColor
                            : configuration.foggedNSColor(configuration.theme.cubeVUHotNSColor, depth: speaker.depth)
                        OrbitalViewportCubeVUSceneKitMaterial.update(
                            material: node.geometry?.firstMaterial,
                            settings: configuration.cubeVUSettings,
                            scalars: scalars,
                            clip: speaker.peak >= 0.995,
                            alpha: alpha,
                            vuColor: vuColor,
                            hotColor: hotColor
                        )
                        didMutate = true
                        didMutate = updateCubeOutline(
                            channel: speaker.channel,
                            speakerOutlineNodes[speaker.channel],
                            renderStyle: configuration.renderStyle,
                            color: selected
                                ? configuration.theme.selectedLabelNSColor
                                : configuration.foggedNSColor(configuration.theme.cubeOutlineNSColor, depth: speaker.depth),
                            alpha: alpha,
                            strength: configuration.cubeVUSettings.cubeOutlineStrength,
                            selected: selected,
                            visible: visible
                        ) || didMutate
                    } else {
                        let color = configuration.foggedNSColor(
                            configuration.theme.vuNSColor(heat: heat),
                            depth: speaker.depth
                        )
                        didMutate = setMaterial(
                            node.geometry?.firstMaterial,
                            color: color,
                            alpha: alpha * (0.72 + visibleFill * 0.28),
                            emission: color.withAlphaComponent(OrbitalViewportMath.clamp01(emissionOpacity))
                        ) || didMutate
                    }
                }

                guard let label = labelNodes[speaker.channel] else {
                    continue
                }
                if updateVisibility {
                    let labelHidden = !configuration.speakerLabelVisible(depth: speaker.depth, selected: selected)
                    if label.isHidden != labelHidden {
                        label.isHidden = labelHidden
                        didMutate = true
                    }
                }
                if updateMaterial {
                    let textureBacked = configuration.speakerLabelFont.usesTextureBackedSceneKitLabel
                    let labelAlpha = configuration.speakerLabelAlpha(depth: speaker.depth, selected: selected)
                    let labelMaterialKey = OrbitalViewportSpeakerLabelMaterialUpdateKey(
                        renderStyle: configuration.renderStyle,
                        selected: selected,
                        textureBacked: textureBacked,
                        alpha: labelAlpha
                    )
                    guard speakerLabelMaterialKeys[speaker.channel] != labelMaterialKey else {
                        continue
                    }

                    speakerLabelMaterialKeys[speaker.channel] = labelMaterialKey
                    instrumentation.speakerLabelMaterialUpdateCount += 1
                    let baseLabelColor = selected ? configuration.theme.selectedLabel : configuration.theme.text
                    let labelColor = selected
                        ? baseLabelColor
                        : configuration.foggedColor(baseLabelColor, depth: speaker.depth)
                    if textureBacked {
                        didMutate = setTextureBackedLabelMaterial(
                            label.geometry?.firstMaterial,
                            color: labelColor,
                            alpha: labelAlpha
                        ) || didMutate
                    } else {
                        didMutate = setMaterial(
                            label.geometry?.firstMaterial,
                            color: labelColor,
                            alpha: labelAlpha,
                            emission: labelColor.opacity(selected ? 0.35 : 0.18)
                        ) || didMutate
                    }
                }
            }
            return didMutate
        }

        private func ensureSourceNodes(configuration: OrbitalViewportRenderConfiguration) -> Bool {
            var didMutate = false
            let activeIDs = Set(configuration.sources.map(\.sourceID))
            let staleIDs = sourceNodes.keys.filter { !activeIDs.contains($0) }
            for sourceID in staleIDs {
                if let node = sourceNodes[sourceID] {
                    forgetMaterialStates(in: node)
                    node.removeFromParentNode()
                }
                sourceNodes.removeValue(forKey: sourceID)
                didMutate = true
            }

            for source in configuration.sources {
                if sourceNodes[source.sourceID] == nil {
                    let node = SCNNode(geometry: SCNSphere(radius: max(0.026, 0.042 * configuration.sceneScale)))
                    node.name = "source-\(source.sourceID)"
                    let material = SCNMaterial()
                    material.lightingModel = .physicallyBased
                    material.metalness.contents = 0.06
                    material.roughness.contents = 0.34
                    node.geometry?.materials = [material]
                    sourceRoot.addChildNode(node)
                    sourceNodes[source.sourceID] = node
                    didMutate = true
                }
            }
            return didMutate
        }

        private func updateSourcePoseAndVisibility(
            configuration: OrbitalViewportRenderConfiguration,
            snapshot: OrbitalViewportSnapshot
        ) -> Bool {
            sourceUpdateCount += 1
            instrumentation.sourcePoseOrVisibilityUpdateCount += 1
            var didMutate = ensureSourceNodes(configuration: configuration)

            for source in snapshot.sources {
                guard let node = sourceNodes[source.sourceID] else {
                    continue
                }
                let position = OVVector3(source.source).scn
                if node.position.x != position.x ||
                    node.position.y != position.y ||
                    node.position.z != position.z {
                    node.position = position
                    didMutate = true
                }
                let hidden = !source.visible
                if node.isHidden != hidden {
                    node.isHidden = hidden
                    didMutate = true
                }
            }
            return didMutate
        }

        private func updateSourceMaterial(
            configuration: OrbitalViewportRenderConfiguration,
            snapshot: OrbitalViewportSnapshot
        ) -> Bool {
            sourceUpdateCount += 1
            instrumentation.sourceMaterialUpdateCount += 1
            var didMutate = ensureSourceNodes(configuration: configuration)

            for source in snapshot.sources {
                guard let node = sourceNodes[source.sourceID] else {
                    continue
                }
                let color = configuration.foggedNSColor(
                    source.source.nsColor(theme: configuration.sourceSpeakerTheme),
                    depth: source.depth
                )
                let alpha = configuration.speakerAlpha(depth: source.depth, selected: false)
                let bloom = (0.24 + (source.peak * 0.55)) *
                    configuration.speakerEmissionScale(depth: source.depth)
                didMutate = setMaterial(
                    node.geometry?.firstMaterial,
                    color: color,
                    alpha: alpha,
                    emission: color.withAlphaComponent(OrbitalViewportMath.clamp01(bloom))
                ) || didMutate
            }
            return didMutate
        }

        private func updateFog(configuration: OrbitalViewportRenderConfiguration) {
            instrumentation.fogUpdateCount += 1
            let fog = configuration.fogConfiguration
            scene.fogColor = NSColor(configuration.theme.fog)
            scene.fogStartDistance = fog.startDistance
            scene.fogEndDistance = fog.endDistance
            scene.fogDensityExponent = fog.densityExponent
        }

        private func makeRibbedSpeakerSphereBatchNode(
            curves: [OrbitalViewportRibbedSpeakerSphereGeometry.Curve],
            radius: Double,
            name: String
        ) -> SCNNode? {
            guard let geometry = makeRibbedSpeakerSphereBatchGeometry(
                curves: curves,
                radius: radius
            ) else {
                return nil
            }

            let material = SCNMaterial()
            material.lightingModel = .constant
            material.isDoubleSided = true
            material.readsFromDepthBuffer = true
            material.writesToDepthBuffer = true
            material.transparency = 1
            geometry.materials = [material]

            let node = SCNNode(geometry: geometry)
            node.name = name
            return node
        }

        private func makeRibbedSpeakerSphereBatchGeometry(
            curves: [OrbitalViewportRibbedSpeakerSphereGeometry.Curve],
            radius: Double
        ) -> SCNGeometry? {
            guard !curves.isEmpty else {
                return nil
            }

            let sides = 6
            var vertices: [SCNVector3] = []
            var indices: [Int32] = []
            let segmentCount = curves.reduce(0) { $0 + $1.segmentCount }
            let capCount = curves.filter { !$0.isClosed }.count * 2
            vertices.reserveCapacity(curves.reduce(0) { $0 + $1.points.count * sides } + capCount)
            indices.reserveCapacity((segmentCount * sides * 6) + (capCount * sides * 3))

            for curve in curves {
                appendTubeCurve(
                    curve,
                    radius: radius,
                    sides: sides,
                    vertices: &vertices,
                    indices: &indices
                )
            }

            return SCNGeometry(
                sources: [SCNGeometrySource(vertices: vertices)],
                elements: [SCNGeometryElement(indices: indices, primitiveType: .triangles)]
            )
        }

        private func appendTubeCurve(
            _ curve: OrbitalViewportRibbedSpeakerSphereGeometry.Curve,
            radius: Double,
            sides: Int,
            vertices: inout [SCNVector3],
            indices: inout [Int32]
        ) {
            let points = curve.points.map(\.simdSCN)
            guard sides >= 3,
                points.count >= 2,
                !curve.isClosed || points.count >= 3 else {
                return
            }

            let baseIndex = Int32(vertices.count)
            let tubeRadius = Float(max(0.000_1, radius))
            var previousNormal: SIMD3<Float>?

            for pointIndex in points.indices {
                let tangent = tubeCurveTangent(points: points, index: pointIndex, isClosed: curve.isClosed)
                let normal: SIMD3<Float>
                if let previousNormal {
                    let projected = previousNormal - tangent * simd_dot(previousNormal, tangent)
                    normal = normalizedTubeVector(projected, fallback: initialTubeNormal(for: tangent))
                } else {
                    normal = initialTubeNormal(for: tangent)
                }
                let binormal = normalizedTubeVector(
                    simd_cross(tangent, normal),
                    fallback: initialTubeNormal(for: tangent)
                )
                previousNormal = normal

                for side in 0..<sides {
                    let angle = (Float(side) / Float(sides)) * Float.pi * 2
                    let offset = normal * (cos(angle) * tubeRadius) + binormal * (sin(angle) * tubeRadius)
                    let vertex = points[pointIndex] + offset
                    vertices.append(SCNVector3(vertex.x, vertex.y, vertex.z))
                }
            }

            let spanCount = curve.isClosed ? points.count : points.count - 1
            for span in 0..<spanCount {
                let currentRing = span
                let nextRing = (span + 1) % points.count
                appendTubeSpanIndices(
                    currentRing: currentRing,
                    nextRing: nextRing,
                    sides: sides,
                    baseIndex: baseIndex,
                    indices: &indices
                )
            }

            if !curve.isClosed {
                appendTubeCap(
                    center: points[0],
                    ring: 0,
                    sides: sides,
                    baseIndex: baseIndex,
                    reversed: true,
                    vertices: &vertices,
                    indices: &indices
                )
                appendTubeCap(
                    center: points[points.count - 1],
                    ring: points.count - 1,
                    sides: sides,
                    baseIndex: baseIndex,
                    reversed: false,
                    vertices: &vertices,
                    indices: &indices
                )
            }
        }

        private func appendTubeSpanIndices(
            currentRing: Int,
            nextRing: Int,
            sides: Int,
            baseIndex: Int32,
            indices: inout [Int32]
        ) {
            for side in 0..<sides {
                let nextSide = (side + 1) % sides
                let a = baseIndex + Int32(currentRing * sides + side)
                let b = baseIndex + Int32(nextRing * sides + side)
                let c = baseIndex + Int32(currentRing * sides + nextSide)
                let d = baseIndex + Int32(nextRing * sides + nextSide)
                indices.append(contentsOf: [a, b, c, c, b, d])
            }
        }

        private func appendTubeCap(
            center: SIMD3<Float>,
            ring: Int,
            sides: Int,
            baseIndex: Int32,
            reversed: Bool,
            vertices: inout [SCNVector3],
            indices: inout [Int32]
        ) {
            let centerIndex = Int32(vertices.count)
            vertices.append(SCNVector3(center.x, center.y, center.z))
            for side in 0..<sides {
                let nextSide = (side + 1) % sides
                let current = baseIndex + Int32(ring * sides + side)
                let next = baseIndex + Int32(ring * sides + nextSide)
                if reversed {
                    indices.append(contentsOf: [centerIndex, next, current])
                } else {
                    indices.append(contentsOf: [centerIndex, current, next])
                }
            }
        }

        private func tubeCurveTangent(
            points: [SIMD3<Float>],
            index: Int,
            isClosed: Bool
        ) -> SIMD3<Float> {
            if isClosed {
                let previous = points[(index - 1 + points.count) % points.count]
                let next = points[(index + 1) % points.count]
                return normalizedTubeVector(next - previous, fallback: SIMD3<Float>(0, 1, 0))
            }
            if index == 0 {
                return normalizedTubeVector(points[1] - points[0], fallback: SIMD3<Float>(0, 1, 0))
            }
            if index == points.count - 1 {
                return normalizedTubeVector(points[index] - points[index - 1], fallback: SIMD3<Float>(0, 1, 0))
            }
            return normalizedTubeVector(points[index + 1] - points[index - 1], fallback: SIMD3<Float>(0, 1, 0))
        }

        private func initialTubeNormal(for tangent: SIMD3<Float>) -> SIMD3<Float> {
            let reference = abs(simd_dot(tangent, SIMD3<Float>(0, 1, 0))) > 0.96
                ? SIMD3<Float>(1, 0, 0)
                : SIMD3<Float>(0, 1, 0)
            return normalizedTubeVector(simd_cross(tangent, reference), fallback: SIMD3<Float>(1, 0, 0))
        }

        private func normalizedTubeVector(
            _ vector: SIMD3<Float>,
            fallback: SIMD3<Float>
        ) -> SIMD3<Float> {
            let length = simd_length(vector)
            guard length > 0.000_001 else {
                return fallback
            }
            return vector / length
        }

        private func updateRibbedSpeakerSphereBatchMaterial(
            _ node: SCNNode?,
            lane: String,
            configuration: OrbitalViewportRenderConfiguration,
            color: NSColor,
            alpha: Double
        ) -> Bool {
            guard let material = node?.geometry?.firstMaterial else {
                return false
            }

            let brightness = OrbitalViewportMath.clamp01(0.16 + alpha * 1.08)
            let diffuse = ribbedSphereMaterialColor(color, brightness: brightness)
            let emission = ribbedSphereMaterialColor(color, brightness: brightness * 0.42)
            let materialName = ribbedSphereMaterialName(lane: lane, configuration: configuration)
            let didWriteMaterial = setOpaqueRibbedSphereMaterial(
                material,
                name: materialName,
                diffuse: diffuse,
                emission: emission
            )
            let didClearShader = clearRibbedSphereDepthFogShader(material)
            if didWriteMaterial || didClearShader {
                instrumentation.ribbedSphereMaterialWriteCount += 1
            }
            return didWriteMaterial || didClearShader
        }

        private func ribbedSphereMaterialName(
            lane: String,
            configuration: OrbitalViewportRenderConfiguration
        ) -> String {
            let saturationBucket = Int((configuration.geodesicSaturation * 100).rounded())
            return "ribbed.\(lane).style.\(configuration.geodesicRenderStyle.rawValue).sat.\(saturationBucket)"
        }

        private func ribbedSphereMaterialColor(
            _ color: NSColor,
            brightness: Double
        ) -> NSColor {
            let resolved = color.usingColorSpace(.deviceRGB) ?? color
            let brightness = CGFloat(OrbitalViewportMath.clamp01(brightness))
            return NSColor(
                deviceRed: resolved.redComponent * brightness,
                green: resolved.greenComponent * brightness,
                blue: resolved.blueComponent * brightness,
                alpha: 1
            )
        }

        @discardableResult
        private func setOpaqueRibbedSphereMaterial(
            _ material: SCNMaterial,
            name: String,
            diffuse: NSColor,
            emission: NSColor
        ) -> Bool {
            let state = OrbitalViewportSceneMaterialState(
                name: name,
                diffuse: diffuse,
                emission: emission,
                transparency: 1,
                isDoubleSided: true
            )
            let materialID = ObjectIdentifier(material)
            guard sceneMaterialStates[materialID] != state else {
                instrumentation.sceneMaterialSkipCount += 1
                return false
            }

            material.name = name
            material.diffuse.contents = diffuse
            material.emission.contents = emission
            material.lightingModel = .physicallyBased
            material.metalness.contents = 0.08
            material.roughness.contents = 0.24
            material.specular.contents = NSColor.white.withAlphaComponent(0.32)
            material.transparency = 1
            material.isDoubleSided = true
            material.readsFromDepthBuffer = true
            material.writesToDepthBuffer = true
            sceneMaterialStates[materialID] = state
            instrumentation.sceneMaterialWriteCount += 1
            return true
        }

        @discardableResult
        private func clearRibbedSphereDepthFogShader(_ material: SCNMaterial) -> Bool {
            guard material.shaderModifiers != nil else {
                return false
            }

            material.shaderModifiers = nil
            instrumentation.sceneMaterialWriteCount += 1
            return true
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
            let pole = OVVector3(x: 0, y: 0, z: 1)
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
            func column(_ vector: OVVector3, w: Float) -> SIMD4<Float> {
                SIMD4<Float>(Float(vector.x), Float(vector.z), Float(vector.y), w)
            }

            return simd_float4x4(
                column(longAxis, w: 0),
                column(sideAxis, w: 0),
                column(radialAxis, w: 0),
                column(position, w: 1)
            )
        }

        @discardableResult
        private func setMaterial(
            _ material: SCNMaterial?,
            color: Color,
            alpha: Double,
            emission: Color? = nil
        ) -> Bool {
            let nsColor = sceneColor(color)
            return setMaterial(
                material,
                color: nsColor,
                alpha: alpha,
                emission: sceneColor(emission ?? .clear)
            )
        }

        @discardableResult
        private func setMaterial(
            _ material: SCNMaterial?,
            color: NSColor,
            alpha: Double,
            emission: NSColor? = nil
        ) -> Bool {
            guard let material else {
                return false
            }

            let diffuse = color.withAlphaComponent(alpha)
            let emission = emission ?? NSColor.clear
            let state = OrbitalViewportSceneMaterialState(
                diffuse: diffuse,
                emission: emission,
                transparency: alpha,
                isDoubleSided: true
            )
            let materialID = ObjectIdentifier(material)
            guard sceneMaterialStates[materialID] != state else {
                instrumentation.sceneMaterialSkipCount += 1
                return false
            }

            material.diffuse.contents = diffuse
            material.emission.contents = emission
            material.transparency = alpha
            material.isDoubleSided = true
            sceneMaterialStates[materialID] = state
            instrumentation.sceneMaterialWriteCount += 1
            return true
        }

        private func sceneColor(_ color: Color) -> NSColor {
            let nsColor = NSColor(color)
            return nsColor.usingColorSpace(.deviceRGB) ?? nsColor
        }

        @discardableResult
        private func setTextureBackedLabelMaterial(
            _ material: SCNMaterial?,
            color: Color,
            alpha: Double
        ) -> Bool {
            guard let material else {
                return false
            }

            let multiply = sceneColor(color).withAlphaComponent(alpha)
            let state = OrbitalViewportSceneMaterialState(
                multiply: multiply,
                transparency: alpha,
                isDoubleSided: true
            )
            let materialID = ObjectIdentifier(material)
            guard sceneMaterialStates[materialID] != state else {
                instrumentation.sceneMaterialSkipCount += 1
                return false
            }

            material.multiply.contents = multiply
            material.transparency = CGFloat(alpha)
            material.isDoubleSided = true
            sceneMaterialStates[materialID] = state
            instrumentation.sceneMaterialWriteCount += 1
            return true
        }

        private func updateCubeOutline(
            channel: Int,
            _ nodes: [SCNNode]?,
            renderStyle: OrbitalViewportRenderStyle,
            color: NSColor,
            alpha: Double,
            strength: Double,
            selected: Bool,
            visible: Bool
        ) -> Bool {
            let strength = OrbitalViewportMath.clamp01(strength)
            let alphaMultiplier = selected
                ? OrbitalViewportCubeVUSceneKitMaterial.cubeOutlineSelectedAlphaMultiplier
                : OrbitalViewportCubeVUSceneKitMaterial.cubeOutlineNormalAlphaMultiplier
            let outlineAlpha = alpha * strength * alphaMultiplier
            let isHidden = !visible || outlineAlpha <= 0.001
            let key = OrbitalViewportCubeOutlineMaterialUpdateKey(
                renderStyle: renderStyle,
                alpha: outlineAlpha,
                strength: strength,
                selected: selected,
                isHidden: isHidden
            )
            guard speakerOutlineMaterialKeys[channel] != key else {
                return false
            }

            speakerOutlineMaterialKeys[channel] = key
            var didMutate = false
            if nodes?.isEmpty == false {
                instrumentation.cubeOutlineMaterialUpdateCount += 1
            }
            nodes?.forEach { node in
                if node.isHidden != isHidden {
                    node.isHidden = isHidden
                    didMutate = true
                }
                guard !isHidden else {
                    return
                }
                didMutate = setMaterial(
                    node.geometry?.firstMaterial,
                    color: color,
                    alpha: outlineAlpha,
                    emission: color.withAlphaComponent(
                        strength * OrbitalViewportCubeVUSceneKitMaterial.cubeOutlineEmissionMultiplier
                    )
                ) || didMutate
            }
            return didMutate
        }
    }
}

final class OrbitalViewportSceneNSView: SCNView {
    var onDragStarted: () -> Void = {}
    var onDrag: (CGSize) -> Void = { _ in }
    var onDragEnded: () -> Void = {}
    var onZoom: (Double) -> Void = { _ in }
    var onSelect: (Int?) -> Void = { _ in }

    private let frameRateMeterContainer = NSView()
    private let frameRateDotView = NSView()
    private let frameRateLabel = NSTextField(labelWithString: "FPS --")
    private var frameRateTheme = OrbitalViewportTheme(style: OrbitalViewportMockup.defaultRenderStyle)
    private var frameRateSample = OrbitalViewportFrameRateSample.pending
    #if DEBUG
    private let ribbedDebugOverlayContainer = NSStackView()
    private let ribbedDebugBuildLabel = NSTextField(labelWithString: "")
    private let ribbedDebugStyleLabel = NSTextField(labelWithString: "")
    private let ribbedDebugSaturationLabel = NSTextField(labelWithString: "")
    private let ribbedDebugApplySequenceLabel = NSTextField(labelWithString: "")
    private let ribbedDebugLastWriterLabel = NSTextField(labelWithString: "")
    private let ribbedDebugMaterialsLabel = NSTextField(labelWithString: "")
    #endif
    private var mouseDownPoint: CGPoint?
    private var previousDragPoint: CGPoint?
    private var hasDragged = false

    override init(frame frameRect: NSRect, options: [String: Any]? = nil) {
        super.init(frame: frameRect, options: options)
        setupFrameRateMeter()
        #if DEBUG
        setupRibbedDebugOverlay()
        #endif
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFrameRateMeter()
        #if DEBUG
        setupRibbedDebugOverlay()
        #endif
    }

    var frameRateMeterTextForTests: String {
        frameRateLabel.stringValue
    }

    var frameRateMeterAccessibilityValueForTests: String? {
        frameRateMeterContainer.accessibilityValue() as? String
    }

    #if DEBUG
    func ribbedDebugOverlayTextForTests(identifier: String) -> String? {
        ribbedDebugOverlayLabels.first { $0.identifier?.rawValue == identifier }?.stringValue
    }

    private var ribbedDebugOverlayLabels: [NSTextField] {
        [
            ribbedDebugBuildLabel,
            ribbedDebugStyleLabel,
            ribbedDebugSaturationLabel,
            ribbedDebugApplySequenceLabel,
            ribbedDebugLastWriterLabel,
            ribbedDebugMaterialsLabel
        ]
    }
    #endif

    func configureFrameRateMeter(
        theme: OrbitalViewportTheme,
        sample: OrbitalViewportFrameRateSample? = nil
    ) {
        frameRateTheme = theme
        if let sample {
            frameRateSample = sample
        }
        applyFrameRateMeterAppearance()
    }

    func updateFrameRateMeter(sample: OrbitalViewportFrameRateSample) {
        frameRateSample = sample
        applyFrameRateMeterAppearance()
    }

    #if DEBUG
    func updateRibbedDebugOverlay(
        configuration: OrbitalViewportRenderConfiguration,
        state: OrbitalViewportRibbedDebugState,
        isEnabled: Bool = OrbitalRenderTrace.isEnvironmentFlagEnabled("ORB_DEBUG_RIBBED_OVERLAY")
    ) {
        ribbedDebugOverlayContainer.isHidden = !isEnabled
        guard isEnabled else {
            return
        }

        ribbedDebugBuildLabel.stringValue = "build: \(state.buildStamp)"
        ribbedDebugStyleLabel.stringValue = "live-render-style-\(configuration.geodesicRenderStyle.rawValue)"
        ribbedDebugSaturationLabel.stringValue = "live-saturation-\(configuration.geodesicSaturation)"
        ribbedDebugApplySequenceLabel.stringValue = "ribbed-apply-sequence-\(state.lastApplySequence)"
        ribbedDebugLastWriterLabel.stringValue = "ribbed-last-writer-\(state.lastWriter)"
        ribbedDebugMaterialsLabel.stringValue = "ribbed-materials-\(state.materialNames)"
    }
    #endif

    private func setupFrameRateMeter() {
        frameRateMeterContainer.translatesAutoresizingMaskIntoConstraints = false
        frameRateMeterContainer.wantsLayer = true
        frameRateMeterContainer.layer?.cornerRadius = 7
        frameRateMeterContainer.layer?.shadowColor = NSColor.black.cgColor
        frameRateMeterContainer.layer?.shadowOpacity = 0.24
        frameRateMeterContainer.layer?.shadowRadius = 12
        frameRateMeterContainer.layer?.shadowOffset = CGSize(width: 0, height: -8)
        frameRateMeterContainer.setAccessibilityLabel("Viewport FPS meter")
        frameRateMeterContainer.setAccessibilityElement(true)

        frameRateDotView.translatesAutoresizingMaskIntoConstraints = false
        frameRateDotView.wantsLayer = true
        frameRateDotView.layer?.cornerRadius = 3.5

        frameRateLabel.translatesAutoresizingMaskIntoConstraints = false
        frameRateLabel.font = .monospacedSystemFont(ofSize: 11, weight: .heavy)
        frameRateLabel.alignment = .center
        frameRateLabel.isBezeled = false
        frameRateLabel.isBordered = false
        frameRateLabel.drawsBackground = false
        frameRateLabel.isEditable = false
        frameRateLabel.isSelectable = false
        frameRateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        frameRateLabel.setContentHuggingPriority(.required, for: .horizontal)

        addSubview(frameRateMeterContainer)
        frameRateMeterContainer.addSubview(frameRateDotView)
        frameRateMeterContainer.addSubview(frameRateLabel)

        NSLayoutConstraint.activate([
            frameRateMeterContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            frameRateMeterContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            frameRateMeterContainer.heightAnchor.constraint(equalToConstant: 30),
            frameRateMeterContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 74),

            frameRateDotView.leadingAnchor.constraint(equalTo: frameRateMeterContainer.leadingAnchor, constant: 10),
            frameRateDotView.centerYAnchor.constraint(equalTo: frameRateMeterContainer.centerYAnchor),
            frameRateDotView.widthAnchor.constraint(equalToConstant: 7),
            frameRateDotView.heightAnchor.constraint(equalToConstant: 7),

            frameRateLabel.leadingAnchor.constraint(equalTo: frameRateDotView.trailingAnchor, constant: 8),
            frameRateLabel.trailingAnchor.constraint(equalTo: frameRateMeterContainer.trailingAnchor, constant: -10),
            frameRateLabel.centerYAnchor.constraint(equalTo: frameRateMeterContainer.centerYAnchor)
        ])
        applyFrameRateMeterAppearance()
    }

    #if DEBUG
    private func setupRibbedDebugOverlay() {
        ribbedDebugOverlayContainer.translatesAutoresizingMaskIntoConstraints = false
        ribbedDebugOverlayContainer.orientation = .vertical
        ribbedDebugOverlayContainer.alignment = .leading
        ribbedDebugOverlayContainer.spacing = 2
        ribbedDebugOverlayContainer.edgeInsets = NSEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        ribbedDebugOverlayContainer.wantsLayer = true
        ribbedDebugOverlayContainer.layer?.cornerRadius = 6
        ribbedDebugOverlayContainer.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.72).cgColor
        ribbedDebugOverlayContainer.layer?.borderColor = NSColor.systemGreen.withAlphaComponent(0.55).cgColor
        ribbedDebugOverlayContainer.layer?.borderWidth = 1
        ribbedDebugOverlayContainer.isHidden = true
        ribbedDebugOverlayContainer.setAccessibilityLabel("Ribbed debug overlay")
        ribbedDebugOverlayContainer.setAccessibilityElement(true)

        let labels: [(NSTextField, String)] = [
            (ribbedDebugBuildLabel, "orbital-build-stamp"),
            (ribbedDebugStyleLabel, "live-render-style"),
            (ribbedDebugSaturationLabel, "live-geodesic-saturation"),
            (ribbedDebugApplySequenceLabel, "ribbed-apply-sequence"),
            (ribbedDebugLastWriterLabel, "ribbed-last-writer"),
            (ribbedDebugMaterialsLabel, "ribbed-material-names")
        ]

        for (label, identifier) in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
            label.textColor = .systemGreen
            label.isBezeled = false
            label.isBordered = false
            label.drawsBackground = false
            label.isEditable = false
            label.isSelectable = false
            label.lineBreakMode = .byTruncatingTail
            label.identifier = NSUserInterfaceItemIdentifier(identifier)
            label.setAccessibilityIdentifier(identifier)
            ribbedDebugOverlayContainer.addArrangedSubview(label)
        }

        addSubview(ribbedDebugOverlayContainer)
        NSLayoutConstraint.activate([
            ribbedDebugOverlayContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            ribbedDebugOverlayContainer.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            ribbedDebugOverlayContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 360)
        ])
    }
    #endif

    private func applyFrameRateMeterAppearance() {
        frameRateLabel.stringValue = "FPS \(frameRateSample.displayFramesPerSecondText)"
        frameRateLabel.textColor = Self.nsColor(frameRateTheme.text)
        frameRateDotView.layer?.backgroundColor = Self.nsColor(statusColor(for: frameRateSample)).cgColor
        frameRateMeterContainer.layer?.backgroundColor = Self.nsColor(frameRateTheme.chipBackground).cgColor
        frameRateMeterContainer.layer?.borderColor = Self.nsColor(frameRateTheme.line).cgColor
        frameRateMeterContainer.layer?.borderWidth = 1
        frameRateMeterContainer.setAccessibilityValue(frameRateSample.accessibilityValue)
    }

    private func statusColor(for sample: OrbitalViewportFrameRateSample) -> Color {
        guard !sample.isPending else {
            return frameRateTheme.muted
        }

        switch sample.status {
        case .target:
            return frameRateTheme.accent
        case .belowTarget:
            return OrbitalViewportLabTheme.amber
        case .underTarget:
            return OrbitalViewportLabTheme.red
        }
    }

    private static func nsColor(_ color: Color) -> NSColor {
        let nsColor = NSColor(color)
        return nsColor.usingColorSpace(.deviceRGB) ?? nsColor
    }

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
    let onFrameRateSample: (OrbitalViewportFrameRateSample) -> Void

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

    private var geodesicTheme: OrbitalViewportTheme {
        configuration.geodesicTheme
    }

    private var sourceSpeakerTheme: OrbitalViewportTheme {
        configuration.sourceSpeakerTheme
    }

    private var gridPlaneTheme: OrbitalViewportTheme {
        configuration.gridPlaneTheme
    }

    mutating func draw(size: CGSize) {
        drawBackground(size: size)
        drawFogVeil(size: size)
        drawGridPlane()
        drawRibbedSpeakerSphere()
        drawSpeakers()
        drawSources()
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

    mutating private func drawGridPlane() {
        guard configuration.showGridPlane else {
            return
        }

        for line in OrbitalViewportGridPlaneGeometry.lineSegments(spacing: configuration.gridPlaneSpacing) {
            let start = configuration.rotate(line.start)
            let end = configuration.rotate(line.end)
            var path = Path()
            path.move(to: configuration.project(start))
            path.addLine(to: configuration.project(end))
            let color = line.isMajor ? gridPlaneTheme.equator : gridPlaneTheme.structure
            let alpha = OrbitalViewportGridPlaneGeometry.alpha(
                for: line,
                visibility: configuration.gridPlaneVisibility
            )
            context.stroke(
                path,
                with: .color(color.opacity(alpha)),
                style: StrokeStyle(
                    lineWidth: (line.isMajor ? 1.05 : 0.72) * configuration.gridPlaneThickness,
                    lineCap: .round
                )
            )
        }
    }

    mutating private func drawRibbedSpeakerSphere() {
        guard configuration.showRibbedSpeakerSphere else {
            return
        }

        let segments = OrbitalViewportRibbedSpeakerSphereGeometry.segments(
            for: configuration.speakers,
            verticalRibs: configuration.ribbedSphereVerticalRibs,
            horizontalRings: configuration.ribbedSphereHorizontalRings,
            fallbackRadius: configuration.sceneScale
        )
            .compactMap { segment -> (segment: OrbitalViewportRibbedSpeakerSphereGeometry.Segment, start: OVVector3, end: OVVector3, depth: Double, fade: Double)? in
                let start = configuration.rotate(segment.start)
                let end = configuration.rotate(segment.end)
                guard let clipped = clipSegmentToFront(start: start, end: end) else {
                    return nil
                }
                let fade = configuration.ribbedSphereDepthAlpha(
                    startDepth: clipped.start.z,
                    endDepth: clipped.end.z
                )
                guard fade > 0.02 else {
                    return nil
                }
                return (
                    segment,
                    clipped.start,
                    clipped.end,
                    (clipped.start.z + clipped.end.z) * 0.5,
                    fade
                )
            }
            .sorted { $0.depth < $1.depth }

        for item in segments {
            var path = Path()
            path.move(to: configuration.project(item.start))
            path.addLine(to: configuration.project(item.end))
            let baseAlpha = item.segment.kind == .verticalRib ? 0.74 : 0.64
            let alpha = baseAlpha * item.fade * OrbitalViewportRibbedSpeakerSphereGeometry.frontLineAlpha
            let strokeColor = configuration.geodesicColor(
                geodesicTheme.accent
            )
            let foggedStrokeColor = configuration.foggedGeodesicColor(strokeColor, depth: item.depth)
            context.stroke(
                path,
                with: .color(foggedStrokeColor.opacity(alpha)),
                style: StrokeStyle(
                    lineWidth: 1.02 * configuration.ribbedSphereThickness,
                    lineCap: .round
                )
            )
        }
    }

    mutating private func drawFogVeil(size: CGSize) {
        let fog = configuration.fogConfiguration
        guard fog.isEnabled else {
            return
        }
        let alpha = min(0.42, pow(fog.normalizedDensity, 1.15) * 0.42)
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
            let baseColor = theme.colorForPeak(speaker.peak)
            let color = selected ? baseColor : configuration.foggedColor(baseColor, depth: speaker.depth)

            switch configuration.speakerShape {
            case .sphere:
                guard configuration.isVisibleDepth(speaker.depth) else {
                    continue
                }
                drawSpeakerSphere(speaker, color: color, alpha: alpha, selected: selected)
            case .prism, .cubeVU:
                drawSpeakerPrism(speaker, color: color, baseAlpha: alpha, selected: selected)
            }

            if configuration.speakerLabelVisible(depth: speaker.depth, selected: selected) {
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

    mutating private func drawSources() {
        for source in snapshot.sources {
            guard configuration.isVisibleDepth(source.depth) else {
                continue
            }
            let radius = 7.5 + source.peak * 4
            let rect = CGRect(
                x: source.screen.x - radius,
                y: source.screen.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            let color = configuration.foggedColor(
                source.source.color(theme: sourceSpeakerTheme),
                depth: source.depth
            )
            let alpha = configuration.speakerAlpha(depth: source.depth, selected: false)
            context.fill(Path(ellipseIn: rect), with: .color(color.opacity((0.32 + source.peak * 0.42) * alpha)))
            context.stroke(Path(ellipseIn: rect), with: .color(theme.selectedLabel.opacity(0.58 * alpha)), lineWidth: 1)
        }
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
        let baseColor = configuration.renderStyle == .bw ? Color(hex: "#111111") : (selected ? theme.selectedLabel : theme.label)
        let color = selected ? baseColor : configuration.foggedColor(baseColor, depth: speaker.depth)
        let alpha = configuration.speakerLabelAlpha(depth: speaker.depth, selected: selected)
        context.draw(
            Text(String(format: "%02d", speaker.channel))
                .font(.system(size: 11))
                .foregroundColor(color.opacity(alpha)),
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
        let pole = OVVector3(x: 0, y: 0, z: 1)
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
        let depth = short
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
    static let speakerLabelFontPointSize = OrbitalViewportLabTheme.controlFontSize
    static let speakerLabelScale: Float = 0.0032
    static let speakerLabelTextureFontPointSize: CGFloat = 44
    static let speakerLabelTextureWidth: CGFloat = 0.084
    static let speakerLabelTextureHeight: CGFloat = 0.042
}

struct OrbitalViewportTheme: Equatable {
    let style: OrbitalViewportRenderStyle

    private var palette: OrbitalViewportPalette {
        style.palette
    }

    #if os(macOS)
    private enum ResolvedColorRole: Hashable {
        case text
        case muted
        case accentSecondary
        case danger
        case cubeOutline
    }

    private static var resolvedVUPalettes: [OrbitalViewportRenderStyle: OrbitalViewportResolvedVUPalette] = [:]
    private static var resolvedVURampColorBuckets: [OrbitalViewportRenderStyle: [Int: NSColor]] = [:]
    private static var resolvedThemeColors: [OrbitalViewportRenderStyle: [ResolvedColorRole: NSColor]] = [:]
    private static let resolvedVURampBucketScale = 16_384

    private static func resolvedVUPalette(for style: OrbitalViewportRenderStyle) -> OrbitalViewportResolvedVUPalette {
        if let palette = resolvedVUPalettes[style] {
            return palette
        }

        let palette = OrbitalViewportResolvedVUPalette(palette: style.palette)
        resolvedVUPalettes[style] = palette
        return palette
    }

    private static func resolvedVURampBucket(for level: Double) -> Int {
        guard level.isFinite else {
            return 0
        }
        return Int((OrbitalViewportMath.clamp01(level) * Double(resolvedVURampBucketScale)).rounded())
    }

    private static func resolvedVURampColor(for style: OrbitalViewportRenderStyle, level: Double) -> NSColor {
        let bucket = resolvedVURampBucket(for: level)
        if let color = resolvedVURampColorBuckets[style]?[bucket] {
            return color
        }

        let normalized = Double(bucket) / Double(resolvedVURampBucketScale)
        let color = resolvedVUPalette(for: style).vuColor(for: normalized)
        var styleBuckets = resolvedVURampColorBuckets[style] ?? [:]
        styleBuckets[bucket] = color
        resolvedVURampColorBuckets[style] = styleBuckets
        return color
    }

    private static func resolvedThemeColor(
        for style: OrbitalViewportRenderStyle,
        role: ResolvedColorRole,
        makeColor: () -> Color
    ) -> NSColor {
        if let color = resolvedThemeColors[style]?[role] {
            return color
        }

        let color = NSColor(makeColor())
        let resolved = color.usingColorSpace(.deviceRGB) ?? color
        var styleColors = resolvedThemeColors[style] ?? [:]
        styleColors[role] = resolved
        resolvedThemeColors[style] = styleColors
        return resolved
    }
    #endif

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

    #if os(macOS)
    var selectedLabelNSColor: NSColor {
        Self.resolvedThemeColor(for: style, role: .text) { palette.text }
    }

    var mutedNSColor: NSColor {
        Self.resolvedThemeColor(for: style, role: .muted) { palette.textSoft }
    }

    var accentSecondaryNSColor: NSColor {
        Self.resolvedThemeColor(for: style, role: .accentSecondary) { palette.accentSecondary }
    }

    var vuHotNSColor: NSColor {
        Self.resolvedThemeColor(for: style, role: .danger) { palette.danger }
    }

    var cubeOutlineNSColor: NSColor {
        Self.resolvedThemeColor(for: style, role: .cubeOutline) { palette.text }
    }

    func vuNSColor(heat: Double) -> NSColor {
        Self.resolvedVURampColor(for: style, level: heat)
    }

    func cubeVUNSColor(heat: Double) -> NSColor {
        Self.resolvedVURampColor(for: style, level: heat)
    }

    var cubeVUHotNSColor: NSColor {
        vuHotNSColor
    }
    #endif
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
    static func blend(_ color: Color, with target: Color, amount: Double) -> Color {
        let amount = OrbitalViewportMath.clamp01(amount)
        guard amount > 0.001 else {
            return color
        }

        #if os(macOS)
        return Color(blend(NSColor(color), with: NSColor(target), amount: amount))
        #else
        return color
        #endif
    }

    #if os(macOS)
    static func blend(_ color: NSColor, with target: NSColor, amount: Double) -> NSColor {
        let amount = CGFloat(OrbitalViewportMath.clamp01(amount))
        guard amount > 0.001 else {
            return color
        }

        guard let base = color.usingColorSpace(.deviceRGB) ?? color.usingColorSpace(.sRGB),
              let fog = target.usingColorSpace(.deviceRGB) ?? target.usingColorSpace(.sRGB) else {
            return color
        }
        return NSColor(
            deviceRed: base.redComponent + (fog.redComponent - base.redComponent) * amount,
            green: base.greenComponent + (fog.greenComponent - base.greenComponent) * amount,
            blue: base.blueComponent + (fog.blueComponent - base.blueComponent) * amount,
            alpha: base.alphaComponent
        )
    }
    #endif

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
    static let speakerLabelFontSizeSliderCenter = 50.0
    private static let fogMidpointDensity = 20.0
    private static let fogDensityExponent = log(fogMidpointDensity / 100) / log(0.5)

    static func speakerSize(fromSlider value: Double) -> Double {
        let offset = (value - 50) / 50
        return speakerSizeCenter * pow(2, offset)
    }

    static func fogDensity(fromSlider value: Double) -> Double {
        let normalized = max(0, min(1, value / 100))
        return round(100 * pow(normalized, fogDensityExponent))
    }

    static func speakerLabelSizeScale(fromSlider value: Double) -> Double {
        let normalized = max(0, min(1, value / 100))
        return 0.62 + normalized * 0.76
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
    static let zero = OVVector3(x: 0, y: 0, z: 0)

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

    init(_ source: OrbitalViewportSourceMarker) {
        self.init(x: source.position.x, y: source.position.y, z: source.position.z)
    }

    init(_ vector: OrbitalViewVector3) {
        self.init(x: vector.x, y: vector.y, z: vector.z)
    }

    var coreVector: OrbitalViewVector3 {
        (try? OrbitalViewVector3(x: x, y: y, z: z)) ?? .origin
    }

    var scn: SCNVector3 {
        SCNVector3(x, z, y)
    }

    var simdSCN: SIMD3<Float> {
        SIMD3<Float>(Float(x), Float(z), Float(y))
    }

    var simdNormalized: SIMD3<Float> {
        let vector = simdSCN
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
