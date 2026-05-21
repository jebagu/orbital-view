import Foundation
#if os(macOS)
import AppKit
import SceneKit
import simd
#endif
import SwiftUI

public struct OrbitalViewportMockup: View {
    public static let sourceMockupPath = "mockups/orbital-view-viewport/index.html"
    public static let desktopSize = CGSize(width: 1512, height: 850)
    public static let nativeDefaultWindowSize = CGSize(width: 1180, height: 760)
    public static let nativeMinimumWindowSize = CGSize(width: 980, height: 680)
    public static let leftRailWidth: CGFloat = 240
    public static let inspectorWidth: CGFloat = 300
    public static let footerHeight: CGFloat = 46
    public static let controlSkinSource = "orbisonic-design-language"
    static let usesRootAnimationTimeline = false
    static let viewportAnimationFramesPerSecond = 30
    static let meterOnlyViewportFramesPerSecond = 10
    static let inspectorRefreshFramesPerSecond = 10
    public static let speakerCount = OrbitalViewportSpeaker.referenceSpeakers.count
    public static let feyGeodesicNodeCount = OrbitalViewportGeodesic.structure.nodes.count
    public static let feyGeodesicEdgeCount = OrbitalViewportGeodesic.structure.edges.count

    @State private var yaw = 0.0
    @State private var pitch = 0.0
    @State private var zoom = 1.0
    @State private var cameraView: OrbitalViewportCameraView = .isometric
    @State private var renderStyle: OrbitalViewportRenderStyle = .purple
    @State private var speakerShape: OrbitalViewportSpeakerShape = .prism
    @State private var speakerSizeSlider = 50.0
    @State private var fogDensitySlider = 50.0
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
    @State private var exportToken = 0
    @State private var magnificationStartZoom: Double?

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
            speakerShape: speakerShape,
            speakerSize: speakerSize,
            fogDensity: fogDensity,
            showSpeakerNumbers: showSpeakerNumbers,
            showHiddenLines: showHiddenLines,
            selectedChannel: selectedChannel,
            spin: spin && !isDragging,
            spinStartYaw: spinStartYaw,
            spinStartTimeMS: spinStartTimeMS
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

            inspector(configuration: renderConfiguration)
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
                inspector(configuration: renderConfiguration)
                    .frame(minHeight: 420)
                footer()
                    .frame(height: Self.footerHeight)
            }
        }
        .background(theme.pageBackground)
    }

    private var controlRail: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    colorSection
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

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Color Scheme")
            controlButtonGroup(
                OrbitalViewportRenderStyle.allCases,
                selection: renderStyle,
                title: \.title
            ) { style in
                renderStyle = style
            }
        }
    }

    private var shapeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Speaker Shape")
            controlButtonGroup(
                OrbitalViewportSpeakerShape.allCases,
                selection: speakerShape,
                title: \.title
            ) { shape in
                speakerShape = shape
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
                .font(.system(size: 12, weight: .semibold))
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

    private func viewport(
        renderConfiguration: OrbitalViewportRenderConfiguration,
        snapshot: OrbitalViewportSnapshot
    ) -> some View {
        OrbitalViewport3DSceneView(
            configuration: renderConfiguration,
            snapshot: snapshot,
            exportToken: exportToken,
            onExportFinished: handleExportResult,
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
                selectedChannel = channel
            }
        )
            .accessibilityLabel("Orbital 3D Sonic Sphere viewport")
            .simultaneousGesture(magnificationGesture())
    }

    private func inspector(configuration: OrbitalViewportRenderConfiguration) -> some View {
        OrbitalViewportInspectorView(
            configuration: configuration,
            selectedChannel: selectedChannel
        )
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
                Text("Fake meter stream")
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
        exportToken += 1
        let requestedToken = exportToken
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if exportInProgress && exportToken == requestedToken {
                handleExportResult(.failure(OrbitalViewportExportError.timedOut))
            }
        }
    }

    private func handleExportResult(_ result: Result<URL, Error>) {
        exportInProgress = false
        let status: OrbitalViewportExportStatus
        switch result {
        case .success:
            status = OrbitalViewportExportStatus(message: "Saved PNG to Desktop", isError: false)
        case .failure:
            status = OrbitalViewportExportStatus(message: "PNG export failed", isError: true)
        }
        exportStatus = status
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if exportStatus?.id == status.id {
                exportStatus = nil
            }
        }
    }
}

