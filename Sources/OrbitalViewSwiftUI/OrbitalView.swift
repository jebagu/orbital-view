import OrbitalViewCore
import SwiftUI

public struct OrbitalView: View {
    public let scene: OrbitalViewSceneSpec
    public let meters: SpeakerMeterFrame?

    let showsMeterSettingsTray: Bool

    @Binding private var camera: OrbitalViewCameraState
    @Binding private var selection: OrbitalViewSelection?
    @Binding private var meterVisualSettings: SpeakerMeterVisualSettings
    @State private var meterSettingsTrayExpanded = false

    private let onEvents: ([OrbitalViewEvent]) -> Void

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?> = .constant(nil),
        onEvents: @escaping ([OrbitalViewEvent]) -> Void = { _ in }
    ) {
        self.scene = scene
        self.meters = meters
        self.showsMeterSettingsTray = false
        self._camera = camera
        self._selection = selection
        self._meterVisualSettings = .constant(.default)
        self.onEvents = onEvents
    }

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        meterVisualSettings: Binding<SpeakerMeterVisualSettings>,
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?> = .constant(nil),
        onEvents: @escaping ([OrbitalViewEvent]) -> Void = { _ in }
    ) {
        self.scene = scene
        self.meters = meters
        self.showsMeterSettingsTray = true
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
                    camera: camera,
                    selection: selection
                ),
                onEvents: onEvents
            )

            if showsMeterSettingsTray {
                OrbitalViewMeterSettingsTray(
                    settings: $meterVisualSettings,
                    isExpanded: $meterSettingsTrayExpanded
                )
            }
        }
    }
}

struct OrbitalViewMeterSettingsTray: View {
    @Binding var settings: SpeakerMeterVisualSettings
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            DisclosureGroup(isExpanded: $isExpanded) {
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

    private var visualGainBinding: Binding<Double> {
        Binding(
            get: { Double(settings.visualGainDB) },
            set: { newValue in
                updateSettings(visualGainDB: Float(newValue))
            }
        )
    }

    private var styleBinding: Binding<SpeakerMeterVisualStyle> {
        Binding(
            get: { settings.style },
            set: { newStyle in
                updateSettings(style: newStyle)
            }
        )
    }

    private var colorSchemeBinding: Binding<SpeakerMeterColorScheme> {
        Binding(
            get: { settings.colorScheme },
            set: { updateSettings(colorScheme: $0) }
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
        checkerBandWidth: Float? = nil
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
            checkerBandWidth: checkerBandWidth ?? settings.checkerBandWidth
        ) {
            settings = next
        }
    }
}
