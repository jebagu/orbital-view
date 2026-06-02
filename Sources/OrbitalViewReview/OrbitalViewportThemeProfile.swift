#if os(macOS)
import AppKit
import Darwin
import Foundation
import Metal
import QuartzCore
import SceneKit

/// Profiles the SceneKit review render path for a *real saved theme* (e.g. "Quantum Grid",
/// "Prism Comet") under spin + impulse meters, the way an operator drives it.
///
/// This is a measurement-only harness. It decodes a saved-theme JSON via the same
/// `OrbitalViewportSettingsExportPayload` the app's "load saved theme" uses, rebuilds a faithful
/// `OrbitalViewportRenderConfiguration` (reusing the same slider→value transforms), then drives
/// `coordinator.renderHeadlessFrameForBenchmark` frame by frame. It reports whole-frame throughput
/// plus the per-aspect render instrumentation deltas so we can see *which* sub-systems do work
/// each frame (ribbed sphere, speaker materials, cell/cube materials, texture generation, fog).
public struct OrbitalViewportThemeProfileOptions: Sendable {
    public var themePath: String
    public var warmupFrames: Int
    public var measuredFrames: Int
    public var width: Int
    public var height: Int
    public var forceSpin: Bool
    public var forceImpulse: Bool

    public init(
        themePath: String,
        warmupFrames: Int = 60,
        measuredFrames: Int = 300,
        width: Int = 1360,
        height: Int = 820,
        forceSpin: Bool = true,
        forceImpulse: Bool = true
    ) {
        self.themePath = themePath
        self.warmupFrames = max(0, warmupFrames)
        self.measuredFrames = max(1, measuredFrames)
        self.width = max(1, width)
        self.height = max(1, height)
        self.forceSpin = forceSpin
        self.forceImpulse = forceImpulse
    }
}

public struct OrbitalViewportThemeProfileResult: Sendable {
    public let themeName: String
    public let speakerShape: String
    public let ribbedSphereEnabled: Bool
    public let ribbedSphereVerticalRibs: Int
    public let ribbedSphereHorizontalRings: Int
    public let fogDensity: Double
    public let spin: Bool
    public let frames: Int
    public let framesPerSecond: Double
    public let cpuPercent: Double
    public let scheduledFramesPerSecond: Int
    public let sceneMutationMSPerFrame: Double
    public let gpuRenderMSPerFrame: Double
    public let summaryLines: [String]

