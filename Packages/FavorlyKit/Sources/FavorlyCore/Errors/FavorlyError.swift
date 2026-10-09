import Foundation

public enum FavorlyError: Error, Equatable, Sendable {
    case notFound
    case alreadyClaimed
    case cannotClaimOwnRequest
    /// For example, cancelling someone else's request.
    case notAllowed
    case invalidTransition(from: RequestStatus, to: RequestStatus)
    /// Carries a user-facing message.
    case validation(String)
    case locationUnavailable
    /// The requester already reviewed this request.
    case alreadyReviewed
    /// Fewer available Kindness points than a gift card costs.
    case notEnoughPoints
}
