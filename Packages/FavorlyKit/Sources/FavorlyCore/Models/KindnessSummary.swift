import Foundation

/// A user's Kindness score and what is left of it to spend.
public struct KindnessSummary: Hashable, Sendable {
    public let completedFavors: Int
    public let reviewCount: Int
    /// `nil` with no reviews.
    public let averageRating: Double?
    /// The "Kindness score" everyone sees. It never decreases.
    public let lifetimePoints: Int
    public let redeemedPoints: Int
    public var availablePoints: Int { lifetimePoints - redeemedPoints }

    public init(
        completedFavors: Int,
        reviewCount: Int,
        averageRating: Double?,
        lifetimePoints: Int,
        redeemedPoints: Int
    ) {
        self.completedFavors = completedFavors
        self.reviewCount = reviewCount
        self.averageRating = averageRating
        self.lifetimePoints = lifetimePoints
        self.redeemedPoints = redeemedPoints
    }
}
