import FavorlyCore
import FavorlyData
@testable import FavorlyFeatures
import Testing

@MainActor
struct ReviewFormViewModelTests {
    let world = TestWorld()
    static let saffronID = TestWorld.seedID(12)

    private func makeViewModel(as user: UserProfile = DemoUsers.dana) -> ReviewFormViewModel {
        world.session.switchUser(to: user.id)
        return ReviewFormViewModel(requestID: Self.saffronID, environment: world.environment)
    }

    @Test func submitIsDisabledUntilARatingIsChosen() {
        let viewModel = makeViewModel()
        #expect(viewModel.rating == 0)
        #expect(!viewModel.canSubmit)
        #expect(viewModel.commentMessage == nil)
        viewModel.comment = "Fast and friendly"
        #expect(!viewModel.canSubmit)
        viewModel.rating = 5
        #expect(viewModel.canSubmit)
    }

    @Test func aRatingAloneIsEnough() {
        let viewModel = makeViewModel()
        viewModel.rating = 3
        #expect(viewModel.canSubmit)
    }

    @Test func aTooLongCommentExplainsWhyAndBlocksSubmit() {
        let viewModel = makeViewModel()
        viewModel.rating = 5
        viewModel.comment = String(repeating: "a", count: 301)
        #expect(!viewModel.canSubmit)
        #expect(viewModel.commentMessage == "Comment must be 300 characters or fewer.")
        #expect(viewModel.commentCountText == "301 / 300")
    }

    @Test func theCountFollowsTheComment() {
        let viewModel = makeViewModel()
        #expect(viewModel.commentCountText == "0 / 300")
        viewModel.comment = "Fast and friendly"
        #expect(viewModel.commentCountText == "17 / 300")
    }

    @Test func submittingStoresTheReviewAndRaisesTheHelpersScore() async throws {
        let viewModel = makeViewModel()
        viewModel.rating = 5
        viewModel.comment = "Fast and friendly"

        let review = try #require(await viewModel.submit())

        #expect(review.rating == 5)
        #expect(review.comment == "Fast and friendly")
        #expect(review.revieweeID == DemoUsers.bea.id)
        #expect(viewModel.submitError == nil)
        #expect(try await world.repository.kindnessSummary(for: DemoUsers.bea.id).lifetimePoints == 100)
    }

    @Test func aSecondReviewShowsAlreadyReviewed() async {
        let first = makeViewModel()
        first.rating = 5
        _ = await first.submit()

        let second = ReviewFormViewModel(requestID: Self.saffronID, environment: world.environment)
        second.rating = 4
        #expect(await second.submit() == nil)
        #expect(second.submitError == "You already reviewed this favor.")
    }

    @Test func someoneOtherThanTheRequesterGetsNotAllowed() async {
        let viewModel = makeViewModel(as: DemoUsers.bea)
        viewModel.rating = 5
        #expect(await viewModel.submit() == nil)
        #expect(viewModel.submitError == "You're not allowed to do that.")
    }

    @Test func submitWithoutARatingDoesNothing() async throws {
        let viewModel = makeViewModel()
        #expect(await viewModel.submit() == nil)
        #expect(viewModel.submitError == nil)
        #expect(try await world.repository.review(for: Self.saffronID) == nil)
    }
}
