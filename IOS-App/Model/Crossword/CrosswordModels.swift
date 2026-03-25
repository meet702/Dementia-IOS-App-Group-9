import Foundation

public struct CrosswordData: Codable {
    let name: String
    let clue: String
}

struct CrosswordCategoryData: Codable {
    let countries: [CrosswordData]
    let dailyObjects: [CrosswordData]
    let food: [CrosswordData]
    let gk: [CrosswordData]
}

enum CrosswordDirection {
    case across
    case down
}

struct CrosswordWord {
    let number: Int
    let answer: String
    let clue: String
    let startIndex: Int
    let direction: CrosswordDirection

    var globalDirection: GlobalDirection {
        return direction == .across ? .across : .down
    }
}

struct CrosswordCell {
    let index: Int
    let row: Int
    let col: Int

    var numbers: [Int] = []
    var letter: Character?
    var correctLetter: Character?

    var isBlocked: Bool
    var isHighlighted: Bool

    var isCorrectLetter: Bool
    var isCorrectWord: Bool
    var isWrongLetter: Bool
    
    var isSelected: Bool = false

}

enum CrosswordCategory: String {
    case countries = "Countries"
    case dailyObjects = "Daily Objects"
    case gk = "GK"
    case food = "Food"
    
    var data: [CrosswordData] {
        guard let data = loadCrosswordData() else {
            print("No data found in UserDefaults")
            return []
        }

        switch self {
        case .countries:
            return data.countries
        case .dailyObjects:
            return data.dailyObjects
        case .gk:
            return data.gk
        case .food:
            return data.food
        }
    }
}
