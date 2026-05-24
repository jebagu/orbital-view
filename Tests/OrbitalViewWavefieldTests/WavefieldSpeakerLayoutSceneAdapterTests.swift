import XCTest
@testable import OrbitalViewCore
@testable import OrbitalViewWavefield

final class WavefieldSpeakerLayoutSceneAdapterTests: XCTestCase {
    func testFeyLayoutMapsToOrbitalViewSceneWithoutChannelReorder() throws {
        let scene = try WavefieldSpeakerLayoutSceneAdapter().makeScene(layoutURL: feyFixtureURL())

        XCTAssertEqual(scene.id, "fey-30")
        XCTAssertEqual(scene.coordinateSystem, .wavefield)
        XCTAssertEqual(scene.speakers.count, 30)
        XCTAssertEqual(scene.speakers.map(\.channel), Array(1...30))
        XCTAssertEqual(scene.speakers.first?.id, "fey-30-channel-1")
        XCTAssertEqual(scene.speakers.first?.label, "Fey 01")
        XCTAssertEqual(scene.speakers.first?.shape, .cube(edgeM: 0.06))
        XCTAssertEqual(scene.speakers.last?.id, "fey-30-channel-30")
        XCTAssertEqual(scene.speakers.last?.label, "Fey 30")

        guard case .direction(let direction, let offsetM) = scene.speakers[0].anchor else {
            return XCTFail("Expected direction anchor")
        }

        XCTAssertEqual(direction.x, 0, accuracy: 1.0e-12)
        XCTAssertEqual(direction.y, 0.554700196225229, accuracy: 1.0e-12)
        XCTAssertEqual(direction.z, -0.832050294337844, accuracy: 1.0e-12)
        XCTAssertLessThan(direction.z, 0)
        XCTAssertEqual(offsetM, 0.05)
    }

    func testFeyLayoutUsesZUpRingNumbering() throws {
        let scene = try WavefieldSpeakerLayoutSceneAdapter().makeScene(layoutURL: feyFixtureURL())

        let expectedChannelsByRing = [
            1...5,
            6...10,
            11...15,
            16...20,
            21...25,
            26...30
        ].map(Array.init)

        let zValuesByRing = try expectedChannelsByRing.map { channels in
            try channels.map { try direction(for: $0, in: scene).z }
        }

        XCTAssertEqual(expectedChannelsByRing.flatMap { $0 }, Array(1...30))
        for (lowerRing, upperRing) in zip(zValuesByRing, zValuesByRing.dropFirst()) {
            XCTAssertLessThan(lowerRing.max() ?? 0, upperRing.min() ?? 0)
        }
    }

    func testSceneUsesCallerProvidedShell() throws {
        let shell = try OrbitalViewSceneBuilder.makeDefaultOctahedronShell(radiusM: 2)
        let scene = try WavefieldSpeakerLayoutSceneAdapter().makeScene(
            layoutURL: feyFixtureURL(),
            shell: shell
        )

        XCTAssertEqual(scene.shell, shell)
    }

    func testRejectsUnsupportedAxes() throws {
        var json = try String(contentsOf: feyFixtureURL(), encoding: .utf8)
        json = json.replacingOccurrences(of: "\"z\": \"up\"", with: "\"z\": \"front\"")

        XCTAssertThrowsError(
            try WavefieldSpeakerLayoutSceneAdapter().makeScene(data: Data(json.utf8))
        ) { error in
            XCTAssertEqual(
                error as? WavefieldSpeakerLayoutSceneAdapterError,
                .unsupportedAxes(["x": "right", "y": "front", "z": "front"])
            )
        }
    }

    func testRejectsInvalidMainSpeakerCount() throws {
        var json = try String(contentsOf: feyFixtureURL(), encoding: .utf8)
        json = json.replacingOccurrences(of: "\"mainSpeakerCount\": 30", with: "\"mainSpeakerCount\": 29")

        XCTAssertThrowsError(
            try WavefieldSpeakerLayoutSceneAdapter().makeScene(data: Data(json.utf8))
        ) { error in
            XCTAssertEqual(
                error as? WavefieldSpeakerLayoutSceneAdapterError,
                .invalidMainSpeakerCount(expected: 30, actual: 29)
            )
        }
    }

    func testRejectsInvalidSpeakerDirection() throws {
        var json = try String(contentsOf: feyFixtureURL(), encoding: .utf8)
        json = json.replacingOccurrences(
            of: "\"x\": 0,\n        \"y\": 0.554700196225229,\n        \"z\": -0.832050294337844",
            with: "\"x\": 2,\n        \"y\": 0,\n        \"z\": 0"
        )

        XCTAssertThrowsError(
            try WavefieldSpeakerLayoutSceneAdapter().makeScene(data: Data(json.utf8))
        ) { error in
            guard case .invalidSpeakerPosition(channel: 1, let reason) = error as? WavefieldSpeakerLayoutSceneAdapterError else {
                return XCTFail("Expected invalid speaker position, got \(error)")
            }
            XCTAssertTrue(reason.contains("invalidUnitVectorMagnitude"))
        }
    }

    private func feyFixtureURL() -> URL {
        guard let url = Bundle.module.url(
            forResource: "fey-30-layout",
            withExtension: "json"
        ) else {
            XCTFail("Missing Fey fixture")
            return URL(fileURLWithPath: "/missing-fey-fixture.json")
        }
        return url
    }

    private func direction(for channel: Int, in scene: OrbitalViewSceneSpec) throws -> UnitSphereDirection {
        guard let speaker = scene.speakers.first(where: { $0.channel == channel }) else {
            throw XCTSkip("Missing channel \(channel)")
        }

        guard case .direction(let direction, _) = speaker.anchor else {
            throw XCTSkip("Expected direction anchor for channel \(channel)")
        }

        return direction
    }
}
