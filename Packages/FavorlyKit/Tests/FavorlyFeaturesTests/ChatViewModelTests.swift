import FavorlyCore
import FavorlyData
@testable import FavorlyFeatures
import Foundation
import Testing

@MainActor
struct ChatViewModelTests {
    let world = TestWorld()

    /// The ladder request (6): Dana asked, Chen is helping.
    private func loaded(as user: UserProfile, _ id: RequestID = TestWorld.ladderID) async -> ChatViewModel {
        world.session.switchUser(to: user.id)
        let viewModel = ChatViewModel(requestID: id, environment: world.environment)
        await viewModel.load()
        return viewModel
    }

    @Test func startsLoadingThenShowsAnEmptyThread() async {
        world.session.switchUser(to: DemoUsers.chen.id)
        let viewModel = ChatViewModel(requestID: TestWorld.ladderID, environment: world.environment)
        #expect(viewModel.state == .loading)
        #expect(!viewModel.canSend)

        await viewModel.load()
        #expect(viewModel.messages == [])
        #expect(viewModel.title == "Hold a ladder while I change a bulb")
        #expect(viewModel.isOpenForSending)
        #expect(viewModel.closedText == nil)
    }

    @Test func sendRequiresText() async {
        let viewModel = await loaded(as: DemoUsers.chen)
        #expect(!viewModel.canSend)
        viewModel.draft = "   "
        #expect(!viewModel.canSend)
        #expect(viewModel.draftMessage == nil)
        viewModel.draft = "On my way"
        #expect(viewModel.canSend)
        #expect(viewModel.draftCountText == "9 / 500")
    }

    @Test func aTooLongDraftExplainsWhy() async {
        let viewModel = await loaded(as: DemoUsers.chen)
        viewModel.draft = String(repeating: "a", count: 501)
        #expect(!viewModel.canSend)
        #expect(viewModel.draftMessage == "Message must be 500 characters or fewer.")
    }

    @Test func sendingAddsTheMessageAndClearsTheDraft() async {
        let viewModel = await loaded(as: DemoUsers.chen)
        viewModel.draft = "On my way"
        await viewModel.send()

        #expect(viewModel.draft.isEmpty)
        #expect(viewModel.sendError == nil)
        let message = viewModel.messages?.first
        #expect(viewModel.messages?.map(\.text) == ["On my way"])
        #expect(message.map(viewModel.isMine) == true)
        #expect(message.map(viewModel.senderName) == "You")
    }

    @Test func theOtherPersonSeesTheMessageWithTheSendersName() async throws {
        _ = try await world.repository.send("On my way", in: TestWorld.ladderID, by: DemoUsers.chen.id)
        let viewModel = await loaded(as: DemoUsers.dana)
        let message = try #require(viewModel.messages?.first)
        #expect(!viewModel.isMine(message))
        #expect(viewModel.senderName(of: message) == "Chen")
    }

    @Test func aNonParticipantGetsAnError() async {
        let viewModel = await loaded(as: DemoUsers.alex)
        #expect(viewModel.state == .failed("You're not allowed to do that."))
        #expect(!viewModel.isOpenForSending)
    }

    @Test func aCompletedThreadIsReadOnly() async throws {
        _ = try await world.repository.send("On my way", in: TestWorld.ladderID, by: DemoUsers.chen.id)
        _ = try await world.repository.complete(TestWorld.ladderID, by: DemoUsers.dana.id)
        let viewModel = await loaded(as: DemoUsers.dana)
        #expect(viewModel.messages?.count == 1)
        #expect(!viewModel.isOpenForSending)
        #expect(viewModel.closedText == "This request is completed. The conversation is read-only.")
        viewModel.draft = "Thanks"
        #expect(!viewModel.canSend)
    }

    @Test func aCancelledThreadSaysSo() async throws {
        _ = try await world.repository.cancel(TestWorld.ladderID, by: DemoUsers.dana.id)
        let viewModel = await loaded(as: DemoUsers.chen)
        #expect(viewModel.closedText == "This request was cancelled. The conversation is read-only.")
    }

    @Test func aSendThatFailsShowsTheMessageAndKeepsTheDraft() async throws {
        let viewModel = await loaded(as: DemoUsers.chen)
        viewModel.draft = "On my way"
        // The requester completes the request in another window before Chen sends.
        _ = try await world.repository.complete(TestWorld.ladderID, by: DemoUsers.dana.id)
        await viewModel.send()
        #expect(viewModel.sendError == "You're not allowed to do that.")
        #expect(viewModel.draft == "On my way")
        #expect(viewModel.closedText != nil)
    }

    @Test func aReplyAppearsWithoutAManualRefresh() async throws {
        let viewModel = await loaded(as: DemoUsers.chen)
        let observing = Task { await viewModel.observeChanges() }
        defer { observing.cancel() }
        await Task.yield()

        _ = try await world.repository.send("See you soon", in: TestWorld.ladderID, by: DemoUsers.dana.id)
        #expect(await TestWorld.eventually { viewModel.messages?.map(\.text) == ["See you soon"] })
    }

    @Test func messagesStayOldestFirst() async throws {
        _ = try await world.repository.send("First", in: TestWorld.ladderID, by: DemoUsers.chen.id)
        _ = try await world.repository.send("Second", in: TestWorld.ladderID, by: DemoUsers.dana.id)
        let viewModel = await loaded(as: DemoUsers.chen)
        #expect(viewModel.messages?.map(\.text) == ["First", "Second"])
    }

    @Test func reloadKeyFollowsTheCurrentUser() async {
        let viewModel = await loaded(as: DemoUsers.chen)
        world.session.switchUser(to: DemoUsers.dana.id)
        #expect(viewModel.reloadKey == DemoUsers.dana.id)
        await viewModel.load()
        #expect(viewModel.isOpenForSending)
    }
}
