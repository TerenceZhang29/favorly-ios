import FavorlyCore

extension UserID {
    /// One of `Theme.Colors.avatars`, picked by a hash of the ID that is the same on every launch
    /// (Swift's own `hashValue` changes between launches).
    var avatarColor: AdaptiveColor {
        let colors = Theme.Colors.avatars
        let hash = rawValue.unicodeScalars.reduce(UInt32(0)) { $0 &* 33 &+ $1.value }
        return colors[Int(hash % UInt32(colors.count))]
    }
}
