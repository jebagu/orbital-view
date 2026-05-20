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

public enum SpeakerMeterVisualStyle: String, Codable, CaseIterable, Equatable, Sendable {
    case checkerPulseRingAndDiagonalWave
    case prismGlow
    case warmPulse
    case coolPulse
    case customTBD

    public static let builtInStyles: [SpeakerMeterVisualStyle] = [
        .checkerPulseRingAndDiagonalWave,
        .prismGlow,
        .warmPulse,
        .coolPulse
    ]

    public var displayName: String {
        switch self {
        case .checkerPulseRingAndDiagonalWave:
            return "Checker Pulse Ring + Diagonal Wave"
        case .prismGlow:
            return "Prism Glow"
        case .warmPulse:
            return "Warm Pulse"
        case .coolPulse:
            return "Cool Pulse"
        case .customTBD:
            return "Custom / TBD"
        }
    }
}

public enum SpeakerMeterColorScheme: String, Codable, CaseIterable, Equatable, Sendable {
    case kimiPurple
    case orbisonicGreen
    case monochrome

    public var displayName: String {
        switch self {
        case .kimiPurple:
            return "Kimi Purple"
        case .orbisonicGreen:
            return "Orbisonic Green"
        case .monochrome:
            return "Monochrome"
        }
    }
}

