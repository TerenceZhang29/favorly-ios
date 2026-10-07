import FavorlyCore
import FavorlyData
import Testing

struct LocationPresetsTests {
    private func milesFromCornellTech(_ preset: LocationPreset) -> Double {
        Distance.meters(from: LocationPresets.cornellTech.location.point, to: preset.location.point)
            / Distance.metersPerMile
    }

    @Test func fivePresetsWithCornellTechAsTheDefault() {
        #expect(LocationPresets.all.count == 5)
        #expect(Set(LocationPresets.all.map(\.id)).count == 5)
        #expect(LocationPresets.default == LocationPresets.cornellTech)
        #expect(LocationPresets.default.location.label == "Cornell Tech, Roosevelt Island")
    }

    @Test func presetsSitAtThePlannedDistances() {
        #expect(abs(milesFromCornellTech(LocationPresets.rooseveltIslandNorth) - 1.4) < 0.1)
        #expect(abs(milesFromCornellTech(LocationPresets.midtownEast) - 0.6) < 0.1)
        #expect(milesFromCornellTech(LocationPresets.ithaca) > 100)
    }
}
