import OrbitalViewCore
import SwiftUI

public struct OrbitalView: View {
    public let scene: OrbitalViewSceneSpec
    public let meters: SpeakerMeterFrame?
    public let objectFrames: OrbitalViewObjectFrameSet?
    public let objectMeters: ObjectMeterFrame?
    public let objectVisualSettings: ObjectVisualSettings
    public let inputDiagnostics: OrbitalViewInputDiagnostics

    let showsMeterSettingsTray: Bool
    let visualPresetStore: (any OrbitalViewVisualPresetStore)?

    @Binding private var camera: OrbitalViewCameraState
    @Binding private var selection: OrbitalViewSelection?
    @Binding private var meterVisualSettings: SpeakerMeterVisualSettings
    @State private var meterSettingsTrayExpanded = false

    private let onEvents: ([OrbitalViewEvent]) -> Void

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        objectFrames: OrbitalViewObjectFrameSet? = nil,
        objectMeters: ObjectMeterFrame? = nil,
        objectVisualSettings: ObjectVisualSettings = .default,
        inputDiagnostics: OrbitalViewInputDiagnostics = .empty,
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?> = .constant(nil),
        onEvents: @escaping ([OrbitalViewEvent]) -> Void = { _ in }
    ) {
        self.scene = scene
        self.meters = meters
        self.objectFrames = objectFrames
        self.objectMeters = objectMeters
        self.objectVisualSettings = objectVisualSettings
        self.inputDiagnostics = inputDiagnostics
        self.showsMeterSettingsTray = false
        self.visualPresetStore = nil
        self._camera = camera
        self._selection = selection
        self._meterVisualSettings = .constant(.default)
        self.onEvents = onEvents
    }

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        objectFrames: OrbitalViewObjectFrameSet? = nil,
        objectMeters: ObjectMeterFrame? = nil,
        objectVisualSettings: ObjectVisualSettings = .default,
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
        self.objectVisualSettings = objectVisualSettings
        self.inputDiagnostics = inputDiagnostics
        self.showsMeterSettingsTray = showsMeterSettingsTray
        self.visualPresetStore = visualPresetStore
        self._camera = camera
        self._selection = selection
        self._meterVisualSettings = meterVisualSettings
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
                    camera: camera,
                    selection: selection
                ),
                onEvents: onEvents
            )

            if showsMeterSettingsTray {
                OrbitalViewMeterSettingsTray(
                    settings: $meterVisualSettings,
                    isExpanded: $meterSettingsTrayExpanded,
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

    let inputDiagnostics: OrbitalViewInputDiagnostics
    let visualPresetStore: (any OrbitalViewVisualPresetStore)?

    @State private var presetName = "Custom VU Preset"
    @State private var presetStatus: String?

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: 10) {
                    basicSection
                    advancedSection
                    presetSection
                    diagnosticsSection
                }
                .padding(.top, 8)
            } label: {
                Text("VU Settings")
                    .font(.caption.weight(.semibold))
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
        }
    }

    private var basicSection: some View {
        GroupBox("Basic") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Text("Visual Gain")
                    Slider(value: visualGainBinding, in: -24...24, step: 0.5)
                    Text(gainText)
                        .monospacedDigit()
                        .frame(width: 64, alignment: .trailing)
                }

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

                HStack(spacing: 12) {
                    Text("Speaker Height: Cube -> 2 Cubes")
                    Slider(value: speakerZScaleBinding, in: 1...2, step: 0.01)
                    Text(settings.speakerZScale.formatted(.number.precision(.fractionLength(2))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }
            }
            .padding(.top, 2)
        }
    }

    private var advancedSection: some View {
        GroupBox("Advanced") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Text("Ring / Front Density")
                    Slider(value: ringFrontDensityBinding, in: 0.1...12, step: 0.1)
                    Text(settings.ringFrontDensity.formatted(.number.precision(.fractionLength(1))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Band Softness")
                    Slider(value: bandSoftnessBinding, in: 0.1...3, step: 0.05)
                    Text(settings.bandSoftness.formatted(.number.precision(.fractionLength(2))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Tile Detail")
                    Stepper(value: tileDetailBinding, in: 4...32) {
                        Text("\(settings.tileDetail)")
                            .monospacedDigit()
                            .frame(width: 44, alignment: .trailing)
                    }
                }

                HStack(spacing: 12) {
                    Text("Idle Tint")
                    Slider(value: idleTintBinding, in: 0...1, step: 0.01)
                    Text(settings.idleTint.formatted(.number.precision(.fractionLength(2))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Memory")
                    Slider(value: memoryCarryoverBinding, in: 0...1, step: 0.01)
                    Text(settings.memoryCarryover.formatted(.number.precision(.fractionLength(2))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Band Velocity")
                    Slider(value: checkerBandVelocityBinding, in: 0...4, step: 0.01)
                    Text(settings.checkerBandVelocity.formatted(.number.precision(.fractionLength(2))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Band Width")
                    Slider(value: checkerBandWidthBinding, in: 0.22...0.96, step: 0.01)
                    Text(settings.checkerBandWidth.formatted(.number.precision(.fractionLength(2))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Bloom Range")
                    Slider(value: bloomMinBinding, in: 0...Double(settings.bloomMax), step: 0.01)
                    Slider(value: bloomMaxBinding, in: Double(settings.bloomMin)...1, step: 0.01)
                    Text("\(settings.bloomMin.formatted(.number.precision(.fractionLength(2)))) / \(settings.bloomMax.formatted(.number.precision(.fractionLength(2))))")
                        .monospacedDigit()
                        .frame(width: 84, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Bloom Edge")
                    Slider(value: bloomEdgeBinding, in: 0.001...1, step: 0.001)
                    Text(settings.bloomEdge.formatted(.number.precision(.fractionLength(3))))
                        .monospacedDigit()
                        .frame(width: 52, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Response Curve")
                    Slider(value: responseCurveBinding, in: 0.2...4, step: 0.01)
                    Text(settings.responseCurve.formatted(.number.precision(.fractionLength(2))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Peak Hold")
                    Slider(value: peakHoldSecondsBinding, in: 0...3, step: 0.01)
                    Text("\(settings.peakHoldSeconds.formatted(.number.precision(.fractionLength(2))))s")
                        .monospacedDigit()
                        .frame(width: 52, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Release")
                    Slider(value: releaseMemoryBinding, in: 0...1, step: 0.01)
                    Text(settings.releaseMemory.formatted(.number.precision(.fractionLength(2))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Hot Fill")
                    Slider(value: hotFillBinding, in: 0...1, step: 0.01)
                    Text(settings.hotFill.formatted(.number.precision(.fractionLength(2))))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                HStack(spacing: 12) {
                    Text("Face Pixels")
                    Stepper(value: facePixelsBinding, in: 4...64) {
                        Text("\(settings.facePixels)")
                            .monospacedDigit()
                            .frame(width: 44, alignment: .trailing)
                    }
                }

                Toggle("Show Diagnostics", isOn: showsDiagnosticsBinding)
            }
            .padding(.top, 2)
        }
    }

    private var presetSection: some View {
        GroupBox("Presets") {
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
            .padding(.top, 2)
        }
    }

    @ViewBuilder
    private var diagnosticsSection: some View {
        if settings.showsDiagnostics || inputDiagnostics.hasIssues {
            GroupBox("Diagnostics") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(OrbitalViewInputDiagnosticsSummary.lines(for: inputDiagnostics), id: \.self) { line in
                        Text(line)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(inputDiagnostics.hasIssues ? .primary : .secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
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
        idleTint: Float? = nil,
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
            idleTint: idleTint ?? settings.idleTint,
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
