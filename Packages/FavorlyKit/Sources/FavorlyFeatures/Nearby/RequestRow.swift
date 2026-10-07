import FavorlyCore
import SwiftUI

struct RequestRow: View {
    let item: NearbyRequest
    let requesterName: String
    let isOwn: Bool
    @ScaledMetric private var iconWidth = 28.0

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.request.category.systemImage)
                .frame(width: iconWidth)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.request.title)
                Text("\(DistanceFormatter.miles(item.distanceMeters)) · \(requesterName) · \(postedText)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isOwn {
                Text("Yours")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
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
