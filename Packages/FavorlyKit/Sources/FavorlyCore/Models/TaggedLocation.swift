import Foundation

public struct TaggedLocation: Hashable, Codable, Sendable {
    public let point: GeoPoint
    /// A neighborhood-level name such as "Roosevelt Island", never a full street address.
    public let label: String

    public init(point: GeoPoint, label: String) {
        self.point = point
        self.label = label
    }
}
