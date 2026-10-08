import SwiftUI

/// A short validation or error message in the theme red, with a small warning symbol.
struct InlineMessage: View {
    let text: String
    /// Identifier for the message text, so UI tests can read it.
    let identifier: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.small) {
            Image(systemName: "exclamationmark.triangle.fill")
                .accessibilityHidden(true)
            Text(text)
                .accessibilityIdentifier(identifier)
        }
        .font(.footnote)
        .foregroundStyle(Theme.Colors.statusCancelled)
    }
}

#Preview {
    LightAndDarkPreview {
        InlineMessage(text: "Title must be at least 3 characters.", identifier: "preview.message")
    }
}
