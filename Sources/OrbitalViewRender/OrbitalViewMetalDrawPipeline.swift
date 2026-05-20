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
    private static let speakerQuadRadius: Float = 0.045

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

        let speakers = scene.speakers.map { speaker -> OrbitalViewSpeakerDrawInput in
            let position = projectedPosition(for: speaker)
            let staticInput = OrbitalViewSpeakerStaticDrawInput(
                id: speaker.id,
                channel: speaker.channel,
                projectedX: position.x,
                projectedY: position.y,
                quadRadius: speakerQuadRadius
            )
            return OrbitalViewSpeakerDrawInput(
                staticInput: staticInput,
                meterLevel: state.meters?.levelsByChannel[speaker.channel],
                color: meterColor(
                    for: speaker,
                    meters: state.meters,
                    settings: state.meterVisualSettings
                )
            )
        }

        return OrbitalViewSpeakerDrawInputs(speakers: speakers)
    }

    private static func projectedPosition(for speaker: OrbitalViewSpeaker) -> SIMD2<Float> {
        switch speaker.anchor {
        case .direction(let direction, _):
            return SIMD2<Float>(Float(direction.x) * 0.72, Float(direction.y) * 0.72)
        case .node, .edge, .face:
            return SIMD2<Float>(0, 0)
        }
    }

    private static func meterColor(
        for speaker: OrbitalViewSpeaker,
        meters: SpeakerMeterFrame?,
        settings: SpeakerMeterVisualSettings
    ) -> SIMD4<Float> {
        guard let level = meters?.levelsByChannel[speaker.channel] else {
            return styleColor(
                value: 0,
                style: settings.style,
                settings: settings,
                speaker: speaker,
                meters: meters
            )
        }

        if level.clip {
            return SIMD4<Float>(1, 0.1, 0.04, 1)
        }

        let gain = pow(10.0, Double(settings.visualGainDB) / 20.0)
        let peak = min(max(Double(level.peak) * gain, 0), 1)
        return styleColor(
            value: Float(peak),
            style: settings.style,
            settings: settings,
            speaker: speaker,
            meters: meters
        )
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
