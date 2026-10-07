import FavorlyCore

enum RadiusOption: Double, CaseIterable, Identifiable, Sendable {
    case quarterMile = 0.25
    case halfMile = 0.5
    case oneMile = 1
    case threeMiles = 3

    static let `default` = RadiusOption.oneMile

    var id: Double { rawValue }
    var miles: Double { rawValue }
    var meters: Double { Distance.meters(fromMiles: miles) }

    var title: String {
        switch self {
        case .quarterMile: "0.25 mi"
        case .halfMile: "0.5 mi"
        case .oneMile: "1 mi"
        case .threeMiles: "3 mi"
        }
    }
}
