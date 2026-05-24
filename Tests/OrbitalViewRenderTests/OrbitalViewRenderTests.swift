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

        renderer.updateMeters(frame)
        XCTAssertEqual(renderer.renderState.scene, scene)
        XCTAssertEqual(renderer.renderState.meters, frame)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 1)
        XCTAssertEqual(renderer.renderState.meterVisualSettingsRevision, 0)
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

    func testObjectFrameAndMeterUpdatesStaySeparateFromSpeakerGeometry() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        let baselineSpeakers = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        let baselineSpeakerCacheKey = OrbitalViewMetalDrawPipeline.makeSpeakerStaticGeometryCacheKey(
            from: renderer.renderState
        )
        let objectFrame = try OrbitalViewObjectFrameSet(
            timestamp: 1,
            activeObjects: [
                makeObject(objectID: 7, direction: (1, 0, 0), width: 0.25)
            ]
        )

        renderer.updateObjects(objectFrame)
        let objectInputs = OrbitalViewMetalDrawPipeline.makeObjectDrawInputs(from: renderer.renderState)
        let speakersAfterObjects = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(baselineSpeakers.staticGeometry, speakersAfterObjects.staticGeometry)
        XCTAssertEqual(
            baselineSpeakerCacheKey,
            OrbitalViewMetalDrawPipeline.makeSpeakerStaticGeometryCacheKey(from: renderer.renderState)
        )
        XCTAssertEqual(objectInputs.staticObjects.map(\.objectID), [7])
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.objectFrameRevision, 1)
        XCTAssertEqual(renderer.renderState.objectMeterRevision, 0)

        renderer.updateObjectMeters(
            try ObjectMeterFrame(
                timestamp: 1.2,
                levelsByObjectID: [
                    7: ObjectMeterLevel(rms: 0.2, peak: 0.85, clip: false)
                ]
            )
        )
        let meteredObjectInputs = OrbitalViewMetalDrawPipeline.makeObjectDrawInputs(from: renderer.renderState)

        XCTAssertEqual(objectInputs.staticObjects, meteredObjectInputs.staticObjects)
        XCTAssertNotEqual(objectInputs.colors, meteredObjectInputs.colors)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 0)
        XCTAssertEqual(renderer.renderState.objectFrameRevision, 1)
        XCTAssertEqual(renderer.renderState.objectMeterRevision, 1)
    }

    func testObjectDisappearRemovesObjectDrawInputAndTrailOwnership() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.updateObjectVisualSettings(
            try ObjectVisualSettings(trailsEnabled: true, maxTrailPointsPerObject: 3)
        )
        renderer.updateObjects(
            try OrbitalViewObjectFrameSet(
                timestamp: 1,
                activeObjects: [
                    makeObject(
                        objectID: 4,
                        direction: (1, 0, 0),
                        trailDirections: [(0, 1, 0), (0, 0, 1), (-1, 0, 0)]
                    )
                ],
                maxTrailPointsPerObject: 3
            )
        )

        let activeInputs = OrbitalViewMetalDrawPipeline.makeObjectDrawInputs(from: renderer.renderState)
        XCTAssertEqual(activeInputs.staticObjects.map(\.objectID), [4])
        XCTAssertEqual(activeInputs.objects.count, 4)
        XCTAssertEqual(activeInputs.objects.filter { $0.isTrailSample }.count, 3)

        renderer.updateObjects(try OrbitalViewObjectFrameSet(timestamp: 2, activeObjects: []))
        let emptyInputs = OrbitalViewMetalDrawPipeline.makeObjectDrawInputs(from: renderer.renderState)

        XCTAssertTrue(emptyInputs.objects.isEmpty)
        XCTAssertTrue(emptyInputs.staticObjects.isEmpty)
        XCTAssertEqual(renderer.renderState.objectFrameRevision, 2)
    }

    func testTrailsAndGlowTrailsShareCappedObjectDrawInputs() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.updateObjectVisualSettings(
            try ObjectVisualSettings(
                trailsEnabled: true,
                maxTrailPointsPerObject: 2,
                glowTrailsEnabled: true,
                glowTrailWidth: 0.12
            )
        )
        renderer.updateObjects(
            try OrbitalViewObjectFrameSet(
                timestamp: 1,
                activeObjects: [
                    makeObject(
                        objectID: 9,
                        direction: (1, 0, 0),
                        trailDirections: [(0, 1, 0), (0, 0, 1), (-1, 0, 0), (0, -1, 0)]
                    )
                ],
                maxTrailPointsPerObject: 4
            )
        )

        let inputs = OrbitalViewMetalDrawPipeline.makeObjectDrawInputs(from: renderer.renderState)

        XCTAssertEqual(inputs.staticObjects.map(\.objectID), [9])
        XCTAssertEqual(inputs.objects.count, 3)
        XCTAssertEqual(inputs.objects.filter { $0.isTrailSample }.count, 2)
        XCTAssertTrue(inputs.objects.filter { $0.isTrailSample }.allSatisfy { $0.quadRadius <= 0.12 })
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

    func testMeterColorSchemeSettingsAffectEverySpeakerColorWithoutChangingGeometry() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
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

        XCTAssertEqual(renderer.renderState.meterVisualSettings.style, .cubeScalarCenterBloom)
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

    func testSpeakerDrawInputsExposeInstancedCubePrismMeshAndMeterMaterial() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(
            try makeThreeSpeakerScene(
                speaker2Shape: SpeakerShape.sonicSphereRectangularPrism(edgeM: 0.06, zScale: 1.75)
            )
        )
        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.25, peak: 0.6, clip: false),
                    2: SpeakerMeterLevel(rms: 0.5, peak: 0.8, clip: true)
                ]
            )
        )

        let inputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(inputs.staticGeometry.map(\.meshVertexCount), [36, 36, 36])
        XCTAssertEqual(inputs.staticGeometry[0].meshDepthScale, 1, accuracy: 0.0001)
        XCTAssertEqual(inputs.staticGeometry[1].meshDepthScale, 1.75, accuracy: 0.0001)
        XCTAssertEqual(inputs.staticGeometry[2].meshDepthScale, 1, accuracy: 0.0001)
        XCTAssertEqual(inputs.positions[1].y, 0, accuracy: 0.0001)
        XCTAssertEqual(inputs.positions[2].y, 0.72, accuracy: 0.0001)
        XCTAssertEqual(inputs.orientations[0], SIMD4<Float>(1, 0, 0, 1))
        XCTAssertEqual(inputs.orientations[1], SIMD4<Float>(0, 0, 1, 1.75))
        XCTAssertEqual(inputs.orientations[2], SIMD4<Float>(0, 1, 0, 1))
        XCTAssertEqual(inputs.materials.count, 3)
        let speaker1Scalars = SpeakerCubeVUScalars(rawRms: 0.25, settings: .default)
        let speaker2Scalars = SpeakerCubeVUScalars(rawRms: 0.5, settings: .default)
        XCTAssertEqual(inputs.materials[0].x, speaker1Scalars.displayVuScalar, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[0].y, speaker1Scalars.hotScalar, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[0].z, speaker1Scalars.paletteHeat, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[0].w, 0, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[1].x, speaker2Scalars.displayVuScalar, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[1].y, speaker2Scalars.hotScalar, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[1].z, speaker2Scalars.paletteHeat, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[1].w, 1, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[2].x, 0, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[2].y, 0, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[2].z, 0, accuracy: 0.0001)
        XCTAssertEqual(inputs.materials[2].w, 0, accuracy: 0.0001)
    }

    func testOffscreenCenterBloomRespondsToHotAndClipMetersWithoutChangingGeometry() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw XCTSkip("Metal device unavailable; skipping center-bloom pixel probe.")
        }

        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        renderer.updateMeterVisualSettings(
            try SpeakerMeterVisualSettings(style: .cubeScalarCenterBloom, colorScheme: .daftPunkBow)
        )
        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.02, peak: 0.04, clip: false),
                    2: SpeakerMeterLevel(rms: 0.02, peak: 0.04, clip: false),
                    3: SpeakerMeterLevel(rms: 0.02, peak: 0.04, clip: false)
                ]
            )
        )
        let quietInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        let quietMetrics = pixelMetrics(for: try renderer.renderOffscreen(device: device, width: 96, height: 96))

        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 2,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.88, peak: 0.96, clip: false),
                    2: SpeakerMeterLevel(rms: 0.02, peak: 0.04, clip: false),
                    3: SpeakerMeterLevel(rms: 0.02, peak: 0.04, clip: false)
                ]
            )
        )
        let hotInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        let hotMetrics = pixelMetrics(for: try renderer.renderOffscreen(device: device, width: 96, height: 96))

        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 3,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.88, peak: 1, clip: true),
                    2: SpeakerMeterLevel(rms: 0.02, peak: 0.04, clip: false),
                    3: SpeakerMeterLevel(rms: 0.02, peak: 0.04, clip: false)
                ]
            )
        )
        let clipInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        let clipMetrics = pixelMetrics(for: try renderer.renderOffscreen(device: device, width: 96, height: 96))

        XCTAssertEqual(quietInputs.staticGeometry, hotInputs.staticGeometry)
        XCTAssertEqual(hotInputs.staticGeometry, clipInputs.staticGeometry)
        XCTAssertEqual(quietInputs.positions, hotInputs.positions)
        XCTAssertEqual(hotInputs.positions, clipInputs.positions)
        XCTAssertEqual(quietInputs.orientations, hotInputs.orientations)
        XCTAssertEqual(hotInputs.orientations, clipInputs.orientations)
        XCTAssertNotEqual(quietInputs.materials, hotInputs.materials)
        XCTAssertNotEqual(hotInputs.materials, clipInputs.materials)
        XCTAssertEqual(quietMetrics.bounds, hotMetrics.bounds)
        XCTAssertEqual(hotMetrics.bounds, clipMetrics.bounds)
        XCTAssertGreaterThan(hotMetrics.totalIntensity, quietMetrics.totalIntensity)
        XCTAssertGreaterThan(clipMetrics.redIntensity, hotMetrics.redIntensity)
    }

    func testDaftPunkBowRampUniformChangesOffscreenColorWithoutChangingSpeakerGeometry() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw XCTSkip("Metal device unavailable; skipping ramp uniform pixel probe.")
        }

        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.82, peak: 0.94, clip: false),
                    2: SpeakerMeterLevel(rms: 0.2, peak: 0.36, clip: false)
                ]
            )
        )
        renderer.updateMeterVisualSettings(
            try SpeakerMeterVisualSettings(style: .cubeScalarCenterBloom, colorScheme: .daftPunkBow)
        )
        let bowInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        let bowMetrics = pixelMetrics(for: try renderer.renderOffscreen(device: device, width: 96, height: 96))

        renderer.updateMeterVisualSettings(
            try SpeakerMeterVisualSettings(style: .cubeScalarCenterBloom, colorScheme: .monochrome)
        )
        let monochromeInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        let monochromeMetrics = pixelMetrics(for: try renderer.renderOffscreen(device: device, width: 96, height: 96))

        XCTAssertEqual(bowInputs.staticGeometry, monochromeInputs.staticGeometry)
        XCTAssertEqual(bowInputs.positions, monochromeInputs.positions)
        XCTAssertEqual(bowInputs.orientations, monochromeInputs.orientations)
        XCTAssertNotEqual(bowInputs.colors, monochromeInputs.colors)
        XCTAssertNotEqual(bowMetrics.redIntensity, monochromeMetrics.redIntensity)
        XCTAssertNotEqual(bowMetrics.greenIntensity, monochromeMetrics.greenIntensity)
    }

    func testRepeatedObjectRenderReusesMetalBufferCapacity() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw XCTSkip("Metal device unavailable; skipping retained buffer reuse check.")
        }

        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThirtySpeakerScene())
        renderer.updateObjectVisualSettings(
            try ObjectVisualSettings(trailsEnabled: true, maxTrailPointsPerObject: 3, glowTrailsEnabled: true)
        )
        renderer.updateObjects(
            try OrbitalViewObjectFrameSet(
                timestamp: 1,
                activeObjects: makeObjectSet(count: 128, trailCount: 3),
                maxTrailPointsPerObject: 3
            )
        )

        _ = try renderer.renderOffscreen(device: device, width: 96, height: 96)
        let firstAllocationCount = try renderer.debugBufferAllocationCount(device: device)
        _ = try renderer.renderOffscreen(device: device, width: 96, height: 96)
        let secondAllocationCount = try renderer.debugBufferAllocationCount(device: device)

        XCTAssertEqual(firstAllocationCount, secondAllocationCount)
    }

    func testMeterOnlyUpdatesDoNotChangeStaticSpeakerDrawInputs() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        let baselineShapes = renderer.renderState.scene?.speakers.map(\.shape)

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
        XCTAssertEqual(renderer.renderState.scene?.speakers.map(\.shape), baselineShapes)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterRevision, 2)
    }

    func testSpeakerStaticGeometryCacheKeyIsStableForMeterSettingsAndCameraOnlyUpdates() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        let baselineKey = OrbitalViewMetalDrawPipeline.makeSpeakerStaticGeometryCacheKey(from: renderer.renderState)

        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.2, peak: 0.35, clip: false),
                    2: SpeakerMeterLevel(rms: 0.1, peak: 0.2, clip: false)
                ]
            )
        )
        XCTAssertEqual(
            baselineKey,
            OrbitalViewMetalDrawPipeline.makeSpeakerStaticGeometryCacheKey(from: renderer.renderState)
        )

        renderer.updateMeterVisualSettings(
            try SpeakerMeterVisualSettings(visualGainDB: 4, style: .checkerPulseRingAndDiagonalWave)
        )
        XCTAssertEqual(
            baselineKey,
            OrbitalViewMetalDrawPipeline.makeSpeakerStaticGeometryCacheKey(from: renderer.renderState)
        )

        renderer.updateCamera(try OrbitalViewCameraState.preset(.isometric))
        XCTAssertEqual(
            baselineKey,
            OrbitalViewMetalDrawPipeline.makeSpeakerStaticGeometryCacheKey(from: renderer.renderState)
        )
    }

    func testSpeakerStaticGeometryCacheKeyDiffersForCubeAndRectangularPrismShapes() throws {
        let cubeRenderer = OrbitalViewMetalRenderer()
        cubeRenderer.loadScene(try makeThreeSpeakerScene())

        let prismRenderer = OrbitalViewMetalRenderer()
        prismRenderer.loadScene(
            try makeThreeSpeakerScene(
                speaker2Shape: SpeakerShape.sonicSphereRectangularPrism(edgeM: 0.06, zScale: 1.75)
            )
        )

        let cubeKey = OrbitalViewMetalDrawPipeline.makeSpeakerStaticGeometryCacheKey(from: cubeRenderer.renderState)
        let prismKey = OrbitalViewMetalDrawPipeline.makeSpeakerStaticGeometryCacheKey(from: prismRenderer.renderState)

        XCTAssertEqual(cubeKey.entries.map(\.id), prismKey.entries.map(\.id))
        XCTAssertEqual(cubeKey.entries.map(\.channel), prismKey.entries.map(\.channel))
        XCTAssertNotEqual(cubeKey, prismKey)
        XCTAssertEqual(cubeKey.entries[1].shape, try SpeakerShape.sonicSphereDefault())
        XCTAssertEqual(
            prismKey.entries[1].shape,
            try SpeakerShape.sonicSphereRectangularPrism(edgeM: 0.06, zScale: 1.75)
        )
    }

    func testChannelToInstanceMapPreservesSceneInstanceOrderAndMeterIdentity() throws {
        let renderer = OrbitalViewMetalRenderer()
        let speakers = try [
            makeSpeaker(id: "speaker-7", channel: 7, label: "Fey 07", direction: (1, 0, 0)),
            makeSpeaker(id: "speaker-2", channel: 2, label: "Fey 02", direction: (0, 1, 0)),
            makeSpeaker(id: "speaker-30", channel: 30, label: "Fey 30", direction: (0, 0, 1))
        ]
        renderer.loadScene(
            try OrbitalViewSceneBuilder.makeMonitorScene(
                id: "render-channel-instance-map",
                shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
                speakers: speakers
            )
        )
        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [
                    2: SpeakerMeterLevel(rms: 0.2, peak: 0.42, clip: false),
                    7: SpeakerMeterLevel(rms: 0.7, peak: 0.77, clip: false),
                    30: SpeakerMeterLevel(rms: 0.3, peak: 0.3, clip: true),
                    99: SpeakerMeterLevel(rms: 0.99, peak: 0.99, clip: false)
                ]
            )
        )

        let inputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)
        let channelToInstance = inputs.channelToInstanceIndex

        XCTAssertEqual(inputs.staticGeometry.map(\.channel), [7, 2, 30])
        XCTAssertEqual(channelToInstance, [7: 0, 2: 1, 30: 2])
        XCTAssertEqual(inputs.speakers[channelToInstance[2]!].meterLevel?.peak, 0.42)
        XCTAssertEqual(inputs.speakers[channelToInstance[7]!].meterLevel?.peak, 0.77)
        XCTAssertEqual(inputs.speakers[channelToInstance[30]!].meterLevel?.clip, true)
        XCTAssertNil(channelToInstance[99])
    }

    func testSpeakerBuffersDoNotAllocateForMeterSettingsOrCameraOnlyRenders() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw XCTSkip("Metal device unavailable; skipping speaker buffer cache check.")
        }

        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())

        _ = try renderer.renderOffscreen(device: device, width: 96, height: 96)
        let baselineAllocationCount = try renderer.debugBufferAllocationCount(device: device)

        renderer.updateMeters(
            try SpeakerMeterFrame(
                timestamp: 1,
                levelsByChannel: [
                    1: SpeakerMeterLevel(rms: 0.1, peak: 0.2, clip: false),
                    2: SpeakerMeterLevel(rms: 0.3, peak: 0.4, clip: false)
                ]
            )
        )
        _ = try renderer.renderOffscreen(device: device, width: 96, height: 96)
        XCTAssertEqual(try renderer.debugBufferAllocationCount(device: device), baselineAllocationCount)

        renderer.updateMeterVisualSettings(try SpeakerMeterVisualSettings(visualGainDB: 5, facePixels: 12))
        _ = try renderer.renderOffscreen(device: device, width: 96, height: 96)
        XCTAssertEqual(try renderer.debugBufferAllocationCount(device: device), baselineAllocationCount)

        renderer.updateCamera(try OrbitalViewCameraState.preset(.isometric))
        _ = try renderer.renderOffscreen(device: device, width: 96, height: 96)
        XCTAssertEqual(try renderer.debugBufferAllocationCount(device: device), baselineAllocationCount)

        renderer.loadScene(try makeThirtySpeakerScene())
        _ = try renderer.renderOffscreen(device: device, width: 96, height: 96)
        XCTAssertGreaterThan(try renderer.debugBufferAllocationCount(device: device), baselineAllocationCount)
    }

    func testSpeakerZScaleSettingDoesNotMutateSceneSpeakerShape() throws {
        let renderer = OrbitalViewMetalRenderer()
        renderer.loadScene(try makeThreeSpeakerScene())
        let baselineShapes = renderer.renderState.scene?.speakers.map(\.shape)
        let baselineInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        renderer.updateMeterVisualSettings(try SpeakerMeterVisualSettings(speakerZScale: 2))
        let zScaledSettingsInputs = OrbitalViewMetalDrawPipeline.makeSpeakerDrawInputs(from: renderer.renderState)

        XCTAssertEqual(renderer.renderState.scene?.speakers.map(\.shape), baselineShapes)
        XCTAssertEqual(baselineInputs.staticGeometry, zScaledSettingsInputs.staticGeometry)
        XCTAssertEqual(renderer.renderState.structuralRevision, 1)
        XCTAssertEqual(renderer.renderState.meterVisualSettingsRevision, 1)
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
        XCTAssertEqual(inputs.materials.count, 3)
        XCTAssertEqual(inputs.orientations.count, 3)
    }

    private struct PixelBounds: Equatable {
        let minX: Int
        let minY: Int
        let maxX: Int
        let maxY: Int
    }

    private struct FramePixelMetrics: Equatable {
        let bounds: PixelBounds?
        let totalIntensity: Int
        let redIntensity: Int
        let greenIntensity: Int
        let blueIntensity: Int
    }

    private func pixelMetrics(for frame: OrbitalViewOffscreenFrame) -> FramePixelMetrics {
        var minX = frame.width
        var minY = frame.height
        var maxX = -1
        var maxY = -1
        var totalIntensity = 0
        var redIntensity = 0
        var greenIntensity = 0
        var blueIntensity = 0

        for y in 0..<frame.height {
            for x in 0..<frame.width {
                let index = ((y * frame.width) + x) * 4
                let blue = Int(frame.bgra8Bytes[index])
                let green = Int(frame.bgra8Bytes[index + 1])
                let red = Int(frame.bgra8Bytes[index + 2])
                let pixelIntensity = red + green + blue
                guard pixelIntensity > 0 else {
                    continue
                }

                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
                totalIntensity += pixelIntensity
                redIntensity += red
                greenIntensity += green
                blueIntensity += blue
            }
        }

        let bounds: PixelBounds? = maxX >= 0
            ? PixelBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
            : nil
        return FramePixelMetrics(
            bounds: bounds,
            totalIntensity: totalIntensity,
            redIntensity: redIntensity,
            greenIntensity: greenIntensity,
            blueIntensity: blueIntensity
        )
    }

    private func makeScene() throws -> OrbitalViewSceneSpec {
        let direction = try UnitSphereDirection(x: 1, y: 0, z: 0)
        let speaker = try OrbitalViewSpeaker(
            id: "speaker-1",
            channel: 1,
            label: "Fey 01",
            anchor: .direction(direction, offsetM: 0.05),
            shape: try SpeakerShape.sonicSphereDefault()
        )

        return try OrbitalViewSceneBuilder.makeMonitorScene(
            id: "render-test",
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
            speakers: [speaker]
        )
    }

    private func makeThreeSpeakerScene(speaker2Shape: SpeakerShape? = nil) throws -> OrbitalViewSceneSpec {
        let speakers = try [
            makeSpeaker(id: "speaker-1", channel: 1, label: "Fey 01", direction: (1, 0, 0)),
            makeSpeaker(
                id: "speaker-2",
                channel: 2,
                label: "Fey 02",
                direction: (0, 1, 0),
                shape: speaker2Shape
            ),
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
        direction: (Double, Double, Double),
        shape: SpeakerShape? = nil
    ) throws -> OrbitalViewSpeaker {
        try OrbitalViewSpeaker(
            id: id,
            channel: channel,
            label: label,
            anchor: .direction(
                try UnitSphereDirection.normalized(x: direction.0, y: direction.1, z: direction.2),
                offsetM: 0.05
            ),
            shape: try shape ?? SpeakerShape.sonicSphereDefault()
        )
    }

    private func makeObject(
        objectID: Int,
        direction: (Double, Double, Double),
        width: Float = 0,
        trailDirections: [(Double, Double, Double)] = []
    ) throws -> OrbitalViewObjectFrame {
        try OrbitalViewObjectFrame(
            objectID: objectID,
            label: "Object \(objectID)",
            pose: UnitSphereDirection.normalized(x: direction.0, y: direction.1, z: direction.2),
            width: width,
            trail: trailDirections.map {
                try UnitSphereDirection.normalized(x: $0.0, y: $0.1, z: $0.2)
            }
        )
    }

    private func makeObjectSet(count: Int, trailCount: Int) throws -> [OrbitalViewObjectFrame] {
        try (1...count).map { objectID in
            let trail = (0..<trailCount).map { index -> (Double, Double, Double) in
                (
                    Double((objectID + index) % 11 + 1),
                    Double((objectID + index) % 7 + 1),
                    Double((objectID + index) % 5 + 1)
                )
            }
            return try makeObject(
                objectID: objectID,
                direction: (Double(objectID % 13 + 1), Double(objectID % 9 + 1), Double(objectID % 5 + 1)),
                width: Float(objectID % 4) * 0.1,
                trailDirections: trail
            )
        }
    }
}
