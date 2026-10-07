import Foundation

public struct GeoPoint: Hashable, Codable, Sendable {
    /// Degrees, -90...90.
    public let latitude: Double
    /// Degrees, -180...180.
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
