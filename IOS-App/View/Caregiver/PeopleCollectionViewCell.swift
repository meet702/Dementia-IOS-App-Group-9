//
//  PeopleCollectionViewCell.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class PeopleCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var peopleNameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.contentMode = .scaleAspectFill
        
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true

        peopleNameLabel.textAlignment = .center
        peopleNameLabel.numberOfLines = 1
        editButton.layer.cornerRadius = 18
        editButton.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 50
    }
    
    func configurePeopleCell(person: PeopleModel) {
        peopleNameLabel.text = person.personName
        imageView.image = person.personImage
        
    }
    
    @IBAction func editDetailsButtonTapped(_ sender: UIButton) {
        guard let parentVC = self.findViewController() as? PeopleViewController else {
            print("Parent VC not found or is not PeopleViewController")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else { return }

        let presenter = EdgeModalPresenter()
        presenter.heightFraction = 0.55 // adjust: 0.40 = 40% height, set to 0.45 to be taller
        presenter.cornerRadius = 22
        presenter.setContent(detailsVC) // embed your details VC

        // present
        presenter.presentAnimated(from: parentVC)
    }
    
}
