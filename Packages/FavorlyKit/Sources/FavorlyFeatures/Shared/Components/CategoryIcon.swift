import SwiftUI

/// A symbol in its color on a rounded square tinted with the same color. Grows with Dynamic Type, up to
/// `Theme.IconSize.maxScale`, so the text beside it keeps most of the row at the largest text sizes.
struct CategoryIcon: View {
    let systemImage: String
    let color: AdaptiveColor
    private let baseSide: CGFloat
    @ScaledMetric private var scaledSide: CGFloat

    init(systemImage: String, color: AdaptiveColor, isLarge: Bool = false) {
        self.systemImage = systemImage
        self.color = color
        baseSide = isLarge ? Theme.IconSize.large : Theme.IconSize.row
        _scaledSide = ScaledMetric(wrappedValue: baseSide)
    }

    private var side: CGFloat { min(scaledSide, baseSide * Theme.IconSize.maxScale) }

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: side * Theme.IconSize.symbolScale, weight: .medium))
            .foregroundStyle(color)
            .frame(width: side, height: side)
            .background(
                color.opacity(Theme.tintOpacity),
                in: RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}

#Preview {
    LightAndDarkPreview {
        HStack(spacing: Theme.Spacing.large) {
            CategoryIcon(systemImage: "carrot", color: Theme.Colors.categoryIngredient)
            CategoryIcon(systemImage: "shippingbox", color: Theme.Colors.categoryMoving)
            CategoryIcon(systemImage: "car", color: Theme.Colors.categoryCar)
            CategoryIcon(systemImage: "bag", color: Theme.Colors.categoryErrand)
            CategoryIcon(systemImage: "hand.raised", color: Theme.Colors.neutral)
        }
        CategoryIcon(systemImage: "carrot", color: Theme.Colors.categoryIngredient, isLarge: true)
    }
}
