import FavorlyCore
import Foundation
import Testing

struct ReviewRulesTests {
    private func review(of request: HelpRequest) -> Review {
        Review(
            id: ReviewID(rawValue: UUID()),
            requestID: request.id,
            reviewerID: .requester,
            revieweeID: .helper,
            rating: 5,
            comment: "",
            createdAt: Date(timeIntervalSince1970: 120)
        )
    }

    // MARK: Who can review

    @Test func theRequesterCanReviewACompletedRequestOnce() throws {
        let request = HelpRequest.fixture(status: .completed)
        try ReviewRules.validateReviewer(request: request, by: .requester, existing: nil)
        #expect(ReviewRules.canReview(request: request, by: .requester, existing: nil))
    }

    @Test(arguments: [UserID.helper, .stranger])
    func onlyTheRequesterCanReview(user: UserID) {
        #expect(throws: FavorlyError.notAllowed) {
            try ReviewRules.validateReviewer(request: .fixture(status: .completed), by: user, existing: nil)
        }
    }

    @Test(arguments: [RequestStatus.open, .claimed, .cancelled])
    func onlyACompletedRequestCanBeReviewed(status: RequestStatus) {
        #expect(throws: FavorlyError.notAllowed) {
            try ReviewRules.validateReviewer(request: .fixture(status: status), by: .requester, existing: nil)
        }
    }

    @Test func aRequestWithoutAHelperCannotBeReviewed() {
        var request = HelpRequest.fixture(status: .completed)
        request.helperID = nil
        #expect(throws: FavorlyError.notAllowed) {
            try ReviewRules.validateReviewer(request: request, by: .requester, existing: nil)
        }
    }

    @Test func aSecondReviewThrowsAlreadyReviewed() {
        let request = HelpRequest.fixture(status: .completed)
        #expect(throws: FavorlyError.alreadyReviewed) {
            try ReviewRules.validateReviewer(request: request, by: .requester, existing: review(of: request))
        }
        #expect(!ReviewRules.canReview(request: request, by: .requester, existing: review(of: request)))
    }

    // MARK: Draft

    @Test(arguments: 1 ... 5)
    func ratingsFromOneToFiveAreAccepted(rating: Int) throws {
        #expect(try ReviewRules.validate(NewReviewDraft(rating: rating, comment: "")).rating == rating)
    }

    @Test(arguments: [0, 6, -1])
    func ratingsOutsideOneToFiveAreRejected(rating: Int) {
        #expect(throws: FavorlyError.validation("Choose a rating from 1 to 5 stars.")) {
            try ReviewRules.validate(NewReviewDraft(rating: rating, comment: ""))
        }
    }

    @Test func theCommentIsTrimmedAndMayBeEmpty() throws {
        #expect(try ReviewRules.validate(NewReviewDraft(rating: 5, comment: "  Fast and friendly \n")).comment
            == "Fast and friendly")
        #expect(try ReviewRules.validate(NewReviewDraft(rating: 5, comment: "   ")).comment.isEmpty)
    }

    @Test func commentLengthEdges() throws {
        try ReviewRules.validate(NewReviewDraft(rating: 4, comment: String(repeating: "a", count: 300)))
        try ReviewRules.validate(NewReviewDraft(rating: 4, comment: String(repeating: "a", count: 300) + "  "))
        #expect(throws: FavorlyError.validation("Comment must be 300 characters or fewer.")) {
            try ReviewRules.validate(NewReviewDraft(rating: 4, comment: String(repeating: "a", count: 301)))
        }
    }
}
