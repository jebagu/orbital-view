// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OrbitalView",
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
            name: "OrbitalViewTelemetry",
            targets: ["OrbitalViewTelemetry"]
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
    dependencies: [
        .package(path: "/Users/jeremyguillory/Documents/vibecode-projects/orbisonic-telemetry")
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
            name: "OrbitalViewTelemetry",
            dependencies: [
                "OrbitalViewCore",
                .product(name: "OrbisonicTelemetryDashboard", package: "orbisonic-telemetry"),
                .product(name: "OrbisonicTelemetryKit", package: "orbisonic-telemetry")
            ]
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
                "OrbitalViewSpatGRIS",
                "OrbitalViewTelemetry"
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
                "OrbitalViewSwiftUI",
                "OrbitalViewTelemetry"
            ]
        ),
        .testTarget(
            name: "OrbitalViewTelemetryTests",
            dependencies: [
                "OrbitalViewTelemetry",
                .product(name: "OrbisonicTelemetryKit", package: "orbisonic-telemetry")
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
