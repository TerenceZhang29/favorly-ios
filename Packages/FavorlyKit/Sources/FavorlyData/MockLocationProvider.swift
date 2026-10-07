import FavorlyCore

/// Returns whichever preset is selected in the settings it was built with.
public struct MockLocationProvider: LocationProvider {
    private let settings: MockLocationSettings

    public init(settings: MockLocationSettings) {
        self.settings = settings
    }

    public func currentLocation() async throws -> TaggedLocation {
        try await MainActor.run {
            guard !settings.simulatesError else { throw FavorlyError.locationUnavailable }
            return settings.selectedPreset.location
        }
    }
}
