import SwiftUI

public extension EnvironmentValues {
    /// Falls back to the preview environment when nothing is injected.
    /// SwiftUI reads environment values while evaluating a view body, which runs on the main actor.
    @Entry var appEnvironment: AppEnvironment = MainActor.assumeIsolated { .sharedPreview }
}
