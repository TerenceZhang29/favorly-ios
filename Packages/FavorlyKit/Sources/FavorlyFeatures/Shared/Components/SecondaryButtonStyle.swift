import SwiftUI

/// Any other action: full width, a colored label on a soft tint of the same color.
struct SecondaryButtonStyle: ButtonStyle {
    var color = Theme.Colors.brand
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(color)
            .multilineTextAlignment(.center)
            .padding(Theme.Spacing.large)
            .frame(maxWidth: .infinity)
            .background(
                color.opacity(Theme.tintOpacity),
                in: RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous)
            )
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
        Button("Mark completed") {}
            .buttonStyle(SecondaryButtonStyle())
        Button("Cancel request") {}
            .buttonStyle(SecondaryButtonStyle(color: Theme.Colors.statusCancelled))
        Button("Reset demo data") {}
            .buttonStyle(SecondaryButtonStyle(color: Theme.Colors.statusCancelled))
            .disabled(true)
    }
}
