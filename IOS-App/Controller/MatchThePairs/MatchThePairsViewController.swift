import UIKit

class MatchThePairsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var matchedLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!

    var columns: Int = 3
    var rows: Int = 4
    var backImageName: String = "card_back"

    private lazy var pairsCount: Int = (columns * rows) / 2
    private lazy var game: MemoryGame = MemoryGame(pairsCount: pairsCount)
    private var layoutAppliedForSize: CGSize = .zero
    private var isProcessingSelection = false

    
    private var pauseOverlayView: UIView?
    private var isPausedState: Bool = false

    private func pauseGameState() {
        guard !isPausedState else { return }
        isPausedState = true
        collectionView.isUserInteractionEnabled = false
        isProcessingSelection = true

    }

    private func resumeGameState() {
        guard isPausedState else { return }
        isPausedState = false
        collectionView.isUserInteractionEnabled = true
        isProcessingSelection = false
        
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
    
    private func restartGame() {
        resumeGameState()
        isProcessingSelection = false
        startGame()
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false

        matchedLabel.text = "Matched: 0"
        difficultyLabel.text = "Difficulty: " + difficultyName()

        startGame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let currentSize = collectionView.bounds.size
        if currentSize != layoutAppliedForSize {
            layoutAppliedForSize = currentSize
            applyFittingLayout(columns: columns, rows: rows)
        }
    }

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

    private func applyFittingLayout(columns: Int, rows: Int) {
        guard columns > 0 && rows > 0 else { return }

        let interItemSpacing: CGFloat = 12.0
        let interGroupSpacing: CGFloat = 12.0
        let sectionInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        let cvWidth = collectionView.bounds.width - (sectionInsets.leading + sectionInsets.trailing)
        let cvHeight = collectionView.bounds.height - (sectionInsets.top + sectionInsets.bottom)

        let candidateWidth = (cvWidth - CGFloat(columns - 1) * interItemSpacing) / CGFloat(columns)
        let candidateHeight = (cvHeight - CGFloat(rows - 1) * interGroupSpacing) / CGFloat(rows)
        let cellSide = max(20.0, floor(min(candidateWidth, candidateHeight)))

        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(cellSide),
                                              heightDimension: .absolute(cellSide))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

        let groupHeight = NSCollectionLayoutDimension.absolute(cellSide)
        let hGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
        let hGroup = NSCollectionLayoutGroup.horizontal(layoutSize: hGroupSize, subitem: item, count: columns)
//        let hGroup = NSCollectionLayoutGroup.horizontal(
//            layoutSize: hGroupSize,
//            subitems: Array(repeating: item, count: columns)
//        )

        hGroup.interItemSpacing = .fixed(interItemSpacing)

        // vertical stack of rows
        let vGroupHeight = NSCollectionLayoutDimension.absolute(cellSide * CGFloat(rows) + interGroupSpacing * CGFloat(rows - 1))
        let vGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: vGroupHeight)
        let vGroup = NSCollectionLayoutGroup.vertical(layoutSize: vGroupSize, subitem: hGroup, count: rows)
        //let vGroup = NSCollectionLayoutGroup.vertical(layoutSize: vGroupSize, subitems: [hGroup])
//        let vGroup = NSCollectionLayoutGroup.vertical(
//            layoutSize: vGroupSize,
//            subitems: Array(repeating: hGroup, count: rows)
//        )

        vGroup.interItemSpacing = .fixed(interGroupSpacing)

        let section = NSCollectionLayoutSection(group: vGroup)
        section.interGroupSpacing = interGroupSpacing
        section.contentInsets = sectionInsets
        section.orthogonalScrollingBehavior = .none

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.isScrollEnabled = false
    }

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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isProcessingSelection, !isPausedState else { return }
        let idx = indexPath.item
        let card = game.cards[idx]
        if card.isFaceUp || card.isMatched { return }
        
        let result = game.chooseCard(at: idx)
        for changedIndex in result.changed {
            let ip = IndexPath(item: changedIndex, section: 0)
            if let cell = collectionView.cellForItem(at: ip) as? MatchThePairsCollectionViewCell {
                let c = game.cards[changedIndex]
                let front = UIImage(named: c.imageName)
                let back = UIImage(named: backImageName)
                cell.flip(toFaceUp: c.isFaceUp || c.isMatched, frontImage: front, backImage: back)
            } else {
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
