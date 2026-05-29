import Foundation
import OrbitalViewCore

public enum SpatGRISXML {
    public static let maximumFileSizeBytes = 10 * 1024 * 1024

    public static func parseSpeakerSetup(data: Data) throws -> SpatGRISSpeakerSetup {
        try validateXMLData(data)
        let document = try XMLDocument(data: data, options: [.nodePreserveWhitespace])
        guard let root = document.rootElement() else {
            throw SpatGRISLayoutError.malformedXML("missing root element")
        }

        switch root.name {
        case "SPEAKER_SETUP":
            return try parseSpeakerSetup(root: root)
        case "SpeakerSetup":
            return try parseVeryOldSpeakerSetup(root: root)
        case "SPAT_GRIS_PROJECT_DATA":
            throw SpatGRISLayoutError.unsupportedRoot("SPAT_GRIS_PROJECT_DATA")
        default:
            throw SpatGRISLayoutError.unsupportedRoot(root.name ?? "unknown")
        }
    }

    public static func parseSpeakerSetup(from url: URL) throws -> SpatGRISSpeakerSetup {
        try parseSpeakerSetup(data: try limitedData(from: url))
    }

    public static func parseProject(data: Data) throws -> SpatGRISProject {
        try validateXMLData(data)
        let document = try XMLDocument(data: data, options: [.nodePreserveWhitespace])
        guard let root = document.rootElement() else {
            throw SpatGRISLayoutError.malformedXML("missing root element")
        }
        guard root.name == "SPAT_GRIS_PROJECT_DATA" else {
            throw SpatGRISLayoutError.unsupportedRoot(root.name ?? "unknown")
        }

        let mode = root.attributeString("SPAT_MODE").flatMap(SpatGRISSpatMode.init(rawValue:))
        let sourcesElement = root.firstChildElement(named: "SOURCES")
        let sources = try sourcesElement?.childElements.compactMap { element -> SpatGRISProjectSource? in
            guard let tag = element.name, tag.hasPrefix("SOURCE_") else {
                return nil
            }
            let sourceIDText = String(tag.dropFirst("SOURCE_".count))
            guard let sourceID = Int(sourceIDText) else {
                throw SpatGRISLayoutError.invalidSourceID(0)
            }
            let state = try parseState(element.requiredAttribute("STATE"))
            let colorText = try element.requiredAttribute("COLOR")
            let color = UInt32(colorText)
            let directOut = element.attributeString("DIRECT_OUT").flatMap(Int.init)
            let hybrid = element.attributeString("HYBRID_SPAT_MODE").flatMap(SpatGRISSpatMode.init(rawValue:))
            return try SpatGRISProjectSource(
                sourceID: sourceID,
                state: state,
                argbColor: color,
                directOutPatchID: directOut,
                hybridSpatMode: hybrid
            )
        } ?? []

        return try SpatGRISProject(spatMode: mode, sources: sources)
    }

    public static func parseProjectData(from url: URL) throws -> SpatGRISProject {
        try parseProject(data: try limitedData(from: url))
    }

