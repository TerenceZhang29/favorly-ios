import FavorlyCore
import SwiftUI

/// A completed request on a profile: its icon, title, "Helped" or "Asked", and the location label only.
struct ProfileActivityRow: View {
    let request: HelpRequest
    /// "Helped" or "Asked".
    let roleTitle: String

    var body: some View {
        HStack(spacing: Theme.Spacing.large) {
            CategoryIcon(systemImage: request.category.systemImage, color: request.category.color)
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text(request.title)
                    .fontWeight(.semibold)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: Theme.Spacing.medium) { details }
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) { details }
                }
            }
            Spacer(minLength: Theme.Spacing.medium)
        }
        .padding(.vertical, Theme.Spacing.small)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
    }

    @ViewBuilder
    private var details: some View {
        TagBadge(text: roleTitle)
        Text(request.location.label)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    /// "Need a pinch of saffron, Ingredient, Helped, Downtown Brooklyn".
    private var spokenLabel: String {
        [request.title, request.category.title, roleTitle, request.location.label].joined(separator: ", ")
    }
}

#Preview {
    LightAndDarkPreview {
        ProfileActivityRow(
            request: HelpRequest(
                id: RequestID(rawValue: UUID()),
                title: "Need a pinch of saffron",
                details: "",
                category: .ingredient,
                location: TaggedLocation(
                    point: GeoPoint(latitude: 40.6929, longitude: -73.9857),
                    label: "Downtown Brooklyn"
                ),
                requesterID: UserID(rawValue: "preview-dana"),
                helperID: UserID(rawValue: "preview-bea"),
                status: .completed,
                createdAt: Date()
            ),
            roleTitle: "Helped"
        )
    }
}
