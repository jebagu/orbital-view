import Foundation

public struct OrbitalViewVector3: Equatable, Codable, Sendable {
    public static let origin = OrbitalViewVector3(uncheckedX: 0, y: 0, z: 0)

    public let x: Double
    public let y: Double
    public let z: Double

    public init(x: Double, y: Double, z: Double) throws {
        guard x.isFinite else { throw OrbitalViewValidationError.nonFiniteValue(field: "x") }
        guard y.isFinite else { throw OrbitalViewValidationError.nonFiniteValue(field: "y") }
        guard z.isFinite else { throw OrbitalViewValidationError.nonFiniteValue(field: "z") }

        self.x = x
        self.y = y
        self.z = z
    }

    init(uncheckedX x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public var magnitude: Double {
        sqrt((x * x) + (y * y) + (z * z))
    }

    public func validate(fieldPrefix: String = "vector") throws {
        guard x.isFinite else { throw OrbitalViewValidationError.nonFiniteValue(field: "\(fieldPrefix).x") }
        guard y.isFinite else { throw OrbitalViewValidationError.nonFiniteValue(field: "\(fieldPrefix).y") }
        guard z.isFinite else { throw OrbitalViewValidationError.nonFiniteValue(field: "\(fieldPrefix).z") }
    }

    public func isApproximatelyOrigin(tolerance: Double = 1.0e-9) -> Bool {
        abs(x) <= tolerance && abs(y) <= tolerance && abs(z) <= tolerance
    }
}

public struct UnitSphereDirection: Equatable, Codable, Sendable {
    public static let defaultTolerance = 1.0e-6

    public let x: Double
    public let y: Double
    public let z: Double

    public init(x: Double, y: Double, z: Double, tolerance: Double = UnitSphereDirection.defaultTolerance) throws {
        let vector = try OrbitalViewVector3(x: x, y: y, z: z)
        let magnitude = vector.magnitude

        guard magnitude > 0 else {
            throw OrbitalViewValidationError.zeroVector
        }

        guard abs(magnitude - 1.0) <= tolerance else {
            throw OrbitalViewValidationError.invalidUnitVectorMagnitude(magnitude)
        }

        self.x = x
        self.y = y
        self.z = z
    }

    public static func normalized(x: Double, y: Double, z: Double) throws -> UnitSphereDirection {
        let vector = try OrbitalViewVector3(x: x, y: y, z: z)
        let magnitude = vector.magnitude

        guard magnitude > 0 else {
            throw OrbitalViewValidationError.zeroVector
        }

        return try UnitSphereDirection(
            x: x / magnitude,
            y: y / magnitude,
            z: z / magnitude
        )
    }

    public var vector: OrbitalViewVector3 {
        OrbitalViewVector3(uncheckedX: x, y: y, z: z)
    }
}

