import XCTest
@testable import OrbitalViewCore
@testable import OrbitalViewViewerSupport

final class OrbitalViewViewerDemoContentTests: XCTestCase {
    func testDemoSceneUsesOneCubePerPhysicalSpeakerInChannelOrder() throws {
        let scene = try OrbitalViewViewerDemoContent.makeScene()

        XCTAssertEqual(scene.speakers.count, OrbitalViewViewerDemoContent.speakerCount)
        XCTAssertEqual(scene.speakers.map(\.channel), Array(1...OrbitalViewViewerDemoContent.speakerCount))
        XCTAssertEqual(scene.speakers.map(\.id).first, "speaker-01")
        XCTAssertEqual(scene.speakers.map(\.id).last, "speaker-30")
        XCTAssertTrue(scene.speakers.allSatisfy { $0.visualRole == .physicalSpeaker })
        XCTAssertTrue(scene.speakers.allSatisfy { $0.shape == .cube(edgeM: SpeakerShape.defaultSonicSphereEdgeM) })
    }

    func testDemoSpeakerMetersCoverEveryPhysicalChannel() throws {
        let meters = try OrbitalViewViewerDemoContent.makeSpeakerMeters(timestamp: 12.5)

        XCTAssertEqual(meters.levelsByChannel.keys.sorted(), Array(1...OrbitalViewViewerDemoContent.speakerCount))
        XCTAssertEqual(meters.source, .syntheticVisualStress)
        for level in meters.levelsByChannel.values {
            XCTAssertGreaterThanOrEqual(level.rms, 0)
            XCTAssertLessThanOrEqual(level.rms, 1)
            XCTAssertGreaterThanOrEqual(level.peak, 0)
            XCTAssertLessThanOrEqual(level.peak, 1)
        }
    }

    func testDemoObjectFramesAndMetersShareObjectIdentity() throws {
        let frames = try OrbitalViewViewerDemoContent.makeObjectFrames(timestamp: 42)
        let meters = try OrbitalViewViewerDemoContent.makeObjectMeters(timestamp: 42)

        XCTAssertEqual(frames.activeObjects.map(\.objectID), OrbitalViewViewerDemoContent.objectIDs)
        XCTAssertEqual(meters.levelsByObjectID.keys.sorted(), OrbitalViewViewerDemoContent.objectIDs)
        XCTAssertEqual(meters.source, .syntheticVisualStress)
        XCTAssertTrue(frames.activeObjects.allSatisfy {
            $0.trail.count == OrbitalViewViewerDemoContent.maxTrailPointsPerObject
        })
    }

    func testDemoVisualSettingsEnableCubeDiagnosticsAndObjectTrails() throws {
        let meterSettings = try OrbitalViewViewerDemoContent.makeMeterVisualSettings()
        let objectSettings = try OrbitalViewViewerDemoContent.makeObjectVisualSettings()

        XCTAssertEqual(meterSettings.style, .cubeScalarCenterBloom)
        XCTAssertEqual(meterSettings.colorScheme, .daftPunkBow)
        XCTAssertTrue(meterSettings.showsDiagnostics)
        XCTAssertTrue(objectSettings.trailsEnabled)
        XCTAssertTrue(objectSettings.glowTrailsEnabled)
        XCTAssertEqual(objectSettings.maxTrailPointsPerObject, OrbitalViewViewerDemoContent.maxTrailPointsPerObject)
    }

    func testVisualTelemetryStressSceneMatchesNoBackpressureProfile() throws {
        let scene = try OrbitalViewVisualTelemetryStressScene.makeScene()
        let speakerMeters = try OrbitalViewVisualTelemetryStressScene.makeSpeakerMeters(timestamp: 12.5)
        let objectFrames = try OrbitalViewVisualTelemetryStressScene.makeObjectFrames(timestamp: 12.5)
        let objectMeters = try OrbitalViewVisualTelemetryStressScene.makeObjectMeters(timestamp: 12.5)
        let performance = try OrbitalViewVisualTelemetryStressScene.makePerformanceSettings()
        let source = try OrbitalViewVisualTelemetryStressScene.makeSourceDescriptor()

        XCTAssertEqual(scene.speakers.count, 30)
        XCTAssertEqual(scene.speakers.map(\.channel), Array(1...30))
        XCTAssertEqual(scene.virtualObjects.count, OrbitalViewObjectFrameSet.maxObjectCount)
        XCTAssertTrue(scene.speakers.allSatisfy { $0.visualRole == .physicalSpeaker })
        XCTAssertTrue(scene.speakers.allSatisfy { $0.shape == .cube(edgeM: SpeakerShape.defaultSonicSphereEdgeM) })

        XCTAssertEqual(speakerMeters.levelsByChannel.keys.sorted(), Array(1...30))
        XCTAssertEqual(speakerMeters.source, source)
        XCTAssertEqual(speakerMeters.source.kind, .localLivestreamTestGenerator)
        XCTAssertEqual(speakerMeters.source.detail?.contains(
            OrbitalViewVisualTelemetryStressScene.localGeneratorProfileName
        ), true)

        XCTAssertEqual(objectFrames.activeObjects.count, OrbitalViewObjectFrameSet.maxObjectCount)
        XCTAssertEqual(objectFrames.maxActiveObjects, OrbitalViewObjectFrameSet.maxObjectCount)
        XCTAssertEqual(
            objectFrames.activeObjects.map(\.objectID),
            Array(1...OrbitalViewObjectFrameSet.maxObjectCount)
        )
        XCTAssertTrue(objectFrames.activeObjects.allSatisfy {
            $0.trail.count == OrbitalViewVisualTelemetryStressScene.maxTrailPointsPerObject
        })

        XCTAssertEqual(
            objectMeters.levelsByObjectID.keys.sorted(),
            Array(1...OrbitalViewObjectFrameSet.maxObjectCount)
        )
        XCTAssertEqual(objectMeters.source, source)

        XCTAssertEqual(performance.activeViewportFramesPerSecond, 60)
        XCTAssertEqual(
            OrbitalViewVisualTelemetryStressScene.incomingMeterFramesPerSecond,
            performance.activeViewportFramesPerSecond * 2
        )
        XCTAssertTrue(OrbitalViewVisualTelemetryStressScene.diagnosticsAreOpen)
    }

    func testStressDiagnosticsReportDisplayDropsWithoutAudioFailure() {
        let diagnostics = OrbitalViewVisualTelemetryStressScene.makeDroppedDisplayFrameDiagnostics()

        XCTAssertTrue(diagnostics.hasIssues)
        XCTAssertEqual(
            diagnostics.overloadActions,
            [
                .dropStaleFrames,
                .decimateDisplayRefresh,
                .keepLatestCompleteSnapshot,
                .setDiagnosticsOutsideRealtime
            ]
        )
        XCTAssertTrue(diagnostics.missingChannels.isEmpty)
        XCTAssertTrue(diagnostics.extraChannels.isEmpty)
        XCTAssertTrue(diagnostics.invalidChannels.isEmpty)
        XCTAssertTrue(diagnostics.duplicateChannels.isEmpty)
        XCTAssertTrue(diagnostics.replacedValues.isEmpty)
        XCTAssertTrue(diagnostics.clampedValues.isEmpty)
        XCTAssertFalse(diagnostics.timestampReplaced)
    }
}
