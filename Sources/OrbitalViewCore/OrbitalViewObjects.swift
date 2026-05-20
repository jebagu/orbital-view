import Foundation

public struct OrbitalViewObjectFrameSet: Equatable, Sendable {
    public static let maxObjectCount = 128

    public let timestamp: TimeInterval
    public let activeObjects: [OrbitalViewObjectFrame]
    public let maxActiveObjects: Int
    public let maxTrailPointsPerObject: Int

    public init(
        timestamp: TimeInterval,
        activeObjects: [OrbitalViewObjectFrame],
        maxActiveObjects: Int = Self.maxObjectCount,
        maxTrailPointsPerObject: Int = ObjectVisualSettings.default.maxTrailPointsPerObject
    ) throws {
        self.timestamp = timestamp
        self.activeObjects = activeObjects
        self.maxActiveObjects = maxActiveObjects
        self.maxTrailPointsPerObject = maxTrailPointsPerObject
        try validate()
    }

    public func validate() throws {
        guard timestamp.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "objectFrame.timestamp")
        }
        guard maxActiveObjects >= 0, maxActiveObjects <= Self.maxObjectCount else {
            throw OrbitalViewValidationError.invalidRange(
                field: "objectFrame.maxActiveObjects",
                value: Double(maxActiveObjects),
                validRange: "0...128"
            )
        }
        guard maxTrailPointsPerObject >= 0, maxTrailPointsPerObject <= ObjectVisualSettings.maxTrailPointsLimit else {
            throw OrbitalViewValidationError.invalidRange(
                field: "objectFrame.maxTrailPointsPerObject",
                value: Double(maxTrailPointsPerObject),
                validRange: "0...\(ObjectVisualSettings.maxTrailPointsLimit)"
            )
        }
        guard activeObjects.count <= maxActiveObjects else {
            throw OrbitalViewValidationError.invalidRange(
                field: "objectFrame.activeObjects",
                value: Double(activeObjects.count),
                validRange: "0...\(maxActiveObjects)"
            )
        }

        var objectIDs = Set<Int>()
        for object in activeObjects {
            try object.validate()
            guard objectIDs.insert(object.objectID).inserted else {
                throw OrbitalViewValidationError.duplicateObjectID(object.objectID)
            }
            guard object.trail.count <= maxTrailPointsPerObject else {
                throw OrbitalViewValidationError.invalidRange(
                    field: "objectFrame.trail",
                    value: Double(object.trail.count),
                    validRange: "0...\(maxTrailPointsPerObject)"
                )
            }
        }
    }
}

public struct OrbitalViewObjectFrame: Equatable, Sendable {
    public let objectID: Int
    public let label: String
    public let category: String
    public let pose: UnitSphereDirection
    public let width: Float
    public let trail: [UnitSphereDirection]

    public init(
        objectID: Int,
        label: String,
        category: String = "source",
        pose: UnitSphereDirection,
        width: Float = 0,
        trail: [UnitSphereDirection] = []
    ) throws {
        self.objectID = objectID
        self.label = label
        self.category = category
        self.pose = pose
        self.width = width
        self.trail = trail
        try validate()
    }

    public func validate() throws {
        try validateSourceObjectID(objectID, field: "object.objectID")
        guard !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyLabel
        }
        guard !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "object.category")
        }
        guard width.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "object.width")
        }
        guard width >= 0 else {
            throw OrbitalViewValidationError.invalidRange(
                field: "object.width",
                value: Double(width),
                validRange: ">= 0"
            )
        }
    }
}

public struct ObjectMeterFrame: Equatable, Sendable {
    public let timestamp: TimeInterval
    public let levelsByObjectID: [Int: ObjectMeterLevel]

    public init(timestamp: TimeInterval, levelsByObjectID: [Int: ObjectMeterLevel]) throws {
        self.timestamp = timestamp
        self.levelsByObjectID = levelsByObjectID
        try validate()
    }

    public func validate() throws {
        guard timestamp.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "objectMeter.timestamp")
        }
        for objectID in levelsByObjectID.keys {
            try validateSourceObjectID(objectID, field: "objectMeter.objectID")
        }
    }
}

public struct ObjectMeterLevel: Equatable, Sendable {
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
            throw OrbitalViewValidationError.nonFiniteValue(field: "objectMeter.rms")
        }
        guard peak.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "objectMeter.peak")
        }
    }
}

public enum ObjectVisualShape: String, Codable, CaseIterable, Equatable, Sendable {
    case orb
    case halo
    case comet

    public var displayName: String {
        switch self {
        case .orb:
            return "Orb"
        case .halo:
            return "Halo"
        case .comet:
            return "Comet"
        }
    }
}

