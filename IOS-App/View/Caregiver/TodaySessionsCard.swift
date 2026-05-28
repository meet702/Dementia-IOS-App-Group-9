import UIKit

class TodaySessionsCard: UICollectionViewCell {

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cardView.layer.cornerRadius = 18
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.masksToBounds = false
    }

    func configure(imageSession: ImageSession) {

        dateLabel.text = imageSession.startedAt.formattedDate()
        timeLabel.text = imageSession.startedAt.formattedTime()

        if let image = SessionImageStore.shared.fetchImage(by: imageSession.wid) {
            imageView.image = image
        } else if let image = LocalImageStore.shared.fetchImage(by: imageSession.wid) {

            imageView.image = image

            SessionImageStore.shared.saveSessionImage(for: imageSession.wid)
        } else {
            imageView.image = UIImage(named: "photo_placeholder")
        }
    }

}
