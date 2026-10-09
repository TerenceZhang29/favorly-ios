import Foundation

public protocol ReviewRepository: Sendable {
    /// Newest first.
    func reviews(about user: UserID) async throws -> [Review]
    func review(for request: RequestID) async throws -> Review?
}