    init(
        themeName: String,
        speakerShape: String,
        ribbedSphereEnabled: Bool,
        ribbedSphereVerticalRibs: Int,
        ribbedSphereHorizontalRings: Int,
        fogDensity: Double,
        spin: Bool,
        frames: Int,
        framesPerSecond: Double,
        cpuPercent: Double,
        scheduledFramesPerSecond: Int,
        sceneMutationMSPerFrame: Double,
        gpuRenderMSPerFrame: Double,
        instrumentation: OrbitalViewportRenderInstrumentationSnapshot
    ) {
        self.themeName = themeName
        self.speakerShape = speakerShape
        self.ribbedSphereEnabled = ribbedSphereEnabled
        self.ribbedSphereVerticalRibs = ribbedSphereVerticalRibs
        self.ribbedSphereHorizontalRings = ribbedSphereHorizontalRings
        self.fogDensity = fogDensity
        self.spin = spin
        self.frames = frames
        self.framesPerSecond = framesPerSecond
        self.cpuPercent = cpuPercent
        self.scheduledFramesPerSecond = scheduledFramesPerSecond
        self.sceneMutationMSPerFrame = sceneMutationMSPerFrame
        self.gpuRenderMSPerFrame = gpuRenderMSPerFrame
        let perFrame = { (value: Int) -> String in
            String(format: "%.1f", Double(value) / Double(max(1, frames)))
        }
        self.summaryLines = [
            String(
                format: "theme=\"%@\" shape=%@ ribbed=%@ (vRibs=%d hRings=%d) fog=%.1f spin=%@",
                themeName, speakerShape, ribbedSphereEnabled ? "on" : "off",
                ribbedSphereVerticalRibs, ribbedSphereHorizontalRings, fogDensity, spin ? "on" : "off"
            ),
            String(
                format: "  throughput: %.1f FPS over %d frames, cpu=%.1f%% (scheduled %d FPS)",
                framesPerSecond, frames, cpuPercent, scheduledFramesPerSecond
            ),
            String(
                format: "  time split: sceneMutation(CPU)=%.3f ms/frame  gpuRender+wait=%.3f ms/frame",
                sceneMutationMSPerFrame, gpuRenderMSPerFrame
            ),
            "  per-frame work (count/frame):",
            "    renderScene=\(perFrame(instrumentation.renderSceneCount)) " +
                "noOp=\(perFrame(instrumentation.renderSceneNoOpCount)) " +
                "needsDisplay=\(perFrame(instrumentation.needsDisplayCount))",
            "    ribbedSphere: materialUpdate=\(perFrame(instrumentation.ribbedSphereMaterialUpdateCount)) " +
                "segmentVisit=\(perFrame(instrumentation.ribbedSphereSegmentVisitCount)) " +
                "materialWrite=\(perFrame(instrumentation.ribbedSphereMaterialWriteCount)) " +
                "hiddenWrite=\(perFrame(instrumentation.ribbedSphereHiddenStateWriteCount))",
            "    speakers: materialUpdate=\(perFrame(instrumentation.speakerMaterialUpdateCount)) " +
                "visit=\(perFrame(instrumentation.speakerMaterialSpeakerVisitCount)) " +
                "perSpeakerSkip=\(perFrame(instrumentation.speakerMaterialPerSpeakerSkipCount)) " +
                "frameSkip=\(perFrame(instrumentation.speakerMaterialUnchangedFrameSkipCount))",
            "    cubeVU: matUpdate=\(perFrame(instrumentation.cubeVUMaterialUpdateCount)) " +
                "texGen=\(perFrame(instrumentation.cubeVUFaceTextureGenerationCount)) " +
                "texHit=\(perFrame(instrumentation.cubeVUFaceTextureCacheHitCount)) " +
                "texMiss=\(perFrame(instrumentation.cubeVUFaceTextureCacheMissCount)) " +
                "texAssign=\(perFrame(instrumentation.cubeVUTextureAssignmentCount)) " +
                "uniformWrite=\(perFrame(instrumentation.cubeVUUniformWriteCount))",
            "    outline=\(perFrame(instrumentation.cubeOutlineMaterialUpdateCount)) " +
                "sceneMaterialWrite=\(perFrame(instrumentation.sceneMaterialWriteCount)) " +
                "sceneMaterialSkip=\(perFrame(instrumentation.sceneMaterialSkipCount)) " +
                "fog=\(perFrame(instrumentation.fogUpdateCount)) " +
                "camera=\(perFrame(instrumentation.cameraUpdateCount))",
        ]
    }
}

public enum OrbitalViewportThemeProfile {
    public enum ProfileError: LocalizedError {
        case themeUnreadable(String)
        case themeUndecodable(String)
        case metalUnavailable

        public var errorDescription: String? {
            switch self {
            case let .themeUnreadable(path): return "Could not read theme file at \(path)."
            case let .themeUndecodable(detail): return "Could not decode theme payload: \(detail)."
            case .metalUnavailable: return "Metal device/command queue unavailable for theme profile."
            }
        }
    }

    static func loadPayload(path: String) throws -> OrbitalViewportSettingsExportPayload {
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else {
            throw ProfileError.themeUnreadable(path)
        }
        do {
            return try JSONDecoder().decode(OrbitalViewportSettingsExportPayload.self, from: data)
        } catch {
            throw ProfileError.themeUndecodable(String(describing: error))
        }
    }

