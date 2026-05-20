import Foundation
import OrbitalViewCore

public struct OrbitalViewViewerSpeakerSnapshot: Equatable, Sendable {
    public let channel: Int
    public let label: String
    public let direction: UnitSphereDirection

    public init(channel: Int, label: String, direction: UnitSphereDirection) {
        self.channel = channel
        self.label = label
        self.direction = direction
    }

    public var projectedX: Double {
        direction.x * OrbitalViewViewerDemoContent.projectionScale
    }

    public var projectedY: Double {
        direction.y * OrbitalViewViewerDemoContent.projectionScale
    }
}

public enum OrbitalViewViewerDemoContent {
    public static let speakerChannels = Array(1...30)
    public static let projectionScale = 0.72

    public static func makeScene(
        id: String = "orbital-viewer-demo",
        viewMode: OrbitalViewMode = .isometric
    ) throws -> OrbitalViewSceneSpec {
        let speakers = try makeSpeakerSnapshots(viewMode: viewMode).map { speaker in
            try OrbitalViewSpeaker(
                id: "viewer-speaker-\(speaker.channel)",
                channel: speaker.channel,
                label: speaker.label,
                anchor: .direction(
                    speaker.direction,
                    offsetM: 0.05
                ),
                shape: try SpeakerShape.sonicSphereDefault()
            )
        }

        return try OrbitalViewSceneBuilder.makeMonitorScene(
            id: id,
            coordinateSystem: .wavefield,
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
            speakers: speakers,
            theme: .daftPunkBow
        )
    }

    public static func makeSpeakerSnapshots(
        viewMode: OrbitalViewMode = .isometric
    ) throws -> [OrbitalViewViewerSpeakerSnapshot] {
        try feySpeakers.map { speaker in
            OrbitalViewViewerSpeakerSnapshot(
                channel: speaker.channel,
                label: speaker.label,
                direction: try orientedDirection(
                    x: speaker.x,
                    y: speaker.y,
                    z: speaker.z,
                    viewMode: viewMode
                )
            )
        }
    }

    public static func makeMeterFrame(timestamp: TimeInterval = 0) throws -> SpeakerMeterFrame {
        var levelsByChannel: [Int: SpeakerMeterLevel] = [:]

        for channel in speakerChannels {
            let sweep = Float(channel - 1) / Float(speakerChannels.count - 1)
            let wave = Float((sin(Double(channel) * 0.73) + 1) * 0.5)
            let rms = min(0.98, 0.08 + (sweep * 0.58) + (wave * 0.22))
            let peak = min(1, rms + 0.14 + (channel % 6 == 0 ? 0.12 : 0))
            levelsByChannel[channel] = try SpeakerMeterLevel(
                rms: rms,
                peak: peak,
                clip: channel == 30
            )
        }

        return try SpeakerMeterFrame(timestamp: timestamp, levelsByChannel: levelsByChannel)
    }

    public static func makeObjectFrames(
        timestamp: TimeInterval = 0,
        viewMode: OrbitalViewMode = .isometric
    ) throws -> OrbitalViewObjectFrameSet {
        let activeObjects = try [
            makeObject(
                objectID: 1,
                label: "Lead Object",
                pose: (0.88, 0.16, 0.45),
                width: 0.18,
                trail: [(0.70, 0.20, 0.62), (0.50, 0.26, 0.78), (0.22, 0.32, 0.92)],
                viewMode: viewMode
            ),
            makeObject(
                objectID: 2,
                label: "Bed Object",
                pose: (-0.42, 0.55, 0.72),
                width: 0.10,
                trail: [(-0.22, 0.44, 0.87), (-0.08, 0.30, 0.95)],
                viewMode: viewMode
            ),
            makeObject(
                objectID: 3,
                label: "Rear Accent",
                pose: (-0.64, -0.22, -0.74),
                width: 0.06,
                trail: [(-0.50, -0.16, -0.85), (-0.32, -0.08, -0.94)],
                viewMode: viewMode
            )
        ]

        return try OrbitalViewObjectFrameSet(
            timestamp: timestamp,
            activeObjects: activeObjects,
            maxActiveObjects: 8,
            maxTrailPointsPerObject: 8
        )
    }

