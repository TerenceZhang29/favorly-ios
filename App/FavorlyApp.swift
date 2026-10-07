import FavorlyFeatures
import SwiftUI

@main
struct FavorlyApp: App {
    /// UI tests pass `-uiTesting` to drop the mock network delay. Data is in memory, so every launch starts fresh.
    private static let isUITesting = ProcessInfo.processInfo.arguments.contains("-uiTesting")

    @State private var environment = AppEnvironment.demo(artificialDelay: isUITesting ? .zero : .milliseconds(300))

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appEnvironment, environment)
        }
    }
}
