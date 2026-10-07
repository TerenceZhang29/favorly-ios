import Foundation

@MainActor
public protocol SessionStore: AnyObject, Sendable {
    var currentUser: UserProfile { get }
    var availableUsers: [UserProfile] { get }
    func switchUser(to id: UserID)
}
