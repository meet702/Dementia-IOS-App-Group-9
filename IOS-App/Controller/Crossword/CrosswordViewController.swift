import UIKit

final class CrosswordViewController: UIViewController {

    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var hintCollectionView: UICollectionView!
    @IBOutlet weak var keyboardStackView: UIStackView!

    private var cells: [CrosswordCell] = []
    private var words: [CrosswordWord] = []
    private let gameState = CrosswordGameState()

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
    }

    private func loadLevel() {

        // MARK: - Create 10x10 grid
        cells = (0..<100).map {
            CrosswordCell(
                index: $0,
                row: $0 / 10,
                col: $0 % 10,
                number: $0 == 0 ? 1 : nil, // Only first cell numbered
                letter: nil,
                isBlocked: false,
                isHighlighted: false,
                isCorrect: false
            )
        }

        // MARK: - One sample word
        words = [
            CrosswordWord(
                number: 1,
                answer: "APPLE",
                startIndex: 0,
                direction: .across,
                image: UIImage(systemName: "apple.logo")!
            )
        ]

        gridCollectionView.reloadData()
        hintCollectionView.reloadData()
    }

    
    private func handleGridTap(_ cell: CrosswordCell) {

        // If user taps the same numbered cell again → toggle direction
        if gameState.selectedCellIndex == cell.index {
            gameState.selectedDirection =
                gameState.selectedDirection == .across ? .down : .across
        } else {
            // First tap → select new word
            gameState.selectedCellIndex = cell.index
            gameState.selectedWord = words.first { $0.number == cell.number }
            gameState.selectedDirection =
                gameState.selectedWord?.direction ?? .across
        }

        highlightSelectedWord()
    }
    private func highlightSelectedWord() {
        guard let word = gameState.selectedWord else { return }

        // Clear all highlights
        for i in cells.indices {
            cells[i].isHighlighted = false
        }

        let wordLength = word.answer.count
        var index = word.startIndex

        for _ in 0..<wordLength {
            cells[index].isHighlighted = true

            index += (gameState.selectedDirection == .across) ? 1 : 10
        }

        gridCollectionView.reloadData()
    }

    @IBAction func keyTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle,
              let char = title.first,
              let word = gameState.selectedWord else {
            return
        }

        let wordLength = word.answer.count
        var index = word.startIndex

        for _ in 0..<wordLength {
            if cells[index].letter == nil {
                cells[index].letter = char
                break
            }
            index += (gameState.selectedDirection == .across) ? 1 : 10
        }

        gridCollectionView.reloadData()
    }

}

extension CrosswordViewController: UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

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
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HintCell",
                for: indexPath) as! HintCell
            cell.configure(with: words[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        if collectionView == gridCollectionView {
            let model = cells[indexPath.item]
            guard model.number != nil else { return }
            handleGridTap(model)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        if collectionView == gridCollectionView {

            let columns: CGFloat = 10   // 👈 your grid width
            let spacing: CGFloat = 4
            let horizontalPadding: CGFloat = 32 // 16 left + 16 right

            let totalSpacing = spacing * (columns - 1)
            let availableWidth =
                collectionView.bounds.width - totalSpacing - horizontalPadding

            let cellSize = floor(availableWidth / columns)

            return CGSize(width: cellSize, height: cellSize)
        }

        return CGSize(
            width: collectionView.bounds.width,
            height: collectionView.bounds.height
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {

        if collectionView == gridCollectionView {
            return UIEdgeInsets(
                top: 8,
                left: 16,   // 👈 leading padding
                bottom: 8,
                right: 16   // 👈 trailing padding
            )
        } else {
            return .zero
        }
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return collectionView == gridCollectionView ? 3 : 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return collectionView == gridCollectionView ? 3 : 0
    }


}