struct OrbitalViewportExportStatus: Equatable {
    let id = UUID()
    let message: String
    let isError: Bool
}

private struct OrbitalViewportInspectorView: View {
    let configuration: OrbitalViewportRenderConfiguration
    let selectedChannel: Int?

    @State private var timeMS = Date.timeIntervalSinceReferenceDate * 1000

    private var frameConfiguration: OrbitalViewportRenderConfiguration {
        configuration.frameConfiguration(timeMS: timeMS)
    }

    private var snapshot: OrbitalViewportSnapshot {
        OrbitalViewportSnapshot(configuration: frameConfiguration)
    }

    private var theme: OrbitalViewportTheme {
        configuration.theme
    }

    var body: some View {
        VStack(spacing: 12) {
            panel {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scene")
                        .font(.system(size: 12, weight: .bold))
                    HStack(spacing: 8) {
                        metric("Active", value: "\(snapshot.activeCount)/30")
                        metric("Peak", value: snapshot.peakSpeaker.label.replacingOccurrences(of: "Fey ", with: ""))
                    }
                }
            }

            panel {
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedTitle)
                        .font(.system(size: 12, weight: .bold))
                    Text(selectedBody)
                        .font(.system(size: 12))
                        .lineSpacing(2)
                        .foregroundStyle(theme.muted)
                }
            }

            panel {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(snapshot.speakers) { speaker in
                            speakerRow(speaker)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding(12)
        .background(theme.panelBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(theme.line)
                .frame(width: 1)
        }
        .onReceive(
            Timer.publish(
                every: 1 / Double(OrbitalViewportMockup.inspectorRefreshFramesPerSecond),
                on: .main,
                in: .common
            )
            .autoconnect()
        ) { date in
            timeMS = date.timeIntervalSinceReferenceDate * 1000
        }
    }

    private func panel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.panelSecondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func metric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(theme.muted)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.text)
        }
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .padding(8)
        .background(theme.metricBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(theme.metricBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    private func speakerRow(_ speaker: OrbitalViewportProjectedSpeaker) -> some View {
        HStack(spacing: 8) {
            Text(speaker.label)
                .frame(width: 58, alignment: .leading)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.barTrack)
                    .frame(height: 6)
                Capsule()
                    .fill(theme.meterBar)
                    .frame(height: 6)
                    .scaleEffect(x: max(0, min(1, CGFloat(speaker.peak))), y: 1, anchor: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 6, maxHeight: 6)
            .clipped()
            Text(speaker.peak.formatted(.number.precision(.fractionLength(2))))
                .monospacedDigit()
                .frame(width: 42, alignment: .trailing)
        }
        .font(.system(size: 12))
        .foregroundStyle(theme.text)
        .frame(minHeight: 30)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.rowLine)
                .frame(height: 1)
        }
    }

    private var selectedTitle: String {
        guard let selectedSpeaker else {
            return "No speaker selected"
        }
        return selectedSpeaker.label
    }

    private var selectedBody: String {
        guard let speaker = selectedSpeaker else {
            return "Click a speaker in the viewport to inspect channel identity, coordinates, and level state."
        }

        return "Channel \(speaker.channel) / RMS \(speaker.rms.formatted(.number.precision(.fractionLength(2)))) / Peak \(speaker.peak.formatted(.number.precision(.fractionLength(2)))) / xyz \(speaker.source.x.formatted(.number.precision(.fractionLength(3)))), \(speaker.source.y.formatted(.number.precision(.fractionLength(3)))), \(speaker.source.z.formatted(.number.precision(.fractionLength(3))))"
    }

    private var selectedSpeaker: OrbitalViewportProjectedSpeaker? {
        guard let selectedChannel else {
            return nil
        }
        return snapshot.speakers.first(where: { $0.channel == selectedChannel })
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

enum OrbitalViewportPNGExporter {
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
    static func writeSnapshot(
        image: NSImage,
        style: OrbitalViewportRenderStyle,
        date: Date = Date(),
        fileManager: FileManager = .default
    ) throws -> URL {
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let png = bitmap.representation(using: .png, properties: [:])
        else {
            throw OrbitalViewportExportError.missingPNGData
        }
        guard let desktop = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            throw OrbitalViewportExportError.missingDesktopDirectory
        }
        let url = destinationURL(style: style, date: date, desktopDirectory: desktop)
        try png.write(to: url, options: .atomic)
        return url
    }
    #endif
}