    public static func makeObjectMeters(timestamp: TimeInterval = 0) throws -> ObjectMeterFrame {
        try ObjectMeterFrame(
            timestamp: timestamp,
            levelsByObjectID: [
                1: ObjectMeterLevel(rms: 0.72, peak: 0.88, clip: false),
                2: ObjectMeterLevel(rms: 0.38, peak: 0.54, clip: false),
                3: ObjectMeterLevel(rms: 0.58, peak: 0.94, clip: false)
            ]
        )
    }

    public static func makeObjectVisualSettings() throws -> ObjectVisualSettings {
        try ObjectVisualSettings(
            shape: .comet,
            palette: .sourceGold,
            coreSize: 0.065,
            widthScale: 1.1,
            glowIntensity: 0.9,
            trailsEnabled: true,
            maxTrailPointsPerObject: 8,
            glowTrailsEnabled: true,
            glowTrailIntensity: 0.7,
            glowTrailWidth: 0.08
        )
    }

    private struct FeySpeaker {
        let channel: Int
        let label: String
        let x: Double
        let y: Double
        let z: Double
    }

    private static let feySpeakers = [
        FeySpeaker(channel: 1, label: "Fey 01", x: 0, y: 0.554700196225229, z: -0.832050294337844),
        FeySpeaker(channel: 2, label: "Fey 02", x: 0.545454545454545, y: 0.181818181818182, z: -0.818181818181818),
        FeySpeaker(channel: 3, label: "Fey 03", x: 0.331448998468967, y: -0.45113891458276, z: -0.828622496172417),
        FeySpeaker(channel: 4, label: "Fey 04", x: -0.331448998468967, y: -0.45113891458276, z: -0.828622496172417),
        FeySpeaker(channel: 5, label: "Fey 05", x: -0.545454545454545, y: 0.181818181818182, z: -0.818181818181818),
        FeySpeaker(channel: 6, label: "Fey 06", x: -0.548614782048403, y: 0.630906999355663, z: -0.548614782048403),
        FeySpeaker(channel: 7, label: "Fey 07", x: 0.548614782048403, y: 0.630906999355663, z: -0.548614782048403),
        FeySpeaker(channel: 8, label: "Fey 08", x: 0.774258005430618, y: -0.251633851764951, z: -0.580693504072963),
        FeySpeaker(channel: 9, label: "Fey 09", x: 0, y: -0.8, z: -0.6),
        FeySpeaker(channel: 10, label: "Fey 10", x: -0.774258005430618, y: -0.251633851764951, z: -0.580693504072963),
        FeySpeaker(channel: 11, label: "Fey 11", x: -0.923947703083417, y: 0.304902742017528, z: -0.230986925770854),
        FeySpeaker(channel: 12, label: "Fey 12", x: 0, y: 0.970142500145332, z: -0.242535625036333),
        FeySpeaker(channel: 13, label: "Fey 13", x: 0.923947703083417, y: 0.304902742017528, z: -0.230986925770854),
        FeySpeaker(channel: 14, label: "Fey 14", x: 0.577947069890345, y: -0.791708314918281, z: -0.19792707872957),
        FeySpeaker(channel: 15, label: "Fey 15", x: -0.577947069890345, y: -0.791708314918281, z: -0.19792707872957),
        FeySpeaker(channel: 16, label: "Fey 16", x: -0.923947703083417, y: -0.304902742017528, z: 0.230986925770854),
        FeySpeaker(channel: 17, label: "Fey 17", x: -0.572638174674189, y: 0.795330798158596, z: 0.198832699539649),
        FeySpeaker(channel: 18, label: "Fey 18", x: 0.572638174674189, y: 0.795330798158596, z: 0.198832699539649),
        FeySpeaker(channel: 19, label: "Fey 19", x: 0.923947703083417, y: -0.304902742017528, z: 0.230986925770854),
        FeySpeaker(channel: 20, label: "Fey 20", x: 0, y: -0.970142500145332, z: 0.242535625036333),
        FeySpeaker(channel: 21, label: "Fey 21", x: -0.479772219839528, y: -0.662085663378549, z: 0.575726663807434),
        FeySpeaker(channel: 22, label: "Fey 22", x: -0.776114000116266, y: 0.242535625036333, z: 0.582085500087199),
        FeySpeaker(channel: 23, label: "Fey 23", x: 0, y: 0.8, z: 0.6),
        FeySpeaker(channel: 24, label: "Fey 24", x: 0.774258005430618, y: 0.251633851764951, z: 0.580693504072963),
        FeySpeaker(channel: 25, label: "Fey 25", x: 0.479772219839528, y: -0.662085663378549, z: 0.575726663807434),
        FeySpeaker(channel: 26, label: "Fey 26", x: 0, y: -0.554700196225229, z: 0.832050294337844),
        FeySpeaker(channel: 27, label: "Fey 27", x: -0.545454545454545, y: -0.181818181818182, z: 0.818181818181818),
        FeySpeaker(channel: 28, label: "Fey 28", x: -0.403422633196499, y: 0.556723233811169, z: 0.726160739753698),
        FeySpeaker(channel: 29, label: "Fey 29", x: 0.403422633196499, y: 0.556723233811169, z: 0.726160739753698),
        FeySpeaker(channel: 30, label: "Fey 30", x: 0.545454545454545, y: -0.181818181818182, z: 0.818181818181818)
    ]

