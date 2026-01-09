import UIKit

final class CrosswordViewController: UIViewController {

    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var hintCollectionView: UICollectionView!
    @IBOutlet weak var keyboardStackView: UIStackView!

    private var cells: [CrosswordCell] = []
    private var words: [CrosswordWord] = []
    private let gameState = CrosswordGameState()

    private var minX = 0
    private var minY = 0
    var cellIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        loadLevel()
    }

    private func setupCollectionViews() {
        gridCollectionView.dataSource = self
        gridCollectionView.delegate = self
        hintCollectionView.dataSource = self
        hintCollectionView.delegate = self

        gridCollectionView.register(GridCell.self,
                                    forCellWithReuseIdentifier: "GridCell")
        hintCollectionView.register(HintCell.self,
                                    forCellWithReuseIdentifier: "HintCell")

        gridCollectionView.collectionViewLayout = UICollectionViewLayout()
    }

    // MARK: - Crossword Generation

    @MainActor
    private func loadLevel() {

        let inputWords = ["PERU", "IRAN", "MALI", "LAOS", "FIJI"]
        let (board, placedWords) = generateCrossword(words: inputWords)

        let occupied = board.enumerated().flatMap { x, col in
            col.enumerated().compactMap { y, char in
                char != nil ? (x, y) : nil
            }
        }

        guard !occupied.isEmpty else { return }

        minX = occupied.map { $0.0 }.min()!
        let maxX = occupied.map { $0.0 }.max()!
        minY = occupied.map { $0.1 }.min()!
        let maxY = occupied.map { $0.1 }.max()!

        cells.removeAll()

        for y in minY...maxY {
            for x in minX...maxX {
                guard board[x][y] != nil else { continue }

                cells.append(
                    CrosswordCell(
                        index: cellIndex,
                        row: y - minY,
                        col: x - minX,
                        number: nil,
                        letter: nil,
                        isBlocked: false,
                        isHighlighted: false,
                        isCorrect: false
                    )
                )

                cellIndex += 1
            }
        }

        words = placedWords.enumerated().map { (i, w) in
            CrosswordWord(
                number: i + 1,
                answer: w.string,
                startIndex: indexForCell(x: w.x, y: w.y),
                direction: w.dir == 0 ? .across : .down,
                image: UIImage(named: w.string.lowercased()) ?? UIImage()
            )
        }

        for word in words {
            cells[word.startIndex].number = word.number
        }

        gridCollectionView.reloadData()
        hintCollectionView.reloadData()
    }

    // MARK: - Helpers

    private func indexForCell(x: Int, y: Int) -> Int {
        cells.firstIndex { $0.row == y && $0.col == x }!
    }

    private func cellSize() -> CGFloat {
        let spacing: CGFloat = 4
        let maxCols = cells.map { $0.col }.max()! - minX + 1
        let totalSpacing = CGFloat(maxCols - 1) * spacing
        let available = gridCollectionView.bounds.width - totalSpacing
        return floor(available / CGFloat(maxCols))
    }

    // MARK: - Interaction

    private func handleGridTap(_ cell: CrosswordCell) {

        if gameState.selectedCellIndex == cell.index {
            gameState.selectedDirection =
                gameState.selectedDirection == .across ? .down : .across
        } else {
            gameState.selectedCellIndex = cell.index
            gameState.selectedWord = words.first { $0.number == cell.number }
            gameState.selectedDirection =
                gameState.selectedWord?.direction ?? .across
        }

        highlightSelectedWord()
    }

    private func highlightSelectedWord() {
        guard let word = gameState.selectedWord else { return }

        cells.indices.forEach { cells[$0].isHighlighted = false }

        var row = cells[word.startIndex].row
        var col = cells[word.startIndex].col

        for _ in 0..<word.answer.count {
            if let idx = cells.firstIndex(where: {
                $0.row == row && $0.col == col
            }) {
                cells[idx].isHighlighted = true
            }

            if gameState.selectedDirection == .across {
                col += 1
            } else {
                row += 1
            }
        }

        gridCollectionView.reloadData()
    }

    @IBAction func keyTapped(_ sender: UIButton) {
        guard let char = sender.currentTitle?.first,
              let word = gameState.selectedWord else { return }

        var row = cells[word.startIndex].row
        var col = cells[word.startIndex].col

        for _ in 0..<word.answer.count {
            if let idx = cells.firstIndex(where: {
                $0.row == row && $0.col == col
            }), cells[idx].letter == nil {
                cells[idx].letter = char
                break
            }

            if gameState.selectedDirection == .across {
                col += 1
            } else {
                row += 1
            }
        }

        gridCollectionView.reloadData()
    }
}

// MARK: - Collection View

extension CrosswordViewController: UICollectionViewDataSource,
                                   UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        collectionView == gridCollectionView ? cells.count : words.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == gridCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "GridCell",
                for: indexPath) as! GridCell
            cell.configure(with: cells[indexPath.item])
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HintCell",
            for: indexPath) as! HintCell
        cell.configure(with: words[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        guard collectionView == gridCollectionView else { return }
        let model = cells[indexPath.item]
        guard model.number != nil else { return }
        handleGridTap(model)
    }
}
