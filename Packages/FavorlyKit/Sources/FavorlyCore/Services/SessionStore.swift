import Foundation

@MainActor
public protocol SessionStore: AnyObject {
    var currentUser: UserProfile { get }
    var availableUsers: [UserProfile] { get }
    func switchUser(to id: UserID)
}
