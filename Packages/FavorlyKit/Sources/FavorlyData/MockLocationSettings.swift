import FavorlyCore
import Observation

@MainActor
@Observable
public final class MockLocationSettings: LocationSettings {
    public let presets: [LocationPreset]
    public var selectedPreset: LocationPreset
    public var simulatesError = false

    public init(
        presets: [LocationPreset] = LocationPresets.all,
        selectedPreset: LocationPreset = LocationPresets.default
    ) {
        self.presets = presets
        self.selectedPreset = selectedPreset
    }
}
