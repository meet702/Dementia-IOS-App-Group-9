import UIKit

class MemoryLaneCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardTextLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var newBadgeLabel: UILabel!

    private let gradientOverlayTag = 999

    private let cardCornerRadius: CGFloat = 31
    private let gradientBottomAlpha: CGFloat = 0.65
    private let gradientTopPadding: CGFloat = 8.0
    private let fallbackGradientHeight: CGFloat = 120

    private weak var overlayView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = cardCornerRadius
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        cardTextLabel.textColor = .white
        cardTextLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)

        subtitleLabel.textColor = .white
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)

        newBadgeLabel.text = "NEW"
        newBadgeLabel.backgroundColor = .systemRed
        newBadgeLabel.textColor = .white
        newBadgeLabel.font = UIFont.boldSystemFont(ofSize: 12)
        newBadgeLabel.layer.cornerRadius = 7
        newBadgeLabel.clipsToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 8
        layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cardCornerRadius).cgPath

        if let overlay = overlayView {
            if let g = overlay.layer.sublayers?.first as? CAGradientLayer {
                g.frame = overlay.bounds
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        overlayView?.removeFromSuperview()
        overlayView = nil
        imageView.image = nil

    }

    func configureMemoryLaneCell(image: UIImage?,
                                 title: String = "Memory Lane",
                                 subtitle: String = "Revisit these moments") {

        cardTextLabel.text = title
        subtitleLabel.text = subtitle

        imageView.image = image

        contentView.layoutIfNeeded()
        cardView.layoutIfNeeded()
        imageView.layoutIfNeeded()

        addOrUpdateOverlayPinnedToText()
    }

    private func addOrUpdateOverlayPinnedToText() {
        overlayView?.removeFromSuperview()
        overlayView = nil

        let titleRectInCard = cardTextLabel.convert(cardTextLabel.bounds, to: cardView)
        let subtitleRectInCard = subtitleLabel.convert(subtitleLabel.bounds, to: cardView)

        var topOfTextY = min(titleRectInCard.minY, subtitleRectInCard.minY)

        if topOfTextY.isNaN || topOfTextY < -cardView.bounds.height || topOfTextY > cardView.bounds.height {
            let overlay = makeOverlayView()
            cardView.addSubview(overlay)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
                overlay.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
                overlay.heightAnchor.constraint(equalToConstant: fallbackGradientHeight)
            ])
            overlayView = overlay
            setNeedsLayout()
            layoutIfNeeded()
            bringLabelsAboveOverlay()
            return
        }

        topOfTextY = max(0, topOfTextY - gradientTopPadding)

        let overlay = makeOverlayView()
        cardView.addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = overlay.topAnchor.constraint(equalTo: cardView.topAnchor, constant: topOfTextY)
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            topConstraint,
            overlay.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        overlayView = overlay

        overlay.layoutIfNeeded()
        setNeedsLayout()
        layoutIfNeeded()

        bringLabelsAboveOverlay()
    }

    private func makeOverlayView() -> UIView {
        let overlay = UIView()
        overlay.backgroundColor = .clear
        overlay.isUserInteractionEnabled = false
        overlay.tag = gradientOverlayTag

        let g = CAGradientLayer()
        g.colors = [
            UIColor.black.withAlphaComponent(0.30).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        g.startPoint = CGPoint(x: 0.5, y: 1.0)
        g.endPoint = CGPoint(x: 0.5, y: 0.0)
        g.locations = [0.0, 1.0]

        g.frame = overlay.bounds
        overlay.layer.addSublayer(g)
        overlay.layer.masksToBounds = true

        return overlay
    }

    private func bringLabelsAboveOverlay() {
        cardView.bringSubviewToFront(cardTextLabel)
        cardView.bringSubviewToFront(subtitleLabel)
        cardTextLabel.layer.zPosition = 100
        subtitleLabel.layer.zPosition = 100
    }

    func showNewBadge(_ show: Bool) {
        newBadgeLabel.isHidden = !show
    }
}
