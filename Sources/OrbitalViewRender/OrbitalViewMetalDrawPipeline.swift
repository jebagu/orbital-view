import Foundation
import Metal
import OrbitalViewCore
import simd

enum OrbitalViewMetalRenderError: Error, Equatable {
    case invalidOffscreenSize(width: Int, height: Int)
    case missingShaderFunction(String)
    case commandQueueCreationFailed
    case commandBufferCreationFailed
    case commandEncoderCreationFailed
    case bufferCreationFailed
    case textureCreationFailed
    case commandBufferFailed(String)
}

struct OrbitalViewOffscreenFrame: Equatable {
    let width: Int
    let height: Int
    let bgra8Bytes: [UInt8]

    var containsNonClearPixel: Bool {
        stride(from: 0, to: bgra8Bytes.count, by: 4).contains { index in
            bgra8Bytes[index] != 0 || bgra8Bytes[index + 1] != 0 || bgra8Bytes[index + 2] != 0
        }
    }
}

struct OrbitalViewSpeakerStaticDrawInput: Equatable {
    let id: String
    let channel: Int
    let projectedX: Float
    let projectedY: Float
    let projectedDepth: Float
    let quadRadius: Float
}

struct OrbitalViewSpeakerDrawInput: Equatable {
    let staticInput: OrbitalViewSpeakerStaticDrawInput
    let meterLevel: SpeakerMeterLevel?
    let color: SIMD4<Float>

    var position: SIMD4<Float> {
        SIMD4<Float>(
            staticInput.projectedX,
            staticInput.projectedY,
            staticInput.quadRadius,
            1
        )
    }
}

struct OrbitalViewSpeakerDrawInputs: Equatable {
    let speakers: [OrbitalViewSpeakerDrawInput]

    var staticGeometry: [OrbitalViewSpeakerStaticDrawInput] {
        speakers.map(\.staticInput)
    }

    var positions: [SIMD4<Float>] {
        speakers.map(\.position)
    }

    var colors: [SIMD4<Float>] {
        speakers.map(\.color)
    }
}

final class OrbitalViewMetalDrawPipeline {
    private static let verticesPerSpeaker = 6
    private static let defaultSpeakerQuadRadius: Float = 0.045
    private static let worldToUnitSphere = 1 / Float(OrbitalViewSceneBuilder.feySphereRadiusM)
    private static let cameraNearEpsilon: Float = 0.0005
    private static let fogDensityFalloff: Float = 1.12
    private static let fallbackCameraState: OrbitalViewCameraState = {
        guard let fallback = try? OrbitalViewCameraState.preset(.isometric) else {
            fatalError("Unable to create fallback camera state")
        }
        return fallback
    }()

    private let deviceID: ObjectIdentifier
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState

    init(device: MTLDevice, pixelFormat: MTLPixelFormat = .bgra8Unorm) throws {
        self.deviceID = ObjectIdentifier(device as AnyObject)
        self.device = device

        guard let commandQueue = device.makeCommandQueue() else {
            throw OrbitalViewMetalRenderError.commandQueueCreationFailed
        }
        self.commandQueue = commandQueue

        let library = try device.makeLibrary(source: orbitalViewMetalShaderSource, options: nil)
        guard let vertexFunction = library.makeFunction(name: "orbital_vertex") else {
            throw OrbitalViewMetalRenderError.missingShaderFunction("orbital_vertex")
        }
        guard let fragmentFunction = library.makeFunction(name: "orbital_fragment") else {
            throw OrbitalViewMetalRenderError.missingShaderFunction("orbital_fragment")
        }

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = pixelFormat

        self.pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
    }

    func uses(device: MTLDevice) -> Bool {
        deviceID == ObjectIdentifier(device as AnyObject)
    }

