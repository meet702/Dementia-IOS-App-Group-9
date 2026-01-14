//
//  TaskTableViewCell.swift
//  TempApp
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var onCheckTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateCheckButtonUI()
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        updateCheckButtonUI()
        onCheckTapped?()
    }

    func configure(task: RoutineTask, isCompleted: Bool) {

        // Title
        titleLabel.text = task.title

        // Time
        if let time = task.time {
            timePicker.date = time
        }

        // Check button
        updateCheckState(isChecked: isCompleted)

        // Subtitle / Description
        if let subtitle = task.subtitle, !subtitle.isEmpty {
            descriptionLabel.text = subtitle
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }

        // Completed state styling
        if isCompleted {
            titleLabel.textColor = .lightGray
            descriptionLabel.textColor = .lightGray
        } else {
            titleLabel.textColor = .label
            descriptionLabel.textColor = .secondaryLabel
        }
    }


    func updateCheckState(isChecked: Bool) {
        checkButton.isSelected = isChecked
        updateCheckButtonUI()
    }

    func updateCheckButtonUI() {
        if checkButton.isSelected {
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkButton.tintColor = .systemOrange
        } else {
            checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
            checkButton.tintColor = .lightGray
        }
    }

}
