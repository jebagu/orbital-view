import XCTest
@testable import OrbitalViewCore
@testable import OrbitalViewWavefield

final class WavefieldMeterFrameAdapterTests: XCTestCase {
    func testChannelMeterFramesMapByChannelIdentity() throws {
        let frame = try WavefieldMeterFrameAdapter().makeSpeakerMeterFrame(
            timestamp: 10.5,
            channels: [
                WavefieldMeterChannelFrame(channel: 30, rms: 0.3, peak: 0.7),
                WavefieldMeterChannelFrame(channel: 1, rms: 0.1, peak: 0.2)
            ]
        )

        XCTAssertEqual(frame.timestamp, 10.5)
        XCTAssertEqual(frame.levelsByChannel[1], try SpeakerMeterLevel(rms: 0.1, peak: 0.2, clip: false))
        XCTAssertEqual(frame.levelsByChannel[30], try SpeakerMeterLevel(rms: 0.3, peak: 0.7, clip: false))
        XCTAssertNil(frame.levelsByChannel[2])
        XCTAssertEqual(frame.source, .externalWavefieldStream)
    }

    func testClipThresholdMarksPeakAtOrAboveThreshold() throws {
        let adapter = try WavefieldMeterFrameAdapter(clipThreshold: 0.95)
        let frame = try adapter.makeSpeakerMeterFrame(
            timestamp: 0,
            channels: [
                WavefieldMeterChannelFrame(channel: 1, rms: 0.2, peak: 0.949),
                WavefieldMeterChannelFrame(channel: 2, rms: 0.2, peak: 0.95),
                WavefieldMeterChannelFrame(channel: 3, rms: 0.2, peak: 1.2)
            ]
        )

        XCTAssertEqual(frame.levelsByChannel[1]?.clip, false)
        XCTAssertEqual(frame.levelsByChannel[2]?.clip, true)
        XCTAssertEqual(frame.levelsByChannel[3]?.clip, true)
    }

    func testLocalLivestreamGeneratorSourcePreservesChannelIdentity() throws {
        let source = try OrbitalViewTelemetrySourceDescriptor(
            kind: .localLivestreamTestGenerator,
            label: "Wavefield local generator",
            detail: "profile=smoke"
        )
        let frame = try WavefieldMeterFrameAdapter(source: source).makeSpeakerMeterFrame(
            timestamp: 2.5,
            channels: [
                WavefieldMeterChannelFrame(channel: 8, rms: 0.25, peak: 0.5),
                WavefieldMeterChannelFrame(channel: 3, rms: 0.15, peak: 0.35)
            ]
        )

        XCTAssertEqual(frame.source, source)
        XCTAssertEqual(frame.levelsByChannel.keys.sorted(), [3, 8])
        XCTAssertEqual(frame.levelsByChannel[3], try SpeakerMeterLevel(rms: 0.15, peak: 0.35, clip: false))
        XCTAssertEqual(frame.levelsByChannel[8], try SpeakerMeterLevel(rms: 0.25, peak: 0.5, clip: false))
    }

    func testDuplicateChannelsAreRejected() throws {
        XCTAssertThrowsError(
            try WavefieldMeterFrameAdapter().makeSpeakerMeterFrame(
                timestamp: 0,
                channels: [
                    WavefieldMeterChannelFrame(channel: 1, rms: 0.1, peak: 0.2),
                    WavefieldMeterChannelFrame(channel: 1, rms: 0.2, peak: 0.3)
                ]
            )
        ) { error in
            XCTAssertEqual(error as? WavefieldMeterFrameAdapterError, .duplicateChannel(1))
        }
    }

    func testInvalidChannelsAndNonFiniteLevelsAreRejected() throws {
        XCTAssertThrowsError(
            try WavefieldMeterFrameAdapter().makeSpeakerMeterFrame(
                timestamp: 0,
                channels: [
                    WavefieldMeterChannelFrame(channel: 0, rms: 0.1, peak: 0.2)
                ]
            )
        ) { error in
            XCTAssertEqual(error as? WavefieldMeterFrameAdapterError, .invalidChannel(0))
        }

        XCTAssertThrowsError(
            try WavefieldMeterFrameAdapter().makeSpeakerMeterFrame(
                timestamp: 0,
                channels: [
                    WavefieldMeterChannelFrame(channel: 1, rms: .nan, peak: 0.2)
                ]
            )
        ) { error in
            XCTAssertEqual(
                error as? WavefieldMeterFrameAdapterError,
                .nonFiniteLevel(channel: 1, field: "rms")
            )
        }

        XCTAssertThrowsError(
            try WavefieldMeterFrameAdapter().makeSpeakerMeterFrame(
                timestamp: 0,
                channels: [
                    WavefieldMeterChannelFrame(channel: 1, rms: 0.1, peak: .infinity)
                ]
            )
        ) { error in
            XCTAssertEqual(
                error as? WavefieldMeterFrameAdapterError,
                .nonFiniteLevel(channel: 1, field: "peak")
            )
        }
    }

    func testSanitizedMeterFramesReportMissingExtraAndClampedChannels() throws {
        let result = try WavefieldMeterFrameAdapter(clipThreshold: 0.9).makeSanitizedSpeakerMeterFrame(
            timestamp: .infinity,
            expectedChannels: [1, 2, 3],
            channels: [
                WavefieldMeterChannelFrame(channel: 1, rms: 0.2, peak: 0.91),
                WavefieldMeterChannelFrame(channel: 2, rms: .nan, peak: 1.4),
                WavefieldMeterChannelFrame(channel: 4, rms: -0.2, peak: 0.1),
                WavefieldMeterChannelFrame(channel: 2, rms: 0.3, peak: 0.4),
                WavefieldMeterChannelFrame(channel: 0, rms: 0.8, peak: 0.8)
            ],
            timestampFallback: 12.25
        )

        XCTAssertEqual(result.frame.timestamp, 12.25)
        XCTAssertEqual(result.frame.levelsByChannel[1], try SpeakerMeterLevel(rms: 0.2, peak: 0.91, clip: true))
        XCTAssertEqual(result.frame.levelsByChannel[2], try SpeakerMeterLevel(rms: 0.3, peak: 0.4, clip: false))
        XCTAssertEqual(result.frame.levelsByChannel[4], try SpeakerMeterLevel(rms: 0, peak: 0.1, clip: false))
        XCTAssertNil(result.frame.levelsByChannel[3])
        XCTAssertEqual(result.frame.source, .externalWavefieldStream)
        XCTAssertEqual(result.diagnostics.missingChannels, [3])
        XCTAssertEqual(result.diagnostics.extraChannels, [4])
        XCTAssertEqual(result.diagnostics.invalidChannels, [0])
        XCTAssertEqual(result.diagnostics.duplicateChannels, [2])
        XCTAssertEqual(
            result.diagnostics.replacedValues,
            [OrbitalViewInputDiagnostics.ValueReplacement(channel: 2, field: "rms", replacement: 0)]
        )
        XCTAssertEqual(
            result.diagnostics.clampedValues,
            [
                OrbitalViewInputDiagnostics.ValueClamp(channel: 2, field: "peak", original: 1.4, clamped: 1),
                OrbitalViewInputDiagnostics.ValueClamp(channel: 4, field: "rms", original: -0.2, clamped: 0)
            ]
        )
        XCTAssertTrue(result.diagnostics.timestampReplaced)
    }
}
