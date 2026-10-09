import SwiftUI

/// A user's initial on a circle tinted with their color. Stands in for a profile photo.
/// Grows with Dynamic Type, up to `Theme.IconSize.maxScale`.
struct AvatarView: View {
    let name: String
    let color: AdaptiveColor
    private let baseSide: CGFloat
    @ScaledMetric private var scaledSide: CGFloat

    init(name: String, color: AdaptiveColor, side: CGFloat = Theme.IconSize.avatar) {
        self.name = name
        self.color = color
        baseSide = side
        _scaledSide = ScaledMetric(wrappedValue: side)
    }

    private var side: CGFloat { min(scaledSide, baseSide * Theme.IconSize.maxScale) }

    private var initial: String {
        name.first.map { String($0).uppercased() } ?? "?"
    }

    var body: some View {
        Text(initial)
            .font(.system(size: side * Theme.IconSize.symbolScale, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
            .frame(width: side, height: side)
            .background(color.opacity(Theme.tintOpacity), in: Circle())
            .accessibilityHidden(true)
    }
}

#Preview {
    LightAndDarkPreview {
        HStack(spacing: Theme.Spacing.large) {
            ForEach(Array(Theme.Colors.avatars.enumerated()), id: \.offset) { _, color in
                AvatarView(name: "Bea", color: color)
            }
        }
        AvatarView(name: "Chen", color: Theme.Colors.categoryIngredient, side: Theme.IconSize.row)
    }
}
