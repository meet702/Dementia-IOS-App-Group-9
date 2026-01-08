import UIKit

final class GridCell: UICollectionViewCell {

    private let letterLabel = UILabel()
    private let numberLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(letterLabel)
        contentView.addSubview(numberLabel)

        letterLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),

            letterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            letterLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with model: CrosswordCell) {
        letterLabel.text = model.letter.map { String($0) }
        numberLabel.text = model.number.map { String($0) }

        letterLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        numberLabel.font = .systemFont(ofSize: 10, weight: .medium)
        numberLabel.textColor = .black

        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        if model.isBlocked {
            contentView.backgroundColor = .clear
            letterLabel.text = ""
            numberLabel.text = ""
            contentView.layer.borderWidth = 0
            return
        }

        if model.isCorrect {
            // Filled orange cell
            contentView.backgroundColor = UIColor.systemOrange
            contentView.layer.borderWidth = 0
            letterLabel.textColor = .white
        } else {
            // Empty cell with orange border
            contentView.backgroundColor = .clear
            contentView.layer.borderWidth = 1.5
            contentView.layer.borderColor = UIColor.systemOrange.cgColor
            letterLabel.textColor = UIColor.systemOrange
        }
    }

}
