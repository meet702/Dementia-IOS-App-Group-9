import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backgroundCard: UIView!

    private var isToday = false

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundCard.layer.cornerRadius = 19
        updateUI()
    }

    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }

    func configure(with model: DateModel, isSelected: Bool, isToday: Bool) {
        dayLabel.text = model.dayString
        dateLabel.text = model.dateString
        self.isToday = isToday
        updateUI()
    }

    private func updateUI() {
        backgroundCard.backgroundColor = .clear

        dayLabel.alpha = 1.0
        dateLabel.alpha = 1.0

        dayLabel.textColor = .lightGray
        dateLabel.textColor = .black

        if isSelected {
            backgroundCard.backgroundColor = .systemOrange
            dateLabel.textColor = .white

            dayLabel.textColor = .lightGray
            return
        }

        if isToday {
            backgroundCard.backgroundColor = UIColor(
                red: 1.0,
                green: 0.85,
                blue: 0.70,
                alpha: 1.0
            )
            dateLabel.textColor = .systemOrange
        }
    }


}
