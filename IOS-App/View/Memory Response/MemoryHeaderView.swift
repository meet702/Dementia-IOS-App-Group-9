import UIKit

class MemoryHeaderView: UIView {
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    static func loadFromNib() -> MemoryHeaderView {
           return UINib(nibName: "MemoryHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! MemoryHeaderView
    }

    func setupLayout() {
        containerView.layer.cornerRadius = 16
        headerImageView.layer.cornerRadius = 16
    }

}
