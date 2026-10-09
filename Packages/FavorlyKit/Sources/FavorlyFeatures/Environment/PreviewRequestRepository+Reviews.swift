import FavorlyCore

extension PreviewRequestRepository: ReviewRepository {
    func reviews(about user: UserID) async throws -> [Review] {
        reviews
            .filter { $0.revieweeID == user }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func review(for request: RequestID) async throws -> Review? {
        reviews.first { $0.requestID == request }
    }
}
