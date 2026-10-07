import SwiftUI

/// A label and its value, side by side, or stacked at accessibility text sizes. VoiceOver reads them as one item.
struct FactRow: View {
    let label: String
    let value: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                    Text(value)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    Text(label)
                    Spacer()
                    Text(value)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}
