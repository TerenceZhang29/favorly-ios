import SwiftUI

/// A Kindness score: a heart in the brand color, the number of points, and the word "points".
/// VoiceOver reads it as "Kindness score, 90 points".
struct ScoreLabel: View {
    let points: Int
    var isLarge = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.small) {
            Image(systemName: "heart.fill")
                .foregroundStyle(Theme.Colors.brand)
            Text(points.formatted())
                .fontWeight(isLarge ? .bold : .semibold)
            Text(points == 1 ? "point" : "points")
                .foregroundStyle(.secondary)
        }
        .font(isLarge ? .title2 : .subheadline)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Kindness score")
        .accessibilityValue(pointsText)
    }

    private var pointsText: String {
        points == 1 ? "1 point" : "\(points.formatted()) points"
    }
}

#Preview {
    LightAndDarkPreview {
        ScoreLabel(points: 90, isLarge: true)
        ScoreLabel(points: 18)
        ScoreLabel(points: 1)
    }
}
