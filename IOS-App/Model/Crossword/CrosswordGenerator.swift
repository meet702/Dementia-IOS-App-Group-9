import Foundation

public let BOARD_SIZE = 32

public var board: [[Character?]] = []
public var wordArr: [String] = []
public var wordBank: [WordObj] = []
public var wordsActive: [WordObj] = []

public let bounds = Bounds()

public final class Bounds {
    public var top = 999
    public var right = 0
    public var bottom = 0
    public var left = 999

    public func update(x: Int, y: Int) {
        top = min(top, y)
        right = max(right, x)
        bottom = max(bottom, y)
        left = min(left, x)
    }

    public func clean() {
        top = 999
        right = 0
        bottom = 0
        left = 999
    }

    public func center() -> (x: Int, y: Int) {
        ((left + right) / 2, (top + bottom) / 2)
    }
    
    public func width() -> Int {
        return right - left + 1
    }
    
    public func height() -> Int {
        return bottom - top + 1
    }
}

public final class WordObj {
    public let string: String
    public let chars: [Character]

    public var totalMatches = 0
    public var effectiveMatches = 0
    public var successfulMatches: [(x: Int, y: Int, dir: Int)] = []

    public var x = 0
    public var y = 0
    public var dir = 0   // 0 = horizontal, 1 = vertical

    public init(_ value: String) {
        self.string = value
        self.chars = Array(value)
    }
}

@MainActor
func distanceScore(x: Int, y: Int) -> Int {
    let c = bounds.center()
    return abs(x - c.x) + abs(y - c.y)
}

@MainActor
func localDensityScore(x: Int, y: Int, length: Int, dir: Int) -> Int {
    var density = 0
    for i in -2...(length + 2) {
        let px = dir == 0 ? x + i : x
        let py = dir == 0 ? y : y + i
        for dx in -1...1 {
            for dy in -1...1 {
                let nx = px + dx
                let ny = py + dy
                if nx >= 0, ny >= 0, nx < BOARD_SIZE, ny < BOARD_SIZE {
                    if board[nx][ny] != nil { density += 1 }
                }
            }
        }
    }
    return density
}

@MainActor
func directionBalanceBonus(dir: Int) -> Int {
    let horizontal = wordsActive.filter { $0.dir == 0 }.count
    let vertical = wordsActive.count - horizontal

    if dir == 0 && horizontal > vertical { return -5 }
    if dir == 1 && vertical > horizontal { return -5 }
    return 5
}

@MainActor
func chooseBestSpreadPlacement(
    _ placements: [(x: Int, y: Int, dir: Int)],
    wordLength: Int
) -> (x: Int, y: Int, dir: Int) {

    let scored = placements.map { p -> ((Int, Int, Int), Int) in

        let dist = distanceScore(x: p.x, y: p.y) * 3
        let density = localDensityScore(x: p.x, y: p.y, length: wordLength, dir: p.dir) * 4
        let dirBonus = directionBalanceBonus(dir: p.dir)

        return ((p.x, p.y, p.dir), dist - density + dirBonus)
    }

    let bestScore = scored.map { $0.1 }.max()!
    let bestCandidates = scored.filter { $0.1 >= bestScore - 3 }
    return bestCandidates.randomElement()!.0
}

@MainActor
func isCompactCrossword() -> Bool {
    let width = bounds.width()
    let height = bounds.height()
    
    // Crossword should fit in 9x9 grid
    if width > 9 || height > 9 {
        return false
    }
    
    let wordCount = wordsActive.count
    if wordCount < 3 {
        return false
    }
    
    let usedCells = board.flatMap { $0 }.compactMap { $0 }.count
    let gridArea = width * height
    let density = Double(usedCells) / Double(gridArea)
    
    return density >= 0.20 && density <= 0.90
}

@MainActor public func cleanVars() {
    bounds.clean()
    wordBank.removeAll()
    wordsActive.removeAll()

    board = Array(
        repeating: Array(repeating: nil, count: BOARD_SIZE),
        count: BOARD_SIZE
    )
}

