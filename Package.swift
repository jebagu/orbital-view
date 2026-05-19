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
        ),
        .library(
            name: "OrbitalViewRender",
            targets: ["OrbitalViewRender"]
        ),
        .library(
            name: "OrbitalViewSwiftUI",
            targets: ["OrbitalViewSwiftUI"]
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
        .target(
            name: "OrbitalViewRender",
            dependencies: ["OrbitalViewCore"]
        ),
        .target(
            name: "OrbitalViewSwiftUI",
            dependencies: [
                "OrbitalViewCore",
                "OrbitalViewRender"
            ]
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
        ),
        .testTarget(
            name: "OrbitalViewRenderTests",
            dependencies: [
                "OrbitalViewCore",
                "OrbitalViewRender"
            ]
        ),
        .testTarget(
            name: "OrbitalViewSwiftUITests",
            dependencies: [
                "OrbitalViewCore",
                "OrbitalViewRender",
                "OrbitalViewSwiftUI"
            ]
        )
    ]
)
