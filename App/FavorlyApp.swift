import FavorlyFeatures
import SwiftUI

@main
struct FavorlyApp: App {
    @State private var environment = AppEnvironment.demo()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appEnvironment, environment)
        }
    }
}
