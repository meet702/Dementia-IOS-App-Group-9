import Foundation

// =================================
// CONFIG
// =================================

let BOARD_SIZE = 10

// =================================
// GLOBAL STATE
// =================================

var board: [[Character?]] = []
var wordArr: [String] = []
var wordBank: [WordObj] = []
var wordsActive: [WordObj] = []

// =================================
// WORD OBJECT
// =================================

final class WordObj {
    let string: String
    let chars: [Character]

    var totalMatches = 0
    var effectiveMatches = 0
    var successfulMatches: [(x: Int, y: Int, dir: Int)] = []

    var x = 0
    var y = 0
    var dir = 0   // 0 = horizontal, 1 = vertical

    init(_ value: String) {
        self.string = value
        self.chars = Array(value)
    }
}

// =================================
// HELPERS
// =================================

@MainActor
func cleanVars() {
    wordBank.removeAll()
    wordsActive.removeAll()
    board = Array(
        repeating: Array(repeating: nil, count: BOARD_SIZE),
        count: BOARD_SIZE
    )
}

@MainActor
func prepareBoard() {
    wordBank = wordArr.map { WordObj($0) }

    for i in 0..<wordBank.count {
        let wA = wordBank[i]
        for cA in wA.chars {
            for j in 0..<wordBank.count where i != j {
                let wB = wordBank[j]
                for cB in wB.chars where cA == cB {
                    wA.totalMatches += 1
                }
            }
        }
    }
}

// =================================
// VALIDATION
// =================================

@MainActor
func isValidPlacement(word: WordObj, x: Int, y: Int, dir: Int) -> Bool {
    let len = word.chars.count
    let endX = dir == 0 ? x + len - 1 : x
    let endY = dir == 1 ? y + len - 1 : y

    if x < 0 || y < 0 || endX >= BOARD_SIZE || endY >= BOARD_SIZE {
        return false
    }

    for i in -1...len {
        let px = dir == 0 ? x + i : x
        let py = dir == 0 ? y : y + i

        if px < 0 || py < 0 || px >= BOARD_SIZE || py >= BOARD_SIZE {
            if i >= 0 && i < len { return false }
            continue
        }

        if i >= 0 && i < len {
            let existing = board[px][py]
            if existing != nil && existing != word.chars[i] {
                return false
            }
        } else {
            if board[px][py] != nil {
                return false
            }
        }
    }

    return true
}

// =================================
// WORD PLACEMENT
// =================================

@MainActor
func populateBoard() -> Bool {
    prepareBoard()

    for _ in 0..<wordBank.count {
        if !addWordToBoard() {
            return false
        }
    }
    return true
}

@MainActor
func addWordToBoard() -> Bool {
    var curIndex = -1
    var minMatchDiff = Int.max

    // ---------------------------------
    // FIRST WORD (CENTERED & SAFE)
    // ---------------------------------
    if wordsActive.isEmpty {
        curIndex = wordBank.indices.min {
            wordBank[$0].totalMatches < wordBank[$1].totalMatches
        }!

        let word = wordBank[curIndex]
        let len = word.chars.count
        let mid = BOARD_SIZE / 2

        var placements: [(Int, Int, Int)] = []

        for x in 0...(BOARD_SIZE - len) {
            placements.append((x, mid, 0))
        }

        for y in 0...(BOARD_SIZE - len) {
            placements.append((mid, y, 1))
        }

        guard !placements.isEmpty else { return false }
        wordBank[curIndex].successfulMatches = placements
    }
    // ---------------------------------
    // SUBSEQUENT WORDS
    // ---------------------------------
    else {
        for i in 0..<wordBank.count {
            let curWord = wordBank[i]
            curWord.effectiveMatches = 0
            curWord.successfulMatches.removeAll()

            for (j, curChar) in curWord.chars.enumerated() {
                for testWord in wordsActive {
                    for (l, testChar) in testWord.chars.enumerated()
                        where curChar == testChar {

                        curWord.effectiveMatches += 1

                        var x = testWord.x
                        var y = testWord.y
                        let dir = testWord.dir == 0 ? 1 : 0

                        if testWord.dir == 0 {
                            x += l
                            y -= j
                        } else {
                            y += l
                            x -= j
                        }

                        if isValidPlacement(word: curWord, x: x, y: y, dir: dir) {
                            curWord.successfulMatches.append((x, y, dir))
                        }
                    }
                }
            }

            if curWord.successfulMatches.isEmpty {
                let len = curWord.chars.count
                for dir in [0, 1] {
                    for x in 0..<BOARD_SIZE {
                        for y in 0..<BOARD_SIZE {
                            let endX = dir == 0 ? x + len - 1 : x
                            let endY = dir == 1 ? y + len - 1 : y
                            if endX < BOARD_SIZE && endY < BOARD_SIZE &&
                               isValidPlacement(word: curWord, x: x, y: y, dir: dir) {
                                curWord.successfulMatches.append((x, y, dir))
                            }
                        }
                    }
                }
            }

            let diff = curWord.totalMatches - curWord.effectiveMatches
            if diff < minMatchDiff && !curWord.successfulMatches.isEmpty {
                minMatchDiff = diff
                curIndex = i
            }
        }
    }

    if curIndex == -1 { return false }

    let word = wordBank.remove(at: curIndex)
    wordsActive.append(word)

    let match = word.successfulMatches.randomElement()!
    word.x = match.x
    word.y = match.y
    word.dir = match.dir

    for i in 0..<word.chars.count {
        let px = word.dir == 0 ? word.x + i : word.x
        let py = word.dir == 0 ? word.y : word.y + i
        board[px][py] = word.chars[i]
    }

    return true
}

// =================================
// WRAPPER FOR APP INTEGRATION
// =================================

@MainActor
func generateCrossword(words: [String]) -> ([[Character?]], [WordObj]) {

    wordArr = words

    guard wordArr.allSatisfy({ $0.count <= BOARD_SIZE }) else {
        fatalError("Word longer than board size")
    }

    var success = false
    for _ in 0..<20 where !success {
        cleanVars()
        success = populateBoard()
    }

    guard success else {
        fatalError("Failed to generate crossword")
    }

    return (board, wordsActive)
}
