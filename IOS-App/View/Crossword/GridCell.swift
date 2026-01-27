import UIKit

final class GridCell: UICollectionViewCell {

    private let letterLabel = UILabel()
    private let numberLabel = UILabel()  // Now displays multiple numbers

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
        numberLabel.font = UIFont.systemFont(ofSize: 9, weight: .semibold)  // Slightly smaller for multiple numbers

        numberLabel.textColor = .darkGray
        letterLabel.textAlignment = .center
        numberLabel.numberOfLines = 1  // Keep single line

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


        // GENERAL CELL APPEARANCE
        layer.cornerRadius = 6
        layer.masksToBounds = true

        // BLOCKED CELL (black square)
        if model.isBlocked {
            contentView.backgroundColor = .clear
            layer.borderWidth = 0
            letterLabel.text = ""
            numberLabel.text = ""
            return
        }
        
        // 1️⃣ SELECTED CELL (DARK ORANGE)
        if model.isSelected {
            contentView.backgroundColor = UIColor.orange.withAlphaComponent(0.45)
            layer.borderWidth = 2
            layer.borderColor = UIColor.orange.cgColor

            letterLabel.text = model.letter.map { String($0) } ?? ""
            letterLabel.textColor = .black
            numberLabel.text = model.numbers.map { "\($0)" }.joined(separator: ",")

            return
        }
        
        // -----------------------------
        // WORD IS CORRECT (SOLID ORANGE)
        // -----------------------------
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


        // -----------------------------
        // WRONG LETTER (RED STYLE)
        // -----------------------------
        if model.isWrongLetter {
            contentView.backgroundColor = UIColor.red.withAlphaComponent(0.15)
            layer.borderWidth = 1
            layer.borderColor = UIColor.red.cgColor

            letterLabel.textColor = UIColor.red
            letterLabel.text = model.letter != nil ? String(model.letter!) : ""

            numberLabel.textColor = .darkGray
            // CHANGED: Display multiple numbers
            numberLabel.text = model.numbers.isEmpty ? "" : model.numbers.map { "\($0)" }.joined(separator: ",")

            return
        }

        // 2️⃣ HIGHLIGHTED WORD (LIGHT ORANGE)
        if model.isHighlighted {
            contentView.backgroundColor = UIColor.orange.withAlphaComponent(0.25)
            layer.borderWidth = 1
            layer.borderColor = UIColor.orange.cgColor

            letterLabel.text = model.letter.map { String($0) } ?? ""
            letterLabel.textColor = .black
            numberLabel.text = model.numbers.map { "\($0)" }.joined(separator: ",")

            return
        }


        // DEFAULT NORMAL CELL
        contentView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        layer.borderWidth = 1
        layer.borderColor = UIColor.orange.withAlphaComponent(0.5).cgColor

        letterLabel.textColor = .black
        letterLabel.text = model.letter != nil ? String(model.letter!) : ""

        numberLabel.textColor = .darkGray
        // CHANGED: Display multiple numbers separated by comma
        numberLabel.text = model.numbers.isEmpty ? "" : model.numbers.map { "\($0)" }.joined(separator: ",")
    }
}
