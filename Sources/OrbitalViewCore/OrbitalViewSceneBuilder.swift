import Foundation

public enum OrbitalViewSceneBuilder {
    public static let feySphereRadiusM = 3.583369976237713

    public static func makeMonitorScene(
        id: String,
        coordinateSystem: OrbitalViewCoordinateSystem = .wavefield,
        shell: OrbitalViewShellSpec,
        speakers: [OrbitalViewSpeaker],
        theme: OrbitalViewTheme = .default
    ) throws -> OrbitalViewSceneSpec {
        try OrbitalViewSceneSpec(
            id: id,
            coordinateSystem: coordinateSystem,
            shell: shell,
            speakers: speakers,
            virtualObjects: [],
            theme: theme
        )
    }

    public static func makeFeyGeodesicShell(radiusM: Double = feySphereRadiusM) throws -> OrbitalViewShellSpec {
        .imported(try makeFeyGeodesicShellGeometry(radiusM: radiusM))
    }

    public static func makeFeyGeodesicShellGeometry(radiusM: Double = feySphereRadiusM) throws -> OrbitalViewImportedShellGeometry {
        guard radiusM.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "shell.radiusM")
        }
        guard radiusM > 0 else {
            throw OrbitalViewValidationError.nonPositiveValue(field: "shell.radiusM", value: radiusM)
        }

        let unitNodesAndEdges = makeFeyGeodesicUnitNodesAndEdges()
        let nodes = try unitNodesAndEdges.nodes.enumerated().map { index, unit in
            try ShellNode(
                id: String(format: "fey-node-%03d", index),
                position: OrbitalViewVector3(
                    x: unit.x * radiusM,
                    y: unit.y * radiusM,
                    z: unit.z * radiusM
                ),
                normal: OrbitalViewVector3(x: unit.x, y: unit.y, z: unit.z)
            )
        }

        let edges = try unitNodesAndEdges.edges.enumerated().map { index, pair in
            try ShellEdge(
                id: String(format: "fey-edge-%03d", index),
                a: nodes[pair.a].id,
                b: nodes[pair.b].id,
                role: .strut
            )
        }

        return try OrbitalViewImportedShellGeometry(radiusM: radiusM, nodes: nodes, edges: edges, faces: [])
    }

    public static func anchoringSpeakersToNearestShellNodes(
        _ speakers: [OrbitalViewSpeaker],
        in shell: OrbitalViewShellSpec
    ) throws -> [OrbitalViewSpeaker] {
        guard case .imported(let geometry) = shell else {
            return speakers
        }

        return try anchoringSpeakersToNearestShellNodes(speakers, in: geometry)
    }

    public static func anchoringSpeakersToNearestShellNodes(
        _ speakers: [OrbitalViewSpeaker],
        in geometry: OrbitalViewImportedShellGeometry
    ) throws -> [OrbitalViewSpeaker] {
        guard !geometry.nodes.isEmpty else {
            throw OrbitalViewValidationError.invalidAnchorReference(
                "cannot anchor speakers to empty imported shell geometry"
            )
        }

        let nodeDirections = try geometry.nodes.map { node -> (id: String, direction: UnitSphereDirection) in
            if let normal = node.normal {
                return (
                    id: node.id,
                    direction: try UnitSphereDirection.normalized(x: normal.x, y: normal.y, z: normal.z)
                )
            }
            return (
                id: node.id,
                direction: try UnitSphereDirection.normalized(
                    x: node.position.x,
                    y: node.position.y,
                    z: node.position.z
                )
            )
        }

        return try speakers.map { speaker in
            guard case .direction(let direction, let offsetM) = speaker.anchor else {
                return speaker
            }

            let bestNode = nodeDirections.max { lhs, rhs in
                dot(lhs.direction, direction) < dot(rhs.direction, direction)
            }!

            return try OrbitalViewSpeaker(
                id: speaker.id,
                channel: speaker.channel,
                label: speaker.label,
                anchor: .node(nodeID: bestNode.id, offsetM: offsetM),
                shape: speaker.shape,
                visualRole: speaker.visualRole
            )
        }
    }

    public static func makeDefaultOctahedronShell(radiusM: Double = 1.0) throws -> OrbitalViewShellSpec {
        let nodes = try [
            ShellNode(id: "top", position: OrbitalViewVector3(x: 0, y: radiusM, z: 0), normal: nil),
            ShellNode(id: "bottom", position: OrbitalViewVector3(x: 0, y: -radiusM, z: 0), normal: nil),
            ShellNode(id: "front", position: OrbitalViewVector3(x: 0, y: 0, z: radiusM), normal: nil),
            ShellNode(id: "back", position: OrbitalViewVector3(x: 0, y: 0, z: -radiusM), normal: nil),
            ShellNode(id: "right", position: OrbitalViewVector3(x: radiusM, y: 0, z: 0), normal: nil),
            ShellNode(id: "left", position: OrbitalViewVector3(x: -radiusM, y: 0, z: 0), normal: nil)
        ]

        let edges = try [
            ShellEdge(id: "top-front", a: "top", b: "front"),
            ShellEdge(id: "top-right", a: "top", b: "right"),
            ShellEdge(id: "top-back", a: "top", b: "back"),
            ShellEdge(id: "top-left", a: "top", b: "left"),
            ShellEdge(id: "bottom-front", a: "bottom", b: "front"),
            ShellEdge(id: "bottom-right", a: "bottom", b: "right"),
            ShellEdge(id: "bottom-back", a: "bottom", b: "back"),
            ShellEdge(id: "bottom-left", a: "bottom", b: "left"),
            ShellEdge(id: "front-right", a: "front", b: "right"),
            ShellEdge(id: "right-back", a: "right", b: "back"),
            ShellEdge(id: "back-left", a: "back", b: "left"),
            ShellEdge(id: "left-front", a: "left", b: "front")
        ]

        let faces = try [
            ShellFace(id: "top-front-right", nodes: ["top", "front", "right"]),
            ShellFace(id: "top-right-back", nodes: ["top", "right", "back"]),
            ShellFace(id: "top-back-left", nodes: ["top", "back", "left"]),
            ShellFace(id: "top-left-front", nodes: ["top", "left", "front"]),
            ShellFace(id: "bottom-right-front", nodes: ["bottom", "right", "front"]),
            ShellFace(id: "bottom-back-right", nodes: ["bottom", "back", "right"]),
            ShellFace(id: "bottom-left-back", nodes: ["bottom", "left", "back"]),
            ShellFace(id: "bottom-front-left", nodes: ["bottom", "front", "left"])
        ]

        return .imported(try OrbitalViewImportedShellGeometry(
            radiusM: radiusM,
            nodes: nodes,
            edges: edges,
            faces: faces
        ))
    }

    private static func dot(_ lhs: UnitSphereDirection, _ rhs: UnitSphereDirection) -> Double {
        (lhs.x * rhs.x) + (lhs.y * rhs.y) + (lhs.z * rhs.z)
    }

    private static func makeFeyGeodesicUnitNodesAndEdges() -> (nodes: [GeodesicVector], edges: [(a: Int, b: Int)]) {
        let frequency = 3
        let baseVertices = makeIcosahedronVertices()
        let vertexUpSource = baseVertices[5]
        let alignedBaseVertices = baseVertices.map {
            rotate($0, from: vertexUpSource, to: GeodesicVector(x: 0, y: 1, z: 0))
        }

        var nodes: [GeodesicVector] = []
        var nodeIDs: [String: Int] = [:]
        var edgeIDs: [String: (a: Int, b: Int)] = [:]

        func nodeKey(_ point: GeodesicVector) -> String {
            String(format: "%.6f,%.6f,%.6f", point.x, point.y, point.z)
        }

        func nodeID(_ point: GeodesicVector) -> Int {
            let normalized = point.normalized
            let key = nodeKey(normalized)
            if let existing = nodeIDs[key] {
                return existing
            }

            let next = nodes.count
            nodeIDs[key] = next
            nodes.append(normalized)
            return next
        }

        func addEdge(_ a: Int, _ b: Int) {
            guard a != b else { return }
            let ordered = a < b ? (a: a, b: b) : (a: b, b: a)
            let key = "\(ordered.a):\(ordered.b)"
            edgeIDs[key] = ordered
        }

        for face in icosahedronFaces {
            let a = alignedBaseVertices[face[0]]
            let b = alignedBaseVertices[face[1]]
            let c = alignedBaseVertices[face[2]]
            var localNodeIDs: [String: Int] = [:]

            func localNodeID(i: Int, j: Int) -> Int {
                let key = "\(i):\(j)"
                if let existing = localNodeIDs[key] {
                    return existing
                }

                let k = frequency - i - j
                let point = (a * (Double(k) / Double(frequency)))
                    + (b * (Double(i) / Double(frequency)))
                    + (c * (Double(j) / Double(frequency)))
                let next = nodeID(point)
                localNodeIDs[key] = next
                return next
            }

            for i in 0...frequency {
                for j in 0...(frequency - i) {
                    let current = localNodeID(i: i, j: j)
                    for offset in [(di: 1, dj: 0), (di: 0, dj: 1), (di: -1, dj: 1)] {
                        let nextI = i + offset.di
                        let nextJ = j + offset.dj
                        if nextI >= 0, nextJ >= 0, nextI + nextJ <= frequency {
                            addEdge(current, localNodeID(i: nextI, j: nextJ))
                        }
                    }
                }
            }
        }

        return (
            nodes: nodes,
            edges: edgeIDs.keys.sorted().compactMap { edgeIDs[$0] }
        )
    }

    private static var icosahedronFaces: [[Int]] {
        [
            [0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11],
            [1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
            [3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9],
            [4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1]
        ]
    }

    private static func makeIcosahedronVertices() -> [GeodesicVector] {
        let phi = (1 + sqrt(5)) / 2
        return [
            GeodesicVector(x: -1, y: phi, z: 0),
            GeodesicVector(x: 1, y: phi, z: 0),
            GeodesicVector(x: -1, y: -phi, z: 0),
            GeodesicVector(x: 1, y: -phi, z: 0),
            GeodesicVector(x: 0, y: -1, z: phi),
            GeodesicVector(x: 0, y: 1, z: phi),
            GeodesicVector(x: 0, y: -1, z: -phi),
            GeodesicVector(x: 0, y: 1, z: -phi),
            GeodesicVector(x: phi, y: 0, z: -1),
            GeodesicVector(x: phi, y: 0, z: 1),
            GeodesicVector(x: -phi, y: 0, z: -1),
            GeodesicVector(x: -phi, y: 0, z: 1)
        ].map(\.normalized)
    }

    private static func rotate(_ vector: GeodesicVector, from: GeodesicVector, to: GeodesicVector) -> GeodesicVector {
        let source = from.normalized
        let target = to.normalized
        let axis = source.cross(target)
        let sinTheta = axis.magnitude
        let cosTheta = source.dot(target)

        if sinTheta < 0.00001 {
            if cosTheta > 0 {
                return vector
            }
            return GeodesicVector(x: vector.x, y: -vector.y, z: -vector.z)
        }

        let unitAxis = axis * (1 / sinTheta)
        return (vector * cosTheta)
            + (unitAxis.cross(vector) * sinTheta)
            + (unitAxis * (unitAxis.dot(vector) * (1 - cosTheta)))
    }
}

private struct GeodesicVector: Equatable {
    let x: Double
    let y: Double
    let z: Double

    var magnitude: Double {
        sqrt((x * x) + (y * y) + (z * z))
    }

    var normalized: GeodesicVector {
        let length = magnitude
        guard length > 0 else { return self }
        return self * (1 / length)
    }

    func dot(_ other: GeodesicVector) -> Double {
        (x * other.x) + (y * other.y) + (z * other.z)
    }

    func cross(_ other: GeodesicVector) -> GeodesicVector {
        GeodesicVector(
            x: (y * other.z) - (z * other.y),
            y: (z * other.x) - (x * other.z),
            z: (x * other.y) - (y * other.x)
        )
    }

    static func + (lhs: GeodesicVector, rhs: GeodesicVector) -> GeodesicVector {
        GeodesicVector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    static func * (lhs: GeodesicVector, rhs: Double) -> GeodesicVector {
        GeodesicVector(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
}
