import OrbitalViewCore

public protocol OrbitalViewRendering: AnyObject {
    var renderState: OrbitalViewRenderState { get }

    func loadScene(_ scene: OrbitalViewSceneSpec)
    func updateMeters(_ frame: SpeakerMeterFrame)
    func updateCamera(_ camera: OrbitalViewCameraState)
    func select(_ selection: OrbitalViewSelection?)
    func drainEvents() -> [OrbitalViewEvent]
}
