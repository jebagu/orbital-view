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
        XCTAssertEqual(renderer.renderState.meterVisualSettingsRevision, 0)
        XCTAssertEqual(renderer.renderState.displaySettingsRevision, 0)

        renderer.updateMeters(frame)
        XCTAssertEqual(renderer.renderState.scene, scene)
        XCTAssertEqual(renderer.renderState.meters, frame)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 1)
        XCTAssertEqual(renderer.renderState.meterVisualSettingsRevision, 0)
        XCTAssertEqual(renderer.renderState.displaySettingsRevision, 0)
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

    func testThirtyChannelMeterFrameMapsByPhysicalChannelAndIgnoresExtras() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThirtySpeakerScene())

        var levelsByChannel: [Int: SpeakerMeterLevel] = [:]
        for channel in 1...31 {
            levelsByChannel[channel] = try SpeakerMeterLevel(
                rms: Float(channel) / 100,
                peak: Float(channel) / 100,
                clip: false
            )
        }

        renderer.updateMeters(try SpeakerMeterFrame(timestamp: 1, levelsByChannel: levelsByChannel))
        let inputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(inputs.speakers.count, 30)
        XCTAssertEqual(inputs.staticGeometry.map(\.channel), Array(1...30))
        XCTAssertEqual(inputs.speakers.compactMap(\.meterLevel?.peak), (1...30).map { Float($0) / 100 })
        XCTAssertFalse(inputs.staticGeometry.contains { $0.channel == 31 })
    }

    func testMeterVisualGainChangesColorsWithoutChangingStaticGeometryOrMeterRevision() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.1, peak: 0.25, clip: false),
                    2: SpeakerMeterLevel(rms: 0.1, peak: 0.35, clip: false)
                ]
            )
        )
        let baselineInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        renderer.updateMeterVisualSettings(try SpeakerMeterVisualSettings(visualGainDB: 6, style: .prismGlow))
        let boostedInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(baselineInputs.staticGeometry, boostedInputs.staticGeometry)
        XCTAssertNotEqual(baselineInputs.colors, boostedInputs.colors)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 1)
        XCTAssertEqual(renderer.renderState.meterVisualSettingsRevision, 1)
    }

    func testMeterVisualStyleChangesVisualRevisionWithoutChangingRawMeterState() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        let frame = try SpeakerMeterFrame(
            timestamp: 1,
            levelsByChannel: [
                1: SpeakerMeterLevel(rms: 0.1, peak: 0.25, clip: false)
            ]
        )

        renderer.updateMeters(frame)
        let baselineInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        renderer.updateMeterVisualSettings(try SpeakerMeterVisualSettings(visualGainDB: 0, style: .warmPulse))
        let styledInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(renderer.renderState.meters, frame)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 1)
        XCTAssertEqual(renderer.renderState.meterVisualSettingsRevision, 1)
        XCTAssertEqual(baselineInputs.staticGeometry, styledInputs.staticGeometry)
        XCTAssertNotEqual(baselineInputs.colors, styledInputs.colors)
    }

    func testCheckerColorSchemeSettingsAffectEverySpeakerColorWithoutChangingGeometry() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        renderer.updateDisplaySettings(
            try OrbitalViewDisplaySettings(fogDensity: 0)
        )
        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1.25,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.12, peak: 0.32, clip: false),
                    2: SpeakerMeterLevel(rms: 0.18, peak: 0.48, clip: false),
                    3: SpeakerMeterLevel(rms: 0.24, peak: 0.64, clip: false)
                ]
            )
        )

        XCTAssertEqual(renderer.renderState.meterVisualSettings.style, .checkerPulseRingAndDiagonalWave)
        let kimiInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        renderer.updateMeterVisualSettings(
            try SpeakerMeterVisualSettings(
                colorScheme: .orbisonicGreen,
                ringFrontDensity: 5.2,
                tileDetail: 12,
                memoryCarryover: 0.72
            )
        )
        let greenInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(kimiInputs.staticGeometry, greenInputs.staticGeometry)
        XCTAssertEqual(greenInputs.speakers.count, 3)
        XCTAssertNotEqual(kimiInputs.colors, greenInputs.colors)
        XCTAssertTrue(greenInputs.colors.allSatisfy { $0.w == 1 })
    }

    func testDisplaySettingsChangeViewDetailWithoutChangingMetersOrScene() throws {
        let renderer = OrbitalViewMetalRenderer()
        let scene = try makeThreeSpeakerScene()
        let frame = try SpeakerMeterFrame(
            timestamp: 1,
            levelsByChannel: [
                1: SpeakerMeterLevel(rms: 0.1, peak: 0.25, clip: false)
            ]
        )

        renderer.loadScene(scene)
        renderer.updateMeters(frame)
        let baselineInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        renderer.updateDisplaySettings(
            try OrbitalViewDisplaySettings(
                speakerShape: .sphere,
                speakerScale: 3.9,
                fogDensity: 60,
                showsSpeakerNumbers: true,
                showsHiddenLines: true
            )
        )
        let detailedInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(renderer.renderState.scene, scene)
        XCTAssertEqual(renderer.renderState.meters, frame)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 1)
        XCTAssertEqual(renderer.renderState.displaySettingsRevision, 1)
        XCTAssertEqual(detailedInputs.staticGeometry.map(\.id), baselineInputs.staticGeometry.map(\.id))
        XCTAssertEqual(detailedInputs.staticGeometry.map(\.channel), baselineInputs.staticGeometry.map(\.channel))
        XCTAssertEqual(detailedInputs.staticGeometry.map(\.quadRadius), baselineInputs.staticGeometry.map { $0.quadRadius * 2 })
    }

    func testNodeAnchoredSpeakersProjectFromImportedShellNodes() throws {
        let renderer = OrbitalViewMetalRenderer()
        let shell = try OrbitalViewSceneBuilder.makeDefaultOctahedronShell(radiusM: 2)
        let speaker = try OrbitalViewSpeaker(
            id: "speaker-top",
            channel: 1,
            label: "Top",
            anchor: .node(nodeID: "top", offsetM: 0.05),
            shape: .sphere(radiusM: 0.03)
        )
        let scene = try OrbitalViewSceneBuilder.makeMonitorScene(
            id: "node-render",
            shell: shell,
            speakers: [speaker]
        )

        renderer.loadScene(scene)
        let inputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(inputs.staticGeometry.count, 1)
        XCTAssertEqual(inputs.staticGeometry[0].projectedX, 0, accuracy: 1.0e-6)
        XCTAssertGreaterThan(inputs.staticGeometry[0].projectedY, 0)
    }

    func testFogDensityZeroDisablesFogingInSpeakerColorAlpha() throws {
        let renderer = OrbitalViewMetalRenderer()
        let direction = try UnitSphereDirection.normalized(x: 1, y: 1, z: 1)
        let speaker = try OrbitalViewSpeaker(
            id: "speaker-1",
            channel: 1,
            label: "Fey 01",
            anchor: .direction(direction, offsetM: 0.05),
            shape: .sphere(radiusM: 0.03)
        )

        let scene = try OrbitalViewSceneBuilder.makeMonitorScene(
            id: "render-fog-test",
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
            speakers: [speaker]
        )
        renderer.loadScene(scene)

        renderer.updateDisplaySettings(
            try OrbitalViewDisplaySettings(fogDensity: 0)
        )
        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [1: SpeakerMeterLevel(rms: 0.2, peak: 0.4, clip: false)]
            )
        )

        let noFog = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        XCTAssertEqual(noFog.speakers[0].color.w, 1.0, accuracy: 1e-6)

        renderer.updateDisplaySettings(
            try OrbitalViewDisplaySettings(fogDensity: 100)
        )
        let fullFog = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        XCTAssertLessThan(fullFog.speakers[0].color.w, 1.0)

        renderer.updateDisplaySettings(OrbitalViewDisplaySettings.default)
        let defaultFog = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        XCTAssertLessThan(defaultFog.speakers[0].color.w, noFog.speakers[0].color.w)
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

    func testMeterOnlyUpdatesDoNotChangeStaticSpeakerDrawInputs() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())

        let baselineInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.2, peak: 0.35, clip: false),
                    2: SpeakerMeterLevel(rms: 0.1, peak: 0.2, clip: false)
                ]
            )
        )
        let firstMeterInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 2,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.9, peak: 1, clip: true),
                    2: SpeakerMeterLevel(rms: 0.75, peak: 0.85, clip: false)
                ]
            )
        )
        let hotMeterInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(baselineInputs.staticGeometry, firstMeterInputs.staticGeometry)
        XCTAssertEqual(firstMeterInputs.staticGeometry, hotMeterInputs.staticGeometry)
        XCTAssertNotEqual(firstMeterInputs.colors, hotMeterInputs.colors)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 2)
    }

    func testCameraOnlyUpdatesDoNotChangeStaticSpeakerDrawInputs() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        let baselineInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        let camera = try OrbitalViewCameraState.preset(.isometric)
        renderer.updateCamera(camera)
        let cameraInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(baselineInputs.staticGeometry, cameraInputs.staticGeometry)
        XCTAssertEqual(renderer.renderState.camera?.target, .origin)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.cameraRevision, 1)
    }

    func testSpeakerDrawInputsPreserveChannelIdentityAndStableDimensions() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())

        let inputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(inputs.staticGeometry.map(\.id), ["speaker-1", "speaker-2", "speaker-3"])
        XCTAssertEqual(inputs.staticGeometry.map(\.channel), [1, 2, 3])
        XCTAssertEqual(inputs.staticGeometry.map(\.quadRadius), [0.045, 0.045, 0.045])
        XCTAssertEqual(inputs.positions.count, 3)
        XCTAssertEqual(inputs.colors.count, 3)
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

    private func makeThirtySpeakerScene() throws -> OrbitalViewSceneSpec {
        let speakers = try (1...30).map { channel in
            try makeSpeaker(
                id: "speaker-\(channel)",
                channel: channel,
                label: String(format: "Fey %02d", channel),
                direction: (
                    Double(channel),
                    Double((channel % 5) + 1),
                    Double((channel % 7) + 1)
                )
            )
        }

        return try OrbitalViewSceneBuilder.makeMonitorScene(
            id: "render-thirty-channel-test",
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
                try UnitSphereDirection.normalized(x: direction.0, y: direction.1, z: direction.2),
                offsetM: 0.05
            ),
            shape: .sphere(radiusM: 0.03)
        )
    }
}
