//
//  DatePickerCell.swift
//  TempApp
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class DatePickerCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    var onDateChanged: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePicker.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    func configure(date: Date) {
        datePicker.date = date
    }

    @objc func valueChanged(_ sender: UIDatePicker) {
        onDateChanged?(sender.date)
    }
}
