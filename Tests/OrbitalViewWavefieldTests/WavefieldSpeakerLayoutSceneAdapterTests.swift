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
        XCTAssertEqual(scene.speakers.last?.id, "fey-30-channel-30")
        XCTAssertEqual(scene.speakers.last?.label, "Fey 30")

        guard case .direction(let direction, let offsetM) = scene.speakers[0].anchor else {
            return XCTFail("Expected direction anchor")
        }

        XCTAssertEqual(direction.x, 0, accuracy: 1.0e-12)
        XCTAssertEqual(direction.y, 0.554700196225229, accuracy: 1.0e-12)
        XCTAssertEqual(direction.z, -0.832050294337844, accuracy: 1.0e-12)
        XCTAssertEqual(offsetM, 0.05)
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
        json = json.replacingOccurrences(of: "\"z\": \"front\"", with: "\"z\": \"back\"")

        XCTAssertThrowsError(
            try WavefieldSpeakerLayoutSceneAdapter().makeScene(data: Data(json.utf8))
        ) { error in
            XCTAssertEqual(
                error as? WavefieldSpeakerLayoutSceneAdapterError,
                .unsupportedAxes(["x": "right", "y": "up", "z": "back"])
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
}
