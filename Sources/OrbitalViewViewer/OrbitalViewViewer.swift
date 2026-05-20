import OrbitalViewSwiftUI
import SwiftUI

@main
struct OrbitalViewVUKitApp: App {
    var body: some Scene {
        WindowGroup("Orbital View VU Kit") {
            OrbitalViewportMockup()
                .frame(
                    minWidth: OrbitalViewportMockup.nativeMinimumWindowSize.width,
                    idealWidth: OrbitalViewportMockup.nativeDefaultWindowSize.width,
                    maxWidth: .infinity,
                    minHeight: OrbitalViewportMockup.nativeMinimumWindowSize.height,
                    idealHeight: OrbitalViewportMockup.nativeDefaultWindowSize.height,
                    maxHeight: .infinity
                )
        }
        .defaultSize(
            width: OrbitalViewportMockup.nativeDefaultWindowSize.width,
            height: OrbitalViewportMockup.nativeDefaultWindowSize.height
        )
        .windowStyle(.hiddenTitleBar)
    }
}
