import Foundation

public protocol LocationProvider: Sendable {
    func currentLocation() async throws -> TaggedLocation
}
