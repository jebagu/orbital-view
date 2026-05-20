import XCTest
@testable import OrbitalViewCore
@testable import OrbitalViewViewerSupport

final class OrbitalViewViewerDemoContentTests: XCTestCase {
    func testDemoSceneBuildsThirtyChannelMonitorScene() throws {
        let scene = try OrbitalViewViewerDemoContent.makeScene()

        XCTAssertEqual(scene.id, "orbital-viewer-demo")
        XCTAssertEqual(scene.coordinateSystem, .wavefield)
        XCTAssertEqual(scene.theme, .daftPunkBow)
        XCTAssertEqual(scene.speakers.count, 30)
        XCTAssertEqual(scene.speakers.map(\.channel), Array(1...30))
        XCTAssertEqual(scene.speakers.map(\.label).first, "Fey 01")
        XCTAssertTrue(scene.speakers.allSatisfy { speaker in
            if case .direction(_, let offsetM) = speaker.anchor {
                return offsetM == 0.05
            }
            return false
        })

        if case .parametric(let shell) = scene.shell {
            XCTAssertEqual(shell.kind, .geodesic)
            XCTAssertEqual(shell.radiusM, 1)
        } else {
            XCTFail("Viewer demo scene should use a parametric geodesic shell.")
        }
    }

    func testDemoMeterFrameCoversEveryViewerSpeakerChannel() throws {
        let frame = try OrbitalViewViewerDemoContent.makeMeterFrame(timestamp: 12.5)

        XCTAssertEqual(frame.timestamp, 12.5)
        XCTAssertEqual(frame.levelsByChannel.keys.sorted(), Array(1...30))
        XCTAssertTrue(frame.levelsByChannel.values.allSatisfy { level in
            level.rms >= 0 && level.rms <= 1 && level.peak >= level.rms && level.peak <= 1
        })
        XCTAssertEqual(frame.levelsByChannel[30]?.clip, true)
    }

    func testViewerModesTransformSpeakerProjectionWithoutChangingChannelIdentity() throws {
        let frontScene = try OrbitalViewViewerDemoContent.makeScene(viewMode: .frontElevation)
        let sideScene = try OrbitalViewViewerDemoContent.makeScene(viewMode: .sideElevation)

        XCTAssertEqual(frontScene.speakers.map(\.channel), sideScene.speakers.map(\.channel))
        XCTAssertEqual(frontScene.speakers.map(\.label), sideScene.speakers.map(\.label))

        let frontDirection = try XCTUnwrap(direction(from: frontScene.speakers[0]))
        let sideDirection = try XCTUnwrap(direction(from: sideScene.speakers[0]))

        XCTAssertEqual(frontDirection.x, 0, accuracy: 1.0e-12)
        XCTAssertEqual(frontDirection.y, 0.554700196225229, accuracy: 1.0e-12)
        XCTAssertEqual(frontDirection.z, -0.832050294337844, accuracy: 1.0e-12)
        XCTAssertEqual(sideDirection.x, -0.832050294337844, accuracy: 1.0e-12)
        XCTAssertEqual(sideDirection.y, 0.554700196225229, accuracy: 1.0e-12)
    }

    func testDemoObjectsMetersAndVisualSettingsShareObjectIDs() throws {
        let objectFrames = try OrbitalViewViewerDemoContent.makeObjectFrames(timestamp: 21, viewMode: .isometric)
        let objectMeters = try OrbitalViewViewerDemoContent.makeObjectMeters(timestamp: 21)
        let settings = try OrbitalViewViewerDemoContent.makeObjectVisualSettings()

        XCTAssertEqual(objectFrames.timestamp, 21)
        XCTAssertEqual(objectFrames.activeObjects.map(\.objectID), [1, 2, 3])
        XCTAssertEqual(objectMeters.levelsByObjectID.keys.sorted(), [1, 2, 3])
        XCTAssertEqual(objectFrames.maxTrailPointsPerObject, 8)
        XCTAssertTrue(settings.trailsEnabled)
        XCTAssertTrue(settings.glowTrailsEnabled)
    }

    private func direction(from speaker: OrbitalViewSpeaker) -> UnitSphereDirection? {
        if case .direction(let direction, _) = speaker.anchor {
            return direction
        }
        return nil
    }
}
