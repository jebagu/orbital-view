import Foundation

public struct OrbitalViewSceneBounds: Equatable, Codable, Sendable {
    public static let defaultMinimumHalfExtent: Double = 1
    public static let defaultMaximumHalfExtent: Double = 8

    public let minimum: OrbitalViewVector3
    public let maximum: OrbitalViewVector3
    public let center: OrbitalViewVector3
    public let halfExtent: Double

    public init(
        minimum: OrbitalViewVector3,
        maximum: OrbitalViewVector3,
        minimumHalfExtent: Double = Self.defaultMinimumHalfExtent,
        maximumHalfExtent: Double = Self.defaultMaximumHalfExtent
    ) throws {
        try minimum.validate(fieldPrefix: "sceneBounds.minimum")
        try maximum.validate(fieldPrefix: "sceneBounds.maximum")
        guard minimumHalfExtent.isFinite, minimumHalfExtent > 0 else {
            throw OrbitalViewValidationError.nonPositiveValue(
                field: "sceneBounds.minimumHalfExtent",
                value: minimumHalfExtent
            )
        }
        guard maximumHalfExtent.isFinite, maximumHalfExtent >= minimumHalfExtent else {
            throw OrbitalViewValidationError.invalidRange(
                field: "sceneBounds.maximumHalfExtent",
                value: maximumHalfExtent,
                validRange: ">= minimumHalfExtent"
            )
        }

        self.minimum = minimum
        self.maximum = maximum
        self.center = try OrbitalViewVector3(
            x: (minimum.x + maximum.x) * 0.5,
            y: (minimum.y + maximum.y) * 0.5,
            z: (minimum.z + maximum.z) * 0.5
        )
        let rawHalfExtent = max(
            abs(maximum.x - minimum.x) * 0.5,
            abs(maximum.y - minimum.y) * 0.5,
            abs(maximum.z - minimum.z) * 0.5
        )
        self.halfExtent = min(maximumHalfExtent, max(minimumHalfExtent, rawHalfExtent))
    }

    public static func enclosing(
        _ points: [OrbitalViewVector3],
        minimumHalfExtent: Double = Self.defaultMinimumHalfExtent,
        maximumHalfExtent: Double = Self.defaultMaximumHalfExtent
    ) throws -> OrbitalViewSceneBounds {
        guard let first = points.first else {
            return try OrbitalViewSceneBounds(
                minimum: .origin,
                maximum: .origin,
                minimumHalfExtent: minimumHalfExtent,
                maximumHalfExtent: maximumHalfExtent
            )
        }

        var minX = first.x
        var minY = first.y
        var minZ = first.z
        var maxX = first.x
        var maxY = first.y
        var maxZ = first.z

        for point in points {
            try point.validate(fieldPrefix: "sceneBounds.point")
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            minZ = min(minZ, point.z)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
            maxZ = max(maxZ, point.z)
        }

        return try OrbitalViewSceneBounds(
            minimum: OrbitalViewVector3(x: minX, y: minY, z: minZ),
            maximum: OrbitalViewVector3(x: maxX, y: maxY, z: maxZ),
            minimumHalfExtent: minimumHalfExtent,
            maximumHalfExtent: maximumHalfExtent
        )
    }
}
