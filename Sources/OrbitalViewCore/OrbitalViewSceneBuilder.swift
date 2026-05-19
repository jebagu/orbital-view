import Foundation

public enum OrbitalViewSceneBuilder {
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
}

