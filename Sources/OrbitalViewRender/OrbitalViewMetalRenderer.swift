import CoreGraphics
import Metal
import MetalKit
import OrbitalViewCore

public final class OrbitalViewMetalRenderer: NSObject, OrbitalViewRendering {
    public private(set) var renderState: OrbitalViewRenderState

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
}

extension OrbitalViewMetalRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    public func draw(in view: MTKView) {}
}
