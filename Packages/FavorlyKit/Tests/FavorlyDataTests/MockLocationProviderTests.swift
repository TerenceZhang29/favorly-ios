import FavorlyCore
import FavorlyData
import Testing

@MainActor
struct MockLocationProviderTests {
    let settings = MockLocationSettings()
    var provider: MockLocationProvider { MockLocationProvider(settings: settings) }

    @Test func returnsTheDefaultPresetAtFirst() async throws {
        #expect(settings.presets == LocationPresets.all)
        #expect(try await provider.currentLocation() == LocationPresets.cornellTech.location)
    }

    @Test func followsTheSelectedPreset() async throws {
        let provider = provider
        settings.selectedPreset = LocationPresets.ithaca
        #expect(try await provider.currentLocation() == LocationPresets.ithaca.location)
    }

    @Test func throwsLocationUnavailableWhenSimulatingAnError() async {
        settings.simulatesError = true
        await #expect(throws: FavorlyError.locationUnavailable) {
            try await provider.currentLocation()
        }
    }
}
