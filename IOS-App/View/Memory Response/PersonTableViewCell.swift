//
//  PersonTableViewCell.swift
//  MemoryLaneResponseFeature
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var personImageView: UIImageView!
    
    @IBOutlet weak var personNameLabel: UILabel!
    
    var onChevronTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(person: PersonSession) {
        personImageView.image = UIImage(named: person.image)
        personImageView.layer.cornerRadius = 26
        personNameLabel.text = person.personName
    }
    

    @IBAction func chevronTapped(_ sender: UIButton) {
        onChevronTapped?()
    }
    

}
