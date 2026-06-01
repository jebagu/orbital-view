#if os(macOS)
import AppKit
import Darwin
import Foundation
import Metal
import QuartzCore
import SceneKit

public enum OrbitalViewportHeadlessBenchmarkMode: String, CaseIterable, Sendable {
    case idle
    case active
}

public struct OrbitalViewportHeadlessBenchmarkOptions: Sendable {
    public var mode: OrbitalViewportHeadlessBenchmarkMode
    public var warmupFrames: Int
    public var measuredFrames: Int
    public var width: Int
    public var height: Int
    public var targetFramesPerSecond: Int
    public var showRibbedSpeakerSphere: Bool
    public var ribbedSphereVerticalRibs: Int
    public var ribbedSphereHorizontalRings: Int
    public var showHiddenLines: Bool
    public var fogDensity: Double

    public init(
        mode: OrbitalViewportHeadlessBenchmarkMode,
        warmupFrames: Int = 60,
        measuredFrames: Int = 300,
        width: Int = 1360,
        height: Int = 820,
        targetFramesPerSecond: Int = 120,
        showRibbedSpeakerSphere: Bool = false,
        ribbedSphereVerticalRibs: Int = 16,
        ribbedSphereHorizontalRings: Int = 8,
        showHiddenLines: Bool = false,
        fogDensity: Double = 20
    ) {
        self.mode = mode
        self.warmupFrames = max(0, warmupFrames)
        self.measuredFrames = max(1, measuredFrames)
        self.width = max(1, width)
        self.height = max(1, height)
        self.targetFramesPerSecond = OrbitalViewportFrameRate.normalized(targetFramesPerSecond)
        self.showRibbedSpeakerSphere = showRibbedSpeakerSphere
        self.ribbedSphereVerticalRibs = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedVerticalRibs(ribbedSphereVerticalRibs)
        self.ribbedSphereHorizontalRings = OrbitalViewportRibbedSpeakerSphereGeometry.normalizedHorizontalRings(ribbedSphereHorizontalRings)
        self.showHiddenLines = showHiddenLines
        self.fogDensity = max(0, min(100, fogDensity))
    }
}

public struct OrbitalViewportHeadlessBenchmarkResult: Sendable {
    public let mode: OrbitalViewportHeadlessBenchmarkMode
    public let frames: Int
    public let elapsedSeconds: Double
    public let framesPerSecond: Double
    public let scheduledFramesPerSecond: Int
    public let activeTargetFramesPerSecond: Int
    public let width: Int
    public let height: Int
    public let ribbedSphereEnabled: Bool
    public let ribbedSphereSegmentCount: Int
    public let ribbedSphereSceneNodeCount: Int
    public let processCPUPercent: Double

    public var summaryLine: String {
        String(
            format: "%@ headless offscreen throughput: %.1f FPS over %d frames (scheduled %d FPS, active target %d FPS, %dx%d, ribbed=%@, segments=%d, nodes=%d, cpu=%.1f%%)",
            mode.rawValue,
            framesPerSecond,
            frames,
            scheduledFramesPerSecond,
            activeTargetFramesPerSecond,
            width,
            height,
            ribbedSphereEnabled ? "on" : "off",
            ribbedSphereSegmentCount,
            ribbedSphereSceneNodeCount,
            processCPUPercent
        )
    }
}

public enum OrbitalViewportHeadlessBenchmark {
    public static func run(
        options: OrbitalViewportHeadlessBenchmarkOptions
    ) throws -> OrbitalViewportHeadlessBenchmarkResult {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw BenchmarkError.metalDeviceUnavailable
        }
        guard let commandQueue = device.makeCommandQueue() else {
            throw BenchmarkError.commandQueueUnavailable
        }

        let colorTexture = try makeColorTexture(device: device, options: options)
        let depthTexture = try makeDepthTexture(device: device, options: options)
        let passDescriptor = makeRenderPassDescriptor(colorTexture: colorTexture, depthTexture: depthTexture)
        let viewport = CGRect(x: 0, y: 0, width: options.width, height: options.height)
        let renderer = SCNRenderer(device: device, options: nil)
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        renderer.scene = coordinator.scene
        renderer.pointOfView = coordinator.cameraNode
        renderer.autoenablesDefaultLighting = false

