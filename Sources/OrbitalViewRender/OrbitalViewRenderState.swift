import OrbitalViewCore

public struct OrbitalViewRenderState: Equatable, Sendable {
    public static let empty = OrbitalViewRenderState()

    public let scene: OrbitalViewSceneSpec?
    public let meters: SpeakerMeterFrame?
    public let meterVisualSettings: SpeakerMeterVisualSettings
    public let displaySettings: OrbitalViewDisplaySettings
    public let camera: OrbitalViewCameraState?
    public let selection: OrbitalViewSelection?
    public let structuralRevision: Int
    public let meterRevision: Int
    public let meterVisualSettingsRevision: Int
    public let displaySettingsRevision: Int
    public let cameraRevision: Int

    public init(
        scene: OrbitalViewSceneSpec? = nil,
        meters: SpeakerMeterFrame? = nil,
        meterVisualSettings: SpeakerMeterVisualSettings = .default,
        displaySettings: OrbitalViewDisplaySettings = .default,
        camera: OrbitalViewCameraState? = nil,
        selection: OrbitalViewSelection? = nil,
        structuralRevision: Int = 0,
        meterRevision: Int = 0,
        meterVisualSettingsRevision: Int = 0,
        displaySettingsRevision: Int = 0,
        cameraRevision: Int = 0
    ) {
        self.scene = scene
        self.meters = meters
        self.meterVisualSettings = meterVisualSettings
        self.displaySettings = displaySettings
        self.camera = camera
        self.selection = selection
        self.structuralRevision = structuralRevision
        self.meterRevision = meterRevision
        self.meterVisualSettingsRevision = meterVisualSettingsRevision
        self.displaySettingsRevision = displaySettingsRevision
        self.cameraRevision = cameraRevision
    }

    func loading(scene: OrbitalViewSceneSpec) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            displaySettings: displaySettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision + 1,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            displaySettingsRevision: displaySettingsRevision,
            cameraRevision: cameraRevision
        )
    }

    func updating(meters: SpeakerMeterFrame) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            displaySettings: displaySettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision + 1,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            displaySettingsRevision: displaySettingsRevision,
            cameraRevision: cameraRevision
        )
    }

    func updating(meterVisualSettings: SpeakerMeterVisualSettings) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            displaySettings: displaySettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision + 1,
            displaySettingsRevision: displaySettingsRevision,
            cameraRevision: cameraRevision
        )
    }

    func updating(displaySettings: OrbitalViewDisplaySettings) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            displaySettings: displaySettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            displaySettingsRevision: displaySettingsRevision + 1,
            cameraRevision: cameraRevision
        )
    }

    func updating(camera: OrbitalViewCameraState) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            displaySettings: displaySettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            displaySettingsRevision: displaySettingsRevision,
            cameraRevision: cameraRevision + 1
        )
    }

    func selecting(_ selection: OrbitalViewSelection?) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            displaySettings: displaySettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            displaySettingsRevision: displaySettingsRevision,
            cameraRevision: cameraRevision
        )
    }
}
