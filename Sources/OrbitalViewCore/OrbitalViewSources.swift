import Foundation

public struct OrbitalViewSourceLayout: Equatable, Sendable {
    public static let maxSourceCount = 256

    public let id: String
    public let sources: [OrbitalViewSource]
    public let bounds: OrbitalViewSceneBounds

    public init(id: String, sources: [OrbitalViewSource]) throws {
        self.id = id
        self.sources = sources
        self.bounds = try OrbitalViewSceneBounds.enclosing(sources.map(\.position))
        try validate()
    }

    public func validate() throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "sourceLayout.id")
        }
        guard sources.count <= Self.maxSourceCount else {
            throw OrbitalViewValidationError.invalidRange(
                field: "sourceLayout.sources",
                value: Double(sources.count),
                validRange: "0...\(Self.maxSourceCount)"
            )
        }
        var ids = Set<Int>()
        for source in sources {
            try source.validate()
            guard ids.insert(source.sourceID).inserted else {
                throw OrbitalViewValidationError.duplicateObjectID(source.sourceID)
            }
        }
    }
}

public struct OrbitalViewSource: Identifiable, Equatable, Sendable {
    public let sourceID: Int
    public let label: String
    public let position: OrbitalViewVector3
    public let horizontalSpan: Float
    public let verticalSpan: Float
    public let isDirectOut: Bool

    public var id: Int { sourceID }

    public init(
        sourceID: Int,
        label: String,
        position: OrbitalViewVector3,
        horizontalSpan: Float = 0,
        verticalSpan: Float = 0,
        isDirectOut: Bool = false
    ) throws {
        self.sourceID = sourceID
        self.label = label
        self.position = position
        self.horizontalSpan = horizontalSpan
        self.verticalSpan = verticalSpan
        self.isDirectOut = isDirectOut
        try validate()
    }

    public func validate() throws {
        try validateSourceID(sourceID, field: "source.sourceID")
        guard !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyLabel
        }
        try position.validate(fieldPrefix: "source.position")
        try validateSpan(horizontalSpan, field: "source.horizontalSpan")
        try validateSpan(verticalSpan, field: "source.verticalSpan")
    }
}

public struct SourceMeterFrame: Equatable, Sendable {
    public let timestamp: TimeInterval
    public let levelsBySourceID: [Int: ObjectMeterLevel]
    public let source: OrbitalViewTelemetrySourceDescriptor

    public init(
        timestamp: TimeInterval,
        levelsBySourceID: [Int: ObjectMeterLevel],
        source: OrbitalViewTelemetrySourceDescriptor = .objectBus
    ) throws {
        self.timestamp = timestamp
        self.levelsBySourceID = levelsBySourceID
        self.source = source
        try validate()
    }

    public func validate() throws {
        guard timestamp.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "sourceMeter.timestamp")
        }
        try source.validate()
        for sourceID in levelsBySourceID.keys {
            try validateSourceID(sourceID, field: "sourceMeter.sourceID")
        }
    }
}

public func validateSourceID(_ sourceID: Int, field: String = "sourceID") throws {
    guard (1...OrbitalViewSourceLayout.maxSourceCount).contains(sourceID) else {
        throw OrbitalViewValidationError.invalidObjectID(sourceID)
    }
}

private func validateSpan(_ span: Float, field: String) throws {
    guard span.isFinite else {
        throw OrbitalViewValidationError.nonFiniteValue(field: field)
    }
    guard (0...1).contains(span) else {
        throw OrbitalViewValidationError.invalidRange(
            field: field,
            value: Double(span),
            validRange: "0...1"
        )
    }
}
