import Foundation

/// A named place the fake location can be set to.
public struct LocationPreset: Identifiable, Hashable, Sendable {
    public let id: String
    public let location: TaggedLocation

    public init(id: String, location: TaggedLocation) {
        self.id = id
        self.location = location
    }
}