@MainActor func prepareBoard() {
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

@MainActor func populateBoard() -> Bool {
    prepareBoard()
    for _ in 0..<wordBank.count {
        if !addWordToBoard() { return false }
    }
    return true
}

@MainActor
func addWordToBoard() -> Bool {

    var curIndex = -1
    var minMatchDiff = Int.max

    if wordsActive.isEmpty {

        curIndex = wordBank.indices.min { wordBank[$0].totalMatches < wordBank[$1].totalMatches }!
        wordBank[curIndex].successfulMatches = [(12, 12, 0)]

    } else {

        for i in 0..<wordBank.count {
            let curWord = wordBank[i]
            curWord.effectiveMatches = 0
            curWord.successfulMatches.removeAll()

            for (j, curChar) in curWord.chars.enumerated() {
                for testWord in wordsActive {
                    for (l, testChar) in testWord.chars.enumerated()
                        where curChar == testChar {

                        curWord.effectiveMatches += 1
                        var crossX = testWord.x
                        var crossY = testWord.y
                        let crossDir = testWord.dir == 0 ? 1 : 0

                        if testWord.dir == 0 {
                            crossX += l
                            crossY -= j
                        } else {
                            crossY += l
                            crossX -= j
                        }

                        if isValidPlacement(word: curWord, x: crossX, y: crossY, dir: crossDir) {
                            curWord.successfulMatches.append((crossX, crossY, crossDir))
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

    let match = chooseBestSpreadPlacement(word.successfulMatches, wordLength: word.chars.count)

    word.x = match.x
    word.y = match.y
    word.dir = match.dir

    for i in 0..<word.chars.count {
        let x = word.dir == 0 ? word.x + i : word.x
        let y = word.dir == 0 ? word.y : word.y + i
        board[x][y] = word.chars[i]
        bounds.update(x: x, y: y)
    }

    return true
}

@MainActor
func isValidPlacement(word: WordObj, x: Int, y: Int, dir: Int) -> Bool {
    let length = word.chars.count

    for i in 0..<length {
        let px = dir == 0 ? x + i : x
        let py = dir == 0 ? y : y + i

        if px < 0 || py < 0 || px >= BOARD_SIZE || py >= BOARD_SIZE {
            return false
        }

        if let existing = board[px][py], existing != word.chars[i] {
            return false
        }
    }

    return true
}

@MainActor
public func generateCrossword(words: [String]) -> ([[Character?]], [WordObj]) {

    wordArr = words.filter { $0.count >= 4 && $0.count <= 8 }
    wordArr = Array(wordArr.prefix(6))  // Max 6 words

    guard wordArr.count >= 3 else {
        return ([], [])
    }

    var success = false
    var attempts = 0
    let maxAttempts = 30
    
    while !success && attempts < maxAttempts {
        cleanVars()
        success = populateBoard()
        
        if success {
            success = isCompactCrossword()
        }
        
        attempts += 1
    }

    return success ? (board, wordsActive) : ([], [])
}

@MainActor
public func generateUniqueCrosswords(
    from items: [CrosswordData],
    count: Int
) -> [([String], [String: String])] {
    
    var puzzles: [([String], [String: String])] = []
    var usedCombinations: Set<String> = []
    
    for _ in 0..<count {
        var attempts = 0
        var foundUnique = false
        
        while !foundUnique && attempts < 20 {
            
            let shuffled = items.shuffled()
            let subset = Array(shuffled.prefix(min(6, shuffled.count)))
            
            let words = subset.map { $0.name }
            let clues = Dictionary(uniqueKeysWithValues: subset.map { ($0.name, $0.clue) })
            
            let signature = words.sorted().joined()
            
            if !usedCombinations.contains(signature) {
                
                let (_, placedWords) = generateCrossword(words: words)
                
                if !placedWords.isEmpty && placedWords.count >= 3 {
                    puzzles.append((words, clues))
                    usedCombinations.insert(signature)
                    foundUnique = true
                }
            }
            
            attempts += 1
        }
    }
    
    return puzzles
}
