import MetalKit
import XCTest
@testable import OrbitalViewCore
@testable import OrbitalViewRender

final class OrbitalViewRenderTests: XCTestCase {
    func testRendererStateSeparatesSceneAndMeterUpdates() throws {
        let renderer = OrbitalViewMetalRenderer()
        let scene = try makeScene()
        let frame = try SpeakerMeterFrame(
            timestamp: 1,
            levelsByChannel: [
                1: SpeakerMeterLevel(rms: 0.25, peak: 0.5, clip: false)
            ]
        )

        renderer.loadScene(scene)
        XCTAssertEqual(renderer.renderState.scene, scene)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 0)

        renderer.updateMeters(frame)
        XCTAssertEqual(renderer.renderState.scene, scene)
        XCTAssertEqual(renderer.renderState.meters, frame)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 1)
    }

    func testCameraAndSelectionEmitEventsWithoutTouchingMeters() throws {
        let renderer = OrbitalViewMetalRenderer()
        let frame = try SpeakerMeterFrame(
            timestamp: 1,
            levelsByChannel: [
                1: SpeakerMeterLevel(rms: 0.25, peak: 0.5, clip: false)
            ]
        )
        let camera = try OrbitalViewCameraState.preset(.isometric)
        let selection = OrbitalViewSelection(id: .speaker("speaker-1"))

        renderer.updateMeters(frame)
        renderer.updateCamera(camera)
        renderer.select(selection)

        XCTAssertEqual(renderer.renderState.meters, frame)
        XCTAssertEqual(renderer.renderState.camera, camera)
        XCTAssertEqual(renderer.renderState.selection, selection)
        XCTAssertEqual(renderer.renderState.meterRevision, 1)
        XCTAssertEqual(renderer.renderState.cameraRevision, 1)
        XCTAssertEqual(renderer.drainEvents(), [.cameraChanged(camera), .selected(selection)])
        XCTAssertEqual(renderer.drainEvents(), [])
    }

    func testMetalRendererProvidesMTKViewDelegateSeam() {
        let renderer = OrbitalViewMetalRenderer()
        let delegate: MTKViewDelegate = renderer

        XCTAssertTrue(delegate === renderer)
    }

    func testOffscreenRendererSmokeProducesNonClearFrame() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw XCTSkip("Metal device unavailable; skipping offscreen renderer smoke test.")
        }

        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.35, peak: 0.7, clip: false),
                    2: SpeakerMeterLevel(rms: 0.2, peak: 0.4, clip: false)
                ]
            )
        )

        let frame = try renderer.renderOffscreen(device: device, width: 64, height: 64)

        XCTAssertEqual(frame.width, 64)
        XCTAssertEqual(frame.height, 64)
        XCTAssertEqual(frame.bgra8Bytes.count, 64 * 64 * 4)
        XCTAssertTrue(frame.containsNonClearPixel)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 1)
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
            id: "render-test",
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
            speakers: [speaker]
        )
    }

    private func makeThreeSpeakerScene() throws -> OrbitalViewSceneSpec {
        let speakers = try [
            makeSpeaker(id: "speaker-1", channel: 1, label: "Fey 01", direction: (1, 0, 0)),
            makeSpeaker(id: "speaker-2", channel: 2, label: "Fey 02", direction: (0, 1, 0)),
            makeSpeaker(id: "speaker-3", channel: 3, label: "Fey 03", direction: (0, 0, 1))
        ]

        return try OrbitalViewSceneBuilder.makeMonitorScene(
            id: "render-smoke-test",
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
            speakers: speakers
        )
    }

    private func makeSpeaker(
        id: String,
        channel: Int,
        label: String,
        direction: (Double, Double, Double)
    ) throws -> OrbitalViewSpeaker {
        try OrbitalViewSpeaker(
            id: id,
            channel: channel,
            label: label,
            anchor: .direction(
                try UnitSphereDirection(x: direction.0, y: direction.1, z: direction.2),
                offsetM: 0.05
            ),
            shape: .sphere(radiusM: 0.03)
        )
    }
}
