import FavorlyData
import FavorlyFeatures

extension AppEnvironment {
    /// The prototype's wiring: in-memory mocks seeded with demo data.
    @MainActor
    static func demo(artificialDelay: Duration = .milliseconds(300)) -> AppEnvironment {
        let locationSettings = MockLocationSettings()
        return AppEnvironment(
            repository: MockRequestRepository(artificialDelay: artificialDelay),
            locationProvider: MockLocationProvider(settings: locationSettings),
            session: MockSessionStore(),
            locationSettings: locationSettings
        )
    }
}
