import FavorlyCore
import SwiftUI

/// The Profile tab for the signed-in user, or another user's profile pushed from Request Detail.
struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    /// True for the Profile tab, false when pushed for a given user.
    private let isTab: Bool

    /// - Parameter userID: The user to show, or nil for whoever is signed in.
    init(userID: UserID? = nil, environment: AppEnvironment) {
        _viewModel = State(initialValue: ProfileViewModel(userID: userID, environment: environment))
        isTab = userID == nil
    }

    var body: some View {
        List {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.section)
                    .plainListRow()
                    .accessibilityIdentifier("profile.loading")
            case let .loaded(content):
                header(content.user)
                score
                if let redemptions = content.redemptions {
                    giftCard(redemptions)
                }
                activities(content.activities)
            case let .failed(message):
                MessageView(
                    systemImage: "exclamationmark.triangle",
                    message: message,
                    messageIdentifier: "profile.error",
                    retryIdentifier: "profile.retry"
                ) {
                    Task { await viewModel.load() }
                }
                .plainListRow()
            }
        }
        .navigationTitle(isTab ? "Profile" : viewModel.content?.user.displayName ?? "Profile")
        .toolbarTitleDisplayMode(isTab ? .automatic : .inline)
        .refreshable { await viewModel.load() }
        .task(id: viewModel.reloadKey) { await viewModel.load() }
        .task { await viewModel.observeChanges() }
    }

    private func header(_ user: UserProfile) -> some View {
        Section {
            HStack(spacing: Theme.Spacing.xLarge) {
                AvatarView(name: user.displayName, color: user.id.avatarColor)
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text(user.displayName)
                        .font(.title2.bold())
                        .accessibilityIdentifier("profile.name")
                    if !user.neighborhood.isEmpty {
                        Label(user.neighborhood, systemImage: "mappin")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("profile.neighborhood")
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.medium)
        }
    }

    private var score: some View {
        Section {
            ScoreLabel(points: viewModel.content?.summary.lifetimePoints ?? 0, isLarge: true)
                .accessibilityIdentifier("profile.score")
            Label(viewModel.favorsText, systemImage: "hands.sparkles")
                .accessibilityIdentifier("profile.favors")
            Label(viewModel.ratingText, systemImage: "star")
                .accessibilityIdentifier("profile.rating")
        } header: {
            SectionHeader(text: "Kindness score")
        }
    }

    private func giftCard(_ redemptions: [Redemption]) -> some View {
        Section {
            GiftCardCard(
                progress: viewModel.giftCardProgress,
                progressText: viewModel.giftCardProgressText,
                explanation: "Every \(KindnessRules.giftCardCost) points earns a $5 gift card.",
                canRedeem: viewModel.canRedeem,
                newCode: viewModel.latestRedemption?.code,
                pastCodes: redemptions.filter { $0.id != viewModel.latestRedemption?.id }.map(\.code),
                errorMessage: viewModel.redeemError
            ) {
                Task { await viewModel.redeem() }
            }
        }
    }

    private func activities(_ activities: [ProfileActivity]) -> some View {
        Section {
            if activities.isEmpty {
                MessageView(systemImage: "sparkles", message: "No activity yet", messageIdentifier: "profile.empty")
                    .plainListRow()
            }
            ForEach(activities) { activity in
                NavigationLink(value: activity.id) {
                    ProfileActivityRow(request: activity.request, roleTitle: activity.role.title)
                }
                .accessibilityIdentifier("profile.activity.\(activity.id.rawValue.uuidString)")
            }
        } header: {
            SectionHeader(text: "Past activities")
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(environment: .preview())
            .appDestinations(.preview())
    }
}
