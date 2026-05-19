import Foundation

public struct SpeakerMeterFrame: Equatable, Sendable {
    public let timestamp: TimeInterval
    public let levelsByChannel: [Int: SpeakerMeterLevel]

    public init(timestamp: TimeInterval, levelsByChannel: [Int: SpeakerMeterLevel]) throws {
        self.timestamp = timestamp
        self.levelsByChannel = levelsByChannel
        try validate()
    }

    public func validate() throws {
        guard timestamp.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "meter.timestamp")
        }

        for channel in levelsByChannel.keys {
            guard channel > 0 else {
                throw OrbitalViewValidationError.invalidChannel(channel)
            }
        }
    }
}

public struct SpeakerMeterLevel: Equatable, Sendable {
    public let rms: Float
    public let peak: Float
    public let clip: Bool

    public init(rms: Float, peak: Float, clip: Bool) throws {
        self.rms = rms
        self.peak = peak
        self.clip = clip
        try validate()
    }

    public func validate() throws {
        guard rms.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "meter.rms")
        }
        guard peak.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "meter.peak")
        }
    }
}

