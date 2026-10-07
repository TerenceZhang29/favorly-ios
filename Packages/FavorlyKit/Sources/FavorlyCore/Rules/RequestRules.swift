import Foundation

public enum RequestRules {
    /// Status moves only `open → claimed → completed`, plus `open → cancelled` and `claimed → cancelled`.
    public static func canTransition(from: RequestStatus, to: RequestStatus) -> Bool {
        switch (from, to) {
        case (.open, .claimed), (.claimed, .completed), (.open, .cancelled), (.claimed, .cancelled):
            true
        default:
            false
        }
    }

    public static func validateClaim(request: HelpRequest, by user: UserID) throws {
        guard request.requesterID != user else { throw FavorlyError.cannotClaimOwnRequest }
        guard request.status != .claimed else { throw FavorlyError.alreadyClaimed }
        try validateTransition(from: request.status, to: .claimed)
    }

    /// Only the requester can cancel.
    public static func validateCancel(request: HelpRequest, by user: UserID) throws {
        guard request.requesterID == user else { throw FavorlyError.notAllowed }
        try validateTransition(from: request.status, to: .cancelled)
    }

    /// Only the requester or the helper can mark a request completed.
    public static func validateComplete(request: HelpRequest, by user: UserID) throws {
        guard request.requesterID == user || request.helperID == user else { throw FavorlyError.notAllowed }
        try validateTransition(from: request.status, to: .completed)
    }

    private static func validateTransition(from: RequestStatus, to: RequestStatus) throws {
        guard canTransition(from: from, to: to) else {
            throw FavorlyError.invalidTransition(from: from, to: to)
        }
    }
}
