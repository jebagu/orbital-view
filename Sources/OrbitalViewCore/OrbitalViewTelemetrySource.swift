import Foundation

public enum OrbitalViewTelemetrySourceKind: String, Codable, CaseIterable, Equatable, Sendable {
    case speakerBus
    case objectBus
    case finalOutput
    case hardwareTap
    case localLivestreamTestGenerator
    case externalWavefieldStream
    case orbisonicPreparedMeterTap
    case splatPreparedAnalysis
    case reviewLocalAudio
    case syntheticVisualStress

    public var displayName: String {
        switch self {
        case .speakerBus:
            return "Speaker bus"
        case .objectBus:
            return "Object bus"
        case .finalOutput:
            return "Final output"
        case .hardwareTap:
            return "Hardware tap"
        case .localLivestreamTestGenerator:
            return "Local livestream test generator"
        case .externalWavefieldStream:
            return "External Wavefield stream"
        case .orbisonicPreparedMeterTap:
            return "Orbisonic prepared meter tap"
        case .splatPreparedAnalysis:
            return "Splat prepared analysis"
        case .reviewLocalAudio:
            return "Review local audio"
        case .syntheticVisualStress:
            return "Synthetic visual stress"
        }
    }

    public var isReviewOrTestHarness: Bool {
        switch self {
        case .localLivestreamTestGenerator, .reviewLocalAudio, .syntheticVisualStress:
            return true
        case .speakerBus,
             .objectBus,
             .finalOutput,
             .hardwareTap,
             .externalWavefieldStream,
             .orbisonicPreparedMeterTap,
             .splatPreparedAnalysis:
            return false
        }
    }
}

public struct OrbitalViewTelemetrySourceDescriptor: Equatable, Codable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case kind
        case label
        case detail
    }

    public static let maxLabelLength = 96
    public static let maxDetailLength = 160

    public static let speakerBus = Self(uncheckedKind: .speakerBus)
    public static let objectBus = Self(uncheckedKind: .objectBus)
    public static let finalOutput = Self(uncheckedKind: .finalOutput)
    public static let hardwareTap = Self(uncheckedKind: .hardwareTap)
    public static let localLivestreamTestGenerator = Self(uncheckedKind: .localLivestreamTestGenerator)
    public static let externalWavefieldStream = Self(uncheckedKind: .externalWavefieldStream)
    public static let orbisonicPreparedMeterTap = Self(uncheckedKind: .orbisonicPreparedMeterTap)
    public static let splatPreparedAnalysis = Self(uncheckedKind: .splatPreparedAnalysis)
    public static let reviewLocalAudio = Self(uncheckedKind: .reviewLocalAudio)
    public static let syntheticVisualStress = Self(uncheckedKind: .syntheticVisualStress)

    public let kind: OrbitalViewTelemetrySourceKind
    public let label: String
    public let detail: String?

    public init(
        kind: OrbitalViewTelemetrySourceKind,
        label: String? = nil,
        detail: String? = nil
    ) throws {
        self.kind = kind
        self.label = (label ?? kind.displayName).trimmingCharacters(in: .whitespacesAndNewlines)
        self.detail = detail?.trimmingCharacters(in: .whitespacesAndNewlines)
        try validate()
    }

    private init(
        uncheckedKind kind: OrbitalViewTelemetrySourceKind,
        label: String? = nil,
        detail: String? = nil
    ) {
        self.kind = kind
        self.label = label ?? kind.displayName
        self.detail = detail
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            kind: container.decode(OrbitalViewTelemetrySourceKind.self, forKey: .kind),
            label: container.decodeIfPresent(String.self, forKey: .label),
            detail: container.decodeIfPresent(String.self, forKey: .detail)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(label, forKey: .label)
        try container.encodeIfPresent(detail, forKey: .detail)
    }

    public func validate() throws {
        guard !label.isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "telemetrySource.label")
        }
        guard label.count <= Self.maxLabelLength else {
            throw OrbitalViewValidationError.invalidRange(
                field: "telemetrySource.label",
                value: Double(label.count),
                validRange: "1...\(Self.maxLabelLength)"
            )
        }

        guard let detail else { return }
        guard !detail.isEmpty else {
            throw OrbitalViewValidationError.emptyID(field: "telemetrySource.detail")
        }
        guard detail.count <= Self.maxDetailLength else {
            throw OrbitalViewValidationError.invalidRange(
                field: "telemetrySource.detail",
                value: Double(detail.count),
                validRange: "1...\(Self.maxDetailLength)"
            )
        }
    }
}

public enum OrbitalViewTelemetryOverloadAction: String, Codable, CaseIterable, Equatable, Sendable {
    case dropStaleFrames
    case decimateDisplayRefresh
    case keepLatestCompleteSnapshot
    case setDiagnosticsOutsideRealtime

    public var displayName: String {
        switch self {
        case .dropStaleFrames:
            return "Drop stale frames"
        case .decimateDisplayRefresh:
            return "Decimate display refresh"
        case .keepLatestCompleteSnapshot:
            return "Keep latest complete snapshot"
        case .setDiagnosticsOutsideRealtime:
            return "Set diagnostics outside realtime"
        }
    }
}
