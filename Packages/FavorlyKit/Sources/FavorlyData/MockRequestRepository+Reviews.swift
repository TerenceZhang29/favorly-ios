import FavorlyCore
import Foundation

extension MockRequestRepository: ReviewRepository {
    public func reviews(about user: UserID) async throws -> [Review] {
        try await simulateLatency()
        return reviews
            .filter { $0.revieweeID == user }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// Throws `notFound` for an unknown request; returns `nil` while it has no review.
    public func review(for request: RequestID) async throws -> Review? {
        try await simulateLatency()
        guard requests[request] != nil else { throw FavorlyError.notFound }
        return reviews.first { $0.requestID == request }
    }
}
