import Foundation
import OrbitalViewCore

public enum SpatGRISOSC {
    public static let address = "/spat/serv"
    public static let defaultInputPort = 18032
    public static let legalPortRange = 1024...65535

    public static func validatePort(_ port: Int) throws {
        guard legalPortRange.contains(port) else {
            throw SpatGRISLayoutError.invalidPort(port)
        }
    }
}

public struct SpatGRISSourcePositionMessage: Equatable, Sendable {
    public enum CoordinateKind: String, Equatable, Sendable {
        case cartesian = "car"
        case degrees = "deg"
        case radians = "pol"
        case reset
    }

    public let sourceID: Int
    public let kind: CoordinateKind
    public let position: OrbitalViewVector3?
    public let horizontalSpan: Float
    public let verticalSpan: Float

    public init(
        sourceID: Int,
        kind: CoordinateKind,
        position: OrbitalViewVector3?,
        horizontalSpan: Float = 0,
        verticalSpan: Float = 0
    ) throws {
        guard SpatGRISSpeaker.legalPatchRange.contains(sourceID) else {
            throw SpatGRISLayoutError.invalidSourceID(sourceID)
        }
        self.sourceID = sourceID
        self.kind = kind
        self.position = position
        self.horizontalSpan = Self.clampSpan(horizontalSpan)
        self.verticalSpan = Self.clampSpan(verticalSpan)
    }

    public func source(existingLabel: String? = nil) throws -> OrbitalViewSource? {
        guard let position else {
            return nil
        }
        return try OrbitalViewSource(
            sourceID: sourceID,
            label: existingLabel ?? "Source \(String(format: "%02d", sourceID))",
            position: position,
            horizontalSpan: horizontalSpan,
            verticalSpan: verticalSpan
        )
    }

    private static func clampSpan(_ value: Float) -> Float {
        min(1, max(0, value.isFinite ? value : 0))
    }
}

