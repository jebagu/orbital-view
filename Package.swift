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
        ),
        .library(
            name: "OrbitalViewWavefield",
            targets: ["OrbitalViewWavefield"]
        )
    ],
    targets: [
        .target(
            name: "OrbitalViewCore"
        ),
        .target(
            name: "OrbitalViewWavefield",
            dependencies: ["OrbitalViewCore"]
        ),
        .testTarget(
            name: "OrbitalViewCoreTests",
            dependencies: ["OrbitalViewCore"]
        ),
        .testTarget(
            name: "OrbitalViewWavefieldTests",
            dependencies: [
                "OrbitalViewCore",
                "OrbitalViewWavefield"
            ],
            resources: [
                .process("Fixtures")
            ]
        )
    ]
)
