import Foundation
import OrbitalViewCore

public enum WavefieldSpeakerLayoutSceneAdapterError: Error, Equatable, Sendable {
    case missingSpeakerLayout(URL)
    case invalidLayout(String)
    case unsupportedCoordinateSystem(String)
    case unsupportedAxes([String: String]?)
    case invalidMainSpeakerCount(expected: Int, actual: Int)
    case duplicateSpeakerChannel(Int)
    case invalidSpeakerPosition(channel: Int?, reason: String)
}

public struct WavefieldSpeakerLayoutSceneAdapter: Sendable {
    public static let expectedMainSpeakerCount = 30

    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func makeScene(
        layoutURL: URL,
        sceneID: String? = nil,
        shell: OrbitalViewShellSpec? = nil,
        speakerOffsetM: Double = 0.05,
        speakerRadiusM: Double = 0.03
    ) throws -> OrbitalViewSceneSpec {
        guard FileManager.default.fileExists(atPath: layoutURL.path) else {
            throw WavefieldSpeakerLayoutSceneAdapterError.missingSpeakerLayout(layoutURL)
        }

        let data = try Data(contentsOf: layoutURL)
        return try makeScene(
            data: data,
            sourceDescription: layoutURL.path,
            sceneID: sceneID,
            shell: shell,
            speakerOffsetM: speakerOffsetM,
            speakerRadiusM: speakerRadiusM
        )
    }

    public func makeScene(
        data: Data,
        sourceDescription: String = "Wavefield speaker layout data",
        sceneID: String? = nil,
        shell: OrbitalViewShellSpec? = nil,
        speakerOffsetM: Double = 0.05,
        speakerRadiusM: Double = 0.03
    ) throws -> OrbitalViewSceneSpec {
        let raw: RawWavefieldSpeakerLayout
        do {
            raw = try decoder.decode(RawWavefieldSpeakerLayout.self, from: data)
        } catch {
            throw WavefieldSpeakerLayoutSceneAdapterError.invalidLayout(
                "\(sourceDescription): \(String(describing: error))"
            )
        }

        try validate(raw)

        let speakers = try raw.speakers
            .sorted { $0.channel < $1.channel }
            .map { rawSpeaker in
                try OrbitalViewSpeaker(
                    id: "\(raw.id)-channel-\(rawSpeaker.channel)",
                    channel: rawSpeaker.channel,
                    label: rawSpeaker.label,
                    anchor: .direction(
                        try UnitSphereDirection(
                            x: rawSpeaker.position.x,
                            y: rawSpeaker.position.y,
                            z: rawSpeaker.position.z
                        ),
                        offsetM: speakerOffsetM
                    ),
                    shape: .sphere(radiusM: speakerRadiusM),
                    visualRole: .physicalSpeaker
                )
            }

        return try OrbitalViewSceneBuilder.makeMonitorScene(
            id: sceneID ?? raw.id,
            coordinateSystem: .wavefield,
            shell: shell ?? .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1.0)),
            speakers: speakers
        )
    }

    private func validate(_ raw: RawWavefieldSpeakerLayout) throws {
        guard raw.coordinateSystem.type == "unitSphereCartesian" else {
            throw WavefieldSpeakerLayoutSceneAdapterError.unsupportedCoordinateSystem(raw.coordinateSystem.type)
        }

        if let axes = raw.coordinateSystem.axes {
            guard axes["x"] == "right", axes["y"] == "up", axes["z"] == "front" else {
                throw WavefieldSpeakerLayoutSceneAdapterError.unsupportedAxes(axes)
            }
        }

        guard raw.mainSpeakerCount == Self.expectedMainSpeakerCount else {
            throw WavefieldSpeakerLayoutSceneAdapterError.invalidMainSpeakerCount(
                expected: Self.expectedMainSpeakerCount,
                actual: raw.mainSpeakerCount
            )
        }

        guard raw.speakers.count == raw.mainSpeakerCount else {
            throw WavefieldSpeakerLayoutSceneAdapterError.invalidMainSpeakerCount(
                expected: raw.mainSpeakerCount,
                actual: raw.speakers.count
            )
        }

        var seenChannels = Set<Int>()
        for speaker in raw.speakers {
            guard speaker.channel > 0 else {
                throw WavefieldSpeakerLayoutSceneAdapterError.invalidSpeakerPosition(
                    channel: speaker.channel,
                    reason: "Speaker channel must be positive."
                )
            }

            guard seenChannels.insert(speaker.channel).inserted else {
                throw WavefieldSpeakerLayoutSceneAdapterError.duplicateSpeakerChannel(speaker.channel)
            }

            guard speaker.position.type == "unitSphereCartesian" else {
                throw WavefieldSpeakerLayoutSceneAdapterError.invalidSpeakerPosition(
                    channel: speaker.channel,
                    reason: "Speaker position must be unitSphereCartesian."
                )
            }

            do {
                _ = try UnitSphereDirection(
                    x: speaker.position.x,
                    y: speaker.position.y,
                    z: speaker.position.z
                )
            } catch {
                throw WavefieldSpeakerLayoutSceneAdapterError.invalidSpeakerPosition(
                    channel: speaker.channel,
                    reason: String(describing: error)
                )
            }
        }
    }
}

private struct RawWavefieldSpeakerLayout: Decodable {
    let schema: String
    let id: String
    let name: String
    let coordinateSystem: RawWavefieldCoordinateSystem
    let mainSpeakerCount: Int
    let subChannel: Int?
    let speakers: [RawWavefieldSpeaker]
}

private struct RawWavefieldCoordinateSystem: Decodable {
    let type: String
    let axes: [String: String]?
}

private struct RawWavefieldSpeaker: Decodable {
    let channel: Int
    let label: String
    let position: RawWavefieldSpeakerPosition
}

private struct RawWavefieldSpeakerPosition: Decodable {
    let type: String
    let x: Double
    let y: Double
    let z: Double
}

