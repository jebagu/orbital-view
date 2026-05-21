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
    case cubeScalarCenterBloom
    case checkerPulseRingAndDiagonalWave
    case prismGlow
    case warmPulse
    case coolPulse
    case customTBD

    public static let builtInStyles: [SpeakerMeterVisualStyle] = [
        .cubeScalarCenterBloom,
        .checkerPulseRingAndDiagonalWave,
        .prismGlow,
        .warmPulse,
        .coolPulse
    ]

    public var displayName: String {
        switch self {
        case .cubeScalarCenterBloom:
            return "Cube Scalar Center Bloom"
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case Self.cubeScalarCenterBloom.rawValue:
            self = .cubeScalarCenterBloom
        case Self.checkerPulseRingAndDiagonalWave.rawValue, "checkerRipple", "legacyCheckerRipple":
            self = .checkerPulseRingAndDiagonalWave
        case Self.prismGlow.rawValue:
            self = .prismGlow
        case Self.warmPulse.rawValue:
            self = .warmPulse
        case Self.coolPulse.rawValue:
            self = .coolPulse
        case Self.customTBD.rawValue:
            self = .customTBD
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown speaker meter visual style: \(rawValue)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public enum SpeakerMeterColorScheme: String, Codable, CaseIterable, Equatable, Sendable {
    case kimiPurple
    case daftPunkBow
    case orbisonicGreen
    case monochrome

    public var displayName: String {
        switch self {
        case .kimiPurple:
            return "Kimi Purple"
        case .daftPunkBow:
            return "Daft Punk Bow"
        case .orbisonicGreen:
            return "Orbisonic Green"
        case .monochrome:
            return "Monochrome"
        }
    }

    public var theme: OrbitalViewTheme {
        switch self {
        case .kimiPurple:
            return .kimiPurple
        case .daftPunkBow:
            return .daftPunkBow
        case .orbisonicGreen:
            return OrbitalViewTheme(
                name: displayName,
                background: .rgb(0x07100E),
                panel: .rgb(0x0E1714),
                line: .rgb(0x1E332B),
                text: .rgb(0xECFFF7),
                mutedText: .rgb(0x85A49A),
                accent: .rgb(0x42D88A),
                accentSecondary: .rgb(0xD1F77A),
                success: .rgb(0x34D399),
                warning: .rgb(0xFDE047),
                danger: .rgb(0xEF4444),
                vuRamp: [
                    OrbitalColorStop(position: 0.0, color: .rgb(0x173B2A)),
                    OrbitalColorStop(position: 0.5, color: .rgb(0x42D88A)),
                    OrbitalColorStop(position: 1.0, color: .rgb(0xD1F77A))
                ]
            )
        case .monochrome:
            return OrbitalViewTheme(
                name: displayName,
                background: .rgb(0x090909),
                panel: .rgb(0x121212),
                line: .rgb(0x2A2A2A),
                text: .rgb(0xF2F2F2),
                mutedText: .rgb(0x8A8A8A),
                accent: .rgb(0xD8D8D8),
                accentSecondary: .rgb(0xFFFFFF),
                success: .rgb(0xD8D8D8),
                warning: .rgb(0xEAEAEA),
                danger: .rgb(0xFFFFFF),
                vuRamp: [
                    OrbitalColorStop(position: 0.0, color: .rgb(0x303030)),
                    OrbitalColorStop(position: 0.5, color: .rgb(0xD8D8D8)),
                    OrbitalColorStop(position: 1.0, color: .rgb(0xFFFFFF))
                ]
            )
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case Self.kimiPurple.rawValue:
            self = .kimiPurple
        case Self.daftPunkBow.rawValue, "techRainbow":
            self = .daftPunkBow
        case Self.orbisonicGreen.rawValue:
            self = .orbisonicGreen
        case Self.monochrome.rawValue:
            self = .monochrome
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown speaker meter color scheme: \(rawValue)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
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
        case inputCalibration
        case levelCompression
        case displayCeiling
        case hotResponse
        case hotThreshold
        case hotFillStrength
        case vuPaletteDrive
        case idleTint
        case checkerContrast
        case memoryCarryover
        case checkerBandVelocity
        case checkerBandWidth
        case speakerZScale
        case bloomMin
        case bloomMax
        case bloomEdge
        case responseCurve
        case peakHoldSeconds
        case releaseMemory
        case hotFill
        case facePixels
        case showsDiagnostics
    }

    public static let minVisualGainDB: Float = -24
    public static let maxVisualGainDB: Float = 24
    public static let minInputCalibration: Float = 0.25
    public static let maxInputCalibration: Float = 2
    public static let minLevelCompression: Float = 1
    public static let maxLevelCompression: Float = 4
    public static let minDisplayCeiling: Float = 0.5
    public static let maxDisplayCeiling: Float = 1
    public static let minHotResponse: Float = 0.5
    public static let maxHotResponse: Float = 3
    public static let minHotThreshold: Float = 0.35
    public static let maxHotThreshold: Float = 0.98
    public static let minVUPaletteDrive: Float = 0.5
    public static let maxVUPaletteDrive: Float = 4
    public static let minSpeakerZScale: Float = 1
    public static let maxSpeakerZScale: Float = 2
    public static let `default` = SpeakerMeterVisualSettings(
        uncheckedVisualGainDB: 0,
        style: .cubeScalarCenterBloom,
        colorScheme: .daftPunkBow,
        ringFrontDensity: 3.3,
        bandSoftness: 0.85,
        tileDetail: 10,
        inputCalibration: 1,
        levelCompression: 1,
        displayCeiling: 1,
        hotResponse: 1.7,
        hotThreshold: 0.68,
        hotFillStrength: 0.86,
        vuPaletteDrive: 1.7,
        idleTint: 0.25,
        checkerContrast: 0.08,
        memoryCarryover: 0.68,
        checkerBandVelocity: 0.826,
        checkerBandWidth: 0.831,
        speakerZScale: 1,
        bloomMin: 0.08,
        bloomMax: 0.92,
        bloomEdge: 0.16,
        responseCurve: 0.72,
        peakHoldSeconds: 0.35,
        releaseMemory: 0.68,
        hotFill: 0.86,
        facePixels: 9,
        showsDiagnostics: false
    )

    public let visualGainDB: Float
    public let style: SpeakerMeterVisualStyle
    public let colorScheme: SpeakerMeterColorScheme
    public let ringFrontDensity: Float
    public let bandSoftness: Float
    public let tileDetail: Int
    public let inputCalibration: Float
    public let levelCompression: Float
    public let displayCeiling: Float
    public let hotResponse: Float
    public let hotThreshold: Float
    public let hotFillStrength: Float
    public let vuPaletteDrive: Float
    public let idleTint: Float
    public let checkerContrast: Float
    public let memoryCarryover: Float
    public let checkerBandVelocity: Float
    public let checkerBandWidth: Float
    public let speakerZScale: Float
    public let bloomMin: Float
    public let bloomMax: Float
    public let bloomEdge: Float
    public let responseCurve: Float
    public let peakHoldSeconds: Float
    public let releaseMemory: Float
    public let hotFill: Float
    public let facePixels: Int
    public let showsDiagnostics: Bool

    public init(
        visualGainDB: Float = 0,
        style: SpeakerMeterVisualStyle = .cubeScalarCenterBloom,
        colorScheme: SpeakerMeterColorScheme = .daftPunkBow,
        ringFrontDensity: Float = 3.3,
        bandSoftness: Float = 0.85,
        tileDetail: Int = 10,
        inputCalibration: Float = 1,
        levelCompression: Float = 1,
        displayCeiling: Float = 1,
        hotResponse: Float = 1.7,
        hotThreshold: Float = 0.68,
        hotFillStrength: Float = 0.86,
        vuPaletteDrive: Float = 1.7,
        idleTint: Float = 0.25,
        checkerContrast: Float = 0.08,
        memoryCarryover: Float = 0.68,
        checkerBandVelocity: Float = 0.826,
        checkerBandWidth: Float = 0.831,
        speakerZScale: Float = 1,
        bloomMin: Float = 0.08,
        bloomMax: Float = 0.92,
        bloomEdge: Float = 0.16,
        responseCurve: Float = 0.72,
        peakHoldSeconds: Float = 0.35,
        releaseMemory: Float = 0.68,
        hotFill: Float = 0.86,
        facePixels: Int = 9,
        showsDiagnostics: Bool = false
    ) throws {
        self.visualGainDB = visualGainDB
        self.style = style
        self.colorScheme = colorScheme
        self.ringFrontDensity = ringFrontDensity
        self.bandSoftness = bandSoftness
        self.tileDetail = tileDetail
        self.inputCalibration = inputCalibration
        self.levelCompression = levelCompression
        self.displayCeiling = displayCeiling
        self.hotResponse = hotResponse
        self.hotThreshold = hotThreshold
        self.hotFillStrength = hotFillStrength
        self.vuPaletteDrive = vuPaletteDrive
        self.idleTint = idleTint
        self.checkerContrast = checkerContrast
        self.memoryCarryover = memoryCarryover
        self.checkerBandVelocity = checkerBandVelocity
        self.checkerBandWidth = checkerBandWidth
        self.speakerZScale = speakerZScale
        self.bloomMin = bloomMin
        self.bloomMax = bloomMax
        self.bloomEdge = bloomEdge
        self.responseCurve = responseCurve
        self.peakHoldSeconds = peakHoldSeconds
        self.releaseMemory = releaseMemory
        self.hotFill = hotFill
        self.facePixels = facePixels
        self.showsDiagnostics = showsDiagnostics
        try validate()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = Self.default
        let visualGainDB = try container.decodeIfPresent(Float.self, forKey: .visualGainDB) ?? defaults.visualGainDB
        let style = try container.decodeIfPresent(SpeakerMeterVisualStyle.self, forKey: .style) ?? defaults.style
        let colorScheme = try container.decodeIfPresent(SpeakerMeterColorScheme.self, forKey: .colorScheme) ?? defaults.colorScheme
        let ringFrontDensity = try container.decodeIfPresent(Float.self, forKey: .ringFrontDensity) ?? defaults.ringFrontDensity
        let bandSoftness = try container.decodeIfPresent(Float.self, forKey: .bandSoftness) ?? defaults.bandSoftness
        let tileDetail = try container.decodeIfPresent(Int.self, forKey: .tileDetail) ?? defaults.tileDetail
        let inputCalibration = try container.decodeIfPresent(Float.self, forKey: .inputCalibration) ?? defaults.inputCalibration
        let levelCompression = try container.decodeIfPresent(Float.self, forKey: .levelCompression) ?? defaults.levelCompression
        let displayCeiling = try container.decodeIfPresent(Float.self, forKey: .displayCeiling) ?? defaults.displayCeiling
        let hotResponse = try container.decodeIfPresent(Float.self, forKey: .hotResponse) ?? defaults.hotResponse
        let hotThreshold = try container.decodeIfPresent(Float.self, forKey: .hotThreshold) ?? defaults.hotThreshold
        let hotFillStrength = try container.decodeIfPresent(Float.self, forKey: .hotFillStrength) ?? defaults.hotFillStrength
        let vuPaletteDrive = try container.decodeIfPresent(Float.self, forKey: .vuPaletteDrive) ?? defaults.vuPaletteDrive
        let idleTint = try container.decodeIfPresent(Float.self, forKey: .idleTint) ?? defaults.idleTint
        let checkerContrast = try container.decodeIfPresent(Float.self, forKey: .checkerContrast) ?? defaults.checkerContrast
        let memoryCarryover = try container.decodeIfPresent(Float.self, forKey: .memoryCarryover) ?? defaults.memoryCarryover
        let checkerBandVelocity = try container.decodeIfPresent(Float.self, forKey: .checkerBandVelocity) ?? defaults.checkerBandVelocity
        let checkerBandWidth = try container.decodeIfPresent(Float.self, forKey: .checkerBandWidth) ?? defaults.checkerBandWidth
        let speakerZScale = try container.decodeIfPresent(Float.self, forKey: .speakerZScale) ?? defaults.speakerZScale
        let bloomMin = try container.decodeIfPresent(Float.self, forKey: .bloomMin) ?? defaults.bloomMin
        let bloomMax = try container.decodeIfPresent(Float.self, forKey: .bloomMax) ?? defaults.bloomMax
        let bloomEdge = try container.decodeIfPresent(Float.self, forKey: .bloomEdge) ?? defaults.bloomEdge
        let responseCurve = try container.decodeIfPresent(Float.self, forKey: .responseCurve) ?? defaults.responseCurve
        let peakHoldSeconds = try container.decodeIfPresent(Float.self, forKey: .peakHoldSeconds) ?? defaults.peakHoldSeconds
        let releaseMemory = try container.decodeIfPresent(Float.self, forKey: .releaseMemory) ?? defaults.releaseMemory
        let hotFill = try container.decodeIfPresent(Float.self, forKey: .hotFill) ?? defaults.hotFill
        let facePixels = try container.decodeIfPresent(Int.self, forKey: .facePixels) ?? defaults.facePixels
        let showsDiagnostics = try container.decodeIfPresent(Bool.self, forKey: .showsDiagnostics) ?? defaults.showsDiagnostics
        try self.init(
            visualGainDB: visualGainDB,
            style: style,
            colorScheme: colorScheme,
            ringFrontDensity: ringFrontDensity,
            bandSoftness: bandSoftness,
            tileDetail: tileDetail,
            inputCalibration: inputCalibration,
            levelCompression: levelCompression,
            displayCeiling: displayCeiling,
            hotResponse: hotResponse,
            hotThreshold: hotThreshold,
            hotFillStrength: hotFillStrength,
            vuPaletteDrive: vuPaletteDrive,
            idleTint: idleTint,
            checkerContrast: checkerContrast,
            memoryCarryover: memoryCarryover,
            checkerBandVelocity: checkerBandVelocity,
            checkerBandWidth: checkerBandWidth,
            speakerZScale: speakerZScale,
            bloomMin: bloomMin,
            bloomMax: bloomMax,
            bloomEdge: bloomEdge,
            responseCurve: responseCurve,
            peakHoldSeconds: peakHoldSeconds,
            releaseMemory: releaseMemory,
            hotFill: hotFill,
            facePixels: facePixels,
            showsDiagnostics: showsDiagnostics
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
        try container.encode(inputCalibration, forKey: .inputCalibration)
        try container.encode(levelCompression, forKey: .levelCompression)
        try container.encode(displayCeiling, forKey: .displayCeiling)
        try container.encode(hotResponse, forKey: .hotResponse)
        try container.encode(hotThreshold, forKey: .hotThreshold)
        try container.encode(hotFillStrength, forKey: .hotFillStrength)
        try container.encode(vuPaletteDrive, forKey: .vuPaletteDrive)
        try container.encode(idleTint, forKey: .idleTint)
        try container.encode(checkerContrast, forKey: .checkerContrast)
        try container.encode(memoryCarryover, forKey: .memoryCarryover)
        try container.encode(checkerBandVelocity, forKey: .checkerBandVelocity)
        try container.encode(checkerBandWidth, forKey: .checkerBandWidth)
        try container.encode(speakerZScale, forKey: .speakerZScale)
        try container.encode(bloomMin, forKey: .bloomMin)
        try container.encode(bloomMax, forKey: .bloomMax)
        try container.encode(bloomEdge, forKey: .bloomEdge)
        try container.encode(responseCurve, forKey: .responseCurve)
        try container.encode(peakHoldSeconds, forKey: .peakHoldSeconds)
        try container.encode(releaseMemory, forKey: .releaseMemory)
        try container.encode(hotFill, forKey: .hotFill)
        try container.encode(facePixels, forKey: .facePixels)
        try container.encode(showsDiagnostics, forKey: .showsDiagnostics)
    }

    private init(
        uncheckedVisualGainDB visualGainDB: Float,
        style: SpeakerMeterVisualStyle,
        colorScheme: SpeakerMeterColorScheme,
        ringFrontDensity: Float,
        bandSoftness: Float,
        tileDetail: Int,
        inputCalibration: Float,
        levelCompression: Float,
        displayCeiling: Float,
        hotResponse: Float,
        hotThreshold: Float,
        hotFillStrength: Float,
        vuPaletteDrive: Float,
        idleTint: Float,
        checkerContrast: Float,
        memoryCarryover: Float,
        checkerBandVelocity: Float,
        checkerBandWidth: Float,
        speakerZScale: Float,
        bloomMin: Float,
        bloomMax: Float,
        bloomEdge: Float,
        responseCurve: Float,
        peakHoldSeconds: Float,
        releaseMemory: Float,
        hotFill: Float,
        facePixels: Int,
        showsDiagnostics: Bool
    ) {
        self.visualGainDB = visualGainDB
        self.style = style
        self.colorScheme = colorScheme
        self.ringFrontDensity = ringFrontDensity
        self.bandSoftness = bandSoftness
        self.tileDetail = tileDetail
        self.inputCalibration = inputCalibration
        self.levelCompression = levelCompression
        self.displayCeiling = displayCeiling
        self.hotResponse = hotResponse
        self.hotThreshold = hotThreshold
        self.hotFillStrength = hotFillStrength
        self.vuPaletteDrive = vuPaletteDrive
        self.idleTint = idleTint
        self.checkerContrast = checkerContrast
        self.memoryCarryover = memoryCarryover
        self.checkerBandVelocity = checkerBandVelocity
        self.checkerBandWidth = checkerBandWidth
        self.speakerZScale = speakerZScale
        self.bloomMin = bloomMin
        self.bloomMax = bloomMax
        self.bloomEdge = bloomEdge
        self.responseCurve = responseCurve
        self.peakHoldSeconds = peakHoldSeconds
        self.releaseMemory = releaseMemory
        self.hotFill = hotFill
        self.facePixels = facePixels
        self.showsDiagnostics = showsDiagnostics
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
            field: "meterVisual.inputCalibration",
            value: inputCalibration,
            validRange: Self.minInputCalibration...Self.maxInputCalibration,
            validRangeDescription: "0.25...2"
        )
        try validateFiniteRange(
            field: "meterVisual.levelCompression",
            value: levelCompression,
            validRange: Self.minLevelCompression...Self.maxLevelCompression,
            validRangeDescription: "1...4"
        )
        try validateFiniteRange(
            field: "meterVisual.displayCeiling",
            value: displayCeiling,
            validRange: Self.minDisplayCeiling...Self.maxDisplayCeiling,
            validRangeDescription: "0.5...1"
        )
        try validateFiniteRange(
            field: "meterVisual.hotResponse",
            value: hotResponse,
            validRange: Self.minHotResponse...Self.maxHotResponse,
            validRangeDescription: "0.5...3"
        )
        try validateFiniteRange(
            field: "meterVisual.hotThreshold",
            value: hotThreshold,
            validRange: Self.minHotThreshold...Self.maxHotThreshold,
            validRangeDescription: "0.35...0.98"
        )
        try validateFiniteRange(
            field: "meterVisual.hotFillStrength",
            value: hotFillStrength,
            validRange: 0...1,
            validRangeDescription: "0...1"
        )
        try validateFiniteRange(
            field: "meterVisual.vuPaletteDrive",
            value: vuPaletteDrive,
            validRange: Self.minVUPaletteDrive...Self.maxVUPaletteDrive,
            validRangeDescription: "0.5...4"
        )
        try validateFiniteRange(
            field: "meterVisual.idleTint",
            value: idleTint,
            validRange: 0...1,
            validRangeDescription: "0...1"
        )
        try validateFiniteRange(
            field: "meterVisual.checkerContrast",
            value: checkerContrast,
            validRange: 0...0.4,
            validRangeDescription: "0...0.4"
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
        try validateFiniteRange(
            field: "meterVisual.speakerZScale",
            value: speakerZScale,
            validRange: Self.minSpeakerZScale...Self.maxSpeakerZScale,
            validRangeDescription: "1...2"
        )
        try validateFiniteRange(
            field: "meterVisual.bloomMin",
            value: bloomMin,
            validRange: 0...1,
            validRangeDescription: "0...1"
        )
        try validateFiniteRange(
            field: "meterVisual.bloomMax",
            value: bloomMax,
            validRange: 0...1,
            validRangeDescription: "0...1"
        )
        guard bloomMax >= bloomMin else {
            throw OrbitalViewValidationError.invalidRange(
                field: "meterVisual.bloomMax",
                value: Double(bloomMax),
                validRange: ">= bloomMin"
            )
        }
        try validateFiniteRange(
            field: "meterVisual.bloomEdge",
            value: bloomEdge,
            validRange: 0.001...1,
            validRangeDescription: "0.001...1"
        )
        try validateFiniteRange(
            field: "meterVisual.responseCurve",
            value: responseCurve,
            validRange: 0.2...4,
            validRangeDescription: "0.2...4"
        )
        try validateFiniteRange(
            field: "meterVisual.peakHoldSeconds",
            value: peakHoldSeconds,
            validRange: 0...3,
            validRangeDescription: "0...3"
        )
        try validateFiniteRange(
            field: "meterVisual.releaseMemory",
            value: releaseMemory,
            validRange: 0...1,
            validRangeDescription: "0...1"
        )
        try validateFiniteRange(
            field: "meterVisual.hotFill",
            value: hotFill,
            validRange: 0...1,
            validRangeDescription: "0...1"
        )

        guard tileDetail >= 4, tileDetail <= 32 else {
            throw OrbitalViewValidationError.invalidRange(
                field: "meterVisual.tileDetail",
                value: Double(tileDetail),
                validRange: "4...32"
            )
        }

        guard facePixels >= 4, facePixels <= 64 else {
            throw OrbitalViewValidationError.invalidRange(
                field: "meterVisual.facePixels",
                value: Double(facePixels),
                validRange: "4...64"
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

public struct SpeakerCubeVUScalars: Equatable, Sendable {
    public let rawRms: Float
    public let calibratedRms: Float
    public let displayVuScalar: Float
    public let hotScalar: Float
    public let paletteHeat: Float

    public init(rawRms: Float, settings: SpeakerMeterVisualSettings, paletteValue: Float? = nil) {
        let raw = Self.clamp01(rawRms)
        self.rawRms = raw
        calibratedRms = Self.clamp01(raw * settings.inputCalibration)
        displayVuScalar = min(Self.compress(calibratedRms, exponent: settings.levelCompression), settings.displayCeiling)
        hotScalar = Self.compress(calibratedRms, exponent: settings.hotResponse)
        paletteHeat = Self.compress(Self.clamp01(paletteValue ?? displayVuScalar), exponent: settings.vuPaletteDrive)
    }

    private static func compress(_ value: Float, exponent: Float) -> Float {
        1 - powf(1 - clamp01(value), max(exponent, 0.000_001))
    }

    private static func clamp01(_ value: Float) -> Float {
        guard value.isFinite else { return 0 }
        return min(max(value, 0), 1)
    }
}
