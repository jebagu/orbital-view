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
    let meshVertexCount: Int
    let meshDepthScale: Float
}

struct OrbitalViewSpeakerStaticGeometryCacheKey: Equatable {
    struct Entry: Equatable {
        let id: String
        let channel: Int
        let anchor: SpeakerAnchor
        let shape: SpeakerShape
        let visualRole: SpeakerVisualRole
    }

    let entries: [Entry]
}

struct OrbitalViewSpeakerDrawInput: Equatable {
    let staticInput: OrbitalViewSpeakerStaticDrawInput
    let meterLevel: SpeakerMeterLevel?
    let color: SIMD4<Float>
    let material: SIMD4<Float>
    let orientation: SIMD4<Float>

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

    var materials: [SIMD4<Float>] {
        speakers.map(\.material)
    }

    var orientations: [SIMD4<Float>] {
        speakers.map(\.orientation)
    }

    var channelToInstanceIndex: [Int: Int] {
        Dictionary(uniqueKeysWithValues: speakers.enumerated().map { index, input in
            (input.staticInput.channel, index)
        })
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
    private static let verticesPerSpeaker = 36
    private static let rampUniformStopCount = 8
    private static let speakerQuadRadius: Float = 0.045
    private static let verticesPerObject = 6
    private static let projectionScale: Float = 0.72

    private let deviceID: ObjectIdentifier
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let speakerPipelineState: MTLRenderPipelineState
    private let objectPipelineState: MTLRenderPipelineState
    private var speakerPositionBuffer: MTLBuffer?
    private var speakerOrientationBuffer: MTLBuffer?
    private var speakerMaterialBuffer: MTLBuffer?
    private var speakerRampBuffer: MTLBuffer?
    private var objectPositionBuffer: MTLBuffer?
    private var objectColorBuffer: MTLBuffer?
    private var speakerPositionCapacity = 0
    private var speakerOrientationCapacity = 0
    private var speakerMaterialCapacity = 0
    private var speakerRampCapacity = 0
    private var objectPositionCapacity = 0
    private var objectColorCapacity = 0
    private var speakerPositionRevision: Int?
    private var speakerOrientationRevision: Int?
    private var speakerMaterialRevisionKey: SpeakerMaterialRevisionKey?
    private var speakerRampRevision: Int?
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
        guard let speakerVertexFunction = library.makeFunction(name: "orbital_speaker_vertex") else {
            throw OrbitalViewMetalRenderError.missingShaderFunction("orbital_speaker_vertex")
        }
        guard let speakerFragmentFunction = library.makeFunction(name: "orbital_speaker_fragment") else {
            throw OrbitalViewMetalRenderError.missingShaderFunction("orbital_speaker_fragment")
        }
        guard let objectVertexFunction = library.makeFunction(name: "orbital_object_vertex") else {
            throw OrbitalViewMetalRenderError.missingShaderFunction("orbital_object_vertex")
        }
        guard let objectFragmentFunction = library.makeFunction(name: "orbital_object_fragment") else {
            throw OrbitalViewMetalRenderError.missingShaderFunction("orbital_object_fragment")
        }

        let speakerDescriptor = MTLRenderPipelineDescriptor()
        speakerDescriptor.vertexFunction = speakerVertexFunction
        speakerDescriptor.fragmentFunction = speakerFragmentFunction
        speakerDescriptor.colorAttachments[0].pixelFormat = pixelFormat

        let objectDescriptor = MTLRenderPipelineDescriptor()
        objectDescriptor.vertexFunction = objectVertexFunction
        objectDescriptor.fragmentFunction = objectFragmentFunction
        objectDescriptor.colorAttachments[0].pixelFormat = pixelFormat

        self.speakerPipelineState = try device.makeRenderPipelineState(descriptor: speakerDescriptor)
        self.objectPipelineState = try device.makeRenderPipelineState(descriptor: objectDescriptor)
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
            let orientationBuffer = speakerResources.orientationBuffer
            let materialBuffer = speakerResources.materialBuffer
            let rampBuffer = speakerResources.rampBuffer
            var bloomUniforms = Self.makeBloomUniforms(settings: state.meterVisualSettings)
            var hotUniforms = Self.makeHotUniforms(settings: state.meterVisualSettings)

            encoder.setRenderPipelineState(speakerPipelineState)
            encoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(orientationBuffer, offset: 0, index: 1)
            encoder.setVertexBuffer(materialBuffer, offset: 0, index: 2)
            encoder.setFragmentBytes(
                &bloomUniforms,
                length: MemoryLayout<SIMD4<Float>>.stride,
                index: 0
            )
            encoder.setFragmentBuffer(rampBuffer, offset: 0, index: 1)
            encoder.setFragmentBytes(
                &hotUniforms,
                length: MemoryLayout<SIMD4<Float>>.stride,
                index: 2
            )
            encoder.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: Self.verticesPerSpeaker,
                instanceCount: speakerResources.drawCount
            )
        }

        if let objectResources = prepareObjectDrawResources(for: state) {
            let positionBuffer = objectResources.positionBuffer
            let colorBuffer = objectResources.colorBuffer

            encoder.setRenderPipelineState(objectPipelineState)
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
    ) -> (
        positionBuffer: MTLBuffer,
        orientationBuffer: MTLBuffer,
        materialBuffer: MTLBuffer,
        rampBuffer: MTLBuffer,
        drawCount: Int
    )? {
        let positionRevision = state.structuralRevision
        let materialRevisionKey = SpeakerMaterialRevisionKey(
            structuralRevision: state.structuralRevision,
            meterRevision: state.meterRevision,
            meterVisualSettingsRevision: state.meterVisualSettingsRevision
        )
        let rampRevision = state.meterVisualSettingsRevision
        var cachedInputs: OrbitalViewSpeakerDrawInputs?

        if speakerPositionRevision != positionRevision {
            let inputs = Self.makeSpeakerDrawInputs(from: state)
            cachedInputs = inputs
            guard !inputs.positions.isEmpty else {
                speakerDrawCount = 0
                speakerPositionRevision = positionRevision
                speakerOrientationRevision = positionRevision
                speakerMaterialRevisionKey = materialRevisionKey
                return nil
            }
            guard updateSpeakerPositionBuffer(from: inputs.positions) != nil else {
                return nil
            }
            guard updateSpeakerOrientationBuffer(from: inputs.orientations) != nil else {
                return nil
            }
            speakerDrawCount = inputs.positions.count
            speakerPositionRevision = positionRevision
            speakerOrientationRevision = positionRevision
            speakerMaterialRevisionKey = nil
        }

        if speakerOrientationRevision != positionRevision {
            let inputs = cachedInputs ?? Self.makeSpeakerDrawInputs(from: state)
            guard updateSpeakerOrientationBuffer(from: inputs.orientations) != nil else {
                return nil
            }
            speakerOrientationRevision = positionRevision
        }

        if speakerMaterialRevisionKey != materialRevisionKey {
            let inputs = cachedInputs ?? Self.makeSpeakerDrawInputs(from: state)
            guard !inputs.materials.isEmpty else {
                speakerDrawCount = 0
                speakerMaterialRevisionKey = materialRevisionKey
                return nil
            }
            guard updateSpeakerMaterialBuffer(from: inputs.materials) != nil else {
                return nil
            }
            speakerDrawCount = inputs.materials.count
            speakerMaterialRevisionKey = materialRevisionKey
        }

        if speakerRampRevision != rampRevision {
            guard updateSpeakerRampBuffer(from: Self.makeRampUniforms(settings: state.meterVisualSettings)) != nil else {
                return nil
            }
            speakerRampRevision = rampRevision
        }

        guard
            let positionBuffer = speakerPositionBuffer,
            let orientationBuffer = speakerOrientationBuffer,
            let materialBuffer = speakerMaterialBuffer,
            let rampBuffer = speakerRampBuffer,
            speakerDrawCount > 0
        else {
            return nil
        }

        return (positionBuffer, orientationBuffer, materialBuffer, rampBuffer, speakerDrawCount)
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

    private func updateSpeakerOrientationBuffer(from values: [SIMD4<Float>]) -> MTLBuffer? {
        let update = reusableBuffer(
            existing: speakerOrientationBuffer,
            capacity: speakerOrientationCapacity,
            values: values
        )
        speakerOrientationBuffer = update.buffer
        speakerOrientationCapacity = update.capacity
        debugBufferAllocationCount += update.allocated ? 1 : 0
        return update.buffer
    }

    private func updateSpeakerMaterialBuffer(from values: [SIMD4<Float>]) -> MTLBuffer? {
        let update = reusableBuffer(existing: speakerMaterialBuffer, capacity: speakerMaterialCapacity, values: values)
        speakerMaterialBuffer = update.buffer
        speakerMaterialCapacity = update.capacity
        debugBufferAllocationCount += update.allocated ? 1 : 0
        return update.buffer
    }

    private func updateSpeakerRampBuffer(from values: [SIMD4<Float>]) -> MTLBuffer? {
        let update = reusableBuffer(existing: speakerRampBuffer, capacity: speakerRampCapacity, values: values)
        speakerRampBuffer = update.buffer
        speakerRampCapacity = update.capacity
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
                quadRadius: speakerQuadRadius,
                meshVertexCount: verticesPerSpeaker,
                meshDepthScale: meshDepthScale(for: speaker.shape)
            )
            return OrbitalViewSpeakerDrawInput(
                staticInput: staticInput,
                meterLevel: state.meters?.levelsByChannel[speaker.channel],
                color: meterColor(
                    for: speaker,
                    meters: state.meters,
                    settings: state.meterVisualSettings
                ),
                material: speakerMaterial(
                    for: speaker,
                    meters: state.meters,
                    settings: state.meterVisualSettings
                ),
                orientation: speakerOrientation(for: speaker, depthScale: staticInput.meshDepthScale)
            )
        }

        return OrbitalViewSpeakerDrawInputs(speakers: speakers)
    }

    static func makeSpeakerStaticGeometryCacheKey(
        from state: OrbitalViewRenderState
    ) -> OrbitalViewSpeakerStaticGeometryCacheKey {
        let entries = state.scene?.speakers.map { speaker in
            OrbitalViewSpeakerStaticGeometryCacheKey.Entry(
                id: speaker.id,
                channel: speaker.channel,
                anchor: speaker.anchor,
                shape: speaker.shape,
                visualRole: speaker.visualRole
            )
        } ?? []

        return OrbitalViewSpeakerStaticGeometryCacheKey(entries: entries)
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
        case .cartesian(let position, _):
            let normal = normalizeNonZero(SIMD3<Float>(
                Float(position.x),
                Float(position.z),
                Float(position.y)
            ))
            return SIMD2<Float>(normal.x * projectionScale, normal.y * projectionScale)
        case .node, .edge, .face:
            return SIMD2<Float>(0, 0)
        }
    }

    private static func projectedPosition(for direction: UnitSphereDirection) -> SIMD2<Float> {
        SIMD2<Float>(Float(direction.x) * projectionScale, Float(direction.z) * projectionScale)
    }

    private static func speakerOrientation(for speaker: OrbitalViewSpeaker, depthScale: Float) -> SIMD4<Float> {
        let normal: SIMD3<Float>
        switch speaker.anchor {
        case .direction(let direction, _):
            normal = normalizeNonZero(SIMD3<Float>(
                Float(direction.x),
                Float(direction.z),
                Float(direction.y)
            ))
        case .cartesian(let position, _):
            normal = normalizeNonZero(SIMD3<Float>(
                Float(position.x),
                Float(position.z),
                Float(position.y)
            ))
        case .node, .edge, .face:
            normal = SIMD3<Float>(0, 0, 1)
        }
        return SIMD4<Float>(normal.x, normal.y, normal.z, depthScale)
    }

    private static func meshDepthScale(for shape: SpeakerShape) -> Float {
        if let zScale = shape.sonicSphereZScale {
            return Float(zScale)
        }

        switch shape {
        case .rectangularPrism(let widthM, _, let depthM, _) where widthM > 0:
            return Float(max(0.25, min(3, depthM / widthM)))
        case .sphere, .cube, .rectangularPrism:
            return 1
        }
    }

    private static func normalizeNonZero(_ value: SIMD3<Float>) -> SIMD3<Float> {
        let length = simd_length(value)
        guard length > 0.000_001, length.isFinite else {
            return SIMD3<Float>(0, 0, 1)
        }
        return value / length
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

        let value: Float
        if settings.style == .cubeScalarCenterBloom {
            value = SpeakerCubeVUScalars(rawRms: level.rms, settings: settings).paletteHeat
        } else {
            let gain = pow(10.0, Double(settings.visualGainDB) / 20.0)
            value = Float(min(max(Double(level.peak) * gain, 0), 1))
        }
        return styleColor(
            value: value,
            style: settings.style,
            settings: settings,
            speaker: speaker,
            meters: meters
        )
    }

    private static func speakerMaterial(
        for speaker: OrbitalViewSpeaker,
        meters: SpeakerMeterFrame?,
        settings: SpeakerMeterVisualSettings
    ) -> SIMD4<Float> {
        guard let level = meters?.levelsByChannel[speaker.channel] else {
            return SIMD4<Float>(0, 0, 0, 0)
        }

        let scalars = SpeakerCubeVUScalars(rawRms: level.rms, settings: settings)
        return SIMD4<Float>(
            scalars.displayVuScalar,
            scalars.hotScalar,
            scalars.paletteHeat,
            level.clip ? 1 : 0
        )
    }

    private static func makeBloomUniforms(settings: SpeakerMeterVisualSettings) -> SIMD4<Float> {
        SIMD4<Float>(
            settings.bloomMin,
            settings.bloomMax,
            settings.bloomEdge,
            settings.idleTint
        )
    }

    private static func makeHotUniforms(settings: SpeakerMeterVisualSettings) -> SIMD4<Float> {
        SIMD4<Float>(
            settings.hotFillStrength,
            settings.hotThreshold,
            settings.vuPaletteDrive,
            settings.checkerContrast
        )
    }

    private static func makeRampUniforms(settings: SpeakerMeterVisualSettings) -> [SIMD4<Float>] {
        let sortedRamp = settings.colorScheme.theme.vuRamp.sorted { $0.position < $1.position }
        let fallback = [
            OrbitalColorStop(position: 0, color: .rgb(0x202020)),
            OrbitalColorStop(position: 1, color: .rgb(0xFFFFFF))
        ]
        let ramp = sortedRamp.isEmpty ? fallback : sortedRamp

        var uniforms: [SIMD4<Float>] = []
        uniforms.reserveCapacity(rampUniformStopCount)
        for stop in ramp.prefix(rampUniformStopCount) {
            uniforms.append(SIMD4<Float>(
                Float(stop.color.red),
                Float(stop.color.green),
                Float(stop.color.blue),
                Float(stop.position)
            ))
        }

        let last = uniforms.last ?? SIMD4<Float>(1, 1, 1, 1)
        while uniforms.count < rampUniformStopCount {
            uniforms.append(last)
        }

        return uniforms
    }

    private static func styleColor(
        value: Float,
        style: SpeakerMeterVisualStyle,
        settings: SpeakerMeterVisualSettings,
        speaker: OrbitalViewSpeaker,
        meters: SpeakerMeterFrame?
    ) -> SIMD4<Float> {
        switch style {
        case .cubeScalarCenterBloom:
            return rampColor(
                value: value,
                settings: settings
            )
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

    private static func rampColor(value: Float, settings: SpeakerMeterVisualSettings) -> SIMD4<Float> {
        let ramp = settings.colorScheme.theme.vuRamp.sorted { $0.position < $1.position }
        guard let first = ramp.first else {
            return SIMD4<Float>(value, value, value, 1)
        }

        let position = max(0, min(1, Double(value)))
        let idle = Double(max(0, min(1, settings.idleTint)))

        var lower = first
        var upper = first
        for stop in ramp {
            if stop.position <= position {
                lower = stop
            }
            if stop.position >= position {
                upper = stop
                break
            }
        }

        let span = max(upper.position - lower.position, 0.000_001)
        let t = (position - lower.position) / span
        let red = lerp(lower.color.red, upper.color.red, t)
        let green = lerp(lower.color.green, upper.color.green, t)
        let blue = lerp(lower.color.blue, upper.color.blue, t)
        return SIMD4<Float>(
            Float(red * (idle + ((1 - idle) * position))),
            Float(green * (idle + ((1 - idle) * position))),
            Float(blue * (idle + ((1 - idle) * position))),
            1
        )
    }

    private static func lerp(_ start: Double, _ end: Double, _ t: Double) -> Double {
        start + ((end - start) * t)
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
        let contrast = min(max(settings.checkerContrast, 0), 0.4)
        let parity: Float = Int(qx + qy + objectIndex).isMultiple(of: 2) ? 1 + contrast : 1 - contrast
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
        case .daftPunkBow:
            return CheckerPalette(
                panel: rgb(0x14, 0x18, 0x1C),
                muted: rgb(0x5B, 0x8C, 0xFF),
                accent: rgb(0x22, 0xD3, 0xEE),
                accent2: rgb(0xEF, 0x44, 0x44)
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

    private struct SpeakerMaterialRevisionKey: Equatable {
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

struct SpeakerVertexOut {
    float4 position [[position]];
    float2 faceUV;
    float shade;
    float4 material;
};

struct ObjectVertexOut {
    float4 position [[position]];
    float4 color;
};

struct SpeakerMeshVertex {
    float3 localPosition;
    float3 localNormal;
    float2 uv;
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

static float2 orbital_face_uv(uint index) {
    switch (index) {
    case 0:
        return float2(0.0, 0.0);
    case 1:
        return float2(1.0, 0.0);
    case 2:
        return float2(0.0, 1.0);
    case 3:
        return float2(0.0, 1.0);
    case 4:
        return float2(1.0, 0.0);
    default:
        return float2(1.0, 1.0);
    }
}

static SpeakerMeshVertex speaker_cube_vertex(uint vertexID) {
    uint faceIndex = vertexID / 6;
    uint cornerIndex = vertexID % 6;
    float2 uv = orbital_face_uv(cornerIndex);
    float x = (uv.x * 2.0) - 1.0;
    float y = (uv.y * 2.0) - 1.0;

    SpeakerMeshVertex meshVertex;
    meshVertex.uv = uv;

    switch (faceIndex) {
    case 0:
        meshVertex.localPosition = float3(-x, y, -1.0);
        meshVertex.localNormal = float3(0.0, 0.0, -1.0);
        break;
    case 1:
        meshVertex.localPosition = float3(1.0, y, -x);
        meshVertex.localNormal = float3(1.0, 0.0, 0.0);
        break;
    case 2:
        meshVertex.localPosition = float3(x, 1.0, -y);
        meshVertex.localNormal = float3(0.0, 1.0, 0.0);
        break;
    case 3:
        meshVertex.localPosition = float3(-1.0, y, x);
        meshVertex.localNormal = float3(-1.0, 0.0, 0.0);
        break;
    case 4:
        meshVertex.localPosition = float3(x, -1.0, y);
        meshVertex.localNormal = float3(0.0, -1.0, 0.0);
        break;
    default:
        meshVertex.localPosition = float3(x, y, 1.0);
        meshVertex.localNormal = float3(0.0, 0.0, 1.0);
        break;
    }

    return meshVertex;
}

static float3 safe_normalize(float3 value, float3 fallback) {
    float lengthSquared = dot(value, value);
    if (lengthSquared <= 0.000001 || !isfinite(lengthSquared)) {
        return fallback;
    }
    return value * rsqrt(lengthSquared);
}

static float3 speaker_world_vector(float3 local, float3 normalOut, float depthScale) {
    float3 upReference = abs(normalOut.y) > 0.88 ? float3(1.0, 0.0, 0.0) : float3(0.0, 1.0, 0.0);
    float3 tangent = safe_normalize(cross(upReference, normalOut), float3(1.0, 0.0, 0.0));
    float3 bitangent = safe_normalize(cross(normalOut, tangent), float3(0.0, 1.0, 0.0));
    return (tangent * local.x) + (bitangent * local.y) + (normalOut * local.z * depthScale);
}

vertex SpeakerVertexOut orbital_speaker_vertex(
    uint vertexID [[vertex_id]],
    uint instanceID [[instance_id]],
    const device float4 *speakerPositions [[buffer(0)]],
    const device float4 *speakerOrientations [[buffer(1)]],
    const device float4 *speakerMaterials [[buffer(2)]]
) {
    SpeakerMeshVertex mesh = speaker_cube_vertex(vertexID);
    float4 speaker = speakerPositions[instanceID];
    float4 orientation = speakerOrientations[instanceID];
    float3 normalOut = safe_normalize(orientation.xyz, float3(0.0, 0.0, 1.0));
    float depthScale = clamp(orientation.w, 0.25, 3.0);
    float3 worldPosition = speaker_world_vector(mesh.localPosition, normalOut, depthScale);
    float3 worldNormal = safe_normalize(speaker_world_vector(mesh.localNormal, normalOut, 1.0), normalOut);
    float2 position = speaker.xy + (worldPosition.xy * speaker.z);
    float3 lightDirection = normalize(float3(0.32, 0.54, 0.78));

    SpeakerVertexOut out;
    out.position = float4(position, clamp(worldPosition.z * 0.025, -0.1, 0.1), 1.0);
    out.faceUV = mesh.uv;
    out.shade = 0.56 + (0.44 * saturate(dot(worldNormal, lightDirection)));
    out.material = speakerMaterials[instanceID];
    return out;
}

static float3 ramp_color(float value, const device float4 *rampStops) {
    float position = saturate(value);
    float4 lower = rampStops[0];
    float4 upper = rampStops[7];

    for (uint index = 0; index < 8; index++) {
        float4 stop = rampStops[index];
        if (stop.w <= position) {
            lower = stop;
        }
        if (stop.w >= position) {
            upper = stop;
            break;
        }
    }

    float span = max(upper.w - lower.w, 0.000001);
    float mixValue = saturate((position - lower.w) / span);
    return mix(lower.rgb, upper.rgb, mixValue);
}

fragment float4 orbital_speaker_fragment(
    SpeakerVertexOut in [[stage_in]],
    constant float4 &bloomUniforms [[buffer(0)]],
    const device float4 *rampStops [[buffer(1)]],
    constant float4 &hotUniforms [[buffer(2)]]
) {
    float displayVuScalar = saturate(in.material.x);
    float hotScalar = saturate(in.material.y);
    float paletteHeat = saturate(in.material.z);
    float clip = in.material.w;
    float bloomMin = saturate(bloomUniforms.x);
    float bloomMax = max(bloomMin + 0.001, saturate(bloomUniforms.y));
    float bloomEdge = max(bloomUniforms.z, 0.001);
    float idleTint = saturate(bloomUniforms.w);
    float hotFillStrength = saturate(hotUniforms.x);
    float hotThreshold = clamp(hotUniforms.y, 0.0, 1.0);
    float centerDistance = length(in.faceUV - float2(0.5, 0.5)) * 1.41421356;
    float bloomRadius = mix(bloomMin, bloomMax, displayVuScalar);
    float bloomEnd = max(bloomRadius + 0.001, min(1.41421356, bloomRadius + bloomEdge));
    float centerBloom = 1.0 - smoothstep(bloomRadius, bloomEnd, centerDistance);
    float3 idleColor = mix(float3(0.02, 0.025, 0.03), ramp_color(0.08, rampStops), idleTint);
    float3 vuColor = ramp_color(paletteHeat, rampStops);
    float bloomBody = saturate((displayVuScalar * 0.38) + (centerBloom * displayVuScalar * 0.92));
    float3 rgb = mix(idleColor, vuColor, bloomBody);
    rgb += vuColor * centerBloom * displayVuScalar * 0.35;
    float hotFill = hotFillStrength * smoothstep(hotThreshold, 1.0, hotScalar);
    rgb = mix(rgb, ramp_color(1.0, rampStops), hotFill);
    rgb *= in.shade;

    if (clip > 0.5) {
        rgb = mix(rgb, float3(1.0, 0.08, 0.02), 0.86);
        rgb += float3(0.38, 0.08, 0.02) * centerBloom;
    }

    return float4(saturate(rgb), 1.0);
}

vertex ObjectVertexOut orbital_object_vertex(
    uint vertexID [[vertex_id]],
    const device float4 *objectPositions [[buffer(0)]],
    const device float4 *objectColors [[buffer(1)]]
) {
    uint objectIndex = vertexID / 6;
    uint cornerIndex = vertexID % 6;
    float4 object = objectPositions[objectIndex];
    float2 position = object.xy + (orbital_corner(cornerIndex) * object.z);

    ObjectVertexOut out;
    out.position = float4(position, 0.0, 1.0);
    out.color = objectColors[objectIndex];
    return out;
}

fragment float4 orbital_object_fragment(ObjectVertexOut in [[stage_in]]) {
    return in.color;
}
"""
