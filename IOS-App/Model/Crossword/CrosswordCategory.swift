import Foundation

enum CrosswordCategory: String {
    case countries = "Countries"
    case dailyObjects = "Daily Objects"
    case gk = "GK"
    case food = "Food"

    var data: [CrosswordData] {
        switch self {
        case .countries:
            return allCountries
        case .dailyObjects:
            return dailyObjectsData
        case .gk:
            return gkData
        case .food:
            return foodData
        }
    }
}
