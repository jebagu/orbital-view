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
        XCTAssertTrue(view.showsControlSurface)
        XCTAssertFalse(view.showsMeterSettingsTray)
    }

    func testOrbitalViewSettingsInitializerOptsIntoTray() throws {
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let settings = try SpeakerMeterVisualSettings(visualGainDB: 3, style: .coolPulse)
        let view = OrbitalView(
            scene: scene,
            meters: nil,
            meterVisualSettings: .constant(settings),
            camera: .constant(camera),
            selection: .constant(nil)
        )

        XCTAssertEqual(view.scene, scene)
        XCTAssertTrue(view.showsControlSurface)
        XCTAssertTrue(view.showsMeterSettingsTray)
    }

    func testCoordinatorAppliesConfigurationWithoutRepeatedStructuralUpdates() throws {
        var emitted: [OrbitalViewEvent] = []
        let coordinator = OrbitalViewMetalView.Coordinator(
            renderer: OrbitalViewMetalRenderer(),
            onEvents: { emitted.append(contentsOf: $0) }
        )
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
            meterVisualSettings: .default,
            displaySettings: .default,
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
                meterVisualSettings: .default,
                displaySettings: .default,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 2)
    }

    func testCoordinatorAppliesMeterVisualSettingsWithoutReloadingScene() throws {
        var emitted: [OrbitalViewEvent] = []
        let coordinator = OrbitalViewMetalView.Coordinator(
            renderer: OrbitalViewMetalRenderer(),
            onEvents: { emitted.append(contentsOf: $0) }
        )
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let initialSettings = SpeakerMeterVisualSettings.default
        let boostedSettings = try SpeakerMeterVisualSettings(visualGainDB: 6, style: .warmPulse)

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: initialSettings,
                displaySettings: .default,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterVisualSettingsRevision, 0)

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: boostedSettings,
                displaySettings: .default,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.scene, scene)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 0)
        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.meterVisualSettings, boostedSettings)
        XCTAssertEqual(coordinator.renderer.renderState.meterVisualSettingsRevision, 1)
    }

    func testCoordinatorAppliesDisplaySettingsWithoutReloadingSceneOrMeters() throws {
        var emitted: [OrbitalViewEvent] = []
        let coordinator = OrbitalViewMetalView.Coordinator(
            renderer: OrbitalViewMetalRenderer(),
            onEvents: { emitted.append(contentsOf: $0) }
        )
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let detailed = try OrbitalViewDisplaySettings(
            speakerShape: .sphere,
            speakerScale: 2.25,
            fogDensity: 70,
            showsSpeakerNumbers: true,
            showsHiddenLines: true
        )

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: .default,
                displaySettings: .default,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.displaySettingsRevision, 0)

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: .default,
                displaySettings: detailed,
                camera: camera,
                selection: nil
            )
        )

        XCTAssertEqual(coordinator.renderer.renderState.scene, scene)
        XCTAssertEqual(coordinator.renderer.renderState.meterRevision, 0)
        XCTAssertEqual(coordinator.renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(coordinator.renderer.renderState.displaySettings, detailed)
        XCTAssertEqual(coordinator.renderer.renderState.displaySettingsRevision, 1)
    }

    func testCoordinatorEmitsCameraAndSelectionEvents() throws {
        var emitted: [OrbitalViewEvent] = []
        let coordinator = OrbitalViewMetalView.Coordinator(
            renderer: OrbitalViewMetalRenderer(),
            onEvents: { emitted.append(contentsOf: $0) }
        )
        let scene = try makeScene()
        let camera = try OrbitalViewCameraState.preset(.frontElevation)
        let selection = OrbitalViewSelection(id: .speaker("speaker-1"))

        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: .default,
                displaySettings: .default,
                camera: camera,
                selection: selection
            )
        )

        XCTAssertEqual(emitted, [.cameraChanged(camera), .selected(selection)])
        emitted.removeAll(keepingCapacity: false)
        _ = coordinator.apply(
            OrbitalViewRenderConfiguration(
                scene: scene,
                meters: nil,
                meterVisualSettings: .default,
                displaySettings: .default,
                camera: camera,
                selection: selection
            )
        )
        XCTAssertTrue(emitted.isEmpty)
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
