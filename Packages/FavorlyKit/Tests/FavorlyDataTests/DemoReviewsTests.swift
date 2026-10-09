import FavorlyCore
import FavorlyData
import Foundation
import Testing

struct DemoReviewsTests {
    let now = Date(timeIntervalSince1970: 1_000_000)
    var reviews: [Review] { DemoReviews.all(now: now) }
    var requests: [RequestID: HelpRequest] {
        Dictionary(uniqueKeysWithValues: DemoRequests.all(now: now).map { ($0.id, $0) })
    }

    @Test func fiveReviewsWithStableUniqueIDs() {
        #expect(reviews.count == 5)
        #expect(Set(reviews.map(\.id)).count == 5)
        #expect(reviews.map(\.id) == DemoReviews.all(now: now.addingTimeInterval(3600)).map(\.id))
    }

    @Test func historyRequestsAreReviewedButNotTheSaffronRequest() {
        #expect(reviews.map(\.requestID) == (13 ... 17).map { DemoRequests.id($0) })
        #expect(!reviews.contains { $0.requestID == DemoRequests.id(12) })
    }

    @Test func eachReviewIsByTheRequesterAboutTheHelperOfACompletedRequest() throws {
        for review in reviews {
            let request = try #require(requests[review.requestID])
            #expect(request.status == .completed)
            #expect(review.reviewerID == request.requesterID)
            #expect(review.revieweeID == request.helperID)
            #expect(review.createdAt > (request.claimedAt ?? .distantFuture))
            #expect(review.createdAt < now)
        }
    }

    @Test func beaGetsFourFiveStarReviewsAndChenOneFourStar() {
        #expect(reviews.filter { $0.revieweeID == DemoUsers.bea.id }.map(\.rating) == [5, 5, 5, 5])
        #expect(reviews.filter { $0.revieweeID == DemoUsers.chen.id }.map(\.rating) == [4])
        #expect(reviews.allSatisfy { $0.reviewerID != DemoUsers.alex.id && $0.revieweeID != DemoUsers.alex.id })
        #expect(reviews.allSatisfy { !$0.comment.isEmpty && $0.comment.count <= 300 })
    }
}
