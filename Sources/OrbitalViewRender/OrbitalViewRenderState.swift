import OrbitalViewCore

public struct OrbitalViewRenderState: Equatable, Sendable {
    public static let empty = OrbitalViewRenderState()

    public let scene: OrbitalViewSceneSpec?
    public let meters: SpeakerMeterFrame?
    public let camera: OrbitalViewCameraState?
    public let selection: OrbitalViewSelection?
    public let structuralRevision: Int
    public let meterRevision: Int
    public let cameraRevision: Int

    public init(
        scene: OrbitalViewSceneSpec? = nil,
        meters: SpeakerMeterFrame? = nil,
        camera: OrbitalViewCameraState? = nil,
        selection: OrbitalViewSelection? = nil,
        structuralRevision: Int = 0,
        meterRevision: Int = 0,
        cameraRevision: Int = 0
    ) {
        self.scene = scene
        self.meters = meters
        self.camera = camera
        self.selection = selection
        self.structuralRevision = structuralRevision
        self.meterRevision = meterRevision
        self.cameraRevision = cameraRevision
    }

    func loading(scene: OrbitalViewSceneSpec) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision + 1,
            meterRevision: meterRevision,
            cameraRevision: cameraRevision
        )
    }

    func updating(meters: SpeakerMeterFrame) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision + 1,
            cameraRevision: cameraRevision
        )
    }

    func updating(camera: OrbitalViewCameraState) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            cameraRevision: cameraRevision + 1
        )
    }

    func selecting(_ selection: OrbitalViewSelection?) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            cameraRevision: cameraRevision
        )
    }
}
