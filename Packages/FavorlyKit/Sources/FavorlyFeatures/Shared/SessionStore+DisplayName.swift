import FavorlyCore

extension SessionStore {
    func displayName(for id: UserID) -> String {
        availableUsers.first { $0.id == id }?.displayName ?? "A neighbor"
    }
}