public enum OrbitalViewportCameraView: String, CaseIterable, Identifiable, Equatable {
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

public enum OrbitalViewportRenderStyle: String, CaseIterable, Identifiable, Equatable {
    case purple
    case flamingo
    case green
    case bw

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
        }
    }
}

public enum OrbitalViewportSpeakerShape: String, CaseIterable, Identifiable, Equatable {
    case prism
    case sphere

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .prism:
            return "Prism"
        case .sphere:
            return "Sphere"
        }
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
    let speakerShape: OrbitalViewportSpeakerShape
    let speakerSize: Double
    let fogDensity: Double
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
        speakerShape: OrbitalViewportSpeakerShape,
        speakerSize: Double,
        fogDensity: Double,
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
        self.speakerShape = speakerShape
        self.speakerSize = speakerSize
        self.fogDensity = fogDensity
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
    let showHiddenLines: Bool

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.yaw = configuration.yaw
        self.pitch = configuration.pitch
        self.cameraView = configuration.cameraView
        self.renderStyle = configuration.renderStyle
        self.showHiddenLines = configuration.showHiddenLines
    }
}

struct OrbitalViewportSpeakerGeometryUpdateKey: Equatable {
    let speakerShape: OrbitalViewportSpeakerShape
    let speakerSize: Double

    init(speakerShape: OrbitalViewportSpeakerShape, speakerSize: Double) {
        self.speakerShape = speakerShape
        self.speakerSize = speakerSize
    }

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.init(speakerShape: configuration.speakerShape, speakerSize: configuration.speakerSize)
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
    let renderStyle: OrbitalViewportRenderStyle
    let selectedChannel: Int?

    init(configuration: OrbitalViewportRenderConfiguration) {
        self.meterFrame = Int(configuration.timeMS / (1000 / Double(OrbitalViewportMockup.viewportAnimationFramesPerSecond)))
        self.renderStyle = configuration.renderStyle
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
        let meter = OrbitalViewportMath.meter(channel: source.channel, timeMS: configuration.timeMS)
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

    let configuration: OrbitalViewportRenderConfiguration
    let snapshot: OrbitalViewportSnapshot
    let exportToken: Int
    let onExportFinished: (Result<URL, Error>) -> Void
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
        view.preferredFramesPerSecond = Self.sceneFramesPerSecond
        view.scene = context.coordinator.scene
        view.pointOfView = context.coordinator.cameraNode
        view.onDragStarted = onDragStarted
        view.onDrag = onDrag
        view.onDragEnded = onDragEnded
        view.onZoom = onZoom
        view.onSelect = onSelect
        context.coordinator.attach(to: view)
        context.coordinator.update(
            configuration: configuration,
            snapshot: snapshot,
            exportToken: exportToken,
            onExportFinished: onExportFinished
        )
        return view
    }

    func updateNSView(_ nsView: OrbitalViewportSceneNSView, context: Context) {
        nsView.onDragStarted = onDragStarted
        nsView.onDrag = onDrag
        nsView.onDragEnded = onDragEnded
        nsView.onZoom = onZoom
        nsView.onSelect = onSelect
        context.coordinator.attach(to: nsView)
        context.coordinator.update(
            configuration: configuration,
            snapshot: snapshot,
            exportToken: exportToken,
            onExportFinished: onExportFinished
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
        private var lastExportToken = 0

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
            rebuildSpeakers(shape: .prism, speakerSize: OrbitalViewportMath.speakerSize(fromSlider: 50))
        }

        deinit {
            animationTimer?.invalidate()
        }

        func attach(to view: OrbitalViewportSceneNSView) {
            self.view = view
            startAnimationTimerIfNeeded()
        }

        func update(
            configuration: OrbitalViewportRenderConfiguration,
            snapshot: OrbitalViewportSnapshot,
            exportToken: Int,
            onExportFinished: @escaping (Result<URL, Error>) -> Void
        ) {
            _ = snapshot
            latestConfiguration = configuration

            let geometryKey = OrbitalViewportSpeakerGeometryUpdateKey(configuration: configuration)
            if lastSpeakerGeometryKey != geometryKey {
                rebuildSpeakers(shape: configuration.speakerShape, speakerSize: configuration.speakerSize)
            }

            renderScene(configuration: configuration)

            if exportToken != lastExportToken {
                lastExportToken = exportToken
                exportSnapshot(configuration: configuration.frameConfiguration(timeMS: currentTimeMS()), onExportFinished: onExportFinished)
            }
        }

        private func startAnimationTimerIfNeeded() {
            guard animationTimer == nil else {
                return
            }

            let interval = 1 / Double(OrbitalViewport3DSceneView.sceneFramesPerSecond)
            let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
                self?.renderAnimationFrame()
            }
            RunLoop.main.add(timer, forMode: .common)
            animationTimer = timer
        }

