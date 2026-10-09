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
}
