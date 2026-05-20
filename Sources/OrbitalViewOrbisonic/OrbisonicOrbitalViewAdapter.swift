import Foundation
import OrbitalViewCore

public enum OrbisonicOrbitalViewAdapterError: Error, Equatable, Sendable {
    case invalidPhysicalSpeakerCount(expected: Int, actual: Int)
    case physicalChannelSetMismatch(expected: [Int], actual: [Int])
    case duplicatePhysicalChannel(Int)
    case invalidPhysicalChannel(Int)
    case invalidSpeakerPosition(channel: Int, reason: String)
}

public enum OrbisonicOrbitalMeterSource: String, Codable, CaseIterable, Equatable, Sendable {
    case rendererOutputMonitor
    case danteOutputMonitor
    case sonicSphereAnalysisMonitor

    public var displayName: String {
        switch self {
        case .rendererOutputMonitor:
            return "Renderer Output Monitor"
        case .danteOutputMonitor:
            return "Dante Output Monitor"
        case .sonicSphereAnalysisMonitor:
            return "Sonic Sphere Analysis Monitor"
        }
    }
}

public enum OrbisonicOrbitalColorScheme: String, Codable, CaseIterable, Equatable, Sendable {
    case orbisonicLab
    case kimiPurple
    case daftPunkBow
    case monochrome

    public var displayName: String {
        switch self {
        case .orbisonicLab:
            return "Orbisonic Lab"
        case .kimiPurple:
            return "Kimi Purple"
        case .daftPunkBow:
            return "Daft Punk Bow"
        case .monochrome:
            return "Monochrome"
        }
    }

    public var theme: OrbitalViewTheme {
        switch self {
        case .orbisonicLab:
            return OrbitalViewTheme(
                name: displayName,
                background: .rgb(0x071014),
                panel: .rgb(0x0D181D, alpha: 0.88),
                line: .rgb(0xD9FBFF, alpha: 0.14),
                text: .rgb(0xEFFCFF),
                mutedText: .rgb(0x9FB9BD),
                accent: .rgb(0x5EEAD4),
                accentSecondary: .rgb(0x60A5FA),
                success: .rgb(0x22C55E),
                warning: .rgb(0xFACC15),
                danger: .rgb(0xFB7185),
                vuRamp: [
                    OrbitalColorStop(position: 0.0, color: .rgb(0x22C55E)),
                    OrbitalColorStop(position: 0.45, color: .rgb(0x5EEAD4)),
                    OrbitalColorStop(position: 0.72, color: .rgb(0x60A5FA)),
                    OrbitalColorStop(position: 0.88, color: .rgb(0xFACC15)),
                    OrbitalColorStop(position: 1.0, color: .rgb(0xFB7185))
                ]
            )
        case .kimiPurple:
            return .kimiPurple
        case .daftPunkBow:
            return .daftPunkBow
        case .monochrome:
            return SpeakerMeterColorScheme.monochrome.theme
        }
    }
}

public extension OrbitalViewCoordinateSystem {
    static let orbisonicMonitor = OrbitalViewCoordinateSystem(
        xAxis: .right,
        yAxis: .up,
        zAxis: .front
    )
}

public struct OrbisonicOutputSpeakerRecord: Equatable, Sendable {
    public let physicalChannel: Int
    public let x: Double
    public let y: Double
    public let z: Double
    public let label: String

    public init(
        physicalChannel: Int,
        x: Double,
        y: Double,
        z: Double,
        label: String? = nil
    ) {
        self.physicalChannel = physicalChannel
        self.x = x
        self.y = y
        self.z = z
        self.label = label ?? "Speaker \(physicalChannel)"
    }
}

public struct OrbisonicMeterRecord: Equatable, Sendable {
    public let physicalChannel: Int
    public let rms: Float
    public let peak: Float
    public let clip: Bool

    public init(
        physicalChannel: Int,
        rms: Float,
        peak: Float,
        clip: Bool = false
    ) {
        self.physicalChannel = physicalChannel
        self.rms = rms
        self.peak = peak
        self.clip = clip
    }
}

public struct OrbisonicOrbitalViewAdapter: Sendable {
    public static let expectedPhysicalChannels = Array(1...30)

