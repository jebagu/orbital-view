// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OrbitalViewKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "OrbitalViewCore",
            targets: ["OrbitalViewCore"]
        )
    ],
    targets: [
        .target(
            name: "OrbitalViewCore"
        ),
        .testTarget(
            name: "OrbitalViewCoreTests",
            dependencies: ["OrbitalViewCore"]
        )
    ]
)

