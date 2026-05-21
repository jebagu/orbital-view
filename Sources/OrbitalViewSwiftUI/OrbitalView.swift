import OrbitalViewCore
import SwiftUI

public struct OrbitalView: View {
    public let scene: OrbitalViewSceneSpec
    public let meters: SpeakerMeterFrame?
    public let objectFrames: OrbitalViewObjectFrameSet?
    public let objectMeters: ObjectMeterFrame?
    public let inputDiagnostics: OrbitalViewInputDiagnostics

    let showsMeterSettingsTray: Bool
    let visualPresetStore: (any OrbitalViewVisualPresetStore)?

    @Binding private var camera: OrbitalViewCameraState
    @Binding private var selection: OrbitalViewSelection?
    @Binding private var meterVisualSettings: SpeakerMeterVisualSettings
    @Binding private var objectVisualSettingsBinding: ObjectVisualSettings
    @Binding private var performanceSettingsBinding: OrbitalViewPerformanceSettings
    @State private var meterSettingsTrayExpanded = false

    private let onEvents: ([OrbitalViewEvent]) -> Void

    public var objectVisualSettings: ObjectVisualSettings {
        objectVisualSettingsBinding
    }

    public var performanceSettings: OrbitalViewPerformanceSettings {
        performanceSettingsBinding
    }

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        objectFrames: OrbitalViewObjectFrameSet? = nil,
        objectMeters: ObjectMeterFrame? = nil,
        objectVisualSettings: ObjectVisualSettings = .default,
        performanceSettings: OrbitalViewPerformanceSettings = .default,
        inputDiagnostics: OrbitalViewInputDiagnostics = .empty,
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?> = .constant(nil),
        onEvents: @escaping ([OrbitalViewEvent]) -> Void = { _ in }
    ) {
        self.scene = scene
        self.meters = meters
        self.objectFrames = objectFrames
        self.objectMeters = objectMeters
        self.inputDiagnostics = inputDiagnostics
        self.showsMeterSettingsTray = false
        self.visualPresetStore = nil
        self._camera = camera
        self._selection = selection
        self._meterVisualSettings = .constant(.default)
        self._objectVisualSettingsBinding = .constant(objectVisualSettings)
        self._performanceSettingsBinding = .constant(performanceSettings)
        self.onEvents = onEvents
    }

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        objectFrames: OrbitalViewObjectFrameSet? = nil,
        objectMeters: ObjectMeterFrame? = nil,
        objectVisualSettings: ObjectVisualSettings = .default,
        performanceSettings: OrbitalViewPerformanceSettings = .default,
        inputDiagnostics: OrbitalViewInputDiagnostics = .empty,
        visualPresetStore: (any OrbitalViewVisualPresetStore)? = nil,
        showsMeterSettingsTray: Bool = true,
        meterVisualSettings: Binding<SpeakerMeterVisualSettings>,
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?> = .constant(nil),
        onEvents: @escaping ([OrbitalViewEvent]) -> Void = { _ in }
    ) {
        self.scene = scene
        self.meters = meters
        self.objectFrames = objectFrames
        self.objectMeters = objectMeters
        self.inputDiagnostics = inputDiagnostics
        self.showsMeterSettingsTray = showsMeterSettingsTray
        self.visualPresetStore = visualPresetStore
        self._camera = camera
        self._selection = selection
        self._meterVisualSettings = meterVisualSettings
        self._objectVisualSettingsBinding = .constant(objectVisualSettings)
        self._performanceSettingsBinding = .constant(performanceSettings)
        self.onEvents = onEvents
    }

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        objectFrames: OrbitalViewObjectFrameSet? = nil,
        objectMeters: ObjectMeterFrame? = nil,
        objectVisualSettings: Binding<ObjectVisualSettings>,
        performanceSettings: Binding<OrbitalViewPerformanceSettings> = .constant(.default),
        inputDiagnostics: OrbitalViewInputDiagnostics = .empty,
        visualPresetStore: (any OrbitalViewVisualPresetStore)? = nil,
        showsMeterSettingsTray: Bool = true,
        meterVisualSettings: Binding<SpeakerMeterVisualSettings>,
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?> = .constant(nil),
        onEvents: @escaping ([OrbitalViewEvent]) -> Void = { _ in }
    ) {
        self.scene = scene
        self.meters = meters
        self.objectFrames = objectFrames
        self.objectMeters = objectMeters
        self.inputDiagnostics = inputDiagnostics
        self.showsMeterSettingsTray = showsMeterSettingsTray
        self.visualPresetStore = visualPresetStore
        self._camera = camera
        self._selection = selection
        self._meterVisualSettings = meterVisualSettings
        self._objectVisualSettingsBinding = objectVisualSettings
        self._performanceSettingsBinding = performanceSettings
        self.onEvents = onEvents
    }

    public var body: some View {
        VStack(spacing: 0) {
            OrbitalViewMetalView(
                configuration: OrbitalViewRenderConfiguration(
                    scene: scene,
                    meters: meters,
                    meterVisualSettings: meterVisualSettings,
                    objectFrames: objectFrames,
                    objectMeters: objectMeters,
                    objectVisualSettings: objectVisualSettings,
                    performanceSettings: performanceSettings,
                    camera: camera,
                    selection: selection
                ),
                onEvents: onEvents
            )

            if showsMeterSettingsTray {
                OrbitalViewMeterSettingsTray(
                    settings: $meterVisualSettings,
                    isExpanded: $meterSettingsTrayExpanded,
                    scene: scene,
                    meters: meters,
                    selection: selection,
                    objectFrames: objectFrames,
                    objectMeters: objectMeters,
                    objectSettings: $objectVisualSettingsBinding,
                    performanceSettings: $performanceSettingsBinding,
                    inputDiagnostics: inputDiagnostics,
                    visualPresetStore: visualPresetStore
                )
            }
        }
    }
}