    public let coordinateSystem: OrbitalViewCoordinateSystem
    public let theme: OrbitalViewTheme
    public let speakerShape: SpeakerShape
    public let speakerOffsetM: Double

    public init(
        coordinateSystem: OrbitalViewCoordinateSystem = .orbisonicMonitor,
        theme: OrbitalViewTheme = OrbisonicOrbitalColorScheme.orbisonicLab.theme,
        speakerShape: SpeakerShape? = nil,
        speakerOffsetM: Double = 0.05
    ) throws {
        guard speakerOffsetM.isFinite else {
            throw OrbitalViewValidationError.nonFiniteValue(field: "orbisonic.speakerOffsetM")
        }

        let resolvedShape: SpeakerShape
        if let speakerShape {
            resolvedShape = speakerShape
        } else {
            resolvedShape = try SpeakerShape.sonicSphereDefault()
        }
        try resolvedShape.validate()

        self.coordinateSystem = coordinateSystem
        self.theme = theme
        self.speakerShape = resolvedShape
        self.speakerOffsetM = speakerOffsetM
    }

    public func makeScene(
        speakers records: [OrbisonicOutputSpeakerRecord],
        sceneID: String = "orbisonic-sonic-sphere-30",
        shell: OrbitalViewShellSpec? = nil
    ) throws -> OrbitalViewSceneSpec {
        guard records.count == Self.expectedPhysicalChannels.count else {
            throw OrbisonicOrbitalViewAdapterError.invalidPhysicalSpeakerCount(
                expected: Self.expectedPhysicalChannels.count,
                actual: records.count
            )
        }

        var seenChannels = Set<Int>()
        for record in records {
            guard record.physicalChannel > 0 else {
                throw OrbisonicOrbitalViewAdapterError.invalidPhysicalChannel(record.physicalChannel)
            }
            guard seenChannels.insert(record.physicalChannel).inserted else {
                throw OrbisonicOrbitalViewAdapterError.duplicatePhysicalChannel(record.physicalChannel)
            }
        }

        let actualChannels = seenChannels.sorted()
        guard actualChannels == Self.expectedPhysicalChannels else {
            throw OrbisonicOrbitalViewAdapterError.physicalChannelSetMismatch(
                expected: Self.expectedPhysicalChannels,
                actual: actualChannels
            )
        }

        let speakers = try records
            .sorted { $0.physicalChannel < $1.physicalChannel }
            .map { record in
                let direction: UnitSphereDirection
                do {
                    direction = try UnitSphereDirection.normalized(x: record.x, y: record.y, z: record.z)
                } catch {
                    throw OrbisonicOrbitalViewAdapterError.invalidSpeakerPosition(
                        channel: record.physicalChannel,
                        reason: String(describing: error)
                    )
                }

                return try OrbitalViewSpeaker(
                    id: "orbisonic-channel-\(record.physicalChannel)",
                    channel: record.physicalChannel,
                    label: record.label,
                    anchor: .direction(direction, offsetM: speakerOffsetM),
                    shape: speakerShape,
                    visualRole: .physicalSpeaker
                )
            }

        return try OrbitalViewSceneBuilder.makeMonitorScene(
            id: sceneID,
            coordinateSystem: coordinateSystem,
            shell: shell ?? .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1.0)),
            speakers: speakers,
            theme: theme
        )
    }

    public func makeSanitizedSpeakerMeterFrame(
        timestamp: TimeInterval,
        meters: [OrbisonicMeterRecord],
        expectedChannels: [Int] = OrbisonicOrbitalViewAdapter.expectedPhysicalChannels,
        timestampFallback: TimeInterval = 0
    ) throws -> SpeakerMeterFrameSanitizer.Result {
        let samples = meters.map { meter in
            SpeakerMeterSample(
                channel: meter.physicalChannel,
                rms: meter.rms,
                peak: meter.peak,
                clip: meter.clip
            )
        }

        return try SpeakerMeterFrameSanitizer(
            expectedChannels: expectedChannels,
            timestampFallback: timestampFallback
        )
        .sanitize(timestamp: timestamp, samples: samples)
    }
}
