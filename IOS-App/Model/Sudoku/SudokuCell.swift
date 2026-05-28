import Foundation

struct SudokuCellModel {
    var value: Int?
    var isGiven: Bool
    var isConflict: Bool
    init(value: Int? = nil, isGiven: Bool = false) {
        self.value = value
        self.isGiven = isGiven
        self.isConflict = false
    }
}
