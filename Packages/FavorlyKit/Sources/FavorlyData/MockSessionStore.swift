import FavorlyCore
import Observation

@MainActor
@Observable
public final class MockSessionStore: SessionStore {
    public let availableUsers: [UserProfile]
    public private(set) var currentUser: UserProfile

    public init(availableUsers: [UserProfile] = DemoUsers.all, currentUser: UserProfile = DemoUsers.alex) {
        self.availableUsers = availableUsers
        self.currentUser = currentUser
    }

    /// Does nothing if `id` is not one of `availableUsers`.
    public func switchUser(to id: UserID) {
        guard let user = availableUsers.first(where: { $0.id == id }) else { return }
        currentUser = user
    }
}
