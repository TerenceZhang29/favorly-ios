import Foundation

public struct UserProfile: Identifiable, Hashable, Codable, Sendable {
    public let id: UserID
    public var displayName: String
    public var neighborhood: String

    public init(id: UserID, displayName: String, neighborhood: String) {
        self.id = id
        self.displayName = displayName
        self.neighborhood = neighborhood
    }
}
