import FavorlyCore
import SwiftUI

struct RequestRow: View {
    let item: NearbyRequest
    let requesterName: String
    let isOwn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.request.category.systemImage)
                .frame(width: 28)
                .accessibilityLabel(item.request.category.title)
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
    }

    private var postedText: String {
        item.request.createdAt.formatted(.relative(presentation: .named))
    }
}
