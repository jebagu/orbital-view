import Foundation
import OrbitalViewCore

public enum SpatGRISSpatMode: String, Codable, CaseIterable, Equatable, Sendable {
    case dome = "Dome"
    case cube = "Cube"
    case hybrid = "Hybrid"
}

public enum SpatGRISSliceState: String, Codable, CaseIterable, Equatable, Sendable {
    case normal
    case muted
    case solo
}

public enum SpatGRISDiagnosticSeverity: String, Codable, Equatable, Sendable {
    case warning
    case error
}

public struct SpatGRISDiagnostic: Equatable, Codable, Sendable {
    public let severity: SpatGRISDiagnosticSeverity
    public let message: String

    public init(severity: SpatGRISDiagnosticSeverity, message: String) {
        self.severity = severity
        self.message = message
    }
}

public struct SpatGRISSpeaker: Identifiable, Equatable, Sendable {
    public static let legalPatchRange = 1...256

    public let patchID: Int
    public let state: SpatGRISSliceState
    public let gainDB: Double
    public let directOutOnly: Bool
    public let position: OrbitalViewVector3
    public let uuid: String
    public let highpassHz: Double?

    public var id: Int { patchID }

    public init(
        patchID: Int,
        state: SpatGRISSliceState = .normal,
        gainDB: Double = 0,
        directOutOnly: Bool = false,
        position: OrbitalViewVector3,
        uuid: String = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased(),
        highpassHz: Double? = nil
    ) throws {
        self.patchID = patchID
        self.state = state
        self.gainDB = gainDB
        self.directOutOnly = directOutOnly
        self.position = position
        self.uuid = uuid
        self.highpassHz = highpassHz
        try validate()
    }

    public func validate() throws {
        guard Self.legalPatchRange.contains(patchID) else {
            throw SpatGRISLayoutError.invalidPatchID(patchID)
        }
        guard gainDB.isFinite else {
            throw SpatGRISLayoutError.invalidNumericValue("speaker gain")
        }
        try position.validate(fieldPrefix: "spatgris.speaker.position")
        if let highpassHz {
            guard highpassHz.isFinite else {
                throw SpatGRISLayoutError.invalidNumericValue("speaker highpass")
            }
            guard (20...150).contains(highpassHz) else {
                throw SpatGRISLayoutError.invalidHighpass(highpassHz)
            }
        }
    }

    public func coreSpeaker(labelPrefix: String = "SpatGRIS") throws -> OrbitalViewSpeaker {
        try OrbitalViewSpeaker(
            id: "spatgris-speaker-\(patchID)",
            channel: patchID,
            label: "\(labelPrefix) \(String(format: "%02d", patchID))",
            anchor: .cartesian(position, offsetM: 0),
            shape: .sonicSphereDefault(),
            visualRole: directOutOnly ? .diagnostic : .physicalSpeaker
        )
    }

    public func source(labelPrefix: String = "Source") throws -> OrbitalViewSource {
        try OrbitalViewSource(
            sourceID: patchID,
            label: "\(labelPrefix) \(String(format: "%02d", patchID))",
            position: position,
            isDirectOut: directOutOnly
        )
    }
}

public struct SpatGRISSpeakerSetup: Equatable, Sendable {
    public static let currentSpeakerSetupVersion = "4.0.0"
    public static let domeRadiusTolerance = 0.02

    public let layoutID: String
    public let version: String
    public let spatMode: SpatGRISSpatMode
    public let diffusion: Double
    public let generalMute: Bool
    public let uuid: String
    public let speakers: [SpatGRISSpeaker]
    public let diagnostics: [SpatGRISDiagnostic]
    public let bounds: OrbitalViewSceneBounds

    public init(
        layoutID: String = UUID().uuidString,
        version: String = currentSpeakerSetupVersion,
        spatMode: SpatGRISSpatMode,
        diffusion: Double = 0,
        generalMute: Bool = false,
        uuid: String = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased(),
        speakers: [SpatGRISSpeaker],
        diagnostics: [SpatGRISDiagnostic] = []
    ) throws {
        self.layoutID = layoutID
        self.version = version
        self.spatMode = spatMode
        self.diffusion = diffusion
        self.generalMute = generalMute
        self.uuid = uuid
        self.speakers = speakers
        self.diagnostics = diagnostics + Self.diagnostics(for: speakers, spatMode: spatMode)
        self.bounds = try OrbitalViewSceneBounds.enclosing(speakers.map(\.position))
        try validate()
    }

    public func validate() throws {
        guard !layoutID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SpatGRISLayoutError.emptyLayoutID
        }
        guard spatMode == .dome || spatMode == .cube else {
            throw SpatGRISLayoutError.invalidSpatMode(spatMode.rawValue)
        }
        guard diffusion.isFinite, (0...1).contains(diffusion) else {
            throw SpatGRISLayoutError.invalidDiffusion(diffusion)
        }
        guard !speakers.isEmpty else {
            throw SpatGRISLayoutError.emptySpeakerSetup
        }
        guard speakers.count <= SpatGRISSpeaker.legalPatchRange.count else {
            throw SpatGRISLayoutError.tooManySpeakers(speakers.count)
        }

