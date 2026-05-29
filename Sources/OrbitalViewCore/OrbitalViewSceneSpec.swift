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
        case (_, .cartesian):
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

public struct OrbitalColor: Equatable, Codable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public static func rgb(_ hex: UInt32, alpha: Double = 1) -> OrbitalColor {
        OrbitalColor(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

public struct OrbitalColorStop: Equatable, Codable, Sendable {
    public let position: Double
    public let color: OrbitalColor

    public init(position: Double, color: OrbitalColor) {
        self.position = position
        self.color = color
    }
}

public struct OrbitalViewTheme: Equatable, Codable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case name
        case background
        case panel
        case line
        case text
        case mutedText
        case accent
        case accentSecondary
        case success
        case warning
        case danger
        case vuRamp
    }

    public static let `default` = kimiPurple
    public static let kimiPurple = OrbitalViewTheme(
        name: "Kimi Purple",
        background: .rgb(0x080A0D),
        panel: .rgb(0x14181C),
        line: .rgb(0x2A2E38),
        text: .rgb(0xF4F1FF),
        mutedText: .rgb(0xA7A0B8),
        accent: .rgb(0xAA88FF),
        accentSecondary: .rgb(0x32D6BF),
        success: .rgb(0x34D399),
        warning: .rgb(0xFDE047),
        danger: .rgb(0xEF4444),
        vuRamp: [
            OrbitalColorStop(position: 0.0, color: .rgb(0x2A223D)),
            OrbitalColorStop(position: 0.5, color: .rgb(0xAA88FF)),
            OrbitalColorStop(position: 1.0, color: .rgb(0x32D6BF))
        ]
    )
    public static let daftPunkBow = OrbitalViewTheme(
        name: "Daft Punk Bow",
        background: .rgb(0x080A0D),
        panel: .rgb(0x14181C),
        line: .rgb(0x2A2E38),
        text: .rgb(0xF8FAFC),
        mutedText: .rgb(0xA7A0B8),
        accent: .rgb(0x22D3EE),
        accentSecondary: .rgb(0xFDE047),
        success: .rgb(0x34D399),
        warning: .rgb(0xFB923C),
        danger: .rgb(0xEF4444),
        vuRamp: [
            OrbitalColorStop(position: 0.00, color: .rgb(0xA78BFA)),
            OrbitalColorStop(position: 0.18, color: .rgb(0x5B8CFF)),
            OrbitalColorStop(position: 0.34, color: .rgb(0x22D3EE)),
            OrbitalColorStop(position: 0.50, color: .rgb(0x34D399)),
            OrbitalColorStop(position: 0.66, color: .rgb(0xFDE047)),
            OrbitalColorStop(position: 0.82, color: .rgb(0xFB923C)),
            OrbitalColorStop(position: 1.00, color: .rgb(0xEF4444))
        ]
    )

    public let name: String
    public let background: OrbitalColor
    public let panel: OrbitalColor
    public let line: OrbitalColor
    public let text: OrbitalColor
    public let mutedText: OrbitalColor
    public let accent: OrbitalColor
    public let accentSecondary: OrbitalColor
    public let success: OrbitalColor
    public let warning: OrbitalColor
    public let danger: OrbitalColor
    public let vuRamp: [OrbitalColorStop]

    public init(name: String) {
        self.init(
            name: name,
            background: Self.default.background,
            panel: Self.default.panel,
            line: Self.default.line,
            text: Self.default.text,
            mutedText: Self.default.mutedText,
            accent: Self.default.accent,
            accentSecondary: Self.default.accentSecondary,
            success: Self.default.success,
            warning: Self.default.warning,
            danger: Self.default.danger,
            vuRamp: Self.default.vuRamp
        )
    }

    public init(
        name: String,
        background: OrbitalColor,
        panel: OrbitalColor,
        line: OrbitalColor,
        text: OrbitalColor,
        mutedText: OrbitalColor,
        accent: OrbitalColor,
        accentSecondary: OrbitalColor,
        success: OrbitalColor,
        warning: OrbitalColor,
        danger: OrbitalColor,
        vuRamp: [OrbitalColorStop]
    ) {
        self.name = name
        self.background = background
        self.panel = panel
        self.line = line
        self.text = text
        self.mutedText = mutedText
        self.accent = accent
        self.accentSecondary = accentSecondary
        self.success = success
        self.warning = warning
        self.danger = danger
        self.vuRamp = vuRamp
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fallback = Self.default
        self.init(
            name: try container.decode(String.self, forKey: .name),
            background: try container.decodeIfPresent(OrbitalColor.self, forKey: .background) ?? fallback.background,
            panel: try container.decodeIfPresent(OrbitalColor.self, forKey: .panel) ?? fallback.panel,
            line: try container.decodeIfPresent(OrbitalColor.self, forKey: .line) ?? fallback.line,
            text: try container.decodeIfPresent(OrbitalColor.self, forKey: .text) ?? fallback.text,
            mutedText: try container.decodeIfPresent(OrbitalColor.self, forKey: .mutedText) ?? fallback.mutedText,
            accent: try container.decodeIfPresent(OrbitalColor.self, forKey: .accent) ?? fallback.accent,
            accentSecondary: try container.decodeIfPresent(OrbitalColor.self, forKey: .accentSecondary) ?? fallback.accentSecondary,
            success: try container.decodeIfPresent(OrbitalColor.self, forKey: .success) ?? fallback.success,
            warning: try container.decodeIfPresent(OrbitalColor.self, forKey: .warning) ?? fallback.warning,
            danger: try container.decodeIfPresent(OrbitalColor.self, forKey: .danger) ?? fallback.danger,
            vuRamp: try container.decodeIfPresent([OrbitalColorStop].self, forKey: .vuRamp) ?? fallback.vuRamp
        )
    }
}
