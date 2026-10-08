import SwiftUI

/// A short piece of text in a color on a soft tint of that color, such as "Open" or "Claimed by Bea".
struct StatusBadge: View {
    let text: String
    let color: AdaptiveColor

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.vertical, Theme.Spacing.small)
            .background(
                color.opacity(Theme.tintOpacity),
                in: RoundedRectangle(cornerRadius: Theme.Radius.badge, style: .continuous)
            )
    }
}

#Preview {
    LightAndDarkPreview {
        StatusBadge(text: "Open", color: Theme.Colors.statusOpen)
        StatusBadge(text: "Claimed by Bea", color: Theme.Colors.statusClaimed)
        StatusBadge(text: "Completed", color: Theme.Colors.neutral)
        StatusBadge(text: "Cancelled", color: Theme.Colors.statusCancelled)
    }
}
