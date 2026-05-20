import Foundation

public struct OrbitalViewVisualPreset: Equatable, Codable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case settings
    }

    public let id: String
    public let displayName: String
    public let settings: SpeakerMeterVisualSettings

    public init(id: String, displayName: String, settings: SpeakerMeterVisualSettings) throws {
        let trimmedID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedID.isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "visualPreset.id")
        }
        guard !trimmedName.isEmpty else {
            throw OrbitalViewValidationError.emptyLabel
        }

        self.id = trimmedID
        self.displayName = trimmedName
        self.settings = settings
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: container.decode(String.self, forKey: .id),
            displayName: container.decode(String.self, forKey: .displayName),
            settings: container.decode(SpeakerMeterVisualSettings.self, forKey: .settings)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(settings, forKey: .settings)
    }

    public static let defaultMusic = OrbitalViewVisualPreset(
        uncheckedID: "default-music",
        displayName: "Default Music",
        settings: .default
    )

    public static func resetToDefaultMusic() -> OrbitalViewVisualPreset {
        .defaultMusic
    }

    private init(uncheckedID id: String, displayName: String, settings: SpeakerMeterVisualSettings) {
        self.id = id
        self.displayName = displayName
        self.settings = settings
    }
}

public protocol OrbitalViewVisualPresetStore: Sendable {
    func loadVisualPreset() throws -> OrbitalViewVisualPreset?
    func saveVisualPreset(_ preset: OrbitalViewVisualPreset) throws
    func resetVisualPreset() throws
}
