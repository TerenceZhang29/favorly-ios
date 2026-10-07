import FavorlyCore
import Observation

@MainActor
@Observable
final class NearbyViewModel {
    enum State: Equatable {
        case loading
        case loaded([NearbyRequest])
        case empty
        case failed(String)
    }

    /// Everything that should trigger a fresh load when it changes.
    struct ReloadKey: Hashable {
        let preset: LocationPreset
        let simulatesError: Bool
        let radius: RadiusOption
    }

    private(set) var state: State = .loading
    var radius = RadiusOption.default

    @ObservationIgnored private let environment: AppEnvironment
    @ObservationIgnored private var latestLoad = 0

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    var reloadKey: ReloadKey {
        ReloadKey(
            preset: environment.locationSettings.selectedPreset,
            simulatesError: environment.locationSettings.simulatesError,
            radius: radius
        )
    }

    /// "7 requests", or nil when there is no list to count.
    var countText: String? {
        guard case let .loaded(results) = state else { return nil }
        return results.count == 1 ? "1 request" : "\(results.count) requests"
    }

    var emptyMessage: String {
        "No requests within \(radius.title)"
    }

    func isOwn(_ request: HelpRequest) -> Bool {
        request.requesterID == environment.session.currentUser.id
    }

    func requesterName(for request: HelpRequest) -> String {
        environment.session.displayName(for: request.requesterID)
    }

    /// Loads requests around the current location. An existing list stays visible while it reloads.
    func load() async {
        latestLoad += 1
        let load = latestLoad
        if case .failed = state {
            state = .loading
        }

        do {
            let location = try await environment.locationProvider.currentLocation()
            let results = try await environment.repository.nearby(around: location.point, radiusMeters: radius.meters)
            guard load == latestLoad else { return }
            state = results.isEmpty ? .empty : .loaded(results)
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
