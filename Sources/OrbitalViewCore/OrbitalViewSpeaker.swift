import Foundation

public struct OrbitalViewSpeaker: Identifiable, Equatable, Codable, Sendable {
    public let id: String
    public let channel: Int
    public let label: String
    public let anchor: SpeakerAnchor
    public let shape: SpeakerShape
    public let visualRole: SpeakerVisualRole

    public init(
        id: String,
        channel: Int,
        label: String,
        anchor: SpeakerAnchor,
        shape: SpeakerShape,
        visualRole: SpeakerVisualRole = .physicalSpeaker
    ) throws {
        self.id = id
        self.channel = channel
        self.label = label
        self.anchor = anchor
        self.shape = shape
        self.visualRole = visualRole
        try validate()
    }

    public func validate() throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "speaker.id")
        }

        guard channel > 0 else {
            throw OrbitalViewValidationError.invalidChannel(channel)
        }

        guard !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyLabel
        }

        try anchor.validate()
        try shape.validate()
    }
}

public enum SpeakerAnchor: Equatable, Codable, Sendable {
    case direction(UnitSphereDirection, offsetM: Double)
    case node(nodeID: String, offsetM: Double)
    case edge(edgeID: String, t: Double, offsetM: Double)
    case face(faceID: String, barycentric: OrbitalViewVector3, offsetM: Double)

    public func validate() throws {
        switch self {
        case .direction(_, let offsetM):
            try validateOffset(offsetM)
        case .node(let nodeID, let offsetM):
            guard !nodeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw OrbitalViewValidationError.emptyID(field: "speaker.anchor.nodeID")
            }
            try validateOffset(offsetM)
        case .edge(let edgeID, let t, let offsetM):
            guard !edgeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw OrbitalViewValidationError.emptyID(field: "speaker.anchor.edgeID")
            }
            guard t.isFinite else {
                throw OrbitalViewValidationError.nonFiniteValue(field: "speaker.anchor.t")
            }
            guard (0.0...1.0).contains(t) else {
                throw OrbitalViewValidationError.invalidRange(
                    field: "speaker.anchor.t",
                    value: t,
                    validRange: "0...1"
                )
            }
            try validateOffset(offsetM)
        case .face(let faceID, let barycentric, let offsetM):
            guard !faceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw OrbitalViewValidationError.emptyID(field: "speaker.anchor.faceID")
            }
            try barycentric.validate(fieldPrefix: "speaker.anchor.barycentric")
            try validateOffset(offsetM)
        }
    }

    private func validateOffset(_ offsetM: Double) throws {
        guard offsetM.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "speaker.anchor.offsetM")
        }
    }
}

public enum SpeakerShape: Equatable, Codable, Sendable {
    public static let defaultSonicSphereEdgeM: Double = 0.06
    public static let minSonicSphereZScale: Double = 1
    public static let maxSonicSphereZScale: Double = 2

    case sphere(radiusM: Double)
    case cube(edgeM: Double)
    case rectangularPrism(widthM: Double, heightM: Double, depthM: Double, bevelM: Double)

    public static func sonicSphereDefault(edgeM: Double = Self.defaultSonicSphereEdgeM) throws -> SpeakerShape {
        try cube(edgeM: edgeM).validated()
    }

    public static func sonicSphereRectangularPrism(edgeM: Double, zScale: Double) throws -> SpeakerShape {
        try validatePositive(edgeM, field: "speaker.shape.edgeM")
        try validateSonicSphereZScale(zScale)

        if zScale == 1 {
            return .cube(edgeM: edgeM)
        }

        return .rectangularPrism(
            widthM: edgeM,
            heightM: edgeM,
            depthM: edgeM * zScale,
            bevelM: 0
        )
    }

    public var sonicSphereZScale: Double? {
        switch self {
        case .cube:
            return 1
        case .rectangularPrism(let widthM, let heightM, let depthM, _)
            where widthM == heightM && widthM > 0:
            let zScale = depthM / widthM
            guard (Self.minSonicSphereZScale...Self.maxSonicSphereZScale).contains(zScale) else {
                return nil
            }
            return zScale
        case .sphere, .rectangularPrism:
            return nil
        }
    }

    public func validate() throws {
        switch self {
        case .sphere(let radiusM):
            try Self.validatePositive(radiusM, field: "speaker.shape.radiusM")
        case .cube(let edgeM):
            try Self.validatePositive(edgeM, field: "speaker.shape.edgeM")
        case .rectangularPrism(let widthM, let heightM, let depthM, let bevelM):
            try Self.validatePositive(widthM, field: "speaker.shape.widthM")
            try Self.validatePositive(heightM, field: "speaker.shape.heightM")
            try Self.validatePositive(depthM, field: "speaker.shape.depthM")
            guard bevelM.isFinite else {
                throw OrbitalViewValidationError.nonFiniteValue(field: "speaker.shape.bevelM")
            }
            guard bevelM >= 0 else {
                throw OrbitalViewValidationError.invalidRange(
                    field: "speaker.shape.bevelM",
                    value: bevelM,
                    validRange: ">= 0"
                )
            }
        }
    }

    private func validated() throws -> SpeakerShape {
        try validate()
        return self
    }

    public static func validateSonicSphereZScale(_ zScale: Double) throws {
        guard zScale.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "speaker.shape.zScale")
        }
        guard (minSonicSphereZScale...maxSonicSphereZScale).contains(zScale) else {
            throw OrbitalViewValidationError.invalidRange(
                field: "speaker.shape.zScale",
                value: zScale,
                validRange: "1...2"
            )
        }
    }

    private static func validatePositive(_ value: Double, field: String) throws {
        guard value.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: field)
        }
        guard value > 0 else {
            throw OrbitalViewValidationError.nonPositiveValue(field: field, value: value)
        }
    }
}

public enum SpeakerVisualRole: String, Codable, Equatable, Sendable {
    case physicalSpeaker
    case virtualSpeaker
    case source
    case diagnostic
}

public enum SpeakerFaceCenterBloom: Sendable {
    public static let centerU: Double = 0.5
    public static let centerV: Double = 0.5

    public static func normalizedDistanceFromFaceCenter(u: Double, v: Double) throws -> Double {
        try validateFaceCoordinate(u, field: "speaker.face.u")
        try validateFaceCoordinate(v, field: "speaker.face.v")

        return hypot(u - centerU, v - centerV) * sqrt(2)
    }

    private static func validateFaceCoordinate(_ value: Double, field: String) throws {
        guard value.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: field)
        }
        guard (0...1).contains(value) else {
            throw OrbitalViewValidationError.invalidRange(field: field, value: value, validRange: "0...1")
        }
    }
}
