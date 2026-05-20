import Foundation
import OrbitalViewCore

public enum WavefieldMeterFrameAdapterError: Error, Equatable, Sendable {
    case duplicateChannel(Int)
    case invalidChannel(Int)
    case nonFiniteLevel(channel: Int, field: String)
}

public struct WavefieldMeterChannelFrame: Equatable, Sendable {
    public let channel: Int
    public let rms: Float
    public let peak: Float

    public init(channel: Int, rms: Float, peak: Float) {
        self.channel = channel
        self.rms = rms
        self.peak = peak
    }
}

public struct WavefieldMeterFrameAdapter: Sendable {
    public let clipThreshold: Float

    public init(clipThreshold: Float = 1.0) throws {
        guard clipThreshold.isFinite else {
            throw WavefieldMeterFrameAdapterError.nonFiniteLevel(channel: 0, field: "clipThreshold")
        }
        self.clipThreshold = clipThreshold
    }

    public func makeSpeakerMeterFrame(
        timestamp: TimeInterval,
        channels: [WavefieldMeterChannelFrame]
    ) throws -> SpeakerMeterFrame {
        var levelsByChannel: [Int: SpeakerMeterLevel] = [:]

        for channelFrame in channels {
            guard channelFrame.channel > 0 else {
                throw WavefieldMeterFrameAdapterError.invalidChannel(channelFrame.channel)
            }

            guard levelsByChannel[channelFrame.channel] == nil else {
                throw WavefieldMeterFrameAdapterError.duplicateChannel(channelFrame.channel)
            }

            guard channelFrame.rms.isFinite else {
                throw WavefieldMeterFrameAdapterError.nonFiniteLevel(
                    channel: channelFrame.channel,
                    field: "rms"
                )
            }

            guard channelFrame.peak.isFinite else {
                throw WavefieldMeterFrameAdapterError.nonFiniteLevel(
                    channel: channelFrame.channel,
                    field: "peak"
                )
            }

            levelsByChannel[channelFrame.channel] = try SpeakerMeterLevel(
                rms: channelFrame.rms,
                peak: channelFrame.peak,
                clip: channelFrame.peak >= clipThreshold
            )
        }

        return try SpeakerMeterFrame(timestamp: timestamp, levelsByChannel: levelsByChannel)
    }

    public func makeSanitizedSpeakerMeterFrame(
        timestamp: TimeInterval,
        expectedChannels: [Int],
        channels: [WavefieldMeterChannelFrame],
        timestampFallback: TimeInterval = 0
    ) throws -> SpeakerMeterFrameSanitizer.Result {
        let samples = channels.map { channelFrame in
            SpeakerMeterSample(
                channel: channelFrame.channel,
                rms: channelFrame.rms,
                peak: channelFrame.peak,
                clip: channelFrame.peak.isFinite && channelFrame.peak >= clipThreshold
            )
        }
        return try SpeakerMeterFrameSanitizer(
            expectedChannels: expectedChannels,
            timestampFallback: timestampFallback
        )
        .sanitize(timestamp: timestamp, samples: samples)
    }
}
