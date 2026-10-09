import FavorlyCore
import SwiftUI

struct ActivityRow: View {
    let request: HelpRequest
    /// The status, then " · Posted by Dana" when someone else posted the request.
    let subtitle: String
    let isNew: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: Theme.Spacing.large) {
            CategoryIcon(systemImage: request.category.systemImage, color: request.category.color)
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text(request.title)
                    .fontWeight(.semibold)
                if stacksBadges {
                    statusLine
                    if isNew { newBadge }
                } else {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: Theme.Spacing.medium) { statusLine }
                        VStack(alignment: .leading, spacing: Theme.Spacing.small) { statusLine }
                    }
                }
            }
            Spacer(minLength: Theme.Spacing.medium)
            if isNew, !stacksBadges { newBadge }
        }
        .padding(.vertical, Theme.Spacing.small)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
    }

    /// At accessibility text sizes the badges go under the title, so the title keeps the row's width.
    private var stacksBadges: Bool { dynamicTypeSize.isAccessibilitySize }

    private var newBadge: some View { TagBadge(text: "New") }

    @ViewBuilder
    private var statusLine: some View {
        StatusBadge(text: subtitleParts[0], color: request.status.color)
        if subtitleParts.count > 1 {
            Text(subtitleParts.dropFirst().joined(separator: Self.separator))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private static let separator = " · "

    private var subtitleParts: [String] {
        subtitle.components(separatedBy: Self.separator)
    }

    private var spokenLabel: String {
        let parts = [request.title, request.category.title, subtitle.replacingOccurrences(of: " · ", with: ", ")]
        return (isNew ? parts + ["new"] : parts).joined(separator: ", ")
    }
}