        let baseConfiguration = makeConfiguration(options: options, timeMS: 0)
        let scheduledFramesPerSecond = OrbitalViewportRenderScheduler.targetFramesPerSecond(
            activeFramesPerSecond: baseConfiguration.activeViewportFramesPerSecond,
            meterOnlyFramesPerSecond: baseConfiguration.meterOnlyViewportFramesPerSecond,
            isActiveMotion: baseConfiguration.spin
        )
        try renderFrames(
            count: options.warmupFrames,
            measured: false,
            scheduledFramesPerSecond: scheduledFramesPerSecond,
            baseConfiguration: baseConfiguration,
            coordinator: coordinator,
            renderer: renderer,
            commandQueue: commandQueue,
            passDescriptor: passDescriptor,
            viewport: viewport
        )

        coordinator.resetInstrumentationForTests()
        let startCPUSeconds = currentProcessCPUSeconds()
        let start = CACurrentMediaTime()
        try renderFrames(
            count: options.measuredFrames,
            measured: true,
            scheduledFramesPerSecond: scheduledFramesPerSecond,
            baseConfiguration: baseConfiguration,
            coordinator: coordinator,
            renderer: renderer,
            commandQueue: commandQueue,
            passDescriptor: passDescriptor,
            viewport: viewport
        )
        let elapsed = max(CACurrentMediaTime() - start, 0.000_001)
        let instrumentation = coordinator.instrumentationSnapshotForTests
        print(
            String(
                format: "  %@ diagnostics: renderScene=%d frameMaterialSkip=%d perSpeakerSkip=%d cubeMatUpdate=%d texHit=%d texMiss=%d texGen=%d texEvict=%d texAssign=%d",
                options.mode.rawValue,
                instrumentation.renderSceneCount,
                instrumentation.speakerMaterialUnchangedFrameSkipCount,
                instrumentation.speakerMaterialPerSpeakerSkipCount,
                instrumentation.cubeVUMaterialUpdateCount,
                instrumentation.cubeVUFaceTextureCacheHitCount,
                instrumentation.cubeVUFaceTextureCacheMissCount,
                instrumentation.cubeVUFaceTextureGenerationCount,
                instrumentation.cubeVUFaceTextureEvictionCount,
                instrumentation.cubeVUTextureAssignmentCount
            )
        )
        let cpuSeconds = max(0, currentProcessCPUSeconds() - startCPUSeconds)
        let cpuPercent = (cpuSeconds / elapsed) * 100
        let ribbedSphereEnabled = options.showRibbedSpeakerSphere