public enum SpatGRISOSCParser {
    public static func parseTextLine(_ line: String) throws -> SpatGRISSourcePositionMessage? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else {
            return nil
        }
        let parts = trimmed.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
        guard parts.count >= 3, parts[0] == SpatGRISOSC.address else {
            return nil
        }
        return try parseArguments(Array(parts.dropFirst()))
    }

    public static func parsePacket(_ data: Data) throws -> [SpatGRISSourcePositionMessage] {
        var reader = OSCReader(data: data)
        return try parsePacket(reader: &reader)
    }

    private static func parsePacket(reader: inout OSCReader) throws -> [SpatGRISSourcePositionMessage] {
        let address = try reader.readString()
        if address == "#bundle" {
            _ = try reader.readInt32()
            _ = try reader.readInt32()
            var messages: [SpatGRISSourcePositionMessage] = []
            while !reader.isAtEnd {
                let size = try Int(reader.readInt32())
                let elementData = try reader.readData(count: size)
                messages.append(contentsOf: try parsePacket(elementData))
            }
            return messages
        }

        guard address == SpatGRISOSC.address else {
            return []
        }
        let typeTags = try reader.readString()
        guard typeTags.first == "," else {
            throw SpatGRISLayoutError.unsupportedOSC("missing OSC type tag")
        }
        var values: [OSCValue] = []
        for tag in typeTags.dropFirst() {
            switch tag {
            case "s":
                values.append(.string(try reader.readString()))
            case "i":
                values.append(.int(Int(try reader.readInt32())))
            case "f":
                values.append(.float(try reader.readFloat32()))
            default:
                throw SpatGRISLayoutError.unsupportedOSC("unsupported type tag \(tag)")
            }
        }
        return [try parseOSCValues(values)]
    }

    private static func parseArguments(_ args: [String]) throws -> SpatGRISSourcePositionMessage {
        guard let first = args.first else {
            throw SpatGRISLayoutError.unsupportedOSC("missing coordinate kind")
        }
        if first == "reset" {
            guard args.count >= 2, let sourceID = Int(args[1]) else {
                throw SpatGRISLayoutError.unsupportedOSC("missing reset source")
            }
            return try SpatGRISSourcePositionMessage(sourceID: sourceID, kind: .reset, position: nil)
        }
        guard args.count >= 7,
              let sourceID = Int(args[1]),
              let a = Double(args[2]),
              let b = Double(args[3]),
              let c = Double(args[4]),
              let horizontalSpan = Float(args[5]),
              let verticalSpan = Float(args[6]) else {
            throw SpatGRISLayoutError.unsupportedOSC("invalid source position arguments")
        }
        return try makeMessage(
            kindRawValue: first,
            sourceID: sourceID,
            a: a,
            b: b,
            c: c,
            horizontalSpan: horizontalSpan,
            verticalSpan: verticalSpan
        )
    }

    private static func parseOSCValues(_ values: [OSCValue]) throws -> SpatGRISSourcePositionMessage {
        guard let kind = values.first?.stringValue else {
            throw SpatGRISLayoutError.unsupportedOSC("missing coordinate kind")
        }
        if kind == "reset" {
            guard let sourceID = values[safe: 1]?.intValue else {
                throw SpatGRISLayoutError.unsupportedOSC("missing reset source")
            }
            return try SpatGRISSourcePositionMessage(sourceID: sourceID, kind: .reset, position: nil)
        }
        guard let sourceID = values[safe: 1]?.intValue,
              let a = values[safe: 2]?.doubleValue,
              let b = values[safe: 3]?.doubleValue,
              let c = values[safe: 4]?.doubleValue,
              let horizontalSpan = values[safe: 5]?.floatValue,
              let verticalSpan = values[safe: 6]?.floatValue else {
            throw SpatGRISLayoutError.unsupportedOSC("invalid source position arguments")
        }
        return try makeMessage(
            kindRawValue: kind,
            sourceID: sourceID,
            a: a,
            b: b,
            c: c,
            horizontalSpan: horizontalSpan,
            verticalSpan: verticalSpan
        )
    }

    private static func makeMessage(
        kindRawValue: String,
        sourceID: Int,
        a: Double,
        b: Double,
        c: Double,
        horizontalSpan: Float,
        verticalSpan: Float
    ) throws -> SpatGRISSourcePositionMessage {
        guard let kind = SpatGRISSourcePositionMessage.CoordinateKind(rawValue: kindRawValue) else {
            throw SpatGRISLayoutError.unsupportedOSC("unknown coordinate kind \(kindRawValue)")
        }
        let position: OrbitalViewVector3
        switch kind {
        case .cartesian:
            position = try OrbitalViewVector3(x: a, y: b, z: c)
        case .degrees:
            position = try SpatGRISXML.cartesianFromPolarDegrees(
                azimuthDegrees: a,
                elevationDegrees: b,
                radius: c
            )
        case .radians:
            position = try SpatGRISXML.cartesianFromPolarRadians(
                azimuthRadians: a,
                elevationRadians: b,
                radius: c
            )
        case .reset:
            return try SpatGRISSourcePositionMessage(sourceID: sourceID, kind: .reset, position: nil)
        }
        return try SpatGRISSourcePositionMessage(
            sourceID: sourceID,
            kind: kind,
            position: position,
            horizontalSpan: horizontalSpan,
            verticalSpan: verticalSpan
        )
    }
}

private enum OSCValue {
    case string(String)
    case int(Int)
    case float(Float)

    var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }

    var intValue: Int? {
        if case .int(let value) = self { return value }
        return nil
    }

    var floatValue: Float? {
        if case .float(let value) = self { return value }
        return nil
    }

    var doubleValue: Double? {
        switch self {
        case .float(let value):
            return Double(value)
        case .int(let value):
            return Double(value)
        case .string:
            return nil
        }
    }
}

private struct OSCReader {
    let data: Data
    var offset = 0

    var isAtEnd: Bool {
        offset >= data.count
    }

    mutating func readString() throws -> String {
        let start = offset
        while offset < data.count, data[offset] != 0 {
            offset += 1
        }
        guard offset < data.count else {
            throw SpatGRISLayoutError.unsupportedOSC("unterminated string")
        }
        let stringData = data[start..<offset]
        offset += 1
        align()
        guard let string = String(data: stringData, encoding: .utf8) else {
            throw SpatGRISLayoutError.unsupportedOSC("non-utf8 string")
        }
        return string
    }

    mutating func readInt32() throws -> Int32 {
        let raw = try readData(count: 4)
        return raw.reduce(Int32(0)) { ($0 << 8) | Int32($1) }
    }

    mutating func readFloat32() throws -> Float {
        let raw = UInt32(bitPattern: try readInt32())
        return Float(bitPattern: raw)
    }

    mutating func readData(count: Int) throws -> Data {
        guard count >= 0, offset + count <= data.count else {
            throw SpatGRISLayoutError.unsupportedOSC("truncated packet")
        }
        let range = offset..<(offset + count)
        offset += count
        return data[range]
    }

    private mutating func align() {
        let remainder = offset % 4
        if remainder != 0 {
            offset += 4 - remainder
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
