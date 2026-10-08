import FavorlyCore

extension RequestCategory {
    var color: AdaptiveColor {
        switch self {
        case .ingredient: Theme.Colors.categoryIngredient
        case .movingHelp: Theme.Colors.categoryMoving
        case .carHelp: Theme.Colors.categoryCar
        case .errand: Theme.Colors.categoryErrand
        case .other: Theme.Colors.neutral
        }
    }
}
