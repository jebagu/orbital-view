import Foundation

public struct SpeakerMeterSample: Equatable, Sendable {
    public let channel: Int
    public let rms: Float
    public let peak: Float
    public let clip: Bool

    public init(channel: Int, rms: Float, peak: Float, clip: Bool) {
        self.channel = channel
        self.rms = rms
        self.peak = peak
        self.clip = clip
    }
}

public struct OrbitalViewInputDiagnostics: Equatable, Codable, Sendable {
    public struct ValueReplacement: Equatable, Codable, Sendable {
        public let channel: Int
        public let field: String
        public let replacement: Float

        public init(channel: Int, field: String, replacement: Float) {
            self.channel = channel
            self.field = field
            self.replacement = replacement
        }
    }

    public struct ValueClamp: Equatable, Codable, Sendable {
        public let channel: Int
        public let field: String
        public let original: Float
        public let clamped: Float

        public init(channel: Int, field: String, original: Float, clamped: Float) {
            self.channel = channel
            self.field = field
            self.original = original
            self.clamped = clamped
        }
    }

    public static let empty = OrbitalViewInputDiagnostics()

    public let missingChannels: [Int]
    public let extraChannels: [Int]
    public let invalidChannels: [Int]
    public let duplicateChannels: [Int]
    public let replacedValues: [ValueReplacement]
    public let clampedValues: [ValueClamp]
    public let timestampReplaced: Bool

    public init(
        missingChannels: [Int] = [],
        extraChannels: [Int] = [],
        invalidChannels: [Int] = [],
        duplicateChannels: [Int] = [],
        replacedValues: [ValueReplacement] = [],
        clampedValues: [ValueClamp] = [],
        timestampReplaced: Bool = false
    ) {
        self.missingChannels = missingChannels
        self.extraChannels = extraChannels
        self.invalidChannels = invalidChannels
        self.duplicateChannels = duplicateChannels
        self.replacedValues = replacedValues
        self.clampedValues = clampedValues
        self.timestampReplaced = timestampReplaced
    }

    public var hasIssues: Bool {
        timestampReplaced
            || !missingChannels.isEmpty
            || !extraChannels.isEmpty
            || !invalidChannels.isEmpty
            || !duplicateChannels.isEmpty
            || !replacedValues.isEmpty
            || !clampedValues.isEmpty
    }
}

public struct SpeakerMeterFrameSanitizer: Equatable, Sendable {
    public struct Result: Equatable, Sendable {
        public let frame: SpeakerMeterFrame
        public let diagnostics: OrbitalViewInputDiagnostics

        public init(frame: SpeakerMeterFrame, diagnostics: OrbitalViewInputDiagnostics) {
            self.frame = frame
            self.diagnostics = diagnostics
        }
    }

    public let expectedChannels: [Int]
    public let timestampFallback: TimeInterval

    public init(expectedChannels: [Int], timestampFallback: TimeInterval = 0) {
        self.expectedChannels = Array(Set(expectedChannels.filter { $0 > 0 })).sorted()
        self.timestampFallback = timestampFallback.isFinite ? timestampFallback : 0
    }

    public func sanitize(timestamp: TimeInterval, samples: [SpeakerMeterSample]) throws -> Result {
        let safeTimestamp = timestamp.isFinite ? timestamp : timestampFallback
        var levelsByChannel: [Int: SpeakerMeterLevel] = [:]
        var invalidChannels: [Int] = []
        var duplicateChannels = Set<Int>()
        var seenChannels = Set<Int>()
        var replacedValues: [OrbitalViewInputDiagnostics.ValueReplacement] = []
        var clampedValues: [OrbitalViewInputDiagnostics.ValueClamp] = []

        for sample in samples {
            guard sample.channel > 0 else {
                invalidChannels.append(sample.channel)
                continue
            }

            if !seenChannels.insert(sample.channel).inserted {
                duplicateChannels.insert(sample.channel)
            }

            let rms = sanitizeLevelValue(
                sample.rms,
                channel: sample.channel,
                field: "rms",
                replacedValues: &replacedValues,
                clampedValues: &clampedValues
            )
            let peak = sanitizeLevelValue(
                sample.peak,
                channel: sample.channel,
                field: "peak",
                replacedValues: &replacedValues,
                clampedValues: &clampedValues
            )
            let clip = sample.clip || peak >= 1
            levelsByChannel[sample.channel] = try SpeakerMeterLevel(rms: rms, peak: peak, clip: clip)
        }

        let sanitizedChannels = Set(levelsByChannel.keys)
        let expectedSet = Set(expectedChannels)
        let missingChannels = expectedChannels.filter { !sanitizedChannels.contains($0) }
        let extraChannels = expectedSet.isEmpty ? [] : sanitizedChannels.subtracting(expectedSet).sorted()

        let diagnostics = OrbitalViewInputDiagnostics(
            missingChannels: missingChannels,
            extraChannels: extraChannels,
            invalidChannels: invalidChannels.sorted(),
            duplicateChannels: Array(duplicateChannels).sorted(),
            replacedValues: replacedValues,
            clampedValues: clampedValues,
            timestampReplaced: !timestamp.isFinite
        )
        return try Result(
            frame: SpeakerMeterFrame(timestamp: safeTimestamp, levelsByChannel: levelsByChannel),
            diagnostics: diagnostics
        )
    }

    private func sanitizeLevelValue(
        _ value: Float,
        channel: Int,
        field: String,
        replacedValues: inout [OrbitalViewInputDiagnostics.ValueReplacement],
        clampedValues: inout [OrbitalViewInputDiagnostics.ValueClamp]
    ) -> Float {
        guard value.isFinite else {
            replacedValues.append(
                OrbitalViewInputDiagnostics.ValueReplacement(channel: channel, field: field, replacement: 0)
            )
            return 0
        }

        let clamped = min(max(value, 0), 1)
        if clamped != value {
            clampedValues.append(
                OrbitalViewInputDiagnostics.ValueClamp(
                    channel: channel,
                    field: field,
                    original: value,
                    clamped: clamped
                )
            )
        }
        return clamped
    }
}