    func render(
        state: OrbitalViewRenderState,
        renderPassDescriptor: MTLRenderPassDescriptor,
        drawable: MTLDrawable? = nil,
        waitUntilCompleted: Bool = false
    ) throws {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw OrbitalViewMetalRenderError.commandBufferCreationFailed
        }

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            throw OrbitalViewMetalRenderError.commandEncoderCreationFailed
        }

        let inputs = Self.makeSpeakerDrawInputs(from: state)
        if !inputs.positions.isEmpty {
            guard
                let positionBuffer = makeBuffer(from: inputs.positions),
                let colorBuffer = makeBuffer(from: inputs.colors)
            else {
                throw OrbitalViewMetalRenderError.bufferCreationFailed
            }

            encoder.setRenderPipelineState(pipelineState)
            encoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
            encoder.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: inputs.positions.count * Self.verticesPerSpeaker
            )
        }

        encoder.endEncoding()

        if let drawable {
            commandBuffer.present(drawable)
        }

        commandBuffer.commit()

        if waitUntilCompleted {
            commandBuffer.waitUntilCompleted()
            if let error = commandBuffer.error {
                throw OrbitalViewMetalRenderError.commandBufferFailed(error.localizedDescription)
            }
        }
    }

    func renderOffscreen(state: OrbitalViewRenderState, width: Int, height: Int) throws -> OrbitalViewOffscreenFrame {
        guard width > 0, height > 0 else {
            throw OrbitalViewMetalRenderError.invalidOffscreenSize(width: width, height: height)
        }

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.storageMode = .shared

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            throw OrbitalViewMetalRenderError.textureCreationFailed
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 1
        )

        try render(
            state: state,
            renderPassDescriptor: renderPassDescriptor,
            waitUntilCompleted: true
        )

        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var bytes = [UInt8](repeating: 0, count: bytesPerRow * height)
        texture.getBytes(
            &bytes,
            bytesPerRow: bytesPerRow,
            from: MTLRegionMake2D(0, 0, width, height),
            mipmapLevel: 0
        )

        return OrbitalViewOffscreenFrame(width: width, height: height, bgra8Bytes: bytes)
    }

    private func makeBuffer(from values: [SIMD4<Float>]) -> MTLBuffer? {
        values.withUnsafeBytes { bytes in
            guard let baseAddress = bytes.baseAddress else {
                return nil
            }
            return device.makeBuffer(bytes: baseAddress, length: bytes.count, options: .storageModeShared)
        }
    }

    static func makeSpeakerDrawInputs(from state: OrbitalViewRenderState) -> OrbitalViewSpeakerDrawInputs {
        guard let scene = state.scene else {
            return OrbitalViewSpeakerDrawInputs(speakers: [])
        }
        let camera = state.camera ?? fallbackCameraState

        let speakers = scene.speakers.map { speaker -> OrbitalViewSpeakerDrawInput in
            let worldPosition = basePosition(for: speaker, in: scene)
            let projected = project(worldPosition, with: camera)
            let staticInput = OrbitalViewSpeakerStaticDrawInput(
                id: speaker.id,
                channel: speaker.channel,
                projectedX: projected.x,
                projectedY: projected.y,
                projectedDepth: projected.z,
                quadRadius: speakerQuadRadius(for: state.displaySettings)
            )

            let fogAlpha = fogAlpha(
                viewSpaceDepth: projected.z,
                camera: camera,
                settings: state.displaySettings
            )
            return OrbitalViewSpeakerDrawInput(
                staticInput: staticInput,
                meterLevel: state.meters?.levelsByChannel[speaker.channel],
                color: mutedColor(
                    for: speaker,
                    meters: state.meters,
                    settings: state.meterVisualSettings,
                    alpha: fogAlpha
                )
            )
        }

        return OrbitalViewSpeakerDrawInputs(speakers: speakers)
    }

    private static func basePosition(for speaker: OrbitalViewSpeaker, in scene: OrbitalViewSceneSpec) -> SIMD3<Float> {
        switch speaker.anchor {
        case .direction(let direction, _):
            return SIMD3<Float>(
                Float(direction.x) * worldToUnitSphere,
                Float(direction.y) * worldToUnitSphere,
                Float(direction.z) * worldToUnitSphere
            )
        case .node(let nodeID, _):
            guard case .imported(let geometry) = scene.shell,
                  let node = geometry.nodes.first(where: { $0.id == nodeID })
            else {
                return SIMD3<Float>(0, 0, 0)
            }
            return SIMD3<Float>(Float(node.position.x / geometry.radiusM), Float(node.position.y / geometry.radiusM), Float(node.position.z / geometry.radiusM))
        case .edge(let edgeID, let t, _):
            guard case .imported(let geometry) = scene.shell,
                  let edge = geometry.edges.first(where: { $0.id == edgeID }),
                  let a = geometry.nodes.first(where: { $0.id == edge.a }),
                  let b = geometry.nodes.first(where: { $0.id == edge.b })
            else {
                return SIMD3<Float>(0, 0, 0)
            }
            let position = interpolate(a.position, b.position, t: t)
            return SIMD3<Float>(
                Float(position.x / geometry.radiusM),
                Float(position.y / geometry.radiusM),
                Float(position.z / geometry.radiusM)
            )
        case .face(let faceID, let barycentric, _):
            guard case .imported(let geometry) = scene.shell,
                  let face = geometry.faces.first(where: { $0.id == faceID }),
                  face.nodes.count >= 3,
                  let a = geometry.nodes.first(where: { $0.id == face.nodes[0] }),
                  let b = geometry.nodes.first(where: { $0.id == face.nodes[1] }),
                  let c = geometry.nodes.first(where: { $0.id == face.nodes[2] })
            else {
                return SIMD3<Float>(0, 0, 0)
            }
            let position = weighted(a.position, b.position, c.position, weights: barycentric)
            return SIMD3<Float>(
                Float(position.x / geometry.radiusM),
                Float(position.y / geometry.radiusM),
                Float(position.z / geometry.radiusM)
            )
        }
    }

    private static func speakerQuadRadius(for displaySettings: OrbitalViewDisplaySettings) -> Float {
        let scale = displaySettings.speakerScale / OrbitalViewDisplaySettings.defaultSpeakerScale
        return defaultSpeakerQuadRadius * max(scale, 0.01)
    }

    private static func project(_ position: SIMD3<Float>, with camera: OrbitalViewCameraState) -> SIMD3<Float> {
        let cameraPosition = simdOrbitCameraPosition(orbit: camera.orbit)
        let worldUp = SIMD3<Float>(0, 1, 0)

        let forward = normalize(-cameraPosition)
        let crossUp = cross(worldUp, forward)
        let right = normalize(length(crossUp) > 0.000_1 ? crossUp : SIMD3<Float>(0, 0, 1))
        let up = cross(forward, right)
        let relative = position - cameraPosition

        let x = dot(relative, right)
        let y = dot(relative, up)
        let z = dot(relative, forward)

        let clampedZ = max(z, cameraNearEpsilon)
        let perspective = 0.72 / clampedZ
        return SIMD3<Float>(x * perspective, y * perspective, z)
    }

    private static func simdOrbitCameraPosition(orbit: OrbitalViewOrbit) -> SIMD3<Float> {
        let pitch = Float(orbit.pitchRadians)
        let yaw = Float(orbit.yawRadians)
        let distance = Float(orbit.distanceM)

        let x = distance * cos(pitch) * sin(yaw)
        let y = distance * sin(pitch)
        let z = distance * cos(pitch) * cos(yaw)
        return SIMD3<Float>(x, y, z)
    }

    private static func fogAlpha(viewSpaceDepth: Float, camera: OrbitalViewCameraState, settings: OrbitalViewDisplaySettings) -> Float {
        guard settings.isFogEnabled else {
            return 1
        }

        let minDepth = Float(camera.orbit.distanceM) - 1
        let maxDepth = Float(camera.orbit.distanceM) + 1
        let normalizedDepth = (viewSpaceDepth - minDepth) / max(0.000_1, maxDepth - minDepth)
        let depthRatio = min(max(normalizedDepth, 0), 1)
        let density = settings.normalizedFogDensity
        return 1 - min(1, depthRatio * density * fogDensityFalloff)
    }

    private static func interpolate(
        _ a: OrbitalViewVector3,
        _ b: OrbitalViewVector3,
        t: Double
    ) -> SIMD3<Double> {
        SIMD3<Double>(
            a.x + ((b.x - a.x) * t),
            a.y + ((b.y - a.y) * t),
            a.z + ((b.z - a.z) * t)
        )
    }

    private static func weighted(
        _ a: OrbitalViewVector3,
        _ b: OrbitalViewVector3,
        _ c: OrbitalViewVector3,
        weights: OrbitalViewVector3
    ) -> SIMD3<Double> {
        SIMD3<Double>(
            (a.x * weights.x) + (b.x * weights.y) + (c.x * weights.z),
            (a.y * weights.x) + (b.y * weights.y) + (c.y * weights.z),
            (a.z * weights.x) + (b.z * weights.y) + (c.z * weights.z)
        )
    }

    private static func mutedColor(
        for speaker: OrbitalViewSpeaker,
        meters: SpeakerMeterFrame?,
        settings: SpeakerMeterVisualSettings,
        alpha: Float
    ) -> SIMD4<Float> {
        guard let level = meters?.levelsByChannel[speaker.channel] else {
            var color = styleColor(
                value: 0,
                style: settings.style,
                settings: settings,
                speaker: speaker,
                meters: meters
            )
            color.w = alpha
            return color
        }

        if level.clip {
            return SIMD4<Float>(1, 0.1, 0.04, alpha)
        }

        let gain = pow(10.0, Double(settings.visualGainDB) / 20.0)
        let peak = min(max(Double(level.peak) * gain, 0), 1)
        var color = styleColor(
            value: Float(peak),
            style: settings.style,
            settings: settings,
            speaker: speaker,
            meters: meters
        )
        color.w = alpha
        return color
    }

    private static func styleColor(
        value: Float,
        style: SpeakerMeterVisualStyle,
        settings: SpeakerMeterVisualSettings,
        speaker: OrbitalViewSpeaker,
        meters: SpeakerMeterFrame?
    ) -> SIMD4<Float> {
        switch style {
        case .checkerPulseRingAndDiagonalWave, .customTBD:
            return checkerPulseColor(
                value: value,
                settings: settings,
                speaker: speaker,
                timestamp: meters?.timestamp ?? 0
            )
        case .prismGlow:
            return SIMD4<Float>(
                0.12 + (0.18 * value),
                0.46 + (0.42 * value),
                0.72 + (0.18 * value),
                1
            )
        case .warmPulse:
            return SIMD4<Float>(
                0.38 + (0.54 * value),
                0.18 + (0.36 * value),
                0.12 + (0.08 * value),
                1
            )
        case .coolPulse:
            return SIMD4<Float>(
                0.08 + (0.22 * value),
                0.32 + (0.46 * value),
                0.42 + (0.52 * value),
                1
            )
        }
    }

    private static func checkerPulseColor(
        value: Float,
        settings: SpeakerMeterVisualSettings,
        speaker: OrbitalViewSpeaker,
        timestamp: TimeInterval
    ) -> SIMD4<Float> {
        let objectIndex = Float(max(speaker.channel - 1, 0))
        let bandPhase = Float(timestamp.truncatingRemainder(dividingBy: 10_000))
            * settings.checkerBandVelocity
            * 3.9
        let u = fract(objectIndex * 0.37 + 0.13)
        let v = fract(objectIndex * 0.61 + 0.29)
        let checkerSize = Float(max(4, settings.tileDetail - 1))
        let qx = floor(u * checkerSize)
        let qy = floor(v * checkerSize)
        let parity: Float = Int(qx + qy + objectIndex).isMultiple(of: 2) ? 1.06 : 0.82
        let localBandWidth = min(max(settings.checkerBandWidth, 0.22), 0.96)
        let softness = max(0.1, settings.bandSoftness)

        let radial = hypot(u - 0.5, v - 0.5) * 1.42
        let ringPhase = radial * settings.ringFrontDensity - bandPhase + objectIndex * 0.043
        let ring = bandWave(phase: ringPhase, softness: softness, lift: value * 0.035, width: localBandWidth)

        let qu = qx / checkerSize
        let qv = qy / checkerSize
        let diagonal = (qu * 0.92 + qv * 1.18) * settings.ringFrontDensity
        let diagonalPhase = diagonal - bandPhase + objectIndex * 0.051
        let front = bandWave(
            phase: diagonalPhase,
            softness: max(0.45, softness * 0.82),
            lift: 0,
            width: localBandWidth
        )
        let carry = bandWave(
            phase: diagonalPhase + 0.38,
            softness: 1.65,
            lift: 0,
            width: localBandWidth * 0.72
        ) * settings.memoryCarryover

        let hit = max(ring, max(front, carry * 0.68)) * parity
        let quietGate = smoothstep(edge0: 0.045, edge1: 0.16, x: value)
        let alpha = quietGate * min(max(0.11 + hit * (0.41 + value * 0.65), 0), 1)
        let vu = min(max(value * 0.19 + hit * value * 1.21 + carry * 0.16, 0), 1)

        let palette = checkerPalette(for: settings.colorScheme)
        let idle = mix(
            palette.panel,
            mix(palette.accent, palette.accent2, 0.12),
            min(max(settings.idleTint, 0), 1)
        )
        let ramp = rampColor(value: vu, palette: palette)
        let rgb = mix(idle, ramp, alpha)
        return SIMD4<Float>(rgb.x, rgb.y, rgb.z, 1)
    }

    private static func bandWave(phase: Float, softness: Float, lift: Float, width: Float) -> Float {
        let distance = abs(fract(phase) - 0.5) * 2
        let band = pow(min(max(1 - distance / max(width, 0.001), 0), 1), softness)
        return min(max(band + lift, 0), 1)
    }

    private static func rampColor(value: Float, palette: CheckerPalette) -> SIMD3<Float> {
        let clamped = min(max(value, 0), 1)
        if clamped < 0.5 {
            return mix(palette.muted, palette.accent, clamped * 2)
        }
        return mix(palette.accent, palette.accent2, (clamped - 0.5) * 2)
    }

    private static func checkerPalette(for colorScheme: SpeakerMeterColorScheme) -> CheckerPalette {
        switch colorScheme {
        case .kimiPurple:
            return CheckerPalette(
                panel: rgb(0x14, 0x18, 0x1C),
                muted: rgb(0xA7, 0xA0, 0xB8),
                accent: rgb(0xAA, 0x88, 0xFF),
                accent2: rgb(0x32, 0xD6, 0xBF)
            )
        case .orbisonicGreen:
            return CheckerPalette(
                panel: rgb(0x07, 0x10, 0x0E),
                muted: rgb(0x85, 0xA4, 0x9A),
                accent: rgb(0x42, 0xD8, 0x8A),
                accent2: rgb(0xD1, 0xF7, 0x7A)
            )
        case .monochrome:
            return CheckerPalette(
                panel: rgb(0x12, 0x12, 0x12),
                muted: rgb(0x8A, 0x8A, 0x8A),
                accent: rgb(0xD8, 0xD8, 0xD8),
                accent2: rgb(0xFF, 0xFF, 0xFF)
            )
        }
    }

    private static func smoothstep(edge0: Float, edge1: Float, x: Float) -> Float {
        let t = min(max((x - edge0) / (edge1 - edge0), 0), 1)
        return t * t * (3 - 2 * t)
    }

    private static func fract(_ value: Float) -> Float {
        value - floor(value)
    }

    private static func mix(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ t: Float) -> SIMD3<Float> {
        a + ((b - a) * min(max(t, 0), 1))
    }

    private static func rgb(_ red: Int, _ green: Int, _ blue: Int) -> SIMD3<Float> {
        SIMD3<Float>(Float(red) / 255, Float(green) / 255, Float(blue) / 255)
    }

    private struct CheckerPalette {
        let panel: SIMD3<Float>
        let muted: SIMD3<Float>
        let accent: SIMD3<Float>
        let accent2: SIMD3<Float>
    }
}

