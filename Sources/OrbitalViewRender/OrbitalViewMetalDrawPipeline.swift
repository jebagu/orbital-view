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
                color: meterColor(for: speaker, meters: state.meters)
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

    private static func meterColor(for speaker: OrbitalViewSpeaker, meters: SpeakerMeterFrame?) -> SIMD4<Float> {
        guard let level = meters?.levelsByChannel[speaker.channel] else {
            return SIMD4<Float>(0.12, 0.58, 0.88, 1)
        }

        if level.clip {
            return SIMD4<Float>(1, 0.1, 0.04, 1)
        }

        let peak = min(max(level.peak, 0), 1)
        return SIMD4<Float>(
            0.12 + (0.18 * peak),
            0.46 + (0.42 * peak),
            0.72 + (0.18 * peak),
            1
        )
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
