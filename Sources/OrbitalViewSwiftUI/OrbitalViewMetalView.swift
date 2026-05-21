import MetalKit
import OrbitalViewCore
import OrbitalViewRender
import SwiftUI

struct OrbitalViewRenderConfiguration: Equatable {
    let scene: OrbitalViewSceneSpec
    let meters: SpeakerMeterFrame?
    let meterVisualSettings: SpeakerMeterVisualSettings
    let objectFrames: OrbitalViewObjectFrameSet?
    let objectMeters: ObjectMeterFrame?
    let objectVisualSettings: ObjectVisualSettings
    let performanceSettings: OrbitalViewPerformanceSettings
    let camera: OrbitalViewCameraState
    let selection: OrbitalViewSelection?
}

struct OrbitalViewMetalView: NSViewRepresentable {
    let configuration: OrbitalViewRenderConfiguration
    let onEvents: ([OrbitalViewEvent]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(renderer: OrbitalViewMetalRenderer())
    }

    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        Self.configure(view, with: configuration.performanceSettings)
        context.coordinator.renderer.attach(to: view)
        emit(context.coordinator.apply(configuration))
        view.setNeedsDisplay(view.bounds)
        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {
        Self.configure(nsView, with: configuration.performanceSettings)
        emit(context.coordinator.apply(configuration))
        nsView.setNeedsDisplay(nsView.bounds)
    }

    private func emit(_ events: [OrbitalViewEvent]) {
        guard !events.isEmpty else { return }
        onEvents(events)
    }

    static func configure(_ view: MTKView, with settings: OrbitalViewPerformanceSettings) {
        view.preferredFramesPerSecond = settings.activeViewportFramesPerSecond
        view.enableSetNeedsDisplay = settings.drawsOnDemand
        view.isPaused = settings.drawsOnDemand
    }

    final class Coordinator {
        let renderer: OrbitalViewMetalRenderer

        private var appliedConfiguration: OrbitalViewRenderConfiguration?

        init(renderer: OrbitalViewMetalRenderer) {
            self.renderer = renderer
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

            if appliedConfiguration?.objectFrames != configuration.objectFrames, let objectFrames = configuration.objectFrames {
                renderer.updateObjects(objectFrames)
            }

            if appliedConfiguration?.objectMeters != configuration.objectMeters, let objectMeters = configuration.objectMeters {
                renderer.updateObjectMeters(objectMeters)
            }

            if renderer.renderState.objectVisualSettings != configuration.objectVisualSettings {
                renderer.updateObjectVisualSettings(configuration.objectVisualSettings)
            }

            if appliedConfiguration?.camera != configuration.camera {
                renderer.updateCamera(configuration.camera)
            }

            if appliedConfiguration?.selection != configuration.selection {
                renderer.select(configuration.selection)
            }

            appliedConfiguration = configuration
            return renderer.drainEvents()
        }
    }
}
