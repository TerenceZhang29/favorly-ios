import Foundation

/// How helpers earn Kindness points and spend them on gift cards.
public enum KindnessRules {
    /// Earned by the helper for each completed request.
    public static let pointsPerFavor = 10
    /// Earned by the helper for each star in a completed request's review.
    public static let pointsPerStar = 2
    /// The available points one gift card costs.
    public static let giftCardCost = 100

    /// Derives a user's score from their history; nothing stores a running total.
    ///
    /// - Parameters:
    ///   - completedAsHelper: Requests the user picked up. Only completed ones earn points.
    ///   - reviews: Reviews about the user. Only reviews of a counted request earn points.
    ///   - redemptions: The user's gift cards.
    public static func summary(
        completedAsHelper: [HelpRequest],
        reviews: [Review],
        redemptions: [Redemption]
    ) -> KindnessSummary {
        let completed = Set(completedAsHelper.filter { $0.status == .completed }.map(\.id))
        let ratings = reviews.filter { completed.contains($0.requestID) }.map(\.rating)
        let stars = ratings.reduce(0, +)
        return KindnessSummary(
            completedFavors: completed.count,
            reviewCount: ratings.count,
            averageRating: ratings.isEmpty ? nil : Double(stars) / Double(ratings.count),
            lifetimePoints: completed.count * pointsPerFavor + stars * pointsPerStar,
            redeemedPoints: redemptions.map(\.points).reduce(0, +)
        )
    }

    /// Throws `notEnoughPoints` unless a gift card is affordable.
    public static func validateRedeem(_ summary: KindnessSummary) throws {
        guard summary.availablePoints >= giftCardCost else { throw FavorlyError.notEnoughPoints }
    }

    /// The reward code for the `number`th gift card ever redeemed, counting from 1: "FAVORLY-0001".
    public static func rewardCode(number: Int) -> String {
        "FAVORLY-" + String(format: "%04d", number)
    }
}
