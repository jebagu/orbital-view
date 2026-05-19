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
}

