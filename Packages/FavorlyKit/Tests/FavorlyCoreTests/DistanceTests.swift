import FavorlyCore
import Testing

struct DistanceTests {
    static let cornellTech = GeoPoint(latitude: 40.7553, longitude: -73.9562)
    static let midtownEast = GeoPoint(latitude: 40.7549, longitude: -73.9680)

    private func isWithinOnePercent(_ actual: Double, of expected: Double) -> Bool {
        abs(actual - expected) <= expected * 0.01
    }

    @Test func cornellTechToMidtownEastIsAboutOneKilometer() {
        let meters = Distance.meters(from: Self.cornellTech, to: Self.midtownEast)
        #expect(isWithinOnePercent(meters, of: 995))
    }

    @Test func oneDegreeOfLongitudeAtTheEquator() {
        let meters = Distance.meters(
            from: GeoPoint(latitude: 0, longitude: 0),
            to: GeoPoint(latitude: 0, longitude: 1)
        )
        #expect(isWithinOnePercent(meters, of: 111_195))
    }

    @Test func oppositeSidesOfTheEarthAreHalfTheCircumferenceApart() {
        let meters = Distance.meters(
            from: GeoPoint(latitude: 0, longitude: 0),
            to: GeoPoint(latitude: 0, longitude: 180)
        )
        #expect(isWithinOnePercent(meters, of: .pi * Distance.earthRadiusMeters))
    }

    @Test func distanceToTheSamePointIsZero() {
        #expect(Distance.meters(from: Self.cornellTech, to: Self.cornellTech) == 0)
    }

    @Test func distanceIsSymmetric() {
        let there = Distance.meters(from: Self.cornellTech, to: Self.midtownEast)
        let back = Distance.meters(from: Self.midtownEast, to: Self.cornellTech)
        #expect(abs(there - back) < 0.001)
    }

    @Test func milesConvertToMeters() {
        #expect(Distance.meters(fromMiles: 1) == 1609.344)
        #expect(Distance.meters(fromMiles: 0.25) == 402.336)
    }
}
