import UIKit

class HintCell: UICollectionViewCell {

    @IBOutlet weak var hintLabel: UILabel!

    func configure(with hint: CrosswordWord) {
        hintLabel.text = hint.answer
    }
}
