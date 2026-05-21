import OrbitalViewCore
import OrbitalViewSwiftUI
import SwiftUI

@main
struct OrbitalViewVUKitApp: App {
    @State private var scene: OrbitalViewSceneSpec = {
        do {
            return try makeDefaultScene()
        } catch {
            // The app is expected to be offline by default and should always load this synthetic
            // scene. In the unlikely event it cannot, fail fast with a useful assertion.
            fatalError("Failed to create Orbital View VU Kit default scene: \(error)")
        }
    }()

    @State private var camera: OrbitalViewCameraState = {
        do {
            return try OrbitalViewCameraState.preset(.isometric)
        } catch {
            fatalError("Failed to create default camera state: \(error)")
        }
    }()

    @State private var selection: OrbitalViewSelection?
    @State private var meterVisualSettings: SpeakerMeterVisualSettings = .default
    @State private var displaySettings: OrbitalViewDisplaySettings = .default

    var body: some Scene {
        Window("Orbital View VU Kit", id: "orbital-view-vu-kit") {
            OrbitalView(
                scene: scene,
                meterVisualSettings: $meterVisualSettings,
                displaySettings: $displaySettings,
                camera: $camera,
                selection: $selection,
                onEvents: { _ in }
            )
            .frame(minWidth: 1024, minHeight: 640)
        }
        .windowStyle(.titleBar)
    }
}

private func makeDefaultScene() throws -> OrbitalViewSceneSpec {
    let shell = try OrbitalViewSceneBuilder.makeFeyGeodesicShell()
    let directionalSpeakers = try (0..<30).map { index -> OrbitalViewSpeaker in
        let channel = index + 1
        let goldenAngle = Double.pi * (3 - sqrt(5))
        let y = 1 - (Double(index) / 29.0) * 2
        let radius = sqrt(max(0.0, 1 - (y * y)))
        let theta = Double(index) * goldenAngle

        return try OrbitalViewSpeaker(
            id: "speaker-\(channel)",
            channel: channel,
            label: String(format: "Fey %02d", channel),
            anchor: .direction(
                try UnitSphereDirection.normalized(
                    x: cos(theta) * radius,
                    y: y,
                    z: sin(theta) * radius
                ),
                offsetM: 0.05
            ),
            shape: .sphere(radiusM: 0.03)
        )
    }

    let speakers = try OrbitalViewSceneBuilder.anchoringSpeakersToNearestShellNodes(
        directionalSpeakers,
        in: shell
    )

    return try OrbitalViewSceneBuilder.makeMonitorScene(
        id: "orbital-view-vu-kit-default",
        shell: shell,
        speakers: speakers
    )
}
