import Foundation

public enum Distance {
    public static let earthRadiusMeters = 6_371_000.0
    public static let metersPerMile = 1609.344

    /// Great-circle distance by the haversine formula.
    public static func meters(from start: GeoPoint, to end: GeoPoint) -> Double {
        let startLatitude = radians(start.latitude)
        let endLatitude = radians(end.latitude)
        let deltaLatitude = endLatitude - startLatitude
        let deltaLongitude = radians(end.longitude - start.longitude)

        let haversine = pow(sin(deltaLatitude / 2), 2)
            + cos(startLatitude) * cos(endLatitude) * pow(sin(deltaLongitude / 2), 2)
        return 2 * earthRadiusMeters * asin(min(1, sqrt(haversine)))
    }

    public static func meters(fromMiles miles: Double) -> Double {
        miles * metersPerMile
    }

    private static func radians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
}
