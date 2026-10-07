import SwiftUI

public struct RootView: View {
    @State private var selection: RootTab = .nearby

    public init() {}

    public var body: some View {
        TabView(selection: $selection) {
            ForEach(RootTab.allCases) { tab in
                Text(tab.title)
                    .accessibilityIdentifier("root.placeholder.\(tab.rawValue)")
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
                    .accessibilityIdentifier("root.tab.\(tab.rawValue)")
            }
        }
    }
}

#Preview {
    RootView()
}