    private static func orientedDirection(
        x: Double,
        y: Double,
        z: Double,
        viewMode: OrbitalViewMode
    ) throws -> UnitSphereDirection {
        let viewVector: (x: Double, y: Double, z: Double)
        switch viewMode {
        case .frontElevation:
            viewVector = (x, y, z)
        case .sideElevation:
            viewVector = (z, y, -x)
        case .plan:
            viewVector = (x, z, -y)
        case .isometric, .custom:
            viewVector = rotateX(rotateY((x, y, z), radians: -.pi / 4), radians: -.pi / 7)
        }

        return try UnitSphereDirection.normalized(x: viewVector.x, y: viewVector.y, z: viewVector.z)
    }

    private static func rotateY(
        _ vector: (x: Double, y: Double, z: Double),
        radians: Double
    ) -> (x: Double, y: Double, z: Double) {
        let cosValue = cos(radians)
        let sinValue = sin(radians)
        return (
            (cosValue * vector.x) + (sinValue * vector.z),
            vector.y,
            (-sinValue * vector.x) + (cosValue * vector.z)
        )
    }

    private static func rotateX(
        _ vector: (x: Double, y: Double, z: Double),
        radians: Double
    ) -> (x: Double, y: Double, z: Double) {
        let cosValue = cos(radians)
        let sinValue = sin(radians)
        return (
            vector.x,
            (cosValue * vector.y) - (sinValue * vector.z),
            (sinValue * vector.y) + (cosValue * vector.z)
        )
    }

    private static func makeObject(
        objectID: Int,
        label: String,
        pose: (Double, Double, Double),
        width: Float,
        trail: [(Double, Double, Double)],
        viewMode: OrbitalViewMode
    ) throws -> OrbitalViewObjectFrame {
        try OrbitalViewObjectFrame(
            objectID: objectID,
            label: label,
            pose: orientedDirection(x: pose.0, y: pose.1, z: pose.2, viewMode: viewMode),
            width: width,
            trail: try trail.map {
                try orientedDirection(x: $0.0, y: $0.1, z: $0.2, viewMode: viewMode)
            }
        )
    }
}