    /// Rebuilds a render configuration from a saved-theme payload, faithfully reproducing the
    /// model's slider→value transforms and palette resolution used when loading a theme.
    static func configuration(
        payload: OrbitalViewportSettingsExportPayload,
        options: OrbitalViewportThemeProfileOptions,
        timeMS: Double
    ) -> OrbitalViewportRenderConfiguration {
        let speakers = OrbitalViewportSpeaker.referenceSpeakers
        let sceneBounds = OrbitalViewportSceneBounds3D.enclosing(speakers: speakers, sources: [])
        let orbit = payload.leftPanel.camera.resolvedOrbitState

        let speakerSize = OrbitalViewportMath.speakerSize(
            fromSlider: payload.leftPanel.viewDetail.speakerSizeSlider
        )
        let fogDensity = OrbitalViewportMath.fogDensity(
            fromSlider: payload.leftPanel.viewDetail.fogDensitySlider
        )
        let speakerLabelSizeScale = OrbitalViewportMath.speakerLabelSizeScale(
            fromSlider: payload.speakerLabelFontSizeSlider
        )
        let gridPlaneVisibility = OrbitalViewportGridPlaneGeometry.visibility(
            fromSlider: payload.groundAppearance.gridPlaneVisibilitySlider
        )

        // The geodesic / grid palettes follow the main palette when their follow flag is set,
        // matching `applyViewTheme`.
        let geodesicRenderStyle = payload.geodesicPaletteFollowsMainTheme
            ? payload.renderStyle
            : payload.geodesicRenderStyle
        let gridPlaneRenderStyle = payload.groundAppearance.gridPlanePaletteFollowsMainTheme
            ? payload.renderStyle
            : payload.groundAppearance.gridPlaneRenderStyle

        let spin = options.forceSpin || payload.leftPanel.camera.spin
        var cubeSettings = payload.cubeSettings
        cubeSettings.speakerHeight = 1

        // Impulse meters are the easiest way to get representative activity on the meters, matching
        // the operator selecting "Demo Patterns". `forceImpulse` is the profiling default; we always
        // resolve to the theme's impulse kind here.
        _ = options.forceImpulse
        let meterSource: OrbitalViewportMeterSource = .impulse(payload.driveMode.impulseKind ?? .ripple)

        return OrbitalViewportRenderConfiguration(
            size: CGSize(width: options.width, height: options.height),
            timeMS: timeMS,
            yaw: orbit.yaw,
            pitch: orbit.pitch,
            cameraView: orbit.view,
            zoom: min(1.75, max(0.62, payload.leftPanel.camera.zoom)),
            renderStyle: payload.renderStyle,
            sourceSpeakerRenderStyle: payload.sourceSpeakerRenderStyle,
            geodesicRenderStyle: geodesicRenderStyle,
            geodesicSaturation: payload.geodesicSaturation,
            showRibbedSpeakerSphere: payload.showRibbedSpeakerSphere,
            ribbedSphereThickness: payload.ribbedSphereThickness,
            ribbedSphereVerticalRibs: payload.ribbedSphereVerticalRibs,
            ribbedSphereHorizontalRings: payload.ribbedSphereHorizontalRings,
            speakerShape: payload.speakerShape,
            jetLengthPixels: payload.jetLengthPixels,
            speakerSize: speakerSize,
            fogDensity: fogDensity,
            meterSource: meterSource,
            cubeVUSettings: cubeSettings,
            activeViewportFramesPerSecond: payload.activeViewportFramesPerSecond,
            meterOnlyViewportFramesPerSecond: payload.meterOnlyViewportFramesPerSecond,
            inspectorRefreshFramesPerSecond: payload.inspectorRefreshFramesPerSecond,
            speakerLabelFont: payload.speakerLabelFont,
            speakerLabelSizeScale: speakerLabelSizeScale,
            showSpeakerNumbers: payload.leftPanel.viewDetail.showSpeakerNumbers,
            showHiddenLines: payload.leftPanel.viewDetail.showHiddenLines,
            showGridPlane: payload.groundAppearance.showGridPlane,
            gridPlaneVisibility: gridPlaneVisibility,
            gridPlaneSpacing: payload.groundAppearance.gridPlaneSpacing,
            gridPlaneRenderStyle: gridPlaneRenderStyle,
            gridPlaneThickness: payload.groundAppearance.gridPlaneThickness,
            selectedChannel: nil,
            speakers: speakers,
            sources: [],
            sceneCenter: sceneBounds.center,
            sceneHalfExtent: sceneBounds.halfExtent,
            spin: spin,
            spinStartYaw: orbit.yaw,
            spinStartTimeMS: 0
        )
    }

    public static func run(options: OrbitalViewportThemeProfileOptions) throws -> OrbitalViewportThemeProfileResult {
        let payload = try loadPayload(path: options.themePath)
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            throw ProfileError.metalUnavailable
        }

        let colorTexture = try makeTexture(device: device, options: options, pixelFormat: .bgra8Unorm, usage: [.renderTarget, .shaderRead])
        let depthTexture = try makeTexture(device: device, options: options, pixelFormat: .depth32Float, usage: [.renderTarget])
        let passDescriptor = makePassDescriptor(colorTexture: colorTexture, depthTexture: depthTexture)
        let viewport = CGRect(x: 0, y: 0, width: options.width, height: options.height)

        let renderer = SCNRenderer(device: device, options: nil)
        let coordinator = OrbitalViewport3DSceneView.Coordinator()
        renderer.scene = coordinator.scene
        renderer.pointOfView = coordinator.cameraNode
        renderer.autoenablesDefaultLighting = false

