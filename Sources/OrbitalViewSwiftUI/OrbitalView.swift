import OrbitalViewCore
import SwiftUI

public struct OrbitalView: View {
    public let scene: OrbitalViewSceneSpec
    public let meters: SpeakerMeterFrame?

    let showsControlSurface: Bool
    let showsMeterSettingsTray: Bool

    @Binding private var camera: OrbitalViewCameraState
    @Binding private var selection: OrbitalViewSelection?
    @Binding private var meterVisualSettings: SpeakerMeterVisualSettings
    @Binding private var displaySettings: OrbitalViewDisplaySettings

    @State private var meterSettingsTrayExpanded = false
    @State private var isViewportDragging = false
    @State private var isSpinning = false
    @State private var exportStatus: OrbitalViewExportStatus?
    @State private var lastSpinTimestamp: Date?
    @State private var mountedView: OrbitalViewInteractiveMTKView?
    @State private var clearMessageWorkItem: DispatchWorkItem?

    private let onEvents: ([OrbitalViewEvent]) -> Void
    private let onExportPNG: () -> Void

    private let spinSpeed = 0.95
    private let spinDirection: Double = -1

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        displaySettings: Binding<OrbitalViewDisplaySettings> = .constant(.default),
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?> = .constant(nil),
        onEvents: @escaping ([OrbitalViewEvent]) -> Void = { _ in },
        onExportPNG: @escaping () -> Void = {}
    ) {
        self.scene = scene
        self.meters = meters
        self.showsControlSurface = true
        self.showsMeterSettingsTray = false
        self._camera = camera
        self._selection = selection
        self._meterVisualSettings = .constant(.default)
        self._displaySettings = displaySettings
        self.onEvents = onEvents
        self.onExportPNG = onExportPNG
    }

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        meterVisualSettings: Binding<SpeakerMeterVisualSettings>,
        displaySettings: Binding<OrbitalViewDisplaySettings> = .constant(.default),
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?> = .constant(nil),
        onEvents: @escaping ([OrbitalViewEvent]) -> Void = { _ in },
        onExportPNG: @escaping () -> Void = {}
    ) {
        self.scene = scene
        self.meters = meters
        self.showsControlSurface = true
        self.showsMeterSettingsTray = true
        self._camera = camera
        self._selection = selection
        self._meterVisualSettings = meterVisualSettings
        self._displaySettings = displaySettings
        self.onEvents = onEvents
        self.onExportPNG = onExportPNG
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if showsControlSurface {
                    OrbitalViewControlSurfaceLeft(
                        camera: $camera,
                        displaySettings: $displaySettings,
                        isSpinning: $isSpinning,
                        onPreset: applyPreset,
                        onExportPNG: requestExport,
                        exportStatus: exportStatus
                    )
                    .frame(width: 250)
                    Divider()
                }

                OrbitalViewMetalView(
                    configuration: OrbitalViewRenderConfiguration(
                        scene: scene,
                        meters: meters,
                        meterVisualSettings: meterVisualSettings,
                        displaySettings: displaySettings,
                        camera: camera,
                        selection: selection
                    ),
                    onEvents: onEvents,
                    onUpdateCamera: { next in
                        camera = next
                    },
                    onDragStateChange: { isDragging in
                        isViewportDragging = isDragging
                        if !isDragging {
                            lastSpinTimestamp = nil
                        }
                    },
                    onViewMounted: { mounted in
                        mountedView = mounted
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if showsControlSurface {
                Divider()
                OrbitalViewControlSurfaceRight(
                    displaySettings: $displaySettings
                )
                    .frame(width: 250)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if showsMeterSettingsTray {
                OrbitalViewMeterSettingsTray(
                    settings: $meterVisualSettings,
                    isExpanded: $meterSettingsTrayExpanded
                )
            }
        }
        .onAppear {
            lastSpinTimestamp = nil
        }
        .onDisappear {
            clearStatusWorkItem()
            isSpinning = false
            lastSpinTimestamp = nil
        }
        .onReceive(Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()) { now in
            guard isSpinning, !isViewportDragging else {
                return
            }

            let elapsed = lastSpinTimestamp.flatMap { now.timeIntervalSince($0) } ?? 0
            lastSpinTimestamp = now
            guard elapsed > 0 else { return }
            applySpin(deltaSeconds: elapsed)
        }
    }

    private func applyPreset(_ preset: OrbitalViewMode) {
        guard let next = try? OrbitalViewCameraState.preset(preset, projection: camera.projection, distanceM: camera.orbit.distanceM) else {
            return
        }
        camera = next
        lastSpinTimestamp = nil
    }

    private func applySpin(deltaSeconds: TimeInterval) {
        let deltaYaw = spinDirection * spinSpeed * deltaSeconds
        guard let orbit = try? OrbitalViewOrbit(
            yawRadians: camera.orbit.yawRadians + deltaYaw,
            pitchRadians: camera.orbit.pitchRadians,
            distanceM: camera.orbit.distanceM
        ) else { return }

        guard let next = try? OrbitalViewCameraState(
            mode: camera.mode,
            projection: camera.projection,
            orbit: orbit,
            target: camera.target,
            enforceCenterLock: true
        ) else { return }

        camera = next
    }

    private func requestExport() {
        guard let mountedView else {
            showExportMessage("Export failed: renderer not ready", isError: true)
            onExportPNG()
            return
        }

        guard let png = mountedView.snapshotPNG() else {
            showExportMessage("Export failed", isError: true)
            onExportPNG()
            return
        }

        let target = desktopURL().appendingPathComponent(exportFileName)
        do {
            try png.write(to: target, options: .atomic)
            showExportMessage("Saved to Desktop: \(target.lastPathComponent)")
            onExportPNG()
        } catch {
            showExportMessage("Export failed: \(error.localizedDescription)", isError: true)
            onExportPNG()
        }
    }

    private func desktopURL() -> URL {
        FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser
    }

    private var exportFileName: String {
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: ".", with: "-")
        return "Orbital-View-VU-Kit-\(timestamp).png"
    }

    private func showExportMessage(_ text: String, isError: Bool = false) {
        clearStatusWorkItem()
        exportStatus = OrbitalViewExportStatus(text: text, isError: isError)

        let workItem = DispatchWorkItem {
            exportStatus = nil
        }
        clearMessageWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2, execute: workItem)
    }

    private func clearStatusWorkItem() {
        clearMessageWorkItem?.cancel()
        clearMessageWorkItem = nil
    }
}

