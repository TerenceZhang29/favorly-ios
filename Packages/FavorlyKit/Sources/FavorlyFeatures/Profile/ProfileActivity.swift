import FavorlyCore

/// A completed request on a profile, and whether the profile's user helped or asked.
struct ProfileActivity: Identifiable, Hashable, Sendable {
    enum Role: Hashable, Sendable {
        case helped
        case asked

        var title: String {
            switch self {
            case .helped: "Helped"
            case .asked: "Asked"
            }
        }
    }

    let request: HelpRequest
    let role: Role

    var id: RequestID { request.id }
}
