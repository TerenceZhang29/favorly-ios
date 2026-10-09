import Foundation

public protocol KindnessRepository: Sendable {
    func kindnessSummary(for user: UserID) async throws -> KindnessSummary
    /// Newest first.
    func redemptions(by user: UserID) async throws -> [Redemption]
    func redeemGiftCard(by user: UserID) async throws -> Redemption
}
