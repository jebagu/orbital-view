import Foundation

public struct OrbitalViewSceneSpec: Equatable, Sendable {
    public let id: String
    public let coordinateSystem: OrbitalViewCoordinateSystem
    public let shell: OrbitalViewShellSpec
    public let speakers: [OrbitalViewSpeaker]
    public let virtualObjects: [OrbitalViewVirtualObject]
    public let theme: OrbitalViewTheme

    public init(
        id: String,
        coordinateSystem: OrbitalViewCoordinateSystem,
        shell: OrbitalViewShellSpec,
        speakers: [OrbitalViewSpeaker],
        virtualObjects: [OrbitalViewVirtualObject] = [],
        theme: OrbitalViewTheme = .default
    ) throws {
        self.id = id
        self.coordinateSystem = coordinateSystem
        self.shell = shell
        self.speakers = speakers
        self.virtualObjects = virtualObjects
        self.theme = theme
        try validate()
    }

    public func validate() throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "scene.id")
        }

        try shell.validate()

        var speakerIDs = Set<String>()
        var physicalChannels = Set<Int>()
        for speaker in speakers {
            try speaker.validate()
            guard speakerIDs.insert(speaker.id).inserted else {
                throw OrbitalViewValidationError.duplicateID(speaker.id)
            }

            if speaker.visualRole == .physicalSpeaker {
                guard physicalChannels.insert(speaker.channel).inserted else {
                    throw OrbitalViewValidationError.duplicatePhysicalChannel(speaker.channel)
                }
            }

            try validate(anchor: speaker.anchor)
        }

        var virtualObjectIDs = Set<String>()
        for virtualObject in virtualObjects {
            try virtualObject.validate()
            guard virtualObjectIDs.insert(virtualObject.id).inserted else {
                throw OrbitalViewValidationError.duplicateID(virtualObject.id)
            }
        }
    }

    private func validate(anchor: SpeakerAnchor) throws {
        switch (shell, anchor) {
        case (_, .direction):
            return
        case (.imported(let geometry), .node(let nodeID, _)):
            guard geometry.nodes.contains(where: { $0.id == nodeID }) else {
                throw OrbitalViewValidationError.unknownNodeID(nodeID)
            }
        case (.imported(let geometry), .edge(let edgeID, _, _)):
            guard geometry.edges.contains(where: { $0.id == edgeID }) else {
                throw OrbitalViewValidationError.unknownEdgeID(edgeID)
            }
        case (.imported(let geometry), .face(let faceID, _, _)):
            guard geometry.faces.contains(where: { $0.id == faceID }) else {
                throw OrbitalViewValidationError.unknownFaceID(faceID)
            }
        case (.parametric, .node(let nodeID, _)):
            throw OrbitalViewValidationError.invalidAnchorReference("node anchor \(nodeID) requires imported shell geometry")
        case (.parametric, .edge(let edgeID, _, _)):
            throw OrbitalViewValidationError.invalidAnchorReference("edge anchor \(edgeID) requires imported shell geometry")
        case (.parametric, .face(let faceID, _, _)):
            throw OrbitalViewValidationError.invalidAnchorReference("face anchor \(faceID) requires imported shell geometry")
        }
    }
}

public struct OrbitalViewVirtualObject: Identifiable, Equatable, Codable, Sendable {
    public let id: String
    public let label: String

    public init(id: String, label: String) throws {
        self.id = id
        self.label = label
        try validate()
    }

    public func validate() throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "virtualObject.id")
        }
        guard !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrbitalViewValidationError.emptyLabel
        }
    }
}

public struct OrbitalViewTheme: Equatable, Codable, Sendable {
    public static let `default` = OrbitalViewTheme(name: "Orbital Default")

    public let name: String

    public init(name: String) {
        self.name = name
    }
}

