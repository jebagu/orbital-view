import OrbitalViewCore
import OrbitalViewSwiftUI
import OrbitalViewViewerSupport
import SwiftUI

@main
struct OrbitalViewViewerApp: App {
    var body: some Scene {
        WindowGroup("Orbital View Viewer") {
            OrbitalViewViewerRoot()
                .frame(minWidth: 980, minHeight: 700)
        }
    }
}

struct OrbitalViewViewerRoot: View {
    private let meters: SpeakerMeterFrame
    private let objectMeters: ObjectMeterFrame
    private let objectVisualSettings: ObjectVisualSettings
    private let timestamp: TimeInterval

    @State private var camera: OrbitalViewCameraState
    @State private var selection: OrbitalViewSelection?
    @State private var viewMode: OrbitalViewMode = .isometric

    init() {
        let timestamp = Date().timeIntervalSince1970
        self.timestamp = timestamp
        self.meters = try! OrbitalViewViewerDemoContent.makeMeterFrame(timestamp: timestamp)
        self.objectMeters = try! OrbitalViewViewerDemoContent.makeObjectMeters(timestamp: timestamp)
        self.objectVisualSettings = try! OrbitalViewViewerDemoContent.makeObjectVisualSettings()
        self._camera = State(initialValue: try! OrbitalViewCameraState.preset(.isometric, distanceM: 4.2))
        self._selection = State(initialValue: nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack {
                OrbitalView(
                    scene: scene,
                    meters: meters,
                    objectFrames: objectFrames,
                    objectMeters: objectMeters,
                    objectVisualSettings: objectVisualSettings,
                    inputDiagnostics: .empty,
                    camera: $camera,
                    selection: $selection
                )

                ViewerGuideOverlay(speakers: speakerSnapshots)
                    .allowsHitTesting(false)
            }

            footer
        }
        .background(Color(red: 0.02, green: 0.025, blue: 0.032))
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Orbital View Viewer")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Fey 30 speaker fixture / \(objectFrames.activeObjects.count) demo source objects")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.62))
            }

            Spacer()

            cameraButton("Plan", systemImage: "square.grid.3x3", mode: .plan)
            cameraButton("Front", systemImage: "rectangle", mode: .frontElevation)
            cameraButton("Side", systemImage: "rectangle.portrait", mode: .sideElevation)
            cameraButton("Iso", systemImage: "cube.transparent", mode: .isometric)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 0.055, green: 0.065, blue: 0.08))
    }

    private var footer: some View {
        HStack(spacing: 10) {
            Text("Camera preset transforms the viewer fixture until renderer-native camera projection lands.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.54))
                .lineLimit(1)

            Spacer()

            Text(viewModeLabel)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(red: 0.055, green: 0.065, blue: 0.08))
    }

    private var scene: OrbitalViewSceneSpec {
        try! OrbitalViewViewerDemoContent.makeScene(viewMode: viewMode)
    }

    private var objectFrames: OrbitalViewObjectFrameSet {
        try! OrbitalViewViewerDemoContent.makeObjectFrames(timestamp: timestamp, viewMode: viewMode)
    }

    private var speakerSnapshots: [OrbitalViewViewerSpeakerSnapshot] {
        (try? OrbitalViewViewerDemoContent.makeSpeakerSnapshots(viewMode: viewMode)) ?? []
    }

    private var viewModeLabel: String {
        switch viewMode {
        case .plan:
            return "PLAN"
        case .frontElevation:
            return "FRONT"
        case .sideElevation:
            return "SIDE"
        case .isometric:
            return "ISO"
        case .custom:
            return "CUSTOM"
        }
    }

    private func cameraButton(_ title: String, systemImage: String, mode: OrbitalViewMode) -> some View {
        Button {
            setCamera(mode)
        } label: {
            Label(title, systemImage: systemImage)
        }
        .buttonStyle(.bordered)
        .tint(viewMode == mode ? .cyan : .secondary)
    }

    private func setCamera(_ mode: OrbitalViewMode) {
        if let nextCamera = try? OrbitalViewCameraState.preset(mode, distanceM: 4.2) {
            viewMode = mode
            camera = nextCamera
        }
    }
}

private struct ViewerGuideOverlay: View {
    let speakers: [OrbitalViewViewerSpeakerSnapshot]

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                let radius = min(size.width, size.height) * 0.5 * OrbitalViewViewerDemoContent.projectionScale
                drawSphereGuide(context: &context, center: center, radius: radius)
                drawSpeakerLabels(context: &context, size: size)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func drawSphereGuide(context: inout GraphicsContext, center: CGPoint, radius: CGFloat) {
        let stroke = StrokeStyle(lineWidth: 1)
        let color = Color.white.opacity(0.13)
        for scale in [1.0, 0.72, 0.44] {
            let scaledRadius = radius * scale
            let rect = CGRect(
                x: center.x - scaledRadius,
                y: center.y - scaledRadius,
                width: scaledRadius * 2,
                height: scaledRadius * 2
            )
            context.stroke(Path(ellipseIn: rect), with: .color(color), style: stroke)
        }

        var vertical = Path()
        vertical.move(to: CGPoint(x: center.x, y: center.y - radius))
        vertical.addLine(to: CGPoint(x: center.x, y: center.y + radius))
        context.stroke(vertical, with: .color(Color.white.opacity(0.08)), style: stroke)

        var horizontal = Path()
        horizontal.move(to: CGPoint(x: center.x - radius, y: center.y))
        horizontal.addLine(to: CGPoint(x: center.x + radius, y: center.y))
        context.stroke(horizontal, with: .color(Color.white.opacity(0.08)), style: stroke)
    }

    private func drawSpeakerLabels(context: inout GraphicsContext, size: CGSize) {
        for speaker in speakers where speaker.channel == 1 || speaker.channel % 5 == 0 {
            let point = CGPoint(
                x: (size.width * 0.5) + (speaker.projectedX * size.width * 0.5),
                y: (size.height * 0.5) - (speaker.projectedY * size.height * 0.5)
            )
            context.draw(
                Text("\(speaker.channel)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.58)),
                at: CGPoint(x: point.x + 15, y: point.y - 14)
            )
        }
    }
}
