import FavorlyCore
import SwiftUI

struct ActivityRow: View {
    let request: HelpRequest
    let subtitle: String
    let isNew: Bool
    @ScaledMetric private var iconWidth = 28.0

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: request.category.systemImage)
                .frame(width: iconWidth)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
    }

    private var spokenLabel: String {
        let parts = [request.title, request.category.title, subtitle.replacingOccurrences(of: " · ", with: ", ")]
        return (isNew ? parts + ["new"] : parts).joined(separator: ", ")
    }
}
