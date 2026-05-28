import Foundation

struct SudokuSolver {
    static func solve(_ board: inout [Int?]) -> Bool {
        guard let emptyIndex = board.firstIndex(where: { $0 == nil }) else { return true }
        let row = emptyIndex / 9, col = emptyIndex % 9

        let used = usedNumbers(board, row: row, col: col)
        for n in (1...9).shuffled() {
            if !used.contains(n) {
                board[emptyIndex] = n
                if solve(&board) { return true }
                board[emptyIndex] = nil
            }
        }
        return false
    }

    static func countSolutions(_ board: [Int?], limit: Int = 2) -> Int {
        var count = 0
        var b = board
        func backtrack() -> Bool {
            if count >= limit { return true }
            guard let emptyIndex = b.firstIndex(where: { $0 == nil }) else {
                count += 1
                return count >= limit
            }
            let row = emptyIndex / 9, col = emptyIndex % 9
            let used = usedNumbers(b, row: row, col: col)
            for n in 1...9 {
                if !used.contains(n) {
                    b[emptyIndex] = n
                    if backtrack() { if count >= limit { return true } }
                    b[emptyIndex] = nil
                }
            }
            return false
        }
        _ = backtrack()
        return count
    }

    private static func usedNumbers(_ board: [Int?], row: Int, col: Int) -> Set<Int> {
        var s = Set<Int>()
        for c in 0..<9 { if let v = board[row*9 + c] { s.insert(v) } }
        for r in 0..<9 { if let v = board[r*9 + col] { s.insert(v) } }
        let br = (row/3)*3, bc = (col/3)*3
        for r in br..<br+3 {
            for c in bc..<bc+3 {
                if let v = board[r*9 + c] { s.insert(v) }
            }
        }
        return s
    }
}
