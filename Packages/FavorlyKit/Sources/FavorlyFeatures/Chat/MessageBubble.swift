import SwiftUI

/// One chat message: the signed-in user's on the right on a brand tint, the other person's on the left on gray.
struct MessageBubble: View {
    let text: String
    /// "You" or the sender's name.
    let senderName: String
    /// "9:41 PM".
    let timeText: String
    let isMine: Bool

    var body: some View {
        VStack(alignment: isMine ? .trailing : .leading, spacing: Theme.Spacing.small) {
            Text(text)
                .padding(.horizontal, Theme.Spacing.large)
                .padding(.vertical, Theme.Spacing.medium)
                .background(
                    color.opacity(Theme.tintOpacity),
                    in: RoundedRectangle(cornerRadius: Theme.Radius.bubble, style: .continuous)
                )
            Text("\(senderName) · \(timeText)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
        .padding(.leading, isMine ? Theme.Spacing.bubbleInset : Theme.Spacing.xLarge)
        .padding(.trailing, isMine ? Theme.Spacing.xLarge : Theme.Spacing.bubbleInset)
        .padding(.vertical, Theme.Spacing.small)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(senderName) said: \(text), at \(timeText)")
    }

    private var color: AdaptiveColor {
        isMine ? Theme.Colors.brand : Theme.Colors.neutral
    }
}

#Preview {
    LightAndDarkPreview {
        MessageBubble(text: "On my way", senderName: "Bea", timeText: "9:41 PM", isMine: false)
        MessageBubble(text: "Thank you! The door code is 1234.", senderName: "You", timeText: "9:42 PM", isMine: true)
    }
}