        var patchIDs = Set<Int>()
        for speaker in speakers {
            try speaker.validate()
            guard patchIDs.insert(speaker.patchID).inserted else {
                throw SpatGRISLayoutError.duplicatePatchID(speaker.patchID)
            }
        }
    }

    public var sortedSpeakers: [SpatGRISSpeaker] {
        speakers.sorted { lhs, rhs in lhs.patchID < rhs.patchID }
    }

    public func coreScene(
        id: String,
        labelPrefix: String = "SpatGRIS"
    ) throws -> OrbitalViewSceneSpec {
        let shellRadius = max(1, bounds.halfExtent)
        return try OrbitalViewSceneSpec(
            id: id,
            coordinateSystem: .spatGRIS,
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: shellRadius)),
            speakers: sortedSpeakers.map { try $0.coreSpeaker(labelPrefix: labelPrefix) },
            theme: .default
        )
    }

    public func sourceLayout(id: String) throws -> OrbitalViewSourceLayout {
        try OrbitalViewSourceLayout(id: id, sources: sortedSpeakers.map { try $0.source() })
    }

    private static func diagnostics(
        for speakers: [SpatGRISSpeaker],
        spatMode: SpatGRISSpatMode
    ) -> [SpatGRISDiagnostic] {
        guard spatMode == .dome else {
            return []
        }
        return speakers.compactMap { speaker in
            guard !speaker.directOutOnly else {
                return nil
            }
            let radius = speaker.position.magnitude
            guard abs(radius - 1) > domeRadiusTolerance else {
                return nil
            }
            return SpatGRISDiagnostic(
                severity: .warning,
                message: "Speaker \(speaker.patchID) is outside Dome radius tolerance"
            )
        }
    }
}

public struct SpatGRISProjectSource: Identifiable, Equatable, Sendable {
    public let sourceID: Int
    public let state: SpatGRISSliceState
    public let argbColor: UInt32?
    public let directOutPatchID: Int?
    public let hybridSpatMode: SpatGRISSpatMode?

    public var id: Int { sourceID }

    public init(
        sourceID: Int,
        state: SpatGRISSliceState,
        argbColor: UInt32?,
        directOutPatchID: Int?,
        hybridSpatMode: SpatGRISSpatMode?
    ) throws {
        guard SpatGRISSpeaker.legalPatchRange.contains(sourceID) else {
            throw SpatGRISLayoutError.invalidSourceID(sourceID)
        }
        if let directOutPatchID,
           !SpatGRISSpeaker.legalPatchRange.contains(directOutPatchID) {
            throw SpatGRISLayoutError.invalidPatchID(directOutPatchID)
        }
        self.sourceID = sourceID
        self.state = state
        self.argbColor = argbColor
        self.directOutPatchID = directOutPatchID
        self.hybridSpatMode = hybridSpatMode
    }
}

public struct SpatGRISProject: Equatable, Sendable {
    public let spatMode: SpatGRISSpatMode?
    public let sources: [SpatGRISProjectSource]

    public init(spatMode: SpatGRISSpatMode?, sources: [SpatGRISProjectSource]) throws {
        self.spatMode = spatMode
        self.sources = sources
        var sourceIDs = Set<Int>()
        for source in sources {
            guard sourceIDs.insert(source.sourceID).inserted else {
                throw SpatGRISLayoutError.duplicateSourceID(source.sourceID)
            }
        }
    }
}

public enum SpatGRISLayoutError: Error, Equatable, LocalizedError, Sendable {
    case emptyLayoutID
    case emptySpeakerSetup
    case malformedXML(String)
    case unsafeXML
    case unsupportedRoot(String)
    case missingAttribute(String)
    case invalidTuple(String)
    case invalidPatchID(Int)
    case invalidSourceID(Int)
    case duplicatePatchID(Int)
    case duplicateSourceID(Int)
    case invalidState(String)
    case invalidSpatMode(String)
    case invalidDiffusion(Double)
    case invalidHighpass(Double)
    case invalidNumericValue(String)
    case tooManySpeakers(Int)
    case tooLarge(Int)
    case invalidPort(Int)
    case unsupportedOSC(String)

    public var errorDescription: String? {
        switch self {
        case .emptyLayoutID:
            return "Layout ID is empty"
        case .emptySpeakerSetup:
            return "Speaker setup has no speakers"
        case .malformedXML(let reason):
            return "Malformed XML: \(reason)"
        case .unsafeXML:
            return "XML with DTD or entity declarations is not allowed"
        case .unsupportedRoot(let root):
            return "Unsupported SpatGRIS XML root: \(root)"
        case .missingAttribute(let attribute):
            return "Missing required attribute: \(attribute)"
        case .invalidTuple(let value):
            return "Invalid tuple: \(value)"
        case .invalidPatchID(let id):
            return "Invalid patch ID \(id)"
        case .invalidSourceID(let id):
            return "Invalid source ID \(id)"
        case .duplicatePatchID(let id):
            return "Duplicate patch ID \(id)"
        case .duplicateSourceID(let id):
            return "Duplicate source ID \(id)"
        case .invalidState(let state):
            return "Invalid state: \(state)"
        case .invalidSpatMode(let mode):
            return "Invalid SPAT_MODE: \(mode)"
        case .invalidDiffusion(let value):
            return "Invalid diffusion \(value)"
        case .invalidHighpass(let value):
            return "Invalid high-pass frequency \(value)"
        case .invalidNumericValue(let field):
            return "Invalid numeric value for \(field)"
        case .tooManySpeakers(let count):
            return "Too many speakers: \(count)"
        case .tooLarge(let count):
            return "File is too large: \(count) bytes"
        case .invalidPort(let port):
            return "Invalid OSC port \(port)"
        case .unsupportedOSC(let reason):
            return "Unsupported OSC packet: \(reason)"
        }
    }
}
