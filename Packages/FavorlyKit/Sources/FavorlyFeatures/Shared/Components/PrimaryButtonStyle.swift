import SwiftUI

/// The one main action on a screen: full width, filled with the brand color.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(Theme.Colors.onBrand)
            .multilineTextAlignment(.center)
            .padding(.vertical, Theme.Spacing.xLarge)
            .padding(.horizontal, Theme.Spacing.large)
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.brand, in: RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
            .opacity(opacity(isPressed: configuration.isPressed))
            .contentShape(Rectangle())
    }

    private func opacity(isPressed: Bool) -> Double {
        guard isEnabled else { return Theme.disabledOpacity }
        return isPressed ? Theme.pressedOpacity : 1
    }
}

#Preview {
    LightAndDarkPreview {
        Button("Pick up") {}
        Button("Post request") {}
            .disabled(true)
    }
    .buttonStyle(PrimaryButtonStyle())
}
