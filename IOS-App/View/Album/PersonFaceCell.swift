//
//  PersonFaceCell.swift
//  IOS-App
//
//  Created by SDC-USER on 04/02/26.
//

import UIKit

class PersonFaceCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var faceImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    var onNameChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        faceImageView.layer.cornerRadius = 55
        let doubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didDoubleTapName)
        )
        doubleTap.numberOfTapsRequired = 2
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(doubleTap)

        nameTextField.delegate = self
    }
    
    @objc private func didDoubleTapName() {
        nameTextField.text = nameLabel.text == "Add Name" ? "" : nameLabel.text
        nameLabel.isHidden = true
        nameTextField.isHidden = false
        nameTextField.becomeFirstResponder()
    }
    
    private func finishEditing() {
        let text = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        let finalName = (text?.isEmpty == false) ? text! : ""
        nameLabel.text = finalName.isEmpty ? "Add Name" : finalName
        nameLabel.text = finalName

        nameTextField.resignFirstResponder()
        nameTextField.isHidden = true
        nameLabel.isHidden = false

        if finalName != "Add Name" {
            onNameChanged?(finalName)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishEditing()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        finishEditing()
    }

}


