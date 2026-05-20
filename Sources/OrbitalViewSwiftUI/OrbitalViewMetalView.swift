import MetalKit
import OrbitalViewCore
import OrbitalViewRender
import SwiftUI

struct OrbitalViewRenderConfiguration: Equatable {
    let scene: OrbitalViewSceneSpec
    let meters: SpeakerMeterFrame?
    let meterVisualSettings: SpeakerMeterVisualSettings
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
        context.coordinator.renderer.attach(to: view)
        emit(context.coordinator.apply(configuration))
        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {
        emit(context.coordinator.apply(configuration))
    }

    private func emit(_ events: [OrbitalViewEvent]) {
        guard !events.isEmpty else { return }
        onEvents(events)
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
