import UIKit

class HeroImageCell: UICollectionViewCell {

    @IBOutlet weak var heroImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        heroImageView.layer.cornerRadius = 16
    }

    func configure(image: UIImage) {
        heroImageView.image = image

        let ratio = image.size.height / image.size.width
        heroImageView.heightAnchor
            .constraint(equalTo: heroImageView.widthAnchor, multiplier: ratio)
            .isActive = true
    }

    func configurePlaceholder() {
        heroImageView.image = nil
        heroImageView.backgroundColor = UIColor.systemGray5
    }

}
