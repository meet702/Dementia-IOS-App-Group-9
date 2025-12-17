import UIKit

class SudokuViewController: UIViewController {

    var difficultyLevel: Int = 1

    private var clueCount: Int {
        switch difficultyLevel {
        case 1: return 40
        case 2: return 34
        case 3: return 28
        default: return 40
        }
    }

    private var difficultyName: String {
        switch difficultyLevel {
        case 1: return "Easy"
        case 2: return "Medium"
        case 3: return "Hard"
        default: return "Easy"
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var numberPadContainer: UIView!

    private var pauseOverlayView: UIView?
    private var isPausedState: Bool = false

    private func pauseGameState() {
        guard !isPausedState else { return }
        isPausedState = true
        collectionView.isUserInteractionEnabled = false
        numberPadContainer.isUserInteractionEnabled = false
        collectionView.alpha = 0.98
    }

    private func resumeGameState() {
        guard isPausedState else { return }
        isPausedState = false
        collectionView.isUserInteractionEnabled = true
        numberPadContainer.isUserInteractionEnabled = true
        collectionView.alpha = 1.0
    }

    @IBAction func pauseTapped(_ sender: Any) {
        pauseGameState()
        showPauseAlert()
    }

    func showPauseAlert() {
        let alert = UIAlertController(
            title: "Game Paused",
            message: nil,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Resume", style: .default, handler: { _ in
            self.resumeGameState()
        }))

        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.restartGame()
        }))

        alert.addAction(UIAlertAction(title: "Quit", style: .destructive, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))

        present(alert, animated: true, completion: nil)
    }

    private var puzzle: [Int?] = Array(repeating: nil, count: 81)
    private var solution: [Int?] = Array(repeating: nil, count: 81)
    private var boardModel = SudokuBoard()
    private var selectedIndex: Int? = nil
    private var undoStack: [(index: Int, previous: Int?)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        difficultyLabel.text = "Difficulty: \(difficultyName)"

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.collectionViewLayout = createSudokuLayout()

        DispatchQueue.global(qos: .userInitiated).async {
            let (p, s) = SudokuGenerator.generatePuzzle(
                targetClues: self.clueCount,
                ensureUnique: false
            )
            DispatchQueue.main.async {
                self.puzzle = p
                self.solution = s
                self.loadBoardFromPuzzle()
                self.collectionView.reloadData()
            }
        }
    }

    private func loadBoardFromPuzzle() {
        var b = SudokuBoard()
        for i in 0..<81 {
            let r = i / 9
            let c = i % 9
            let val = puzzle[i]
            b.setValue(val, atRow: r, col: c, isGiven: val != nil)
        }
        boardModel = b
        undoStack.removeAll()
        selectedIndex = nil
    }

    private func restartGame() {
        let (newPuzzle, newSolution) = SudokuGenerator.generatePuzzle(
            targetClues: clueCount,
            ensureUnique: false
        )

        puzzle = newPuzzle
        solution = newSolution
        loadBoardFromPuzzle()
        collectionView.reloadData()
    }

    private func createSudokuLayout() -> UICollectionViewLayout {
        let columns = 9
        let rows = 9
        let _: CGFloat = 0
        let sectionInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let rowHeight = NSCollectionLayoutDimension.fractionalWidth(1.0 / CGFloat(columns))
        let hGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: rowHeight)
        let hGroup = NSCollectionLayoutGroup.horizontal(layoutSize: hGroupSize, subitem: item, count: columns)

        let vGroupHeight = NSCollectionLayoutDimension.fractionalWidth(CGFloat(rows) * (1.0 / CGFloat(columns)))
        let vGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: vGroupHeight)
        let vGroup = NSCollectionLayoutGroup.vertical(layoutSize: vGroupSize, subitem: hGroup, count: rows)

        let section = NSCollectionLayoutSection(group: vGroup)
        section.contentInsets = sectionInsets
        return UICollectionViewCompositionalLayout(section: section)
    }

    @IBAction func numberTapped(_ sender: UIButton) {
        let num = sender.tag
        guard let idx = selectedIndex else { return }
        let row = idx / 9
        let col = idx % 9
        let cell = boardModel.cells[idx]

        if cell.isGiven { return }

        undoStack.append((idx, cell.value))

        if cell.value == num {
            boardModel.setValue(nil, atRow: row, col: col)
        } else {
            boardModel.setValue(num, atRow: row, col: col)
        }

        validateConflicts(aroundIndex: idx)
        collectionView.reloadItems(at: [IndexPath(item: idx, section: 0)])
    }

    @IBAction func undoTapped(_ sender: UIButton) {
        guard let last = undoStack.popLast() else { return }
        let index = last.index
        let r = index / 9
        let c = index % 9

        boardModel.setValue(last.previous, atRow: r, col: c)
        validateConflictsAll()
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    @IBAction func hintTapped(_ sender: UIButton) {
        let empty = (0..<81).filter { boardModel.cells[$0].value == nil }
        guard !empty.isEmpty else { return }

        let idx = empty.randomElement()!
        let r = idx / 9
        let c = idx % 9
        guard let correct = solution[idx] else { return }

        undoStack.append((idx, boardModel.cells[idx].value))
        boardModel.setValue(correct, atRow: r, col: c)

        validateConflicts(aroundIndex: idx)
        collectionView.reloadItems(at: [IndexPath(item: idx, section: 0)])
    }

    private func validateConflictsAll() {
        for i in 0..<81 { boardModel.cells[i].isConflict = false }

        for r in 0..<9 {
            checkConflicts(in: (0..<9).map { r * 9 + $0 })
        }

        for c in 0..<9 {
            checkConflicts(in: (0..<9).map { $0 * 9 + c })
        }

        for br in stride(from: 0, to: 9, by: 3) {
            for bc in stride(from: 0, to: 9, by: 3) {
                var indices: [Int] = []
                for rr in br..<br+3 {
                    for cc in bc..<bc+3 {
                        indices.append(rr * 9 + cc)
                    }
                }
                checkConflicts(in: indices)
            }
        }
    }

    private func validateConflicts(aroundIndex idx: Int) {
        let r = idx / 9
        let c = idx % 9

        for i in 0..<81 {
            let rr = i / 9
            let cc = i % 9
            if rr == r || cc == c || (rr / 3 == r / 3 && cc / 3 == c / 3) {
                boardModel.cells[i].isConflict = false
            }
        }

        checkConflicts(in: (0..<9).map { r * 9 + $0 })
        checkConflicts(in: (0..<9).map { $0 * 9 + c })

        var block: [Int] = []
        let br = (r / 3) * 3
        let bc = (c / 3) * 3
        for rr in br..<br+3 {
            for cc in bc..<bc+3 {
                block.append(rr * 9 + cc)
            }
        }
        checkConflicts(in: block)
    }

    private func checkConflicts(in indices: [Int]) {
        var seen: [Int: Int] = [:] // value → index
        for idx in indices {
            if let v = boardModel.cells[idx].value {
                if let prev = seen[v] {
                    boardModel.cells[idx].isConflict = true
                    boardModel.cells[prev].isConflict = true
                } else {
                    seen[v] = idx
                }
            }
        }
    }
}

extension SudokuViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 81 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SudokuCollectionViewCell.reuseId,
            for: indexPath
        ) as! SudokuCollectionViewCell

        let idx = indexPath.item
        let r = idx / 9
        let c = idx % 9
        let model = boardModel.cells[idx]
        let isSelectedCell = (selectedIndex == idx)

        cell.configure(
            value: model.value,
            isGiven: model.isGiven,
            isSelected: isSelectedCell,
            isConflict: model.isConflict,
            row: r,
            col: c
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let idx = indexPath.item
        let cellModel = boardModel.cells[idx]

        if cellModel.isGiven { return }

        let previous = selectedIndex
        selectedIndex = idx

        var reload: [IndexPath] = [indexPath]
        if let prev = previous, prev != idx {
            reload.append(IndexPath(item: prev, section: 0))
        }

        collectionView.reloadItems(at: reload)
    }
}
