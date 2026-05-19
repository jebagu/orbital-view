import Foundation

public struct OrbitalViewCameraState: Equatable, Sendable {
    public let mode: OrbitalViewMode
    public let projection: OrbitalViewProjection
    public let orbit: OrbitalViewOrbit
    public let target: OrbitalViewVector3

    public init(
        mode: OrbitalViewMode,
        projection: OrbitalViewProjection,
        orbit: OrbitalViewOrbit,
        target: OrbitalViewVector3,
        enforceCenterLock: Bool = false
    ) throws {
        self.mode = mode
        self.projection = projection
        self.orbit = orbit
        self.target = target
        try validate(enforceCenterLock: enforceCenterLock)
    }

    public static func preset(
        _ mode: OrbitalViewMode,
        projection: OrbitalViewProjection = .perspective,
        distanceM: Double = 4.0
    ) throws -> OrbitalViewCameraState {
        guard mode != .custom else {
            return try OrbitalViewCameraState(
                mode: .custom,
                projection: projection,
                orbit: OrbitalViewOrbit(yawRadians: 0, pitchRadians: 0, distanceM: distanceM),
                target: .origin,
                enforceCenterLock: true
            )
        }

        let orbit: OrbitalViewOrbit
        switch mode {
        case .plan:
            orbit = try OrbitalViewOrbit(yawRadians: 0, pitchRadians: .pi / 2.0, distanceM: distanceM)
        case .frontElevation:
            orbit = try OrbitalViewOrbit(yawRadians: 0, pitchRadians: 0, distanceM: distanceM)
        case .sideElevation:
            orbit = try OrbitalViewOrbit(yawRadians: .pi / 2.0, pitchRadians: 0, distanceM: distanceM)
        case .isometric:
            orbit = try OrbitalViewOrbit(yawRadians: .pi / 4.0, pitchRadians: .pi / 6.0, distanceM: distanceM)
        case .custom:
            orbit = try OrbitalViewOrbit(yawRadians: 0, pitchRadians: 0, distanceM: distanceM)
        }

        return try OrbitalViewCameraState(
            mode: mode,
            projection: projection,
            orbit: orbit,
            target: .origin,
            enforceCenterLock: true
        )
    }

    public func validate(enforceCenterLock: Bool) throws {
        try orbit.validate()
        try target.validate(fieldPrefix: "camera.target")
        if enforceCenterLock && !target.isApproximatelyOrigin() {
            throw OrbitalViewValidationError.nonOriginMonitorTarget(target)
        }
    }
}

public enum OrbitalViewMode: String, Codable, Equatable, Sendable, CaseIterable {
    case plan
    case frontElevation
    case sideElevation
    case isometric
    case custom
}

public enum OrbitalViewProjection: String, Codable, Equatable, Sendable {
    case perspective
    case orthographic
}

public struct OrbitalViewOrbit: Equatable, Codable, Sendable {
    public let yawRadians: Double
    public let pitchRadians: Double
    public let distanceM: Double

    public init(yawRadians: Double, pitchRadians: Double, distanceM: Double) throws {
        self.yawRadians = yawRadians
        self.pitchRadians = pitchRadians
        self.distanceM = distanceM
        try validate()
    }

    public func validate() throws {
        guard yawRadians.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "camera.orbit.yawRadians")
        }
        guard pitchRadians.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "camera.orbit.pitchRadians")
        }
        guard distanceM.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "camera.orbit.distanceM")
        }
        guard distanceM > 0 else {
            throw OrbitalViewValidationError.nonPositiveValue(field: "camera.orbit.distanceM", value: distanceM)
        }
    }
}

