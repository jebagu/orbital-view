import OrbitalViewCore
import SwiftUI

public struct OrbitalView: View {
    public let scene: OrbitalViewSceneSpec
    public let meters: SpeakerMeterFrame?

    @Binding private var camera: OrbitalViewCameraState
    @Binding private var selection: OrbitalViewSelection?

    private let onEvents: ([OrbitalViewEvent]) -> Void

    public init(
        scene: OrbitalViewSceneSpec,
        meters: SpeakerMeterFrame? = nil,
        camera: Binding<OrbitalViewCameraState>,
        selection: Binding<OrbitalViewSelection?> = .constant(nil),
        onEvents: @escaping ([OrbitalViewEvent]) -> Void = { _ in }
    ) {
        self.scene = scene
        self.meters = meters
        self._camera = camera
        self._selection = selection
        self.onEvents = onEvents
    }

    public var body: some View {
        OrbitalViewMetalView(
            configuration: OrbitalViewRenderConfiguration(
                scene: scene,
                meters: meters,
                camera: camera,
                selection: selection
            ),
            onEvents: onEvents
        )
    }
}