        return OrbitalViewportHeadlessBenchmarkResult(
            mode: options.mode,
            frames: options.measuredFrames,
            elapsedSeconds: elapsed,
            framesPerSecond: Double(options.measuredFrames) / elapsed,
            scheduledFramesPerSecond: scheduledFramesPerSecond,
            activeTargetFramesPerSecond: options.targetFramesPerSecond,
            width: options.width,
            height: options.height,
            ribbedSphereEnabled: ribbedSphereEnabled,
            ribbedSphereSegmentCount: ribbedSphereEnabled ? coordinator.ribbedSphereSegmentCountForTests : 0,
            ribbedSphereSceneNodeCount: ribbedSphereEnabled ? coordinator.ribbedSphereSceneNodeCountForTests : 0,
            processCPUPercent: cpuPercent
        )
    }

    static func makeConfiguration(
        options: OrbitalViewportHeadlessBenchmarkOptions,
        timeMS: Double
    ) -> OrbitalViewportRenderConfiguration {
        let sceneBounds = OrbitalViewportSceneBounds3D.enclosing(
            speakers: OrbitalViewportSpeaker.referenceSpeakers,
            sources: []
        )
        let activeMotion = options.mode == .active
        return OrbitalViewportRenderConfiguration(
            size: CGSize(width: options.width, height: options.height),
            timeMS: timeMS,
            yaw: 0,
            pitch: 0,
            cameraView: .isometric,
            zoom: 1,
            renderStyle: OrbitalViewportMockup.defaultRenderStyle,
            sourceSpeakerRenderStyle: OrbitalViewportMockup.defaultSourceSpeakerRenderStyle,
            geodesicRenderStyle: OrbitalViewportMockup.defaultGeodesicRenderStyle,
            geodesicSaturation: OrbitalViewportMockup.defaultGeodesicSaturation,
            showRibbedSpeakerSphere: options.showRibbedSpeakerSphere,
            ribbedSphereThickness: OrbitalViewportMockup.defaultRibbedSphereThickness,
            ribbedSphereVerticalRibs: options.ribbedSphereVerticalRibs,
            ribbedSphereHorizontalRings: options.ribbedSphereHorizontalRings,
            speakerShape: OrbitalViewportMockup.defaultSpeakerShape,
            jetLengthPixels: OrbitalViewportMockup.defaultJetLengthPixels,
            speakerSize: OrbitalViewportMath.speakerSize(fromSlider: 50),
            fogDensity: options.fogDensity,
            meterSource: .impulse(OrbitalViewportMockup.defaultVUDriveMode.impulseKind ?? .ripple),
            cubeVUSettings: OrbitalViewportMockup.defaultCubeVUSettings,
            activeViewportFramesPerSecond: options.targetFramesPerSecond,
            meterOnlyViewportFramesPerSecond: OrbitalViewportMockup.meterOnlyViewportFramesPerSecond,
            inspectorRefreshFramesPerSecond: OrbitalViewportMockup.inspectorRefreshFramesPerSecond,
            speakerLabelFont: .systemDefault,
            speakerLabelSizeScale: 1,
            showSpeakerNumbers: false,
            showHiddenLines: options.showHiddenLines,
            showGridPlane: false,
            selectedChannel: nil,
            speakers: OrbitalViewportSpeaker.referenceSpeakers,
            sources: [],
            sceneCenter: sceneBounds.center,
            sceneHalfExtent: sceneBounds.halfExtent,
            spin: activeMotion,
            spinStartYaw: 0,
            spinStartTimeMS: 0
        )
    }

    private static func currentProcessCPUSeconds() -> Double {
        var usage = rusage()
        getrusage(RUSAGE_SELF, &usage)
        return seconds(usage.ru_utime) + seconds(usage.ru_stime)
    }

    private static func seconds(_ value: timeval) -> Double {
        Double(value.tv_sec) + (Double(value.tv_usec) / 1_000_000)
    }

    private static func renderFrames(
        count: Int,
        measured: Bool,
        scheduledFramesPerSecond: Int,
        baseConfiguration: OrbitalViewportRenderConfiguration,
        coordinator: OrbitalViewport3DSceneView.Coordinator,
        renderer: SCNRenderer,
        commandQueue: MTLCommandQueue,
        passDescriptor: MTLRenderPassDescriptor,
        viewport: CGRect
    ) throws {
        guard count > 0 else {
            return
        }

        for frame in 0..<count {
            try autoreleasepool {
                let timeMS = Double(frame) * (1_000 / Double(scheduledFramesPerSecond))
                let configuration = baseConfiguration.frameConfiguration(timeMS: timeMS)
                coordinator.renderHeadlessFrameForBenchmark(configuration: configuration)
                guard let commandBuffer = commandQueue.makeCommandBuffer() else {
                    throw BenchmarkError.commandBufferUnavailable
                }
                renderer.render(
                    atTime: timeMS / 1_000,
                    viewport: viewport,
                    commandBuffer: commandBuffer,
                    passDescriptor: passDescriptor
                )
                commandBuffer.commit()
                if measured {
                    commandBuffer.waitUntilCompleted()
                } else {
                    commandBuffer.waitUntilCompleted()
                }
            }
        }
    }

    private static func makeColorTexture(
        device: MTLDevice,
        options: OrbitalViewportHeadlessBenchmarkOptions
    ) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: options.width,
            height: options.height,
            mipmapped: false
        )
        descriptor.usage = [.renderTarget, .shaderRead]
        descriptor.storageMode = .private
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            throw BenchmarkError.textureUnavailable("color")
        }
        return texture
    }

    private static func makeDepthTexture(
        device: MTLDevice,
        options: OrbitalViewportHeadlessBenchmarkOptions
    ) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .depth32Float,
            width: options.width,
            height: options.height,
            mipmapped: false
        )
        descriptor.usage = [.renderTarget]
        descriptor.storageMode = .private
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            throw BenchmarkError.textureUnavailable("depth")
        }
        return texture
    }

    private static func makeRenderPassDescriptor(
        colorTexture: MTLTexture,
        depthTexture: MTLTexture
    ) -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = colorTexture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        descriptor.depthAttachment.texture = depthTexture
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.storeAction = .dontCare
        descriptor.depthAttachment.clearDepth = 1
        return descriptor
    }

    enum BenchmarkError: LocalizedError {
        case metalDeviceUnavailable
        case commandQueueUnavailable
        case commandBufferUnavailable
        case textureUnavailable(String)

        var errorDescription: String? {
            switch self {
            case .metalDeviceUnavailable:
                return "Metal device unavailable for headless SceneKit benchmark."
            case .commandQueueUnavailable:
                return "Metal command queue unavailable for headless SceneKit benchmark."
            case .commandBufferUnavailable:
                return "Metal command buffer unavailable for headless SceneKit benchmark."
            case let .textureUnavailable(kind):
                return "Metal \(kind) texture unavailable for headless SceneKit benchmark."
            }
        }
    }
}
#endif
