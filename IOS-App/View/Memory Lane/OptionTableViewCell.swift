//
//  OptionTableViewCell.swift
//  MemoryLane
//
//  Created by SDC-User on 08/12/25.
//

import Foundation
import UIKit
class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var optionLabel: UILabel!

    func configure(title: String, selected: Bool) {
        optionLabel.text = title

        let symbolName = selected ? "checkmark.circle.fill" : "circle"
        selectButton.setImage(UIImage(systemName: symbolName), for: .normal)
        selectButton.tintColor = selected ? UIColor.systemOrange : UIColor.systemGray

        optionLabel.textColor = .black
        backgroundColor = .clear
        selectionStyle = .none
    }
}
