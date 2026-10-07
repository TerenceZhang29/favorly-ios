import FavorlyCore

extension SessionStore {
    /// "Open", "Claimed by Bea", "Completed" or "Cancelled".
    func statusText(for request: HelpRequest) -> String {
        if request.status == .claimed, let helperID = request.helperID {
            return "Claimed by \(displayName(for: helperID))"
        }
        return request.status.title
    }
}
