import FavorlyCore
import Foundation
import Testing

struct KindnessRulesTests {
    private func review(of request: HelpRequest, rating: Int) -> Review {
        Review(
            id: ReviewID(rawValue: UUID()),
            requestID: request.id,
            reviewerID: request.requesterID,
            revieweeID: .helper,
            rating: rating,
            comment: "",
            createdAt: Date(timeIntervalSince1970: 120)
        )
    }

    private func redemption(points: Int = KindnessRules.giftCardCost) -> Redemption {
        Redemption(
            id: RedemptionID(rawValue: UUID()),
            userID: .helper,
            points: points,
            code: "FAVORLY-0001",
            createdAt: Date(timeIntervalSince1970: 180)
        )
    }

    private func summary(
        _ requests: [HelpRequest],
        reviews: [Review] = [],
        redemptions: [Redemption] = []
    ) -> KindnessSummary {
        KindnessRules.summary(completedAsHelper: requests, reviews: reviews, redemptions: redemptions)
    }

    // MARK: Points

    @Test func noHistoryMeansZero() {
        let empty = summary([])
        #expect(empty == KindnessSummary(
            completedFavors: 0,
            reviewCount: 0,
            averageRating: nil,
            lifetimePoints: 0,
            redeemedPoints: 0
        ))
        #expect(empty.availablePoints == 0)
    }

    @Test func eachCompletedFavorEarnsTenPoints() {
        let result = summary([.fixture(status: .completed), .fixture(status: .completed)])
        #expect(result.completedFavors == 2)
        #expect(result.lifetimePoints == 20)
        #expect(result.reviewCount == 0)
        #expect(result.averageRating == nil)
    }

    @Test(arguments: [RequestStatus.open, .claimed, .cancelled])
    func onlyCompletedRequestsCount(status: RequestStatus) {
        let request = HelpRequest.fixture(status: status)
        let result = summary([request], reviews: [review(of: request, rating: 5)])
        #expect(result.completedFavors == 0)
        #expect(result.reviewCount == 0)
        #expect(result.lifetimePoints == 0)
    }

    @Test(arguments: 1 ... 5)
    func eachStarEarnsTwoPoints(rating: Int) {
        let request = HelpRequest.fixture(status: .completed)
        let result = summary([request], reviews: [review(of: request, rating: rating)])
        #expect(result.lifetimePoints == 10 + 2 * rating)
        #expect(result.reviewCount == 1)
        #expect(result.averageRating == Double(rating))
    }

    @Test func oneFavorIsWorthTenToTwentyPoints() {
        let request = HelpRequest.fixture(status: .completed)
        #expect(summary([request]).lifetimePoints == 10)
        #expect(summary([request], reviews: [review(of: request, rating: 5)]).lifetimePoints == 20)
    }

    @Test func averageRatingIsTheMeanOfCountedReviews() {
        let first = HelpRequest.fixture(status: .completed)
        let second = HelpRequest.fixture(status: .completed)
        let result = summary([first, second], reviews: [review(of: first, rating: 5), review(of: second, rating: 4)])
        #expect(result.reviewCount == 2)
        #expect(result.averageRating == 4.5)
        #expect(result.lifetimePoints == 20 + 18)
    }

    @Test func reviewsOfOtherRequestsAreIgnored() {
        let helped = HelpRequest.fixture(status: .completed)
        let elsewhere = HelpRequest.fixture(status: .completed)
        let result = summary([helped], reviews: [review(of: elsewhere, rating: 5)])
        #expect(result.reviewCount == 0)
        #expect(result.lifetimePoints == 10)
    }

    // MARK: Lifetime and available

    @Test func redeemingLowersAvailableButNotLifetimePoints() {
        let requests = (0 ..< 12).map { _ in HelpRequest.fixture(status: .completed) }
        let result = summary(requests, redemptions: [redemption()])
        #expect(result.lifetimePoints == 120)
        #expect(result.redeemedPoints == 100)
        #expect(result.availablePoints == 20)
    }

    @Test func redeemedPointsAddUp() {
        let result = summary([], redemptions: [redemption(), redemption(points: 50)])
        #expect(result.redeemedPoints == 150)
        #expect(result.availablePoints == -150)
    }

    // MARK: Redeem

    @Test func redeemNeedsOneHundredAvailablePoints() throws {
        let at99 = KindnessSummary(
            completedFavors: 0,
            reviewCount: 0,
            averageRating: nil,
            lifetimePoints: 199,
            redeemedPoints: 100
        )
        #expect(throws: FavorlyError.notEnoughPoints) { try KindnessRules.validateRedeem(at99) }

        let at100 = KindnessSummary(
            completedFavors: 0,
            reviewCount: 0,
            averageRating: nil,
            lifetimePoints: 100,
            redeemedPoints: 0
        )
        try KindnessRules.validateRedeem(at100)
    }

    @Test func rewardCodesCountUpWithFourDigits() {
        #expect(KindnessRules.rewardCode(number: 1) == "FAVORLY-0001")
        #expect(KindnessRules.rewardCode(number: 2) == "FAVORLY-0002")
        #expect(KindnessRules.rewardCode(number: 42) == "FAVORLY-0042")
        #expect(KindnessRules.rewardCode(number: 12345) == "FAVORLY-12345")
    }

    @Test func pointValuesMatchThePlan() {
        #expect(KindnessRules.pointsPerFavor == 10)
        #expect(KindnessRules.pointsPerStar == 2)
        #expect(KindnessRules.giftCardCost == 100)
    }
}
