import Foundation

public enum OrbitalViewShellSpec: Equatable, Codable, Sendable {
    case parametric(OrbitalViewParametricShell)
    case imported(OrbitalViewImportedShellGeometry)

    public func validate() throws {
        switch self {
        case .parametric(let shell):
            try shell.validate()
        case .imported(let geometry):
            try geometry.validate()
        }
    }
}

public enum OrbitalViewParametricShellKind: String, Codable, Equatable, Sendable {
    case geodesic
    case lamella
}

public struct OrbitalViewParametricShell: Equatable, Codable, Sendable {
    public let kind: OrbitalViewParametricShellKind
    public let radiusM: Double

    public init(kind: OrbitalViewParametricShellKind, radiusM: Double) throws {
        self.kind = kind
        self.radiusM = radiusM
        try validate()
    }

    public func validate() throws {
        guard radiusM.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "shell.radiusM")
        }

        guard radiusM > 0 else {
            throw OrbitalViewValidationError.nonPositiveValue(field: "shell.radiusM", value: radiusM)
        }
    }
}

public struct OrbitalViewImportedShellGeometry: Equatable, Codable, Sendable {
    public let radiusM: Double
    public let nodes: [ShellNode]
    public let edges: [ShellEdge]
    public let faces: [ShellFace]

    public init(radiusM: Double, nodes: [ShellNode], edges: [ShellEdge], faces: [ShellFace]) throws {
        self.radiusM = radiusM
        self.nodes = nodes
        self.edges = edges
        self.faces = faces
        try validate()
    }

    public func validate() throws {
        guard radiusM.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "shell.radiusM")
        }

        guard radiusM > 0 else {
            throw OrbitalViewValidationError.nonPositiveValue(field: "shell.radiusM", value: radiusM)
        }

        var nodeIDs = Set<String>()
        for node in nodes {
            try node.validate()
            guard nodeIDs.insert(node.id).inserted else {
                throw OrbitalViewValidationError.duplicateID(node.id)
            }
        }

        var edgeIDs = Set<String>()
        for edge in edges {
            try edge.validate()
            guard edgeIDs.insert(edge.id).inserted else {
                throw OrbitalViewValidationError.duplicateID(edge.id)
            }
            guard nodeIDs.contains(edge.a) else {
                throw OrbitalViewValidationError.unknownNodeID(edge.a)
            }
            guard nodeIDs.contains(edge.b) else {
                throw OrbitalViewValidationError.unknownNodeID(edge.b)
            }
            guard edge.a != edge.b else {
                throw OrbitalViewValidationError.invalidEdgeReference(
                    edgeID: edge.id,
                    reason: "edge endpoints must be different"
                )
            }
        }

        var faceIDs = Set<String>()
        for face in faces {
            try face.validate()
            guard faceIDs.insert(face.id).inserted else {
                throw OrbitalViewValidationError.duplicateID(face.id)
            }
            for nodeID in face.nodes {
                guard nodeIDs.contains(nodeID) else {
                    throw OrbitalViewValidationError.unknownNodeID(nodeID)
                }
            }
        }
    }
}

public struct ShellNode: Identifiable, Equatable, Codable, Sendable {
    public let id: String
    public let position: OrbitalViewVector3
    public let normal: OrbitalViewVector3?

    public init(id: String, position: OrbitalViewVector3, normal: OrbitalViewVector3? = nil) throws {
        self.id = id
        self.position = position
        self.normal = normal
        try validate()
    }

    public func validate() throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "node.id")
        }
        try position.validate(fieldPrefix: "node.position")
        try normal?.validate(fieldPrefix: "node.normal")
    }
}

public struct ShellEdge: Identifiable, Equatable, Codable, Sendable {
    public let id: String
    public let a: String
    public let b: String
    public let role: ShellEdgeRole

    public init(id: String, a: String, b: String, role: ShellEdgeRole = .strut) throws {
        self.id = id
        self.a = a
        self.b = b
        self.role = role
        try validate()
    }

    public func validate() throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "edge.id")
        }
        guard !a.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "edge.a")
        }
        guard !b.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "edge.b")
        }
    }
}

public struct ShellFace: Identifiable, Equatable, Codable, Sendable {
    public let id: String
    public let nodes: [String]

    public init(id: String, nodes: [String]) throws {
        self.id = id
        self.nodes = nodes
        try validate()
    }

    public func validate() throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "face.id")
        }
        guard nodes.count >= 3 else {
            throw OrbitalViewValidationError.invalidFaceReference(
                faceID: id,
                reason: "faces must reference at least three nodes"
            )
        }
        for nodeID in nodes {
            guard !nodeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw OrbitalViewValidationError.emptyID(field: "face.nodes")
            }
        }
    }
}

public enum ShellEdgeRole: String, Codable, Equatable, Sendable {
    case strut
    case hoop
    case lamella
    case seam
}