struct OrbitalViewMeterSettingsTray: View {
    @Binding var settings: SpeakerMeterVisualSettings
    @Binding var isExpanded: Bool

    let scene: OrbitalViewSceneSpec
    let meters: SpeakerMeterFrame?
    let selection: OrbitalViewSelection?
    let objectFrames: OrbitalViewObjectFrameSet?
    let objectMeters: ObjectMeterFrame?
    @Binding var objectSettings: ObjectVisualSettings
    @Binding var performanceSettings: OrbitalViewPerformanceSettings
    let inputDiagnostics: OrbitalViewInputDiagnostics
    let visualPresetStore: (any OrbitalViewVisualPresetStore)?

    @State private var presetName = "Custom VU Preset"
    @State private var presetStatus: String?
    @State private var speakerVUExpanded = true
    @State private var meterCalibrationExpanded = false
    @State private var surfaceBloomExpanded = false
    @State private var objectOverlayExpanded = false
    @State private var trailsExpanded = false
    @State private var boundsExpanded = false
    @State private var performanceExpanded = false
    @State private var presetsExpanded = false
    @State private var diagnosticsExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: 10) {
                    collapsibleTray("Speaker VU", isExpanded: $speakerVUExpanded) {
                        speakerVUSection
                    }
                    collapsibleTray("Meter Calibration", isExpanded: $meterCalibrationExpanded) {
                        meterCalibrationSection
                    }
                    collapsibleTray("Surface + Bloom", isExpanded: $surfaceBloomExpanded) {
                        surfaceBloomSection
                    }
                    collapsibleTray("Object Overlay", isExpanded: $objectOverlayExpanded) {
                        objectOverlaySection
                    }
                    collapsibleTray("Trails", isExpanded: $trailsExpanded) {
                        trailsSection
                    }
                    collapsibleTray("Bounds", isExpanded: $boundsExpanded) {
                        boundsSection
                    }
                    collapsibleTray("Graphical Performance vs CPU Load", isExpanded: $performanceExpanded) {
                        performanceSection
                    }
                    collapsibleTray("Presets", isExpanded: $presetsExpanded) {
                        presetSection
                    }
                    collapsibleTray("Debug + Diagnostics", isExpanded: $diagnosticsExpanded) {
                        diagnosticsSection
                    }
                }
                .padding(.top, 8)
            } label: {
                Text("Viewport Tuning")
                    .font(.caption.weight(.semibold))
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
        }
    }

    private func collapsibleTray<Content: View>(
        _ title: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        DisclosureGroup(isExpanded: isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(.top, 8)
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var speakerVUSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            valueRow("Shape", "Cube VU")
            sliderRow("Visual Gain", value: visualGainBinding, range: -24...24, step: 0.5, valueText: gainText)

            Picker("Style", selection: styleBinding) {
                ForEach(SpeakerMeterVisualStyle.builtInStyles, id: \.self) { style in
                    Text(style.displayName).tag(style)
                }
            }
            .pickerStyle(.menu)

            Picker("Color Scheme", selection: colorSchemeBinding) {
                ForEach(SpeakerMeterColorScheme.allCases, id: \.self) { scheme in
                    Text(scheme.displayName).tag(scheme)
                }
            }
            .pickerStyle(.menu)

            sliderRow(
                "Speaker Height: Cube -> 2 Cubes",
                value: speakerZScaleBinding,
                range: 1...2,
                step: 0.01,
                valueText: settings.speakerZScale.formatted(.number.precision(.fractionLength(2)))
            )
        }
    }

    private var meterCalibrationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow(
                "Input Calibration",
                value: inputCalibrationBinding,
                range: 0.25...2,
                step: 0.05,
                valueText: "\(settings.inputCalibration.formatted(.number.precision(.fractionLength(2))))x"
            )
            sliderRow(
                "Level Compression",
                value: levelCompressionBinding,
                range: 1...4,
                step: 0.05,
                valueText: "\(settings.levelCompression.formatted(.number.precision(.fractionLength(2))))x"
            )
            sliderRow(
                "Display Ceiling",
                value: displayCeilingBinding,
                range: 0.5...1,
                step: 0.01,
                valueText: "\((settings.displayCeiling * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            sliderRow(
                "Hot Response",
                value: hotResponseBinding,
                range: 0.5...3,
                step: 0.05,
                valueText: "\(settings.hotResponse.formatted(.number.precision(.fractionLength(2))))x"
            )
            sliderRow(
                "Hot Threshold",
                value: hotThresholdBinding,
                range: 0.35...0.98,
                step: 0.01,
                valueText: "\((settings.hotThreshold * 100).formatted(.number.precision(.fractionLength(0))))%"
            )
            sliderRow(
                "Hot Fill Strength",
                value: hotFillStrengthBinding,
                range: 0...1,
                step: 0.01,
                valueText: settings.hotFillStrength.formatted(.number.precision(.fractionLength(2)))
            )
            sliderRow(
                "Palette Drive",
                value: vuPaletteDriveBinding,
                range: 0.5...4,
                step: 0.05,
                valueText: "\(settings.vuPaletteDrive.formatted(.number.precision(.fractionLength(2))))x"
            )
        }
    }

    private var surfaceBloomSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow(
                "Ring / Front Density",
                value: ringFrontDensityBinding,
                range: 0.1...12,
                step: 0.1,
                valueText: settings.ringFrontDensity.formatted(.number.precision(.fractionLength(1)))
            )
            sliderRow(
                "Band Softness",
                value: bandSoftnessBinding,
                range: 0.1...3,
                step: 0.05,
                valueText: settings.bandSoftness.formatted(.number.precision(.fractionLength(2)))
            )
            stepperRow("Tile Detail", value: tileDetailBinding, range: 4...32, valueText: "\(settings.tileDetail)")
            sliderRow(
                "Idle Tint",
                value: idleTintBinding,
                range: 0...1,
                step: 0.01,
                valueText: settings.idleTint.formatted(.number.precision(.fractionLength(2)))
            )
            sliderRow(
                "Checker / Tile Contrast",
                value: checkerContrastBinding,
                range: 0...0.4,
                step: 0.01,
                valueText: settings.checkerContrast.formatted(.number.precision(.fractionLength(2)))
            )
            sliderRow(
                "Memory",
                value: memoryCarryoverBinding,
                range: 0...1,
                step: 0.01,
                valueText: settings.memoryCarryover.formatted(.number.precision(.fractionLength(2)))
            )
            sliderRow(
                "Band Velocity",
                value: checkerBandVelocityBinding,
                range: 0...4,
                step: 0.01,
                valueText: settings.checkerBandVelocity.formatted(.number.precision(.fractionLength(2)))
            )
            sliderRow(
                "Band Width",
                value: checkerBandWidthBinding,
                range: 0.22...0.96,
                step: 0.01,
                valueText: settings.checkerBandWidth.formatted(.number.precision(.fractionLength(2)))
            )

            HStack(spacing: 12) {
                Text("Bloom Range")
                Slider(value: bloomMinBinding, in: 0...Double(settings.bloomMax), step: 0.01)
                Slider(value: bloomMaxBinding, in: Double(settings.bloomMin)...1, step: 0.01)
                Text("\(settings.bloomMin.formatted(.number.precision(.fractionLength(2)))) / \(settings.bloomMax.formatted(.number.precision(.fractionLength(2))))")
                    .monospacedDigit()
                    .frame(width: 84, alignment: .trailing)
            }

            sliderRow(
                "Bloom Edge",
                value: bloomEdgeBinding,
                range: 0.001...1,
                step: 0.001,
                valueText: settings.bloomEdge.formatted(.number.precision(.fractionLength(3)))
            )
            sliderRow(
                "Response Curve",
                value: responseCurveBinding,
                range: 0.2...4,
                step: 0.01,
                valueText: settings.responseCurve.formatted(.number.precision(.fractionLength(2)))
            )
            sliderRow(
                "Peak Hold",
                value: peakHoldSecondsBinding,
                range: 0...3,
                step: 0.01,
                valueText: "\(settings.peakHoldSeconds.formatted(.number.precision(.fractionLength(2))))s"
            )
            sliderRow(
                "Release",
                value: releaseMemoryBinding,
                range: 0...1,
                step: 0.01,
                valueText: settings.releaseMemory.formatted(.number.precision(.fractionLength(2)))
            )
            sliderRow(
                "Hot Fill",
                value: hotFillBinding,
                range: 0...1,
                step: 0.01,
                valueText: settings.hotFill.formatted(.number.precision(.fractionLength(2)))
            )
            stepperRow("Face Pixels", value: facePixelsBinding, range: 4...64, valueText: "\(settings.facePixels)")
            Toggle("Show Diagnostics", isOn: showsDiagnosticsBinding)
        }
    }

    private var objectOverlaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Object Shape", selection: objectShapeBinding) {
                ForEach(ObjectVisualShape.allCases, id: \.self) { shape in
                    Text(shape.displayName).tag(shape)
                }
            }
            .pickerStyle(.menu)

            Picker("Object Palette", selection: objectPaletteBinding) {
                ForEach(ObjectVisualPalette.allCases, id: \.self) { palette in
                    Text(palette.displayName).tag(palette)
                }
            }
            .pickerStyle(.menu)

            sliderRow("Core Size", value: objectCoreSizeBinding, range: 0.01...0.24, step: 0.005, valueText: formatScalar(objectSettings.coreSize))
            sliderRow("Width Scale", value: objectWidthScaleBinding, range: 0...5, step: 0.05, valueText: objectSettings.widthScale.formatted(.number.precision(.fractionLength(2))))
            sliderRow("Smoothing", value: objectSmoothingBinding, range: 0...1, step: 0.01, valueText: "\(objectSettings.smoothingHalfLifeSeconds.formatted(.number.precision(.fractionLength(2))))s")
            sliderRow("Visual Lookbehind", value: objectLookbehindBinding, range: 0...120, step: 1, valueText: "\(objectSettings.visualLookbehindMilliseconds.formatted(.number.precision(.fractionLength(0)))) ms")
            sliderRow("Snap Threshold", value: objectSnapThresholdBinding, range: 0...Double(Float.pi), step: 0.01, valueText: objectSettings.snapThresholdRadians.formatted(.number.precision(.fractionLength(2))))
            sliderRow("Glow", value: objectGlowBinding, range: 0...2, step: 0.01, valueText: objectSettings.glowIntensity.formatted(.number.precision(.fractionLength(2))))
            sliderRow("Clip Flash", value: objectClipFlashBinding, range: 0...2, step: 0.01, valueText: objectSettings.clipFlashIntensity.formatted(.number.precision(.fractionLength(2))))
        }
    }

    private var trailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Trails", isOn: objectTrailsEnabledBinding)
            sliderRow("Trail Length", value: objectTrailLengthBinding, range: 0...10, step: 0.1, valueText: "\(objectSettings.trailLengthSeconds.formatted(.number.precision(.fractionLength(1))))s")
            sliderRow("Trail Decay", value: objectTrailDecayBinding, range: 0...1, step: 0.01, valueText: objectSettings.trailDecay.formatted(.number.precision(.fractionLength(2))))
            stepperRow("Max Trail Points", value: objectMaxTrailPointsBinding, range: 0...ObjectVisualSettings.maxTrailPointsLimit, valueText: "\(objectSettings.maxTrailPointsPerObject)")
            Toggle("Glow Trails", isOn: objectGlowTrailsEnabledBinding)
            sliderRow("Glow Trail Intensity", value: objectGlowTrailIntensityBinding, range: 0...2, step: 0.01, valueText: objectSettings.glowTrailIntensity.formatted(.number.precision(.fractionLength(2))))
            sliderRow("Glow Trail Width", value: objectGlowTrailWidthBinding, range: 0...0.5, step: 0.005, valueText: objectSettings.glowTrailWidth.formatted(.number.precision(.fractionLength(3))))
            sliderRow("Glow Trail Decay", value: objectGlowTrailDecayBinding, range: 0...1, step: 0.01, valueText: objectSettings.glowTrailDecay.formatted(.number.precision(.fractionLength(2))))
        }
    }

    private var boundsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            valueRow("X Bounds", "\(formatBound(objectSettings.bounds.minimum))...\(formatBound(objectSettings.bounds.maximum))")
            valueRow("Y Bounds", "\(formatBound(objectSettings.bounds.minimum))...\(formatBound(objectSettings.bounds.maximum))")
            valueRow("Z Bounds", "\(formatBound(objectSettings.bounds.minimum))...\(formatBound(objectSettings.bounds.maximum))")
            Toggle("Show Bounds", isOn: objectShowsBoundsBinding)
            Toggle("Clip Diagnostics", isOn: objectShowsClipDiagnosticsBinding)
            valueRow("Clipped Active Objects", "\(clippedActiveObjectCount)")
        }
    }

    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Active Motion FPS", selection: activeViewportFPSBinding) {
                Text("30 FPS").tag(30)
                Text("60 FPS").tag(60)
            }
            .pickerStyle(.segmented)

            stepperRow("Meter-only FPS", value: meterOnlyFPSBinding, range: 1...30, valueText: "\(performanceSettings.meterOnlyViewportFramesPerSecond)")
            stepperRow("Inspector FPS", value: inspectorFPSBinding, range: 1...30, valueText: "\(performanceSettings.inspectorRefreshFramesPerSecond)")
            Toggle("Draw on Demand", isOn: drawsOnDemandBinding)
            stepperRow("Face Pixels Cost", value: facePixelsBinding, range: 4...64, valueText: "\(settings.facePixels)")
            stepperRow("Trail Point Cap", value: objectMaxTrailPointsBinding, range: 0...ObjectVisualSettings.maxTrailPointsLimit, valueText: "\(objectSettings.maxTrailPointsPerObject)")
            valueRow("Max Active Objects", "\(OrbitalViewObjectFrameSet.maxObjectCount)")
            valueRow("Active Objects Now", "\(objectFrames?.activeObjects.count ?? 0)")
            valueRow("Draw Mode", performanceSettings.drawsOnDemand ? "on demand" : "continuous")
        }
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Preset Name", text: $presetName)

            HStack(spacing: 8) {
                Button("Save as Default") {
                    performPresetAction("Saved default") {
                        _ = try presetController.saveAsDefault(settings: settings)
                    }
                }
                .disabled(visualPresetStore == nil)

                Button("Save Preset") {
                    performPresetAction("Saved preset") {
                        _ = try presetController.savePreset(displayName: presetName, settings: settings)
                    }
                }
                .disabled(visualPresetStore == nil)

                Button("Load Preset") {
                    performPresetAction("Loaded preset") {
                        if let preset = try presetController.loadPreset() {
                            settings = preset.settings
                            presetName = preset.displayName
                        }
                    }
                }
                .disabled(visualPresetStore == nil)

                Button("Reset to Saved Default") {
                    performPresetAction("Reset to saved default") {
                        if let preset = try presetController.resetToSavedDefault() {
                            settings = preset.settings
                            presetName = preset.displayName
                        }
                    }
                }
                .disabled(visualPresetStore == nil)

                Button("Reset to Factory") {
                    performPresetAction("Reset to factory") {
                        settings = try presetController.resetToFactory()
                        presetName = OrbitalViewVisualPreset.defaultMusic.displayName
                    }
                }
            }

            if let presetStatus {
                Text(presetStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var diagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(cubeDiagnosticLines, id: \.self) { line in
                Text(line)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            ForEach(objectDiagnosticLines, id: \.self) { line in
                Text(line)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            ForEach(OrbitalViewInputDiagnosticsSummary.lines(for: inputDiagnostics), id: \.self) { line in
                Text(line)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(inputDiagnostics.hasIssues ? .primary : .secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var cubeDiagnosticLines: [String] {
        var lines = [
            meters == nil ? "Speaker data source: no meter frame" : "Speaker data source: host meter frame",
            objectFrames == nil ? "Object source: no object frame" : "Object source: object frame",
            objectMeters == nil ? "Object meter source: none" : "Object meter source: object meter frame"
        ]

        guard
            case .speaker(let speakerID)? = selection?.id,
            let speaker = scene.speakers.first(where: { $0.id == speakerID })
        else {
            lines.append("Selected speaker/channel: none")
            return lines
        }

        lines.append("Selected speaker/channel: \(speaker.label) / \(speaker.channel)")
        guard let level = meters?.levelsByChannel[speaker.channel] else {
            lines.append("Raw RMS: no level")
            return lines
        }

        let scalars = SpeakerCubeVUScalars(rawRms: level.rms, settings: settings)
        lines.append("Raw RMS: \(formatScalar(scalars.rawRms))")
        lines.append("Calibrated RMS: \(formatScalar(scalars.calibratedRms))")
        lines.append("Display VU scalar: \(formatScalar(scalars.displayVuScalar))")
        lines.append("Hot scalar: \(formatScalar(scalars.hotScalar))")
        return lines
    }

    private var objectDiagnosticLines: [String] {
        let activeObjects = objectFrames?.activeObjects.count ?? 0
        let activeCap = objectFrames?.maxActiveObjects ?? OrbitalViewObjectFrameSet.maxObjectCount
        let trailCap = objectFrames.map { min($0.maxTrailPointsPerObject, objectSettings.maxTrailPointsPerObject) } ?? objectSettings.maxTrailPointsPerObject
        let activeTrailSamples = objectFrames?.activeObjects.reduce(0) { total, object in
            total + min(object.trail.count, trailCap)
        } ?? 0
        return [
            "Active objects: \(activeObjects) / \(activeCap)",
            "Object meter levels: \(objectMeters?.levelsByObjectID.count ?? 0)",
            "Trail samples capped: \(activeTrailSamples)",
            "Render bounds: \(formatBound(objectSettings.bounds.minimum))...\(formatBound(objectSettings.bounds.maximum))"
        ]
    }

    private var clippedActiveObjectCount: Int {
        objectFrames?.activeObjects.filter { !isInsideBounds($0.pose) }.count ?? 0
    }

    private func isInsideBounds(_ direction: UnitSphereDirection) -> Bool {
        let minValue = Double(objectSettings.bounds.minimum)
        let maxValue = Double(objectSettings.bounds.maximum)
        return (minValue...maxValue).contains(direction.x)
            && (minValue...maxValue).contains(direction.y)
            && (minValue...maxValue).contains(direction.z)
    }

    private func formatScalar(_ value: Float) -> String {
        value.formatted(.number.precision(.fractionLength(3)))
    }

    private func formatBound(_ value: Float) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }

    private func valueRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
            Spacer(minLength: 8)
            Text(value)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .font(.caption)
    }

    private func sliderRow(
        _ label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        valueText: String
    ) -> some View {
        HStack(spacing: 12) {
            Text(label)
            Slider(value: value, in: range, step: step)
            Text(valueText)
                .monospacedDigit()
                .frame(width: 64, alignment: .trailing)
        }
    }

    private func stepperRow(
        _ label: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        valueText: String
    ) -> some View {
        HStack(spacing: 12) {
            Text(label)
            Spacer(minLength: 8)
            Stepper(value: value, in: range) {
                Text(valueText)
                    .monospacedDigit()
                    .frame(width: 44, alignment: .trailing)
            }
        }
    }

    private var presetController: OrbitalViewVisualPresetController {
        OrbitalViewVisualPresetController(store: visualPresetStore)
    }

    private func performPresetAction(_ successMessage: String, action: () throws -> Void) {
        do {
            try action()
            presetStatus = successMessage
        } catch {
            presetStatus = "Preset error: \(error)"
        }
    }

    private var visualGainBinding: Binding<Double> {
        Binding(
            get: { Double(settings.visualGainDB) },
            set: { updateSettings(visualGainDB: Float($0)) }
        )
    }

    private var inputCalibrationBinding: Binding<Double> {
        Binding(
            get: { Double(settings.inputCalibration) },
            set: { updateSettings(inputCalibration: Float($0)) }
        )
    }

    private var levelCompressionBinding: Binding<Double> {
        Binding(
            get: { Double(settings.levelCompression) },
            set: { updateSettings(levelCompression: Float($0)) }
        )
    }

    private var displayCeilingBinding: Binding<Double> {
        Binding(
            get: { Double(settings.displayCeiling) },
            set: { updateSettings(displayCeiling: Float($0)) }
        )
    }

    private var hotResponseBinding: Binding<Double> {
        Binding(
            get: { Double(settings.hotResponse) },
            set: { updateSettings(hotResponse: Float($0)) }
        )
    }

    private var hotThresholdBinding: Binding<Double> {
        Binding(
            get: { Double(settings.hotThreshold) },
            set: { updateSettings(hotThreshold: Float($0)) }
        )
    }

    private var hotFillStrengthBinding: Binding<Double> {
        Binding(
            get: { Double(settings.hotFillStrength) },
            set: { updateSettings(hotFillStrength: Float($0)) }
        )
    }

    private var vuPaletteDriveBinding: Binding<Double> {
        Binding(
            get: { Double(settings.vuPaletteDrive) },
            set: { updateSettings(vuPaletteDrive: Float($0)) }
        )
    }

    private var styleBinding: Binding<SpeakerMeterVisualStyle> {
        Binding(
            get: { settings.style },
            set: { updateSettings(style: $0) }
        )
    }

    private var colorSchemeBinding: Binding<SpeakerMeterColorScheme> {
        Binding(
            get: { settings.colorScheme },
            set: { updateSettings(colorScheme: $0) }
        )
    }

    private var speakerZScaleBinding: Binding<Double> {
        Binding(
            get: { Double(settings.speakerZScale) },
            set: { updateSettings(speakerZScale: Float($0)) }
        )
    }

    private var ringFrontDensityBinding: Binding<Double> {
        Binding(
            get: { Double(settings.ringFrontDensity) },
            set: { updateSettings(ringFrontDensity: Float($0)) }
        )
    }

    private var bandSoftnessBinding: Binding<Double> {
        Binding(
            get: { Double(settings.bandSoftness) },
            set: { updateSettings(bandSoftness: Float($0)) }
        )
    }

    private var tileDetailBinding: Binding<Int> {
        Binding(
            get: { settings.tileDetail },
            set: { updateSettings(tileDetail: $0) }
        )
    }

    private var idleTintBinding: Binding<Double> {
        Binding(
            get: { Double(settings.idleTint) },
            set: { updateSettings(idleTint: Float($0)) }
        )
    }

    private var checkerContrastBinding: Binding<Double> {
        Binding(
            get: { Double(settings.checkerContrast) },
            set: { updateSettings(checkerContrast: Float($0)) }
        )
    }

    private var memoryCarryoverBinding: Binding<Double> {
        Binding(
            get: { Double(settings.memoryCarryover) },
            set: { updateSettings(memoryCarryover: Float($0)) }
        )
    }

    private var checkerBandVelocityBinding: Binding<Double> {
        Binding(
            get: { Double(settings.checkerBandVelocity) },
            set: { updateSettings(checkerBandVelocity: Float($0)) }
        )
    }

    private var checkerBandWidthBinding: Binding<Double> {
        Binding(
            get: { Double(settings.checkerBandWidth) },
            set: { updateSettings(checkerBandWidth: Float($0)) }
        )
    }

    private var bloomMinBinding: Binding<Double> {
        Binding(
            get: { Double(settings.bloomMin) },
            set: { updateSettings(bloomMin: Float($0)) }
        )
    }

    private var bloomMaxBinding: Binding<Double> {
        Binding(
            get: { Double(settings.bloomMax) },
            set: { updateSettings(bloomMax: Float($0)) }
        )
    }

    private var bloomEdgeBinding: Binding<Double> {
        Binding(
            get: { Double(settings.bloomEdge) },
            set: { updateSettings(bloomEdge: Float($0)) }
        )
    }

    private var responseCurveBinding: Binding<Double> {
        Binding(
            get: { Double(settings.responseCurve) },
            set: { updateSettings(responseCurve: Float($0)) }
        )
    }

    private var peakHoldSecondsBinding: Binding<Double> {
        Binding(
            get: { Double(settings.peakHoldSeconds) },
            set: { updateSettings(peakHoldSeconds: Float($0)) }
        )
    }

    private var releaseMemoryBinding: Binding<Double> {
        Binding(
            get: { Double(settings.releaseMemory) },
            set: { updateSettings(releaseMemory: Float($0)) }
        )
    }

    private var hotFillBinding: Binding<Double> {
        Binding(
            get: { Double(settings.hotFill) },
            set: { updateSettings(hotFill: Float($0)) }
        )
    }

    private var facePixelsBinding: Binding<Int> {
        Binding(
            get: { settings.facePixels },
            set: { updateSettings(facePixels: $0) }
        )
    }

    private var showsDiagnosticsBinding: Binding<Bool> {
        Binding(
            get: { settings.showsDiagnostics },
            set: { updateSettings(showsDiagnostics: $0) }
        )
    }

    private var objectShapeBinding: Binding<ObjectVisualShape> {
        Binding(
            get: { objectSettings.shape },
            set: { updateObjectSettings(shape: $0) }
        )
    }

    private var objectPaletteBinding: Binding<ObjectVisualPalette> {
        Binding(
            get: { objectSettings.palette },
            set: { updateObjectSettings(palette: $0) }
        )
    }

    private var objectCoreSizeBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.coreSize) },
            set: { updateObjectSettings(coreSize: Float($0)) }
        )
    }

    private var objectWidthScaleBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.widthScale) },
            set: { updateObjectSettings(widthScale: Float($0)) }
        )
    }

    private var objectSmoothingBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.smoothingHalfLifeSeconds) },
            set: { updateObjectSettings(smoothingHalfLifeSeconds: Float($0)) }
        )
    }

    private var objectLookbehindBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.visualLookbehindMilliseconds) },
            set: { updateObjectSettings(visualLookbehindMilliseconds: Float($0)) }
        )
    }

    private var objectSnapThresholdBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.snapThresholdRadians) },
            set: { updateObjectSettings(snapThresholdRadians: Float($0)) }
        )
    }

    private var objectGlowBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.glowIntensity) },
            set: { updateObjectSettings(glowIntensity: Float($0)) }
        )
    }

    private var objectClipFlashBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.clipFlashIntensity) },
            set: { updateObjectSettings(clipFlashIntensity: Float($0)) }
        )
    }

    private var objectTrailsEnabledBinding: Binding<Bool> {
        Binding(
            get: { objectSettings.trailsEnabled },
            set: { updateObjectSettings(trailsEnabled: $0) }
        )
    }

    private var objectTrailLengthBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.trailLengthSeconds) },
            set: { updateObjectSettings(trailLengthSeconds: Float($0)) }
        )
    }

    private var objectTrailDecayBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.trailDecay) },
            set: { updateObjectSettings(trailDecay: Float($0)) }
        )
    }

    private var objectMaxTrailPointsBinding: Binding<Int> {
        Binding(
            get: { objectSettings.maxTrailPointsPerObject },
            set: { updateObjectSettings(maxTrailPointsPerObject: $0) }
        )
    }

    private var objectGlowTrailsEnabledBinding: Binding<Bool> {
        Binding(
            get: { objectSettings.glowTrailsEnabled },
            set: { updateObjectSettings(glowTrailsEnabled: $0) }
        )
    }

    private var objectGlowTrailIntensityBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.glowTrailIntensity) },
            set: { updateObjectSettings(glowTrailIntensity: Float($0)) }
        )
    }

    private var objectGlowTrailWidthBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.glowTrailWidth) },
            set: { updateObjectSettings(glowTrailWidth: Float($0)) }
        )
    }

    private var objectGlowTrailDecayBinding: Binding<Double> {
        Binding(
            get: { Double(objectSettings.glowTrailDecay) },
            set: { updateObjectSettings(glowTrailDecay: Float($0)) }
        )
    }

    private var objectShowsBoundsBinding: Binding<Bool> {
        Binding(
            get: { objectSettings.showsBounds },
            set: { updateObjectSettings(showsBounds: $0) }
        )
    }

    private var objectShowsClipDiagnosticsBinding: Binding<Bool> {
        Binding(
            get: { objectSettings.showsClipDiagnostics },
            set: { updateObjectSettings(showsClipDiagnostics: $0) }
        )
    }

    private var activeViewportFPSBinding: Binding<Int> {
        Binding(
            get: { performanceSettings.activeViewportFramesPerSecond },
            set: { updatePerformanceSettings(activeViewportFramesPerSecond: $0) }
        )
    }

    private var meterOnlyFPSBinding: Binding<Int> {
        Binding(
            get: { performanceSettings.meterOnlyViewportFramesPerSecond },
            set: { updatePerformanceSettings(meterOnlyViewportFramesPerSecond: $0) }
        )
    }

    private var inspectorFPSBinding: Binding<Int> {
        Binding(
            get: { performanceSettings.inspectorRefreshFramesPerSecond },
            set: { updatePerformanceSettings(inspectorRefreshFramesPerSecond: $0) }
        )
    }

    private var drawsOnDemandBinding: Binding<Bool> {
        Binding(
            get: { performanceSettings.drawsOnDemand },
            set: { updatePerformanceSettings(drawsOnDemand: $0) }
        )
    }

    private var gainText: String {
        let prefix = settings.visualGainDB > 0 ? "+" : ""
        return "\(prefix)\(settings.visualGainDB.formatted(.number.precision(.fractionLength(0...1)))) dB"
    }

    private func updateSettings(
        visualGainDB: Float? = nil,
        style: SpeakerMeterVisualStyle? = nil,
        colorScheme: SpeakerMeterColorScheme? = nil,
        ringFrontDensity: Float? = nil,
        bandSoftness: Float? = nil,
        tileDetail: Int? = nil,
        inputCalibration: Float? = nil,
        levelCompression: Float? = nil,
        displayCeiling: Float? = nil,
        hotResponse: Float? = nil,
        hotThreshold: Float? = nil,
        hotFillStrength: Float? = nil,
        vuPaletteDrive: Float? = nil,
        idleTint: Float? = nil,
        checkerContrast: Float? = nil,
        memoryCarryover: Float? = nil,
        checkerBandVelocity: Float? = nil,
        checkerBandWidth: Float? = nil,
        speakerZScale: Float? = nil,
        bloomMin: Float? = nil,
        bloomMax: Float? = nil,
        bloomEdge: Float? = nil,
        responseCurve: Float? = nil,
        peakHoldSeconds: Float? = nil,
        releaseMemory: Float? = nil,
        hotFill: Float? = nil,
        facePixels: Int? = nil,
        showsDiagnostics: Bool? = nil
    ) {
        if let next = try? SpeakerMeterVisualSettings(
            visualGainDB: visualGainDB ?? settings.visualGainDB,
            style: style ?? settings.style,
            colorScheme: colorScheme ?? settings.colorScheme,
            ringFrontDensity: ringFrontDensity ?? settings.ringFrontDensity,
            bandSoftness: bandSoftness ?? settings.bandSoftness,
            tileDetail: tileDetail ?? settings.tileDetail,
            inputCalibration: inputCalibration ?? settings.inputCalibration,
            levelCompression: levelCompression ?? settings.levelCompression,
            displayCeiling: displayCeiling ?? settings.displayCeiling,
            hotResponse: hotResponse ?? settings.hotResponse,
            hotThreshold: hotThreshold ?? settings.hotThreshold,
            hotFillStrength: hotFillStrength ?? settings.hotFillStrength,
            vuPaletteDrive: vuPaletteDrive ?? settings.vuPaletteDrive,
            idleTint: idleTint ?? settings.idleTint,
            checkerContrast: checkerContrast ?? settings.checkerContrast,
            memoryCarryover: memoryCarryover ?? settings.memoryCarryover,
            checkerBandVelocity: checkerBandVelocity ?? settings.checkerBandVelocity,
            checkerBandWidth: checkerBandWidth ?? settings.checkerBandWidth,
            speakerZScale: speakerZScale ?? settings.speakerZScale,
            bloomMin: bloomMin ?? settings.bloomMin,
            bloomMax: bloomMax ?? settings.bloomMax,
            bloomEdge: bloomEdge ?? settings.bloomEdge,
            responseCurve: responseCurve ?? settings.responseCurve,
            peakHoldSeconds: peakHoldSeconds ?? settings.peakHoldSeconds,
            releaseMemory: releaseMemory ?? settings.releaseMemory,
            hotFill: hotFill ?? settings.hotFill,
            facePixels: facePixels ?? settings.facePixels,
            showsDiagnostics: showsDiagnostics ?? settings.showsDiagnostics
        ) {
            settings = next
        }
    }

    private func updateObjectSettings(
        shape: ObjectVisualShape? = nil,
        palette: ObjectVisualPalette? = nil,
        coreSize: Float? = nil,
        widthScale: Float? = nil,
        smoothingHalfLifeSeconds: Float? = nil,
        visualLookbehindMilliseconds: Float? = nil,
        snapThresholdRadians: Float? = nil,
        glowIntensity: Float? = nil,
        clipFlashIntensity: Float? = nil,
        trailsEnabled: Bool? = nil,
        trailLengthSeconds: Float? = nil,
        trailDecay: Float? = nil,
        maxTrailPointsPerObject: Int? = nil,
        glowTrailsEnabled: Bool? = nil,
        glowTrailIntensity: Float? = nil,
        glowTrailWidth: Float? = nil,
        glowTrailDecay: Float? = nil,
        showsBounds: Bool? = nil,
        showsClipDiagnostics: Bool? = nil
    ) {
        if let next = try? ObjectVisualSettings(
            shape: shape ?? objectSettings.shape,
            palette: palette ?? objectSettings.palette,
            coreSize: coreSize ?? objectSettings.coreSize,
            widthScale: widthScale ?? objectSettings.widthScale,
            smoothingHalfLifeSeconds: smoothingHalfLifeSeconds ?? objectSettings.smoothingHalfLifeSeconds,
            visualLookbehindMilliseconds: visualLookbehindMilliseconds ?? objectSettings.visualLookbehindMilliseconds,
            snapThresholdRadians: snapThresholdRadians ?? objectSettings.snapThresholdRadians,
            glowIntensity: glowIntensity ?? objectSettings.glowIntensity,
            clipFlashIntensity: clipFlashIntensity ?? objectSettings.clipFlashIntensity,
            trailsEnabled: trailsEnabled ?? objectSettings.trailsEnabled,
            trailLengthSeconds: trailLengthSeconds ?? objectSettings.trailLengthSeconds,
            trailDecay: trailDecay ?? objectSettings.trailDecay,
            maxTrailPointsPerObject: maxTrailPointsPerObject ?? objectSettings.maxTrailPointsPerObject,
            glowTrailsEnabled: glowTrailsEnabled ?? objectSettings.glowTrailsEnabled,
            glowTrailIntensity: glowTrailIntensity ?? objectSettings.glowTrailIntensity,
            glowTrailWidth: glowTrailWidth ?? objectSettings.glowTrailWidth,
            glowTrailDecay: glowTrailDecay ?? objectSettings.glowTrailDecay,
            bounds: objectSettings.bounds,
            showsBounds: showsBounds ?? objectSettings.showsBounds,
            showsClipDiagnostics: showsClipDiagnostics ?? objectSettings.showsClipDiagnostics
        ) {
            objectSettings = next
        }
    }

    private func updatePerformanceSettings(
        activeViewportFramesPerSecond: Int? = nil,
        meterOnlyViewportFramesPerSecond: Int? = nil,
        inspectorRefreshFramesPerSecond: Int? = nil,
        drawsOnDemand: Bool? = nil
    ) {
        if let next = try? OrbitalViewPerformanceSettings(
            activeViewportFramesPerSecond: activeViewportFramesPerSecond ?? performanceSettings.activeViewportFramesPerSecond,
            meterOnlyViewportFramesPerSecond: meterOnlyViewportFramesPerSecond ?? performanceSettings.meterOnlyViewportFramesPerSecond,
            inspectorRefreshFramesPerSecond: inspectorRefreshFramesPerSecond ?? performanceSettings.inspectorRefreshFramesPerSecond,
            drawsOnDemand: drawsOnDemand ?? performanceSettings.drawsOnDemand
        ) {
            performanceSettings = next
        }
    }
}

