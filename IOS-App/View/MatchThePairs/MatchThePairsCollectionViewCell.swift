import UIKit

class MatchThePairsCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "CardCell"
    private let backImageName = "card_back"
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           setupAppearance()
       }

       private func setupAppearance() {
           containerView.layer.cornerRadius = 18
           containerView.clipsToBounds = true

           // image view content mode
           imageView.contentMode = .scaleAspectFill
           imageView.clipsToBounds = true

           // apply shadow to the cell layer (outside clipped container)
           layer.shadowColor = UIColor.black.cgColor
           layer.shadowOpacity = 0.12
           layer.shadowRadius = 6
           layer.shadowOffset = CGSize(width: 0, height: 3)
           layer.masksToBounds = false
       }

       func configure(card: Card, backImageName: String) {
           if card.isFaceUp || card.isMatched {
               imageView.image = UIImage(named: card.imageName)
           } else {
               // show back image
               imageView.image = UIImage(named: backImageName)
           }

           // dim when matched
           if card.isMatched {
               contentView.alpha = 0.6
           } else {
               contentView.alpha = 1.0
           }

           accessibilityLabel = card.isFaceUp ? "Card \(card.pairId)" : "Hidden card"
       }

       func flip(toFaceUp: Bool, frontImage: UIImage?, backImage: UIImage?) {
           let newImage = toFaceUp ? frontImage : backImage
           UIView.transition(with: imageView, duration: 0.4, options: [.transitionFlipFromLeft, .allowAnimatedContent]) {
               self.imageView.image = newImage
           }
       }

       override func layoutSubviews() {
           super.layoutSubviews()
           // match shadow path to rounded corners for performance
           let radius = containerView?.layer.cornerRadius ?? contentView.layer.cornerRadius
           layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
       }
}