private let orbitalViewMetalShaderSource = """
#include <metal_stdlib>
using namespace metal;

struct OrbitalVertexOut {
    float4 position [[position]];
    float4 color;
};

static float2 orbital_corner(uint index) {
    switch (index) {
    case 0:
        return float2(-1.0, -1.0);
    case 1:
        return float2(1.0, -1.0);
    case 2:
        return float2(-1.0, 1.0);
    case 3:
        return float2(-1.0, 1.0);
    case 4:
        return float2(1.0, -1.0);
    default:
        return float2(1.0, 1.0);
    }
}

vertex OrbitalVertexOut orbital_vertex(
    uint vertexID [[vertex_id]],
    const device float4 *speakerPositions [[buffer(0)]],
    const device float4 *speakerColors [[buffer(1)]]
) {
    uint speakerIndex = vertexID / 6;
    uint cornerIndex = vertexID % 6;
    float4 speaker = speakerPositions[speakerIndex];
    float2 position = speaker.xy + (orbital_corner(cornerIndex) * speaker.z);

    OrbitalVertexOut out;
    out.position = float4(position, 0.0, 1.0);
    out.color = speakerColors[speakerIndex];
    return out;
}

fragment float4 orbital_fragment(OrbitalVertexOut in [[stage_in]]) {
    return in.color;
}
"""
