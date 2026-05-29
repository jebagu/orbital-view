import Foundation

public enum AxisMeaning: String, Codable, Equatable, Sendable {
    case right
    case left
    case up
    case down
    case front
    case back
}

public struct OrbitalViewCoordinateSystem: Equatable, Codable, Sendable {
    public static let wavefield = OrbitalViewCoordinateSystem(
        xAxis: .right,
        yAxis: .front,
        zAxis: .up
    )

    public static let spatGRIS = OrbitalViewCoordinateSystem(
        xAxis: .right,
        yAxis: .front,
        zAxis: .up
    )

    public let xAxis: AxisMeaning
    public let yAxis: AxisMeaning
    public let zAxis: AxisMeaning

    public init(xAxis: AxisMeaning, yAxis: AxisMeaning, zAxis: AxisMeaning) {
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.zAxis = zAxis
    }
}
