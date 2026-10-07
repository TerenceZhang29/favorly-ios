import FavorlyCore

public enum LocationPresets {
    public static let cornellTech = preset("cornell-tech", "Cornell Tech, Roosevelt Island", 40.7553, -73.9562)
    public static let rooseveltIslandNorth = preset(
        "roosevelt-island-north",
        "Roosevelt Island north",
        40.7720,
        -73.9406
    )
    public static let longIslandCity = preset("long-island-city", "Long Island City", 40.7447, -73.9485)
    public static let midtownEast = preset("midtown-east", "Midtown East", 40.7549, -73.9680)
    public static let ithaca = preset("ithaca", "Ithaca, NY", 42.4440, -76.5019)

    public static let all = [cornellTech, rooseveltIslandNorth, longIslandCity, midtownEast, ithaca]
    public static let `default` = cornellTech

    private static func preset(_ id: String, _ label: String, _ lat: Double, _ lon: Double) -> LocationPreset {
        LocationPreset(
            id: id,
            location: TaggedLocation(point: GeoPoint(latitude: lat, longitude: lon), label: label)
        )
    }
}
