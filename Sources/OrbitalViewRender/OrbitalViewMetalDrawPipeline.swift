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

struct OrbitalViewObjectStaticDrawInput: Equatable {
    let objectID: Int
    let label: String
    let shape: ObjectVisualShape
}

struct OrbitalViewObjectDrawInput: Equatable {
    let staticInput: OrbitalViewObjectStaticDrawInput
    let isTrailSample: Bool
    let trailIndex: Int
    let projectedX: Float
    let projectedY: Float
    let quadRadius: Float
    let meterLevel: ObjectMeterLevel?
    let color: SIMD4<Float>

    var position: SIMD4<Float> {
        SIMD4<Float>(projectedX, projectedY, quadRadius, 1)
    }
}

struct OrbitalViewObjectDrawInputs: Equatable {
    let objects: [OrbitalViewObjectDrawInput]

    var staticObjects: [OrbitalViewObjectStaticDrawInput] {
        var seen = Set<Int>()
        return objects.compactMap { input in
            guard !input.isTrailSample, seen.insert(input.staticInput.objectID).inserted else {
                return nil
            }
            return input.staticInput
        }
    }

    var positions: [SIMD4<Float>] {
        objects.map(\.position)
    }

    var colors: [SIMD4<Float>] {
        objects.map(\.color)
    }
}

final class OrbitalViewMetalDrawPipeline {
    private static let verticesPerSpeaker = 6
    private static let speakerQuadRadius: Float = 0.045
    private static let verticesPerObject = 6
    private static let projectionScale: Float = 0.72

    private let deviceID: ObjectIdentifier
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private var speakerPositionBuffer: MTLBuffer?
    private var speakerColorBuffer: MTLBuffer?
    private var objectPositionBuffer: MTLBuffer?
    private var objectColorBuffer: MTLBuffer?
    private var speakerPositionCapacity = 0
    private var speakerColorCapacity = 0
    private var objectPositionCapacity = 0
    private var objectColorCapacity = 0
    private var speakerPositionRevision: Int?
    private var speakerColorRevisionKey: SpeakerColorRevisionKey?
    private var objectPositionRevisionKey: ObjectPositionRevisionKey?
    private var objectColorRevisionKey: ObjectColorRevisionKey?
    private var speakerDrawCount = 0
    private var objectDrawCount = 0
    private(set) var debugBufferAllocationCount = 0

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

