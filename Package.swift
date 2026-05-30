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
            name: "OrbitalViewSpatGRIS",
            targets: ["OrbitalViewSpatGRIS"]
        ),
        .library(
            name: "OrbitalViewRender",
            targets: ["OrbitalViewRender"]
        ),
        .library(
            name: "OrbitalViewSwiftUI",
            targets: ["OrbitalViewSwiftUI"]
        ),
        .library(
            name: "OrbitalViewReview",
            targets: ["OrbitalViewReview"]
        ),
        .executable(
            name: "OrbitalViewViewer",
            targets: ["OrbitalViewViewer"]
        ),
        .executable(
            name: "OrbitalViewHeadlessBenchmark",
            targets: ["OrbitalViewHeadlessBenchmark"]
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
            name: "OrbitalViewSpatGRIS",
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
            name: "OrbitalViewReview",
            dependencies: [
                "OrbitalViewCore",
                "OrbitalViewSpatGRIS"
            ],
            resources: [
                .process("Resources")
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
                "OrbitalViewReview",
                "OrbitalViewViewerSupport"
            ]
        ),
        .executableTarget(
            name: "OrbitalViewHeadlessBenchmark",
            dependencies: [
                "OrbitalViewReview"
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
            name: "OrbitalViewSpatGRISTests",
            dependencies: [
                "OrbitalViewCore",
                "OrbitalViewSpatGRIS"
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
                "OrbitalViewReview",
                "OrbitalViewSpatGRIS",
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
