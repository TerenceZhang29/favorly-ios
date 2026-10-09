import FavorlyCore
import Foundation

public enum DemoReviews {
    /// Reviews of the completed history requests 13–17. The saffron request (12) has none yet, so Dana can leave one.
    ///
    /// Each review comes a few hours after its request was claimed. Bea starts with 5 favors and 20 stars
    /// (90 points), Chen with 1 favor and 4 stars (18 points).
    public static func all(now: Date = Date()) -> [Review] {
        let bea = DemoUsers.bea.id
        let chen = DemoUsers.chen.id
        let dana = DemoUsers.dana.id

        return [
            Seed(1, request: 13, chen, about: bea, 5, "Watered everything and sent a photo. Thanks!", daysAgo: 1.25),
            Seed(2, request: 14, dana, about: bea, 5, "Quick, cheerful and careful with the eggs.", daysAgo: 1.75),
            Seed(3, request: 15, chen, about: bea, 5, "Brought the drill bits too. Lifesaver.", daysAgo: 2.25),
            Seed(4, request: 16, dana, about: bea, 5, "Saved my cookies. Brought extra sugar!", daysAgo: 2.75),
            Seed(5, request: 17, bea, about: chen, 4, "Checked all four tires and the spare.", daysAgo: 0.75),
        ].map { $0.review(now: now) }
    }

    private struct Seed {
        let number: UInt8
        let request: UInt8
        let reviewer: UserID
        let reviewee: UserID
        let rating: Int
        let comment: String
        let daysAgo: Double

        init(
            _ number: UInt8,
            request: UInt8,
            _ reviewer: UserID,
            about reviewee: UserID,
            _ rating: Int,
            _ comment: String,
            daysAgo: Double
        ) {
            self.number = number
            self.request = request
            self.reviewer = reviewer
            self.reviewee = reviewee
            self.rating = rating
            self.comment = comment
            self.daysAgo = daysAgo
        }

        func review(now: Date) -> Review {
            Review(
                id: ReviewID(rawValue: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, number))),
                requestID: DemoRequests.id(request),
                reviewerID: reviewer,
                revieweeID: reviewee,
                rating: rating,
                comment: comment,
                createdAt: now.addingTimeInterval(-daysAgo * 24 * 60 * 60)
            )
        }
    }
}
