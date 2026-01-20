//
//  PeopleCollectionViewCell.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class PeopleCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var peopleNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!

    var onNameUpdated: ((String) -> Void)?
    var onImageTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true

        peopleNameLabel.textAlignment = .center
        peopleNameLabel.numberOfLines = 1
        peopleNameLabel.isUserInteractionEnabled = true

        editButton.layer.cornerRadius = 18
        editButton.clipsToBounds = true

        nameTextField.isHidden = true
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        nameTextField.textAlignment = .center

        let doubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap)
        )
        doubleTap.numberOfTapsRequired = 2
        peopleNameLabel.addGestureRecognizer(doubleTap)
        
        imageView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(imageTapped)
        )

        imageView.addGestureRecognizer(tap)
    }
    
    @objc private func imageTapped() {
        onImageTapped?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 50
    }

    func configurePeopleCell(person: PeopleModel) {
        peopleNameLabel.text = person.personName
        nameTextField.text = person.personName
        imageView.image = person.personImage
    }

    @objc private func handleDoubleTap() {
        peopleNameLabel.isHidden = true
        nameTextField.isHidden = false
        nameTextField.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishEditing()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        finishEditing()
    }

    private func finishEditing() {
        nameTextField.resignFirstResponder()

        let newName = nameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let newName = newName, !newName.isEmpty {
            peopleNameLabel.text = newName
            onNameUpdated?(newName)
        }

        nameTextField.isHidden = true
        peopleNameLabel.isHidden = false
    }
}
