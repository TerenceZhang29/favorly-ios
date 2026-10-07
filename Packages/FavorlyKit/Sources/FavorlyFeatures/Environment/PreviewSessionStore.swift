import FavorlyCore
import Observation

@MainActor
@Observable
final class PreviewSessionStore: SessionStore {
    let availableUsers: [UserProfile]
    private(set) var currentUser: UserProfile

    init(availableUsers: [UserProfile], currentUser: UserProfile) {
        self.availableUsers = availableUsers
        self.currentUser = currentUser
    }

    func switchUser(to id: UserID) {
        guard let user = availableUsers.first(where: { $0.id == id }) else { return }
        currentUser = user
    }
}
