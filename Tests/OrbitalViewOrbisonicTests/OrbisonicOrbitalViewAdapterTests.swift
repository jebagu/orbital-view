import XCTest
import OrbitalViewCore
import OrbitalViewOrbisonic

final class OrbisonicOrbitalViewAdapterTests: XCTestCase {
    func testOrbisonicAdapterBuildsSceneFromThirtyPhysicalSpeakers() throws {
        let adapter = try OrbisonicOrbitalViewAdapter(theme: OrbisonicOrbitalColorScheme.daftPunkBow.theme)
        let records = makeSpeakerRecords().reversed()

        let scene = try adapter.makeScene(speakers: Array(records))

        XCTAssertEqual(scene.id, "orbisonic-sonic-sphere-30")
        XCTAssertEqual(scene.coordinateSystem, .orbisonicMonitor)
        XCTAssertEqual(scene.theme, .daftPunkBow)
        XCTAssertEqual(scene.speakers.map(\.channel), Array(1...30))
        XCTAssertEqual(scene.speakers.first?.id, "orbisonic-channel-1")
        XCTAssertEqual(scene.speakers.first?.label, "Speaker 1")
        XCTAssertEqual(scene.speakers.last?.channel, 30)
        XCTAssertEqual(scene.speakers.last?.visualRole, .physicalSpeaker)
    }

    func testOrbisonicAdapterRejectsDuplicateOrIncompleteSpeakerContracts() throws {
        let adapter = try OrbisonicOrbitalViewAdapter()

        XCTAssertThrowsError(try adapter.makeScene(speakers: Array(makeSpeakerRecords().dropLast()))) { error in
            XCTAssertEqual(
                error as? OrbisonicOrbitalViewAdapterError,
                .invalidPhysicalSpeakerCount(expected: 30, actual: 29)
            )
        }

        var duplicate = makeSpeakerRecords()
        duplicate[1] = OrbisonicOutputSpeakerRecord(
            physicalChannel: 1,
            x: 0,
            y: 1,
            z: 0
        )

        XCTAssertThrowsError(try adapter.makeScene(speakers: duplicate)) { error in
            XCTAssertEqual(error as? OrbisonicOrbitalViewAdapterError, .duplicatePhysicalChannel(1))
        }

        var wrongSet = makeSpeakerRecords()
        wrongSet[29] = OrbisonicOutputSpeakerRecord(
            physicalChannel: 31,
            x: 0,
            y: 1,
            z: 0
        )

        XCTAssertThrowsError(try adapter.makeScene(speakers: wrongSet)) { error in
            XCTAssertEqual(
                error as? OrbisonicOrbitalViewAdapterError,
                .physicalChannelSetMismatch(expected: Array(1...30), actual: Array(1...29) + [31])
            )
        }
    }

    func testOrbisonicAdapterSanitizesOutputMonitorMeterRecords() throws {
        let adapter = try OrbisonicOrbitalViewAdapter()
        let result = try adapter.makeSanitizedSpeakerMeterFrame(
            timestamp: .nan,
            meters: [
                OrbisonicMeterRecord(physicalChannel: 1, rms: .nan, peak: 1.2),
                OrbisonicMeterRecord(physicalChannel: 1, rms: 0.25, peak: 0.35),
                OrbisonicMeterRecord(physicalChannel: 3, rms: 0.7, peak: 0.9, clip: true),
                OrbisonicMeterRecord(physicalChannel: 31, rms: 0.4, peak: 0.5),
                OrbisonicMeterRecord(physicalChannel: 0, rms: 0.1, peak: 0.2)
            ],
            timestampFallback: 12
        )

        XCTAssertEqual(result.frame.timestamp, 12)
        XCTAssertEqual(result.frame.levelsByChannel[1]?.rms, 0.25)
        XCTAssertEqual(result.frame.levelsByChannel[3]?.clip, true)
        XCTAssertEqual(result.diagnostics.missingChannels, [2] + Array(4...30))
        XCTAssertEqual(result.diagnostics.extraChannels, [31])
        XCTAssertEqual(result.diagnostics.invalidChannels, [0])
        XCTAssertEqual(result.diagnostics.duplicateChannels, [1])
        XCTAssertEqual(
            result.diagnostics.replacedValues,
            [OrbitalViewInputDiagnostics.ValueReplacement(channel: 1, field: "rms", replacement: 0)]
        )
        XCTAssertEqual(
            result.diagnostics.clampedValues,
            [OrbitalViewInputDiagnostics.ValueClamp(channel: 1, field: "peak", original: 1.2, clamped: 1)]
        )
        XCTAssertTrue(result.diagnostics.timestampReplaced)
    }

    func testOrbisonicColorSchemeContractIncludesDaftPunkBow() {
        XCTAssertTrue(OrbisonicOrbitalColorScheme.allCases.contains(.daftPunkBow))
        XCTAssertEqual(OrbisonicOrbitalColorScheme.daftPunkBow.displayName, "Daft Punk Bow")
        XCTAssertEqual(OrbisonicOrbitalColorScheme.daftPunkBow.theme, .daftPunkBow)
        XCTAssertFalse(OrbisonicOrbitalColorScheme.orbisonicLab.theme.vuRamp.isEmpty)
    }

    private func makeSpeakerRecords() -> [OrbisonicOutputSpeakerRecord] {
        (1...30).map { channel in
            let angle = (Double(channel - 1) / 30.0) * Double.pi * 2.0
            return OrbisonicOutputSpeakerRecord(
                physicalChannel: channel,
                x: cos(angle),
                y: sin(angle),
                z: channel.isMultiple(of: 2) ? 0.2 : -0.2
            )
        }
    }
}