public struct OrbitalViewExportStatus: Equatable {
    let text: String
    let isError: Bool
}

public struct OrbitalViewControlSurfaceLeft: View {
    @Binding private var camera: OrbitalViewCameraState
    @Binding private var displaySettings: OrbitalViewDisplaySettings
    @Binding private var isSpinning: Bool

    let onPreset: (OrbitalViewMode) -> Void
    let onExportPNG: () -> Void
    let exportStatus: OrbitalViewExportStatus?

    public init(
        camera: Binding<OrbitalViewCameraState>,
        displaySettings: Binding<OrbitalViewDisplaySettings>,
        isSpinning: Binding<Bool>,
        onPreset: @escaping (OrbitalViewMode) -> Void,
        onExportPNG: @escaping () -> Void,
        exportStatus: OrbitalViewExportStatus?
    ) {
        self._camera = camera
        self._displaySettings = displaySettings
        self._isSpinning = isSpinning
        self.onPreset = onPreset
        self.onExportPNG = onExportPNG
        self.exportStatus = exportStatus
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            controlSection("Viewport") {
                HStack(spacing: 8) {
                    cameraButton("Plan", mode: .plan)
                    cameraButton("Elevation", mode: .frontElevation)
                    cameraButton("Isometric", mode: .isometric)
                }

                controlRow {
                    Toggle("Spin", isOn: $isSpinning)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .frame(width: 60)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                Button("Export PNG") {
                    onExportPNG()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                if let exportStatus {
                    Text(exportStatus.text)
                        .font(.caption)
                        .foregroundStyle(exportStatus.isError ? .red : .green)
                        .lineLimit(2)
                        .padding(.top, 4)
                }
            }

            controlSection("Speaker Shape") {
                Picker("Speaker Shape", selection: speakerShapeBinding) {
                    ForEach(OrbitalViewSpeakerDisplayShape.allCases, id: \.self) { shape in
                        Text(shape.displayName).tag(shape)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxHeight: .infinity)
        .background(Color(NSColor(calibratedWhite: 0.11, alpha: 1)))
    }

    private func controlSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
    }

    private func controlRow<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 8) {
            content()
        }
    }

    private func cameraButton(_ label: String, mode: OrbitalViewMode) -> some View {
        Button(label) {
            onPreset(mode)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .foregroundStyle(camera.mode == mode ? .secondary : .primary)
        .disabled(camera.mode == mode)
    }

    private var speakerShapeBinding: Binding<OrbitalViewSpeakerDisplayShape> {
        Binding(
            get: { displaySettings.speakerShape },
            set: { updateDisplaySettings(speakerShape: $0) }
        )
    }

    private func updateDisplaySettings(
        speakerShape: OrbitalViewSpeakerDisplayShape? = nil
    ) {
        if let next = try? OrbitalViewDisplaySettings(
            speakerShape: speakerShape ?? displaySettings.speakerShape,
            speakerScale: displaySettings.speakerScale,
            fogDensity: displaySettings.fogDensity,
            showsSpeakerNumbers: displaySettings.showsSpeakerNumbers,
            showsHiddenLines: displaySettings.showsHiddenLines
        ) {
            displaySettings = next
        }
    }
}

public struct OrbitalViewControlSurfaceRight: View {
    @Binding private var displaySettings: OrbitalViewDisplaySettings

    public init(
        displaySettings: Binding<OrbitalViewDisplaySettings>
    ) {
        self._displaySettings = displaySettings
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            controlSection("View Detail") {
                sliderRow(
                    "Speaker Size",
                    value: speakerScaleBinding,
                    range: Double(OrbitalViewDisplaySettings.minSpeakerScale)...Double(OrbitalViewDisplaySettings.maxSpeakerScale)
                )

                sliderRow(
                    "Fog Density",
                    value: fogDensityBinding,
                    range: Double(OrbitalViewDisplaySettings.minFogDensity)...Double(OrbitalViewDisplaySettings.maxFogDensity)
                )

                trailingToggleRow("Speaker Numbers", isOn: speakerNumbersBinding)
                trailingToggleRow("Hidden Lines", isOn: hiddenLinesBinding)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxHeight: .infinity)
        .background(Color(NSColor(calibratedWhite: 0.11, alpha: 1)))
    }

    private func controlSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
    }

    private func sliderRow(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Slider(value: value, in: range)
                .tint(.cyan)
        }
    }

