import SwiftUI

public struct RootView: View {
    @Environment(\.appEnvironment) private var environment
    @State private var selection: RootTab = .nearby

    public init() {}

    public var body: some View {
        TabView(selection: $selection) {
            ForEach(RootTab.allCases) { tab in
                NavigationStack {
                    content(for: tab)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.systemImage)
                }
                .tag(tab)
                .accessibilityIdentifier("root.tab.\(tab.rawValue)")
            }
        }
    }

    @ViewBuilder
    private func content(for tab: RootTab) -> some View {
        switch tab {
        case .nearby: NearbyView(environment: environment)
        case .post: PostRequestView()
        case .activity: ActivityView()
        case .devSettings: DevSettingsView()
        }
    }
}

#Preview {
    RootView()
}
