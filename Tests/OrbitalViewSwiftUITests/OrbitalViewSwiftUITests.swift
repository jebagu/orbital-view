import SwiftUI
import XCTest
@testable import OrbitalViewCore
@testable import OrbitalViewRender
@testable import OrbitalViewSwiftUI

final class OrbitalViewSwiftUITests: XCTestCase {
    func testOrbitalViewInitializesWithBindings() throws {
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let view = OrbitalView(
            scene: scene,
            camera: .constant(camera),
            selection: .constant(nil)
        )

        XCTAssertEqual(view.scene, scene)
        XCTAssertNil(view.meters)
    }

    func testCoordinatorAppliesConfigurationWithoutRepeatedStructuralUpdates() throws {
        let coordinator = OrbitalViewMetalView.Coordinator(renderer: OrbitalViewMetalRenderer())
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let firstFrame = try SpeakerMeterFrame(
            timestamp: 1,
            levelsByChannel: [
                1: SpeakerMeterLevel(rms: 0.2, peak: 0.3, clip: false)
            ]
        )
        let configuration = OrbitalViewRenderConfiguration(
            scene: scene,
            meters: firstFrame,
            camera: camera,
            selection: nil
        )

        _ = coordinator.apply(configuration)
        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 1)

        _ = coordinator.apply(configuration)
        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 1)

        let secondFrame = try SpeakerMeterFrame(
            timestamp: 2,
            levelsByChannel: [
                1: SpeakerMeterLevel(rms: 0.5, peak: 0.7, clip: false)
            ]
        )
        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: secondFrame,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 2)
    }

    func testCoordinatorEmitsCameraAndSelectionEvents() throws {
        let coordinator = OrbitalViewMetalView.Coordinator(renderer: OrbitalViewMetalRenderer())
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.frontElevation)
        let selection = OrbitalViewSelection(id: .speaker("speaker-1"))

        let events = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                camera: camera,
                selection: selection
            )
        )

        XCTAssertEqual(events, [.cameraChanged(camera), .selected(selection)])
        XCTAssertEqual(coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                camera: camera,
                selection: selection
            )
        ), [])
    }

    private func makeScene() throws -> OrbitalViewSceneSpec {
        let direction = try UnitSphereDirection(x: 1, y: 0, z: 0)
        let speaker = try OrbitalViewSpeaker(
            id: "speaker-1",
            channel: 1,
            label: "Fey 01",
            anchor: .direction(direction, offsetM: 0.05),
            shape: .sphere(radiusM: 0.03)
        )

        return try OrbitalViewSceneBuilder.makeMonitorScene(
            id: "swiftui-test",
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
            speakers: [speaker]
        )
    }
}
