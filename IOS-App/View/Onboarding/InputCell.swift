//
//  InputCell.swift
//  onboardingScreen
//
//  Created by SDC-USER on 16/12/25.
//

import Foundation

import UIKit

class InputCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    var onTextChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        textField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 0.4
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.addTarget(self,
                            action: #selector(textDidChange),
                            for: .editingChanged)
        addLeftPadding()
    }

    func configure(title: String, placeholder: String) {
        titleLabel.text = title
        textField.placeholder = placeholder
    }

    @objc private func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }
    
    private func addGenderChevron() {
        let chevron = UIImageView(image: UIImage(systemName: "chevron.compact.up.chevron.compact.down"))
        chevron.tintColor = .systemGray3
        chevron.contentMode = .scaleAspectFit
        chevron.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        chevron.center = container.center
        container.addSubview(chevron)

        textField.rightView = container
        textField.rightViewMode = .always
    }

    
    private let genderPicker = UIPickerView()
    private let genders = ["Male", "Female", "Other", "Prefer not to say"]

    func enableGenderPicker() {
        genderPicker.delegate = self
        genderPicker.dataSource = self

        textField.inputView = genderPicker
        textField.tintColor = .clear

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flex = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let done = UIBarButtonItem(
            title: "Done",
            style: .prominent,
            target: self,
            action: #selector(genderDone)
        )

        toolbar.setItems([flex, done], animated: false)
        textField.inputAccessoryView = toolbar

        addGenderChevron()
    }

    @objc private func genderDone() {
        let row = genderPicker.selectedRow(inComponent: 0)
        let value = genders[row]

        textField.text = value
        textField.textColor = .darkGray
        textField.resignFirstResponder()

        onTextChanged?(value)
    }

    private func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }

    
    @objc private func doneTapped() {
        textField.resignFirstResponder()
    }

}

extension InputCell: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return genders[row]
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        textField.text = genders[row]
        onTextChanged?(genders[row])
    }
}
