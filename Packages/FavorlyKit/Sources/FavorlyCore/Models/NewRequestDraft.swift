import Foundation

public struct NewRequestDraft: Sendable {
    public var title: String
    public var details: String
    public var category: RequestCategory
    public var location: TaggedLocation

    public init(title: String, details: String, category: RequestCategory, location: TaggedLocation) {
        self.title = title
        self.details = details
        self.category = category
        self.location = location
    }
}
