import UIKit

class MemoryRecapCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subTitleLabel: UILabel!

    @IBOutlet weak var cardView: UIView!

    func configureMemoryRecapCardCell() {
        titleLabel.text = "View Recap"

        subTitleLabel.text = "A look back at your beautiful moments"

        cardView.layer.cornerRadius = 33
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 7)
        layer.shadowRadius = 8
        layer.masksToBounds = false
    }

}
