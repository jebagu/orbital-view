import AppKit
import MetalKit
import OrbitalViewCore
import OrbitalViewRender
import SwiftUI

struct OrbitalViewRenderConfiguration: Equatable {
    let scene: OrbitalViewSceneSpec
    let meters: SpeakerMeterFrame?
    let meterVisualSettings: SpeakerMeterVisualSettings
    let displaySettings: OrbitalViewDisplaySettings
    let camera: OrbitalViewCameraState
    let selection: OrbitalViewSelection?
}

struct OrbitalViewMetalView: NSViewRepresentable {
    let configuration: OrbitalViewRenderConfiguration
    let onEvents: ([OrbitalViewEvent]) -> Void
    let onUpdateCamera: (OrbitalViewCameraState) -> Void
    let onDragStateChange: (Bool) -> Void
    let onViewMounted: (OrbitalViewInteractiveMTKView) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(renderer: OrbitalViewMetalRenderer(), onEvents: onEvents)
    }

    func makeNSView(context: Context) -> OrbitalViewInteractiveMTKView {
        let view = OrbitalViewInteractiveMTKView()
        view.captureDelegate = context.coordinator
        view.onUpdateCamera = { newCamera in
            onUpdateCamera(newCamera)
        }
        view.onDragStateChanged = { isDragging in
            onDragStateChange(isDragging)
        }
        view.onWheelZoom = { delta in
            guard let updated = view.applyZoomDelta(delta) else {
                return
            }
            onUpdateCamera(updated)
        }
        context.coordinator.renderer.attach(to: view)
        onViewMounted(view)
        emit(context.coordinator.apply(configuration))
        return view
    }

    func updateNSView(_ nsView: OrbitalViewInteractiveMTKView, context: Context) {
        nsView.synchronizeCamera(configuration.camera)
        emit(context.coordinator.apply(configuration))
    }

    private func emit(_ events: [OrbitalViewEvent]) {
        guard !events.isEmpty else { return }
        onEvents(events)
    }

    final class Coordinator: NSObject {
        let renderer: OrbitalViewMetalRenderer
        let onEvents: ([OrbitalViewEvent]) -> Void

        private var appliedConfiguration: OrbitalViewRenderConfiguration?

        init(renderer: OrbitalViewMetalRenderer, onEvents: @escaping ([OrbitalViewEvent]) -> Void) {
            self.renderer = renderer
            self.onEvents = onEvents
        }

        func apply(_ configuration: OrbitalViewRenderConfiguration) -> [OrbitalViewEvent] {
            if appliedConfiguration?.scene != configuration.scene {
                renderer.loadScene(configuration.scene)
            }

            if appliedConfiguration?.meters != configuration.meters, let meters = configuration.meters {
                renderer.updateMeters(meters)
            }

            if renderer.renderState.meterVisualSettings != configuration.meterVisualSettings {
                renderer.updateMeterVisualSettings(configuration.meterVisualSettings)
            }

            if renderer.renderState.displaySettings != configuration.displaySettings {
                renderer.updateDisplaySettings(configuration.displaySettings)
            }

            if appliedConfiguration?.camera != configuration.camera {
                renderer.updateCamera(configuration.camera)
            }

        if appliedConfiguration?.selection != configuration.selection {
            renderer.select(configuration.selection)
        }

        appliedConfiguration = configuration
        let events = renderer.drainEvents()
        onEvents(events)
        return events
    }
}
}

final class OrbitalViewInteractiveMTKView: MTKView {
    struct DragState {
        var isDragging = false
        var startPoint = CGPoint.zero
        var startYaw = 0.0
        var startPitch = 0.0
        var startDistance = 4.0
    }

    var captureDelegate: OrbitalViewMetalView.Coordinator?

    var onUpdateCamera: (OrbitalViewCameraState) -> Void = { _ in }
    var onDragStateChanged: (Bool) -> Void = { _ in }
    var onWheelZoom: (Double) -> Void = { _ in }

    private var dragState = DragState()
    private(set) var camera: OrbitalViewCameraState = {
        try! OrbitalViewCameraState.preset(.isometric)
    }() {
        didSet {
            captureDelegate?.renderer.updateCamera(camera)
        }
    }

    private let pitchRange = (-Double.pi / 2 + 0.05)...(Double.pi / 2 - 0.05)
    private let zoomRange = 1.5...35.0
    private let yawSensitivity = 0.006
    private let pitchSensitivity = 0.005
    private let zoomSensitivity = 0.18

    func synchronizeCamera(_ camera: OrbitalViewCameraState) {
        self.camera = camera
    }

    func applyZoomDelta(_ deltaY: CGFloat) -> OrbitalViewCameraState? {
        let adjusted = min(max(camera.orbit.distanceM + (Double(deltaY) * zoomSensitivity), zoomRange.lowerBound), zoomRange.upperBound)
        guard abs(adjusted - camera.orbit.distanceM) > .ulpOfOne else {
            return nil
        }

        let next = try? OrbitalViewOrbit(yawRadians: camera.orbit.yawRadians, pitchRadians: camera.orbit.pitchRadians, distanceM: adjusted)
        guard let nextOrbit = next else { return nil }
        return try? OrbitalViewCameraState(
            mode: camera.mode,
            projection: camera.projection,
            orbit: nextOrbit,
            target: camera.target,
            enforceCenterLock: true
        )
    }

    override func scrollWheel(with event: NSEvent) {
        onWheelZoom(event.scrollingDeltaY)
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        dragState.isDragging = true
        dragState.startPoint = convert(event.locationInWindow, from: nil)
        dragState.startYaw = camera.orbit.yawRadians
        dragState.startPitch = camera.orbit.pitchRadians
        dragState.startDistance = camera.orbit.distanceM
        onDragStateChanged(true)
    }

    override func mouseDragged(with event: NSEvent) {
        guard dragState.isDragging else { return }
        let current = convert(event.locationInWindow, from: nil)
        let dx = current.x - dragState.startPoint.x
        let dy = current.y - dragState.startPoint.y

        let nextYaw = dragState.startYaw + Double(dx) * yawSensitivity
        let nextPitch = dragState.startPitch - Double(dy) * pitchSensitivity
        let clampedPitch = min(max(nextPitch, pitchRange.lowerBound), pitchRange.upperBound)

        if let nextOrbit = try? OrbitalViewOrbit(
            yawRadians: nextYaw,
            pitchRadians: clampedPitch,
            distanceM: dragState.startDistance
        ),
           let nextCamera = try? OrbitalViewCameraState(
            mode: camera.mode,
            projection: camera.projection,
            orbit: nextOrbit,
            target: camera.target,
            enforceCenterLock: true
           ) {
            camera = nextCamera
            setNeedsDisplay(bounds)
            onUpdateCamera(nextCamera)
        }
    }

    override func mouseUp(with event: NSEvent) {
        dragState.isDragging = false
        onDragStateChanged(false)
        super.mouseUp(with: event)
    }

    override func rightMouseDown(with event: NSEvent) {
        dragState.isDragging = false
        onDragStateChanged(false)
        super.rightMouseDown(with: event)
    }

    func snapshotPNG() -> Data? {
        let rect = bounds
        guard rect.width > 0, rect.height > 0 else {
            return nil
        }
        guard let rep = bitmapImageRepForCachingDisplay(in: rect) else {
            return nil
        }
        cacheDisplay(in: rect, to: rep)
        return rep.representation(using: .png, properties: [:])
    }
}
