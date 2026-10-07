import FavorlyCore

extension RequestCategory {
    var title: String {
        switch self {
        case .ingredient: "Ingredient"
        case .movingHelp: "Moving help"
        case .carHelp: "Car help"
        case .errand: "Errand"
        case .other: "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .ingredient: "carrot"
        case .movingHelp: "shippingbox"
        case .carHelp: "car"
        case .errand: "bag"
        case .other: "hand.raised"
        }
    }
}