public struct SpeakerMeterVisualSettings: Equatable, Codable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case visualGainDB
        case style
        case colorScheme
        case ringFrontDensity
        case bandSoftness
        case tileDetail
        case idleTint
        case memoryCarryover
        case checkerBandVelocity
        case checkerBandWidth
    }

    public static let minVisualGainDB: Float = -24
    public static let maxVisualGainDB: Float = 24
    public static let `default` = SpeakerMeterVisualSettings(
        uncheckedVisualGainDB: 0,
        style: .checkerPulseRingAndDiagonalWave,
        colorScheme: .kimiPurple,
        ringFrontDensity: 3.3,
        bandSoftness: 0.85,
        tileDetail: 10,
        idleTint: 0.36,
        memoryCarryover: 0.58,
        checkerBandVelocity: 0.826,
        checkerBandWidth: 0.831
    )

    public let visualGainDB: Float
    public let style: SpeakerMeterVisualStyle
    public let colorScheme: SpeakerMeterColorScheme
    public let ringFrontDensity: Float
    public let bandSoftness: Float
    public let tileDetail: Int
    public let idleTint: Float
    public let memoryCarryover: Float
    public let checkerBandVelocity: Float
    public let checkerBandWidth: Float

    public init(
        visualGainDB: Float = 0,
        style: SpeakerMeterVisualStyle = .checkerPulseRingAndDiagonalWave,
        colorScheme: SpeakerMeterColorScheme = .kimiPurple,
        ringFrontDensity: Float = 3.3,
        bandSoftness: Float = 0.85,
        tileDetail: Int = 10,
        idleTint: Float = 0.36,
        memoryCarryover: Float = 0.58,
        checkerBandVelocity: Float = 0.826,
        checkerBandWidth: Float = 0.831
    ) throws {
        self.visualGainDB = visualGainDB
        self.style = style
        self.colorScheme = colorScheme
        self.ringFrontDensity = ringFrontDensity
        self.bandSoftness = bandSoftness
        self.tileDetail = tileDetail
        self.idleTint = idleTint
        self.memoryCarryover = memoryCarryover
        self.checkerBandVelocity = checkerBandVelocity
        self.checkerBandWidth = checkerBandWidth
        try validate()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let visualGainDB = try container.decode(Float.self, forKey: .visualGainDB)
        let style = try container.decode(SpeakerMeterVisualStyle.self, forKey: .style)
        let colorScheme = try container.decode(SpeakerMeterColorScheme.self, forKey: .colorScheme)
        let ringFrontDensity = try container.decode(Float.self, forKey: .ringFrontDensity)
        let bandSoftness = try container.decode(Float.self, forKey: .bandSoftness)
        let tileDetail = try container.decode(Int.self, forKey: .tileDetail)
        let idleTint = try container.decode(Float.self, forKey: .idleTint)
        let memoryCarryover = try container.decode(Float.self, forKey: .memoryCarryover)
        let checkerBandVelocity = try container.decode(Float.self, forKey: .checkerBandVelocity)
        let checkerBandWidth = try container.decode(Float.self, forKey: .checkerBandWidth)
        try self.init(
            visualGainDB: visualGainDB,
            style: style,
            colorScheme: colorScheme,
            ringFrontDensity: ringFrontDensity,
            bandSoftness: bandSoftness,
            tileDetail: tileDetail,
            idleTint: idleTint,
            memoryCarryover: memoryCarryover,
            checkerBandVelocity: checkerBandVelocity,
            checkerBandWidth: checkerBandWidth
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(visualGainDB, forKey: .visualGainDB)
        try container.encode(style, forKey: .style)
        try container.encode(colorScheme, forKey: .colorScheme)
        try container.encode(ringFrontDensity, forKey: .ringFrontDensity)
        try container.encode(bandSoftness, forKey: .bandSoftness)
        try container.encode(tileDetail, forKey: .tileDetail)
        try container.encode(idleTint, forKey: .idleTint)
        try container.encode(memoryCarryover, forKey: .memoryCarryover)
        try container.encode(checkerBandVelocity, forKey: .checkerBandVelocity)
        try container.encode(checkerBandWidth, forKey: .checkerBandWidth)
    }

    private init(
        uncheckedVisualGainDB visualGainDB: Float,
        style: SpeakerMeterVisualStyle,
        colorScheme: SpeakerMeterColorScheme,
        ringFrontDensity: Float,
        bandSoftness: Float,
        tileDetail: Int,
        idleTint: Float,
        memoryCarryover: Float,
        checkerBandVelocity: Float,
        checkerBandWidth: Float
    ) {
        self.visualGainDB = visualGainDB
        self.style = style
        self.colorScheme = colorScheme
        self.ringFrontDensity = ringFrontDensity
        self.bandSoftness = bandSoftness
        self.tileDetail = tileDetail
        self.idleTint = idleTint
        self.memoryCarryover = memoryCarryover
        self.checkerBandVelocity = checkerBandVelocity
        self.checkerBandWidth = checkerBandWidth
    }

    public func validate() throws {
        guard visualGainDB.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "meterVisual.visualGainDB")
        }

        guard
            visualGainDB >= Self.minVisualGainDB,
            visualGainDB <= Self.maxVisualGainDB
        else {
            throw OrbitalViewValidationError.invalidRange(
                field: "meterVisual.visualGainDB",
                value: Double(visualGainDB),
                validRange: "-24...24"
            )
        }

        try validateFiniteRange(
            field: "meterVisual.ringFrontDensity",
            value: ringFrontDensity,
            validRange: 0.1...12,
            validRangeDescription: "0.1...12"
        )
        try validateFiniteRange(
            field: "meterVisual.bandSoftness",
            value: bandSoftness,
            validRange: 0.1...3,
            validRangeDescription: "0.1...3"
        )
        try validateFiniteRange(
            field: "meterVisual.idleTint",
            value: idleTint,
            validRange: 0...1,
            validRangeDescription: "0...1"
        )
        try validateFiniteRange(
            field: "meterVisual.memoryCarryover",
            value: memoryCarryover,
            validRange: 0...1,
            validRangeDescription: "0...1"
        )
        try validateFiniteRange(
            field: "meterVisual.checkerBandVelocity",
            value: checkerBandVelocity,
            validRange: 0...4,
            validRangeDescription: "0...4"
        )
        try validateFiniteRange(
            field: "meterVisual.checkerBandWidth",
            value: checkerBandWidth,
            validRange: 0.22...0.96,
            validRangeDescription: "0.22...0.96"
        )

        guard tileDetail >= 4, tileDetail <= 32 else {
            throw OrbitalViewValidationError.invalidRange(
                field: "meterVisual.tileDetail",
                value: Double(tileDetail),
                validRange: "4...32"
            )
        }
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
