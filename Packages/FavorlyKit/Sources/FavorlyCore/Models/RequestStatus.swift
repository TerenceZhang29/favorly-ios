import Foundation

public enum RequestStatus: String, Codable, Sendable {
    case open, claimed, completed, cancelled
}
