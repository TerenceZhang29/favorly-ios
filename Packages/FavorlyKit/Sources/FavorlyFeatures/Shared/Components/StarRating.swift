import FavorlyCore
import SwiftUI

/// A read-only row of stars in the brand color, such as 4 of 5 filled. VoiceOver reads "4 out of 5 stars".
struct StarRating: View {
    let rating: Int
    var maximum = ReviewRules.ratingRange.upperBound

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            ForEach(1 ... maximum, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
            }
        }
        .font(.subheadline)
        .foregroundStyle(Theme.Colors.brand)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(rating) out of \(maximum) stars")
    }
}

#Preview {
    LightAndDarkPreview {
        StarRating(rating: 5)
        StarRating(rating: 4)
        StarRating(rating: 0)
    }
}
