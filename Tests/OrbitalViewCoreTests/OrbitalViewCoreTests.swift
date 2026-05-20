import XCTest
@testable import OrbitalViewCore

final class OrbitalViewCoreTests: XCTestCase {
    func testUnitSphereDirectionValidation() throws {
        let direction = try UnitSphereDirection(x: 1, y: 0, z: 0)
        XCTAssertEqual(direction.x, 1)

        XCTAssertThrowsError(try UnitSphereDirection(x: .nan, y: 0, z: 0)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .nonFiniteValue(field: "x"))
        }

        XCTAssertThrowsError(try UnitSphereDirection(x: 0, y: 0, z: 0)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .zeroVector)
        }

        XCTAssertThrowsError(try UnitSphereDirection(x: 2, y: 0, z: 0)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .invalidUnitVectorMagnitude(2))
        }

        let normalized = try UnitSphereDirection.normalized(x: 2, y: 0, z: 0)
        XCTAssertEqual(normalized, try UnitSphereDirection(x: 1, y: 0, z: 0))
    }

    func testSpeakerValidationRejectsInvalidValues() throws {
        let direction = try UnitSphereDirection(x: 1, y: 0, z: 0)

        XCTAssertThrowsError(
            try OrbitalViewSpeaker(
                id: "s0",
                channel: 0,
                label: "Fey 00",
                anchor: .direction(direction, offsetM: 0.05),
                shape: .sphere(radiusM: 0.02)
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .invalidChannel(0))
        }

        XCTAssertThrowsError(
            try OrbitalViewSpeaker(
                id: "s1",
                channel: 1,
                label: " ",
                anchor: .direction(direction, offsetM: 0.05),
                shape: .sphere(radiusM: 0.02)
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .emptyLabel)
        }

        XCTAssertThrowsError(
            try OrbitalViewSpeaker(
                id: "s1",
                channel: 1,
                label: "Fey 01",
                anchor: .edge(edgeID: "e1", t: 1.5, offsetM: 0.05),
                shape: .sphere(radiusM: 0.02)
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "speaker.anchor.t", value: 1.5, validRange: "0...1")
            )
        }

        XCTAssertThrowsError(
            try OrbitalViewSpeaker(
                id: "s1",
                channel: 1,
                label: "Fey 01",
                anchor: .direction(direction, offsetM: 0.05),
                shape: .sphere(radiusM: 0)
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .nonPositiveValue(field: "speaker.shape.radiusM", value: 0)
            )
        }
    }

    func testImportedShellReferenceValidation() throws {
        let nodes = try [
            ShellNode(id: "n1", position: OrbitalViewVector3(x: 0, y: 1, z: 0)),
            ShellNode(id: "n2", position: OrbitalViewVector3(x: 1, y: 0, z: 0)),
            ShellNode(id: "n3", position: OrbitalViewVector3(x: 0, y: 0, z: 1))
        ]

        XCTAssertThrowsError(
            try OrbitalViewImportedShellGeometry(
                radiusM: 1,
                nodes: nodes,
                edges: [
                    try ShellEdge(id: "e1", a: "n1", b: "missing")
                ],
                faces: []
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .unknownNodeID("missing"))
        }

        XCTAssertThrowsError(try ShellFace(id: "f1", nodes: ["n1", "n2"])) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidFaceReference(faceID: "f1", reason: "faces must reference at least three nodes")
            )
        }

        XCTAssertNoThrow(
            try OrbitalViewImportedShellGeometry(
                radiusM: 1,
                nodes: nodes,
                edges: [
                    try ShellEdge(id: "e1", a: "n1", b: "n2")
                ],
                faces: [
                    try ShellFace(id: "f1", nodes: ["n1", "n2", "n3"])
                ]
            )
        )
    }

    func testMeterFramePreservesChannelIdentity() throws {
        let low = try SpeakerMeterLevel(rms: 0.2, peak: 0.3, clip: false)
        let hot = try SpeakerMeterLevel(rms: 0.9, peak: 1.0, clip: true)
        let frame = try SpeakerMeterFrame(timestamp: 42, levelsByChannel: [1: low, 30: hot])

        XCTAssertEqual(frame.levelsByChannel[1], low)
        XCTAssertEqual(frame.levelsByChannel[30], hot)
        XCTAssertNil(frame.levelsByChannel[2])

        XCTAssertThrowsError(try SpeakerMeterLevel(rms: .nan, peak: 0, clip: false)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .nonFiniteValue(field: "meter.rms"))
        }

        XCTAssertThrowsError(try SpeakerMeterFrame(timestamp: 0, levelsByChannel: [0: low])) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .invalidChannel(0))
        }
    }

    func testSpeakerMeterVisualSettingsValidateDisplayGainAndStyle() throws {
        let defaults = SpeakerMeterVisualSettings.default
        XCTAssertEqual(defaults.visualGainDB, 0)
        XCTAssertEqual(defaults.style, .checkerPulseRingAndDiagonalWave)
        XCTAssertEqual(defaults.colorScheme, .kimiPurple)
        XCTAssertEqual(defaults.ringFrontDensity, 3.3)
        XCTAssertEqual(defaults.tileDetail, 10)
        XCTAssertEqual(defaults.idleTint, 0.36)
        XCTAssertEqual(defaults.memoryCarryover, 0.58)
        XCTAssertEqual(defaults.checkerBandVelocity, 0.826)
        XCTAssertEqual(defaults.checkerBandWidth, 0.831)
        XCTAssertEqual(
            SpeakerMeterVisualStyle.builtInStyles,
            [.checkerPulseRingAndDiagonalWave, .prismGlow, .warmPulse, .coolPulse]
        )

        let hot = try SpeakerMeterVisualSettings(visualGainDB: 24, style: .warmPulse)
        XCTAssertEqual(hot.visualGainDB, 24)
        XCTAssertEqual(hot.style.displayName, "Warm Pulse")
        XCTAssertEqual(hot.colorScheme, .kimiPurple)

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(visualGainDB: .nan)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .nonFiniteValue(field: "meterVisual.visualGainDB")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(visualGainDB: 24.5)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.visualGainDB", value: 24.5, validRange: "-24...24")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(tileDetail: 2)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.tileDetail", value: 2, validRange: "4...32")
            )
        }
    }

    func testSpeakerMeterVisualStyleCodableRoundTrip() throws {
        let settings = try SpeakerMeterVisualSettings(visualGainDB: -6, style: .customTBD)
        let encoded = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(SpeakerMeterVisualSettings.self, from: encoded)

        XCTAssertEqual(decoded, settings)

        let invalidJSON = """
        {
            "visualGainDB": 99,
            "style": "checkerPulseRingAndDiagonalWave",
            "colorScheme": "kimiPurple",
            "ringFrontDensity": 3.3,
            "bandSoftness": 0.85,
            "tileDetail": 10,
            "idleTint": 0.36,
            "memoryCarryover": 0.58,
            "checkerBandVelocity": 0.826,
            "checkerBandWidth": 0.831
        }
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(SpeakerMeterVisualSettings.self, from: invalidJSON)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.visualGainDB", value: 99, validRange: "-24...24")
            )
        }
    }

    func testCameraPresetsAreCenterLocked() throws {
        for mode in [OrbitalViewMode.plan, .frontElevation, .sideElevation, .isometric] {
            let camera = try OrbitalViewCameraState.preset(mode)
            XCTAssertEqual(camera.mode, mode)
            XCTAssertTrue(camera.target.isApproximatelyOrigin())
        }

        XCTAssertThrowsError(
            try OrbitalViewCameraState(
                mode: .custom,
                projection: .perspective,
                orbit: OrbitalViewOrbit(yawRadians: 0, pitchRadians: 0, distanceM: 2),
                target: OrbitalViewVector3(x: 0.1, y: 0, z: 0),
                enforceCenterLock: true
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .nonOriginMonitorTarget(try! OrbitalViewVector3(x: 0.1, y: 0, z: 0))
            )
        }
    }

    func testThirtyPhysicalSpeakersPreserveChannelOrder() throws {
        let speakers = try (1...30).map { channel in
            try makeSpeaker(channel: channel)
        }

        let scene = try OrbitalViewSceneBuilder.makeMonitorScene(
            id: "fey-30",
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
            speakers: speakers
        )

        XCTAssertEqual(scene.speakers.count, 30)
        XCTAssertEqual(scene.speakers.map(\.channel), Array(1...30))
        XCTAssertEqual(scene.speakers.first?.label, "Fey 01")
        XCTAssertEqual(scene.speakers.last?.label, "Fey 30")
    }

    func testSceneRejectsDuplicatePhysicalChannelsAndIDs() throws {
        let first = try makeSpeaker(channel: 1, id: "speaker-1")
        let duplicateChannel = try makeSpeaker(channel: 1, id: "speaker-2")

        XCTAssertThrowsError(
            try OrbitalViewSceneBuilder.makeMonitorScene(
                id: "duplicate-channel",
                shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
                speakers: [first, duplicateChannel]
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .duplicatePhysicalChannel(1))
        }

        let duplicateID = try makeSpeaker(channel: 2, id: "speaker-1")
        XCTAssertThrowsError(
            try OrbitalViewSceneBuilder.makeMonitorScene(
                id: "duplicate-id",
                shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
                speakers: [first, duplicateID]
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .duplicateID("speaker-1"))
        }
    }

    func testSceneRejectsUnknownStructuralSpeakerAnchor() throws {
        let shell = try OrbitalViewSceneBuilder.makeDefaultOctahedronShell()
        let anchoredSpeaker = try OrbitalViewSpeaker(
            id: "speaker-1",
            channel: 1,
            label: "Fey 01",
            anchor: .node(nodeID: "missing-node", offsetM: 0.05),
            shape: .sphere(radiusM: 0.03)
        )

        XCTAssertThrowsError(
            try OrbitalViewSceneBuilder.makeMonitorScene(
                id: "unknown-anchor",
                shell: shell,
                speakers: [anchoredSpeaker]
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .unknownNodeID("missing-node"))
        }

        let parametricAnchor = try OrbitalViewSpeaker(
            id: "speaker-2",
            channel: 2,
            label: "Fey 02",
            anchor: .node(nodeID: "top", offsetM: 0.05),
            shape: .sphere(radiusM: 0.03)
        )

        XCTAssertThrowsError(
            try OrbitalViewSceneBuilder.makeMonitorScene(
                id: "parametric-anchor",
                shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
                speakers: [parametricAnchor]
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidAnchorReference("node anchor top requires imported shell geometry")
            )
        }
    }

    private func makeSpeaker(channel: Int, id: String? = nil) throws -> OrbitalViewSpeaker {
        let angle = (Double(channel - 1) / 30.0) * (Double.pi * 2.0)
        let direction = try UnitSphereDirection.normalized(
            x: cos(angle),
            y: 0.2,
            z: sin(angle)
        )

        return try OrbitalViewSpeaker(
            id: id ?? "speaker-\(channel)",
            channel: channel,
            label: String(format: "Fey %02d", channel),
            anchor: .direction(direction, offsetM: 0.05),
            shape: .sphere(radiusM: 0.03)
        )
    }
}
