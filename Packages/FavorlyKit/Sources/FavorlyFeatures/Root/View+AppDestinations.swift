import SwiftUI

extension View {
    /// Registers `AppDestinations`. Apply once, to the root view of a `NavigationStack`.
    func appDestinations(_ environment: AppEnvironment) -> some View {
        modifier(AppDestinations(environment: environment))
    }
}
