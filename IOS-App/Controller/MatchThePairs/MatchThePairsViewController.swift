import UIKit

class MatchThePairsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - IBOutlets (connect from storyboard)
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var matchedLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!

    // MARK: - Configurable before presenting
    var columns: Int = 3
    var rows: Int = 4
    var backImageName: String = "card_back"

    // MARK: - Internal state
    private lazy var pairsCount: Int = (columns * rows) / 2
    private lazy var game: MemoryGame = MemoryGame(pairsCount: pairsCount)
    private var layoutAppliedForSize: CGSize = .zero
    private var isProcessingSelection = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("GameVC viewDidLoad columns=\(columns) rows=\(rows)")
        // Ensure conformance
        collectionView.dataSource = self
        collectionView.delegate = self

        // Keep selection visible and static board
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false

        matchedLabel.text = "Matched: 0"
        difficultyLabel.text = "Difficulty: " + difficultyName()

        startGame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Apply layout when collectionView gets its size
        let currentSize = collectionView.bounds.size
        if currentSize != layoutAppliedForSize {
            layoutAppliedForSize = currentSize
            applyFittingLayout(columns: columns, rows: rows)
        }
    }

    // MARK: - Game control
    func startGame() {
        pairsCount = (columns * rows) / 2
        game.reset(pairsCount: pairsCount)
        collectionView.reloadData()
        updateMatchedLabel()
    }

    private func updateMatchedLabel() {
        matchedLabel.text = "Matched: \(game.matchedPairs)"
    }

    private func difficultyName() -> String {
        switch (columns, rows) {
        case (3,4): return "Easy"
        case (3,6): return "Medium"
        case (4,6): return "Hard"
        default: return "\(columns)x\(rows)"
        }
    }

    // MARK: - Layout that fits available height (keeps scrolling disabled)
    private func applyFittingLayout(columns: Int, rows: Int) {
        guard columns > 0 && rows > 0 else { return }

        // spacing + insets (tweak to taste)
        let interItemSpacing: CGFloat = 12.0
        let interGroupSpacing: CGFloat = 12.0
        let sectionInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        let cvWidth = collectionView.bounds.width - (sectionInsets.leading + sectionInsets.trailing)
        let cvHeight = collectionView.bounds.height - (sectionInsets.top + sectionInsets.bottom)

        // candidate sizes to fit the grid
        let candidateWidth = (cvWidth - CGFloat(columns - 1) * interItemSpacing) / CGFloat(columns)
        let candidateHeight = (cvHeight - CGFloat(rows - 1) * interGroupSpacing) / CGFloat(rows)
        let cellSide = max(20.0, floor(min(candidateWidth, candidateHeight)))

        // Build compositional layout with absolute square items
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(cellSide),
                                              heightDimension: .absolute(cellSide))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // small internal padding so the container inside has breathing room
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

        let groupHeight = NSCollectionLayoutDimension.absolute(cellSide)
        let hGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
        let hGroup = NSCollectionLayoutGroup.horizontal(layoutSize: hGroupSize, subitem: item, count: columns)
        hGroup.interItemSpacing = .fixed(interItemSpacing)

        // vertical stack of rows
        let vGroupHeight = NSCollectionLayoutDimension.absolute(cellSide * CGFloat(rows) + interGroupSpacing * CGFloat(rows - 1))
        let vGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: vGroupHeight)
        let vGroup = NSCollectionLayoutGroup.vertical(layoutSize: vGroupSize, subitem: hGroup, count: rows)
        vGroup.interItemSpacing = .fixed(interGroupSpacing)

        let section = NSCollectionLayoutSection(group: vGroup)
        section.interGroupSpacing = interGroupSpacing
        section.contentInsets = sectionInsets
        section.orthogonalScrollingBehavior = .none

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.setCollectionViewLayout(layout, animated: false)

        // ensure it does not scroll
        collectionView.isScrollEnabled = false
    }

    // MARK: - DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatchThePairsCollectionViewCell.reuseId, for: indexPath) as? MatchThePairsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let card = game.cards[indexPath.item]
        cell.configure(card: card, backImageName: backImageName)
        return cell
    }

    // MARK: - Delegate (selection & game logic)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isProcessingSelection else { return }
        let idx = indexPath.item
        let card = game.cards[idx]
        if card.isFaceUp || card.isMatched { return }

        let result = game.chooseCard(at: idx)
        // animate changed indices
        for changedIndex in result.changed {
            let ip = IndexPath(item: changedIndex, section: 0)
            if let cell = collectionView.cellForItem(at: ip) as? MatchThePairsCollectionViewCell {
                let c = game.cards[changedIndex]
                let front = UIImage(named: c.imageName)
                let back = UIImage(named: backImageName)
                cell.flip(toFaceUp: c.isFaceUp || c.isMatched, frontImage: front, backImage: back)
            } else {
                // if cell isn't visible then reload that item so it shows correct state later
                collectionView.reloadItems(at: [ip])
            }
        }

        if result.matched {
            updateMatchedLabel()
            if game.isWin {
                presentWinAlert()
            }
            return
        }

        // if this was the second card and not matched, flip back after delay
        if result.changed.count == 2 {
            isProcessingSelection = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.game.flipBack(indices: result.changed)
                for changedIndex in result.changed {
                    let ip = IndexPath(item: changedIndex, section: 0)
                    if let cell = self.collectionView.cellForItem(at: ip) as? MatchThePairsCollectionViewCell {
                        let c = self.game.cards[changedIndex]
                        let front = UIImage(named: c.imageName)
                        let back = UIImage(named: self.backImageName)
                        cell.flip(toFaceUp: c.isFaceUp || c.isMatched, frontImage: front, backImage: back)
                    } else {
                        self.collectionView.reloadItems(at: [ip])
                    }
                }
                self.isProcessingSelection = false
            }
        }
        updateMatchedLabel()
    }

    private func presentWinAlert() {
        let alert = UIAlertController(title: "You win!", message: "Matched all pairs.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play again", style: .default, handler: { _ in
            self.startGame()
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
}
