import Foundation

struct SudokuGenerator {
    static func generateFullBoard() -> [Int?] {
        var board = [Int?](repeating: nil, count: 81)
        _ = SudokuSolver.solve(&board)
        return board
    }

    static func generatePuzzle(targetClues: Int, ensureUnique: Bool = false) -> (puzzle: [Int?], solution: [Int?]) {
        let solution = generateFullBoard()
        var puzzle = solution
        var positions = Array(0..<81).shuffled()
        var currentClues = 81
        while currentClues > targetClues && !positions.isEmpty {
            let pos = positions.removeFirst()
            let backup = puzzle[pos]
            puzzle[pos] = nil
            if ensureUnique {
                let count = SudokuSolver.countSolutions(puzzle, limit: 2)
                if count != 1 {
                    puzzle[pos] = backup
                } else {
                    currentClues -= 1
                }
            } else {
                currentClues -= 1
            }
        }
        return (puzzle, solution)
    }
}
