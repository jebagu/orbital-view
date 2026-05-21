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
}