        private func renderAnimationFrame() {
            guard let latestConfiguration else {
                return
            }
            let frameTimeMS = currentTimeMS()
            let framesPerSecond = latestConfiguration.spin
                ? OrbitalViewport3DSceneView.sceneFramesPerSecond
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
                let node = cylinderNode(from: start, to: end, radius: edge.lengthGroup == 2 ? 0.0032 : 0.0024)
                node.name = "shell-edge-\(edge.a)-\(edge.b)"
                shellNode.addChildNode(node)
                edgeNodes.append(node)
            }

            for point in OrbitalViewportGeodesic.structure.nodes {
                let marker = SCNNode(geometry: SCNSphere(radius: 0.005))
                marker.position = point.scn
                marker.name = "shell-node"
                shellNode.addChildNode(marker)
                nodeMarkers.append(marker)
            }
        }

        private func rebuildSpeakers(shape: OrbitalViewportSpeakerShape, speakerSize: Double) {
            speakerRebuildCount += 1
            speakerRoot.childNodes.forEach { $0.removeFromParentNode() }
            labelRoot.childNodes.forEach { $0.removeFromParentNode() }
            speakerNodes.removeAll()
            labelNodes.removeAll()
            lastSpeakerGeometryKey = OrbitalViewportSpeakerGeometryUpdateKey(speakerShape: shape, speakerSize: speakerSize)
            lastSpeakerVisibilityKey = nil
            lastSpeakerMaterialKey = nil

            for speaker in OrbitalViewportSpeaker.referenceSpeakers {
                let node = makeSpeakerNode(speaker: speaker, shape: shape, speakerSize: speakerSize)
                node.name = "speaker-\(speaker.channel)"
                speakerRoot.addChildNode(node)
                speakerNodes[speaker.channel] = node

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
            speakerSize: Double
        ) -> SCNNode {
            let node: SCNNode
            switch shape {
            case .sphere:
                node = SCNNode(geometry: SCNSphere(radius: 0.035 * speakerSize))
                node.position = (OVVector3(speaker) * 1.02).scn
            case .prism:
                let short = 0.032 * speakerSize
                let geometry = SCNBox(width: short * 2, height: short, length: short, chamferRadius: short * 0.05)
                node = SCNNode(geometry: geometry)
                let basis = prismBasis(for: speaker)
                let position = OVVector3(speaker) + (basis.radialAxis * (short * 0.5))
                node.simdTransform = matrix(
                    longAxis: basis.longAxis,
                    sideAxis: basis.sideAxis,
                    radialAxis: basis.radialAxis,
                    position: position
                )
            }

            node.geometry?.materials = [SCNMaterial()]
            node.geometry?.firstMaterial?.lightingModel = .physicallyBased
            node.geometry?.firstMaterial?.metalness.contents = 0.12
            node.geometry?.firstMaterial?.roughness.contents = 0.38
            return node
        }

        private func makeLabelNode(channel: Int) -> SCNNode {
            let text = SCNText(string: String(format: "%02d", channel), extrusionDepth: 0.0008)
            text.font = NSFont.systemFont(ofSize: 0.14, weight: .semibold)
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
            node.scale = SCNVector3(0.22, 0.22, 0.22)
            node.renderingOrder = 1000
            node.constraints = [SCNBillboardConstraint()]
            return node
        }

        private func updateShell(configuration: OrbitalViewportRenderConfiguration) {
            let theme = configuration.theme
            let hiddenVisible = configuration.hiddenLinesVisible

            for (index, edgeNode) in edgeNodes.enumerated() {
                let edge = OrbitalViewportGeodesic.structure.edges[index]
                let start = configuration.rotate(OrbitalViewportGeodesic.structure.nodes[edge.a])
                let end = configuration.rotate(OrbitalViewportGeodesic.structure.nodes[edge.b])
                let visible = hiddenVisible || start.z >= configuration.frontClipPlane || end.z >= configuration.frontClipPlane
                edgeNode.isHidden = !visible
                let depthAlpha = start.z < configuration.frontClipPlane && end.z < configuration.frontClipPlane ? 0.28 : 1
                let baseAlpha = ([0.48, 0.64, 0.82][safe: edge.lengthGroup] ?? 0.62) * depthAlpha
                setMaterial(
                    edgeNode.geometry?.firstMaterial,
                    color: edge.lengthGroup == 2 ? theme.equator : theme.structure,
                    alpha: baseAlpha
                )
            }

            for (index, node) in nodeMarkers.enumerated() {
                let rotated = configuration.rotate(OrbitalViewportGeodesic.structure.nodes[index])
                node.isHidden = !configuration.isVisibleDepth(rotated.z)
                let alpha = rotated.z < configuration.frontClipPlane ? 0.18 : 0.34
                setMaterial(node.geometry?.firstMaterial, color: theme.structure, alpha: alpha)
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
                }

                if updateMaterial {
                    let alpha = speaker.depth < configuration.frontClipPlane ? 0.34 : 0.94
                    let color = configuration.theme.colorForPeak(speaker.peak)
                    setMaterial(
                        node.geometry?.firstMaterial,
                        color: color,
                        alpha: selected ? 1 : alpha,
                        emission: color.opacity(0.18 + speaker.peak * 0.52)
                    )
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

        private func exportSnapshot(
            configuration: OrbitalViewportRenderConfiguration,
            onExportFinished: @escaping (Result<URL, Error>) -> Void
        ) {
            guard let view else {
                DispatchQueue.main.async {
                    onExportFinished(.failure(OrbitalViewportExportError.missingView))
                }
                return
            }
            let result: Result<URL, Error>
            do {
                let url = try OrbitalViewportPNGExporter.writeSnapshot(
                    image: view.snapshot(),
                    style: configuration.renderStyle
                )
                result = .success(url)
            } catch {
                result = .failure(error)
            }
            DispatchQueue.main.async {
                onExportFinished(result)
            }
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
    let exportToken: Int
    let onExportFinished: (Result<URL, Error>) -> Void
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
            let strokeColor = edgeView.edge.lengthGroup == 2 ? theme.equator : theme.structure
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
            context.fill(Path(ellipseIn: rect), with: .color(theme.structure.opacity(alpha)))
        }
    }

    mutating private func drawHiddenLinesBoundary() {
        guard !configuration.hiddenLinesVisible else {
            return
        }
        let center = CGPoint(x: configuration.size.width * 0.5, y: configuration.size.height * 0.5)
        let radius = configuration.sphereRadius
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.stroke(Path(ellipseIn: rect), with: .color(theme.structure), lineWidth: 1)
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
            case .prism:
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
        let long = short * 2
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
            vertex(-1, -1, short),
            vertex(1, -1, short),
            vertex(1, 1, short),
            vertex(-1, 1, short)
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
        let distance = (configuration.speakerShape == .prism ? 24 : 17) + configuration.speakerSize * 4
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
    static let switchColumnWidth: CGFloat = 54
    static let toggleRowHeight: CGFloat = 30
}

struct OrbitalViewportTheme: Equatable {
    let style: OrbitalViewportRenderStyle

    var pageBackground: AnyShapeStyle {
        AnyShapeStyle(LinearGradient(colors: [OrbitalViewportLabTheme.bg, OrbitalViewportLabTheme.bgBottom], startPoint: .top, endPoint: .bottom))
    }

    var canvasBackground: GraphicsContext.Shading {
        .linearGradient(Gradient(colors: [OrbitalViewportLabTheme.bg, OrbitalViewportLabTheme.bgBottom]), startPoint: .zero, endPoint: CGPoint(x: 0, y: 900))
    }

    var railBackground: Color {
        OrbitalViewportLabTheme.panel
    }

    var toolbarBackground: Color {
        OrbitalViewportLabTheme.toolbar
    }

    var panelBackground: Color {
        OrbitalViewportLabTheme.panel
    }

    var panelSecondaryBackground: Color {
        OrbitalViewportLabTheme.panelSoft
    }

    var statusBackground: Color {
        OrbitalViewportLabTheme.toolbar
    }

    var chipBackground: Color {
        OrbitalViewportLabTheme.panelSoft
    }

    var text: Color {
        OrbitalViewportLabTheme.text
    }

    var muted: Color {
        OrbitalViewportLabTheme.textSoft
    }

    var line: Color {
        OrbitalViewportLabTheme.line
    }

    var rowLine: Color {
        OrbitalViewportLabTheme.line.opacity(0.72)
    }

    var buttonBackground: Color {
        OrbitalViewportLabTheme.panelSoft
    }

    var buttonActiveBackground: Color {
        OrbitalViewportLabTheme.cyan.opacity(0.14)
    }

    var buttonActiveBorder: Color {
        OrbitalViewportLabTheme.cyan.opacity(0.55)
    }

    var activeButtonText: Color {
        text
    }

    var accent: Color {
        OrbitalViewportLabTheme.cyan
    }

    var accentStrong: Color {
        OrbitalViewportLabTheme.cyan
    }

    var metricBackground: Color {
        OrbitalViewportLabTheme.panelSoft
    }

    var metricBorder: Color {
        line
    }

    var barTrack: Color {
        OrbitalViewportLabTheme.line
    }

    var meterBar: AnyShapeStyle {
        switch style {
        case .green:
            return AnyShapeStyle(LinearGradient(colors: [Color(hex: "#5eead4"), Color(hex: "#18ce0f"), Color(hex: "#facc15"), Color(hex: "#fb7185")], startPoint: .leading, endPoint: .trailing))
        case .flamingo:
            return AnyShapeStyle(LinearGradient(colors: [Color(hex: "#f75ba7"), Color(hex: "#ffb3d7")], startPoint: .leading, endPoint: .trailing))
        case .purple:
            return AnyShapeStyle(LinearGradient(colors: [Color(hex: "#aa88ff"), Color(hex: "#32d6bf"), Color(hex: "#ffb236"), Color(hex: "#ff3636")], startPoint: .leading, endPoint: .trailing))
        case .bw:
            return AnyShapeStyle(LinearGradient(colors: [Color.white.opacity(0.54), Color.white.opacity(0.92)], startPoint: .leading, endPoint: .trailing))
        }
    }

    var structure: Color {
        switch style {
        case .green: return Color(red: 217 / 255, green: 251 / 255, blue: 255 / 255).opacity(0.14)
        case .flamingo: return Color(hex: "#f75ba7").opacity(0.34)
        case .purple: return Color.white.opacity(0.12)
        case .bw: return OrbitalViewportLabTheme.textSoft.opacity(0.32)
        }
    }

    var equator: Color {
        switch style {
        case .green: return Color(hex: "#aa88ff").opacity(0.22)
        case .flamingo: return Color(hex: "#f75ba7").opacity(0.28)
        case .purple: return Color(hex: "#32d6bf").opacity(0.26)
        case .bw: return OrbitalViewportLabTheme.text.opacity(0.42)
        }
    }

    var label: Color {
        switch style {
        case .green: return Color(hex: "#9fb9bd").opacity(0.78)
        case .flamingo: return Color(hex: "#ffdff0").opacity(0.78)
        case .purple: return Color(hex: "#aaacad").opacity(0.78)
        case .bw: return OrbitalViewportLabTheme.text.opacity(0.76)
        }
    }

    var selectedLabel: Color {
        switch style {
        case .green: return Color(hex: "#effcff")
        case .flamingo: return Color.white
        case .purple: return Color(hex: "#f2f2f2")
        case .bw: return OrbitalViewportLabTheme.text
        }
    }

    var fog: Color {
        OrbitalViewportLabTheme.bgBottom.opacity(0.64)
    }

    var backgroundGlow: Color? {
        OrbitalViewportLabTheme.cyan.opacity(0.1)
    }

    var dot: Color {
        OrbitalViewportLabTheme.green
    }

    func colorForPeak(_ peak: Double) -> Color {
        if style == .flamingo {
            return Color(hex: "#f75ba7")
        }
        if style == .bw {
            return Color.white.opacity(0.88)
        }
        if peak > 0.9 {
            return style == .green ? Color(hex: "#fb7185") : Color(hex: "#ff3636")
        }
        if peak > 0.68 {
            return style == .green ? Color(hex: "#facc15") : Color(hex: "#ffb236")
        }
        if peak > 0.35 {
            return style == .green ? Color(hex: "#18ce0f") : Color(hex: "#32d6bf")
        }
        return style == .green ? Color(hex: "#5eead4") : Color(hex: "#aa88ff")
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

    static func meter(channel: Int, timeMS: Double) -> (rms: Double, peak: Double) {
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
