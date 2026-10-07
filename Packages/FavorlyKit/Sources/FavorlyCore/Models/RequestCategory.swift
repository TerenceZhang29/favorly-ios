import Foundation

public enum RequestCategory: String, CaseIterable, Codable, Sendable {
    case ingredient, movingHelp, carHelp, errand, other
}
