import Foundation

public enum OrbitalViewValidationError: Error, Equatable, Sendable {
    case emptyID(field: String)
    case emptyLabel
    case nonFiniteValue(field: String)
    case nonPositiveValue(field: String, value: Double)
    case invalidUnitVectorMagnitude(Double)
    case zeroVector
    case duplicateID(String)
    case duplicatePhysicalChannel(Int)
    case invalidChannel(Int)
    case unknownNodeID(String)
    case unknownEdgeID(String)
    case unknownFaceID(String)
    case invalidEdgeReference(edgeID: String, reason: String)
    case invalidFaceReference(faceID: String, reason: String)
    case invalidAnchorReference(String)
    case invalidRange(field: String, value: Double, validRange: String)
    case nonOriginMonitorTarget(OrbitalViewVector3)
    case invalidObjectID(Int)
    case duplicateObjectID(Int)
}
