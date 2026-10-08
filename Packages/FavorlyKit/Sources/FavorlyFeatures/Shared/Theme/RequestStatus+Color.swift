import FavorlyCore

extension RequestStatus {
    var color: AdaptiveColor {
        switch self {
        case .open: Theme.Colors.statusOpen
        case .claimed: Theme.Colors.statusClaimed
        case .completed: Theme.Colors.neutral
        case .cancelled: Theme.Colors.statusCancelled
        }
    }
}
