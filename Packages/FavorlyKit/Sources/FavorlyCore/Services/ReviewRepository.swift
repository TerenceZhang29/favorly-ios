import Foundation

public protocol ReviewRepository: Sendable {
    /// Newest first.
    func reviews(about user: UserID) async throws -> [Review]
    func review(for request: RequestID) async throws -> Review?
    func submitReview(_ draft: NewReviewDraft, for request: RequestID, by user: UserID) async throws -> Review
}
