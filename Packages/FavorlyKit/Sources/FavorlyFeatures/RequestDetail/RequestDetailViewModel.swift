import FavorlyCore
import Observation

@MainActor
@Observable
final class RequestDetailViewModel {
    enum State: Equatable {
        case loading
        case loaded(HelpRequest)
        case failed(String)
    }

    let requestID: RequestID
    private(set) var state: State = .loading
    /// Rounded distance from the current location, or nil when the location is unavailable.
    private(set) var distanceText: String?
    /// Why the last pick up, cancel or complete failed.
    private(set) var actionError: String?
    private(set) var isWorking = false
    /// Kindness scores of the requester and the helper, or nil until known. A failed lookup leaves them out.
    private(set) var requesterScore: Int?
    private(set) var helperScore: Int?

    @ObservationIgnored private let environment: AppEnvironment

    init(requestID: RequestID, environment: AppEnvironment) {
        self.requestID = requestID
        self.environment = environment
    }

    var request: HelpRequest? {
        guard case let .loaded(request) = state else { return nil }
        return request
    }

    // MARK: What the current user sees

    var isOwn: Bool {
        request?.requesterID == currentUserID
    }

    var requesterName: String {
        guard let request else { return "" }
        return environment.session.displayName(for: request.requesterID)
    }

    var helperName: String? {
        request?.helperID.map { environment.session.displayName(for: $0) }
    }

    /// "Open", "Claimed by Bea", "Completed" or "Cancelled".
    var statusText: String {
        request.map { environment.session.statusText(for: $0) } ?? ""
    }

    var canPickUp: Bool {
        allows(RequestRules.validateClaim)
    }

    var canCancel: Bool {
        allows(RequestRules.validateCancel)
    }

    var canComplete: Bool {
        allows(RequestRules.validateComplete)
    }

    // MARK: Loading

    /// Loads the request. A request already on screen stays visible while it reloads.
    func load() async {
        do {
            let request = try await environment.repository.request(id: requestID)
            let location = try? await environment.locationProvider.currentLocation()
            distanceText = location.map {
                DistanceFormatter.miles(Distance.meters(from: $0.point, to: request.location.point))
            }
            await loadScores(of: request)
            state = .loaded(request)
        } catch is CancellationError {
            // The screen went away.
        } catch {
            state = .failed(ErrorMessage.text(for: error))
        }
    }

    /// Reloads after every repository write. Runs until the surrounding task is cancelled.
    func observeChanges() async {
        for await _ in environment.repository.changes() {
            await load()
        }
    }

    // MARK: Actions

    func pickUp() async {
        await perform(environment.repository.claim)
    }

    func cancel() async {
        await perform(environment.repository.cancel)
    }

    func complete() async {
        await perform(environment.repository.complete)
    }

    // MARK: Helpers

    private func loadScores(of request: HelpRequest) async {
        requesterScore = await score(of: request.requesterID)
        helperScore = if let helperID = request.helperID { await score(of: helperID) } else { nil }
    }

    private func score(of user: UserID) async -> Int? {
        try? await environment.kindness.kindnessSummary(for: user).lifetimePoints
    }

    private var currentUserID: UserID {
        environment.session.currentUser.id
    }

    private func allows(_ rule: (HelpRequest, UserID) throws -> Void) -> Bool {
        guard let request else { return false }
        return (try? rule(request, currentUserID)) != nil
    }

    private func perform(_ action: (RequestID, UserID) async throws -> HelpRequest) async {
        guard !isWorking else { return }
        isWorking = true
        defer { isWorking = false }
        actionError = nil

        do {
            let request = try await action(requestID, currentUserID)
            await loadScores(of: request)
            state = .loaded(request)
        } catch is CancellationError {
            // The screen went away.
        } catch {
            actionError = ErrorMessage.text(for: error)
            // Show what changed underneath, such as someone else's claim.
            await load()
        }
    }
}
