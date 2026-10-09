import Foundation

public struct NewReviewDraft: Sendable {
    /// 1...5
    public var rating: Int
    public var comment: String

    public init(rating: Int, comment: String) {
        self.rating = rating
        self.comment = comment
    }
}
