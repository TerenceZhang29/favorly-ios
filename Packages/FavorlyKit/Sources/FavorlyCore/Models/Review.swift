import Foundation

/// A requester's review of the helper on one completed request.
public struct Review: Identifiable, Hashable, Codable, Sendable {
    public let id: ReviewID
    public let requestID: RequestID
    /// The requester.
    public let reviewerID: UserID
    /// The helper.
    public let revieweeID: UserID
    /// 1...5
    public let rating: Int
    public let comment: String
    public let createdAt: Date

    public init(
        id: ReviewID,
        requestID: RequestID,
        reviewerID: UserID,
        revieweeID: UserID,
        rating: Int,
        comment: String,
        createdAt: Date
    ) {
        self.id = id
        self.requestID = requestID
        self.reviewerID = reviewerID
        self.revieweeID = revieweeID
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
    }
}
