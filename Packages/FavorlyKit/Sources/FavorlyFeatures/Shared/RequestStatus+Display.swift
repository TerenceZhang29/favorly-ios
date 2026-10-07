import FavorlyCore

extension RequestStatus {
    var title: String {
        switch self {
        case .open: "Open"
        case .claimed: "Claimed"
        case .completed: "Completed"
        case .cancelled: "Cancelled"
        }
    }
}
