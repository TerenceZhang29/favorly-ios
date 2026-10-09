import FavorlyData
import FavorlyFeatures

extension AppEnvironment {
    /// The prototype's wiring: in-memory mocks seeded with demo data.
    @MainActor
    static func demo(artificialDelay: Duration = .milliseconds(300)) -> AppEnvironment {
        let locationSettings = MockLocationSettings()
        // One actor serves every repository protocol, so rules that span requests and reviews stay atomic.
        let repository = MockRequestRepository(artificialDelay: artificialDelay)
        return AppEnvironment(
            repository: repository,
            kindness: repository,
            reviews: repository,
            locationProvider: MockLocationProvider(settings: locationSettings),
            session: MockSessionStore(),
            locationSettings: locationSettings
        )
    }
}
