import CoreGraphics
import Metal
import MetalKit
import OrbitalViewCore

public final class OrbitalViewMetalRenderer: NSObject, OrbitalViewRendering {
    public private(set) var renderState: OrbitalViewRenderState
    private(set) var lastDrawErrorDescription: String?

    private var drawPipeline: OrbitalViewMetalDrawPipeline?
    private var pendingEvents: [OrbitalViewEvent]

    public override init() {
        self.renderState = .empty
        self.pendingEvents = []
        super.init()
    }

    public func attach(to view: MTKView) {
        if view.device == nil {
            view.device = MTLCreateSystemDefaultDevice()
        }
        view.delegate = self
    }

    public func loadScene(_ scene: OrbitalViewSceneSpec) {
        renderState = renderState.loading(scene: scene)
    }

    public func updateMeters(_ frame: SpeakerMeterFrame) {
        renderState = renderState.updating(meters: frame)
    }

    public func updateCamera(_ camera: OrbitalViewCameraState) {
        renderState = renderState.updating(camera: camera)
        pendingEvents.append(.cameraChanged(camera))
    }

    public func select(_ selection: OrbitalViewSelection?) {
        renderState = renderState.selecting(selection)
        pendingEvents.append(.selected(selection))
    }

    public func drainEvents() -> [OrbitalViewEvent] {
        let events = pendingEvents
        pendingEvents.removeAll(keepingCapacity: true)
        return events
    }

    func renderOffscreen(device: MTLDevice, width: Int = 64, height: Int = 64) throws -> OrbitalViewOffscreenFrame {
        let pipeline = try pipeline(for: device)
        return try pipeline.renderOffscreen(state: renderState, width: width, height: height)
    }

    private func pipeline(for device: MTLDevice) throws -> OrbitalViewMetalDrawPipeline {
        if let drawPipeline, drawPipeline.uses(device: device) {
            return drawPipeline
        }

        let pipeline = try OrbitalViewMetalDrawPipeline(device: device)
        drawPipeline = pipeline
        return pipeline
    }
}

extension OrbitalViewMetalRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    public func draw(in view: MTKView) {
        guard
            let device = view.device,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable
        else {
            return
        }

        do {
            let pipeline = try pipeline(for: device)
            try pipeline.render(
                state: renderState,
                renderPassDescriptor: renderPassDescriptor,
                drawable: drawable
            )
            lastDrawErrorDescription = nil
        } catch {
            lastDrawErrorDescription = String(describing: error)
        }
    }
}
