import SwiftUI

/// The background of a list row that should stand out: the usual row color with a light brand tint on top.
struct HighlightedRowBackground: View {
    var body: some View {
        Rectangle()
            .fill(.background)
            .overlay(Theme.Colors.brand.opacity(Theme.highlightOpacity))
    }
}

#Preview {
    LightAndDarkPreview {
        Text("Need a cup of rice")
            .padding(Theme.Spacing.xLarge)
            .background(HighlightedRowBackground())
    }
}