        let base = configuration(payload: payload, options: options, timeMS: 0)
        // Spin themes drive the meter cadence; use the meter-only fps as the frame step so impulse
        // meters animate at the cadence the app schedules.
        let scheduledFPS = OrbitalViewportRenderScheduler.targetFramesPerSecond(
            activeFramesPerSecond: base.activeViewportFramesPerSecond,
            meterOnlyFramesPerSecond: base.meterOnlyViewportFramesPerSecond,
            isActiveMotion: base.spin
        )
        let frameStepMS = 1_000 / Double(max(1, scheduledFPS))

        // Returns (sceneMutationSeconds, gpuRenderSeconds) accumulated over the rendered frames so
        // we can attribute cost to the CPU scene-update path vs the GPU render+wait. The split is
        // the key signal for whether a slow theme is a non-graphics (CPU) problem we can address
        // here, or a GPU-bound one.
        @discardableResult
        func renderFrames(_ count: Int, measure: Bool) -> (cpu: Double, gpu: Double) {
            guard count > 0 else { return (0, 0) }
            var cpuSeconds = 0.0
            var gpuSeconds = 0.0
            for frame in 0..<count {
                autoreleasepool {
                    let timeMS = Double(frame) * frameStepMS
                    let frameConfig = base.frameConfiguration(timeMS: timeMS)
                    let mutateStart = measure ? CACurrentMediaTime() : 0
                    coordinator.renderHeadlessFrameForBenchmark(configuration: frameConfig)
                    if measure { cpuSeconds += CACurrentMediaTime() - mutateStart }
                    guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
                    let gpuStart = measure ? CACurrentMediaTime() : 0
                    renderer.render(atTime: timeMS / 1_000, viewport: viewport, commandBuffer: commandBuffer, passDescriptor: passDescriptor)
                    commandBuffer.commit()
                    commandBuffer.waitUntilCompleted()
                    if measure { gpuSeconds += CACurrentMediaTime() - gpuStart }
                }
            }
            return (cpuSeconds, gpuSeconds)
        }

        renderFrames(options.warmupFrames, measure: false)

        coordinator.resetInstrumentationForTests()
        let startCPU = currentProcessCPUSeconds()
        let start = CACurrentMediaTime()
        let split = renderFrames(options.measuredFrames, measure: true)
        let elapsed = max(CACurrentMediaTime() - start, 0.000_001)
        let cpuSeconds = max(0, currentProcessCPUSeconds() - startCPU)
        let instrumentation = coordinator.instrumentationSnapshotForTests

        let themeName = URL(fileURLWithPath: options.themePath).deletingPathExtension().lastPathComponent
        return OrbitalViewportThemeProfileResult(
            themeName: themeName,
            speakerShape: payload.speakerShape.rawValue,
            ribbedSphereEnabled: payload.showRibbedSpeakerSphere,
            ribbedSphereVerticalRibs: payload.ribbedSphereVerticalRibs,
            ribbedSphereHorizontalRings: payload.ribbedSphereHorizontalRings,
            fogDensity: OrbitalViewportMath.fogDensity(fromSlider: payload.leftPanel.viewDetail.fogDensitySlider),
            spin: base.spin,
            frames: options.measuredFrames,
            framesPerSecond: Double(options.measuredFrames) / elapsed,
            cpuPercent: (cpuSeconds / elapsed) * 100,
            scheduledFramesPerSecond: scheduledFPS,
            sceneMutationMSPerFrame: (split.cpu / Double(options.measuredFrames)) * 1_000,
            gpuRenderMSPerFrame: (split.gpu / Double(options.measuredFrames)) * 1_000,
            instrumentation: instrumentation
        )
    }

    private static func currentProcessCPUSeconds() -> Double {
        var usage = rusage()
        getrusage(RUSAGE_SELF, &usage)
        func seconds(_ value: timeval) -> Double { Double(value.tv_sec) + (Double(value.tv_usec) / 1_000_000) }
        return seconds(usage.ru_utime) + seconds(usage.ru_stime)
    }

    private static func makeTexture(
        device: MTLDevice,
        options: OrbitalViewportThemeProfileOptions,
        pixelFormat: MTLPixelFormat,
        usage: MTLTextureUsage
    ) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: pixelFormat, width: options.width, height: options.height, mipmapped: false
        )
        descriptor.usage = usage
        descriptor.storageMode = .private
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            throw ProfileError.metalUnavailable
        }
        return texture
    }

    private static func makePassDescriptor(colorTexture: MTLTexture, depthTexture: MTLTexture) -> MTLRenderPassDescriptor {
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
}
#endif