    public static func exportSpeakerSetup(_ setup: SpatGRISSpeakerSetup) -> String {
        let rootUUID = xmlEscaped(setup.uuid)
        let groupUUID = xmlEscaped(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased())
        var lines: [String] = [
            #"<?xml version="1.0" encoding="UTF-8"?>"#,
            "",
            #"<SPEAKER_SETUP SPEAKER_SETUP_VERSION="\#(SpatGRISSpeakerSetup.currentSpeakerSetupVersion)" SPAT_MODE="\#(setup.spatMode.rawValue)" DIFFUSION="\#(format(setup.diffusion))" GENERAL_MUTE="\#(setup.generalMute ? "1" : "0")" UUID="\#(rootUUID)">"#,
            #"  <SPEAKER_GROUP SPEAKER_GROUP_NAME="MAIN_SPEAKER_GROUP_NAME" CARTESIAN_POSITION="(0, 0, 0)" UUID="\#(groupUUID)">"#
        ]
        for speaker in setup.sortedSpeakers {
            var attributes = [
                #"SPEAKER_PATCH_ID="\#(speaker.patchID)""#,
                #"IO_STATE="\#(speaker.state.rawValue)""#,
                #"GAIN="\#(format(speaker.gainDB))""#,
                #"DIRECT_OUT_ONLY="\#(speaker.directOutOnly ? "1" : "0")""#,
                #"CARTESIAN_POSITION="\#(tupleString(speaker.position, normalizeDome: setup.spatMode == .dome && !speaker.directOutOnly))""#,
                #"UUID="\#(xmlEscaped(speaker.uuid))""#
            ]
            if let highpassHz = speaker.highpassHz {
                attributes.append(#"HIGHPASS_FREQ="\#(format(highpassHz))""#)
            }
            lines.append("    <SPEAKER \(attributes.joined(separator: " "))/>\n".trimmingCharacters(in: .newlines))
        }
        lines.append("  </SPEAKER_GROUP>")
        lines.append("</SPEAKER_SETUP>")
        return lines.joined(separator: "\n") + "\n"
    }

    private static func parseSpeakerSetup(root: XMLElement) throws -> SpatGRISSpeakerSetup {
        if root.attributeString("SPEAKER_SETUP_VERSION") == SpatGRISSpeakerSetup.currentSpeakerSetupVersion {
            return try parseCurrentSpeakerSetup(root: root)
        }
        return try parseLegacySpeakerSetup(root: root)
    }

    private static func limitedData(from url: URL) throws -> Data {
        let data = try Data(contentsOf: url)
        guard data.count <= maximumFileSizeBytes else {
            throw SpatGRISLayoutError.tooLarge(data.count)
        }
        return data
    }

    private static func parseCurrentSpeakerSetup(root: XMLElement) throws -> SpatGRISSpeakerSetup {
        let spatMode = try parseSpatMode(root.requiredAttribute("SPAT_MODE"))
        let diffusion = try parseDouble(root.attributeString("DIFFUSION") ?? "0", field: "DIFFUSION")
        let generalMute = parseBool(root.attributeString("GENERAL_MUTE"))
        let uuid = root.attributeString("UUID") ?? UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        guard let main = root.firstChildElement(named: "SPEAKER_GROUP") else {
            throw SpatGRISLayoutError.missingAttribute("SPEAKER_GROUP")
        }

        var speakers: [SpatGRISSpeaker] = []
        let mainPosition = try parseTuple(main.attributeString("CARTESIAN_POSITION") ?? "(0, 0, 0)")
        for child in main.childElements {
            if child.name == "SPEAKER" {
                speakers.append(try parseCurrentSpeaker(child, groupPosition: mainPosition, yawPitchRoll: nil))
            } else if child.name == "SPEAKER_GROUP" {
                let groupPosition = try parseTuple(child.attributeString("CARTESIAN_POSITION") ?? "(0, 0, 0)")
                let rotation = EulerRotation(
                    yawDegrees: try parseDouble(child.attributeString("YAW") ?? "0", field: "YAW"),
                    pitchDegrees: try parseDouble(child.attributeString("PITCH") ?? "0", field: "PITCH"),
                    rollDegrees: try parseDouble(child.attributeString("ROLL") ?? "0", field: "ROLL")
                )
                for speaker in child.childElements where speaker.name == "SPEAKER" {
                    speakers.append(try parseCurrentSpeaker(speaker, groupPosition: groupPosition, yawPitchRoll: rotation))
                }
            }
        }

        return try SpatGRISSpeakerSetup(
            version: SpatGRISSpeakerSetup.currentSpeakerSetupVersion,
            spatMode: spatMode,
            diffusion: diffusion,
            generalMute: generalMute,
            uuid: uuid,
            speakers: speakers
        )
    }

    private static func parseCurrentSpeaker(
        _ element: XMLElement,
        groupPosition: OrbitalViewVector3,
        yawPitchRoll: EulerRotation?
    ) throws -> SpatGRISSpeaker {
        let patchID = try parseInt(element.requiredAttribute("SPEAKER_PATCH_ID"), field: "SPEAKER_PATCH_ID")
        let state = try parseState(element.requiredAttribute("IO_STATE"))
        let gainDB = try parseDouble(element.requiredAttribute("GAIN"), field: "GAIN")
        let directOutOnly = parseBool(try element.requiredAttribute("DIRECT_OUT_ONLY"))
        var position = try parseTuple(element.requiredAttribute("CARTESIAN_POSITION"))
        if let yawPitchRoll {
            position = try yawPitchRoll.rotate(position)
        }
        position = try add(position, groupPosition)
        let uuid = element.attributeString("UUID") ?? UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        let highpass = try element.attributeString("HIGHPASS_FREQ").map {
            try parseDouble($0, field: "HIGHPASS_FREQ")
        }
        return try SpatGRISSpeaker(
            patchID: patchID,
            state: state,
            gainDB: gainDB,
            directOutOnly: directOutOnly,
            position: position,
            uuid: uuid,
            highpassHz: highpass
        )
    }

    private static func parseLegacySpeakerSetup(root: XMLElement) throws -> SpatGRISSpeakerSetup {
        let spatMode = try parseSpatMode(root.requiredAttribute("SPAT_MODE"))
        let diffusion = try parseDouble(root.attributeString("DIFFUSION") ?? "0", field: "DIFFUSION")
        let generalMute = parseBool(root.attributeString("GENERAL_MUTE"))
        let speakers = try root.childElements.compactMap { element -> SpatGRISSpeaker? in
            guard let tag = element.name, tag.hasPrefix("SPEAKER_") else {
                return nil
            }
            let patchIDText = String(tag.dropFirst("SPEAKER_".count))
            guard let patchID = Int(patchIDText) else {
                throw SpatGRISLayoutError.invalidPatchID(0)
            }
            guard let positionElement = element.firstChildElement(named: "POSITION") else {
                throw SpatGRISLayoutError.missingAttribute("POSITION")
            }
            let position = try OrbitalViewVector3(
                x: parseDouble(positionElement.requiredAttribute("X"), field: "POSITION.X"),
                y: parseDouble(positionElement.requiredAttribute("Y"), field: "POSITION.Y"),
                z: parseDouble(positionElement.requiredAttribute("Z"), field: "POSITION.Z")
            )
            let highpass = try element.firstChildElement(named: "HIGHPASS")?.attributeString("FREQ").map {
                try parseDouble($0, field: "HIGHPASS.FREQ")
            }
            return try SpatGRISSpeaker(
                patchID: patchID,
                state: parseState(element.attributeString("STATE") ?? "normal"),
                gainDB: parseDouble(element.attributeString("GAIN") ?? "0", field: "GAIN"),
                directOutOnly: parseBool(element.attributeString("DIRECT_OUT_ONLY")),
                position: position,
                highpassHz: highpass
            )
        }
        return try SpatGRISSpeakerSetup(
            version: root.attributeString("VERSION") ?? "legacy",
            spatMode: spatMode,
            diffusion: diffusion,
            generalMute: generalMute,
            speakers: speakers
        )
    }

    private static func parseVeryOldSpeakerSetup(root: XMLElement) throws -> SpatGRISSpeakerSetup {
        let speakers = try root.descendants(whereName: "Speaker").compactMap { element -> SpatGRISSpeaker? in
            let patchID = try parseInt(
                element.attributeString("OutputPatch") ?? element.attributeString("LayoutIndex") ?? "0",
                field: "OutputPatch"
            )
            let azimuth = try parseDouble(element.attributeString("Azimuth") ?? "0", field: "Azimuth")
            let zenith = try parseDouble(element.attributeString("Zenith") ?? "90", field: "Zenith")
            let radius = try parseDouble(element.attributeString("Radius") ?? "1", field: "Radius")
            let elevation = 90 - zenith
            let position = try cartesianFromPolarDegrees(
                azimuthDegrees: azimuth,
                elevationDegrees: elevation,
                radius: radius
            )
            return try SpatGRISSpeaker(
                patchID: patchID,
                state: .normal,
                gainDB: parseDouble(element.attributeString("Gain") ?? "0", field: "Gain"),
                directOutOnly: parseBool(element.attributeString("DirectOut")),
                position: position,
                highpassHz: element.attributeString("HighPassCutoff").flatMap(Double.init)
            )
        }
        return try SpatGRISSpeakerSetup(spatMode: .dome, speakers: speakers)
    }

    static func validateXMLData(_ data: Data) throws {
        guard data.count <= maximumFileSizeBytes else {
            throw SpatGRISLayoutError.tooLarge(data.count)
        }
        let prefix = String(decoding: data.prefix(4096), as: UTF8.self).lowercased()
        if prefix.contains("<!doctype") || prefix.contains("<!entity") {
            throw SpatGRISLayoutError.unsafeXML
        }
    }

    static func parseTuple(_ value: String) throws -> OrbitalViewVector3 {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("("), trimmed.hasSuffix(")") else {
            throw SpatGRISLayoutError.invalidTuple(value)
        }
        let content = trimmed.dropFirst().dropLast()
        let parts = content.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard parts.count == 3 else {
            throw SpatGRISLayoutError.invalidTuple(value)
        }
        return try OrbitalViewVector3(
            x: parseDouble(parts[0], field: "tuple.x"),
            y: parseDouble(parts[1], field: "tuple.y"),
            z: parseDouble(parts[2], field: "tuple.z")
        )
    }

    static func cartesianFromPolarDegrees(
        azimuthDegrees: Double,
        elevationDegrees: Double,
        radius: Double
    ) throws -> OrbitalViewVector3 {
        try cartesianFromPolarRadians(
            azimuthRadians: azimuthDegrees * .pi / 180,
            elevationRadians: elevationDegrees * .pi / 180,
            radius: radius
        )
    }

    static func cartesianFromPolarRadians(
        azimuthRadians: Double,
        elevationRadians: Double,
        radius: Double
    ) throws -> OrbitalViewVector3 {
        guard azimuthRadians.isFinite, elevationRadians.isFinite, radius.isFinite else {
            throw SpatGRISLayoutError.invalidNumericValue("polar coordinates")
        }
        let horizontalRadius = cos(elevationRadians) * radius
        return try OrbitalViewVector3(
            x: sin(azimuthRadians) * horizontalRadius,
            y: cos(azimuthRadians) * horizontalRadius,
            z: sin(elevationRadians) * radius
        )
    }

    static func parseState(_ rawValue: String) throws -> SpatGRISSliceState {
        guard let state = SpatGRISSliceState(rawValue: rawValue) else {
            throw SpatGRISLayoutError.invalidState(rawValue)
        }
        return state
    }

    static func parseSpatMode(_ rawValue: String) throws -> SpatGRISSpatMode {
        guard let mode = SpatGRISSpatMode(rawValue: rawValue) else {
            throw SpatGRISLayoutError.invalidSpatMode(rawValue)
        }
        return mode
    }

    static func parseDouble(_ rawValue: String, field: String) throws -> Double {
        guard let value = Double(rawValue.trimmingCharacters(in: .whitespacesAndNewlines)),
              value.isFinite else {
            throw SpatGRISLayoutError.invalidNumericValue(field)
        }
        return value
    }

    static func parseInt(_ rawValue: String, field: String) throws -> Int {
        guard let value = Int(rawValue.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw SpatGRISLayoutError.invalidNumericValue(field)
        }
        return value
    }

    static func parseBool(_ rawValue: String?) -> Bool {
        switch rawValue?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "1", "true", "yes":
            return true
        default:
            return false
        }
    }

