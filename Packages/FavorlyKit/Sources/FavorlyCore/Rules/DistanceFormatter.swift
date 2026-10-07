import Foundation

public enum DistanceFormatter {
    /// Formats a distance in meters as miles rounded to 0.1, such as "0.4 mi", or "< 0.1 mi".
    public static func miles(_ meters: Double) -> String {
        let miles = meters / Distance.metersPerMile
        guard miles >= 0.1 else { return "< 0.1 mi" }
        return String(format: "%.1f mi", miles)
    }

    /// The same distance spelled out for VoiceOver, such as "0.4 miles" or "less than 0.1 miles".
    public static func spokenMiles(_ meters: Double) -> String {
        let miles = meters / Distance.metersPerMile
        guard miles >= 0.1 else { return "less than 0.1 miles" }
        return String(format: "%.1f miles", miles)
    }
}