public enum ObjectVisualPalette: String, Codable, CaseIterable, Equatable, Sendable {
    case objectPurple
    case sourceGold
    case spectralBlue
    case monochrome

    public var displayName: String {
        switch self {
        case .objectPurple:
            return "Object Purple"
        case .sourceGold:
            return "Source Gold"
        case .spectralBlue:
            return "Spectral Blue"
        case .monochrome:
            return "Monochrome"
        }
    }
}

public struct ObjectVisualSettings: Equatable, Codable, Sendable {
    public static let maxTrailPointsLimit = 256
    public static let `default` = ObjectVisualSettings(
        uncheckedShape: .orb,
        palette: .objectPurple,
        coreSize: 0.055,
        widthScale: 1,
        smoothingHalfLifeSeconds: 0.08,
        visualLookbehindMilliseconds: 30,
        snapThresholdRadians: 0.95,
        glowIntensity: 0.65,
        clipFlashIntensity: 1,
        trailsEnabled: false,
        trailLengthSeconds: 1.2,
        trailDecay: 0.72,
        maxTrailPointsPerObject: 24,
        glowTrailsEnabled: false,
        glowTrailIntensity: 0.5,
        glowTrailWidth: 0.09,
        glowTrailDecay: 0.65,
        bounds: .default,
        showsBounds: false,
        showsClipDiagnostics: true
    )

    public let shape: ObjectVisualShape
    public let palette: ObjectVisualPalette
    public let coreSize: Float
    public let widthScale: Float
    public let smoothingHalfLifeSeconds: Float
    public let visualLookbehindMilliseconds: Float
    public let snapThresholdRadians: Float
    public let glowIntensity: Float
    public let clipFlashIntensity: Float
    public let trailsEnabled: Bool
    public let trailLengthSeconds: Float
    public let trailDecay: Float
    public let maxTrailPointsPerObject: Int
    public let glowTrailsEnabled: Bool
    public let glowTrailIntensity: Float
    public let glowTrailWidth: Float
    public let glowTrailDecay: Float
    public let bounds: OrbitalViewObjectRenderBounds
    public let showsBounds: Bool
    public let showsClipDiagnostics: Bool

    public init(
        shape: ObjectVisualShape = .orb,
        palette: ObjectVisualPalette = .objectPurple,
        coreSize: Float = 0.055,
        widthScale: Float = 1,
        smoothingHalfLifeSeconds: Float = 0.08,
        visualLookbehindMilliseconds: Float = 30,
        snapThresholdRadians: Float = 0.95,
        glowIntensity: Float = 0.65,
        clipFlashIntensity: Float = 1,
        trailsEnabled: Bool = false,
        trailLengthSeconds: Float = 1.2,
        trailDecay: Float = 0.72,
        maxTrailPointsPerObject: Int = 24,
        glowTrailsEnabled: Bool = false,
        glowTrailIntensity: Float = 0.5,
        glowTrailWidth: Float = 0.09,
        glowTrailDecay: Float = 0.65,
        bounds: OrbitalViewObjectRenderBounds = .default,
        showsBounds: Bool = false,
        showsClipDiagnostics: Bool = true
    ) throws {
        self.shape = shape
        self.palette = palette
        self.coreSize = coreSize
        self.widthScale = widthScale
        self.smoothingHalfLifeSeconds = smoothingHalfLifeSeconds
        self.visualLookbehindMilliseconds = visualLookbehindMilliseconds
        self.snapThresholdRadians = snapThresholdRadians
        self.glowIntensity = glowIntensity
        self.clipFlashIntensity = clipFlashIntensity
        self.trailsEnabled = trailsEnabled
        self.trailLengthSeconds = trailLengthSeconds
        self.trailDecay = trailDecay
        self.maxTrailPointsPerObject = maxTrailPointsPerObject
        self.glowTrailsEnabled = glowTrailsEnabled
        self.glowTrailIntensity = glowTrailIntensity
        self.glowTrailWidth = glowTrailWidth
        self.glowTrailDecay = glowTrailDecay
        self.bounds = bounds
        self.showsBounds = showsBounds
        self.showsClipDiagnostics = showsClipDiagnostics
        try validate()
    }

