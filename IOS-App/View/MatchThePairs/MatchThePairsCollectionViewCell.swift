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
           imageView.layer.cornerRadius = 18
           imageView.clipsToBounds = true

           imageView.contentMode = .scaleAspectFill
           imageView.clipsToBounds = true
       }

       func configure(card: Card, backImageName: String) {

           if card.isFaceUp || card.isMatched {
               imageView.image = UIImage(named: card.imageName)
           } else {
               imageView.image = UIImage(named: backImageName)
           }

           contentView.alpha = card.isMatched ? 0.6 : 1.0
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
           let radius = containerView?.layer.cornerRadius ?? contentView.layer.cornerRadius
           layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
       }
}
