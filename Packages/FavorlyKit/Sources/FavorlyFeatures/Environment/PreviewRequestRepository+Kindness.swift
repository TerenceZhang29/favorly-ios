import FavorlyCore

/// Scores derived from the fixed requests and reviews. Nobody has redeemed anything, and redeeming throws.
extension PreviewRequestRepository: KindnessRepository {
    func kindnessSummary(for user: UserID) async throws -> KindnessSummary {
        KindnessRules.summary(
            completedAsHelper: requests.filter { $0.helperID == user },
            reviews: reviews.filter { $0.revieweeID == user },
            redemptions: []
        )
    }

    func redemptions(by _: UserID) async throws -> [Redemption] {
        []
    }

    func redeemGiftCard(by _: UserID) async throws -> Redemption {
        throw FavorlyError.notAllowed
    }
}
