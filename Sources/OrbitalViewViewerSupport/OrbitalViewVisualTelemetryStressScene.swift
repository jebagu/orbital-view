import Foundation
import OrbitalViewCore

public enum OrbitalViewVisualTelemetryStressScene {
    public static let speakerCount = 30
    public static let objectCount = OrbitalViewObjectFrameSet.maxObjectCount
    public static let maxTrailPointsPerObject = 16
    public static let activeMotionFramesPerSecond = 60
    public static let incomingMeterFramesPerSecond = 120
    public static let diagnosticsAreOpen = true
    public static let localGeneratorProfileName = "32-object-should-pass-stress"

    public static func makeSourceDescriptor() throws -> OrbitalViewTelemetrySourceDescriptor {
        try OrbitalViewTelemetrySourceDescriptor(
            kind: .localLivestreamTestGenerator,
            label: "Wavefield local generator stress",
            detail: "profile=\(localGeneratorProfileName); incoming=120fps; display=60fps"
        )
    }

    public static func makeScene() throws -> OrbitalViewSceneSpec {
        let shell = try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)
        return try OrbitalViewSceneSpec(
            id: "orbital-view-visual-telemetry-stress",
            coordinateSystem: .wavefield,
            shell: .parametric(shell),
            speakers: makeSpeakers(),
            virtualObjects: try (1...objectCount).map { objectID in
                try OrbitalViewVirtualObject(
                    id: String(format: "stress-object-%03d", objectID),
                    label: String(format: "Object %03d", objectID)
                )
            },
            theme: .daftPunkBow
        )
    }

    public static func makeSpeakerMeters(timestamp: TimeInterval) throws -> SpeakerMeterFrame {
        let source = try makeSourceDescriptor()
        var levelsByChannel: [Int: SpeakerMeterLevel] = [:]
        for channel in 1...speakerCount {
            let phase = timestamp * 2.1 + Double(channel) * 0.37
            let travel = timestamp * 0.43 + Double(channel % 10) * 0.91
            let rms = clamp01(Float(0.16 + 0.56 * normalizedSine(phase) + 0.16 * normalizedSine(travel)))
            let peak = clamp01(rms + 0.15 + Float(0.08 * normalizedSine(phase * 2.4)))
            levelsByChannel[channel] = try SpeakerMeterLevel(rms: rms, peak: peak, clip: peak > 0.97)
        }

        return try SpeakerMeterFrame(
            timestamp: timestamp,
            levelsByChannel: levelsByChannel,
            source: source
        )
    }

    public static func makeObjectFrames(timestamp: TimeInterval) throws -> OrbitalViewObjectFrameSet {
        let frames = try (1...objectCount).map { objectID in
            try OrbitalViewObjectFrame(
                objectID: objectID,
                label: String(format: "Object %03d", objectID),
                category: objectID <= 32 ? "local-generator" : "stress-source",
                pose: objectPose(objectID: objectID, timestamp: timestamp),
                width: Float(0.05 + 0.13 * normalizedSine(timestamp * 0.55 + Double(objectID) * 0.29)),
                trail: makeTrail(objectID: objectID, timestamp: timestamp)
            )
        }

        return try OrbitalViewObjectFrameSet(
            timestamp: timestamp,
            activeObjects: frames,
            maxActiveObjects: objectCount,
            maxTrailPointsPerObject: maxTrailPointsPerObject
        )
    }

    public static func makeObjectMeters(timestamp: TimeInterval) throws -> ObjectMeterFrame {
        let source = try makeSourceDescriptor()
        var levelsByObjectID: [Int: ObjectMeterLevel] = [:]
        for objectID in 1...objectCount {
            let phase = timestamp * (0.95 + Double(objectID % 13) * 0.04) + Double(objectID) * 0.17
            let rms = clamp01(Float(0.1 + 0.68 * normalizedSine(phase)))
            let peak = clamp01(rms + 0.12 + Float(0.08 * normalizedSine(phase * 1.9)))
            levelsByObjectID[objectID] = try ObjectMeterLevel(rms: rms, peak: peak, clip: peak > 0.98)
        }

        return try ObjectMeterFrame(
            timestamp: timestamp,
            levelsByObjectID: levelsByObjectID,
            source: source
        )
    }

    public static func makePerformanceSettings() throws -> OrbitalViewPerformanceSettings {
        try OrbitalViewPerformanceSettings(
            activeViewportFramesPerSecond: activeMotionFramesPerSecond,
            meterOnlyViewportFramesPerSecond: 30,
            inspectorRefreshFramesPerSecond: 10,
            drawsOnDemand: true
        )
    }

    public static func makeDroppedDisplayFrameDiagnostics() -> OrbitalViewInputDiagnostics {
        OrbitalViewInputDiagnostics(
            overloadActions: [
                .dropStaleFrames,
                .decimateDisplayRefresh,
                .keepLatestCompleteSnapshot,
                .setDiagnosticsOutsideRealtime
            ]
        )
    }

    private static func makeSpeakers() throws -> [OrbitalViewSpeaker] {
        try (1...speakerCount).map { channel in
            try OrbitalViewSpeaker(
                id: String(format: "stress-speaker-%02d", channel),
                channel: channel,
                label: String(format: "Fey %02d", channel),
                anchor: .direction(speakerDirection(channel), offsetM: 0.05),
                shape: SpeakerShape.sonicSphereDefault(edgeM: SpeakerShape.defaultSonicSphereEdgeM)
            )
        }
    }

    private static func speakerDirection(_ channel: Int) throws -> UnitSphereDirection {
        let index = Double(channel - 1)
        let count = Double(speakerCount)
        let z = 1.0 - (2.0 * (index + 0.5) / count)
        let radius = sqrt(max(0, 1.0 - z * z))
        let goldenAngle = Double.pi * (3.0 - sqrt(5.0))
        let theta = index * goldenAngle
        return try UnitSphereDirection.normalized(
            x: cos(theta) * radius,
            y: sin(theta) * radius,
            z: z
        )
    }

    private static func objectPose(objectID: Int, timestamp: TimeInterval) throws -> UnitSphereDirection {
        let objectIndex = Double(objectID - 1)
        let goldenAngle = Double.pi * (3.0 - sqrt(5.0))
        let orbit = timestamp * (0.22 + Double(objectID % 17) * 0.006)
        let theta = objectIndex * goldenAngle + orbit
        let z = sin(timestamp * 0.16 + Double(objectID) * 0.11) * 0.72
        let radius = sqrt(max(0, 1.0 - z * z))
        return try UnitSphereDirection.normalized(
            x: cos(theta) * radius,
            y: sin(theta) * radius,
            z: z
        )
    }

    private static func makeTrail(objectID: Int, timestamp: TimeInterval) throws -> [UnitSphereDirection] {
        try (1...maxTrailPointsPerObject).map { step in
            try objectPose(
                objectID: objectID,
                timestamp: timestamp - TimeInterval(step) * 0.0167
            )
        }
    }

    private static func normalizedSine(_ value: Double) -> Double {
        (sin(value) + 1.0) * 0.5
    }

    private static func clamp01(_ value: Float) -> Float {
        min(max(value, 0), 1)
    }
}
