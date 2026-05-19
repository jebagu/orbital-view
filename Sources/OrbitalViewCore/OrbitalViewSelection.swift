import Foundation

public enum OrbitalViewSelectableID: Equatable, Codable, Sendable {
    case speaker(String)
    case shellNode(String)
    case shellEdge(String)
    case shellFace(String)
    case virtualObject(String)
}

public struct OrbitalViewSelection: Equatable, Codable, Sendable {
    public let id: OrbitalViewSelectableID

    public init(id: OrbitalViewSelectableID) {
        self.id = id
    }
}

public enum OrbitalViewEvent: Equatable, Sendable {
    case cameraChanged(OrbitalViewCameraState)
    case selected(OrbitalViewSelection?)
    case speakerHovered(channel: Int?)
    case renderWarning(String)
}

