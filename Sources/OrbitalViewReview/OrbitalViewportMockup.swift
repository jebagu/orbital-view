import Foundation
import OrbitalViewCore
import OrbitalViewSpatGRIS
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
    public static let correctReviewAppName = "Orbital View VU Kit Native SceneKit Geodesic Viewport Review App With Preserved Control Rail, Right Tuning Panel, Motion FPS Toggle, Full-Window PNG Export, and Cube VU Speaker Surface"
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
    static let viewportAnimationFramesPerSecond = OrbitalViewportFrameRate.sixty.framesPerSecond
    static let meterOnlyViewportFramesPerSecond = 10
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
    static let colorPaletteControlTitles = [
        "Sonic Sphere Speaker Palette",
        "Source Speaker Palette",
        "App Skin",
        "Cube VU Ramp"
    ]
    static let globalDiceButtonStyle = "icon-only-centered-dice"
    static let viewDetailControlTitles = [
        "Speaker Size",
        "Fog Density",
        "Speaker Numbers",
        "Hidden Lines"
    ]
    static let geodesicAppearanceControlTitles = [
        "Geodesic Palette",
        "Geodesic Saturation"
    ]
    static let sphereGeometryControlTitles = [
        "Ribbed Speaker Sphere",
        "Rib Thickness",
        "Vertical Ribs",
        "Horizontal Rings"
    ]
    static let groundAppearanceControlTitles = [
        "Ground Palette",
        "Grid Plane",
        "Grid Visibility",
        "Grid Spacing",
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
    static let futureWorkTrayTitles = [
        "Speaker Pattern"
    ]
    static let futureWorkLabel = "Future work"
    static let tuningTrayTitles = [
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
    static let globalDiceRandomizedControlTitles = [
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
    static let fpsMeterTargetFramesPerSecond = 60
    static let fpsMeterUnderTargetFramesPerSecond = 30
    static let fpsMeterLogSamplesPerSecond = 5
    static let removedRightPanelCards = [
        "Scene",
        "No speaker selected",
        "30-channel VU list"
    ]
    static let rightPanelPurpose = "tuning-debug-panel"
    static let defaultSettingsSourceFileName = "Orbital View VU Kit Settings 2026-05-21-171537.json"
    static let defaultRenderStyle: OrbitalViewportRenderStyle = .purple
    static let defaultSourceSpeakerRenderStyle: OrbitalViewportRenderStyle = defaultRenderStyle
    static let defaultGeodesicRenderStyle: OrbitalViewportRenderStyle = .purple
    static let defaultGeodesicSaturation = 0.0
    static let defaultShowRibbedSpeakerSphere = false
    static let defaultRibbedSphereThickness = 1.0
    static let defaultRibbedSphereVerticalRibs = 16
    static let defaultRibbedSphereHorizontalRings = 8
    static let defaultSpeakerShape: OrbitalViewportSpeakerShape = .cubeVU
    static let defaultViewportFrameRate: OrbitalViewportFrameRate = .sixty
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

    @State private var yaw = 0.0
    @State private var pitch = 0.0
    @State private var zoom = 1.0
    @State private var cameraView: OrbitalViewportCameraView = .isometric
    @State private var renderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultRenderStyle
    @State private var sourceSpeakerRenderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultSourceSpeakerRenderStyle
    @State private var geodesicRenderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultGeodesicRenderStyle
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
    @StateObject private var spatGRISOscListener = OrbitalViewportSpatGRISOSCListener()
    @State private var sourceMode: OrbitalViewportSourceMode = OrbitalViewportMockup.defaultSourceMode
    @State private var inputTrayExpanded = true
    @State private var telemetryAdvertisers = OrbitalViewportMockup.defaultTelemetryAdvertisers
    @State private var selectedTelemetryAdvertiserID: String?
    @State private var localAudioRenderMode: OrbitalViewportAudioRenderMode = .allMono
    @State private var cubeVUSettings = OrbitalViewportMockup.defaultCubeVUSettings
    @State private var cubeVUPreset: OrbitalViewportCubeVUPreset = OrbitalViewportMockup.defaultCubeVUPreset
    @State private var vuDriveMode: OrbitalViewportVUDriveMode = OrbitalViewportMockup.defaultVUDriveMode
    @State private var speakerLabelFont: OrbitalViewportSpeakerLabelFont = .systemDefault
    @State private var speakerLabelFontSizeSlider = OrbitalViewportMath.speakerLabelFontSizeSliderCenter
    @State private var objectTuning = OrbitalViewportObjectTuning.default
    @State private var themeExpanded = false
    @State private var sourceThemeExpanded = false
    @State private var viewThemeExpanded = false
    @State private var speakerLayoutExpanded = true
    @State private var sourceLayoutExpanded = true
    @State private var speakerGeometryExpanded = false
    @State private var sphereGeometryExpanded = false
    @State private var speakerPatternExpanded = false
    @State private var geodesicAppearanceExpanded = false
    @State private var groundAppearanceExpanded = false
    @State private var speakerLabelsExpanded = false
    @State private var meterCalibrationExpanded = false
    @State private var surfaceBloomExpanded = false
    @State private var objectOverlayExpanded = false
    @State private var trailsExpanded = false
    @State private var glowTrailsExpanded = false
    @State private var boundsExpanded = false
    @State private var performanceExpanded = false
    @State private var presetsExpanded = false
    @State private var diagnosticsExpanded = false
    @State private var frameRateSample = OrbitalViewportFrameRateSample.pending
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
        .onReceive(spatGRISOscListener.$latestMessage.compactMap { $0 }) { message in
            applySpatGRISOSCMessage(message)
        }
        .onReceive(spatGRISOscListener.$latestDiagnostic.compactMap { $0 }) { diagnostic in
            exportStatus = OrbitalViewportExportStatus(message: diagnostic.userMessage, isError: diagnostic.isError)
            recordDiagnostic(diagnostic.detail)
        }
        .onAppear {
            guard !didLoadInitialViewThemes else {
                return
            }
            didLoadInitialViewThemes = true
            refreshViewThemes(applyDefault: true)
            refreshSpeakerLayouts(applyDefault: true)
            refreshSourceLayouts(applyDefault: true)
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
        return OrbitalViewportRenderConfiguration(
            size: size,
            timeMS: timeMS,
            yaw: effectiveYaw,
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
            meterSource: activeMeterSource,
            cubeVUSettings: cubeVUSettings,
            activeViewportFramesPerSecond: viewportFrameRate.framesPerSecond,
            speakerLabelFont: speakerLabelFont,
            speakerLabelSizeScale: speakerLabelSizeScale,
            showSpeakerNumbers: showSpeakerNumbers,
            showHiddenLines: showHiddenLines,
            showGridPlane: showGridPlane,
            gridPlaneVisibility: gridPlaneVisibility,
            gridPlaneSpacing: gridPlaneSpacing,
            gridPlaneRenderStyle: gridPlaneRenderStyle,
            selectedChannel: selectedChannel,
            speakers: activeViewportSpeakers,
            sources: activeViewportSources,
            sceneCenter: sceneBounds.center,
            sceneHalfExtent: sceneBounds.halfExtent,
            spin: spin && !isDragging,
            spinStartYaw: spinStartYaw,
            spinStartTimeMS: spinStartTimeMS
        )
    }

    private var activeMeterSource: OrbitalViewportMeterSource {
        switch sourceMode {
        case .telemetry:
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
            selectedID: selectedTelemetryAdvertiserID
        )
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
            toggleRow("Speaker Numbers", isOn: $showSpeakerNumbers)
            toggleRow("Hidden Lines", isOn: $showHiddenLines)
        }
    }

    private var orbisonicThemeTray: some View {
        tuningTray("Sonic Sphere Speaker Palette", isExpanded: $themeExpanded) {
            VStack(spacing: 6) {
                ForEach(OrbitalViewportRenderStyle.allCases) { style in
                    paletteButton(style, selection: renderStyle) {
                        if renderStyle != style {
                            renderStyle = style
                            recordDiagnostic("Sonic Sphere speaker palette set to \(style.title)")
                        }
                    }
                }
            }
            tuningValueRow("Sonic Sphere Speaker Palette", value: renderStyle.title)
            tuningValueRow("App Skin", value: renderStyle.title)
            tuningValueRow("Cube VU Ramp", value: renderStyle.title)
        }
    }

    private var sourceSpeakerThemeTray: some View {
        tuningTray("Source Speaker Palette", isExpanded: $sourceThemeExpanded) {
            VStack(spacing: 6) {
                ForEach(OrbitalViewportRenderStyle.allCases) { style in
                    paletteButton(style, selection: sourceSpeakerRenderStyle) {
                        if sourceSpeakerRenderStyle != style {
                            sourceSpeakerRenderStyle = style
                            recordDiagnostic("Source speaker palette set to \(style.title)")
                        }
                    }
                }
            }
            tuningValueRow("Source Speaker Palette", value: sourceSpeakerRenderStyle.title)
        }
    }

    private var geodesicAppearanceTray: some View {
        tuningTray("Geodesic Appearance", isExpanded: $geodesicAppearanceExpanded) {
            VStack(spacing: 6) {
                ForEach(OrbitalViewportRenderStyle.allCases) { style in
                    paletteButton(style, selection: geodesicRenderStyle) {
                        if geodesicRenderStyle != style {
                            geodesicRenderStyle = style
                            recordDiagnostic("Geodesic palette set to \(style.title)")
                        }
                    }
                }
            }
            tuningSliderRow(
                "Geodesic Saturation",
                value: $geodesicSaturation,
                range: 0...1,
                step: 0.01,
                valueText: "\((geodesicSaturation * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            tuningValueRow("Geodesic Palette", value: geodesicRenderStyle.title)
        }
    }

    private var groundAppearanceTray: some View {
        tuningTray("Ground Appearance", isExpanded: $groundAppearanceExpanded) {
            VStack(spacing: 6) {
                ForEach(OrbitalViewportRenderStyle.allCases) { style in
                    paletteButton(style, selection: gridPlaneRenderStyle) {
                        if gridPlaneRenderStyle != style {
                            gridPlaneRenderStyle = style
                            recordDiagnostic("Ground palette set to \(style.title)")
                        }
                    }
                }
            }
            toggleRow("Grid Plane", isOn: $showGridPlane)
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
            tuningValueRow("Ground Palette", value: gridPlaneRenderStyle.title)
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
                tuningValueRow("Telemetry Status", value: advertiser?.status ?? "Waiting for provider")
                tuningValueRow("Displayed Meter", value: advertiser == nil ? "silent until telemetry arrives" : "prepared telemetry")
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

    private var speakerPatternTray: some View {
        tuningTray("Speaker Pattern", isExpanded: $speakerPatternExpanded) {
            futureWorkRow()
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
            currentSourceSpeakerRenderStyle: sourceSpeakerRenderStyle,
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

        renderStyle = roll.renderStyle
        sourceSpeakerRenderStyle = roll.sourceSpeakerRenderStyle
        showRibbedSpeakerSphere = roll.showRibbedSpeakerSphere
        ribbedSphereThickness = roll.ribbedSphereThickness
        ribbedSphereVerticalRibs = roll.ribbedSphereVerticalRibs
        ribbedSphereHorizontalRings = roll.ribbedSphereHorizontalRings
        geodesicRenderStyle = roll.geodesicRenderStyle
        geodesicSaturation = roll.geodesicSaturation
        gridPlaneRenderStyle = roll.gridPlaneRenderStyle
        showGridPlane = roll.showGridPlane
        gridPlaneVisibilitySlider = roll.gridPlaneVisibilitySlider
        gridPlaneSpacing = roll.gridPlaneSpacing

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

    private func paletteButton(
        _ style: OrbitalViewportRenderStyle,
        selection: OrbitalViewportRenderStyle,
        action: @escaping () -> Void
    ) -> some View {
        let isActive = selection == style
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
        ZStack(alignment: .bottomTrailing) {
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

            frameRateMeter(sample: frameRateSample)
                .padding(.trailing, 14)
                .padding(.bottom, 14)
        }
        .simultaneousGesture(magnificationGesture())
    }

    private func handleFrameRateSample(_ sample: OrbitalViewportFrameRateSample) {
        frameRateSample = sample
        if sample.shouldLog {
            recordDiagnostic(sample.diagnosticMessage)
        }
    }

    private func frameRateMeter(sample: OrbitalViewportFrameRateSample) -> some View {
        let statusColor = frameRateStatusColor(sample)

        return HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 7, height: 7)

            Text("FPS \(sample.displayFramesPerSecondText)")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(theme.text)
                .monospacedDigit()
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(theme.chipBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 8)
        .allowsHitTesting(false)
        .accessibilityLabel("Viewport FPS meter")
        .accessibilityValue(sample.accessibilityValue)
    }

    private func frameRateStatusColor(_ sample: OrbitalViewportFrameRateSample) -> Color {
        guard !sample.isPending else {
            return theme.muted
        }

        switch sample.status {
        case .target:
            return theme.accent
        case .belowTarget:
            return OrbitalViewportLabTheme.amber
        case .underTarget:
            return OrbitalViewportLabTheme.red
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
                viewThemeTray

                rightPanelSectionHeader("Speaker Appearance")
                speakerGeometryTray
                speakerPatternTray
                speakerLabelsTray
                orbisonicThemeTray
                sourceSpeakerThemeTray
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
            sourceSpeakerRenderStyle: sourceSpeakerRenderStyle,
            geodesicRenderStyle: geodesicRenderStyle,
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
                gridPlaneRenderStyle: gridPlaneRenderStyle
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
                applyViewTheme(payload, preferDefaultSourceWhenMissing: true)
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

        applyViewTheme(payload)
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
        preferDefaultSourceWhenMissing: Bool = false
    ) {
        renderStyle = payload.renderStyle
        sourceSpeakerRenderStyle = payload.sourceSpeakerRenderStyle
        geodesicRenderStyle = payload.geodesicRenderStyle
        geodesicSaturation = OrbitalViewportMath.clamp01(payload.geodesicSaturation)
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
        cameraView = payload.leftPanel.camera.cameraView
        yaw = payload.leftPanel.camera.yaw
        pitch = min(
            OrbitalViewportOrbitState.maxPitch,
            max(-OrbitalViewportOrbitState.maxPitch, payload.leftPanel.camera.pitch)
        )
        zoom = min(1.75, max(0.62, payload.leftPanel.camera.zoom))
        spin = payload.leftPanel.camera.spin
        cameraAdjusted = payload.leftPanel.camera.cameraAdjusted
        speakerSizeSlider = min(100, max(0, payload.leftPanel.viewDetail.speakerSizeSlider))
        fogDensitySlider = min(100, max(0, payload.leftPanel.viewDetail.fogDensitySlider))
        showSpeakerNumbers = payload.leftPanel.viewDetail.showSpeakerNumbers
        showHiddenLines = payload.leftPanel.viewDetail.showHiddenLines
        showGridPlane = payload.groundAppearance.showGridPlane
        gridPlaneVisibilitySlider = payload.groundAppearance.gridPlaneVisibilitySlider
        gridPlaneSpacing = payload.groundAppearance.gridPlaneSpacing
        gridPlaneRenderStyle = payload.groundAppearance.gridPlaneRenderStyle
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
        if framesPerSecond < Double(OrbitalViewportMockup.fpsMeterUnderTargetFramesPerSecond) {
            return .underTarget
        }
        if framesPerSecond < Double(OrbitalViewportMockup.fpsMeterTargetFramesPerSecond) {
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

    private var frameTimesMS: [Double] = []
    private var lastEmitTimeMS: Double?
    private var lastStatus: OrbitalViewportFrameRateStatus?

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
        let status = OrbitalViewportFrameRateStatus.status(for: framesPerSecond)
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
            targetFramesPerSecond: OrbitalViewportMockup.fpsMeterTargetFramesPerSecond,
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
    var themeID: String?
    let schemaVersion: Int
    let appName: String
    let exportedAt: String
    let renderStyle: OrbitalViewportRenderStyle
    let sourceSpeakerRenderStyle: OrbitalViewportRenderStyle
    let geodesicRenderStyle: OrbitalViewportRenderStyle
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
        self.geodesicRenderStyle = geodesicRenderStyle ?? renderStyle
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
        groundAppearance = try container.decodeIfPresent(
            OrbitalViewportGroundAppearanceExportSettings.self,
            forKey: .groundAppearance
        ) ?? OrbitalViewportGroundAppearanceExportSettings(
            showGridPlane: leftPanel.viewDetail.showGridPlane,
            gridPlaneVisibilitySlider: leftPanel.viewDetail.gridPlaneVisibilitySlider,
            gridPlaneSpacing: OrbitalViewportGridPlaneGeometry.defaultSpacing,
            gridPlaneRenderStyle: geodesicRenderStyle
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
        gridPlaneRenderStyle: OrbitalViewportMockup.defaultGeodesicRenderStyle
    )

    let showGridPlane: Bool
    let gridPlaneVisibilitySlider: Double
    let gridPlaneSpacing: Double
    let gridPlaneRenderStyle: OrbitalViewportRenderStyle

    init(
        showGridPlane: Bool = false,
        gridPlaneVisibilitySlider: Double = OrbitalViewportGridPlaneGeometry.defaultVisibilitySlider,
        gridPlaneSpacing: Double = OrbitalViewportGridPlaneGeometry.defaultSpacing,
        gridPlaneRenderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultGeodesicRenderStyle
    ) {
        self.showGridPlane = showGridPlane
        self.gridPlaneVisibilitySlider = min(100, max(0, gridPlaneVisibilitySlider))
        self.gridPlaneSpacing = OrbitalViewportGridPlaneGeometry.normalizedSpacing(gridPlaneSpacing)
        self.gridPlaneRenderStyle = gridPlaneRenderStyle
    }

    enum CodingKeys: String, CodingKey {
        case showGridPlane
        case gridPlaneVisibilitySlider
        case gridPlaneSpacing
        case gridPlaneRenderStyle
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
            ) ?? OrbitalViewportMockup.defaultGeodesicRenderStyle
        )
    }
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
        (0, 0)
    }

    fileprivate var baseViewDirection: OVVector3 {
        switch self {
        case .plan:
            return OVVector3(x: 0, y: 0, z: 1)
        case .elevation:
            return OVVector3(x: 0, y: 1, z: 0)
        case .isometric:
            let yaw = Double.pi * 0.25
            let pitch = Double.pi * 0.22
            let horizontal = cos(pitch)
            return OVVector3(
                x: sin(yaw) * horizontal,
                y: cos(yaw) * horizontal,
                z: sin(pitch)
            ).normalized()
        }
    }

    fileprivate var baseUp: OVVector3 {
        switch self {
        case .plan:
            return OVVector3(x: 0, y: -1, z: 0)
        case .elevation:
            return OVVector3(x: 0, y: 0, z: 1)
        case .isometric:
            let direction = baseViewDirection
            let worldUp = OVVector3(x: 0, y: 0, z: 1)
            return (worldUp - (direction * worldUp.dot(direction)))
                .normalized(fallback: OVVector3(x: 0, y: 0, z: 1))
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
        let url = URL(fileURLWithPath: fileName)
        return Bundle.module.url(
            forResource: url.deletingPathExtension().lastPathComponent,
            withExtension: url.pathExtension,
            subdirectory: "Fonts"
        ) ?? Bundle.module.url(
            forResource: url.deletingPathExtension().lastPathComponent,
            withExtension: url.pathExtension
        )
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
    let geodesicSaturation: Double
    let gridPlaneRenderStyle: OrbitalViewportRenderStyle
    let showGridPlane: Bool
    let gridPlaneVisibilitySlider: Double
    let gridPlaneSpacing: Double
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
        currentSourceSpeakerRenderStyle: OrbitalViewportRenderStyle = OrbitalViewportMockup.defaultSourceSpeakerRenderStyle,
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
        let geodesicRenderStyle = randomRenderStyle(
            excluding: currentGeodesicRenderStyle,
            using: &generator
        )
        let geodesicSaturation = randomSaturation(
            excluding: currentGeodesicSaturation,
            using: &generator
        )
        let sourceSpeakerRenderStyle = randomRenderStyle(
            excluding: currentSourceSpeakerRenderStyle,
            using: &generator
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
            renderStyle: OrbitalViewportRenderStyle.allCases.randomElement(using: &generator) ?? OrbitalViewportMockup.defaultRenderStyle,
            sourceSpeakerRenderStyle: sourceSpeakerRenderStyle,
            showRibbedSpeakerSphere: !currentShowRibbedSpeakerSphere,
            ribbedSphereThickness: ribbedSphereThickness,
            ribbedSphereVerticalRibs: ribbedSphereVerticalRibs,
            ribbedSphereHorizontalRings: ribbedSphereHorizontalRings,
            geodesicRenderStyle: geodesicRenderStyle,
            geodesicSaturation: geodesicSaturation,
            gridPlaneRenderStyle: OrbitalViewportRenderStyle.allCases.randomElement(using: &generator) ?? OrbitalViewportMockup.defaultGeodesicRenderStyle,
            showGridPlane: Bool.random(using: &generator),
            gridPlaneVisibilitySlider: Double.random(in: 0...100, using: &generator),
            gridPlaneSpacing: Double.random(in: OrbitalViewportGridPlaneGeometry.spacingRange, using: &generator),
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

    static func option(for framesPerSecond: Int) -> OrbitalViewportFrameRate {
        allCases.first(where: { $0.framesPerSecond == framesPerSecond }) ?? .sixty
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
            yaw: yaw + Double(translation.width) * 0.006,
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
        let baseDirection = view.baseViewDirection.normalized(fallback: OVVector3(x: 0, y: 1, z: 0))
        let baseUp = view.baseUp.normalized(fallback: OVVector3(x: 0, y: 0, z: 1))
        let yawedDirection = baseDirection.rotated(around: baseUp, angle: yaw)
            .normalized(fallback: baseDirection)
        let yawedRight = OVVector3.cross(baseUp, yawedDirection)
            .normalized(fallback: OVVector3(x: 1, y: 0, z: 0))
        let pitchedDirection = yawedDirection.rotated(around: yawedRight, angle: pitch)
            .normalized(fallback: yawedDirection)
        let pitchedUp = baseUp.rotated(around: yawedRight, angle: pitch)
            .normalized(fallback: baseUp)
        let right = OVVector3.cross(pitchedDirection, pitchedUp)
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
    let speakerLabelFont: OrbitalViewportSpeakerLabelFont
    let speakerLabelSizeScale: Double
    let showSpeakerNumbers: Bool
    let showHiddenLines: Bool
    let showGridPlane: Bool
    let gridPlaneVisibility: Double
    let gridPlaneSpacing: Double
    let gridPlaneRenderStyle: OrbitalViewportRenderStyle
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
        speakerLabelFont: OrbitalViewportSpeakerLabelFont = .systemDefault,
        speakerLabelSizeScale: Double = 1,
        showSpeakerNumbers: Bool,
        showHiddenLines: Bool,
        showGridPlane: Bool = false,
        gridPlaneVisibility: Double = OrbitalViewportGridPlaneGeometry.defaultVisibility,
        gridPlaneSpacing: Double = OrbitalViewportGridPlaneGeometry.defaultSpacing,
        gridPlaneRenderStyle: OrbitalViewportRenderStyle? = nil,
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
        self.speakerLabelFont = speakerLabelFont
        self.speakerLabelSizeScale = max(0.1, speakerLabelSizeScale)
        self.showSpeakerNumbers = showSpeakerNumbers
        self.showHiddenLines = showHiddenLines
        self.showGridPlane = showGridPlane
        self.gridPlaneVisibility = OrbitalViewportMath.clamp01(gridPlaneVisibility)
        self.gridPlaneSpacing = OrbitalViewportGridPlaneGeometry.normalizedSpacing(gridPlaneSpacing)
        self.gridPlaneRenderStyle = gridPlaneRenderStyle ?? OrbitalViewportMockup.defaultGeodesicRenderStyle
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
        return OrbitalViewportMath.clamp01((frontClipPlane - depth) / (1.15 * sceneScale))
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

    func ribbedSphereSegmentVisible(startDepth: Double, endDepth: Double) -> Bool {
        if hiddenLinesVisible || startDepth >= frontClipPlane || endDepth >= frontClipPlane {
            return true
        }
        return fogConfiguration.isEnabled && ribbedSphereDepthAlpha(startDepth: startDepth, endDepth: endDepth) > 0.04
    }

    func ribbedSphereDepthAlpha(startDepth: Double, endDepth: Double) -> Double {
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
            sceneCenter: sceneCenter,
            sceneHalfExtent: sceneHalfExtent,
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

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.speakers = configuration.speakers
        self.ribbedSphereThickness = configuration.ribbedSphereThickness
        self.ribbedSphereVerticalRibs = configuration.ribbedSphereVerticalRibs
        self.ribbedSphereHorizontalRings = configuration.ribbedSphereHorizontalRings
    }
}

struct OrbitalViewportRibbedSpeakerSphereUpdateKey: Equatable {
    let yaw: Double
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let showRibbedSpeakerSphere: Bool
    let geodesicRenderStyle: OrbitalViewportRenderStyle
    let geodesicSaturation: Double
    let showHiddenLines: Bool

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.yaw = configuration.yaw
        self.pitch = configuration.pitch
        self.cameraView = configuration.cameraView
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

struct OrbitalViewportSpeakerVisibilityUpdateKey: Equatable {
    let yaw: Double
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let showHiddenLines: Bool
    let showSpeakerNumbers: Bool
    let selectedChannel: Int?
    let speakers: [OrbitalViewportSpeaker]

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.yaw = configuration.yaw
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

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.showGridPlane = configuration.showGridPlane
        self.gridPlaneVisibility = configuration.gridPlaneVisibility
        self.gridPlaneSpacing = configuration.gridPlaneSpacing
        self.gridPlaneRenderStyle = configuration.gridPlaneRenderStyle
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
        var materialSettings = configuration.cubeVUSettings
        materialSettings.speakerHeight = 1
        self.cubeVUSettings = materialSettings
        self.selectedChannel = configuration.selectedChannel
    }
}

struct OrbitalViewportSourceUpdateKey: Equatable {
    let yaw: Double
    let pitch: Double
    let cameraView: OrbitalViewportCameraView
    let showHiddenLines: Bool
    let sourceSpeakerRenderStyle: OrbitalViewportRenderStyle
    let meterSourceMode: OrbitalViewportMeterSource.Mode
    let meterFrame: Int
    let activeFramesPerSecond: Int
    let sources: [OrbitalViewportSourceMarker]

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.yaw = configuration.yaw
        self.pitch = configuration.pitch
        self.cameraView = configuration.cameraView
        self.showHiddenLines = configuration.showHiddenLines
        self.sourceSpeakerRenderStyle = configuration.sourceSpeakerRenderStyle
        self.meterSourceMode = configuration.meterSource.mode
        self.meterFrame = Int(configuration.timeMS / (1000 / Double(configuration.activeViewportFramesPerSecond)))
        self.activeFramesPerSecond = configuration.activeViewportFramesPerSecond
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
    static let thicknessRange = 0.25...2.5
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

    static func segments(
        for speakers: [OrbitalViewportSpeaker],
        verticalRibs: Int,
        horizontalRings: Int,
        fallbackRadius: Double = 1
    ) -> [Segment] {
        let fit = fit(for: speakers, fallbackRadius: fallbackRadius)
        let ribCount = normalizedVerticalRibs(verticalRibs)
        let ringCount = normalizedHorizontalRings(horizontalRings)
        let longitudes = verticalRibLongitudes(for: speakers, count: ribCount)
        let latitudes = horizontalRingLatitudes(for: speakers, count: ringCount)
        let meridianSteps = max(24, min(80, 24 + ringCount * 3))
        let ringSteps = max(24, min(96, ribCount * 3))
        var output: [Segment] = []

        for (ribIndex, longitude) in longitudes.enumerated() {
            for step in 0..<meridianSteps {
                let startLatitude = (-Double.pi * 0.5) + (Double(step) / Double(meridianSteps)) * Double.pi
                let endLatitude = (-Double.pi * 0.5) + (Double(step + 1) / Double(meridianSteps)) * Double.pi
                output.append(
                    Segment(
                        kind: .verticalRib,
                        index: ribIndex,
                        start: point(center: fit.center, radius: fit.radius, longitude: longitude, latitude: startLatitude),
                        end: point(center: fit.center, radius: fit.radius, longitude: longitude, latitude: endLatitude)
                    )
                )
            }
        }

        for (ringIndex, latitude) in latitudes.enumerated() {
            for step in 0..<ringSteps {
                let startLongitude = (Double(step) / Double(ringSteps)) * twoPi
                let endLongitude = (Double(step + 1) / Double(ringSteps)) * twoPi
                output.append(
                    Segment(
                        kind: .horizontalRing,
                        index: ringIndex,
                        start: point(center: fit.center, radius: fit.radius, longitude: startLongitude, latitude: latitude),
                        end: point(center: fit.center, radius: fit.radius, longitude: endLongitude, latitude: latitude)
                    )
                )
            }
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

        let startDistance = max(0.1, cameraDistance - (0.24 + normalized * 0.18))
        let endDistance = cameraDistance + max(0.42, 2.55 - (normalized * 2.12))
        return OrbitalViewportFogConfiguration(
            isEnabled: true,
            normalizedDensity: normalized,
            startDistance: startDistance,
            endDistance: max(startDistance + 0.1, endDistance),
            densityExponent: 0.62 + normalized * 1.95
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
    let onFrameRateSample: (OrbitalViewportFrameRateSample) -> Void

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
        context.coordinator.onFrameRateSample = onFrameRateSample
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
    }

    final class Coordinator {
        let scene = SCNScene()
        let rootNode = SCNNode()
        let gridPlaneNode = SCNNode()
        let ribbedSphereNode = SCNNode()
        let speakerRoot = SCNNode()
        let sourceRoot = SCNNode()
        let labelRoot = SCNNode()
        let cameraNode = SCNNode()

        private weak var view: OrbitalViewportSceneNSView?
        private var gridPlaneLineNodes: [SCNNode] = []
        private var ribbedSphereSegmentNodes: [SCNNode] = []
        private var speakerNodes: [Int: SCNNode] = [:]
        private var speakerOutlineNodes: [Int: [SCNNode]] = [:]
        private var sourceNodes: [Int: SCNNode] = [:]
        private var labelNodes: [Int: SCNNode] = [:]
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
        private var lastSourceUpdateKey: OrbitalViewportSourceUpdateKey?
        private var lastFogKey: OrbitalViewportFogUpdateKey?
        private var lastRenderedAnimationTimeMS: Double?
        private var gridPlaneSpacing = OrbitalViewportGridPlaneGeometry.defaultSpacing
        private var activeFramesPerSecond = OrbitalViewport3DSceneView.sceneFramesPerSecond
        private var frameRateMonitor = OrbitalViewportFrameRateMonitor()
        var onFrameRateSample: (OrbitalViewportFrameRateSample) -> Void = { _ in }

        private(set) var gridPlaneBuildCount = 0
        private(set) var ribbedSphereBuildCount = 0
        private(set) var speakerRebuildCount = 0
        private(set) var sourceUpdateCount = 0
        private(set) var labelRebuildCount = 0

        init() {
            scene.rootNode.addChildNode(rootNode)
            rootNode.addChildNode(gridPlaneNode)
            rootNode.addChildNode(ribbedSphereNode)
            rootNode.addChildNode(speakerRoot)
            rootNode.addChildNode(sourceRoot)
            rootNode.addChildNode(labelRoot)
            configureCamera()
            configureLights()
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
            let normalizedFramesPerSecond = OrbitalViewportFrameRate.normalized(framesPerSecond)
            guard activeFramesPerSecond != normalizedFramesPerSecond else {
                return
            }

            activeFramesPerSecond = normalizedFramesPerSecond
            lastRenderedAnimationTimeMS = nil
            frameRateMonitor.reset()
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
            let gridPlaneKey = OrbitalViewportGridPlaneUpdateKey(configuration: configuration)
            let ribbedSphereTopologyKey = OrbitalViewportRibbedSpeakerSphereTopologyKey(configuration: configuration)
            let ribbedSphereUpdateKey = OrbitalViewportRibbedSpeakerSphereUpdateKey(configuration: configuration)
            let visibilityKey = OrbitalViewportSpeakerVisibilityUpdateKey(configuration: configuration)
            let materialKey = OrbitalViewportSpeakerMaterialUpdateKey(configuration: configuration)
            let sourceKey = OrbitalViewportSourceUpdateKey(configuration: configuration)
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
            if lastGridPlaneKey != gridPlaneKey {
                updateGridPlane(configuration: configuration)
                lastGridPlaneKey = gridPlaneKey
            }
            if lastRibbedSphereTopologyKey != ribbedSphereTopologyKey {
                buildRibbedSpeakerSphere(
                    speakers: configuration.speakers,
                    verticalRibs: configuration.ribbedSphereVerticalRibs,
                    horizontalRings: configuration.ribbedSphereHorizontalRings,
                    thickness: configuration.ribbedSphereThickness,
                    fallbackRadius: configuration.sceneScale
                )
                lastRibbedSphereTopologyKey = ribbedSphereTopologyKey
                lastRibbedSphereUpdateKey = nil
            }
            if lastRibbedSphereUpdateKey != ribbedSphereUpdateKey {
                updateRibbedSpeakerSphere(configuration: configuration)
                lastRibbedSphereUpdateKey = ribbedSphereUpdateKey
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

            if lastSourceUpdateKey != sourceKey {
                updateSources(configuration: configuration, snapshot: snapshot)
                lastSourceUpdateKey = sourceKey
            }

            if lastFogKey != fogKey {
                updateFog(configuration: configuration)
                lastFogKey = fogKey
            }

            view?.needsDisplay = true
            if view != nil,
               let sample = frameRateMonitor.recordFrame(at: currentTimeMS()) {
                onFrameRateSample(sample)
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

        private func buildGridPlane(spacing: Double = OrbitalViewportGridPlaneGeometry.defaultSpacing) {
            gridPlaneBuildCount += 1
            gridPlaneNode.childNodes.forEach { $0.removeFromParentNode() }
            gridPlaneLineNodes.removeAll()
            gridPlaneSpacing = OrbitalViewportGridPlaneGeometry.normalizedSpacing(spacing)
            gridPlaneNode.name = "grid-plane"
            gridPlaneNode.isHidden = true

            for line in OrbitalViewportGridPlaneGeometry.lineSegments(spacing: gridPlaneSpacing) {
                let node = cylinderNode(
                    from: line.start,
                    to: line.end,
                    radius: line.isMajor
                        ? OrbitalViewportGridPlaneGeometry.majorLineRadius
                        : OrbitalViewportGridPlaneGeometry.minorLineRadius
                )
                node.name = line.isMajor ? "grid-plane-major-line" : "grid-plane-line"
                let material = SCNMaterial()
                material.lightingModel = .constant
                material.isDoubleSided = true
                node.geometry?.materials = [material]
                gridPlaneNode.addChildNode(node)
                gridPlaneLineNodes.append(node)
            }
        }

        private func updateGridPlane(configuration: OrbitalViewportRenderConfiguration) {
            gridPlaneNode.isHidden = !configuration.showGridPlane
            guard configuration.showGridPlane else {
                return
            }

            let lineSegments = OrbitalViewportGridPlaneGeometry.lineSegments(spacing: configuration.gridPlaneSpacing)
            if gridPlaneLineNodes.count != lineSegments.count ||
                abs(gridPlaneSpacing - configuration.gridPlaneSpacing) > 0.000_001 {
                buildGridPlane(spacing: configuration.gridPlaneSpacing)
                gridPlaneNode.isHidden = false
            }

            let theme = configuration.gridPlaneTheme
            let structureColor = theme.structure
            let axisColor = theme.equator

            for (index, lineNode) in gridPlaneLineNodes.enumerated() {
                let line = lineSegments[index]
                setMaterial(
                    lineNode.geometry?.firstMaterial,
                    color: line.isMajor ? axisColor : structureColor,
                    alpha: OrbitalViewportGridPlaneGeometry.alpha(
                        for: line,
                        visibility: configuration.gridPlaneVisibility
                    )
                )
            }
        }

        private func updateCamera(configuration: OrbitalViewportRenderConfiguration) {
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
            ribbedSphereNode.childNodes.forEach { $0.removeFromParentNode() }
            ribbedSphereSegmentNodes.removeAll()
            ribbedSphereNode.name = "ribbed-speaker-sphere"
            ribbedSphereNode.isHidden = true

            let radius = OrbitalViewportRibbedSpeakerSphereGeometry.baseStrutRadius *
                OrbitalViewportRibbedSpeakerSphereGeometry.normalizedThickness(thickness)
            for segment in OrbitalViewportRibbedSpeakerSphereGeometry.segments(
                for: speakers,
                verticalRibs: verticalRibs,
                horizontalRings: horizontalRings,
                fallbackRadius: fallbackRadius
            ) {
                let node = cylinderNode(
                    from: segment.start,
                    to: segment.end,
                    radius: radius
                )
                node.name = "ribbed-speaker-sphere-\(segment.kind.rawValue)-\(segment.index)"
                let material = SCNMaterial()
                material.lightingModel = .constant
                material.isDoubleSided = true
                node.geometry?.materials = [material]
                ribbedSphereNode.addChildNode(node)
                ribbedSphereSegmentNodes.append(node)
            }
        }

        private func rebuildSpeakers(
            speakers: [OrbitalViewportSpeaker],
            shape: OrbitalViewportSpeakerShape,
            speakerSize: Double,
            speakerLabelFont: OrbitalViewportSpeakerLabelFont,
            speakerLabelSizeScale: Double
        ) {
            speakerRebuildCount += 1
            speakerRoot.childNodes.forEach { $0.removeFromParentNode() }
            speakerNodes.removeAll()
            speakerOutlineNodes.removeAll()
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
            labelRoot.childNodes.forEach { $0.removeFromParentNode() }
            labelNodes.removeAll()
            lastSpeakerLabelGeometryKey = OrbitalViewportSpeakerLabelGeometryUpdateKey(
                speakerLabelFont: font,
                speakerLabelSizeScale: sizeScale
            )
            lastSpeakerVisibilityKey = nil
            lastSpeakerMaterialKey = nil

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

        private func updateRibbedSpeakerSphere(configuration: OrbitalViewportRenderConfiguration) {
            ribbedSphereNode.isHidden = !configuration.showRibbedSpeakerSphere
            guard configuration.showRibbedSpeakerSphere else {
                return
            }

            let segments = OrbitalViewportRibbedSpeakerSphereGeometry.segments(
                for: configuration.speakers,
                verticalRibs: configuration.ribbedSphereVerticalRibs,
                horizontalRings: configuration.ribbedSphereHorizontalRings,
                fallbackRadius: configuration.sceneScale
            )
            if segments.count != ribbedSphereSegmentNodes.count {
                buildRibbedSpeakerSphere(
                    speakers: configuration.speakers,
                    verticalRibs: configuration.ribbedSphereVerticalRibs,
                    horizontalRings: configuration.ribbedSphereHorizontalRings,
                    thickness: configuration.ribbedSphereThickness,
                    fallbackRadius: configuration.sceneScale
                )
            }

            let theme = configuration.geodesicTheme
            for (index, segmentNode) in ribbedSphereSegmentNodes.enumerated() {
                guard let segment = segments[safe: index] else {
                    segmentNode.isHidden = true
                    continue
                }
                let start = configuration.rotate(segment.start)
                let end = configuration.rotate(segment.end)
                let visible = configuration.ribbedSphereSegmentVisible(startDepth: start.z, endDepth: end.z)
                segmentNode.isHidden = !visible
                let depthAlpha = configuration.ribbedSphereDepthAlpha(startDepth: start.z, endDepth: end.z)
                let baseAlpha = segment.kind == .verticalRib ? 0.74 : 0.64
                let alpha = baseAlpha * depthAlpha * OrbitalViewportRibbedSpeakerSphereGeometry.frontLineAlpha
                let color = configuration.geodesicColor(
                    segment.kind == .verticalRib ? theme.equator : theme.structure
                )
                setMaterial(
                    segmentNode.geometry?.firstMaterial,
                    color: color,
                    alpha: alpha,
                    emission: color.opacity(alpha * 0.28)
                )
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
                    if configuration.speakerLabelFont.usesTextureBackedSceneKitLabel {
                        setTextureBackedLabelMaterial(
                            label.geometry?.firstMaterial,
                            color: labelColor,
                            alpha: selected ? 1 : 0.94
                        )
                    } else {
                        setMaterial(
                            label.geometry?.firstMaterial,
                            color: labelColor,
                            alpha: selected ? 1 : 0.94,
                            emission: labelColor.opacity(selected ? 0.35 : 0.18)
                        )
                    }
                }
            }
        }

        private func updateSources(
            configuration: OrbitalViewportRenderConfiguration,
            snapshot: OrbitalViewportSnapshot
        ) {
            sourceUpdateCount += 1
            let activeIDs = Set(configuration.sources.map(\.sourceID))
            let staleIDs = sourceNodes.keys.filter { !activeIDs.contains($0) }
            for sourceID in staleIDs {
                sourceNodes[sourceID]?.removeFromParentNode()
                sourceNodes.removeValue(forKey: sourceID)
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
                }
            }

            for source in snapshot.sources {
                guard let node = sourceNodes[source.sourceID] else {
                    continue
                }
                node.position = OVVector3(source.source).scn
                node.isHidden = !source.visible
                let color = source.source.color(theme: configuration.sourceSpeakerTheme)
                let alpha = configuration.speakerAlpha(depth: source.depth, selected: false)
                let bloom = 0.24 + (source.peak * 0.55)
                setMaterial(
                    node.geometry?.firstMaterial,
                    color: color,
                    alpha: alpha,
                    emission: color.opacity(OrbitalViewportMath.clamp01(bloom))
                )
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

        private func setTextureBackedLabelMaterial(
            _ material: SCNMaterial?,
            color: Color,
            alpha: Double
        ) {
            material?.multiply.contents = NSColor(color).withAlphaComponent(alpha)
            material?.transparency = CGFloat(alpha)
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
        drawGridPlane()
        drawRibbedSpeakerSphere()
        drawFogVeil(size: size)
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
                style: StrokeStyle(lineWidth: line.isMajor ? 1.05 : 0.72, lineCap: .round)
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
                let fade = min(configuration.hiddenDepthFade(clipped.start.z), configuration.hiddenDepthFade(clipped.end.z))
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
                item.segment.kind == .verticalRib ? geodesicTheme.equator : geodesicTheme.structure
            )
            context.stroke(
                path,
                with: .color(strokeColor.opacity(alpha)),
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
            let color = source.source.color(theme: sourceSpeakerTheme)
            context.fill(Path(ellipseIn: rect), with: .color(color.opacity(0.32 + source.peak * 0.42)))
            context.stroke(Path(ellipseIn: rect), with: .color(theme.selectedLabel.opacity(0.58)), lineWidth: 1)
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

    var simdNormalized: SIMD3<Float> {
        let vector = SIMD3<Float>(Float(x), Float(z), Float(y))
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
