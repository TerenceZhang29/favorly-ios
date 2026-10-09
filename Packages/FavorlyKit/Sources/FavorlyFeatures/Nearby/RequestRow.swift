import FavorlyCore
import SwiftUI

struct RequestRow: View {
    let item: NearbyRequest
    let requesterName: String
    let isOwn: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: Theme.Spacing.large) {
            CategoryIcon(systemImage: item.request.category.systemImage, color: item.request.category.color)
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text(item.request.title)
                    .fontWeight(.semibold)
                Text("\(distanceText) · \(requesterName) · \(postedText)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if isOwn, stacksBadge {
                    ownBadge
                }
            }
            Spacer(minLength: Theme.Spacing.medium)
            if isOwn, !stacksBadge {
                ownBadge
            }
        }
        .padding(.vertical, Theme.Spacing.small)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
    }

    /// At accessibility text sizes the badge goes under the text, so the title keeps the row's width.
    private var stacksBadge: Bool { dynamicTypeSize.isAccessibilitySize }

    private var ownBadge: some View { TagBadge(text: "Yours") }

    private var distanceText: Text {
        Text(DistanceFormatter.miles(item.distanceMeters))
            .fontWeight(.medium)
            .foregroundStyle(Theme.Colors.brand)
    }

    private var postedText: String {
        item.request.createdAt.formatted(.relative(presentation: .named))
    }

    private var spokenLabel: String {
        let distance = DistanceFormatter.spokenMiles(item.distanceMeters)
        let parts = [
            item.request.title,
            item.request.category.title,
            "\(distance) away",
            "posted \(postedText) by \(requesterName)",
        ]
        return (isOwn ? parts + ["yours"] : parts).joined(separator: ", ")
    }
}
