import FavorlyCore
import Observation

@MainActor
@Observable
final class ActivityViewModel {
    enum State: Equatable {
        case loading
        case loaded(posted: [HelpRequest], pickedUp: [HelpRequest])
        case failed(String)
    }

    private(set) var state: State = .loading
    var segment = ActivitySegment.posted

    @ObservationIgnored private let environment: AppEnvironment
    @ObservationIgnored private var latestLoad = 0

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    /// Changes when the user is switched, which should trigger a fresh load.
    var reloadKey: UserID {
        environment.session.currentUser.id
    }

    /// The requests in the selected segment, or nil until they have loaded.
    var items: [HelpRequest]? {
        guard case let .loaded(posted, pickedUp) = state else { return nil }
        return segment == .posted ? posted : pickedUp
    }

    /// The line under a request's title: its status, and who posted it when that is someone else.
    func subtitle(for request: HelpRequest) -> String {
        let status = environment.session.statusText(for: request)
        guard request.requesterID != environment.session.currentUser.id else { return status }
        return "\(status) · Posted by \(environment.session.displayName(for: request.requesterID))"
    }

    /// Loads both segments for the current user. Lists already on screen stay visible while they reload.
    func load() async {
        latestLoad += 1
        let load = latestLoad
        let user = environment.session.currentUser.id
        if case .failed = state {
            state = .loading
        }

        do {
            let posted = try await environment.repository.requests(postedBy: user)
            let pickedUp = try await environment.repository.requests(claimedBy: user)
            guard load == latestLoad else { return }
            state = .loaded(posted: posted, pickedUp: pickedUp)
        } catch is CancellationError {
            // A newer load replaced this one.
        } catch {
            guard load == latestLoad else { return }
            state = .failed(ErrorMessage.text(for: error))
        }
    }

    /// Reloads after every repository write. Runs until the surrounding task is cancelled.
    func observeChanges() async {
        for await _ in environment.repository.changes() {
            await load()
        }
    }
}
