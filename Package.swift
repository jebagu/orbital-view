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
            name: "OrbitalViewOrbisonic",
            targets: ["OrbitalViewOrbisonic"]
        ),
        .library(
            name: "OrbitalViewRender",
            targets: ["OrbitalViewRender"]
        ),
        .library(
            name: "OrbitalViewSwiftUI",
            targets: ["OrbitalViewSwiftUI"]
        ),
        .executable(
            name: "OrbitalViewViewer",
            targets: ["OrbitalViewViewer"]
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
            name: "OrbitalViewOrbisonic",
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
        .target(
            name: "OrbitalViewViewerSupport",
            dependencies: ["OrbitalViewCore"]
        ),
        .executableTarget(
            name: "OrbitalViewViewer",
            dependencies: [
                "OrbitalViewCore",
                "OrbitalViewSwiftUI",
                "OrbitalViewViewerSupport"
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
            name: "OrbitalViewOrbisonicTests",
            dependencies: [
                "OrbitalViewCore",
                "OrbitalViewOrbisonic"
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
        ),
        .testTarget(
            name: "OrbitalViewViewerTests",
            dependencies: [
                "OrbitalViewCore",
                "OrbitalViewViewerSupport"
            ]
        )
    ]
)
