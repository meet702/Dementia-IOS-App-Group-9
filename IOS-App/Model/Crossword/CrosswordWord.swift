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
