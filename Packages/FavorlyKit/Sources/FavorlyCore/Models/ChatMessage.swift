import Foundation

/// One message in a request's thread between the requester and the helper.
public struct ChatMessage: Identifiable, Hashable, Codable, Sendable {
    public let id: MessageID
    public let requestID: RequestID
    public let senderID: UserID
    public let text: String
    public let sentAt: Date

    public init(id: MessageID, requestID: RequestID, senderID: UserID, text: String, sentAt: Date) {
        self.id = id
        self.requestID = requestID
        self.senderID = senderID
        self.text = text
        self.sentAt = sentAt
    }
}
