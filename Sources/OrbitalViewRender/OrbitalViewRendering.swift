import OrbitalViewCore

public protocol OrbitalViewRendering: AnyObject {
    var renderState: OrbitalViewRenderState { get }

    func loadScene(_ scene: OrbitalViewSceneSpec)
    func updateMeters(_ frame: SpeakerMeterFrame)
    func updateMeterVisualSettings(_ settings: SpeakerMeterVisualSettings)
    func updateObjects(_ frameSet: OrbitalViewObjectFrameSet)
    func updateObjectMeters(_ frame: ObjectMeterFrame)
    func updateObjectVisualSettings(_ settings: ObjectVisualSettings)
    func updateCamera(_ camera: OrbitalViewCameraState)
    func select(_ selection: OrbitalViewSelection?)
    func drainEvents() -> [OrbitalViewEvent]
}