    private static func add(_ lhs: OrbitalViewVector3, _ rhs: OrbitalViewVector3) throws -> OrbitalViewVector3 {
        try OrbitalViewVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    private static func tupleString(_ position: OrbitalViewVector3, normalizeDome: Bool) -> String {
        let value: OrbitalViewVector3
        if normalizeDome, position.magnitude > 0 {
            let magnitude = position.magnitude
            value = (try? OrbitalViewVector3(
                x: position.x / magnitude,
                y: position.y / magnitude,
                z: position.z / magnitude
            )) ?? position
        } else {
            value = position
        }
        return "(\(format(value.x)), \(format(value.y)), \(format(value.z)))"
    }

    private static func format(_ value: Double) -> String {
        let formatted = String(format: "%.7f", value)
        return formatted
            .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\.$"#, with: ".0", options: .regularExpression)
    }

    private static func xmlEscaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}

private struct EulerRotation {
    let yawDegrees: Double
    let pitchDegrees: Double
    let rollDegrees: Double

    func rotate(_ vector: OrbitalViewVector3) throws -> OrbitalViewVector3 {
        let yaw = yawDegrees * .pi / 180
        let pitch = pitchDegrees * .pi / 180
        let roll = rollDegrees * .pi / 180

        let cy = cos(yaw)
        let sy = sin(yaw)
        let cp = cos(pitch)
        let sp = sin(pitch)
        let cr = cos(roll)
        let sr = sin(roll)

        let yawed = (
            x: vector.x * cy - vector.y * sy,
            y: vector.x * sy + vector.y * cy,
            z: vector.z
        )
        let pitched = (
            x: yawed.x * cp + yawed.z * sp,
            y: yawed.y,
            z: -yawed.x * sp + yawed.z * cp
        )
        return try OrbitalViewVector3(
            x: pitched.x,
            y: pitched.y * cr - pitched.z * sr,
            z: pitched.y * sr + pitched.z * cr
        )
    }
}

private extension XMLElement {
    var childElements: [XMLElement] {
        children?.compactMap { $0 as? XMLElement } ?? []
    }

    func firstChildElement(named name: String) -> XMLElement? {
        childElements.first { $0.name == name }
    }

    func descendants(whereName name: String) -> [XMLElement] {
        childElements.flatMap { child -> [XMLElement] in
            var matches: [XMLElement] = child.name == name ? [child] : []
            matches.append(contentsOf: child.descendants(whereName: name))
            return matches
        }
    }

    func attributeString(_ name: String) -> String? {
        attribute(forName: name)?.stringValue
    }

    func requiredAttribute(_ name: String) throws -> String {
        guard let value = attributeString(name), !value.isEmpty else {
            throw SpatGRISLayoutError.missingAttribute(name)
        }
        return value
    }
}
