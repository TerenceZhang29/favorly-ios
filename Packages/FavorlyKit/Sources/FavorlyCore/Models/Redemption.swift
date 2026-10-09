import Foundation

/// A gift card bought with Kindness points.
public struct Redemption: Identifiable, Hashable, Codable, Sendable {
    public let id: RedemptionID
    public let userID: UserID
    /// Points spent.
    public let points: Int
    /// A fake reward code, such as "FAVORLY-0001".
    public let code: String
    public let createdAt: Date

    public init(id: RedemptionID, userID: UserID, points: Int, code: String, createdAt: Date) {
        self.id = id
        self.userID = userID
        self.points = points
        self.code = code
        self.createdAt = createdAt
    }
}
