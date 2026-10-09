import FavorlyCore
import Testing

struct ChatRulesTests {
    // MARK: Reading

    @Test func thereIsNoThreadBeforePickUp() {
        #expect(throws: FavorlyError.notAllowed) {
            try ChatRules.validateRead(request: .fixture(), by: .requester)
        }
        #expect(!ChatRules.canRead(request: .fixture(), by: .requester))
    }

    @Test(arguments: [RequestStatus.claimed, .completed])
    func requesterAndHelperCanRead(status: RequestStatus) throws {
        try ChatRules.validateRead(request: .fixture(status: status), by: .requester)
        try ChatRules.validateRead(request: .fixture(status: status), by: .helper)
    }

    @Test func aCancelledPickUpKeepsItsThreadReadable() throws {
        var request = HelpRequest.fixture(status: .claimed)
        request.status = .cancelled
        try ChatRules.validateRead(request: request, by: .helper)
        #expect(!ChatRules.canSend(request: request, by: .helper))
    }

    @Test(arguments: [RequestStatus.claimed, .completed])
    func aNonParticipantCannotRead(status: RequestStatus) {
        #expect(throws: FavorlyError.notAllowed) {
            try ChatRules.validateRead(request: .fixture(status: status), by: .stranger)
        }
    }

    // MARK: Sending

    @Test func participantsCanSendWhileClaimed() throws {
        try ChatRules.validateSend(request: .fixture(status: .claimed), by: .requester)
        try ChatRules.validateSend(request: .fixture(status: .claimed), by: .helper)
        #expect(ChatRules.canSend(request: .fixture(status: .claimed), by: .helper))
    }

    @Test func aCompletedThreadIsReadOnly() {
        #expect(throws: FavorlyError.notAllowed) {
            try ChatRules.validateSend(request: .fixture(status: .completed), by: .requester)
        }
        #expect(ChatRules.canRead(request: .fixture(status: .completed), by: .requester))
        #expect(!ChatRules.canSend(request: .fixture(status: .completed), by: .requester))
    }

    @Test func aNonParticipantCannotSend() {
        #expect(throws: FavorlyError.notAllowed) {
            try ChatRules.validateSend(request: .fixture(status: .claimed), by: .stranger)
        }
        #expect(throws: FavorlyError.notAllowed) {
            try ChatRules.validateSend(request: .fixture(), by: .requester)
        }
    }

    // MARK: Text

    @Test func textIsTrimmed() throws {
        #expect(try ChatRules.validateText("  On my way \n") == "On my way")
    }

    @Test(arguments: ["", "   ", "\n\t"])
    func emptyTextIsRejected(text: String) {
        #expect(throws: FavorlyError.validation("Message can't be empty.")) {
            try ChatRules.validateText(text)
        }
    }

    @Test func textLengthEdges() throws {
        try ChatRules.validateText("k")
        try ChatRules.validateText(String(repeating: "a", count: 500))
        #expect(throws: FavorlyError.validation("Message must be 500 characters or fewer.")) {
            try ChatRules.validateText(String(repeating: "a", count: 501))
        }
    }
}
