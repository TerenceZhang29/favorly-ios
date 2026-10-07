import FavorlyCore
import Foundation

public actor MockRequestRepository: RequestRepository {
    private let seed: @Sendable () -> [HelpRequest]
    private let artificialDelay: Duration
    private let now: @Sendable () -> Date
    private let broadcaster = ChangeBroadcaster()
    private var requests: [RequestID: HelpRequest]

    /// - Parameters:
    ///   - seed: Builds the starting data, and again on every `reset()`.
    ///   - artificialDelay: Wait before each read or write, so loading states are visible.
    ///   - now: The clock used for `createdAt` and `claimedAt`.
    public init(
        seed: @escaping @Sendable () -> [HelpRequest] = { DemoRequests.all() },
        artificialDelay: Duration = .milliseconds(300),
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.seed = seed
        self.artificialDelay = artificialDelay
        self.now = now
        requests = Self.indexed(seed())
    }

    // MARK: Reads

    public func nearby(around point: GeoPoint, radiusMeters: Double) async throws -> [NearbyRequest] {
        try await simulateLatency()
        return requests.values
            .filter { $0.status == .open }
            .map { NearbyRequest(request: $0, distanceMeters: Distance.meters(from: point, to: $0.location.point)) }
            .filter { $0.distanceMeters <= radiusMeters }
            .sorted {
                if $0.distanceMeters != $1.distanceMeters {
                    return $0.distanceMeters < $1.distanceMeters
                }
                return $0.request.createdAt > $1.request.createdAt
            }
    }

    public func request(id: RequestID) async throws -> HelpRequest {
        try await simulateLatency()
        guard let request = requests[id] else { throw FavorlyError.notFound }
        return request
    }

    public func requests(postedBy user: UserID) async throws -> [HelpRequest] {
        try await simulateLatency()
        return requests.values
            .filter { $0.requesterID == user }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func requests(claimedBy user: UserID) async throws -> [HelpRequest] {
        try await simulateLatency()
        return requests.values
            .filter { $0.helperID == user }
            .sorted { ($0.claimedAt ?? $0.createdAt) > ($1.claimedAt ?? $1.createdAt) }
    }

    // MARK: Writes

    public func create(_ draft: NewRequestDraft, by user: UserID) async throws -> HelpRequest {
        try await simulateLatency()
        let draft = try DraftValidator.validate(draft)
        let request = HelpRequest(
            id: RequestID(rawValue: UUID()),
            title: draft.title,
            details: draft.details,
            category: draft.category,
            location: draft.location,
            requesterID: user,
            createdAt: now()
        )
        requests[request.id] = request
        broadcaster.send()
        return request
    }

    public func claim(_ id: RequestID, by user: UserID) async throws -> HelpRequest {
        let claimedAt = now()
        return try await update(id) { request in
            try RequestRules.validateClaim(request: request, by: user)
            request.helperID = user
            request.claimedAt = claimedAt
            request.status = .claimed
        }
    }

    public func cancel(_ id: RequestID, by user: UserID) async throws -> HelpRequest {
        try await update(id) { request in
            try RequestRules.validateCancel(request: request, by: user)
            request.status = .cancelled
        }
    }

    public func complete(_ id: RequestID, by user: UserID) async throws -> HelpRequest {
        try await update(id) { request in
            try RequestRules.validateComplete(request: request, by: user)
            request.status = .completed
        }
    }

    public nonisolated func changes() -> AsyncStream<Void> {
        broadcaster.stream()
    }

    public func reset() async {
        requests = Self.indexed(seed())
        broadcaster.send()
    }

    // MARK: Helpers

    /// Validates and mutates one request in a single actor turn, so two claims cannot both succeed.
    private func update(_ id: RequestID, _ change: (inout HelpRequest) throws -> Void) async throws -> HelpRequest {
        try await simulateLatency()
        guard var request = requests[id] else { throw FavorlyError.notFound }
        try change(&request)
        requests[id] = request
        broadcaster.send()
        return request
    }

    private func simulateLatency() async throws {
        guard artificialDelay > .zero else { return }
        try await Task.sleep(for: artificialDelay)
    }

    private static func indexed(_ requests: [HelpRequest]) -> [RequestID: HelpRequest] {
        Dictionary(requests.map { ($0.id, $0) }) { _, latest in latest }
    }
}
