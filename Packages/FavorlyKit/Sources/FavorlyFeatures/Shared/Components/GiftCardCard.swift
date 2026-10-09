import SwiftUI

/// Progress toward the next gift card, the Redeem button, and the codes redeemed so far. Only the owner sees it.
struct GiftCardCard: View {
    /// From 0 to 1.
    let progress: Double
    /// "90 of 100 points".
    let progressText: String
    /// "Every 100 points earns a $5 gift card."
    let explanation: String
    let canRedeem: Bool
    /// The code just redeemed, shown large.
    let newCode: String?
    /// Earlier codes, newest first.
    let pastCodes: [String]
    let errorMessage: String?
    let onRedeem: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.large) {
            Label {
                Text("Gift card")
                    .font(.headline)
            } icon: {
                Image(systemName: "giftcard")
                    .foregroundStyle(Theme.Colors.brand)
            }
            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                ProgressView(value: progress)
                    .tint(Theme.Colors.brand)
                    .accessibilityHidden(true)
                Text(progressText)
                    .font(.subheadline.weight(.semibold))
                    .accessibilityLabel("Gift card progress")
                    .accessibilityValue(progressText)
                    .accessibilityIdentifier("profile.giftCardProgress")
            }

            if let newCode {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Your reward code")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(newCode)
                        .font(.title3.monospaced().bold())
                        .foregroundStyle(Theme.Colors.brand)
                        .textSelection(.enabled)
                        .accessibilityLabel("Your reward code")
                        .accessibilityValue(newCode)
                        .accessibilityIdentifier("profile.rewardCode")
                }
                .padding(Theme.Spacing.large)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Theme.Colors.brand.opacity(Theme.tintOpacity),
                    in: RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                )
            }

            if let errorMessage {
                InlineMessage(text: errorMessage, identifier: "profile.redeemError")
            }

            Button("Redeem", action: onRedeem)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canRedeem)
                .accessibilityIdentifier("profile.redeem")

            if !pastCodes.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Past reward codes")
                        .font(.subheadline.weight(.semibold))
                    ForEach(pastCodes, id: \.self) { code in
                        Text(code)
                            .font(.subheadline.monospaced())
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("profile.pastCodes")
            }
        }
        .padding(.vertical, Theme.Spacing.medium)
    }
}

#Preview {
    LightAndDarkPreview {
        GiftCardCard(
            progress: 0.9,
            progressText: "90 of 100 points",
            explanation: "Every 100 points earns a $5 gift card.",
            canRedeem: false,
            newCode: nil,
            pastCodes: [],
            errorMessage: nil
        ) {}
        GiftCardCard(
            progress: 0.1,
            progressText: "10 of 100 points",
            explanation: "Every 100 points earns a $5 gift card.",
            canRedeem: false,
            newCode: "FAVORLY-0002",
            pastCodes: ["FAVORLY-0001"],
            errorMessage: nil
        ) {}
    }
}
