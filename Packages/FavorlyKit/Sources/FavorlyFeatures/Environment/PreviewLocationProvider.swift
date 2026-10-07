import FavorlyCore

struct PreviewLocationProvider: LocationProvider {
    let location: TaggedLocation

    func currentLocation() async throws -> TaggedLocation {
        location
    }
}
