import SwiftUI

/// A label and its value, side by side, or stacked at accessibility text sizes. VoiceOver reads them as one item.
struct FactRow: View {
    let label: String
    let value: String
    /// An optional SF Symbol shown before the label.
    var systemImage: String?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var symbolWidth = Theme.Spacing.section

    var body: some View {
        HStack(spacing: Theme.Spacing.large) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: symbolWidth)
            }
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                    Text(value)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(label)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}

#Preview {
    LightAndDarkPreview {
        FactRow(label: "Category", value: "Ingredient", systemImage: "tag")
        FactRow(label: "Location", value: "Cornell Tech, Roosevelt Island", systemImage: "mappin")
        FactRow(label: "Status", value: "Open")
    }
}
