import FavorlyCore
import Foundation
import Observation

/// One user's profile: who they are, their Kindness score, and their completed favors.
/// The owner also sees gift-card progress and past reward codes.
@MainActor
@Observable
final class ProfileViewModel {
    struct Content: Equatable {
        let user: UserProfile
        let summary: KindnessSummary
        /// Completed requests the user helped with or asked for, newest first.
        let activities: [ProfileActivity]
        /// Newest first.
        let reviews: [Review]
        /// The owner's past gift cards, newest first; nil on someone else's profile.
        let redemptions: [Redemption]?
    }

    enum State: Equatable {
        case loading
        case loaded(Content)
        case failed(String)
    }

    private(set) var state: State = .loading
    /// The gift card redeemed on this screen, shown until the user is switched.
    private(set) var latestRedemption: Redemption?
    /// Why the last redeem failed.
    private(set) var redeemError: String?
    private(set) var isRedeeming = false

    /// The user whose profile this is, or nil for the signed-in user (the Profile tab).
    private let subjectID: UserID?
    @ObservationIgnored private let environment: AppEnvironment
    @ObservationIgnored private var latestLoad = 0

    init(userID: UserID? = nil, environment: AppEnvironment) {
        subjectID = userID
        self.environment = environment
    }

    /// Changes when the user is switched, which should trigger a fresh load.
    var reloadKey: UserID {
        environment.session.currentUser.id
    }

    var userID: UserID {
        subjectID ?? environment.session.currentUser.id
    }

    /// The signed-in user is looking at their own profile, so the gift card shows.
    var isOwn: Bool {
        userID == environment.session.currentUser.id
    }

    var content: Content? {
        guard case let .loaded(content) = state else { return nil }
        return content
    }

    // MARK: Display text

    /// "5 favors completed", "1 favor completed" or "No favors yet".
    var favorsText: String {
        guard let count = content?.summary.completedFavors, count > 0 else { return "No favors yet" }
        return count == 1 ? "1 favor completed" : "\(count) favors completed"
    }

    /// "4.5 average from 2 reviews", "5.0 average from 1 review" or "No reviews yet".
    var ratingText: String {
        guard let summary = content?.summary, let average = summary.averageRating else { return "No reviews yet" }
        let reviews = summary.reviewCount == 1 ? "1 review" : "\(summary.reviewCount) reviews"
        return "\(Self.ratingFormat(average)) average from \(reviews)"
    }

    /// "90 of 100 points". Above 100 it reads "110 of 100 points", so the number is never hidden.
    var giftCardProgressText: String {
        "\(content?.summary.availablePoints ?? 0) of \(KindnessRules.giftCardCost) points"
    }

    /// Progress toward the next gift card, from 0 to 1.
    var giftCardProgress: Double {
        let available = Double(content?.summary.availablePoints ?? 0)
        return min(max(available / Double(KindnessRules.giftCardCost), 0), 1)
    }

    var canRedeem: Bool {
        guard isOwn, !isRedeeming, let summary = content?.summary else { return false }
        return (try? KindnessRules.validateRedeem(summary)) != nil
    }

    func displayName(for id: UserID) -> String {
        environment.session.displayName(for: id)
    }

    // MARK: Loading

    /// Loads the profile. A profile already on screen stays visible while it reloads.
    func load() async {
        latestLoad += 1
        let load = latestLoad
        let user = userID
        let isOwn = isOwn
        if case .failed = state {
            state = .loading
        }
        if let latestRedemption, latestRedemption.userID != user {
            self.latestRedemption = nil
        }

        do {
            let summary = try await environment.kindness.kindnessSummary(for: user)
            let posted = try await environment.repository.requests(postedBy: user)
            let pickedUp = try await environment.repository.requests(claimedBy: user)
            let reviews = try await environment.reviews.reviews(about: user)
            let redemptions: [Redemption]? = if isOwn {
                try await environment.kindness.redemptions(by: user)
            } else {
                nil
            }
            guard load == latestLoad else { return }
            state = .loaded(Content(
                user: profile(for: user),
                summary: summary,
                activities: Self.activities(posted: posted, pickedUp: pickedUp),
                reviews: reviews,
                redemptions: redemptions
            ))
        } catch is CancellationError {
            // A newer load replaced this one.
        } catch {
            guard load == latestLoad else { return }
            state = .failed(ErrorMessage.text(for: error))
        }
    }

    /// Reloads after every repository write. Runs until the surrounding task is cancelled.
    func observeChanges() async {
        for await _ in environment.repository.changes() {
            await load()
        }
    }

    // MARK: Actions

    /// Spends 100 points on a gift card and shows its code.
    func redeem() async {
        guard canRedeem else { return }
        isRedeeming = true
        defer { isRedeeming = false }
        redeemError = nil

        do {
            latestRedemption = try await environment.kindness.redeemGiftCard(by: userID)
            await load()
        } catch is CancellationError {
            // The screen went away.
        } catch {
            redeemError = ErrorMessage.text(for: error)
        }
    }

    // MARK: Helpers

    private func profile(for id: UserID) -> UserProfile {
        environment.session.availableUsers.first { $0.id == id }
            ?? UserProfile(id: id, displayName: environment.session.displayName(for: id), neighborhood: "")
    }

    /// Completed requests only, on every profile: open and cancelled ones stay private to their owner.
    private static func activities(posted: [HelpRequest], pickedUp: [HelpRequest]) -> [ProfileActivity] {
        let asked = posted.filter { $0.status == .completed }.map { ProfileActivity(request: $0, role: .asked) }
        let helped = pickedUp.filter { $0.status == .completed }.map { ProfileActivity(request: $0, role: .helped) }
        return (asked + helped).sorted { date(of: $0.request) > date(of: $1.request) }
    }

    /// When the favor happened, as near as the model knows: the pick-up time.
    private static func date(of request: HelpRequest) -> Date {
        request.claimedAt ?? request.createdAt
    }

    private static func ratingFormat(_ average: Double) -> String {
        String(format: "%.1f", average)
    }
}
