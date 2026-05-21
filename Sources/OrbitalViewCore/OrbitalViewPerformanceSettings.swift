import Foundation

public struct OrbitalViewPerformanceSettings: Equatable, Codable, Sendable {
    public static let `default` = OrbitalViewPerformanceSettings(
        uncheckedActiveViewportFramesPerSecond: 60,
        meterOnlyViewportFramesPerSecond: 10,
        inspectorRefreshFramesPerSecond: 10,
        drawsOnDemand: true
    )

    public let activeViewportFramesPerSecond: Int
    public let meterOnlyViewportFramesPerSecond: Int
    public let inspectorRefreshFramesPerSecond: Int
    public let drawsOnDemand: Bool

    public init(
        activeViewportFramesPerSecond: Int = 60,
        meterOnlyViewportFramesPerSecond: Int = 10,
        inspectorRefreshFramesPerSecond: Int = 10,
        drawsOnDemand: Bool = true
    ) throws {
        self.activeViewportFramesPerSecond = activeViewportFramesPerSecond
        self.meterOnlyViewportFramesPerSecond = meterOnlyViewportFramesPerSecond
        self.inspectorRefreshFramesPerSecond = inspectorRefreshFramesPerSecond
        self.drawsOnDemand = drawsOnDemand
        try validate()
    }

    private init(
        uncheckedActiveViewportFramesPerSecond activeViewportFramesPerSecond: Int,
        meterOnlyViewportFramesPerSecond: Int,
        inspectorRefreshFramesPerSecond: Int,
        drawsOnDemand: Bool
    ) {
        self.activeViewportFramesPerSecond = activeViewportFramesPerSecond
        self.meterOnlyViewportFramesPerSecond = meterOnlyViewportFramesPerSecond
        self.inspectorRefreshFramesPerSecond = inspectorRefreshFramesPerSecond
        self.drawsOnDemand = drawsOnDemand
    }

    public func validate() throws {
        guard [30, 60].contains(activeViewportFramesPerSecond) else {
            throw OrbitalViewValidationError.invalidRange(
                field: "performance.activeViewportFramesPerSecond",
                value: Double(activeViewportFramesPerSecond),
                validRange: "30 or 60"
            )
        }
        guard (1...30).contains(meterOnlyViewportFramesPerSecond) else {
            throw OrbitalViewValidationError.invalidRange(
                field: "performance.meterOnlyViewportFramesPerSecond",
                value: Double(meterOnlyViewportFramesPerSecond),
                validRange: "1...30"
            )
        }
        guard (1...30).contains(inspectorRefreshFramesPerSecond) else {
            throw OrbitalViewValidationError.invalidRange(
                field: "performance.inspectorRefreshFramesPerSecond",
                value: Double(inspectorRefreshFramesPerSecond),
                validRange: "1...30"
            )
        }
    }
}
