import FavorlyCore
import Testing

struct DistanceFormatterTests {
    @Test(arguments: [
        (0.0, "< 0.1 mi"),
        (100.0, "< 0.1 mi"),
        (160.9, "< 0.1 mi"),
        (161.0, "0.1 mi"),
        (643.7376, "0.4 mi"),
        (1609.344, "1.0 mi"),
        (2333.5, "1.4 mi"),
        (282_000.0, "175.2 mi"),
    ])
    func metersAreShownAsMilesRoundedToOneDecimal(meters: Double, expected: String) {
        #expect(DistanceFormatter.miles(meters) == expected)
    }
}