        if let speakerResources = prepareSpeakerDrawResources(for: state) {
            let positionBuffer = speakerResources.positionBuffer
            let colorBuffer = speakerResources.colorBuffer

            encoder.setRenderPipelineState(pipelineState)
            encoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
            encoder.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: speakerResources.drawCount * Self.verticesPerSpeaker
            )
        }

        if let objectResources = prepareObjectDrawResources(for: state) {
            let positionBuffer = objectResources.positionBuffer
            let colorBuffer = objectResources.colorBuffer

            encoder.setRenderPipelineState(pipelineState)
            encoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
            encoder.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: objectResources.drawCount * Self.verticesPerObject
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

    private func updateSpeakerPositionBuffer(from values: [SIMD4<Float>]) -> MTLBuffer? {
        let update = reusableBuffer(existing: speakerPositionBuffer, capacity: speakerPositionCapacity, values: values)
        speakerPositionBuffer = update.buffer
        speakerPositionCapacity = update.capacity
        debugBufferAllocationCount += update.allocated ? 1 : 0
        return update.buffer
    }

    private func prepareSpeakerDrawResources(
        for state: OrbitalViewRenderState
    ) -> (positionBuffer: MTLBuffer, colorBuffer: MTLBuffer, drawCount: Int)? {
        let positionRevision = state.structuralRevision
        let colorRevisionKey = SpeakerColorRevisionKey(
            structuralRevision: state.structuralRevision,
            meterRevision: state.meterRevision,
            meterVisualSettingsRevision: state.meterVisualSettingsRevision
        )
        var cachedInputs: OrbitalViewSpeakerDrawInputs?

        if speakerPositionRevision != positionRevision {
            let inputs = Self.makeSpeakerDrawInputs(from: state)
            cachedInputs = inputs
            guard !inputs.positions.isEmpty else {
                speakerDrawCount = 0
                speakerPositionRevision = positionRevision
                speakerColorRevisionKey = colorRevisionKey
                return nil
            }
            guard updateSpeakerPositionBuffer(from: inputs.positions) != nil else {
                return nil
            }
            speakerDrawCount = inputs.positions.count
            speakerPositionRevision = positionRevision
            speakerColorRevisionKey = nil
        }

        if speakerColorRevisionKey != colorRevisionKey {
            let inputs = cachedInputs ?? Self.makeSpeakerDrawInputs(from: state)
            guard !inputs.colors.isEmpty else {
                speakerDrawCount = 0
                speakerColorRevisionKey = colorRevisionKey
                return nil
            }
            guard updateSpeakerColorBuffer(from: inputs.colors) != nil else {
                return nil
            }
            speakerDrawCount = inputs.colors.count
            speakerColorRevisionKey = colorRevisionKey
        }

        guard
            let positionBuffer = speakerPositionBuffer,
            let colorBuffer = speakerColorBuffer,
            speakerDrawCount > 0
        else {
            return nil
        }

        return (positionBuffer, colorBuffer, speakerDrawCount)
    }

    private func prepareObjectDrawResources(
        for state: OrbitalViewRenderState
    ) -> (positionBuffer: MTLBuffer, colorBuffer: MTLBuffer, drawCount: Int)? {
        let positionRevisionKey = ObjectPositionRevisionKey(
            objectFrameRevision: state.objectFrameRevision,
            objectVisualSettingsRevision: state.objectVisualSettingsRevision
        )
        let colorRevisionKey = ObjectColorRevisionKey(
            objectFrameRevision: state.objectFrameRevision,
            objectMeterRevision: state.objectMeterRevision,
            objectVisualSettingsRevision: state.objectVisualSettingsRevision
        )
        var cachedInputs: OrbitalViewObjectDrawInputs?

        if objectPositionRevisionKey != positionRevisionKey {
            let inputs = Self.makeObjectDrawInputs(from: state)
            cachedInputs = inputs
            guard !inputs.positions.isEmpty else {
                objectDrawCount = 0
                objectPositionRevisionKey = positionRevisionKey
                objectColorRevisionKey = colorRevisionKey
                return nil
            }
            guard updateObjectPositionBuffer(from: inputs.positions) != nil else {
                return nil
            }
            objectDrawCount = inputs.positions.count
            objectPositionRevisionKey = positionRevisionKey
            objectColorRevisionKey = nil
        }

        if objectColorRevisionKey != colorRevisionKey {
            let inputs = cachedInputs ?? Self.makeObjectDrawInputs(from: state)
            guard !inputs.colors.isEmpty else {
                objectDrawCount = 0
                objectColorRevisionKey = colorRevisionKey
                return nil
            }
            guard updateObjectColorBuffer(from: inputs.colors) != nil else {
                return nil
            }
            objectDrawCount = inputs.colors.count
            objectColorRevisionKey = colorRevisionKey
        }

        guard
            let positionBuffer = objectPositionBuffer,
            let colorBuffer = objectColorBuffer,
            objectDrawCount > 0
        else {
            return nil
        }

        return (positionBuffer, colorBuffer, objectDrawCount)
    }

    private func updateSpeakerColorBuffer(from values: [SIMD4<Float>]) -> MTLBuffer? {
        let update = reusableBuffer(existing: speakerColorBuffer, capacity: speakerColorCapacity, values: values)
        speakerColorBuffer = update.buffer
        speakerColorCapacity = update.capacity
        debugBufferAllocationCount += update.allocated ? 1 : 0
        return update.buffer
    }

    private func updateObjectPositionBuffer(from values: [SIMD4<Float>]) -> MTLBuffer? {
        let update = reusableBuffer(existing: objectPositionBuffer, capacity: objectPositionCapacity, values: values)
        objectPositionBuffer = update.buffer
        objectPositionCapacity = update.capacity
        debugBufferAllocationCount += update.allocated ? 1 : 0
        return update.buffer
    }

    private func updateObjectColorBuffer(from values: [SIMD4<Float>]) -> MTLBuffer? {
        let update = reusableBuffer(existing: objectColorBuffer, capacity: objectColorCapacity, values: values)
        objectColorBuffer = update.buffer
        objectColorCapacity = update.capacity
        debugBufferAllocationCount += update.allocated ? 1 : 0
        return update.buffer
    }

    private func reusableBuffer(
        existing: MTLBuffer?,
        capacity: Int,
        values: [SIMD4<Float>]
    ) -> (buffer: MTLBuffer?, capacity: Int, allocated: Bool) {
        let requiredCapacity = max(values.count, 1)
        let byteCount = requiredCapacity * MemoryLayout<SIMD4<Float>>.stride
        let buffer: MTLBuffer
        let nextCapacity: Int
        let allocated: Bool

        if let existing, capacity >= requiredCapacity {
            buffer = existing
            nextCapacity = capacity
            allocated = false
        } else if let created = device.makeBuffer(length: byteCount, options: .storageModeShared) {
            buffer = created
            nextCapacity = requiredCapacity
            allocated = true
        } else {
            return (nil, capacity, false)
        }

        values.withUnsafeBytes { bytes in
            guard let baseAddress = bytes.baseAddress else {
                return
            }
            buffer.contents().copyMemory(from: baseAddress, byteCount: bytes.count)
        }

        return (buffer, nextCapacity, allocated)
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

    static func makeObjectDrawInputs(from state: OrbitalViewRenderState) -> OrbitalViewObjectDrawInputs {
        guard let frameSet = state.objectFrames else {
            return OrbitalViewObjectDrawInputs(objects: [])
        }

        let settings = state.objectVisualSettings
        let maxTrailPoints = min(settings.maxTrailPointsPerObject, frameSet.maxTrailPointsPerObject)
        var drawInputs: [OrbitalViewObjectDrawInput] = []
        drawInputs.reserveCapacity(frameSet.activeObjects.count * max(1, maxTrailPoints + 1))

        for object in frameSet.activeObjects {
            guard isInsideBounds(object.pose, settings: settings) else {
                continue
            }
            let staticInput = OrbitalViewObjectStaticDrawInput(
                objectID: object.objectID,
                label: object.label,
                shape: settings.shape
            )
            let meterLevel = state.objectMeters?.levelsByObjectID[object.objectID]
            let position = projectedPosition(for: object.pose)
            let coreRadius = objectCoreRadius(width: object.width, settings: settings)
            drawInputs.append(
                OrbitalViewObjectDrawInput(
                    staticInput: staticInput,
                    isTrailSample: false,
                    trailIndex: 0,
                    projectedX: position.x,
                    projectedY: position.y,
                    quadRadius: coreRadius,
                    meterLevel: meterLevel,
                    color: objectColor(
                        for: object,
                        meterLevel: meterLevel,
                        settings: settings,
                        trailStrength: 1
                    )
                )
            )

            guard settings.trailsEnabled || settings.glowTrailsEnabled, maxTrailPoints > 0 else {
                continue
            }

            let cappedTrail = object.trail.suffix(maxTrailPoints)
            for (index, trailPose) in cappedTrail.enumerated() {
                guard isInsideBounds(trailPose, settings: settings) else {
                    continue
                }
                let trailPosition = projectedPosition(for: trailPose)
                let age = Float(index + 1) / Float(max(cappedTrail.count, 1))
                let decay = max(0, 1 - age) * settings.trailDecay
                let trailRadius = max(
                    0.004,
                    min(coreRadius * 0.72, settings.glowTrailsEnabled ? settings.glowTrailWidth : coreRadius * 0.5)
                )
                drawInputs.append(
                    OrbitalViewObjectDrawInput(
                        staticInput: staticInput,
                        isTrailSample: true,
                        trailIndex: index,
                        projectedX: trailPosition.x,
                        projectedY: trailPosition.y,
                        quadRadius: trailRadius,
                        meterLevel: meterLevel,
                        color: objectColor(
                            for: object,
                            meterLevel: meterLevel,
                            settings: settings,
                            trailStrength: decay
                        )
                    )
                )
            }
        }

        return OrbitalViewObjectDrawInputs(objects: drawInputs)
    }

    private static func projectedPosition(for speaker: OrbitalViewSpeaker) -> SIMD2<Float> {
        switch speaker.anchor {
        case .direction(let direction, _):
            return projectedPosition(for: direction)
        case .node, .edge, .face:
            return SIMD2<Float>(0, 0)
        }
    }

    private static func projectedPosition(for direction: UnitSphereDirection) -> SIMD2<Float> {
        SIMD2<Float>(Float(direction.x) * projectionScale, Float(direction.y) * projectionScale)
    }

    private static func objectCoreRadius(width: Float, settings: ObjectVisualSettings) -> Float {
        let widthLift = min(max(width * settings.widthScale, 0), 5) * 0.018
        return settings.coreSize + widthLift
    }

    private static func isInsideBounds(_ direction: UnitSphereDirection, settings: ObjectVisualSettings) -> Bool {
        let maximum = settings.bounds.maximum
        let minimum = settings.bounds.minimum
        return Float(direction.x) >= minimum
            && Float(direction.x) <= maximum
            && Float(direction.y) >= minimum
            && Float(direction.y) <= maximum
            && Float(direction.z) >= minimum
            && Float(direction.z) <= maximum
    }

    private static func objectColor(
        for object: OrbitalViewObjectFrame,
        meterLevel: ObjectMeterLevel?,
        settings: ObjectVisualSettings,
        trailStrength: Float
    ) -> SIMD4<Float> {
        if meterLevel?.clip == true {
            let flash = min(max(settings.clipFlashIntensity, 0), 2)
            return SIMD4<Float>(1, max(0.05, 0.22 * flash), 0.05, 1)
        }

        let peak = min(max(meterLevel?.peak ?? 0, 0), 1)
        let palette = objectPalette(for: settings.palette)
        let shapeLift: Float
        switch settings.shape {
        case .orb:
            shapeLift = 0.12
        case .halo:
            shapeLift = 0.2
        case .comet:
            shapeLift = 0.28
        }

        let glow = min(max(peak * settings.glowIntensity + shapeLift, 0), 1)
        let base = mix(palette.idle, palette.hot, glow)
        let trailMix = min(max(trailStrength, 0), 1)
        let rgb = mix(palette.trail, base, trailMix)
        return SIMD4<Float>(rgb.x, rgb.y, rgb.z, 1)
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

    private static func objectPalette(for palette: ObjectVisualPalette) -> ObjectPalette {
        switch palette {
        case .objectPurple:
            return ObjectPalette(
                idle: rgb(0x32, 0x25, 0x50),
                hot: rgb(0xCC, 0xA8, 0xFF),
                trail: rgb(0x5A, 0x46, 0x7D)
            )
        case .sourceGold:
            return ObjectPalette(
                idle: rgb(0x35, 0x26, 0x0E),
                hot: rgb(0xFF, 0xD1, 0x5C),
                trail: rgb(0x8F, 0x67, 0x1E)
            )
        case .spectralBlue:
            return ObjectPalette(
                idle: rgb(0x0D, 0x24, 0x33),
                hot: rgb(0x5E, 0xEA, 0xD4),
                trail: rgb(0x1F, 0x74, 0x9A)
            )
        case .monochrome:
            return ObjectPalette(
                idle: rgb(0x22, 0x22, 0x22),
                hot: rgb(0xFF, 0xFF, 0xFF),
                trail: rgb(0x77, 0x77, 0x77)
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

    private struct ObjectPalette {
        let idle: SIMD3<Float>
        let hot: SIMD3<Float>
        let trail: SIMD3<Float>
    }

    private struct SpeakerColorRevisionKey: Equatable {
        let structuralRevision: Int
        let meterRevision: Int
        let meterVisualSettingsRevision: Int
    }

    private struct ObjectPositionRevisionKey: Equatable {
        let objectFrameRevision: Int
        let objectVisualSettingsRevision: Int
    }

    private struct ObjectColorRevisionKey: Equatable {
        let objectFrameRevision: Int
        let objectMeterRevision: Int
        let objectVisualSettingsRevision: Int
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
