import FavorlyCore
import SwiftUI

struct ActivityRow: View {
    let request: HelpRequest
    let subtitle: String
    let isNew: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: request.category.systemImage)
                .frame(width: 28)
                .accessibilityLabel(request.category.title)
            VStack(alignment: .leading, spacing: 2) {
                Text(request.title)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isNew {
                Text("New")
                    .font(.caption)
                    .foregroundStyle(.tint)
            }
        }
    }
}
