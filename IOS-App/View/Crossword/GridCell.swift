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

        letterLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        numberLabel.font = UIFont.systemFont(ofSize: 9, weight: .semibold)

        numberLabel.textColor = .darkGray
        letterLabel.textAlignment = .center
        numberLabel.numberOfLines = 1

        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            numberLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -2),

            letterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            letterLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    

    func configure(with model: CrosswordCell) {
        letterLabel.text = ""
        numberLabel.text = ""
        contentView.backgroundColor = .clear
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        letterLabel.textColor = .black
        numberLabel.textColor = .darkGray

        layer.cornerRadius = 6
        layer.masksToBounds = true

        if model.isBlocked {
            contentView.backgroundColor = .clear
            layer.borderWidth = 0
            letterLabel.text = ""
            numberLabel.text = ""
            return
        }
        
        if model.isSelected {
            contentView.backgroundColor = UIColor.orange.withAlphaComponent(0.45)
            layer.borderWidth = 2
            layer.borderColor = UIColor.orange.cgColor

            letterLabel.text = model.letter.map { String($0) } ?? ""
            letterLabel.textColor = .black
            numberLabel.text = model.numbers.map { "\($0)" }.joined(separator: ",")

            return
        }
        
        if model.isCorrectWord {
            contentView.backgroundColor = UIColor.orange
            layer.borderWidth = 1
            layer.borderColor = UIColor.orange.cgColor

            letterLabel.textColor = .white
            letterLabel.text = model.letter.map { String($0) } ?? ""

            numberLabel.textColor = .white
            numberLabel.text = model.numbers.isEmpty
                ? ""
                : model.numbers.map { "\($0)" }.joined(separator: ",")

            return
        }


        if model.isWrongLetter {
            contentView.backgroundColor = UIColor.red.withAlphaComponent(0.15)
            layer.borderWidth = 1
            layer.borderColor = UIColor.red.cgColor

            letterLabel.textColor = UIColor.red
            letterLabel.text = model.letter != nil ? String(model.letter!) : ""

            numberLabel.textColor = .darkGray
            numberLabel.text = model.numbers.isEmpty ? "" : model.numbers.map { "\($0)" }.joined(separator: ",")

            return
        }

        if model.isHighlighted {
            contentView.backgroundColor = UIColor.orange.withAlphaComponent(0.25)
            layer.borderWidth = 1
            layer.borderColor = UIColor.orange.cgColor

            letterLabel.text = model.letter.map { String($0) } ?? ""
            letterLabel.textColor = .black
            numberLabel.text = model.numbers.map { "\($0)" }.joined(separator: ",")

            return
        }

        // Default Cell
        contentView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        layer.borderWidth = 1
        layer.borderColor = UIColor.orange.withAlphaComponent(0.5).cgColor

        letterLabel.textColor = .black
        letterLabel.text = model.letter != nil ? String(model.letter!) : ""

        numberLabel.textColor = .darkGray
        numberLabel.text = model.numbers.isEmpty ? "" : model.numbers.map { "\($0)" }.joined(separator: ",")
    }
}
