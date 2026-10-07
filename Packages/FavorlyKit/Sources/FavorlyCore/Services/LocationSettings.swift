import Foundation

/// The fake location controls the dev settings screen edits.
@MainActor
public protocol LocationSettings: AnyObject {
    var presets: [LocationPreset] { get }
    var selectedPreset: LocationPreset { get set }
    /// When true, the location provider throws `FavorlyError.locationUnavailable`.
    var simulatesError: Bool { get set }
}
