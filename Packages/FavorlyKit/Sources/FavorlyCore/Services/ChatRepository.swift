import Foundation

public protocol ChatRepository: Sendable {
    /// Oldest first.
    func messages(for request: RequestID, as user: UserID) async throws -> [ChatMessage]
    func send(_ text: String, in request: RequestID, by user: UserID) async throws -> ChatMessage
}
