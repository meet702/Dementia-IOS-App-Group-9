enum GlobalDirection {
    case across
    case down
}

final class CrosswordGameState {
    var selectedWord: CrosswordWord?
    var selectedCellIndex: Int = 0
    var selectedDirection: GlobalDirection = .across
}
