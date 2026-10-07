import FavorlyCore
import Observation

@MainActor
@Observable
final class PreviewLocationSettings: LocationSettings {
    let presets: [LocationPreset]
    var selectedPreset: LocationPreset
    var simulatesError = false

    init(preset: LocationPreset) {
        presets = [preset]
        selectedPreset = preset
    }
}
