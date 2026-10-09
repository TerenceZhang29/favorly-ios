import FavorlyCore
import SwiftUI

/// Five large star buttons. Tapping the third star sets the rating to 3. Each star is its own button for
/// VoiceOver ("3 stars", selected when it is the rating) and for UI tests (`review.star.3`).
struct StarRatingPicker: View {
    @Binding var rating: Int
    var maximum = ReviewRules.ratingRange.upperBound

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            ForEach(1 ... maximum, id: \.self) { star in
                Button {
                    rating = star
                } label: {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.Colors.brand)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(star == 1 ? "1 star" : "\(star) stars")
                .accessibilityAddTraits(star == rating ? .isSelected : [])
                .accessibilityIdentifier("review.star.\(star)")
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LightAndDarkPreview {
        StarRatingPicker(rating: .constant(4))
        StarRatingPicker(rating: .constant(0))
    }
}
