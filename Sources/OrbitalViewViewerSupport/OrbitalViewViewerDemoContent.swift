import Foundation
import OrbitalViewCore

public enum OrbitalViewViewerDemoContent {
    public static let speakerCount = 30
    public static let objectIDs = [1, 2, 3]
    public static let maxTrailPointsPerObject = 12

    public static func makeScene() throws -> OrbitalViewSceneSpec {
        let shell = try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)
        return try OrbitalViewSceneSpec(
            id: "orbital-view-viewer-demo",
            coordinateSystem: .wavefield,
            shell: .parametric(shell),
            speakers: makeSpeakers(),
            virtualObjects: objectIDs.map { try OrbitalViewVirtualObject(id: "object-\($0)", label: "Object \($0)") },
            theme: .daftPunkBow
        )
    }

    public static func makeSpeakerMeters(timestamp: TimeInterval) throws -> SpeakerMeterFrame {
        var levelsByChannel: [Int: SpeakerMeterLevel] = [:]
        for channel in 1...speakerCount {
            let phase = timestamp * 1.85 + Double(channel) * 0.41
            let slowPhase = timestamp * 0.34 + Double(channel) * 0.17
            let base = 0.18 + 0.34 * normalizedSine(phase)
            let lift = 0.22 * normalizedSine(slowPhase)
            let pulse = channel % 6 == 0 ? 0.25 * normalizedSine(timestamp * 4.2) : 0
            let rms = clamp01(Float(base + lift + pulse))
            let peak = clamp01(rms + 0.16 + Float(0.06 * normalizedSine(phase * 1.7)))
            let clip = peak > 0.96
            levelsByChannel[channel] = try SpeakerMeterLevel(rms: rms, peak: peak, clip: clip)
        }

        return try SpeakerMeterFrame(
            timestamp: timestamp,
            levelsByChannel: levelsByChannel,
            source: .syntheticVisualStress
        )
    }

    public static func makeObjectFrames(timestamp: TimeInterval) throws -> OrbitalViewObjectFrameSet {
        let frames = try objectIDs.map { objectID in
            try OrbitalViewObjectFrame(
                objectID: objectID,
                label: "Object \(objectID)",
                category: objectID == 1 ? "dialog" : "source",
                pose: objectPose(objectID: objectID, timestamp: timestamp),
                width: Float(0.18 + 0.06 * normalizedSine(timestamp + Double(objectID))),
                trail: makeTrail(objectID: objectID, timestamp: timestamp)
            )
        }

        return try OrbitalViewObjectFrameSet(
            timestamp: timestamp,
            activeObjects: frames,
            maxActiveObjects: objectIDs.count,
            maxTrailPointsPerObject: maxTrailPointsPerObject
        )
    }

    public static func makeObjectMeters(timestamp: TimeInterval) throws -> ObjectMeterFrame {
        var levelsByObjectID: [Int: ObjectMeterLevel] = [:]
        for objectID in objectIDs {
            let phase = timestamp * (1.1 + Double(objectID) * 0.25)
            let rms = clamp01(Float(0.22 + 0.58 * normalizedSine(phase)))
            let peak = clamp01(rms + 0.18)
            levelsByObjectID[objectID] = try ObjectMeterLevel(rms: rms, peak: peak, clip: peak > 0.98)
        }

        return try ObjectMeterFrame(
            timestamp: timestamp,
            levelsByObjectID: levelsByObjectID,
            source: .syntheticVisualStress
        )
    }

    public static func makeMeterVisualSettings() throws -> SpeakerMeterVisualSettings {
        try SpeakerMeterVisualSettings(
            colorScheme: .daftPunkBow,
            inputCalibration: 1,
            levelCompression: 1.65,
            displayCeiling: 1,
            hotResponse: 1.7,
            hotThreshold: 0.68,
            hotFillStrength: 0.86,
            vuPaletteDrive: 1.7,
            idleTint: 0.25,
            checkerContrast: 0.08,
            speakerZScale: 1,
            facePixels: 9,
            showsDiagnostics: true
        )
    }

    public static func makeObjectVisualSettings() throws -> ObjectVisualSettings {
        try ObjectVisualSettings(
            shape: .halo,
            palette: .sourceGold,
            coreSize: 0.07,
            widthScale: 1.15,
            glowIntensity: 0.9,
            trailsEnabled: true,
            trailLengthSeconds: 1.6,
            trailDecay: 0.76,
            maxTrailPointsPerObject: maxTrailPointsPerObject,
            glowTrailsEnabled: true,
            glowTrailIntensity: 0.85,
            glowTrailWidth: 0.11,
            glowTrailDecay: 0.68,
            showsBounds: true
        )
    }

    private static func makeSpeakers() throws -> [OrbitalViewSpeaker] {
        try (1...speakerCount).map { channel in
            try OrbitalViewSpeaker(
                id: speakerID(channel),
                channel: channel,
                label: speakerLabel(channel),
                anchor: .direction(speakerDirection(channel), offsetM: 0.05),
                shape: SpeakerShape.sonicSphereDefault(edgeM: SpeakerShape.defaultSonicSphereEdgeM)
            )
        }
    }

    private static func speakerID(_ channel: Int) -> String {
        String(format: "speaker-%02d", channel)
    }

    private static func speakerLabel(_ channel: Int) -> String {
        String(format: "Fey %02d", channel)
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
        let phase = timestamp * (0.32 + Double(objectID) * 0.08) + Double(objectID) * 1.7
        let elevation = 0.48 * sin(timestamp * 0.18 + Double(objectID))
        return try UnitSphereDirection.normalized(
            x: cos(phase) * cos(elevation),
            y: sin(phase) * cos(elevation),
            z: sin(elevation)
        )
    }

    private static func makeTrail(objectID: Int, timestamp: TimeInterval) throws -> [UnitSphereDirection] {
        try (1...maxTrailPointsPerObject).map { step in
            try objectPose(
                objectID: objectID,
                timestamp: timestamp - TimeInterval(step) * 0.08
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
