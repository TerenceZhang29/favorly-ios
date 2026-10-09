import FavorlyCore
import FavorlyData
import Foundation
import Testing

struct MockReviewRepositoryTests {
    static let now = Date(timeIntervalSince1970: 1_000_000)

    let repository = MockRequestRepository(
        seed: { DemoRequests.all(now: now) },
        reviewSeed: { DemoReviews.all(now: now) },
        artificialDelay: .zero,
        now: { now }
    )

    @Test func reviewsAboutAUserAreNewestFirst() async throws {
        let aboutBea = try await repository.reviews(about: DemoUsers.bea.id)
        #expect(aboutBea.map(\.requestID) == (13 ... 16).map { DemoRequests.id($0) })
        #expect(aboutBea.map(\.createdAt) == aboutBea.map(\.createdAt).sorted(by: >))
        #expect(aboutBea.allSatisfy { $0.revieweeID == DemoUsers.bea.id })

        #expect(try await repository.reviews(about: DemoUsers.chen.id).map(\.rating) == [4])
        #expect(try await repository.reviews(about: DemoUsers.alex.id).isEmpty)
        #expect(try await repository.reviews(about: DemoUsers.dana.id).isEmpty)
    }

    @Test func reviewForARequestReturnsItOrNil() async throws {
        let review = try await repository.review(for: DemoRequests.id(17))
        #expect(review?.reviewerID == DemoUsers.bea.id)
        #expect(review?.revieweeID == DemoUsers.chen.id)
        #expect(try await repository.review(for: DemoRequests.id(12)) == nil)
        #expect(try await repository.review(for: DemoRequests.id(1)) == nil)
    }

    @Test func reviewForAnUnknownRequestThrowsNotFound() async {
        await #expect(throws: FavorlyError.notFound) {
            try await repository.review(for: RequestID(rawValue: UUID()))
        }
    }

    @Test func resetRestoresTheSeedReviews() async throws {
        let empty = MockRequestRepository(
            seed: { DemoRequests.all(now: Self.now) },
            reviewSeed: { [] },
            artificialDelay: .zero,
            now: { Self.now }
        )
        #expect(try await empty.reviews(about: DemoUsers.bea.id).isEmpty)
        await empty.reset()
        #expect(try await empty.reviews(about: DemoUsers.bea.id).isEmpty)

        await repository.reset()
        #expect(try await repository.reviews(about: DemoUsers.bea.id).count == 4)
    }

    @Test func theDefaultSeedIncludesTheDemoReviews() async throws {
        let demo = MockRequestRepository(artificialDelay: .zero)
        #expect(try await demo.kindnessSummary(for: DemoUsers.bea.id).lifetimePoints == 90)
        #expect(try await demo.reviews(about: DemoUsers.bea.id).count == 4)
    }

    // MARK: Submitting

    private let fiveStars = NewReviewDraft(rating: 5, comment: "  Fast and friendly ")

    @Test func theRequesterReviewsTheHelperOfTheSaffronRequest() async throws {
        let saffron = DemoRequests.id(12)
        let review = try await repository.submitReview(fiveStars, for: saffron, by: DemoUsers.dana.id)

        #expect(review.requestID == saffron)
        #expect(review.reviewerID == DemoUsers.dana.id)
        #expect(review.revieweeID == DemoUsers.bea.id)
        #expect(review.rating == 5)
        #expect(review.comment == "Fast and friendly")
        #expect(review.createdAt == Self.now)
        #expect(try await repository.review(for: saffron) == review)
        #expect(try await repository.reviews(about: DemoUsers.bea.id).first == review)
    }

    @Test func theStarBonusReachesTheHelpersScore() async throws {
        _ = try await repository.submitReview(fiveStars, for: DemoRequests.id(12), by: DemoUsers.dana.id)
        let summary = try await repository.kindnessSummary(for: DemoUsers.bea.id)
        #expect(summary.lifetimePoints == 100)
        #expect(summary.reviewCount == 5)
    }

    @Test func aSecondReviewThrowsAlreadyReviewed() async throws {
        _ = try await repository.submitReview(fiveStars, for: DemoRequests.id(12), by: DemoUsers.dana.id)
        await #expect(throws: FavorlyError.alreadyReviewed) {
            try await repository.submitReview(fiveStars, for: DemoRequests.id(12), by: DemoUsers.dana.id)
        }
        await #expect(throws: FavorlyError.alreadyReviewed) {
            try await repository.submitReview(fiveStars, for: DemoRequests.id(13), by: DemoUsers.chen.id)
        }
    }

    @Test func onlyTheRequesterOfACompletedRequestCanReview() async {
        await #expect(throws: FavorlyError.notAllowed) {
            try await repository.submitReview(fiveStars, for: DemoRequests.id(12), by: DemoUsers.bea.id)
        }
        await #expect(throws: FavorlyError.notAllowed) {
            try await repository.submitReview(fiveStars, for: DemoRequests.id(6), by: DemoUsers.dana.id)
        }
        await #expect(throws: FavorlyError.notFound) {
            try await repository.submitReview(fiveStars, for: RequestID(rawValue: UUID()), by: DemoUsers.dana.id)
        }
    }

    @Test func aBadDraftThrowsValidation() async throws {
        await #expect(throws: FavorlyError.validation("Choose a rating from 1 to 5 stars.")) {
            try await repository.submitReview(
                NewReviewDraft(rating: 0, comment: ""),
                for: DemoRequests.id(12),
                by: DemoUsers.dana.id
            )
        }
        #expect(try await repository.review(for: DemoRequests.id(12)) == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func changesEmitsOnSubmit() async throws {
        var iterator = repository.changes().makeAsyncIterator()
        _ = try await repository.submitReview(fiveStars, for: DemoRequests.id(12), by: DemoUsers.dana.id)
        #expect(await iterator.next() != nil)
    }

    @Test func resetRemovesSubmittedReviews() async throws {
        _ = try await repository.submitReview(fiveStars, for: DemoRequests.id(12), by: DemoUsers.dana.id)
        await repository.reset()
        #expect(try await repository.review(for: DemoRequests.id(12)) == nil)
        #expect(try await repository.reviews(about: DemoUsers.bea.id).count == 4)
    }
}
