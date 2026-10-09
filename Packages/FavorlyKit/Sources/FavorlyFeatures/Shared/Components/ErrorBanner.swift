import SwiftUI

/// An error message with a warning symbol, in the theme red on a soft red tint.
struct ErrorBanner: View {
    let message: String
    /// Identifier for the message text, so UI tests can read it.
    let identifier: String

    var body: some View {
        Label {
            Text(message)
                .accessibilityIdentifier(identifier)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .accessibilityHidden(true)
        }
        .foregroundStyle(Theme.Colors.statusCancelled)
        .padding(Theme.Spacing.xLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Theme.Colors.statusCancelled.opacity(Theme.tintOpacity),
            in: RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous)
        )
    }
}

#Preview {
    LightAndDarkPreview {
        ErrorBanner(message: "Someone else already picked this up.", identifier: "preview.error")
    }
}
