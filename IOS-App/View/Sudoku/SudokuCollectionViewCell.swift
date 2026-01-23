//
//  SudokuCollectionViewCell.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class SudokuCollectionViewCell: UICollectionViewCell {
    static let reuseId = "SudokuCell"

    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var valueLabel: UILabel!

    private var topBorder: CALayer?
    private var leftBorder: CALayer?
    private var bottomBorder: CALayer?
    private var rightBorder: CALayer?

    private let thinBorderWidth: CGFloat = 0.4
    private let blockBorderWidth: CGFloat = 1.5
    private let borderColor = UIColor.systemGray5.cgColor
    private let blockColor = UIColor.systemGray2.cgColor


    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.clipsToBounds = true
        containerView.backgroundColor = .white

        valueLabel.textAlignment = .center
        valueLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)

        topBorder = CALayer()
        leftBorder = CALayer()
        bottomBorder = CALayer()
        rightBorder = CALayer()

        if let t = topBorder { layer.addSublayer(t) }
        if let l = leftBorder { layer.addSublayer(l) }
        if let b = bottomBorder { layer.addSublayer(b) }
        if let r = rightBorder { layer.addSublayer(r) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let _ = self.bounds
    }

    func configure(value: Int?, isGiven: Bool, isSelected: Bool, isConflict: Bool, row: Int, col: Int, totalRows: Int = 9, totalCols: Int = 9) {
        if let v = value {
            valueLabel.text = "\(v)"
            valueLabel.textColor = isGiven ? UIColor.systemOrange : UIColor.label
        } else {
            valueLabel.text = ""
        }

        if isConflict {
            containerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.06)
            valueLabel.textColor = .systemRed
        } else {
            containerView.backgroundColor = isSelected ? UIColor.systemGray5 : UIColor.white
            if !isGiven {
                valueLabel.textColor = .label
            }
        }

        updateBorders(row: row, col: col, totalRows: totalRows, totalCols: totalCols)
    }

    private func updateBorders(row: Int, col: Int, totalRows: Int, totalCols: Int) {
        let topW = (row % 3 == 0) ? blockBorderWidth : thinBorderWidth
        let leftW = (col % 3 == 0) ? blockBorderWidth : thinBorderWidth
        let bottomW = ((row + 1) % 3 == 0) ? blockBorderWidth : thinBorderWidth
        let rightW = ((col + 1) % 3 == 0) ? blockBorderWidth : thinBorderWidth

        let b = self.bounds

        topBorder?.backgroundColor = (topW == blockBorderWidth ? blockColor : borderColor)
        topBorder?.frame = CGRect(x: 0, y: 0, width: b.width, height: topW)

        leftBorder?.backgroundColor = (leftW == blockBorderWidth ? blockColor : borderColor)
        leftBorder?.frame = CGRect(x: 0, y: 0, width: leftW, height: b.height)

        bottomBorder?.backgroundColor = (bottomW == blockBorderWidth ? blockColor : borderColor)
        bottomBorder?.frame = CGRect(x: 0, y: b.height - bottomW, width: b.width, height: bottomW)

        rightBorder?.backgroundColor = (rightW == blockBorderWidth ? blockColor : borderColor)
        rightBorder?.frame = CGRect(x: b.width - rightW, y: 0, width: rightW, height: b.height)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        valueLabel.text = ""
        containerView.backgroundColor = .white
    }
}