struct OrbitalViewVisualPresetController {
    let store: (any OrbitalViewVisualPresetStore)?

    func saveAsDefault(settings: SpeakerMeterVisualSettings) throws -> OrbitalViewVisualPreset? {
        guard let store else {
            return nil
        }
        let preset = try OrbitalViewVisualPreset(
            id: OrbitalViewVisualPreset.defaultMusic.id,
            displayName: OrbitalViewVisualPreset.defaultMusic.displayName,
            settings: settings
        )
        try store.saveVisualPreset(preset)
        return preset
    }

    func savePreset(displayName: String, settings: SpeakerMeterVisualSettings) throws -> OrbitalViewVisualPreset? {
        guard let store else {
            return nil
        }
        let preset = try OrbitalViewVisualPreset(
            id: presetID(from: displayName),
            displayName: displayName,
            settings: settings
        )
        try store.saveVisualPreset(preset)
        return preset
    }

    func loadPreset() throws -> OrbitalViewVisualPreset? {
        try store?.loadVisualPreset()
    }

    func resetToSavedDefault() throws -> OrbitalViewVisualPreset? {
        try store?.loadVisualPreset()
    }

    func resetToFactory() throws -> SpeakerMeterVisualSettings {
        try store?.resetVisualPreset()
        return OrbitalViewVisualPreset.defaultMusic.settings
    }

