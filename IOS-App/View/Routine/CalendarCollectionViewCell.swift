//
//  CalendarCollectionViewCell.swift
//  TempApp
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var backgroundCard: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with model: DateModel, isSelected: Bool, isToday: Bool) {
        dayLabel.text = model.dayString
        dateLabel.text = model.dateString
        backgroundCard.layer.cornerRadius = 24
        
        backgroundCard.backgroundColor = .clear
        dayLabel.textColor = .lightGray
        dateLabel.textColor = .black


        if isSelected {
            dateLabel.textColor = .white
            backgroundCard.backgroundColor = .systemOrange
            return
        }
        if isToday {
            backgroundCard.backgroundColor = UIColor(red: 1.0, green: 0.85, blue: 0.70, alpha: 1.0)
            dateLabel.textColor = .systemOrange
            return
        }
    }

}
