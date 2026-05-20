import OrbitalViewCore

public struct OrbitalViewRenderState: Equatable, Sendable {
    public static let empty = OrbitalViewRenderState()

    public let scene: OrbitalViewSceneSpec?
    public let meters: SpeakerMeterFrame?
    public let meterVisualSettings: SpeakerMeterVisualSettings
    public let objectFrames: OrbitalViewObjectFrameSet?
    public let objectMeters: ObjectMeterFrame?
    public let objectVisualSettings: ObjectVisualSettings
    public let camera: OrbitalViewCameraState?
    public let selection: OrbitalViewSelection?
    public let structuralRevision: Int
    public let meterRevision: Int
    public let meterVisualSettingsRevision: Int
    public let objectFrameRevision: Int
    public let objectMeterRevision: Int
    public let objectVisualSettingsRevision: Int
    public let cameraRevision: Int

    public init(
        scene: OrbitalViewSceneSpec? = nil,
        meters: SpeakerMeterFrame? = nil,
        meterVisualSettings: SpeakerMeterVisualSettings = .default,
        objectFrames: OrbitalViewObjectFrameSet? = nil,
        objectMeters: ObjectMeterFrame? = nil,
        objectVisualSettings: ObjectVisualSettings = .default,
        camera: OrbitalViewCameraState? = nil,
        selection: OrbitalViewSelection? = nil,
        structuralRevision: Int = 0,
        meterRevision: Int = 0,
        meterVisualSettingsRevision: Int = 0,
        objectFrameRevision: Int = 0,
        objectMeterRevision: Int = 0,
        objectVisualSettingsRevision: Int = 0,
        cameraRevision: Int = 0
    ) {
        self.scene = scene
        self.meters = meters
        self.meterVisualSettings = meterVisualSettings
        self.objectFrames = objectFrames
        self.objectMeters = objectMeters
        self.objectVisualSettings = objectVisualSettings
        self.camera = camera
        self.selection = selection
        self.structuralRevision = structuralRevision
        self.meterRevision = meterRevision
        self.meterVisualSettingsRevision = meterVisualSettingsRevision
        self.objectFrameRevision = objectFrameRevision
        self.objectMeterRevision = objectMeterRevision
        self.objectVisualSettingsRevision = objectVisualSettingsRevision
        self.cameraRevision = cameraRevision
    }

    func loading(scene: OrbitalViewSceneSpec) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            objectFrames: objectFrames,
            objectMeters: objectMeters,
            objectVisualSettings: objectVisualSettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision + 1,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            objectFrameRevision: objectFrameRevision,
            objectMeterRevision: objectMeterRevision,
            objectVisualSettingsRevision: objectVisualSettingsRevision,
            cameraRevision: cameraRevision
        )
    }

    func updating(meters: SpeakerMeterFrame) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            objectFrames: objectFrames,
            objectMeters: objectMeters,
            objectVisualSettings: objectVisualSettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision + 1,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            objectFrameRevision: objectFrameRevision,
            objectMeterRevision: objectMeterRevision,
            objectVisualSettingsRevision: objectVisualSettingsRevision,
            cameraRevision: cameraRevision
        )
    }

    func updating(meterVisualSettings: SpeakerMeterVisualSettings) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            objectFrames: objectFrames,
            objectMeters: objectMeters,
            objectVisualSettings: objectVisualSettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision + 1,
            objectFrameRevision: objectFrameRevision,
            objectMeterRevision: objectMeterRevision,
            objectVisualSettingsRevision: objectVisualSettingsRevision,
            cameraRevision: cameraRevision
        )
    }

    func updating(objects frameSet: OrbitalViewObjectFrameSet) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            objectFrames: frameSet,
            objectMeters: objectMeters,
            objectVisualSettings: objectVisualSettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            objectFrameRevision: objectFrameRevision + 1,
            objectMeterRevision: objectMeterRevision,
            objectVisualSettingsRevision: objectVisualSettingsRevision,
            cameraRevision: cameraRevision
        )
    }

    func updating(objectMeters frame: ObjectMeterFrame) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            objectFrames: objectFrames,
            objectMeters: frame,
            objectVisualSettings: objectVisualSettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            objectFrameRevision: objectFrameRevision,
            objectMeterRevision: objectMeterRevision + 1,
            objectVisualSettingsRevision: objectVisualSettingsRevision,
            cameraRevision: cameraRevision
        )
    }

    func updating(objectVisualSettings settings: ObjectVisualSettings) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            objectFrames: objectFrames,
            objectMeters: objectMeters,
            objectVisualSettings: settings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            objectFrameRevision: objectFrameRevision,
            objectMeterRevision: objectMeterRevision,
            objectVisualSettingsRevision: objectVisualSettingsRevision + 1,
            cameraRevision: cameraRevision
        )
    }

    func updating(camera: OrbitalViewCameraState) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            objectFrames: objectFrames,
            objectMeters: objectMeters,
            objectVisualSettings: objectVisualSettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            objectFrameRevision: objectFrameRevision,
            objectMeterRevision: objectMeterRevision,
            objectVisualSettingsRevision: objectVisualSettingsRevision,
            cameraRevision: cameraRevision + 1
        )
    }

    func selecting(_ selection: OrbitalViewSelection?) -> OrbitalViewRenderState {
        OrbitalViewRenderState(
            scene: scene,
            meters: meters,
            meterVisualSettings: meterVisualSettings,
            objectFrames: objectFrames,
            objectMeters: objectMeters,
            objectVisualSettings: objectVisualSettings,
            camera: camera,
            selection: selection,
            structuralRevision: structuralRevision,
            meterRevision: meterRevision,
            meterVisualSettingsRevision: meterVisualSettingsRevision,
            objectFrameRevision: objectFrameRevision,
            objectMeterRevision: objectMeterRevision,
            objectVisualSettingsRevision: objectVisualSettingsRevision,
            cameraRevision: cameraRevision
        )
    }
}
