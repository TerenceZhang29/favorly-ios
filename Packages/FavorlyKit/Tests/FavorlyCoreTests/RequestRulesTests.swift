import FavorlyCore
import Testing

struct RequestRulesTests {
    static let allStatuses: [RequestStatus] = [.open, .claimed, .completed, .cancelled]
    static let terminalStatuses: [RequestStatus] = [.completed, .cancelled]

    @Test(arguments: allStatuses, allStatuses)
    func transitionIsAllowedOnlyAlongThePlannedPaths(from: RequestStatus, to: RequestStatus) {
        let allowed: [[RequestStatus]] = [
            [.open, .claimed],
            [.claimed, .completed],
            [.open, .cancelled],
            [.claimed, .cancelled],
        ]
        #expect(RequestRules.canTransition(from: from, to: to) == allowed.contains([from, to]))
    }

    // MARK: Claim

    @Test func anotherUserCanClaimAnOpenRequest() throws {
        try RequestRules.validateClaim(request: .fixture(), by: .helper)
    }

    @Test func requesterCannotClaimTheirOwnRequest() {
        #expect(throws: FavorlyError.cannotClaimOwnRequest) {
            try RequestRules.validateClaim(request: .fixture(), by: .requester)
        }
    }

    @Test func secondClaimThrowsAlreadyClaimed() {
        #expect(throws: FavorlyError.alreadyClaimed) {
            try RequestRules.validateClaim(request: .fixture(status: .claimed), by: .stranger)
        }
    }

    @Test(arguments: terminalStatuses)
    func finishedRequestCannotBeClaimed(status: RequestStatus) {
        #expect(throws: FavorlyError.invalidTransition(from: status, to: .claimed)) {
            try RequestRules.validateClaim(request: .fixture(status: status), by: .stranger)
        }
    }

    // MARK: Cancel

    @Test(arguments: [RequestStatus.open, .claimed])
    func requesterCanCancelAnOpenOrClaimedRequest(status: RequestStatus) throws {
        try RequestRules.validateCancel(request: .fixture(status: status), by: .requester)
    }

    @Test(arguments: [UserID.helper, .stranger])
    func onlyTheRequesterCanCancel(user: UserID) {
        #expect(throws: FavorlyError.notAllowed) {
            try RequestRules.validateCancel(request: .fixture(status: .claimed), by: user)
        }
    }

    @Test(arguments: terminalStatuses)
    func finishedRequestCannotBeCancelled(status: RequestStatus) {
        #expect(throws: FavorlyError.invalidTransition(from: status, to: .cancelled)) {
            try RequestRules.validateCancel(request: .fixture(status: status), by: .requester)
        }
    }

    // MARK: Complete

    @Test(arguments: [UserID.requester, .helper])
    func requesterOrHelperCanCompleteAClaimedRequest(user: UserID) throws {
        try RequestRules.validateComplete(request: .fixture(status: .claimed), by: user)
    }

    @Test func strangerCannotComplete() {
        #expect(throws: FavorlyError.notAllowed) {
            try RequestRules.validateComplete(request: .fixture(status: .claimed), by: .stranger)
        }
    }

    @Test(arguments: [RequestStatus.open, .completed, .cancelled])
    func onlyAClaimedRequestCanBeCompleted(status: RequestStatus) {
        #expect(throws: FavorlyError.invalidTransition(from: status, to: .completed)) {
            try RequestRules.validateComplete(request: .fixture(status: status), by: .requester)
        }
    }
}