    private func trailingToggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    private var speakerScaleBinding: Binding<Double> {
        Binding(
            get: { Double(displaySettings.speakerScale) },
            set: { updateDisplaySettings(speakerScale: Float($0)) }
        )
    }

    private var fogDensityBinding: Binding<Double> {
        Binding(
            get: { Double(displaySettings.fogDensity) },
            set: { updateDisplaySettings(fogDensity: Float($0)) }
        )
    }

    private var speakerNumbersBinding: Binding<Bool> {
        Binding(
            get: { displaySettings.showsSpeakerNumbers },
            set: { updateDisplaySettings(showsSpeakerNumbers: $0) }
        )
    }

    private var hiddenLinesBinding: Binding<Bool> {
        Binding(
            get: { displaySettings.showsHiddenLines },
            set: { updateDisplaySettings(showsHiddenLines: $0) }
        )
    }

    private func updateDisplaySettings(
        speakerScale: Float? = nil,
        fogDensity: Float? = nil,
        showsSpeakerNumbers: Bool? = nil,
        showsHiddenLines: Bool? = nil
    ) {
        if let next = try? OrbitalViewDisplaySettings(
            speakerShape: displaySettings.speakerShape,
            speakerScale: speakerScale ?? displaySettings.speakerScale,
            fogDensity: fogDensity ?? displaySettings.fogDensity,
            showsSpeakerNumbers: showsSpeakerNumbers ?? displaySettings.showsSpeakerNumbers,
            showsHiddenLines: showsHiddenLines ?? displaySettings.showsHiddenLines
        ) {
            displaySettings = next
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
            .background(Color(NSColor(calibratedWhite: 0.11, alpha: 1)))
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
