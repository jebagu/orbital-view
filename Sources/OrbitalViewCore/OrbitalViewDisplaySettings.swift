import Foundation

public enum OrbitalViewSpeakerDisplayShape: String, Codable, CaseIterable, Equatable, Sendable {
    case prism
    case sphere

    public var displayName: String {
        switch self {
        case .prism:
            return "Prism"
        case .sphere:
            return "Sphere"
        }
    }
}

public struct OrbitalViewDisplaySettings: Equatable, Codable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case speakerShape
        case speakerScale
        case fogDensity
        case showsSpeakerNumbers
        case showsHiddenLines
    }

    public static let minSpeakerScale: Float = 0.975
    public static let defaultSpeakerScale: Float = 1.95
    public static let maxSpeakerScale: Float = 3.9
    public static let minFogDensity: Float = 0
    public static let defaultFogDensity: Float = 30
    public static let maxFogDensity: Float = 100

    public static let `default` = OrbitalViewDisplaySettings(
        uncheckedSpeakerShape: .prism,
        speakerScale: defaultSpeakerScale,
        fogDensity: defaultFogDensity,
        showsSpeakerNumbers: false,
        showsHiddenLines: false
    )

    public let speakerShape: OrbitalViewSpeakerDisplayShape
    public let speakerScale: Float
    public let fogDensity: Float
    public let showsSpeakerNumbers: Bool
    public let showsHiddenLines: Bool

    public var isFogEnabled: Bool {
        fogDensity > Self.minFogDensity
    }

    public var normalizedFogDensity: Float {
        guard isFogEnabled else {
            return 0
        }
        return min(max(fogDensity / Self.maxFogDensity, 0), 1)
    }

    public init(
        speakerShape: OrbitalViewSpeakerDisplayShape = .prism,
        speakerScale: Float = Self.defaultSpeakerScale,
        fogDensity: Float = Self.defaultFogDensity,
        showsSpeakerNumbers: Bool = false,
        showsHiddenLines: Bool = false
    ) throws {
        self.speakerShape = speakerShape
        self.speakerScale = speakerScale
        self.fogDensity = fogDensity
        self.showsSpeakerNumbers = showsSpeakerNumbers
        self.showsHiddenLines = showsHiddenLines
        try validate()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            speakerShape: container.decode(OrbitalViewSpeakerDisplayShape.self, forKey: .speakerShape),
            speakerScale: container.decode(Float.self, forKey: .speakerScale),
            fogDensity: container.decode(Float.self, forKey: .fogDensity),
            showsSpeakerNumbers: container.decode(Bool.self, forKey: .showsSpeakerNumbers),
            showsHiddenLines: container.decode(Bool.self, forKey: .showsHiddenLines)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(speakerShape, forKey: .speakerShape)
        try container.encode(speakerScale, forKey: .speakerScale)
        try container.encode(fogDensity, forKey: .fogDensity)
        try container.encode(showsSpeakerNumbers, forKey: .showsSpeakerNumbers)
        try container.encode(showsHiddenLines, forKey: .showsHiddenLines)
    }

    private init(
        uncheckedSpeakerShape speakerShape: OrbitalViewSpeakerDisplayShape,
        speakerScale: Float,
        fogDensity: Float,
        showsSpeakerNumbers: Bool,
        showsHiddenLines: Bool
    ) {
        self.speakerShape = speakerShape
        self.speakerScale = speakerScale
        self.fogDensity = fogDensity
        self.showsSpeakerNumbers = showsSpeakerNumbers
        self.showsHiddenLines = showsHiddenLines
    }

    public func validate() throws {
        try validateFiniteRange(
            field: "display.speakerScale",
            value: speakerScale,
            validRange: Self.minSpeakerScale...Self.maxSpeakerScale,
            validRangeDescription: "\(Self.minSpeakerScale)...\(Self.maxSpeakerScale)"
        )
        try validateFiniteRange(
            field: "display.fogDensity",
            value: fogDensity,
            validRange: Self.minFogDensity...Self.maxFogDensity,
            validRangeDescription: "\(Self.minFogDensity)...\(Self.maxFogDensity)"
        )
    }

    private func validateFiniteRange(
        field: String,
        value: Float,
        validRange: ClosedRange<Float>,
        validRangeDescription: String
    ) throws {
        guard value.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: field)
        }

        guard validRange.contains(value) else {
            throw OrbitalViewValidationError.invalidRange(
                field: field,
                value: Double(value),
                validRange: validRangeDescription
            )
        }
    }
}
