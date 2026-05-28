import Foundation

struct SudokuBoard {
    var cells: [SudokuCellModel] = Array(repeating: SudokuCellModel(), count: 81)

    static let size = 9

    func index(row: Int, col: Int) -> Int { row * SudokuBoard.size + col }

    subscript(row: Int, col: Int) -> SudokuCellModel {
        get { cells[index(row: row, col: col)] }
        set { }
    }

    mutating func setValue(_ value: Int?, atRow row: Int, col: Int, isGiven: Bool = false) {
        let i = index(row: row, col: col)
        cells[i].value = value
        cells[i].isGiven = isGiven
        cells[i].isConflict = false
    }

    func valueAt(_ row: Int, _ col: Int) -> Int? { cells[index(row: row, col: col)].value }

    func rowValues(_ row: Int) -> [Int] {
        (0..<SudokuBoard.size).compactMap { valueAt(row, $0) }
    }
    func colValues(_ col: Int) -> [Int] {
        (0..<SudokuBoard.size).compactMap { valueAt($0, col) }
    }
    func blockValues(row: Int, col: Int) -> [Int] {
        let br = (row/3)*3, bc = (col/3)*3
        var r: [Int] = []
        for rr in br..<br+3 {
            for cc in bc..<bc+3 {
                if let v = valueAt(rr, cc) { r.append(v) }
            }
        }
        return r
    }
}
