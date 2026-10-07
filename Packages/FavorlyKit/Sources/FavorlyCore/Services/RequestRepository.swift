import Foundation

public protocol RequestRepository: Sendable {
    func nearby(around point: GeoPoint, radiusMeters: Double) async throws -> [NearbyRequest]
    func request(id: RequestID) async throws -> HelpRequest
    func requests(postedBy user: UserID) async throws -> [HelpRequest]
    func requests(claimedBy user: UserID) async throws -> [HelpRequest]
    func create(_ draft: NewRequestDraft, by user: UserID) async throws -> HelpRequest
    func claim(_ id: RequestID, by user: UserID) async throws -> HelpRequest
    func cancel(_ id: RequestID, by user: UserID) async throws -> HelpRequest
    func complete(_ id: RequestID, by user: UserID) async throws -> HelpRequest
    /// Emits after any write, so open screens refresh.
    func changes() -> AsyncStream<Void>
    /// Restores the seed data (dev settings).
    func reset() async
}
