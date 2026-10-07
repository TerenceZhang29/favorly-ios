import SwiftUI

/// Placeholder until phase 1E. Shows who is signed in and where, to prove the environment is wired.
struct NearbyView: View {
    @Environment(\.appEnvironment) private var environment

    var body: some View {
        Text(environment.debugSummary)
            .accessibilityIdentifier("nearby.debugSummary")
            .navigationTitle("Nearby")
    }
}

#Preview {
    NavigationStack {
        NearbyView()
    }
}
