import Foundation

public struct NearbyRequest: Identifiable, Hashable, Sendable {
    public let request: HelpRequest
    public let distanceMeters: Double
    public var id: RequestID { request.id }

    public init(request: HelpRequest, distanceMeters: Double) {
        self.request = request
        self.distanceMeters = distanceMeters
    }
}