    private func presetID(from displayName: String) -> String {
        let normalized = displayName
            .lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .joined(separator: "-")
        return normalized.isEmpty ? "custom-vu-preset" : normalized
    }
}

struct OrbitalViewInputDiagnosticsSummary {
    static func lines(for diagnostics: OrbitalViewInputDiagnostics) -> [String] {
        guard diagnostics.hasIssues else {
            return ["No channel diagnostics."]
        }

        var lines: [String] = []
        if !diagnostics.missingChannels.isEmpty {
            lines.append("Missing channels: \(channelList(diagnostics.missingChannels))")
        }
        if !diagnostics.extraChannels.isEmpty {
            lines.append("Extra channels: \(channelList(diagnostics.extraChannels))")
        }
        if !diagnostics.invalidChannels.isEmpty {
            lines.append("Invalid channels: \(channelList(diagnostics.invalidChannels))")
        }
        if !diagnostics.duplicateChannels.isEmpty {
            lines.append("Duplicate channels: \(channelList(diagnostics.duplicateChannels))")
        }
        if !diagnostics.replacedValues.isEmpty {
            lines.append("Sanitized values: \(diagnostics.replacedValues.count) replaced")
        }
        if !diagnostics.clampedValues.isEmpty {
            lines.append("Sanitized values: \(diagnostics.clampedValues.count) clamped")
        }
        if diagnostics.timestampReplaced {
            lines.append("Timestamp fallback used.")
        }
        return lines
    }

    private static func channelList(_ channels: [Int]) -> String {
        channels.map(String.init).joined(separator: ", ")
    }
}
