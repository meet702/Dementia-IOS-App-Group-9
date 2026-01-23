//
//  RepeatCell.swift
//  TempApp
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class RepeatCell: UITableViewCell {

    @IBOutlet weak var repeatSwitch: UISwitch!
    
    var onSwitchChanged: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        repeatSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    @objc private func switchValueChanged() {
        onSwitchChanged?(repeatSwitch.isOn)
    }

}