    private init(
        uncheckedShape shape: ObjectVisualShape,
        palette: ObjectVisualPalette,
        coreSize: Float,
        widthScale: Float,
        smoothingHalfLifeSeconds: Float,
        visualLookbehindMilliseconds: Float,
        snapThresholdRadians: Float,
        glowIntensity: Float,
        clipFlashIntensity: Float,
        trailsEnabled: Bool,
        trailLengthSeconds: Float,
        trailDecay: Float,
        maxTrailPointsPerObject: Int,
        glowTrailsEnabled: Bool,
        glowTrailIntensity: Float,
        glowTrailWidth: Float,
        glowTrailDecay: Float,
        bounds: OrbitalViewObjectRenderBounds,
        showsBounds: Bool,
        showsClipDiagnostics: Bool
    ) {
        self.shape = shape
        self.palette = palette
        self.coreSize = coreSize
        self.widthScale = widthScale
        self.smoothingHalfLifeSeconds = smoothingHalfLifeSeconds
        self.visualLookbehindMilliseconds = visualLookbehindMilliseconds
        self.snapThresholdRadians = snapThresholdRadians
        self.glowIntensity = glowIntensity
        self.clipFlashIntensity = clipFlashIntensity
        self.trailsEnabled = trailsEnabled
        self.trailLengthSeconds = trailLengthSeconds
        self.trailDecay = trailDecay
        self.maxTrailPointsPerObject = maxTrailPointsPerObject
        self.glowTrailsEnabled = glowTrailsEnabled
        self.glowTrailIntensity = glowTrailIntensity
        self.glowTrailWidth = glowTrailWidth
        self.glowTrailDecay = glowTrailDecay
        self.bounds = bounds
        self.showsBounds = showsBounds
        self.showsClipDiagnostics = showsClipDiagnostics
    }

    public func validate() throws {
        try validateFiniteRange(field: "objectVisual.coreSize", value: coreSize, validRange: 0.01...0.24, validRangeDescription: "0.01...0.24")
        try validateFiniteRange(field: "objectVisual.widthScale", value: widthScale, validRange: 0...5, validRangeDescription: "0...5")
        try validateFiniteRange(field: "objectVisual.smoothingHalfLifeSeconds", value: smoothingHalfLifeSeconds, validRange: 0...1, validRangeDescription: "0...1")
        try validateFiniteRange(field: "objectVisual.visualLookbehindMilliseconds", value: visualLookbehindMilliseconds, validRange: 0...120, validRangeDescription: "0...120")
        try validateFiniteRange(field: "objectVisual.snapThresholdRadians", value: snapThresholdRadians, validRange: 0...Float.pi, validRangeDescription: "0...pi")
        try validateFiniteRange(field: "objectVisual.glowIntensity", value: glowIntensity, validRange: 0...2, validRangeDescription: "0...2")
        try validateFiniteRange(field: "objectVisual.clipFlashIntensity", value: clipFlashIntensity, validRange: 0...2, validRangeDescription: "0...2")
        try validateFiniteRange(field: "objectVisual.trailLengthSeconds", value: trailLengthSeconds, validRange: 0...10, validRangeDescription: "0...10")
        try validateFiniteRange(field: "objectVisual.trailDecay", value: trailDecay, validRange: 0...1, validRangeDescription: "0...1")
        guard maxTrailPointsPerObject >= 0, maxTrailPointsPerObject <= Self.maxTrailPointsLimit else {
            throw OrbitalViewValidationError.invalidRange(
                field: "objectVisual.maxTrailPointsPerObject",
                value: Double(maxTrailPointsPerObject),
                validRange: "0...\(Self.maxTrailPointsLimit)"
            )
        }
        try validateFiniteRange(field: "objectVisual.glowTrailIntensity", value: glowTrailIntensity, validRange: 0...2, validRangeDescription: "0...2")
        try validateFiniteRange(field: "objectVisual.glowTrailWidth", value: glowTrailWidth, validRange: 0...0.5, validRangeDescription: "0...0.5")
        try validateFiniteRange(field: "objectVisual.glowTrailDecay", value: glowTrailDecay, validRange: 0...1, validRangeDescription: "0...1")
        try bounds.validate()
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

public struct OrbitalViewObjectRenderBounds: Equatable, Codable, Sendable {
    public static let `default` = OrbitalViewObjectRenderBounds(halfExtent: 5)

    public let halfExtent: Float

    public init(halfExtent: Float) {
        self.halfExtent = halfExtent
    }

    public var minimum: Float { -halfExtent }
    public var maximum: Float { halfExtent }

    public func validate() throws {
        guard halfExtent.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "objectBounds.halfExtent")
        }
        guard halfExtent > 0 else {
            throw OrbitalViewValidationError.nonPositiveValue(field: "objectBounds.halfExtent", value: Double(halfExtent))
        }
    }
}

func validateSourceObjectID(_ objectID: Int, field: String) throws {
    guard (1...OrbitalViewObjectFrameSet.maxObjectCount).contains(objectID) else {
        throw OrbitalViewValidationError.invalidObjectID(objectID)
    }
}
