import Foundation

enum RootTab: String, CaseIterable, Identifiable, Sendable {
    case nearby
    case post
    case activity
    case profile
    case devSettings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .nearby: "Nearby"
        case .post: "Post"
        case .activity: "My Activity"
        case .profile: "Profile"
        case .devSettings: "Dev Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .nearby: "location"
        case .post: "plus.circle"
        case .activity: "list.bullet"
        case .profile: "person.crop.circle"
        case .devSettings: "gearshape"
        }
    }
}
