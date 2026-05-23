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
    private enum CodingKeys: String, CodingKey {
        case missingChannels
        case extraChannels
        case invalidChannels
        case duplicateChannels
        case replacedValues
        case clampedValues
        case timestampReplaced
        case overloadActions
    }

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
    public let overloadActions: [OrbitalViewTelemetryOverloadAction]

    public init(
        missingChannels: [Int] = [],
        extraChannels: [Int] = [],
        invalidChannels: [Int] = [],
        duplicateChannels: [Int] = [],
        replacedValues: [ValueReplacement] = [],
        clampedValues: [ValueClamp] = [],
        timestampReplaced: Bool = false,
        overloadActions: [OrbitalViewTelemetryOverloadAction] = []
    ) {
        self.missingChannels = missingChannels
        self.extraChannels = extraChannels
        self.invalidChannels = invalidChannels
        self.duplicateChannels = duplicateChannels
        self.replacedValues = replacedValues
        self.clampedValues = clampedValues
        self.timestampReplaced = timestampReplaced
        self.overloadActions = Self.normalizedOverloadActions(overloadActions)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            missingChannels: try container.decodeIfPresent([Int].self, forKey: .missingChannels) ?? [],
            extraChannels: try container.decodeIfPresent([Int].self, forKey: .extraChannels) ?? [],
            invalidChannels: try container.decodeIfPresent([Int].self, forKey: .invalidChannels) ?? [],
            duplicateChannels: try container.decodeIfPresent([Int].self, forKey: .duplicateChannels) ?? [],
            replacedValues: try container.decodeIfPresent([ValueReplacement].self, forKey: .replacedValues) ?? [],
            clampedValues: try container.decodeIfPresent([ValueClamp].self, forKey: .clampedValues) ?? [],
            timestampReplaced: try container.decodeIfPresent(Bool.self, forKey: .timestampReplaced) ?? false,
            overloadActions: try container.decodeIfPresent(
                [OrbitalViewTelemetryOverloadAction].self,
                forKey: .overloadActions
            ) ?? []
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(missingChannels, forKey: .missingChannels)
        try container.encode(extraChannels, forKey: .extraChannels)
        try container.encode(invalidChannels, forKey: .invalidChannels)
        try container.encode(duplicateChannels, forKey: .duplicateChannels)
        try container.encode(replacedValues, forKey: .replacedValues)
        try container.encode(clampedValues, forKey: .clampedValues)
        try container.encode(timestampReplaced, forKey: .timestampReplaced)
        try container.encode(overloadActions, forKey: .overloadActions)
    }

    public var hasIssues: Bool {
        timestampReplaced
            || !missingChannels.isEmpty
            || !extraChannels.isEmpty
            || !invalidChannels.isEmpty
            || !duplicateChannels.isEmpty
            || !replacedValues.isEmpty
            || !clampedValues.isEmpty
            || !overloadActions.isEmpty
    }

    private static func normalizedOverloadActions(
        _ actions: [OrbitalViewTelemetryOverloadAction]
    ) -> [OrbitalViewTelemetryOverloadAction] {
        let actionSet = Set(actions)
        return OrbitalViewTelemetryOverloadAction.allCases.filter { actionSet.contains($0) }
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
    public let source: OrbitalViewTelemetrySourceDescriptor

    public init(
        expectedChannels: [Int],
        timestampFallback: TimeInterval = 0,
        source: OrbitalViewTelemetrySourceDescriptor = .speakerBus
    ) {
        self.expectedChannels = Array(Set(expectedChannels.filter { $0 > 0 })).sorted()
        self.timestampFallback = timestampFallback.isFinite ? timestampFallback : 0
        self.source = source
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
            frame: SpeakerMeterFrame(
                timestamp: safeTimestamp,
                levelsByChannel: levelsByChannel,
                source: source
            ),
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
