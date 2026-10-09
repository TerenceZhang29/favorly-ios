import FavorlyCore

/// The services every screen works with. The App target decides which implementations go in.
public struct AppEnvironment: Sendable {
    public let repository: any RequestRepository
    public let kindness: any KindnessRepository
    public let reviews: any ReviewRepository
    public let locationProvider: any LocationProvider
    public let session: any SessionStore
    public let locationSettings: any LocationSettings

    public init(
        repository: any RequestRepository,
        kindness: any KindnessRepository,
        reviews: any ReviewRepository,
        locationProvider: any LocationProvider,
        session: any SessionStore,
        locationSettings: any LocationSettings
    ) {
        self.repository = repository
        self.kindness = kindness
        self.reviews = reviews
        self.locationProvider = locationProvider
        self.session = session
        self.locationSettings = locationSettings
    }

    /// Who is signed in and where they are, such as "Alex @ Cornell Tech, Roosevelt Island".
    @MainActor public var debugSummary: String {
        "\(session.currentUser.displayName) @ \(locationSettings.selectedPreset.location.label)"
    }
}
