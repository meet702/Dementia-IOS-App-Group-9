import UIKit

final class CrosswordViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var keyboardStackView: UIStackView!
    @IBOutlet weak var loadingOverlayView: UIView!
    
    private var cells: [CrosswordCell] = []
    private var words: [CrosswordWord] = []
    private let gameState = CrosswordGameState()
    var isCorrectLetter: Bool = false
    var isSelected: Bool = false
    
    private let totalCols = 9
    private let totalRows = 9

    private var minX = 0
    private var minY = 0
    private var maxX = 0
    private var maxY = 0
    
    // PUZZLE MANAGEMENT
    private var allPuzzles: [([String], [String: String])] = []
    private var currentPuzzleIndex = 0
    
    // CATEGORY
    var selectedCategory: CrosswordCategory!
    
    private var dotsTimer: Timer?


    // ---------------------------------------------------------
    // MARK: - View Lifecycle
    // ---------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show loading only
        loadingOverlayView.isHidden = false
        loadingOverlayView.alpha = 1.0
        
        Task {
            print("➡️ Generating for category:", self.selectedCategory.rawValue)

            await generatePuzzles()
            await loadLevel()

            hideLoadingScreen()

            // ✅ Set title AFTER loading finishes
            DispatchQueue.main.async {
                self.title = self.selectedCategory.rawValue
            }

            // Wait slightly, then connect keyboard
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.setupKeyboardConnections()
            }
        }
    }


    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gridCollectionView.collectionViewLayout.invalidateLayout()
    }


    // ---------------------------------------------------------
    // MARK: - Loading Screen
    // ---------------------------------------------------------

    private func hideLoadingScreen() {
        DispatchQueue.main.async {
            self.dotsTimer?.invalidate()
            self.dotsTimer = nil
            
            UIView.animate(withDuration: 0.3, animations: {
                self.loadingOverlayView.alpha = 0
            }) { _ in
                self.loadingOverlayView.isHidden = true
            }
        }
    }
    
    private func showLoadingScreen() {
        DispatchQueue.main.async {
            self.loadingOverlayView.alpha = 0
            self.loadingOverlayView.isHidden = false

            UIView.animate(withDuration: 0.25) {
                self.loadingOverlayView.alpha = 1
            }

        }
    }


    // ---------------------------------------------------------
    // MARK: - Setup CollectionView
    // ---------------------------------------------------------

    private func setupCollectionView() {
        gridCollectionView.dataSource = self
        gridCollectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        gridCollectionView.collectionViewLayout = layout
    }


    // ---------------------------------------------------------
    // MARK: - Generate Multiple Puzzles - OPTIMIZED
    // ---------------------------------------------------------
    
    @MainActor
    private func generatePuzzles() async {
        print("🎲 Generating \(selectedCategory.rawValue) crossword puzzles...")
        
        // Generate 10 puzzles using selected category data
        allPuzzles = generateUniqueCrosswords(from: selectedCategory.data, count: 10)
        
        print("✅ Generated \(allPuzzles.count) unique puzzles")
        
        // Fallback if generation fails
        if allPuzzles.isEmpty {
            print("⚠️ Using fallback puzzles")
            allPuzzles = createFallbackPuzzles()
        }
        
        // Shuffle puzzles for variety
        allPuzzles.shuffle()
    }
    
    private func createFallbackPuzzles() -> [([String], [String: String])] {

        guard let category = selectedCategory else {
            print("❌ No selected category — using GK as default")
            let data = Array(gkData.prefix(15))
            return [(data.map {$0.name}, Dictionary(uniqueKeysWithValues: data.map { ($0.name, $0.clue) }))]
        }

        let data = Array(category.data.prefix(15))
        let words = data.map { $0.name }
        let clues = Dictionary(uniqueKeysWithValues: data.map { ($0.name, $0.clue) })

        return [(words, clues)]
    }



    // ---------------------------------------------------------
    // MARK: - Load Crossword
    // ---------------------------------------------------------

    @MainActor
    private func loadLevel() async {
        guard !allPuzzles.isEmpty else {
            print("❌ No puzzles available")
            return
        }
        
        let (inputWords, clues) = allPuzzles[currentPuzzleIndex]
        
        print("📋 Loading puzzle \(currentPuzzleIndex + 1)/\(allPuzzles.count)")
        print("   Words: \(inputWords.joined(separator: ", "))")

        let (board, placedWords) = generateCrossword(words: inputWords)
        guard !placedWords.isEmpty else {
            print("❌ Failed to generate crossword, trying next puzzle...")
            await loadNextPuzzle()
            return
        }

        let occupied = board.enumerated().flatMap { x, col in
            col.enumerated().compactMap { y, char in char != nil ? (x, y) : nil }
        }

        minX = occupied.map { $0.0 }.min()!
        maxX = occupied.map { $0.0 }.max()!
        minY = occupied.map { $0.1 }.min()!
        maxY = occupied.map { $0.1 }.max()!

        let crosswordCols = maxX - minX + 1
        let crosswordRows = maxY - minY + 1

        let offsetX = (9 - crosswordCols) / 2
        let offsetY = (9 - crosswordRows) / 2

        cells = (0..<81).map { index in
            CrosswordCell(
                index: index,
                row: index / 9,
                col: index % 9,
                numbers: [],
                letter: nil,
                correctLetter: nil,
                isBlocked: true,
                isHighlighted: false,
                isCorrectLetter: false,
                isCorrectWord: false,
                isWrongLetter: false,
                isSelected: false
            )
        }

        for w in placedWords {
            for i in 0..<w.string.count {
                let letter = w.string[w.string.index(w.string.startIndex, offsetBy: i)]
                let gx = (w.dir == 0 ? w.x + i : w.x)
                let gy = (w.dir == 0 ? w.y : w.y + i)
                let cx = (gx - minX) + offsetX
                let cy = (gy - minY) + offsetY
                let idx = indexForCell(x: cx, y: cy)
                cells[idx].isBlocked = false
                cells[idx].correctLetter = letter
            }
        }

        words = placedWords.enumerated().map { (i, w) in
            let sx = (w.x - minX) + offsetX
            let sy = (w.y - minY) + offsetY
            let idx = indexForCell(x: sx, y: sy)

            return CrosswordWord(
                number: i + 1,
                answer: w.string,
                clue: clues[w.string] ?? "No clue",
                startIndex: idx,
                direction: w.dir == 0 ? .across : .down
            )
        }

        for word in words {
            cells[word.startIndex].numbers.append(word.number)
        }

        gridCollectionView.reloadData()

        if let first = words.first {
            gameState.selectedWord = first
            gameState.selectedCellIndex = first.startIndex
            gameState.selectedDirection = first.globalDirection
            updateClueLabel()
            highlightSelectedWord()
        }
    }
    
    @MainActor
    func loadNextPuzzle() async {
        showLoadingScreen()
        currentPuzzleIndex = (currentPuzzleIndex + 1) % allPuzzles.count
        await loadLevel()
        hideLoadingScreen()
    }
    
    private func isPuzzleComplete() -> Bool {
        for cell in cells where !cell.isBlocked {
            if !isCellCorrect(cell.index) {
                return false
            }
        }
        return true
    }



    // ---------------------------------------------------------
    // MARK: - Helpers
    // ---------------------------------------------------------

    private func indexForCell(x: Int, y: Int) -> Int {
        return y * totalCols + x
    }

    private func updateClueLabel() {
        guard let word = gameState.selectedWord else { return }
        questionLabel.text = "\(word.number). \(word.clue)"
    }


    // ---------------------------------------------------------
    // MARK: - Finding Word Containing a Cell
    // ---------------------------------------------------------

    private func findWordForCell(_ cell: CrosswordCell) -> CrosswordWord? {
        for word in words {
            var r = cells[word.startIndex].row
            var c = cells[word.startIndex].col

            for _ in 0..<word.answer.count {
                if r == cell.row && c == cell.col {
                    return word
                }
                if word.direction == .across { c += 1 }
                else { r += 1 }
            }
        }
        return nil
    }

    private func findAllWordsForCell(_ cell: CrosswordCell) -> [CrosswordWord] {
        var matchingWords: [CrosswordWord] = []
        
        for word in words {
            var r = cells[word.startIndex].row
            var c = cells[word.startIndex].col
            
            for _ in 0..<word.answer.count {
                if r == cell.row && c == cell.col {
                    matchingWords.append(word)
                    break
                }
                if word.direction == .across { c += 1 }
                else { r += 1 }
            }
        }
        return matchingWords
    }


    // ---------------------------------------------------------
    // MARK: - Tap Cell to Select Word
    // ---------------------------------------------------------

    private func handleGridTap(_ cell: CrosswordCell) {
        let wordsContainingCell = findAllWordsForCell(cell)
        guard !wordsContainingCell.isEmpty else { return }

        // 1️⃣ Clear previous selection
        for i in cells.indices {
            cells[i].isSelected = false
        }

        // 2️⃣ Select tapped cell
        cells[cell.index].isSelected = true
        gameState.selectedCellIndex = cell.index

        // 3️⃣ Direction toggle (only affects clues, NOT cursor)
        if wordsContainingCell.count > 1 {
            let hasAcross = wordsContainingCell.contains { $0.direction == .across }
            let hasDown = wordsContainingCell.contains { $0.direction == .down }

            if hasAcross && hasDown {
                gameState.selectedDirection =
                    (gameState.selectedDirection == .across ? .down : .across)
            }
        }

        // 4️⃣ Pick preferred word (for clue display only)
        let preferredWord: CrosswordWord?
        if gameState.selectedDirection == .across {
            preferredWord = wordsContainingCell.first { $0.direction == .across }
                ?? wordsContainingCell.first
        } else {
            preferredWord = wordsContainingCell.first { $0.direction == .down }
                ?? wordsContainingCell.first
        }

        // 5️⃣ Update UI
        if let word = preferredWord {
            gameState.selectedWord = word
            gameState.selectedDirection = word.globalDirection
            updateClueLabel()
            highlightSelectedWord()
        }

        gridCollectionView.reloadData()
    }


    private func moveSelectionForward(from index: Int) {
        guard let word = gameState.selectedWord else { return }

        let current = cells[index]
        var row = current.row
        var col = current.col

        // 🔁 Move based on word direction
        if word.direction == .across {
            col += 1
        } else {
            row += 1
        }

        // Stay inside grid
        while row < totalRows && col < totalCols {
            let nextIndex = indexForCell(x: col, y: row)

            if !cells[nextIndex].isBlocked {
                // Clear old selection
                for i in cells.indices {
                    cells[i].isSelected = false
                }

                // Select next cell
                cells[nextIndex].isSelected = true
                gameState.selectedCellIndex = nextIndex
                return
            }

            // Keep moving in SAME direction
            if word.direction == .across {
                col += 1
            } else {
                row += 1
            }
        }
    }

    // ---------------------------------------------------------
    // MARK: - Highlight Current Word
    // ---------------------------------------------------------

    private func highlightSelectedWord() {
        for i in cells.indices {
            cells[i].isHighlighted = false
        }

        guard let word = gameState.selectedWord else { return }

        var r = cells[word.startIndex].row
        var c = cells[word.startIndex].col

        for _ in 0..<word.answer.count {
            let idx = indexForCell(x: c, y: r)
            cells[idx].isHighlighted = true

            if word.direction == .across { c += 1 }
            else { r += 1 }
        }
    }




    // ---------------------------------------------------------
    // MARK: - Keyboard Setup
    // ---------------------------------------------------------

    private func setupKeyboardConnections() {
        guard let keyboardStack = keyboardStackView else { return }
        connectAllButtons(in: keyboardStack)
    }
    
    private func connectAllButtons(in view: UIView) {
        func traverse(_ v: UIView) {
            if let button = v as? UIButton {
                button.removeTarget(nil, action: nil, for: .allEvents)
                
                let title = button.currentTitle ?? ""
                let titleLabel = button.titleLabel?.text ?? ""
                let buttonText = !title.isEmpty ? title : titleLabel
                
                let isDeleteButton = buttonText.isEmpty && button.imageView?.image != nil
                
                if isDeleteButton {
                    button.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
                } else if !buttonText.isEmpty {
                    button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
                }
            }
            
            for subview in v.subviews {
                traverse(subview)
            }
        }
        
        traverse(view)
    }


    // ---------------------------------------------------------
    // MARK: - Keyboard Input
    // ---------------------------------------------------------

    @objc @IBAction func keyTapped(_ sender: UIButton) {
        if let char = sender.currentTitle?.first {
            insertLetter(char)
            return
        }
        
        if let labelText = sender.titleLabel?.text?.first {
            insertLetter(labelText)
            return
        }
    }

    @objc @IBAction func deleteTapped(_ sender: UIButton) {
        deleteLetter()
    }


    private func insertLetter(_ char: Character) {
        let idx = gameState.selectedCellIndex

        cells[idx].letter = char
        cells[idx].isWrongLetter = false

        if let correct = cells[idx].correctLetter {
            cells[idx].isCorrectLetter = char.uppercased() == correct.uppercased()
        }

        revalidateWords(at: idx)

        if let word = gameState.selectedWord {
            if isSelectedWordComplete() {
                clearSelection()
                highlightSelectedWord()
                gridCollectionView.reloadData()

                if isPuzzleComplete() {
                    showPuzzleCompleteAlert()
                }
                return
            }
        }

        moveSelectionForward(from: idx)
        highlightSelectedWord()
        gridCollectionView.reloadData()
    }

    private func isSelectedWordComplete() -> Bool {
        guard let word = gameState.selectedWord else { return false }

        var r = cells[word.startIndex].row
        var c = cells[word.startIndex].col

        for _ in 0..<word.answer.count {
            let idx = indexForCell(x: c, y: r)
            if cells[idx].letter == nil {
                return false
            }
            if word.direction == .across { c += 1 }
            else { r += 1 }
        }
        return true
    }


    private func isCellCorrect(_ idx: Int) -> Bool {
        guard let letter = cells[idx].letter,
              let correct = cells[idx].correctLetter else {
            return false
        }
        return letter.uppercased() == correct.uppercased()
    }
    
    
    private func deleteLetter() {
        guard let word = gameState.selectedWord else { return }

        let idx = gameState.selectedCellIndex

        // --------------------------------
        // CASE 1: Current cell has a letter
        // --------------------------------
        if cells[idx].letter != nil {
            cells[idx].letter = nil
            cells[idx].isWrongLetter = false
            cells[idx].isCorrectWord = false

            revalidateWords(at: idx)
            highlightSelectedWord()
            gridCollectionView.reloadData()
            return
        }

        // --------------------------------
        // CASE 2: Move backward WITHIN WORD
        // --------------------------------
        var r = cells[word.startIndex].row
        var c = cells[word.startIndex].col
        var previousIndex: Int? = nil

        for _ in 0..<word.answer.count {
            let currentIndex = indexForCell(x: c, y: r)
            if currentIndex == idx { break }

            previousIndex = currentIndex

            if word.direction == .across { c += 1 }
            else { r += 1 }
        }

        guard let prev = previousIndex else { return }

        // Update selection
        for i in cells.indices {
            cells[i].isSelected = false
        }

        cells[prev].isSelected = true
        gameState.selectedCellIndex = prev

        // Delete letter
        cells[prev].letter = nil
        cells[prev].isWrongLetter = false
        cells[prev].isCorrectWord = false

        revalidateWords(at: prev)
        highlightSelectedWord()
        gridCollectionView.reloadData()
    }


    private func clearSelection() {
        for i in cells.indices {
            cells[i].isSelected = false
        }
    }

    private func moveCursorForward(_ word: CrosswordWord) {
        var r = cells[word.startIndex].row
        var c = cells[word.startIndex].col

        for i in 0..<word.answer.count {
            let idx = indexForCell(x: c, y: r)

            if idx == gameState.selectedCellIndex {
                var nextR = r
                var nextC = c

                for _ in (i + 1)..<word.answer.count {
                    if word.direction == .across { nextC += 1 }
                    else { nextR += 1 }

                    let nextIdx = indexForCell(x: nextC, y: nextR)

                    if nextIdx >= 0 &&
                       nextIdx < cells.count &&
                       !cells[nextIdx].isBlocked &&
                       (cells[nextIdx].letter == nil || !cells[nextIdx].isCorrectWord) {

                        // ✅ Allow filled cells
                        gameState.selectedCellIndex = nextIdx
                        return
                    }
                }
                return
            }

            if word.direction == .across { c += 1 }
            else { r += 1 }
        }
    }
    
    private func moveSelectionBackward(from index: Int) {
        let current = cells[index]
        var row = current.row
        var col = current.col - 1   // move LEFT

        while row >= 0 {
            if col < 0 {
                row -= 1
                col = totalCols - 1
                continue
            }

            let prevIndex = indexForCell(x: col, y: row)

            if !cells[prevIndex].isBlocked {
                // Clear old selection
                for i in cells.indices {
                    cells[i].isSelected = false
                }

                // Select previous cell
                cells[prevIndex].isSelected = true
                gameState.selectedCellIndex = prevIndex
                return
            }

            col -= 1
        }
    }



    // ---------------------------------------------------------
    // MARK: - Check Word Completion
    // ---------------------------------------------------------

    private func checkWordCompletion(_ word: CrosswordWord) {
        var r = cells[word.startIndex].row
        var c = cells[word.startIndex].col

        var indices: [Int] = []
        var allFilled = true
        var allCorrect = true

        // 1️⃣ Collect indices & validate
        for _ in 0..<word.answer.count {
            let idx = indexForCell(x: c, y: r)
            indices.append(idx)

            if let letter = cells[idx].letter {
                if letter.uppercased() != cells[idx].correctLetter?.uppercased() {
                    allCorrect = false
                }
            } else {
                allFilled = false
            }

            if word.direction == .across { c += 1 }
            else { r += 1 }
        }

        // 2️⃣ If word not fully filled → ONLY clear wrong state
        guard allFilled else {
            for idx in indices {
                cells[idx].isWrongLetter = false
            }
            return
        }

        // 3️⃣ Apply correctness WITHOUT wiping other words
        if allCorrect {
            for idx in indices {
                cells[idx].isCorrectWord = true   // 🟧 KEEP ORANGE
                cells[idx].isWrongLetter = false
                cells[idx].isHighlighted = false
                cells[idx].isSelected = false
            }
        } else {
            for idx in indices {
                cells[idx].isWrongLetter = true  // 🟥
            }
        }
    }

    private func revalidateWords(at cellIndex: Int) {
        let cell = cells[cellIndex]
        let affectedWords = findAllWordsForCell(cell)

        for word in affectedWords {
            checkWordCompletion(word)
        }
    }
    
    // ---------------------------------------------------------
    // MARK: - Puzzle Complete Alert
    // ---------------------------------------------------------
    
    private func showPuzzleCompleteAlert() {
        let alert = UIAlertController(
            title: "🎉 Puzzle Complete!",
            message: "Congratulations! Would you like to play another puzzle?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Next Puzzle", style: .default) { [weak self] _ in
            Task {
                await self?.loadNextPuzzle()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel) { [weak self] _ in
            // Navigate back to instructions screen
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }


    // ---------------------------------------------------------
    // MARK: - UICollectionView
    // ---------------------------------------------------------

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
        cell.configure(with: cells[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = cells[indexPath.item]
        if model.isBlocked { return }
        handleGridTap(model)
    }


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 2
        let totalSpacing = CGFloat(totalCols - 1) * spacing
        let usableWidth = gridCollectionView.bounds.width - totalSpacing
        let cellSide = floor(usableWidth / CGFloat(totalCols))
        return CGSize(width: cellSide, height: cellSide)
    }
}
